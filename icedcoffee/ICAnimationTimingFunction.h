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

#import <Foundation/Foundation.h>
#import "icTypes.h"

/**
 @brief Implements an animation timing function
 
 The ICAnimationTimingFunction class implements an animation timing function based on a cubic
 bezier curve. The bezier curve is defined by two control points, ICAnimationTimingFunction::c0
 and ICAnimationTimingFunction::c1. The start and end points of the curve are always set to (0,0)
 and (1,1).
 */
@interface ICAnimationTimingFunction : NSObject {
@protected
    kmVec2 _c0;
    kmVec2 _c1;
}

/**
 @brief Returns a new autoreleased linear animation timing function
 
 Creates a linear animation timing curve, mapping input values ``x`` to identical output time
 factors.
 */
+ (id)linearTimingFunction;

/**
 @brief Returns a new autoreleased ease-in animation timing function
 
 Ease-in animations are slower in the beginning, then smoothly accelerate and continue
 nearly linearly for values of ``t > 0.5``.
 */
+ (id)easeInTimingFunction;

/**
 @brief Returns a new autoreleased ease-out animation timing function
 
 Ease-out animations provide nearly linear animations for values of ``t < 0.5``, then decelerate
 smoothly for values of ``t`` approaching ``1.0``.
 */
+ (id)easeOutTimingFunction;

/**
 @brief Returns a new autoreleased animation timing function with the given control points
 */
+ (id)timingFunctionWithControlPoints:(kmVec2)c0 :(kmVec2)c1;

/**
 @brief Initializes the receiver with the given control points
 */
- (id)initWithControlPoints:(kmVec2)c0 :(kmVec2)c1;

/**
 @brief Returns the transformed time factor for a given input value ``x``
 */
- (icTime)timeFactor:(icTime)x;

@end
