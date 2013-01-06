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
#import "icMacros.h"
#import "ICAnimationDelegate.h"
#import "ICAnimationTimingFunction.h"

@class ICNode;

@interface ICAnimation : NSObject {
@protected
    BOOL _removedOnCompletion;
    ICAnimationTimingFunction *_timingFunction;
    id<ICAnimationDelegate> _delegate;
    BOOL _isFinished;
}

@property (nonatomic, assign) BOOL removedOnCompletion;

@property (nonatomic, retain) ICAnimationTimingFunction *timingFunction;

@property (nonatomic, assign) id<ICAnimationDelegate> delegate;

@property (nonatomic, readonly) BOOL isFinished;

+ (id)animation;

- (id)init;

- (void)processAnimationWithTarget:(ICNode *)target deltaTime:(icTime)dt;

@end
