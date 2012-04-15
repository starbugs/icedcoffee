//  
//  Copyright (C) 2012 Tobias Lensing
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

#import "ICResponder.h"
#import "icMacros.h"

#define FORWARD_NSEVENT_TO_NEXT_RESPONDER(eventMethod) \
    - (void)eventMethod:(NSEvent *)event \
    { \
        [[self nextResponder] eventMethod:event]; \
    }

#define FORWARD_UIEVENT_TO_NEXT_RESPONDER(eventMethod) \
    - (void)eventMethod:(NSSet *)touches withEvent:(UIEvent *)event \
    { \
        [[self nextResponder] eventMethod:touches withEvent:event]; \
    }

@implementation ICResponder

@synthesize nextResponder = _nextResponder;

- (BOOL)acceptsFirstResponder
{
    // Override in subclass
    return NO;
}

- (void)becomeFirstResponder
{
    // Override in subclass
}

- (void)resignFirstResponder
{
    // Override in subclass
}

#if __IC_PLATFORM_DESKTOP

- (void)mouseEntered:(NSEvent *)event {}
- (void)mouseExited:(NSEvent *)event {}

FORWARD_NSEVENT_TO_NEXT_RESPONDER(mouseDown)
FORWARD_NSEVENT_TO_NEXT_RESPONDER(mouseDragged)
FORWARD_NSEVENT_TO_NEXT_RESPONDER(mouseUp)

FORWARD_NSEVENT_TO_NEXT_RESPONDER(rightMouseDown)
FORWARD_NSEVENT_TO_NEXT_RESPONDER(rightMouseDragged)
FORWARD_NSEVENT_TO_NEXT_RESPONDER(rightMouseUp)

FORWARD_NSEVENT_TO_NEXT_RESPONDER(otherMouseDown)
FORWARD_NSEVENT_TO_NEXT_RESPONDER(otherMouseDragged)
FORWARD_NSEVENT_TO_NEXT_RESPONDER(otherMouseUp)

FORWARD_NSEVENT_TO_NEXT_RESPONDER(scrollWheel)

#endif // __IC_PLATFORM_DESKTOP

#if __IC_PLATFORM_IOS

FORWARD_UIEVENT_TO_NEXT_RESPONDER(touchesBegan)
FORWARD_UIEVENT_TO_NEXT_RESPONDER(touchesCancelled)
FORWARD_UIEVENT_TO_NEXT_RESPONDER(touchesEnded)
FORWARD_UIEVENT_TO_NEXT_RESPONDER(touchesMoved)

#endif // __IC_PLATFORM_IOS

@end
