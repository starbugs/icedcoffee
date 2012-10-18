//  
//  Copyright (C) 2012 Tobias Lensing, Marcus Tillmanns
//  http://icedcoffee-framework.org
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//  

#import "ICView.h"
#import "ICScene.h"
#import "ICUIScene.h"
#import "ICSprite.h"
#import "ICNodeVisitorPicking.h"

@implementation ICView

@synthesize backing = _backing;
@synthesize clipsChildren = _clipsChildren;
@synthesize needsLayout = _needsLayout;
@synthesize autoresizingMask = _autoresizingMask;
@synthesize autoresizesSubviews = _autoresizesSubviews;
@synthesize background = _background;
@synthesize drawsBackground = _drawsBackground;

+ (id)view
{
    return [[[[self class] alloc] init] autorelease];
}

+ (id)viewWithSize:(CGSize)size
{
    return [[[[self class] alloc] initWithSize:size] autorelease];
}

- (id)init
{
    return [self initWithSize:CGSizeMake(0, 0)];
}

- (id)initWithSize:(CGSize)size
{
    if ((self = [super init])) {
        self.background = [ICSprite sprite];
        self.autoresizesSubviews = YES;
        self.size = kmVec3Make(size.width, size.height, 0);
        _clippingMask = [[ICSprite alloc] init];
        _clippingMask.size = self.size;
        _clippingMask.color = (icColor4B){255,255,255,255};
        
#if defined(DEBUG) && defined(ICEDCOFFEE_DEBUG)
        if ((size.width == 0 && size.height != 0) ||
            (size.width != 0 && size.height == 0)) {
            ICLog(@"Warning: initializing a view with an invalid size");
        }
#endif
    }
    return self;
}

- (void)dealloc
{
    [_backing release];
    _backing = nil;
    
    [_clippingMask release];
    _clippingMask = nil;
    
    self.background = nil;
    
    [super dealloc];
}

// FIXME: test this thoroughly
- (void)resizeWithOldSuperViewSize:(kmVec3)oldSuperviewSize
{
    if (oldSuperviewSize.x == 0 || oldSuperviewSize.y == 0)
        return;

    NSUInteger autoresizingMask = self.autoresizingMask;
    if (autoresizingMask) {
        kmVec3 newSuperviewSize = self.superview.size;
        kmVec3 leftTop = kmNullVec3, rightBottom = kmNullVec3, newSize = kmNullVec3;
        
        if (autoresizingMask & ICAutoResizingMaskLeftMarginFlexible) {
            leftTop.x = self.position.x / oldSuperviewSize.x * newSuperviewSize.x;
        } else {
            leftTop.x = self.position.x;
        }
        
        if (autoresizingMask & ICAutoResizingMaskTopMarginFlexible) {
            leftTop.y = self.position.y / oldSuperviewSize.y * newSuperviewSize.y;
        } else {
            leftTop.y = self.position.y;
        }

        if (autoresizingMask & ICAutoResizingMaskRightMarginFlexible) {
            rightBottom.x = (self.position.x + self.size.x) / oldSuperviewSize.x * newSuperviewSize.x;
        } else {
            rightBottom.x = newSuperviewSize.x - (oldSuperviewSize.x - (self.position.x + self.size.x));
        }

        if (autoresizingMask & ICAutoResizingMaskBottomMarginFlexible) {
            rightBottom.y = (self.position.y + self.size.y) / oldSuperviewSize.y * newSuperviewSize.y;
        } else {
            rightBottom.y = newSuperviewSize.y - (oldSuperviewSize.y - (self.position.y + self.size.y));
        }
        
        if (autoresizingMask & ICAutoResizingMaskWidthSizable) {
            newSize.x = rightBottom.x - leftTop.x;
        } else {
            newSize.x = self.size.x;
            if (autoresizingMask & ICAutoResizingMaskLeftMarginFlexible &&
                autoresizingMask & ICAutoResizingMaskRightMarginFlexible)
                leftTop.x = leftTop.x + (rightBottom.x - leftTop.x) / 2 - self.size.x / 2;
            else if (autoresizingMask & ICAutoResizingMaskLeftMarginFlexible &&
                     !(autoresizingMask & ICAutoResizingMaskRightMarginFlexible))
                leftTop.x = newSuperviewSize.x - (oldSuperviewSize.x - self.position.x);
        }
        
        if (autoresizingMask & ICAutoResizingMaskHeightSizable) {
            newSize.y = rightBottom.y - leftTop.y;
        } else {
            newSize.y = self.size.y;
            if (autoresizingMask & ICAutoResizingMaskTopMarginFlexible &&
                autoresizingMask & ICAutoResizingMaskBottomMarginFlexible)
                leftTop.y = leftTop.y + (rightBottom.y - leftTop.y) / 2 - self.size.y / 2;
            else if (autoresizingMask & ICAutoResizingMaskTopMarginFlexible &&
                     !(autoresizingMask & ICAutoResizingMaskBottomMarginFlexible))
                leftTop.y = newSuperviewSize.y - (oldSuperviewSize.y - self.position.y);
        }
        
        leftTop.x = roundf(leftTop.x);
        leftTop.y = roundf(leftTop.y);
        newSize.x = roundf(newSize.x);
        newSize.y = roundf(newSize.y);

        [self setPosition:leftTop];
        [self setSize:newSize];
    }
}

- (void)resizeSubviewsWithOldSuperviewSize:(kmVec3)oldSuperviewSize
{
    for (ICView *subview in [self subviews]) {
        [subview resizeWithOldSuperViewSize:oldSuperviewSize];
    }
}

- (void)setSize:(kmVec3)size
{
    if (size.x != self.size.x || size.y != self.size.y || size.z != self.size.z) {    
        kmVec3 oldSize = self.size;
        
        // Update the view's size
        [super setSize:size];
        [_backing setSize:size];
        [_background setSize:size];
        [_clippingMask setSize:size];
        
        if (_autoresizesSubviews) {
            [self resizeSubviewsWithOldSuperviewSize:oldSize];
        }
        
        // Mark the view for layouting
        [self setNeedsLayout:YES];
    }
}

- (void)setWantsRenderTextureBacking:(BOOL)wantsRenderTextureBacking
{
    if (wantsRenderTextureBacking) {
        [self setBacking:[ICRenderTexture renderTextureWithWidth:self.size.x
                                                          height:self.size.y
                                                     pixelFormat:ICPixelFormatDefault
                                               depthBufferFormat:ICDepthBufferFormatDefault
                                             stencilBufferFormat:ICStencilBufferFormatDefault]];
        _backing.frameUpdateMode = ICFrameUpdateModeOnDemand;
    } else {
        [self setBacking:nil];
    }
}

- (ICView *)backingContentView
{
    return ((ICUIScene *)_backing.subScene).contentView;
}

// FIXME: doesn't support exchanging an existing backing yet
- (void)setBacking:(ICRenderTexture *)renderTexture
{
    if (_backing && renderTexture) {
        NSAssert(nil, @"Replacing an existing backing is currently not supported");
    }
    
    if (renderTexture && !renderTexture.subScene) {
        renderTexture.subScene = [ICUIScene scene];
        renderTexture.subScene.clearColor = (icColor4B){0,0,0,0};
    }
    
    if (_backing && !renderTexture) {
        // Move render texture children back to self
        for (ICNode *child in [self backingContentView].children) {
            [super addChild:child];
        }
        [[self backingContentView] removeAllChildren];
    }
    
    if (!_backing && renderTexture) {
        for (ICNode *child in _children) {
            [((ICUIScene *)renderTexture.subScene).contentView addChild:child];
        }
        [super removeAllChildren];
    }
    
    if (_backing) {
        [super removeChild:_backing];
    }
    
    [_backing release];
    _backing = [renderTexture retain];
    
    if (_backing)
        [super addChild:_backing];
}

- (ICRenderTexture *)backing
{
    return _backing;
}

- (BOOL)clipsChildren
{
    if (_backing)
        return YES;
    
    return _clipsChildren;
}

- (void)setClipsChildren:(BOOL)clipsChildren
{
    _clipsChildren = clipsChildren;
}

- (void)setNeedsDisplay
{
    [_backing setNeedsDisplay];
    [super setNeedsDisplay];
}

- (void)setDrawsBackground:(BOOL)drawsBackground
{
    if (_drawsBackground != drawsBackground) {
        if (!_drawsBackground && drawsBackground) {
            [self addChild:self.background];
        } else if(_drawsBackground && !drawsBackground) {
            [self removeChild:self.background];
        }
        _drawsBackground = drawsBackground;
    }
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    if (_needsLayout) {
        [self layoutChildren];
        _needsLayout = NO;
    }
    
    if (!_backing) {
        // Perform clipping via stencil buffer if _clipsChildren is set to YES
        if (_clipsChildren) {
            glClearStencil(0);
            glClear(GL_STENCIL_BUFFER_BIT);
            
            glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
            glDepthMask(GL_FALSE);
            glEnable(GL_STENCIL_TEST);
            
            glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
            glStencilFunc(GL_ALWAYS, 1, 1);
            
            // Draw solid sprite in rectangular region of the view to stencil buffer
            [_clippingMask drawWithVisitor:visitor];
            
            glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
            glDepthMask(GL_TRUE);
            glStencilFunc(GL_EQUAL, 1, 1);
        }
        
        // FIXME: this can be a problem when doing depth testing
        if ([visitor isKindOfClass:[ICNodeVisitorPicking class]]) {
            BOOL depthTestingEnabled = glIsEnabled(GL_DEPTH_TEST);
            if (depthTestingEnabled) {
                glDisable(GL_DEPTH_TEST);
            }
            // Draw view as solid sprite for picking, so the view itself reacts to
            // user interaction events
            [_clippingMask drawWithVisitor:visitor];
            if (depthTestingEnabled) {
                glEnable(GL_DEPTH_TEST);
            }
        }
    }
}

- (void)childrenDidDrawWithVisitor:(ICNodeVisitor *)visitor
{
    if (_clipsChildren && !_backing) {
        glDisable(GL_STENCIL_TEST);
    }    
}

- (ICView *)superview
{
    return (ICView *)[self firstAncestorOfType:[ICView class]];
}

- (NSArray *)subviews
{
    return [self childrenOfType:[ICView class]];
}

- (void)addChild:(ICNode *)child
{
    if (!_backing) {
        [super addChild:child];
    } else {
        [[self backingContentView] addChild:child];
    }
}

- (void)insertChild:(ICNode *)child atIndex:(uint)index
{
    if (!_backing) {
        [super insertChild:child atIndex:index];
    } else {
        [[self backingContentView] insertChild:child atIndex:index];
    }
}

- (void)removeChild:(ICNode *)child
{
    if (!_backing) {
        [super removeChild:child];
    } else {
        [[self backingContentView] removeChild:child];
    }
}

- (void)removeChildAtIndex:(uint)index
{
    if (!_backing) {
        [super removeChildAtIndex:index];
    } else {
        [[self backingContentView] removeChildAtIndex:index];
    }
}

- (void)removeAllChildren
{
    if (!_backing) {
        [super removeAllChildren];
    } else {
        [[self backingContentView] removeAllChildren];
    }
}

- (NSArray *)children
{
    if (!_backing) {
        return [super children];
    } else {
        return [self backingContentView].children;
    }
}

// FIXME: childrenNotOfType missing
- (NSArray *)childrenOfType:(Class)classType
{
    if (!_backing) {
        return [super childrenOfType:classType];
    }
    return [[self backingContentView] childrenOfType:classType];
}

- (ICNode *)childForTag:(uint)tag
{
    if (!_backing) {
        return [super childForTag:tag];
    }
    return [[self backingContentView] childForTag:tag];
}

- (void)setAutoResizingMask:(ICAutoResizingMask)autoresizingMask
{
    _autoresizingMask = autoresizingMask;
}

- (void)setNeedsLayout
{
    [self setNeedsLayout:YES];
}

- (void)setNeedsLayout:(BOOL)needsLayout
{
    _needsLayout = needsLayout;
    if (needsLayout) {
        [self setNeedsDisplay];
    }
}

- (void)layoutChildren
{
    // Override in subclass
}

// ICContainer Protocol

- (BOOL)isContainer
{
    return YES;
}

@end
