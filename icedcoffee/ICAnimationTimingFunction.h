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
 bezier curve, where the X axis is the time axis and the Y axis represents animation progression.
 The timing function transforms input time factors ``x`` in range [0,1] to output time factors
 ``y``, also in range [0,1], by computing the point at the given ``x`` coordinate on the curve
 and returning its ``y`` coordinate value (see the ICAnimationTimingFunction::transform: method).
 
 The function's bezier curve is defined by points (0,0), ICAnimationTimingFunction::c0,
 ICAnimationTimingFunction::c1, and (1,1). The start and end points of the curve cannot be changed.
 
 You may create a custom animation timing function using the
 ICAnimationTimingFunction::timingFunctionWithControlPointsC0:c1: method. Additionally, there are
 a couple of convenience methods to create common predefined timing functions such as
 ICAnimationTimingFunction::linearTimingFunction, ICAnimationTimingFunction::easeInTimingFunction
 or ICAnimationTimingFunction::easeOutTimingFunction.
 */
@interface ICAnimationTimingFunction : NSObject {
@protected
    kmVec2 _c0;
    kmVec2 _c1;
}

/**
 @brief Returns a new autoreleased linear animation timing function
 
 Creates a linear animation timing curve, mapping input time factors ``x`` to identical
 output time factors.
 */
+ (id)linearTimingFunction;

/**
 @brief Returns a new autoreleased ease-in animation timing function
 
 Ease-in animations are slower in the beginning, then smoothly accelerate and continue
 nearly linearly for values of ``x > 0.5``.
 */
+ (id)easeInTimingFunction;

/**
 @brief Returns a new autoreleased ease-out animation timing function
 
 Ease-out animations provide nearly linear animations for values of ``x < 0.5``, then decelerate
 smoothly for values of ``x`` approaching ``1.0``.
 */
+ (id)easeOutTimingFunction;

/**
 @brief Returns a new autoreleased animation timing function with the given control points
 */
+ (id)timingFunctionWithControlPointsC0:(kmVec2)c0 c1:(kmVec2)c1;

/**
 @brief Initializes the receiver with the given control points
 */
- (id)initWithControlPointsC0:(kmVec2)c0 c1:(kmVec2)c1;

/**
 @brief Returns the transformed time factor ``y`` for a given input time factor ``x``
 */
- (icTime)transform:(icTime)x;

@property (nonatomic, assign) kmVec2 c0;

@property (nonatomic, assign) kmVec2 c1;

@end
