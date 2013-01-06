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

#import "ICKeyEventDispatcher.h"
#import "ICHostViewController.h"
#import "ICKeyEvent.h"
#import "Platforms/Mac/ICGLView.h"

#ifdef __IC_PLATFORM_MAC

#define DISPATCH_KEY_EVENT(eventMethod) \
    - (void)eventMethod:(NSEvent *)event \
    { \
        [self dispatchEvent:event withSelector:@selector(eventMethod:)]; \
    }

@implementation ICKeyEventDispatcher

@synthesize hostViewController = _hostViewController;

- (id)initWithHostViewController:(ICHostViewController *)hostViewController
{
    if ((self = [super init])) {
        _hostViewController = hostViewController;
    }
    return self;
}

- (void)dispatchEvent:(NSEvent *)event withSelector:(SEL)selector
{
    ICKeyEvent *keyEvent = [ICKeyEvent eventWithNativeEvent:event hostView:self.hostViewController.view];
    [[self.hostViewController currentFirstResponder] performSelector:selector withObject:keyEvent];
}

DISPATCH_KEY_EVENT(keyDown)
DISPATCH_KEY_EVENT(keyUp)

@end

#endif // __IC_PLATFORM_MAC
