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

#import "ICMutableTexture2D.h"
#import "icFontDefs.h"
#import "ICTextureGlyph.h"

@class ICFont;

/**
 @brief Represents a texture atlas for typographic glyphs
 */
@interface ICGlyphTextureAtlas : ICMutableTexture2D

/**
 @brief Initializes the receiver with a given size, pixel format and resolution type
 
 @param sizeInPixels The size of the receiver in pixels
 @param pixelFormat The pixel format of the receiver. Currently only ``ICPixelFormatRGBA8888``
 and ``ICPixelFormatA8`` are supported by this class.
 @param resolutionType The resolution type to use for the receiver
 */
- (id)initWithSize:(CGSize)sizeInPixels
       pixelFormat:(ICPixelFormat)pixelFormat
    resolutionType:(ICResolutionType)resolutionType;

/**
 @brief Adds the given glyph bitmap data to the receiver
 
 @param bitmapData Bitmap data conforming to the receiver's pixel format and the specified size
 @param glyph An ICGlyph specifying the internal index of the glyph within its font
 @param sizeInPixels The size of the given bitmap data in pixels
 @param boundingRect The bounding rect of the rasterized glyph in pixels
 @param offset The subpixel offset of the rasterized glyph
 @param font An ICFont object defining the font which the given glyph belongs to
 @param uploadImmediately A boolean flag indicating whether to upload the given data to the
 receiver's OpenGL texture immediately.
 
 This method first employs a Skyline-BL bin packing algorithm to determine the destination
 rectangle of the given rectangular glyph bitmap data in the receiver. If there's enough space
 left in the receiver to contain the glyph's bitmap data, the method creates an ICTextureGlyph
 object for the given glyph and copies the specified bitmap data to the receiver.
 
 If ``uploadImmediately`` is set to ``YES``, this method immediately uploads the glyph's bitmap data
 to its destination rectangle in the receiver's OpenGL texture. If no OpenGL texture exists, it
 is implicitly created. If ``uploadImmediately`` is set to ``NO``, this method copies the glyph's
 bitmap data to an internal pixel buffer in RAM. In this case, the caller is responsible to upload
 the receiver's internal data to OpenGL at a suitable point in time, i.e. when there are no more
 glyphs to add to the receiver or the texture needs to be used by a view component.
 
 @return If the given glyph bitmap data fits into the receiver, this method returns an
 ICTextureGlyph object holding information about the texture glyph. If the glyph bitmap data
 does not fit into the receiver, this method returns ``nil``. In this case, the caller must
 allocate another ICGlyphTextureAtlas object with a suitable size to store the given glyph.
 */
- (ICTextureGlyph *)addGlyphBitmapData:(void *)bitmapData
                              forGlyph:(ICGlyph)glyph
                          sizeInPixels:(CGSize)sizeInPixels
                          boundingRect:(CGRect)boundingRect
                                offset:(float)offset
                                  font:(ICFont *)font
                     uploadImmediately:(BOOL)uploadImmediately;

@end

