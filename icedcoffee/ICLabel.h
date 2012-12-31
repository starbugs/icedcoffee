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

#import "ICView.h"

@class ICSprite;
@class ICTextFrame;

#define ICLabelTextDidChange @"ICLabelTextDidChange"
#define ICLabelFontDidChange @"ICLabelFontDidChange"

/**
 @brief Implements a read-only text view commonly used as label in user interfaces
 */
@interface ICLabel : ICView {
@protected
    ICTextFrame *_textFrame;
    
    NSAttributedString *_attributedText;
    NSString *_fontName;
    CGFloat _fontSize;
    icColor4B _color;
    BOOL _autoresizesToTextSize;
}

#pragma mark - Creating a Label
/** @name Creating a Label */

+ (id)labelWithText:(NSString *)text fontName:(NSString *)fontName fontSize:(CGFloat)fontSize;

- (id)initWithText:(NSString *)text fontName:(NSString *)fontName fontSize:(CGFloat)fontSize;

- (id)initWithSize:(CGSize)size;

- (id)initWithSize:(CGSize)size attributedText:(NSAttributedString *)attributedText;


#pragma mark - Manipulating the Label's Text, Font and Color
/** @name Manipulating the Label's Text, Font and Color */

@property (nonatomic, assign) BOOL autoresizesToTextSize;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy, setter=setAttributedText:) NSAttributedString *attributedText;
@property (nonatomic, copy, setter=setFontName:) NSString *fontName;
@property (nonatomic, assign, setter=setFontSize:) CGFloat fontSize;
@property (nonatomic, assign, getter=color, setter=setColor:) icColor4B color;

@end
