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

#import "icAvailability.h"

#ifdef __IC_PLATFORM_MAC

#import "ICMouseEventDispatcher.h"
#import "ICMouseEvent.h"
#import "ICTouchEvent.h"
#import "Platforms/Mac/ICHostViewControllerMac.h"
#import "ICResponder.h"
#import "ICScene.h"
#import "ICControl.h"
#import "icUtils.h"

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
        [self.lastMouseDownNode eventMethod:mouseEvent]; \
    }

#define DISPATCH_TOUCH_EVENT(eventMethod) \
    - (void)eventMethod:(NSEvent *)event \
    { \
        ICTouchEvent *touchEvent = [ICTouchEvent eventWithNativeEvent:event hostView:_hostViewController.view]; \
        [self.lastScrollNode eventMethod:touchEvent];\
    }

ICAbstractMouseEventType ICAbstractMouseEventTypeFromEventType(ICOSXEventType eventType)
{
    switch (eventType) {
        case ICLeftMouseDown:
        case ICRightMouseDown:
        case ICOtherMouseDown:      return ICMouseDown;
            
        case ICLeftMouseUp:
        case ICRightMouseUp:
        case ICOtherMouseUp:        return ICMouseUp;
            
        case ICLeftMouseDragged:
        case ICRightMouseDragged:
        case ICOtherMouseDragged:   return ICMouseDragged;
    }
    return 0;
}

ICMouseButton ICMouseButtonFromEventType(ICOSXEventType eventType)
{
    switch (eventType) {
        case ICLeftMouseDown:
        case ICLeftMouseUp:
        case ICLeftMouseDragged:    return ICLeftMouseButton;
        
        case ICRightMouseDown:
        case ICRightMouseUp:
        case ICRightMouseDragged:   return ICRightMouseButton;
            
        case ICOtherMouseDown:
        case ICOtherMouseUp:
        case ICOtherMouseDragged:   return ICOtherMouseButton;
    }
    return 0;
}


@interface ICMouseEventDispatcher ()

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

@property (nonatomic, retain) ICNode *lastMouseDownNode;
@property (nonatomic, retain) ICNode *lastScrollNode;
@property (nonatomic, retain) ICControl *lastMouseDownControl;

@end


@implementation ICMouseEventDispatcher

// private
@synthesize lastMouseDownNode = _lastMouseDownNode;
@synthesize lastScrollNode = _lastScrollNode;
@synthesize lastMouseDownControl = _lastMouseDownControl;

// public
@synthesize acceptsMouseMovedEvents = _acceptsMouseMovedEvents;
@synthesize updatesEnterExitEventsContinuously = _updatesEnterExitEventsContinuously;

- (id)initWithHostViewController:(ICHostViewControllerMac *)hostViewController
{
    if ((self = [super init])) {
        _hostViewController = hostViewController;
        _previousMouseLocation = CGPointMake(-1, -1);
        _lastMouseLocation = CGPointMake(-1, -1);
        _lastMouseModifierFlags = 0;
        _eventNumber = 0;
        // Handle mouse moved events by default
        _acceptsMouseMovedEvents = YES; 
        _updatesEnterExitEventsContinuously = NO; 
    }
    return self;
}

- (void)dealloc
{
    [_overNodes release];
    
    self.lastMouseDownNode = nil;
    self.lastScrollNode = nil;
    self.lastMouseDownControl = nil;
    
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

- (void)prepareUpdateMouseOverState
{
    if (!_acceptsMouseMovedEvents ||
        (!_updatesEnterExitEventsContinuously &&
         _lastMouseLocation.x == _previousMouseLocation.x &&
         _lastMouseLocation.y == _previousMouseLocation.y))
        return;
    
    [_hostViewController hitTest:_lastMouseLocation deferredReadback:YES];
}

// Note: this will only work if the host view controller's view returns YES in acceptsFirstResponder
// and the view's window is set to accept mouse moved events.
- (void)updateMouseOverState:(BOOL)deferredReadback
{
    if (!_acceptsMouseMovedEvents ||
        (!_updatesEnterExitEventsContinuously &&
         _lastMouseLocation.x == _previousMouseLocation.x &&
         _lastMouseLocation.y == _previousMouseLocation.y))
        return;
    
    if (!_updatesEnterExitEventsContinuously)
        _previousMouseLocation = _lastMouseLocation;
    
    NSArray *hitNodes = deferredReadback ? [_hostViewController performHitTestReadback] :
                        [_hostViewController hitTest:_lastMouseLocation];
    
    NSMutableArray *newOverNodes = [NSMutableArray array];
    ICNode *deepest = [[hitNodes lastObject] retain];
    
    if (deepest) {
        self.lastScrollNode = deepest;
        [newOverNodes addObject:deepest];
    } else {
        self.lastScrollNode = nil;
    }
    
    NSArray *ancestors = [deepest ancestors];
    
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
    
    [deepest release];
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
    ICNode *deepestHitNode = (ICNode *)[[hitNodes lastObject] retain];
    
    // If event is mouseDown, store mouse down node, last mouse location, and modifier flags
    if ([self isMouseDownEventType:[mouseEvent type]]) {
        self.lastMouseDownNode = deepestHitNode;
        _lastMouseLocation = location;
        _lastMouseModifierFlags = [mouseEvent modifierFlags];
    }
    
    // For the time being, set our dispatch target to the deepest hit node
    ICNode *dispatchTarget = [deepestHitNode retain];
    
    // Assign new first responder via mouse down events
    if ([self isMouseDownEventType:[mouseEvent type]]) {        
        // Make the dispatch target the current first responder
        _hostViewController.currentFirstResponder = dispatchTarget;
        
        // Note last mouse down control
        self.lastMouseDownControl = ICControlForNode(dispatchTarget);
    }        
    // Mouse up events are dispatched to the node that received the corresponding mouse
    // down event previously
    else if ([self isMouseUpEventType:[mouseEvent type]]) {

        [dispatchTarget release];
        dispatchTarget = [self.lastMouseDownNode retain];
        self.lastMouseDownNode = nil;
    }

    // Peform event selector on dispatch target node
    if ([dispatchTarget respondsToSelector:selector]) {
        [dispatchTarget performSelector:selector withObject:mouseEvent];
    }

    
    // Control event dispatch:
    // Get the control of the deepest hit node
    ICControl *deepestHitControl = ICControlForNode(deepestHitNode);
    ICControl *controlDispatchTarget = self.lastMouseDownControl;
    [self dispatchControlEventWithEvent:mouseEvent
                      deepestHitControl:deepestHitControl
                  controlDispatchTarget:controlDispatchTarget];
    
    if ([self isMouseUpEventType:[mouseEvent type]]) {
        // Release last mouse down control if necessary
        self.lastMouseDownControl = nil;
    }

    // Release references to retained nodes
    [deepestHitNode release];
    [dispatchTarget release];
}

- (void)dispatchControlEventWithEvent:(ICMouseEvent *)event
                    deepestHitControl:(ICControl *)deepestHitControl
                controlDispatchTarget:(ICControl *)controlDispatchTarget
{
    // FIXME: need to implement repeated mouse down events
    if (controlDispatchTarget) {
        ICControlEvents controlEvent = 0;
        ICAbstractMouseEventType abstractType = ICAbstractMouseEventTypeFromEventType([event type]);
        ICMouseButton mouseButton = ICMouseButtonFromEventType([event type]);
        controlEvent = [self processControlEventsForEventType:abstractType
                                                  mouseButton:mouseButton
                                            deepestHitControl:deepestHitControl
                                        controlDispatchTarget:controlDispatchTarget
                                                        event:event];
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
            if ([event clickCount] > 1) {
                controlEvent = ICConcreteControlEvent(mouseButton, ICAbstractControlEventMouseDownRepeat);
            } else {
                controlEvent = ICConcreteControlEvent(mouseButton, ICAbstractControlEventMouseDown);
            }
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
    if (_hostViewController.frameUpdateMode == ICFrameUpdateModeSynchronized) {
        // For synchronized frame updates, we can just handle mouse events as the current mouse over
        // node and scroll nodes have been determined already
        [self handleMouseMoved:event];
    } else {
        // For on demand frame updates, we have to perform picking first
        [_hostViewController handlePendingMouseMovedEventOnNextFrameUpdate:event];
        //[_hostViewController setNeedsDisplay]; // FIXME: this essentially redraws the scene even if not necessary
    }
}

- (void)handleMouseMoved:(NSEvent *)event
{
    // On mouse moved, note mouse location and current modifier flags; this will be used
    // in updateMouseOverState, which is called repeatedly when the scene is drawn to
    // send entered and exited events.
    _lastMouseLocation = [self locationFromEvent:
                          [ICMouseEvent eventWithNativeEvent:event hostView:_hostViewController.view]];
    _lastMouseModifierFlags = [event modifierFlags];
    
    if (self.acceptsMouseMovedEvents) {
        if ([self.lastScrollNode respondsToSelector:@selector(mouseMoved:)]) {
            // Convert NSEvent to ICMouseEvent
            ICMouseEvent *mouseEvent = [ICMouseEvent eventWithNativeEvent:event
                                                                 hostView:_hostViewController.view];
            // Dispatch event to the node the mouse is currently over
            [self.lastScrollNode mouseMoved:mouseEvent];
        }
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
    //NSLog(@"dx: %f dy: %f", [event deltaX], [event deltaY]);
    // Performance: as the window server potentially sends a flood of scroll events, use over
    // nodes determined in updateMouseOverState instead of performing a hit test for each event.
    [self.lastScrollNode scrollWheel:[ICMouseEvent eventWithNativeEvent:event
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

DISPATCH_TOUCH_EVENT(touchesBeganWithEvent)
DISPATCH_TOUCH_EVENT(touchesMovedWithEvent)
DISPATCH_TOUCH_EVENT(touchesEndedWithEvent)
DISPATCH_TOUCH_EVENT(touchesCancelledWithEvent)

@end

#endif
