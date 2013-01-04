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

#import <Foundation/Foundation.h>


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

+ (id)paragraphStyle;

+ (id)paragraphStyleWithTextAlignment:(ICTextAlignment)textAlignment;

- (id)init;

- (id)initWithTextAlignment:(ICTextAlignment)textAlignment;

- (id)initWithCoreTextParagraphStyle:(CTParagraphStyleRef)ctParagraphStyle;

@property (nonatomic, assign) ICTextAlignment textAlignment;

@property (nonatomic, assign) ICLineBreakMode lineBreakMode;

@property (nonatomic, assign) ICWritingDirection baseWritingDirection;

@property (nonatomic, assign) float firstLineHeadIndent;

@property (nonatomic, assign) float headIndent;

@property (nonatomic, assign) float tailIndent;

// Array of ICTextTabs
@property (nonatomic, assign) NSArray *tabStops;

@property (nonatomic, assign) float defaultTabInterval;

@property (nonatomic, assign) float lineHeightMultiple;

@property (nonatomic, assign) float maximumLineHeight;

@property (nonatomic, assign) float minimumLineHeight;

@property (nonatomic, assign) float paragraphSpacing;

@property (nonatomic, assign) float paragraphSpacingBefore;

// Default is IC_HUGE
@property (nonatomic, assign) float maximumLineSpacing;

@property (nonatomic, assign) float minimumLineSpacing;

@property (nonatomic, assign) float lineSpacingAdjustment;

- (CTParagraphStyleRef)ctParagraphStyle;

@end
