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

#import <Foundation/Foundation.h>
#import "icConfig.h"
#import "ICPlanarNode.h"
#import "ICFont.h"

#if IC_ENABLE_DEBUG_GLYPH_RUN_METRICS
#import "ICLine2D.h"
#endif

#define ICShaderGlyph @"ShaderGlyph"

#define IC_DEFAULT_GLYPH_RUN_COLOR (icColor4B){0,0,0,255}
#define IC_DEFAULT_GLYPH_RUN_GAMMA 1.f

@class ICGlyphRunMetrics;

/**
 @brief Represents a low-level node drawing a single glyph run
 
 The ICGlyphRun class implements a low-level node for drawing a single glyph run using a given
 font. The class attempts to minimize the number of VBOs and texture state changes required to
 display the glyphs of the run.
 
 By default, glyphs are retrieved from the current glyph cache (see ICGlyphCache) as required,
 on the fly, the first time the run is drawn. If the glyphs are not already loaded, the cache
 will load them when they are requested. Depending on the font, font size and amount of different
 characters contained in the run, glyph loading may be heavy and could lead to a decrease of your
 application's performance. If you require more control about the point in time the glyphs are
 loaded, rastered and cached, you may use the ICGlyphRun::precache method to precache all glyphs
 used by the run at a point in time of your convenience.
 
 ICGlyphRun is not designed to be used as a user interface control. Instead, it may be used to
 implement user interface controls, views or composed nodes which need to display glyph runs
 directly, without using the ICTextFrame or ICTextLine classes. If you're looking for a user
 interface control for displaying text, see the ICLabel class.
 */
@interface ICGlyphRun : ICPlanarNode {
@protected
    NSString *_string;
    ICFont *_font;
    icColor4B _color;
    float _gamma;
    BOOL _dirty;
    NSMutableArray *_buffers;
    ICGlyphRunMetrics *_metrics;
    CTRunRef _ctRun;
    
#if IC_ENABLE_DEBUG_GLYPH_RUN_METRICS
    ICLine2D *_dbgBaseline;
#endif
}


/** @name Initialization */

/**
 @brief Returns an autoreleased glyph run with the given string and font
 */
+ (id)glyphRunWithString:(NSString *)string font:(ICFont *)font;

/**
 @brief Returns an autoreleased glyph run with the given string, font and color
 */
+ (id)glyphRunWithString:(NSString *)string font:(ICFont *)font color:(icColor4B)color;

/**
 @brief Returns an autoreleased glyph run with the given string and attributes
 */
+ (id)glyphRunWithString:(NSString *)string attributes:(NSDictionary *)attributes;

/**
 @brief Initializes the receiver with the given string and font
 */
- (id)initWithString:(NSString *)string font:(ICFont *)font;

/**
 @brief Initializes the receiver with the given string, font and color
 */
- (id)initWithString:(NSString *)string font:(ICFont *)font color:(icColor4B)color;

/**
 @brief Initializes the receiver with the given string and attributes
 */
- (id)initWithString:(NSString *)string attributes:(NSDictionary *)attributes;

/**
 @brief Initializes the receiver with the given CoreText run and extended attributes
 
 @param run A ``CTRunRef`` identifiying the CoreText run to initialize the receiver with
 @param extendedAttributes An ``NSDictionary`` containing extended attributes that are not
 supported by CoreText
 */
- (id)initWithCoreTextRun:(CTRunRef)run extendedAttributes:(NSDictionary *)extendedAttributes;


/** @name Precaching Font Glyphs */

/**
 @brief Precaches the glyphs required for drawing the receiver
 
 This method immediately and synchronously precaches all glyphs required for drawing the receiver.
 
 @return Returns the receiver. This method is thought to be used in line with initialization, 
 e.g. ``[[ICGlyphRun glyphRunWithText:@"I love icedcoffee :)" font:arial] precache]``.
 */
- (id)precache;


/** @name Text, Font and Run Metrics */

/**
 @brief The receiver's string
 */
@property (nonatomic, copy, setter=setString:) NSString *string;

/**
 @brief The font the receiver uses to draw its ICGlyphRun::string
 */
@property (nonatomic, retain, setter=setFont:) ICFont *font;

/**
 @brief The color the receiver uses to draw its ICGlyphRun::string
 */
@property (nonatomic, assign, setter=setColor:) icColor4B color;

/**
 @brief The gamma value the receiver uses to draw its ICGlyphRun::string
 
 The default value of this property is 1.
 */
@property (nonatomic, assign, setter=setGamma:) float gamma;

/**
 @brief The tracking of the letters drawn by the receiver
 
 The tracking (or letter spacing) determines the space, in points, that the receiver leaves blank
 between each letter of the run in addition to the glyphs' natural advances. A negative tracking
 increases the density of the run whereas a positive tracking decreases it.
 
 The default value for this property is 0, indicating that only the glyphs' font-defined advances
 should be used to typeset the run.
 */
@property (nonatomic, assign, setter=setTracking:) float tracking;

@property (nonatomic, assign, setter=setSuperscript:) NSInteger superscript;

/**
 @brief Returns the receiver's ascent in points
 */
- (float)ascent;

/**
 @brief Returns the receiver's descent in points
 */
- (float)descent;

/**
 @brief Returns the receiver's leading in points
 */
- (float)leading;

@end
