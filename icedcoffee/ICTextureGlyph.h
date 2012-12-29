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
#import "icMacros.h"
#import "../3rd-party/kazmath/kazmath/kazmath.h"
#import "icFontTypes.h"

@class ICGlyphTextureAtlas;
@class ICFont;

/**
 @brief Represents a font glyph on a texture atlas
 */
@interface ICTextureGlyph : NSObject {
@protected
    ICGlyphTextureAtlas *_textureAtlas; // weak
    ICFont *_font;
    kmVec2 *_texCoords;
    kmVec2 _size;
    CGRect _boundingRect;
    BOOL _rotated;
}

/** @name Initialization */

/**
 @brief Initializes the receiver with information about the texture glyph to be represented
 */
- (id)initWithGlyphTextureAtlas:(ICGlyphTextureAtlas *)textureAtlas
                      texCoords:(kmVec2 *)texCoords
                           size:(kmVec2)size
                   boundingRect:(CGRect)boundingRect
                        rotated:(BOOL)rotated
                          glyph:(ICGlyph)glyph
                           font:(ICFont *)font;


/** @name Retrieving Texture Glyph Properties */

/**
 @brief The texture atlas on which the glyph is cached
 */
@property (nonatomic, readonly) ICGlyphTextureAtlas *textureAtlas;

/**
 @brief The font index of the glyph
 */
@property (nonatomic, readonly) ICGlyph glyph;

/**
 @brief The font from which this glyph was extracted
 */
@property (nonatomic, readonly) ICFont *font;

/**
 @brief The texture coordinates of the glyph on its texture atlas
 */
@property (nonatomic, readonly) kmVec2 *texCoords;

/**
 @brief The size of the glyph's retangle on its texture atlas
 */
@property (nonatomic, readonly) kmVec2 size;

/**
 @brief The bounding rect of the glyph
 */
@property (nonatomic, readonly) CGRect boundingRect;

/**
 @brief Whether the glyph is stored rotated
 */
@property (nonatomic, readonly) BOOL rotated;

@end
