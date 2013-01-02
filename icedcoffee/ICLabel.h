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
#import "ICFont.h"

@class ICSprite;
@class ICTextFrame;

#define ICLabelTextDidChange @"ICLabelTextDidChange"
#define ICLabelFontDidChange @"ICLabelFontDidChange"

/**
 @brief Implements a text view that cannot be edited by the user
 */
@interface ICLabel : ICView {
@protected
    ICTextFrame *_textFrame;
    BOOL _shouldNotApplyPropertiesFromAttributedText;
    BOOL _shouldNotApplyPropertiesFromBasicText;
    
    NSString *_text;
    NSAttributedString *_attributedText;
    ICFont *_font;
    NSString *_fontName;
    CGFloat _fontSize;
    icColor4B _color;
    float _gamma;
    BOOL _autoresizesToTextSize;
}

#pragma mark - Creating a Label
/** @name Creating a Label */

/**
 @brief Returns a new autoreleased label with the given text, using a font defined by
 the specified font name and size
 
 @param text The text displayed by the receiver
 @param fontName The name of the font used by the receiver
 @param fontSize The size in points of the font used by the receiver

 This method resizes the new label to the bounds of ``text`` and set's its
 ICLabel::autoresizesToTextSize property to ``YES``.
 */
+ (id)labelWithText:(NSString *)text fontName:(NSString *)fontName fontSize:(CGFloat)fontSize;

/**
 @brief Initializes the receiver with the given text and font defined by the specified font
 name and size

 @param text The text displayed by the receiver
 @param fontName The name of the font used by the receiver
 @param fontSize The size in points of the font used by the receiver

 This method resizes the receiver to the bounds of ``text`` and set's the receiver's
 ICLabel::autoresizesToTextSize property to ``YES``.
 */
- (id)initWithText:(NSString *)text fontName:(NSString *)fontName fontSize:(CGFloat)fontSize;

/**
 @brief Initializes the receiver with the given size
 */
- (id)initWithSize:(CGSize)size;

/**
 @brief Initializes the receiver with the given size and attributed text
 */
- (id)initWithSize:(CGSize)size attributedText:(NSAttributedString *)attributedText;


#pragma mark - Manipulating the Label's Text, Font and Color
/** @name Manipulating the Label's Text, Font and Color */

/**
 @brief Whether the receiver autoresizes itself to the contents of its ICLabel::text
 */
@property (nonatomic, assign) BOOL autoresizesToTextSize;

/**
 @brief The text displayed by the receiver
 
 If you set this property to a new value on a receiver that currently displays attributed text,
 the attributes previously set on ICLabel::attributedText will be lost. In this case, the receiver
 will use its font, color and gamma properties to display its text.
 */
@property (nonatomic, copy, setter=setText:) NSString *text;

/**
 @brief The attributed text displayed by the receiver
 
 Setting this property implicitly sets ICLabel::text to ``attributedText``'s string.
 The receiver's font, color and gamma properties will be set to the first corresponding attribute
 found in ``attributedText``.
 */
@property (nonatomic, copy, setter=setAttributedText:) NSAttributedString *attributedText;

@property (nonatomic, retain, setter=setFont:) ICFont *font;

/**
 @brief The name of the font used by the receiver to display text
 
 Setting a new font on a receiver that currently displays attributed text will rebuild the
 receiver's attributed text using its current font, color and gamma properties. Information
 stored in the attributed text to define rich text attributes will be lost.
 */
@property (nonatomic, copy, setter=setFontName:) NSString *fontName;

/**
 @brief The size in points of the font used by the receiver to display text

 Setting a new font on a receiver that currently displays attributed text will rebuild the
 receiver's attributed text using its current font, color and gamma properties. Information
 stored in the attributed text to define rich text attributes will be lost.
 */
@property (nonatomic, assign, setter=setFontSize:) CGFloat fontSize;

/**
 @brief The color of the receiver's text
 */
@property (nonatomic, assign, setter=setColor:) icColor4B color;

/**
 @brief The gamma value of the receiver's text
 */
@property (nonatomic, assign, setter=setGamma:) float gamma;

@end
