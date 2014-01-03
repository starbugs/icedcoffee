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

#import "ICResponder.h"
#import "icMacros.h"

#define FORWARD_OSXEVENT_TO_NEXT_RESPONDER(eventMethod, eventClass) \
    - (void)eventMethod:(eventClass *)event \
    { \
        ICResponder *nextResponder = [self nextResponder]; \
        if (nextResponder) \
            [nextResponder eventMethod:event]; \
        else \
            [self noResponderFor:@selector(eventMethod:)]; \
    }

#define FORWARD_TOUCHEVENT_TO_NEXT_RESPONDER(eventMethod) \
    - (void)eventMethod:(NSSet *)touches withTouchEvent:(ICTouchEvent *)event \
    { \
        ICResponder *nextResponder = [self nextResponder]; \
        [nextResponder eventMethod:touches withTouchEvent:event]; \
    }

@implementation ICResponder

@synthesize nextResponder = _nextResponder;

- (ICResponder *)nextResponder
{
    return _nextResponder;
}

- (BOOL)acceptsFirstResponder
{
    // Override in subclass
    return NO;
}

- (BOOL)becomeFirstResponder
{
    // Override in subclass
    return YES;
}

- (BOOL)resignFirstResponder
{
    // Override in subclass
    return YES;
}

- (BOOL)makeFirstResponder
{
    // Override in subclass
    return NO;
}

#ifdef __IC_PLATFORM_DESKTOP
- (void)noResponderFor:(SEL)selector
{
    // Override in subclass
}
#endif // __IC_PLATFORM_DESKTOP

#if __IC_PLATFORM_DESKTOP

// Only visible nodes (nodes that draw something) will receive mouseEntered:
// and mouseExited: messages
- (void)mouseEntered:(ICMouseEvent *)event {} // not forwarded
- (void)mouseExited:(ICMouseEvent *)event {} // not forwarded

FORWARD_OSXEVENT_TO_NEXT_RESPONDER(mouseDown, ICMouseEvent)
FORWARD_OSXEVENT_TO_NEXT_RESPONDER(mouseDragged, ICMouseEvent)
FORWARD_OSXEVENT_TO_NEXT_RESPONDER(mouseUp, ICMouseEvent)
FORWARD_OSXEVENT_TO_NEXT_RESPONDER(mouseUpInside, ICMouseEvent)
FORWARD_OSXEVENT_TO_NEXT_RESPONDER(mouseUpOutside, ICMouseEvent)

FORWARD_OSXEVENT_TO_NEXT_RESPONDER(rightMouseDown, ICMouseEvent)
FORWARD_OSXEVENT_TO_NEXT_RESPONDER(rightMouseDragged, ICMouseEvent)
FORWARD_OSXEVENT_TO_NEXT_RESPONDER(rightMouseUp, ICMouseEvent)
FORWARD_OSXEVENT_TO_NEXT_RESPONDER(rightMouseUpInside, ICMouseEvent)
FORWARD_OSXEVENT_TO_NEXT_RESPONDER(rightMouseUpOutside, ICMouseEvent)

FORWARD_OSXEVENT_TO_NEXT_RESPONDER(otherMouseDown, ICMouseEvent)
FORWARD_OSXEVENT_TO_NEXT_RESPONDER(otherMouseDragged, ICMouseEvent)
FORWARD_OSXEVENT_TO_NEXT_RESPONDER(otherMouseUp, ICMouseEvent)
FORWARD_OSXEVENT_TO_NEXT_RESPONDER(otherMouseUpInside, ICMouseEvent)
FORWARD_OSXEVENT_TO_NEXT_RESPONDER(otherMouseUpOutside, ICMouseEvent)

FORWARD_OSXEVENT_TO_NEXT_RESPONDER(scrollWheel, ICMouseEvent)

FORWARD_OSXEVENT_TO_NEXT_RESPONDER(keyDown, ICKeyEvent)
FORWARD_OSXEVENT_TO_NEXT_RESPONDER(keyUp, ICKeyEvent)

#endif // __IC_PLATFORM_DESKTOP

#if __IC_PLATFORM_IOS

FORWARD_TOUCHEVENT_TO_NEXT_RESPONDER(touchesBegan)
FORWARD_TOUCHEVENT_TO_NEXT_RESPONDER(touchesCancelled)
FORWARD_TOUCHEVENT_TO_NEXT_RESPONDER(touchesEnded)
FORWARD_TOUCHEVENT_TO_NEXT_RESPONDER(touchesMoved)

#endif // __IC_PLATFORM_IOS

@end
