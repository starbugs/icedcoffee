//  
//  Copyright (C) 2012 Tobias Lensing, http://icedcoffee-framework.org
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
#import "ICSprite.h"

@implementation ICView

@synthesize backing = _backing;
@synthesize clipsChildren = _clipsChildren;

+ (id)viewWithSize:(CGSize)size
{
    return [[[[self class] alloc] initWithSize:size] autorelease];
}

- (id)initWithSize:(CGSize)size
{
    if ((self = [super init])) {
        self.size = kmVec3Make(size.width, size.height, 0);
        _clippingMask = [[ICSprite alloc] init];
        _clippingMask.size = self.size;
        _clippingMask.color = (icColor4B){255,255,255,255};
    }
    return self;
}

- (void)dealloc
{
    [_backing release];
    _backing = nil;
    
    [_clippingMask release];
    _clippingMask = nil;
    
    [super dealloc];
}

- (void)setSize:(kmVec3)size
{
    [super setSize:size];
    [_backing setSize:size];
}

- (void)setWantsRenderTextureBacking:(BOOL)wantsRenderTextureBacking
{
    if (wantsRenderTextureBacking) {
        [self setBacking:[ICRenderTexture renderTextureWithWidth:self.size.x
                                                          height:self.size.y
                                                     pixelFormat:kICPixelFormat_Default
                                               depthBufferFormat:kICDepthBufferFormat_Default
                                             stencilBufferFormat:kICStencilBufferFormat_Default]];
        _backing.frameUpdateMode = kICFrameUpdateMode_OnDemand;
    } else {
        [self setBacking:nil];
    }
}

// FIXME: doesn't support exchanging an existing backing yet
- (void)setBacking:(ICRenderTexture *)renderTexture
{
    if (_backing && renderTexture) {
        NSAssert(nil, @"Replacing an existing backing is currently not supported");
    }
    
    if (renderTexture && !renderTexture.subScene) {
        renderTexture.subScene = [ICScene sceneWithHostViewController:nil];
        renderTexture.subScene.clearColor = (icColor4B){0,0,0,0};
    }
    
    if (_backing && !renderTexture) {
        // Move render texture children back to self
        for (ICNode *child in _backing.subScene.children) {
            [super addChild:child];
        }
        [_backing.subScene removeAllChildren];
    }
    
    if (!_backing && renderTexture) {
        for (ICNode *child in _children) {
            [renderTexture.subScene addChild:child];
        }
        [self removeAllChildren];
    }
    
    if (_backing) {
        [self removeChild:_backing];        
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

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    if (_clipsChildren && !_backing) {
        glClearStencil(0);
        glClear(GL_STENCIL_BUFFER_BIT);
        
        glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
        glDepthMask(GL_FALSE);
        glEnable(GL_STENCIL_TEST);
        
        glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
        glStencilFunc(GL_ALWAYS, 1, 1);
        
        // Draw solid sprite in rectangular region of the view
        [_clippingMask drawWithVisitor:visitor];
        
        glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
        glDepthMask(GL_TRUE);
        glStencilFunc(GL_EQUAL, 1, 1);
    }
}

- (void)childrenDidDrawWithVisitor:(ICNodeVisitor *)visitor
{
    if (_clipsChildren && !_backing) {
        glDisable(GL_STENCIL_TEST);
    }    
}

- (void)addChild:(ICNode *)child
{
    if (!_backing) {
        [super addChild:child];
    } else {
        [self.backing.subScene addChild:child];
    }
}

- (void)insertChild:(ICNode *)child atIndex:(uint)index
{
    if (!_backing) {
        [super insertChild:child atIndex:index];
    } else {
        [self.backing.subScene insertChild:child atIndex:index];
    }
}

- (void)removeChild:(ICNode *)child
{
    if (!_backing) {
        [super removeChild:child];
    } else {
        [self.backing.subScene removeChild:child];
    }
}

- (void)removeChildAtIndex:(uint)index
{
    if (!_backing) {
        [super removeChildAtIndex:index];
    } else {
        [self.backing.subScene removeChildAtIndex:index];
    }
}

- (void)removeAllChildren
{
    if (!_backing) {
        [super removeAllChildren];
    } else {
        [self.backing.subScene removeAllChildren];
    }
}

- (NSArray *)children
{
    if (!_backing) {
        return [super children];
    } else {
        return self.backing.subScene.children;
    }
}

@end
