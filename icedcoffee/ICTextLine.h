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

#import "ICNode.h"
#import "icFontTypes.h"
#import "ICFont.h"
#import "ICGlyphRun.h"

/**
 @brief Represents a drawable line of text
 
 The ICTextLine class represents a drawable line of text consisting of one or more glyph runs
 (see the ICGlyphRun class).
 */
@interface ICTextLine : ICNode {
@protected
    CTLineRef _ctLine;
    NSMutableArray *_runs;
    NSAttributedString *_string;
    CGFloat _ascent;
    CGFloat _descent;
    CGFloat _leading;
}

+ (id)textLineWithString:(NSString *)string font:(ICFont *)font;

+ (id)textLineWithString:(NSString *)string attributes:(NSDictionary *)attributes;

+ (id)textLineWithAttributedString:(NSAttributedString *)attributedString;

- (id)initWithString:(NSString *)string font:(ICFont *)font;

- (id)initWithString:(NSString *)string attributes:(NSDictionary *)attributes;

- (id)initWithAttributedString:(NSAttributedString *)attributedString;

- (id)initWithCoreTextLine:(CTLineRef)ctLine;

@property (nonatomic, copy) NSAttributedString *attributedString;

- (NSString *)string;

- (float)ascent;

- (float)descent;

- (float)leading;

@end
