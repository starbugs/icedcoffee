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

#import "ICPlanarNode.h"
#import "icFontDefs.h"
#import "ICFont.h"
#import "ICGlyphRun.h"

/**
 @brief Represents a low-level node drawing a single line of text
 
 The ICTextLine class represents a low-level planar node for drawing a single line of text
 consisting of one or more glyph runs (see the ICGlyphRun class). It allows you to typeset a text
 line using an attributed string providing font and formatting attributes.
 
 ICTextLine is not designed to be used as a user interface control. Instead, it may be used as
 a low-level element to implement user interface controls, view or composed nodes which need to
 display a single line of text. In most cases, it is a better choice to use ICTextFrame instead
 of ICTextLine to realize text displays. If you're looking for a user interface control to display
 text, see the ICLabel class.
 */
@interface ICTextLine : ICPlanarNode {
@protected
    CTLineRef _ctLine;
    NSMutableArray *_runs;
    NSAttributedString *_string;
    NSRange _stringRange;
    CGFloat _ascent;
    CGFloat _descent;
    CGFloat _leading;
    float _lineWidth;
}

/**
 @brief Returns a new autoreleased text line with the given string and font
 */
+ (id)textLineWithString:(NSString *)string font:(ICFont *)font;

/**
 @brief Returns a new autoreleased text line with the given string and text attributes
 */
+ (id)textLineWithString:(NSString *)string attributes:(NSDictionary *)attributes;

/**
 @brief Returns a new autoreleased text line with the given attributed string
 */
+ (id)textLineWithAttributedString:(NSAttributedString *)attributedString;

/**
 @brief Initializes the receiver with the given string and font
 */
- (id)initWithString:(NSString *)string font:(ICFont *)font;

/**
 @brief Initializes the receiver with the given string and text attributes
 */
- (id)initWithString:(NSString *)string attributes:(NSDictionary *)attributes;

/**
 @brief Initializes the receiver with the given attributed string.
 */
- (id)initWithAttributedString:(NSAttributedString *)attributedString;

/**
 @brief Initializes the receiver with the given CoreText line, attributed string and string range
 */
- (id)initWithCoreTextLine:(CTLineRef)ctLine
        icAttributedString:(NSAttributedString *)icAttString
               stringRange:(NSRange)stringRange;

/**
 @brief The attributed string containing formatted text displayed by the receiver
 */
@property (nonatomic, copy, setter=setAttributedString:) NSAttributedString *attributedString;

/**
 @brief The text (without formatting) displayed by the receiver
 */
- (NSString *)string;

- (float)ascent;

- (float)descent;

- (float)leading;

- (float)lineWidth;

@end
