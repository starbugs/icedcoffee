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

/**
 @brief The depth of textures used by the glyph cache to store glyphs
 
 Valid values are 1 for alpha only textures or 4 for RGBA textures.
 */
#define IC_GLYPH_CACHE_TEXTURE_DEPTH 1

/**
 @brief The default size of texture atlases allocated by ICGlyphCache
 */
#define IC_DEFAULT_GLYPH_TEXTURE_ATLAS_SIZE CGSizeMake(1024, 1024)

/**
 @brief The size in pixels of the margin to add to each glyph's bounding box when
 extracting glyph textures
 
 This value is used to compensate for glyph antialiasing. Should be divisible by 2 to work
 correctly on retina displays.
 */
#define IC_GLYPH_RECTANGLE_MARGIN 2


@class ICFont;
@class ICTextureGlyph;

// TODO: asynchronous caching

/**
 @brief Implements a CoreText/OpenGL based font glyph cache
 
 The ICGlyphCache class extracts font glyphs using CoreText, packs them in suitable texture
 atlases and uploads them to OpenGL textures as required by the framework to draw text.
 
 ICGlyphCache employs a Skyline-BL rectangle bin packing algorithm to pack glyphs into texture
 atlases. The size of the textures storing those atlases may be controlled using the
 ICGlyphCache::textureSize property. By default, ICGlyphCache will pack glyphs into 1024x1024
 pixel textures.
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


/** @name Retrieving/Initializing a Glyph Cache */

/**
 @brief Retrieves or creates the glyph cache for the current OpenGL context
 */
+ (id)currentGlyphCache;

/**
 @brief Initializes the receiver
 */
- (id)init;


/** @name Precaching Glyphs Manually */

/**
 @brief Precaches all glyphs from the given string and font
 
 @param string An ``NSString`` containing the characters whose glyphs should be cached
 @param font An ICFont representing the font to extract glyphs from
 */
- (void)cacheGlyphsWithString:(NSString *)string forFont:(ICFont *)font;


/** @name Retrieving Texture Glyphs */

/**
 @brief Retrieves a texture glyph for the given glyph and font

 @param glyph An ICGlyph defining the glyph of which a texture glyph should be retrieved
 @param font An ICFont representing the font to extract glyphs from
 
 If a yet uncached glyph is requested, this method caches the given glyph before returning a result.
 */
- (ICTextureGlyph *)textureGlyphForGlyph:(ICGlyph)glyph font:(ICFont *)font;

/**
 @brief Retrieves a number of texture glyphs for the given glyphs and font

 @param glyphs A C-array with ICGlyph values defining the glyphs of which texture glyphs
 should be retrieved
 @param count The number of ICGlyph values stored in the C-Array
 @param font An ICFont representing the font to extract glyphs from

 If one or more glyphs in the given array of glyphs is not yet cached, this method caches them
 before returning a result.
 
 @return Returns an ``NSArray`` containing ICTextureGlyph objects corresponding to ``glyphs``.
 */
- (NSArray *)textureGlyphsForGlyphs:(ICGlyph *)glyphs count:(NSInteger)count font:(ICFont *)font;

/**
 @brief Retrieves a number of texture glyphs separated by texture for the given glyphs and font

 @param glyphs A C-array with ICGlyph values defining the glyphs of which texture glyphs
 should be retrieved
 @param count The number of ICGlyph values stored in the C-array
 @param font An ICFont representing the font to extract glyphs from

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


/** @name Purging a Glyph Cache */

/**
 @brief Purges the receiver
 */
- (void)purge;


/** @name Managing a Cache's Texture Atlases */

/**
 @brief An array of texture atlas objects the receiver currently uses to cache glyphs
 
 @return Returns an ``NSArray`` containing ICGlyphTextureAtlas objects representing the glyph
 cache's texture atlases.
 */
@property (nonatomic, readonly) NSArray *textures;

/**
 @brief The size used by the receiver to allocate new textures
 
 This property should be set before the receiver is used to cache glyph textures.
 */
@property (nonatomic, readonly) CGSize textureSize;

@end
