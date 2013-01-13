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

#import "ICAnimation.h"

@class ICNode;

/**
 @brief Abstract base class for property animations on nodes
 
 ICPropertyAnimation is an abstract base class implementing support for managing a property
 keypath on top of the ICAnimation superclass. The ICPropertyAnimation::keyPath property is
 thought to be used with key value coding. Subclasses should be designed to animate a single
 property defined by ICPropertyAnimation::keyPath. See the ICBasicAnimation class for an
 exemplary implementation providing basic animations on ICNode objects.
 */
@interface ICPropertyAnimation : ICAnimation {
@protected
    NSString *_keyPath;
}

@property (nonatomic, copy) NSString *keyPath;

+ (id)animationWithKeyPath:(NSString *)keyPath;

- (id)initWithKeyPath:(NSString *)keyPath;

@end
