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

#import "ICMouseEvent.h"

#ifdef __IC_PLATFORM_MAC

@implementation ICMouseEvent

- (NSInteger)buttonNumber
{
    return [_nativeEvent buttonNumber];
}

- (NSInteger)clickCount
{
    return [_nativeEvent clickCount];
}

- (float)pressure
{
    return [_nativeEvent pressure];
}

- (CGFloat)deltaX
{
    return [_nativeEvent deltaX];
}

- (CGFloat)deltaY
{
    return [_nativeEvent deltaY];
}

- (CGFloat)deltaZ
{
    return [_nativeEvent deltaZ];
}

- (CGPoint)locationInHostView
{
    CGPoint location = [self.hostView convertPoint:[self locationInWindow] fromView:nil];
    location.y = self.hostView.bounds.size.height - location.y;
    return location;
}

- (kmVec3)locationInNode:(ICNode<ICProjectionTransforms> *)node
{
    return [node hostViewToNodeLocation:[self locationInHostView]];
}

@end

#endif // __IC_PLATFORM_MAC
