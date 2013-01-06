//  
//  Copyright (C) 2013 Tobias Lensing, Marcus Tillmanns
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

#import "ICTouch.h"
#import "ICHostViewController.h"

#ifdef __IC_PLATFORM_IOS

@implementation ICTouch

@synthesize nativeTouch = _nativeTouch;
@synthesize node = _node;

+ (id)touchWithNativeTouch:(UITouch *)touch node:(ICNode *)node
{
    return [[[[self class] alloc] initWithNativeTouch:touch node:node] autorelease];
}

- (id)initWithNativeTouch:(UITouch *)touch node:(ICNode *)node
{
    if ((self = [super init])) {
        _nativeTouch = [touch retain];
        _node = [node retain];
    }
    return self;
}

- (void)dealloc
{
    [_nativeTouch release];
    [_node release];
    [super dealloc];
}

- (UIWindow *)window
{
    return _nativeTouch.window;
}

- (UIView *)hostView
{
    return [[ICHostViewController currentHostViewController] view];
}

- (NSUInteger)tapCount
{
    return _nativeTouch.tapCount;
}

- (NSTimeInterval)timestamp
{
    return _nativeTouch.timestamp;
}

- (UITouchPhase)phase
{
    return _nativeTouch.phase;
}

- (NSArray *)gestureRecognizers
{
    return _nativeTouch.gestureRecognizers;
}

- (CGPoint)locationInHostView
{
    return [_nativeTouch locationInView:[[ICHostViewController currentHostViewController] view]];
}

- (CGPoint)previousLocationInHostView
{
    return [_nativeTouch previousLocationInView:[[ICHostViewController currentHostViewController] view]];
}

- (kmVec3)locationInNode:(ICNode<ICProjectionTransforms> *)node
{
    return [node hostViewToNodeLocation:[self locationInHostView]];
}

- (kmVec3)previousLocationInNode:(ICNode *)node
{
    return [node hostViewToNodeLocation:[self previousLocationInHostView]];    
}

@end

#endif // __IC_PLATFORM_IOS
