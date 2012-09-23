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

#import "ICIdentifiable.h"

#import "icMacros.h"

#if __IC_PLATFORM_DESKTOP
#import "ICMouseResponder.h"
#define EVENT_PROTOCOLS ICMouseResponder
#elif __IC_PLATFORM_TOUCH
#import "ICTouchResponder.h"
#define EVENT_PROTOCOLS ICTouchResponder
#endif

/**
 @brief An abstract base class providing the foundation for event processing
 in the IcedCoffee framework
 
 <h3>Overview</h3>
 
 The ICResponder abstract base class is the IcedCoffee pendant to the
 <a href="http://goo.gl/7kL9i">NSResponder</a> and <a href="http://goo.gl/5WIzx">UIResponder</a>
 classes.
  
 In contrast to Apple's design, IcedCoffee implements both mouse and touch event handling in one
 class. Only those events supported by the respective target platform will be sent to the responder.
 An advantage of this design is that you may implement both mouse and touch event handlers in one
 subclass without further modification and thus reuse your code for both platforms. 
 
 <h3>Subclassing</h3>
 
 ICResponder should not be subclassed directly. Instead, you should subclass ICNode.
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
@property (nonatomic, assign) ICResponder *nextResponder;

/**
 @brief Overriding sub classes should return YES when the receiver accepts to become first responder
 
 The default implementation returns NO.
 */
- (BOOL)acceptsFirstResponder;

/**
 @brief Called by the framework when the receiver is about to become the first responder
 */
- (void)becomeFirstResponder;

/**
 @brief Called by the framework when another object is about to become the first responder
 */
- (void)resignFirstResponder;


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
