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

#import "ICScrollView.h"
#import "ICScene.h"
#import "ICCamera.h"

@interface ICScrollView (Private)
- (ICView *)contentView;
@end

@implementation ICScrollView

@synthesize contentSize = _contentSize;
@synthesize contentOffset = _contentOffset;

- (id)initWithSize:(CGSize)size
{
    if ((self = [super initWithSize:size])) {
        [self setClipsChildren:YES];
    }
    return self;
}

- (void)dealloc
{
    [_contentView release];
    [super dealloc];
}

- (ICView *)contentView
{
    if (self.backing) {
        return [self backingContentView];
    }
    
    if (!_contentView) {
        _contentView = [[ICView alloc] initWithSize:CGSizeMake(self.size.x, self.size.y)];
        _contentView.name = @"Content view";
        [super addChild:_contentView];
    }
    
    return _contentView;
}

#ifdef __IC_PLATFORM_MAC
- (void)scrollWheel:(ICMouseEvent *)event
{
    [self setContentOffset:kmVec3Make(_contentOffset.x + [event deltaX],
                                      _contentOffset.y + [event deltaY],
                                      0)];
}
#endif

- (void)setContentOffset:(kmVec3)contentOffset
{
    kmVec2 offsetMax = kmVec2Make(-_contentMax.x + _size.x, -_contentMax.y + _size.y);
    contentOffset.x = MAX(offsetMax.x, contentOffset.x);
    contentOffset.y = MAX(offsetMax.y, contentOffset.y);
    contentOffset.x = MIN(-_contentMin.x, contentOffset.x);
    contentOffset.y = MIN(-_contentMin.y, contentOffset.y);
    
    _contentOffset = contentOffset;

    [[self contentView] setPosition:_contentOffset];
    
    [self setNeedsDisplay];
}

- (void)setContentSize:(kmVec3)contentSize
{
    _contentSize = contentSize;
    _contentMin = kmNullVec3;
    _contentMax = _contentSize;
    [[self contentView] setSize:contentSize];
}

- (void)setSize:(kmVec3)size
{
    [super setSize:size];
}

- (void)calculateContentSize
{
    _contentMin = kmNullVec3;
    _contentMax = kmNullVec3;
    
    // FIXME: this should be generalized to support arbitrary transforms
    for (ICNode *child in [self contentView].children) {
        _contentMin.x = MIN(_contentMin.x, child.position.x);
        _contentMin.y = MIN(_contentMin.y, child.position.y);
        _contentMax.x = MAX(_contentMax.x, child.position.x + child.size.x);
        _contentMax.y = MAX(_contentMax.y, child.position.y + child.size.y);
    }
    
    kmVec3Subtract(&_contentSize, &_contentMax, &_contentMin);
}


// Composition overrides

- (void)addChild:(ICNode *)child
{
    [[self contentView] addChild:child];
    [self calculateContentSize];
}

- (void)insertChild:(ICNode *)child atIndex:(uint)index
{
    [[self contentView] insertChild:child atIndex:index];
}

- (void)removeChild:(ICNode *)child
{
    [[self contentView] removeChild:child];
}

- (void)removeChildAtIndex:(uint)index
{
    [[self contentView] removeChildAtIndex:index];
}

- (void)removeAllChildren
{
    [[self contentView] removeAllChildren];
}

- (NSArray *)children
{
    return [[self contentView] children];
}

// FIXME: childrenNotOfType missing
- (NSArray *)childrenOfType:(Class)classType
{
    return [[self contentView] childrenOfType:classType];
}

- (ICNode *)childForTag:(uint)tag
{
    return [[self contentView] childForTag:tag];
}


@end
