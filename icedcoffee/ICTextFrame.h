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

#import "ICPlanarNode.h"
#import "ICFont.h"

@class ICTextLine;

/**
 @brief Implements a low-level text frame node
 
 The ICTextFrame class implements a low-level planar node representing a text frame consisting
 of one or multiple lines of text (see the ICTextLine class). It allows you to typeset text in
 a rectangular text frame using an attributed string providing font and formatting attributes.
 
 ICTextFrame is not designed to be used as a text control in user interfaces. Instead, it should
 be employed as a low-level element to realize such user interface controls, views or other
 composed nodes which should display two-dimensional text frames. If you are looking for a
 user interface control component for displaying text, see the ICLabel class.
 */
@interface ICTextFrame : ICPlanarNode {
@protected
    NSAttributedString *_attributedString;
    NSMutableArray *_lines;
}

/** @name Initialization */

/**
 @brief Returns a new autoreleased text frame with the given size, string and font
 */
+ (id)textFrameWithSize:(kmVec2)size string:(NSString *)string font:(ICFont *)font;

/**
 @brief Returns a new autoreleased text frame with the given size and attributed string
 */
+ (id)textFrameWithSize:(kmVec2)size attributedString:(NSAttributedString *)attributedString;

/**
 @brief Initializes the receiver with the given size, string and font
 */
- (id)initWithSize:(kmVec2)size string:(NSString *)string font:(ICFont *)font;

/**
 @brief Initializes the receiver with the given size, string and text attributes
 */
- (id)initWithSize:(kmVec2)size string:(NSString *)string attributes:(NSDictionary *)attributes;

/**
 @brief Initializes the receiver with the given size and attributed string
 */
- (id)initWithSize:(kmVec2)size attributedString:(NSAttributedString *)attributedString;


/** @name Accessing Lines */

@property (nonatomic, retain) NSArray *lines;


/** @name Setting Attributed Text */

/**
 @brief The attributed string used to represent the receiver's text
 */
@property (nonatomic, copy, setter=setAttributedString:) NSAttributedString *attributedString;


/** @name Caret Handling */

- (NSInteger)stringIndexForPosition:(kmVec2)point;

- (NSInteger)stringIndexForHorizontalOffset:(float)offset inLine:(ICTextLine *)line;

- (kmVec2)offsetForStringIndex:(NSInteger)stringIndex line:(ICTextLine **)line;

@end
