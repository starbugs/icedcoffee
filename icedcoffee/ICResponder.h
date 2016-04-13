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

#import "ICIdentifiable.h"

#import "icMacros.h"

#if __IC_PLATFORM_DESKTOP
#import "ICMouseResponder.h"
#import "ICKeyResponder.h"
#define EVENT_PROTOCOLS ICMouseResponder, ICKeyResponder
#elif __IC_PLATFORM_TOUCH
#import "ICTouchResponder.h"
#define EVENT_PROTOCOLS ICTouchResponder
#endif

/**
 @brief Defines an interface for handling events
 
 ICResponder defines an interface for handling events within the icedcoffee framework.
 Subclasses of ICResponder may receive user interface events and respond to them by implementing
 the corresponding event handling methods.
 */
@interface ICResponder : ICIdentifiable <EVENT_PROTOCOLS>
{
@private
    ICResponder *_nextResponder;
}


#pragma mark - Managing the Responder Chain
/** @name Managing the Responder Chain */

/**
 @brief The next responder in the responder chain
 */
@property (nonatomic, assign, getter=nextResponder) ICResponder *nextResponder;

/**
 @brief Called by the framework to ask whether the receiver accepts to become first responder
 
 The default implementation returns ``NO`` indicating that the receiver does not agree to become
 first responder. Overriding sub classes should return ``YES`` if the receiver should accept
 to become first responder.
 */
- (BOOL)acceptsFirstResponder;

/**
 @brief Called by the framework when the receiver is about to become first responder
 
 The default implementation returns ``YES`` to signal that the receiver accepts to become
 first responder. Subclases may override this method to change state or perform some action
 and/or return ``NO`` refusing to become first responder.
 */
- (BOOL)becomeFirstResponder;

/**
 @brief Called by the framework when the receiver is asked to resign first responder status
 
 The default implementation returns ``YES`` indicating that the receiver resigns first responder
 status. Overriding subclasses may return ``NO`` refusing to resign first responder status.
 */
- (BOOL)resignFirstResponder;

/**
 @brief Attempts to make the receiver the new first responder of its associated host view controller
 
 The default implementation does nothing. This method is overridden by ICNode as the associated
 host view controller is unknown for the ICResponder class.
 
 @return Returns ``YES`` if the receiver became first responder or ``NO`` otherwise.
 */
- (BOOL)makeFirstResponder;

#if __IC_PLATFORM_DESKTOP
/**
 @brief Handles events or action messages falling off the end of the responder chain
 
 The default implementation does nothing. This method is overridden by ICNode as the associated
 host view controller is required to implement the standard behavior (beeping if the event
 selector is ``keyDown:``).
 
 Note that ``selector`` must define a Cocoa event selector rather than an icedcoffee event
 selector.
 
 @param selector The event selector of the unhandled event.
 */
- (void)noResponderFor:(SEL)selector;
#endif // __IC_PLATFORM_DESKTOP

#if __IC_PLATFORM_DESKTOP

#pragma mark - Handling Mouse Events
/** @name Handling Mouse Events */

/**
 @brief Called by the framework when the user presses the left mouse button on the receiver
 */
- (void)mouseDown:(ICMouseEvent *)event;

/**
 @brief Called by the framework when the user drags using the left mouse button on the receiver
 */
- (void)mouseDragged:(ICMouseEvent *)event;

/**
 @brief Called by the framework when the user releases the left mouse button
 */
- (void)mouseUp:(ICMouseEvent *)event;

/**
 @brief Called by the framework when the mouse pointer entered the receiver's picking shape
 */
- (void)mouseEntered:(ICMouseEvent *)event;

/**
 @brief Called by the framework when the mouse pointer exited the receiver's picking shape
 */
- (void)mouseExited:(ICMouseEvent *)event;

/**
 @brief Called by the framework when the user presses the right mouse button on the receiver
 */
- (void)rightMouseDown:(ICMouseEvent *)event;

/**
 @brief Called by the framework when the user drags using the right mouse button on the receiver
 */
- (void)rightMouseDragged:(ICMouseEvent *)event;

/**
 @brief Called by the framework when the user releases the right mouse button
 */
- (void)rightMouseUp:(ICMouseEvent *)event;

/**
 @brief Called by the framework when the user presses the other mouse button on the receiver
 */
- (void)otherMouseDown:(ICMouseEvent *)event;

/**
 @brief Called by the framework when the user drags using the other mouse button on the receiver
 */
- (void)otherMouseDragged:(ICMouseEvent *)event;

/**
 @brief Called by the framework when the user releases the other mouse button
 */
- (void)otherMouseUp:(ICMouseEvent *)event;

/**
 @brief Called by the framework when the user scrolls using the mouse's scroll wheel
 */
- (void)scrollWheel:(ICMouseEvent *)event;


#pragma mark - Handling Key Events
/** @name Handling Key Events */

- (void)keyDown:(ICKeyEvent *)keyEvent;

- (void)keyUp:(ICKeyEvent *)keyEvent;

#endif // __IC_PLATFORM_DESKTOP


#if __IC_PLATFORM_IOS

#pragma mark - Handling Touch Events
/** @name Handling Touch Events */

/**
 @brief Called by the framework when the user began touching on the receiver's shape
 
 @param touches An NSSet containing ICTouch objects representing individual touches
 @param withTouchEvent An ICTouchEvent object representing the touch event
 */
- (void)touchesBegan:(NSSet *)touches withTouchEvent:(ICTouchEvent *)event;

/**
 @brief Called by the framework when touches were cancelled

 @param touches An NSSet containing ICTouch objects representing individual touches
 @param withTouchEvent An ICTouchEvent object representing the touch event
 */
- (void)touchesCancelled:(NSSet *)touches withTouchEvent:(ICTouchEvent *)event;

/**
 @brief Called by the framework when touches ended

 @param touches An NSSet containing ICTouch objects representing individual touches
 @param withTouchEvent An ICTouchEvent object representing the touch event
 */
- (void)touchesEnded:(NSSet *)touches withTouchEvent:(ICTouchEvent *)event;

/**
 @brief Called by the framework when the user's touches moved

 @param touches An NSSet containing ICTouch objects representing individual touches
 @param withTouchEvent An ICTouchEvent object representing the touch event
 */
- (void)touchesMoved:(NSSet *)touches withTouchEvent:(ICTouchEvent *)event;

#endif // __IC_PLATFORM_IOS

@end
