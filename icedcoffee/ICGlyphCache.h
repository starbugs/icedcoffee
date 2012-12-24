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
#import "icFontTypes.h"

@class ICFont;
@class ICTextureGlyph;

/**
 @brief Represents a CoreText/OpenGL based glyph cache
 */
@interface ICGlyphCache : NSObject {
@protected
    // Glyphs by font name
    NSMutableDictionary *_textureGlyphs;
    // Textures used by the glyph cache
    NSMutableArray *_textures;
    // Size to use when allocating new texture atlases
    CGSize _textureSize;
}

/**
 @brief Retrieves or creates the glyph cache for the current OpenGL context
 */
+ (id)currentGlyphCache;

/**
 @brief Initializes the receiver
 */
- (id)init;

/**
 @brief Precaches all glyphcs from the given string and font
 */
- (void)cacheGlyphsWithString:(NSString *)string forFont:(ICFont *)font;

/**
 @brief Retrieves a texture glyph for the given glyph and font
 
 If the glyph has not yet been cached, this method implicitly adds the given glyph to the receiver.
 */
- (ICTextureGlyph *)textureGlyphForGlyph:(ICGlyph)glyph font:(ICFont *)font;

/**
 @brief Retrieves a number of texture glyphs for the given glyphs and font
 */
- (NSArray *)textureGlyphsForGlyphs:(ICGlyph *)glyphs count:(NSInteger)count font:(ICFont *)font;

/**
 @brief Retrieves a number of texture glyphs separated by texture for the given glyphs and font
 
 @return This method returns an ``NSDictionary`` containing ``NSValue`` keys each representing the
 pointer address of an ICGlyphTextureAtlas object pertaining to a texture atlas used to cache
 a list of corresponding texture glyphs. For those keys the dictionary contains ``NSArray`` values
 each representing such list of glyphs. The ``NSArray`` value again contains a number of
 ``NSArray``s each containing a pair of an ``NSNumber`` defining the index of the glyph and an
 ICTextureGlyph object defining the corresponding texture glyph.
 */
- (NSDictionary *)textureGlyphsSeparatedByTextureForGlyphs:(ICGlyph *)glyphs
                                                     count:(NSInteger)count
                                                      font:(ICFont *)font;


/**
 @brief An array of texture atlas objects the receiver currently uses to cache glyphs
 
 @return Returns an ``NSArray`` containing ICGlyphTextureAtlas objects representing the glyph
 cache's texture atlases.
 */
@property (nonatomic, readonly) NSArray *textures;

/**
 @brief The size used by the receiver to allocate new textures
 */
@property (nonatomic, readonly) CGSize textureSize;

@end
