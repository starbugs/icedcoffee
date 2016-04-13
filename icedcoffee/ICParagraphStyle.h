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
#import <CoreText/CoreText.h>


typedef enum {
    ICTextAlignmentLeft = 0,
    ICTextAlignmentRight = 1,
    ICTextAlignmentCenter = 2,
    ICTextAlignmentJustified = 3,
    ICTextAlignmentNatural = 4
} ICTextAlignment;

typedef enum {
    ICLineBreakByWordWrapping = 0,
    ICLineBreakByCharWrapping = 1,
    ICLineBreakByClipping = 2,
    ICLineBreakByTruncatingHead = 3,
    ICLineBreakByTruncatingTail = 4,
    ICLineBreakByTruncatingMiddle = 5
} ICLineBreakMode;

typedef enum {
    ICWritingDirectionNatural = -1,
    ICWritingDirectionLeftToRight = 0,
    ICWritingDirectionRightToLeft = 1,
} ICWritingDirection;


/**
 @brief Defines a paragraph style used in icedcoffee attributed strings
 
 The ICParagraphStyle class defines properties and conversion methods with regard to paragraph
 styles used in icedcoffee attributed strings. Paragraph styles are used primarily as typesetting
 instructions for ICTextFrame objects. They define formatting attributes such as text alignment,
 line break mode, indents, and tab stops.
 */
@interface ICParagraphStyle : NSObject {
@protected
    // Properties
    ICTextAlignment _textAlignment;
    ICLineBreakMode _lineBreakMode;
    ICWritingDirection _baseWritingDirection;
    float _firstLineHeadIndent;
    float _headIndent;
    float _tailIndent;
    NSArray *_tabStops;
    float _defaultTabInterval;
    float _lineHeightMultiple;
    float _maximumLineHeight;
    float _minimumLineHeight;
    float _paragraphSpacing;
    float _paragraphSpacingBefore;
    float _maximumLineSpacing;
    float _minimumLineSpacing;
    float _lineSpacingAdjustment;
    
    // Internals
    CTParagraphStyleRef _ctParagraphStyle;
}

/** @name Initialization */

/**
 @brief Returns an autoreleased paragraph style initialized with default properties
 
 @sa init
 */
+ (id)paragraphStyle;

/**
 @brief Returns an autoreleased paragraph style initialized with the given text alignment
 
 @sa initWithTextAlignment:
 */
+ (id)paragraphStyleWithTextAlignment:(ICTextAlignment)textAlignment;

/**
 @brief Initializes the receiver with default paragraph style properties
 
 The following is a list of default property values set by this method. All properties not
 mentioned in this list are initialized with zero.
 
 - ICParagraphStyle::textAlignment is set to ICTextAlignmentNatural
 - ICParagraphStyle::lineBreakMode is set to ICLineBreakByWordWrapping
 - ICParagraphStyle::baseWritingDirection is set to ICWritingDirectionNatural
 - ICParagraphStyle::maximumLineSpacing is set to IC_HUGE
 */
- (id)init;

/**
 @brief Initializes the receiver with the given text alignment
 
 All other properties are set to default values as defined in ICParagraphStyle::init.
 */
- (id)initWithTextAlignment:(ICTextAlignment)textAlignment;

/**
 @brief Initializes the receiver's properties with the settings of the given CoreText
 paragraph style
 
 The given ``CTParagraphStyleRef`` is retained and kept for future use for the lifecycle of
 the receiver.
 */
- (id)initWithCoreTextParagraphStyle:(CTParagraphStyleRef)ctParagraphStyle;


/** @name Defining Paragraph Style Properties */

/**
 @brief The text alignment (natural, left, center, right)
 
 Defines how the typesetter should align text in a frame.
 
 The default value is ICTextAlignmentNatural, indicating that left or right alignment should be
 used, depending on the first script's line sweep direction contained in the paragraph.
 */
@property (nonatomic, assign) ICTextAlignment textAlignment;

/**
 @brief The line break mode (by word wrapping, char wrapping, clipping or different truncations)
 
 Defines how to break lines when laying out the paragraph's text.
 
 The default value is ICLineBreakByWordWrapping.
 */
@property (nonatomic, assign) ICLineBreakMode lineBreakMode;

/**
 @brief The base writing direction of the lines
 
 The default value is ICWritingDirectionNatural.
 */
@property (nonatomic, assign) ICWritingDirection baseWritingDirection;

/**
 @brief The distance in points from the leading margin of a frame to the beginning of the
 first line of the paragraph
 
 The default value is 0.0. This value is always nonnegative.
 */
@property (nonatomic, assign) float firstLineHeadIndent;

/**
 @brief The distance in points from the leading margin of a frame to the beginning of lines
 other than the first
 
 The default value is 0.0. This value is always nonnegative.
 */
@property (nonatomic, assign) float headIndent;

/**
 @brief The distance in points from the margin of a frame to the end of lines
 
 Positive values denote the distance from the leading margin while negative values denote the
 distance from the trailing margin.
 */
@property (nonatomic, assign) float tailIndent;

// FIXME: no default value yet
/**
 @brief An array of tab stops
 
 An ``NSArray`` of ``ICTextTab`` objects defining the tab stops of the receiver.
 */
@property (nonatomic, assign) NSArray *tabStops;

/**
 @brief The default tab interval in points
 
 If positive, tabs after the last tab defined in ICParagraphStyle::tabStops are placed at integer
 multiplies of this interval.
 
 The default value is 0.0.
 */
@property (nonatomic, assign) float defaultTabInterval;

/**
 @brief The line height multiple
 
 If positive, the framesetter multiplies the natural line height by this factor before constraining
 it by ICParagraphStyle::minimumLineHeight and ICParagraphStyle::maximumLineHeight.
 
 The default value is 0.0.
 */
@property (nonatomic, assign) float lineHeightMultiple;

/**
 @brief The maximum line height in points, regardless of font size
 
 Glyphs exceeding the maximum line height will overlap adjacent lines. A value of 0.0 implies
 no limit to line heights.
 
 The default value is 0.0. This value is always nonnegative.
 */
@property (nonatomic, assign) float maximumLineHeight;

/**
 @brief The minimum line height in points, regardless of font size
 
 The default value is 0.0. This value is always nonnegative.
 */
@property (nonatomic, assign) float minimumLineHeight;

/**
 @brief The size in points of the space appended at the end of the paragraph to seperate it
 from the following paragraph
 
 The final space between paragraphs is calculated by adding the value of
 ICParagraphStyle::paragraphSpacingBefore of the previous paragraph to the value of
 ``paragraphSpacing`` of the current paragraph.
 
 The default value is 0.0. This value is always nonnegative.
 */
@property (nonatomic, assign) float paragraphSpacing;

/**
 @brief The size in points of the space to prepend to the paragraph's text content
 
 The default value is 0.0. This value is always nonnegative.
 */
@property (nonatomic, assign) float paragraphSpacingBefore;

/**
 @brief The maximum space in points between lines (maximum leading)
 
 The default value is IC_HUGE. This value is always nonnegative.
 */
@property (nonatomic, assign) float maximumLineSpacing;

/**
 @brief The minimum space in points between lines (minimum leading)
 
 The default value is 0.0. This value is always nonnegative.
 */
@property (nonatomic, assign) float minimumLineSpacing;

/**
 @brief The space in points between adjacent lines (leading)
 
 The default value is 0.0.
 */
@property (nonatomic, assign) float lineSpacingAdjustment;

/**
 @brief The CoreText representation of the paragraph style defined by the receiver
 
 If the receiver was initialized using initWithCoreTextParagraphStyle:, this method simply returns
 the ``CTParagraphStyleRef`` that was given to the initializer. If the receiver was initialized
 from scratch, this method creates a new ``CTParagraphStyle`` object by converting the receiver's
 values to their corresponding CoreText paragraph style setting representations. The
 ``CTParagraphStyle`` object is retained for the lifecycle of the receiver.
 */
- (CTParagraphStyleRef)ctParagraphStyle;

@end
