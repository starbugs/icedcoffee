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
#import "ICProjectionTransforms.h"

#ifdef __IC_PLATFORM_IOS

@class ICNode;

/**
 @brief Represents a touch in an IcedCoffee scene on iOS
 */
@interface ICTouch : NSObject {
@protected
    UITouch *_nativeTouch;
    ICNode *_node;
}

@property (nonatomic, readonly) UITouch *nativeTouch;

@property (nonatomic, readonly) ICNode *node;

@property (nonatomic, readonly, getter=window) UIWindow *window;

@property (nonatomic, readonly, getter=hostView) UIView *hostView;

@property (nonatomic, readonly, getter=tapCount) NSUInteger tapCount;

@property (nonatomic, readonly, getter=timestamp) NSTimeInterval timestamp;

@property (nonatomic, readonly, getter=phase) UITouchPhase phase;

@property (nonatomic, readonly, getter=gestureRecognizers) NSArray *gestureRecognizers;

+ (id)touchWithNativeTouch:(UITouch *)touch node:(ICNode *)node;

/** @cond */ // Exclude from docs
- (id)init __attribute__((unavailable("Must use initWithNativeTouch: instead.")));
/** @endcond */

- (id)initWithNativeTouch:(UITouch *)touch node:(ICNode *)node;

- (CGPoint)locationInHostView;

- (CGPoint)previousLocationInHostView;

- (kmVec3)locationInNode:(ICNode<ICProjectionTransforms> *)node;

- (kmVec3)previousLocationInNode:(ICNode<ICProjectionTransforms> *)node;

@end

#endif // __IC_PLATFORM_IOS
