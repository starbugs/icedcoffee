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

#import "icMacros.h"

#ifdef __IC_PLATFORM_IOS

#import "ICTouchEventDispatcher.h"
#import "ICHostViewController.h"
#import "ICNode.h"

@implementation ICTouchEventDispatcher

- (id)initWithHostViewController:(ICHostViewController *)hostViewController
{
    if ((self = [super init])) {
        _hostViewController = hostViewController;
    }
    return self;
}

- (void)dispatchEvent:(UIEvent *)event
          withTouches:(NSSet *)touches
    withUIKitSelector:(SEL)selector
{
    NSArray *allTouches = [touches allObjects];
    for (UITouch *touch in allTouches) {
        CGPoint touchLocation = [touch locationInView:[_hostViewController view]];
        touchLocation.y = _hostViewController.view.bounds.size.height - touchLocation.y;
        NSArray *hitNodes = [_hostViewController hitTest:touchLocation];
        ICNode *deepest = [hitNodes lastObject];
        [deepest performSelector:selector withObject:touches withObject:event];
    }    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchEvent:event
            withTouches:touches
      withUIKitSelector:@selector(touchesBegan:withEvent:)];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchEvent:event
            withTouches:touches
      withUIKitSelector:@selector(touchesCancelled:withEvent:)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchEvent:event
            withTouches:touches
      withUIKitSelector:@selector(touchesEnded:withEvent:)];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchEvent:event
            withTouches:touches
      withUIKitSelector:@selector(touchesMoved:withEvent:)];
}

@end

#endif // __IC_PLATFORM_IOS
