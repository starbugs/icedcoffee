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

#import "ICView.h"

@class ICSprite;

#define ICShaderRectangle @"ShaderRectangle"

/**
 @brief Draws a rounded rectangle with a gradient background and solid border
 */
@interface ICRectangle : ICView
{
@protected
    ICSprite* _sprite;
    float     _borderWidth;
    icColor4B _borderColor;
    icColor4B _gradientStartColor;
    icColor4B _gradientEndColor;
}

#pragma mark - Controlling the Rectangle's Appearance
/** @name Controlling the Rectangle's Appearance */

@property (nonatomic, assign, getter=borderWidth, setter=setBorderWidth:) float borderWidth; // in points

@property (nonatomic, assign) icColor4B borderColor;

@property (nonatomic, assign) icColor4B gradientStartColor;

@property (nonatomic, assign) icColor4B gradientEndColor;

@end
