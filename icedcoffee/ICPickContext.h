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
#import "icTypes.h"

/**
 @brief Defines contextual picking information used by ICNodeVisitorPicking
 */
@interface ICPickContext : NSObject {
    CGPoint _point;
    GLint _viewport[4];
}


#pragma mark - Creating a Pick Context
/** @name Creating a Pick Context */

/**
 @brief Returns an autoreleased context with the given point and viewport
 */
+ (id)pickContextWithPoint:(CGPoint)point viewport:(GLint *)viewport;

/**
 @brief Initializes the receiver with the given point and viewport
 */
- (id)initWithPoint:(CGPoint)point viewport:(GLint *)viewport;


#pragma mark - Using the Pick Context's Information
/** @name Using the Pick Context's Information */

/**
 @brief Defines the location to perform picking with
 */
@property (nonatomic, readonly) CGPoint point;

/**
 @brief Defines the viewport to perform picking in
 */
@property (nonatomic, readonly, getter=viewport) GLint *viewport;

@end
