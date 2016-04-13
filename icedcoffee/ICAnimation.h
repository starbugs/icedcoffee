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

#import <Foundation/Foundation.h>
#import "icMacros.h"
#import "ICAnimationDelegate.h"
#import "ICAnimationTimingFunction.h"

@class ICNode;

/**
 @brief Abstract base class for node animations
 
 ICAnimation is an abstract base class defining the basis for animations on ICNode objects in
 the icedcoffee framework. You should use the ICBasicAnimation class if you wish to use the
 built-in animation support shipped with the framework. If you don't find the animation
 functionality you search for there, you should consider subclassing this class or
 the ICPropertyAnimation class.
 */
@interface ICAnimation : NSObject {
@protected
    BOOL _removedOnCompletion;
    ICAnimationTimingFunction *_timingFunction;
    id<ICAnimationDelegate> _delegate;
    BOOL _isFinished;
}

/**
 @brief Whether the receiver will be removed from a node once the animation is completed
 */
@property (nonatomic, assign) BOOL removedOnCompletion;

/**
 @brief The timing function used by the receiver to compute its animation values
 */
@property (nonatomic, retain) ICAnimationTimingFunction *timingFunction;

/**
 @brief A delegate receiving messages about the beginning and ending of the animation
 */
@property (nonatomic, assign) id<ICAnimationDelegate> delegate;

/**
 @brief Whether the receiver's animation is finished
 */
@property (nonatomic, readonly) BOOL isFinished;

/**
 @brief Returns a new autoreleased ICAnimation object
 */
+ (id)animation;

/**
 @brief Initializes the receiver
 */
- (id)init;

/**
 @brief Processes the receiver's animation on the given target node using the specified delta time
 
 @param target An ICNode defining the target of the animation
 @param deltaTime an icTime value defining the time elapsed since the receiver was called for
 the last time
 
 The default implementation of this method does nothing. Subclasses should override this method
 to implement animation value processing.
 */
- (void)processAnimationWithTarget:(ICNode *)target deltaTime:(icTime)dt;

@end
