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
 classes and works in collaboration with the <a href="http://goo.gl/ncoLJ">NSEvent</a> and
 <a href="http://goo.gl/D153o">UIEvent</a> classes found in Apple's AppKit and UIKit frameworks.
  
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


#pragma mark - Responder Chain
/** @name Responder Chain */

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

#pragma mark - Mouse Events (Mac Platform)
/** @name Mouse Events (Mac Platform) */

/**
 @brief Called by the framework when the user presses the left mouse button on the receiver's
 shape on screen
 */
- (void)mouseDown:(NSEvent *)event;

/**
 @brief Called by the framework when the user drags using the left mouse button on the receiver's
 shape on screen
 */
- (void)mouseDragged:(NSEvent *)event;

/**
 @brief Called by the framework when the user releases the left mouse button on the receiver's
 shape on screen
 */
- (void)mouseUp:(NSEvent *)event;

/**
 @brief Called by the framework when the mouse pointer entered the receiver's shape on screen
 */
- (void)mouseEntered:(NSEvent *)event;

/**
 @brief Called by the framework when the mouse pointer exited the receiver's shape on screen
 */
- (void)mouseExited:(NSEvent *)event;

/**
 @brief Called by the framework when the user presses the right mouse button on the receiver's
 shape on screen
 */
- (void)rightMouseDown:(NSEvent *)event;

/**
 @brief Called by the framework when the user drags using the right mouse button on the receiver's
 shape on screen
 */
- (void)rightMouseDragged:(NSEvent *)event;

/**
 @brief Called by the framework when the user releases the right mouse button on the receiver's
 shape on screen
 */
- (void)rightMouseUp:(NSEvent *)event;

/**
 @brief Called by the framework when the user presses the other mouse button on the receiver's
 shape on screen
 */
- (void)otherMouseDown:(NSEvent *)event;

/**
 @brief Called by the framework when the user drags using the other mouse button on the receiver's
 shape on screen
 */
- (void)otherMouseDragged:(NSEvent *)event;

/**
 @brief Called by the framework when the user releases the other mouse button on the receiver's
 shape on screen
 */
- (void)otherMouseUp:(NSEvent *)event;

/**
 @brief Called by the framework when the user scrolls using the mouse's scroll wheel
 */
- (void)scrollWheel:(NSEvent *)event;

#endif // __IC_PLATFORM_DESKTOP


#if __IC_PLATFORM_IOS

#pragma mark - Touch Events (iOS Platform)
/** @name Touch Events (iOS Platform) */

/**
 @brief Called by the framework when the user began touching on the receiver's shape
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

/**
 @brief Called by the framework when the user cancels touching on the receiver's shape
 */
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

/**
 @brief Called by the framework when the user ended touching on the receiver's shape
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

/**
 @brief Called by the framework when the user' touches moved on the receiver's shape
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

#endif // __IC_PLATFORM_IOS

@end
