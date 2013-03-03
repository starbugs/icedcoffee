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

#pragma once

#import "icMacros.h"

/**
 @brief Use high resolution fonts regardless of display type
 */
#define IC_USE_HIGH_RESOLUTION_FONTS    0

/**
 @brief On SD displays, optimize subpixel accuracy by using multiple bitmaps per glyph
 */
#define IC_USE_EXTRA_SUBPIXEL_GLYPHS    1

/**
 @brief Round X positions of glyphs (if not using extra subpixel glyphs)
 */
#define IC_ROUND_GLYPH_X_POSITIONS      0

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
