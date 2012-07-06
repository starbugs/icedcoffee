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
#import "icTypes.h"

// Compatible to NSEventType
enum {
    ICLeftMouseDown = 1,
    ICLeftMouseUp = 2,
    ICRightMouseDown = 3,
    ICRightMouseUp = 4,
    ICMouseMoved = 5,
    ICLeftMouseDragged = 6,
    ICRightMouseDragged = 7,
    ICMouseEntered = 8,
    ICMouseExited = 9,
    ICScrollWheel = 22,
    ICOtherMouseDown = 25,
    ICOtherMouseUp = 26,
    ICOtherMouseDragged = 27
};
typedef NSUInteger ICOSXEventType;

/**
 @brief Base class for Mac OS X events
 
 The ICOSXEvent class aggregates NSEvent, binds it to a given host view and serves as a base
 class for implementing IcedCoffee specific event functionality.
 */
@interface ICOSXEvent : NSObject {
@protected
    NSEvent *_nativeEvent;
    NSView *_hostView;
}

/**
 @brief The native NSEvent object aggregated by the receiver
 */
@property (nonatomic, readonly) NSEvent *nativeEvent;

/**
 @brief The host view the receiver is being dispatched to
 */
@property (nonatomic, readonly) NSView *hostView;

/**
 @brief The system's graphics context for the receiver's NSEvent
 */
@property (nonatomic, readonly, getter=context) NSGraphicsContext *context;

/**
 @brief The receiver's location in its corresponding NSWindow (Y axis points upwards)
 */
@property (nonatomic, readonly, getter=locationInWindow) CGPoint locationInWindow;

/**
 @brief Modifier flags corresponding to NSEvent's specification
 */
@property (nonatomic, readonly, getter=modifierFlags) NSUInteger modifierFlags;

/**
 @brief The receiver's NSEvent's timestamp
 */
@property (nonatomic, readonly, getter=timestamp) NSTimeInterval timestamp;

/**
 @brief The type of event represented by the receiver
 */
@property (nonatomic, readonly, getter=type) ICOSXEventType type;

/**
 @brief The window of the receiver's NSEvent
 */
@property (nonatomic, readonly, getter=window) NSWindow *window;

/**
 @brief The window number of the receiver's NSEvent
 */
@property (nonatomic, readonly, getter=windowNumber) NSInteger windowNumber;

/**
 @brief The Carbon type associated with the receiver's NSEvent for representing an event
 */
@property (nonatomic, readonly, getter=eventRef) const void *eventRef;

/**
 @brief The CoreGraphics event object corresponding to the receiver's NSEvent
 */
@property (nonatomic, readonly, getter=CGEvent) CGEventRef CGEvent;


/**
 @brief Returns an autoreleased event with the given NSEvent object and host view
 */
+ (id)eventWithNativeEvent:(NSEvent *)event hostView:(NSView *)hostView;

/**
 @brief Initializes an event with the given NSEvent object and host view
 */
- (id)initWithNativeEvent:(NSEvent *)event hostView:(NSView *)hostView;

@end
