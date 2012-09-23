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

#import <Foundation/Foundation.h>
#import "icMacros.h"

#ifdef __IC_PLATFORM_MAC

#import "ICMouseResponder.h"

enum {
    ICMouseDown     = 1 << 0,
    ICMouseUp       = 1 << 1,
    ICMouseDragged  = 1 << 2
};
typedef NSUInteger ICAbstractMouseEventType;


@class ICHostViewController;
@class ICResponder;
@class ICNode;
@class ICControl;

/**
 @brief Dispatches mouse events into the icedcoffee responder chain
 */
@interface ICMouseEventDispatcher : NSObject <ICMouseResponder>
{
@private
    ICHostViewController *_hostViewController;
    NSMutableArray *_overNodes;
    CGPoint _previousMouseLocation;
    CGPoint _lastMouseLocation;
    NSUInteger _lastMouseModifierFlags;
    ICNode *_lastMouseDownNode;
    ICNode *_lastScrollNode;
    ICControl *_lastMouseDownControl;
    BOOL _isDragging;
    NSUInteger _eventNumber;
    BOOL _acceptsMouseMovedEvents;
    BOOL _updatesEnterExitEventsContinuously;
}


#pragma mark - Initializing an Event Dispatcher
/** @name Initializing an Event Dispatcher */

- (id)initWithHostViewController:(ICHostViewController *)hostViewController;


#pragma mark - Tracking the Mouse Movement
/** @name Tracking the Mouse Movement */

@property (nonatomic, assign) BOOL acceptsMouseMovedEvents;
@property (nonatomic, assign) BOOL updatesEnterExitEventsContinuously;
- (void)prepareUpdateMouseOverState;
- (void)updateMouseOverState:(BOOL)deferredReadback;


#pragma mark - Handling and Dispatching Mouse Events
/** @name Handling and Dispatching Mouse Events */

- (void)mouseDown:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (void)mouseEntered:(NSEvent *)event;
- (void)mouseExited:(NSEvent *)event;
- (void)mouseMoved:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;

- (void)rightMouseDown:(NSEvent *)event;
- (void)rightMouseDragged:(NSEvent *)event;
- (void)rightMouseUp:(NSEvent *)event;

- (void)otherMouseDown:(NSEvent *)event;
- (void)otherMouseDragged:(NSEvent *)event;
- (void)otherMouseUp:(NSEvent *)event;

- (void)scrollWheel:(NSEvent *)event;

@end

#endif // __IC_PLATFORM_MAC
