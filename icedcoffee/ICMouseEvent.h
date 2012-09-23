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
#import "ICOSXEvent.h"
#import "ICProjectionTransforms.h"

#ifdef __IC_PLATFORM_MAC

@class ICNode;

/**
 @brief Represents a mouse event
 */
@interface ICMouseEvent : ICOSXEvent

#pragma mark - Accessing System Event Properties
/** @name Accessing System Event Properties */

/**
 @brief The receiver's NSEvent button number
 */
@property (nonatomic, readonly, getter=buttonNumber) NSInteger buttonNumber;

/**
 @brief The receiver's NSEvent click count
 */
@property (nonatomic, readonly, getter=clickCount) NSInteger clickCount;

/**
 @brief The receiver's NSEvent pressure value
 */
@property (nonatomic, readonly, getter=pressure) float pressure;

/**
 @brief The receiver's NSEvent deltaX value for scroll events
 */
@property (nonatomic, readonly, getter=deltaX) CGFloat deltaX;

/**
 @brief The receiver's NSEvent deltaY value for scroll events
 */
@property (nonatomic, readonly, getter=deltaY) CGFloat deltaY;

/**
 @brief The receiver's NSEvent deltaZ value for scroll events
 */
@property (nonatomic, readonly, getter=deltaZ) CGFloat deltaZ;


#pragma mark - Obtaining the Event's Location
/** @name Obtaining the Event's Location */

/**
 @brief The event's location inside the host view
 
 @return Returns a CGPoint defining the location of the event relative to the host view's frame.
 Note that the returned location conforms to IcedCoffee's coordinate space, that is, the upper
 left corner of the host view is the origin of the coordinate space.
 */
- (CGPoint)locationInHostView;

/**
 @brief The event's location in the given node's coordinate space
 
 @return Returns a kmVec3 defining the location of the event relative to the node's local
 coordinate space.
 */
- (kmVec3)locationInNode:(ICNode<ICProjectionTransforms> *)node;

@end

#endif // __IC_PLATFORM_MAC

