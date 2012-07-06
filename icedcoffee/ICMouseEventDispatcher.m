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

#import "ICMouseEventDispatcher.h"
#import "ICMouseEvent.h"
#import "ICHostViewController.h"
#import "ICResponder.h"
#import "ICScene.h"
#import "ICControl.h"


#ifdef __IC_PLATFORM_MAC

#import "ICHostViewControllerMac.h"
#import "Carbon/Carbon.h"
#import "Platforms/Mac/ICGLView.h"

#define DISPATCH_UPDOWN_EVENT(eventMethod) \
    - (void)eventMethod:(NSEvent *)event \
    { \
        [self dispatchEvent:event withSelector:@selector(eventMethod:)]; \
    }

#define DISPATCH_DRAGGED_EVENT(eventMethod) \
    - (void)eventMethod:(NSEvent *)event \
    { \
        _lastMouseLocation = [[ICMouseEvent eventWithNativeEvent:event hostView:_hostViewController.view] locationInHostView]; \
        _lastMouseModifierFlags = [event modifierFlags]; \
        ICMouseEvent *mouseEvent = [ICMouseEvent eventWithNativeEvent:event hostView:_hostViewController.view]; \
        [_lastMouseDownNode eventMethod:mouseEvent]; \
    }


@interface ICMouseEventDispatcher (Private)
- (ICScene *)scene;
- (CGPoint)locationFromEvent:(ICMouseEvent *)event;
- (NSEvent *)enterExitEventWithType:(NSEventType)eventType;
- (void)dispatchEvent:(NSEvent *)event withSelector:(SEL)selector;
- (void)dispatchControlEventWithEvent:(ICMouseEvent *)event
                    deepestHitControl:(ICControl *)deepestHitControl
                controlDispatchTarget:(ICControl *)controlDispatchTarget;
- (ICControlEvents)processControlEventsForEventType:(ICAbstractMouseEventType)eventType
                                        mouseButton:(ICMouseButton)mouseButton
                                  deepestHitControl:(ICControl *)deepestHitControl
                              controlDispatchTarget:(ICControl *)controlDispatchTarget
                                              event:(ICMouseEvent *)event;
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

- (BOOL)isMouseDownEventType:(NSEventType)eventType
{
    return eventType == NSLeftMouseDown  ||
           eventType == NSRightMouseDown ||
           eventType == NSOtherMouseDown;
}

- (BOOL)isMouseUpEventType:(NSEventType)eventType
{
    return eventType == NSLeftMouseUp  ||
           eventType == NSRightMouseUp ||
           eventType == NSOtherMouseUp;
}

- (ICControl *)controlForNode:(ICNode *)node
{
    if ([node isKindOfClass:[ICControl class]]) {
        // The node itself is a control
        return (ICControl *)node;
    } else {
        ICControl *ancestorControl = (ICControl *)[node firstAncestorOfType:[ICControl class]];
        if (ancestorControl) {
            // The node has an ancestor which is a control
            return ancestorControl;
        }
    }
    return nil; // no control found for given node
}

- (NSEvent *)enterExitEventWithType:(NSEventType)eventType
{
    NSTimeInterval eventTime = GetCurrentEventTime();
    NSEvent *e = [NSEvent enterExitEventWithType:eventType
                                        location:_lastMouseLocation
                                   modifierFlags:_lastMouseModifierFlags
                                       timestamp:eventTime
                                    windowNumber:_hostViewController.view.window.windowNumber
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
        _lastScrollNode = deepest;
        [newOverNodes addObject:deepest];
    } else {
        _lastScrollNode = nil;
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
                ICMouseEvent *mouseEvent = [ICMouseEvent eventWithNativeEvent:[self enterExitEventWithType:NSMouseExited]
                                                                     hostView:_hostViewController.view];
                [overNode mouseExited:mouseEvent];
            }
        }
    }

    // Check which new nodes are not in the current over nodes array and send them
    // a mouseEntered event
    if ([newOverNodes count]) {
        for (ICNode *newOverNode in newOverNodes) {
            if (![_overNodes containsObject:newOverNode]) {
                // New node not in old overNodes, so mouse entered
                ICMouseEvent *mouseEvent = [ICMouseEvent eventWithNativeEvent:[self enterExitEventWithType:NSMouseEntered]
                                                                     hostView:_hostViewController.view];
                [newOverNode mouseEntered:mouseEvent];
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

- (CGPoint)locationFromEvent:(ICMouseEvent *)event
{
    // FIXME: location must be translated to view frame
    if ([event type] == NSScrollWheel) {
        return _lastMouseLocation;
    }
    CGPoint location = [event locationInHostView];
    return location;
}

- (void)dispatchEvent:(NSEvent *)event withSelector:(SEL)selector
{
    // Convert NSEvent to ICMouseEvent
    ICMouseEvent *mouseEvent = [ICMouseEvent eventWithNativeEvent:event
                                                         hostView:_hostViewController.view];
    
    // Perform hit test with event location
    CGPoint location = [self locationFromEvent:mouseEvent];
    NSArray *hitNodes = [_hostViewController hitTest:location];

    // Get the deepest node the mouse cursor is over
    ICNode *deepestHitNode = (ICNode *)[hitNodes lastObject];
    
    // If event is mouseDown, store mouse down node, last mouse location, and modifier flags
    if ([self isMouseDownEventType:[mouseEvent type]]) {
        _lastMouseDownNode = deepestHitNode;
        _lastMouseLocation = location;
        _lastMouseModifierFlags = [mouseEvent modifierFlags];
    }
    
    // For the time being, set our dispatch target to the deepest hit node
    ICNode *dispatchTarget = deepestHitNode;
    
    // Assign new first responder via mouse down events
    if ([self isMouseDownEventType:[mouseEvent type]]) {
        
        if ([dispatchTarget acceptsFirstResponder]) {
            // Make the dispatch target the current first responder
            _hostViewController.currentFirstResponder = dispatchTarget;
        } else {
            // Make the first ancestor of the dispatch target accepting first responder
            // the new current first responder
            NSArray *ancestors = [dispatchTarget ancestors];
            for (ICNode *ancestor in ancestors) {
                if ([ancestor acceptsFirstResponder]) {
                    _hostViewController.currentFirstResponder = ancestor;
                    break;
                }
            }
        }
        
        // Note last mouse down control
        _lastMouseDownControl = [self controlForNode:dispatchTarget];
    }        
    // Mouse up events are dispatched to the node that received the corresponding mouse
    // down event previously
    else if ([self isMouseUpEventType:[mouseEvent type]]) {
        
        dispatchTarget = _lastMouseDownNode;
        // Reset _lastMouseDownNode, so it cannot produce side effects
        _lastMouseDownNode = nil;
    }

    // Peform event selector on dispatch target node
    if ([dispatchTarget respondsToSelector:selector]) {
        [dispatchTarget performSelector:selector withObject:mouseEvent];
    }

    
    // Control event dispatch:
    // Get the control of the deepest hit node
    ICControl *deepestHitControl = [self controlForNode:deepestHitNode];
    ICControl *controlDispatchTarget = _lastMouseDownControl;
    [self dispatchControlEventWithEvent:mouseEvent
                      deepestHitControl:deepestHitControl
                  controlDispatchTarget:controlDispatchTarget];
}

// FIXME: should dispatch ICMouseEvent instead of NSEvent
- (void)dispatchControlEventWithEvent:(ICMouseEvent *)event
                    deepestHitControl:(ICControl *)deepestHitControl
                controlDispatchTarget:(ICControl *)controlDispatchTarget
{
    // FIXME: need to implement repeated mouse down events
    if (controlDispatchTarget) {
        ICControlEvents controlEvent = 0;
        switch ([event type]) {
            case NSLeftMouseDown:
                controlEvent = [self processControlEventsForEventType:ICMouseDown
                                                          mouseButton:ICLeftMouseButton
                                                    deepestHitControl:deepestHitControl
                                                controlDispatchTarget:controlDispatchTarget
                                                                event:event];
                break;
            case NSLeftMouseUp:
                controlEvent = [self processControlEventsForEventType:ICMouseUp
                                                          mouseButton:ICLeftMouseButton
                                                    deepestHitControl:deepestHitControl
                                                controlDispatchTarget:controlDispatchTarget
                                                                event:event];
                break;
            case NSLeftMouseDragged:
                controlEvent = [self processControlEventsForEventType:ICMouseDragged
                                                          mouseButton:ICLeftMouseButton
                                                    deepestHitControl:deepestHitControl
                                                controlDispatchTarget:controlDispatchTarget
                                                                event:event];
                break;
            case NSRightMouseDown:
                controlEvent = [self processControlEventsForEventType:ICMouseDown
                                                          mouseButton:ICRightMouseButton
                                                    deepestHitControl:deepestHitControl
                                                controlDispatchTarget:controlDispatchTarget
                                                                event:event];
                break;
            case NSRightMouseUp:
                controlEvent = [self processControlEventsForEventType:ICMouseUp
                                                          mouseButton:ICRightMouseButton
                                                    deepestHitControl:deepestHitControl
                                                controlDispatchTarget:controlDispatchTarget
                                                                event:event];
                break;
            case NSRightMouseDragged:
                controlEvent = [self processControlEventsForEventType:ICMouseDragged
                                                          mouseButton:ICRightMouseButton
                                                    deepestHitControl:deepestHitControl
                                                controlDispatchTarget:controlDispatchTarget
                                                                event:event];
                break;
            case NSOtherMouseDown:
                controlEvent = [self processControlEventsForEventType:ICMouseDown
                                                          mouseButton:ICOtherMouseButton
                                                    deepestHitControl:deepestHitControl
                                                controlDispatchTarget:controlDispatchTarget
                                                                event:event];
                break;
            case NSOtherMouseUp:
                controlEvent = [self processControlEventsForEventType:ICMouseUp
                                                          mouseButton:ICOtherMouseButton
                                                    deepestHitControl:deepestHitControl
                                                controlDispatchTarget:controlDispatchTarget
                                                                event:event];
                break;
            case NSOtherMouseDragged:
                controlEvent = [self processControlEventsForEventType:ICMouseDragged
                                                          mouseButton:ICOtherMouseButton
                                                    deepestHitControl:deepestHitControl
                                                controlDispatchTarget:controlDispatchTarget
                                                                event:event];
                break;
        }
        [controlDispatchTarget sendActionsForControlEvent:controlEvent forEvent:event];
    }    
}

- (ICControlEvents)processControlEventsForEventType:(ICAbstractMouseEventType)eventType
                                        mouseButton:(ICMouseButton)mouseButton
                                  deepestHitControl:(ICControl *)deepestHitControl
                              controlDispatchTarget:(ICControl *)controlDispatchTarget
                                              event:(ICMouseEvent *)event
{
    ICControlEvents controlEvent = 0;
    switch (eventType) {
        case ICMouseDown:
            controlEvent = ICControlEventLeftMouseDown;
            break;
        case ICMouseUp:
            if (_isDragging) {
                [deepestHitControl sendActionsForControlEvent:ICConcreteControlEvent(mouseButton, ICAbstractControlEventMouseDragExit)
                                           forEvent:event];
                _isDragging = NO;
            }
            if (deepestHitControl == controlDispatchTarget) {
                controlEvent = ICConcreteControlEvent(mouseButton, ICAbstractControlEventMouseUpInside);
            } else {
                controlEvent = ICConcreteControlEvent(mouseButton, ICAbstractControlEventMouseUpOutside);
            }
            break;
        case ICMouseDragged:
            if (!_isDragging) {
                [deepestHitControl sendActionsForControlEvent:ICConcreteControlEvent(mouseButton, ICAbstractControlEventMouseDragEnter)
                                                     forEvent:event];
                _isDragging = YES;
            }
            if (deepestHitControl == controlDispatchTarget) {
                controlEvent = ICConcreteControlEvent(mouseButton, ICAbstractControlEventMouseDragInside);
            } else {
                controlEvent = ICConcreteControlEvent(mouseButton, ICAbstractControlEventMouseDragOutside);
            }
            break;
    }    
    return controlEvent;
}

- (void)mouseMoved:(NSEvent *)event
{
    // On mouse moved, note mouse location and current modifier flags; this will be used
    // in updateMouseOverState, which is called repeatedly when the scene is drawn to
    // send entered and exited events.
    _lastMouseLocation = [self locationFromEvent:[ICMouseEvent eventWithNativeEvent:event
                                                                           hostView:_hostViewController.view]];
    _lastMouseModifierFlags = [event modifierFlags];
    
    if (self.acceptsMouseMovedEvents) {
        [self dispatchEvent:event withSelector:@selector(mouseMoved:)];
    }
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
    [_lastScrollNode scrollWheel:[ICMouseEvent eventWithNativeEvent:event
                                                           hostView:_hostViewController.view]];
}

// Dispatch dragged events to first responder, all other events go to the responder that
// is currently located over the mouse cursor. Note that all events dispatched using
// DISPATCH_EVENT_TO_NODE_OVER_MOUSE_CURSOR() perform a distinct hit test. These events
// will work even if the mouse position is not being tracked by the dispatcher using
// mouse moved events.

// mouseDown events are straight forward -- they are simply dispatched to the respective deepest
// over node. mouseUp events are sent to the node that received the corresponding mouseDown event.
DISPATCH_UPDOWN_EVENT(mouseDown)
DISPATCH_UPDOWN_EVENT(mouseUp)
DISPATCH_UPDOWN_EVENT(rightMouseDown)
DISPATCH_UPDOWN_EVENT(rightMouseUp)
DISPATCH_UPDOWN_EVENT(otherMouseDown)
DISPATCH_UPDOWN_EVENT(otherMouseUp)

// Dragged events are sent to the current mouse responder only. This ensures that we
// do not lose dragged events when the mouse is dragged outside of dragged objects.
// Note that lastMouseLocation and lastMouseModifierFlags is updated here as well
// to ensure that entered/exited events are handled correctly when dragging objects.
DISPATCH_DRAGGED_EVENT(mouseDragged)
DISPATCH_DRAGGED_EVENT(rightMouseDragged)
DISPATCH_DRAGGED_EVENT(otherMouseDragged)

@end

#endif
