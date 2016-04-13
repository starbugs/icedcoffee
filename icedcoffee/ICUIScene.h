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

#import "ICScene.h"

@class ICView;

/**
 @brief Defines a user interface scene
 
 The ICUIScene class adds a content view to ICScene and resizes it to the size of the
 scene automatically. This allows you to implement a view hierarchy that automatically
 resizes and/or re-layoutes itself based on the scene's size.
 */
@interface ICUIScene : ICScene {
    ICView *_contentView;
}

#pragma mark - Creating a UI Scene
/** @name Creating a UI Scene */

/**
 @brief Initializes the receiver with a default size of 400x300 points
 */
- (id)init;

/**
 @brief Initializes the receiver with the given size
 */
- (id)initWithSize:(kmVec3)size;


#pragma mark - Working with the Content View
/** @name Working with the Content View */

/**
 @brief The receiver's content view
 */
@property (nonatomic, retain) ICView *contentView;


#pragma mark - Managing the Scene's Size
/** @name Managing the Scene's Size */

/**
 @brief Sets the size of the receiver and automatically adjusts the size of the content view
 */
- (void)setSize:(kmVec3)size;

@end
