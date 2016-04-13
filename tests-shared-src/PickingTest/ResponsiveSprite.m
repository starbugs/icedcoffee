//  
//  Copyright (C) 2016 Tobias Lensing, Marcus Tillmanns
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

#import "ResponsiveSprite.h"

@implementation ResponsiveSprite

#ifdef __IC_PLATFORM_IOS

- (void)touchesBegan:(NSSet *)touches withTouchEvent:(ICTouchEvent *)event
{
    [self flipTextureVertically];
    [self setNeedsDisplay];
    
/*    ICTouch *touch = [touches anyObject];
    CGPoint hostViewPoint = [touch locationInHostView];
    kmVec3 nodePoint = [touch locationInNode:self];
    NSLog(@"host view point: (%f,%f)", hostViewPoint.x, hostViewPoint.y);
    NSLog(@"node point: (%f,%f)", nodePoint.x, nodePoint.y);*/
}

#elif defined(__IC_PLATFORM_MAC)

- (void)mouseUp:(ICMouseEvent *)event
{
    [self flipTextureVertically];
    [self setNeedsDisplay];

/*    CGPoint hostViewPoint = [event locationInHostView];
    kmVec3 nodePoint = [event locationInNode:self];
    NSLog(@"host view point: (%f,%f)", hostViewPoint.x, hostViewPoint.y);
    NSLog(@"node point: (%f,%f)", nodePoint.x, nodePoint.y);*/
}

- (void)mouseEntered:(ICMouseEvent *)event
{
    self.color = (icColor4B){255,0,0,255};
    [self setNeedsDisplay];
}

- (void)mouseExited:(ICMouseEvent *)event
{
    self.color = (icColor4B){255,255,255,255};
    [self setNeedsDisplay];
}

#endif // __IC_PLATFORM_*

@end
