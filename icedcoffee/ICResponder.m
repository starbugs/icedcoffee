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

#import "ICResponder.h"
#import "icMacros.h"

#define FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(eventMethod) \
    - (void)eventMethod:(ICMouseEvent *)event \
    { \
        [[self nextResponder] eventMethod:event]; \
    }

#define FORWARD_TOUCHEVENT_TO_NEXT_RESPONDER(eventMethod) \
    - (void)eventMethod:(NSSet *)touches withTouchEvent:(ICTouchEvent *)event \
    { \
        [[self nextResponder] eventMethod:touches withTouchEvent:event]; \
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

// Only visible nodes (nodes that draw something) will receive mouseEntered:
// and mouseExited: messages
- (void)mouseEntered:(ICMouseEvent *)event {} // not forwarded
- (void)mouseExited:(ICMouseEvent *)event {} // not forwarded

FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(mouseDown)
FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(mouseDragged)
FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(mouseUp)
FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(mouseUpInside)
FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(mouseUpOutside)

FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(rightMouseDown)
FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(rightMouseDragged)
FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(rightMouseUp)
FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(rightMouseUpInside)
FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(rightMouseUpOutside)

FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(otherMouseDown)
FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(otherMouseDragged)
FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(otherMouseUp)
FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(otherMouseUpInside)
FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(otherMouseUpOutside)

FORWARD_MOUSEEVENT_TO_NEXT_RESPONDER(scrollWheel)

#endif // __IC_PLATFORM_DESKTOP

#if __IC_PLATFORM_IOS

FORWARD_TOUCHEVENT_TO_NEXT_RESPONDER(touchesBegan)
FORWARD_TOUCHEVENT_TO_NEXT_RESPONDER(touchesCancelled)
FORWARD_TOUCHEVENT_TO_NEXT_RESPONDER(touchesEnded)
FORWARD_TOUCHEVENT_TO_NEXT_RESPONDER(touchesMoved)

#endif // __IC_PLATFORM_IOS

@end
