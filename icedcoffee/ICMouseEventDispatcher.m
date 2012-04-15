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

#import "ICMouseEventDispatcher.h"
#import "ICHostViewController.h"
#import "ICResponder.h"
#import "ICScene.h"
#import "ICEventDelegate.h"


#ifdef __IC_PLATFORM_MAC

#import "ICHostViewControllerMac.h"
#import "Carbon/Carbon.h"
#import "Platforms/Mac/ICGLView.h"

#define DISPATCH_EVENT_TO_NODE_OVER_MOUSE_CURSOR(eventMethod) \
    - (void)eventMethod:(NSEvent *)event \
    { \
        [self dispatchEvent:event withSelector:@selector(eventMethod:)]; \
    }

#define DISPATCH_DRAGGED_EVENT_TO_FIRST_RESPONDER(eventMethod) \
    - (void)eventMethod:(NSEvent *)event \
    { \
        _lastMouseLocation = [event locationInWindow]; \
        _lastMouseModifierFlags = [event modifierFlags]; \
        [self dispatchEventToDelegates:event withSelector:@selector(eventMethod:)]; \
        [_hostViewController.currentFirstResponder eventMethod:event]; \
    }


@interface ICMouseEventDispatcher (Private)
- (ICScene *)scene;
- (CGPoint)locationFromEvent:(NSEvent *)event;
- (NSEvent *)enterExitEventWithType:(NSEventType)eventType;
- (void)dispatchEvent:(NSEvent *)event withSelector:(SEL)selector;
- (void)dispatchEventToDelegates:(NSEvent *)event withSelector:(SEL)selector;
@end


@implementation ICMouseEventDispatcher

@synthesize acceptsMouseMovedEvents = _acceptsMouseMovedEvents;

- (id)initWithHostViewController:(ICHostViewController *)hostViewController
{
    if ((self = [super init])) {
        _hostViewController = hostViewController;
        _lastMouseLocation = CGPointMake(-1, -1);
        _lastMouseModifierFlags = 0;
        _eventNumber = 0;
        _acceptsMouseMovedEvents = YES; // handle mouse moved events by default
    }
    return self;
}

- (void)dealloc
{
    [_overNodes release];
    [super dealloc];
}

- (NSEvent *)enterExitEventWithType:(NSEventType)eventType
{
    NSTimeInterval eventTime = GetCurrentEventTime();
    NSEvent *e = [NSEvent enterExitEventWithType:eventType
                                        location:_lastMouseLocation
                                   modifierFlags:_lastMouseModifierFlags
                                       timestamp:eventTime
                                    windowNumber:0
                                         context:[NSGraphicsContext currentContext]
                                     eventNumber:++_eventNumber
                                  trackingNumber:0
                                        userData:nil];
    return e;
}

// Note: this will only work if the host view controller's view returns YES in acceptsFirstResponder
// and the view's window is set to accept mouse moved events.
- (void)updateMouseOverState
{
    if (!self.acceptsMouseMovedEvents)
        return;
    
    NSMutableArray *newOverNodes = [NSMutableArray array];
    NSArray *hitNodes = [_hostViewController hitTest:_lastMouseLocation];
    ICNode *deepest = [hitNodes lastObject];
    NSArray *ancestors = [deepest ancestors];
    
    if (deepest) {
        [newOverNodes addObject:deepest];
    }
    
    // Check whether the deepest hit node's ancestors contain other hit nodes, and if so,
    // add them to a new overNodes array
    for (ICNode *ancestor in ancestors) {
        if ([hitNodes containsObject:ancestor]) {
            [newOverNodes addObject:ancestor];
        }
    }
    
    // Check which nodes are no longer on the current over nodes array and send them
    // a mouseExited event
    if (_overNodes) {
        for (ICNode *overNode in _overNodes) {
            if (![newOverNodes containsObject:overNode]) {
                // Node not in newOverNodes, so mouse exited
                [overNode mouseExited:[self enterExitEventWithType:NSMouseExited]];
            }
        }
    }

    // Check which new nodes are not in the current over nodes array and send them
    // a mouseEntered event
    if ([newOverNodes count]) {
        for (ICNode *newOverNode in newOverNodes) {
            if (![_overNodes containsObject:newOverNode]) {
                // New node not in old overNodes, so mouse entered
                [newOverNode mouseEntered:[self enterExitEventWithType:NSMouseEntered]];
            }
        }
    }
    
    // Get rid of old over nodes
    [_overNodes release];
    // Set new over nodes
    _overNodes = [newOverNodes retain];
}

- (ICScene *)scene
{
    return [_hostViewController scene];
}

- (CGPoint)locationFromEvent:(NSEvent *)event
{
    // FIXME: location must be translated to view frame
    if ([event type] == NSScrollWheel) {
        return _lastMouseLocation;
    }
    return [event locationInWindow];
}

- (void)dispatchEventToDelegates:(NSEvent *)event withSelector:(SEL)selector
{
    for (id<ICEventDelegate>delegate in _hostViewController.eventDelegates) {
        if ([delegate respondsToSelector:selector]) {
            [delegate performSelector:selector withObject:event];
        }
    }
}

- (void)dispatchEvent:(NSEvent *)event withSelector:(SEL)selector
{
    [self dispatchEventToDelegates:event withSelector:selector];
    
    // Perform hit test with event location
    CGPoint location = [self locationFromEvent:event];
    NSArray *hitNodes = [_hostViewController hitTest:location];
    
    // If event is mouseDown, store last mouse location and modifier flags
    if ([event type] == NSLeftMouseDown ||
        [event type] == NSRightMouseDown ||
        [event type] == NSOtherMouseDown)
    {
        _lastMouseLocation = location;
        _lastMouseModifierFlags = [event modifierFlags];
    }
    
    // Dispatch event to deepest node and assign new first responder if applicable
    ICResponder *deepest = (ICResponder *)[hitNodes lastObject];
    if (deepest)
    {
        if (([event type] == NSLeftMouseDown ||
             [event type] == NSRightMouseDown ||
             [event type] == NSOtherMouseDown) &&
            [deepest acceptsFirstResponder])
        {
            _hostViewController.currentFirstResponder = deepest;
        }
        
        [deepest performSelector:selector withObject:event];
    }
}

- (void)mouseMoved:(NSEvent *)event
{
    // On mouse moved, note mouse location and current modifier flags; this will be used
    // in updateMouseOverState, which is called repeatedly when the scene is drawn to
    // send entered and exited events.
    _lastMouseLocation = [event locationInWindow];
    _lastMouseModifierFlags = [event modifierFlags];
}

- (void)mouseEntered:(NSEvent *)event
{
    // TODO: track gl view
}

- (void)mouseExited:(NSEvent *)event
{
    // TODO: track gl view
}

- (void)scrollWheel:(NSEvent *)event
{
    // Performance: as the window server potentially sends a flood of scroll events, use over
    // nodes determined in updateMouseOverState instead of performing a hit test for each event.
    // What is more, send scroll events to all over nodes instead of just sending it to the
    // deepest node.
    for (ICNode *overNode in _overNodes) {
        [overNode scrollWheel:event];
    }
}

// Dispatch dragged events to first responder, all other events go to the responder that
// is currently located over the mouse cursor. Note that all events dispatched using
// DISPATCH_EVENT_TO_NODE_OVER_MOUSE_CURSOR() perform a distinct hit test. These events
// will work even if the mouse position is not being tracked by the dispatcher using
// mouse moved events.

// mouseDown and mouseUp events are straight forward -- they are simply dispatched to
// the respective deepest over node.
DISPATCH_EVENT_TO_NODE_OVER_MOUSE_CURSOR(mouseDown)
DISPATCH_EVENT_TO_NODE_OVER_MOUSE_CURSOR(mouseUp)
DISPATCH_EVENT_TO_NODE_OVER_MOUSE_CURSOR(rightMouseDown)
DISPATCH_EVENT_TO_NODE_OVER_MOUSE_CURSOR(rightMouseUp)
DISPATCH_EVENT_TO_NODE_OVER_MOUSE_CURSOR(otherMouseDown)
DISPATCH_EVENT_TO_NODE_OVER_MOUSE_CURSOR(otherMouseUp)

// Dragged events are sent to the current first responder only. This ensures that we
// do not lose dragged events when the mouse is dragged outside of dragged objects.
// Note that lastMouseLocation and lastMouseModifierFlags is updated here as well
// to ensure that entered/exited events are handled correctly when dragging objects.
DISPATCH_DRAGGED_EVENT_TO_FIRST_RESPONDER(mouseDragged)
DISPATCH_DRAGGED_EVENT_TO_FIRST_RESPONDER(rightMouseDragged)
DISPATCH_DRAGGED_EVENT_TO_FIRST_RESPONDER(otherMouseDragged)

@end

#endif
