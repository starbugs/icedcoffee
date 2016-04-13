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
//  Note: the idea of an identfiable base class has been taken from the cocos3d project.

#import <Foundation/Foundation.h>
#import "Platforms/icGL.h"

/**
 @brief Base class for identifiable objects
 
 ICIdentifiable is a base class for all identifiable objects in icedcoffee. It allows you to
 identify objects based on a ICIdentifiable::tag and ICIdentifiable::name property. What is more,
 you may attach arbitrary user data to an object using the ICIdentifiable::userData property.
 */
@interface ICIdentifiable : NSObject
{
@private
    uint _tag;
    NSString *_name;
    void *_userData;
}


#pragma mark - Identifying an Object
/** @name Identifying an Object */

/**
 @brief A user-defined tag
 */
@property (nonatomic, assign) uint tag;

/**
 @brief A user-defined name
 */
@property (nonatomic, copy) NSString *name;

/**
 @brief Arbitrary user data
 */
@property (nonatomic, assign) void *userData;

@end
