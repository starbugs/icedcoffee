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

#import "ICGlyphTextureAtlas.h"
#import "ICHostViewController.h"
#import "../3rd-party/RectangleBinPack/SkylineBinPack.h"
#import "icFontDefs.h"
#import "icTypes.h"

using RectangleBinPack::SkylineBinPack;

@interface ICGlyphTextureAtlas () {
@protected
    SkylineBinPack *_skylineBinPack;
}
@end

@implementation ICGlyphTextureAtlas

- (id)initWithSize:(CGSize)sizeInPixels
       pixelFormat:(ICPixelFormat)pixelFormat
    resolutionType:(ICResolutionType)resolutionType
{
    NSAssert(pixelFormat == ICPixelFormatRGBA8888 || pixelFormat == ICPixelFormatA8,
             @"Only RGBA8888 or A8 pixel formats are supported by this class");
    
    if ((self = [super initWithData:nil
                        pixelFormat:pixelFormat
                        textureSize:sizeInPixels
                        contentSize:sizeInPixels
                     resolutionType:resolutionType
                           keepData:YES
                  uploadImmediately:NO])) {
        
        _skylineBinPack = new SkylineBinPack(sizeInPixels.width, sizeInPixels.height, NO);
        
    }
    return self;
}

- (void)dealloc
{
    delete _skylineBinPack;
    
    [super dealloc];
}

- (ICTextureGlyph *)addGlyphBitmapData:(void *)bitmapData
                              forGlyph:(ICGlyph)glyph
                          sizeInPixels:(CGSize)sizeInPixels
                          boundingRect:(CGRect)boundingRect
                                  font:(ICFont *)font
                     uploadImmediately:(BOOL)uploadImmediately
{
    long bitmapWidth = (long)sizeInPixels.width;
    long bitmapHeight = (long)sizeInPixels.height;
    
    RectangleBinPack::Rect rect = _skylineBinPack->Insert(sizeInPixels.width,
                                                          sizeInPixels.height,
                                                          SkylineBinPack::LevelBottomLeft);
    if (rect.x == 0 && rect.y == 0 && rect.width == 0 && rect.height == 0) {
        // Rectangle won't fit into this texture
        return nil;
    }
    
    BOOL rotated = NO;
    if (rect.width == bitmapHeight && rect.height == bitmapWidth)
        rotated = YES;
    
    if (!uploadImmediately) {
        // Determine stride of one pixel (supported formats: RGBA8888 and A8)
        uint stride = 0;
        if (self.pixelFormat == ICPixelFormatRGBA8888) {
            stride = sizeof(icColor4B);
        } else if(self.pixelFormat == ICPixelFormatA8) {
            stride = sizeof(uint8_t);
        } else {
            [NSException raise:NSInternalInconsistencyException
                        format:@"Unsupported or invalid pixel format"];
        }

        // If we're not uploading immediately, allocate pixel data for the whole texture atlas if
        // not already available
        if (!self.data) {
            // Allocate new pixel data
            self.data = calloc((int)self.sizeInPixels.height, (int)self.sizeInPixels.width * stride);
        } else {
            // Pixel data already available; we will mutate it, so we need to set dataDirty to
            // YES here manually
            self.dataDirty = YES;
        }

        // Copy bitmap data to texture pixel data
        int i;
        int textureWidth = (int)self.sizeInPixels.width;
        if (!rotated) {
            // Straight copy
            for (i=0; i<rect.height; i++) {
                uint8_t *glyphRow = (uint8_t *)bitmapData + (i * rect.width * stride);
                uint8_t *textureRow = (uint8_t *)self.data + ((rect.y + i) * textureWidth * stride + rect.x * stride);
                memcpy(textureRow, glyphRow, stride * rect.width);
            }
        } else {
            // Rotated copy
            int j, k;
            for (i=0; i<bitmapHeight; i++) {
                uint8_t *glyphRow = (uint8_t *)bitmapData + (i * bitmapWidth * stride);
                for (j=0; j<bitmapWidth; j++) {
                    uint8_t *texturePixel = (uint8_t *)self.data + ((rect.y + j) * textureWidth * stride + (rect.x + i) * stride);
                    for (k=0; k<stride; k++) {
                        texturePixel[k] = glyphRow[j*stride+k];
                    }
                }
            }
        }
    } else {
        // Upload immediately without storing data in RAM
        [self uploadData:bitmapData inRect:CGRectMake(rect.x, rect.y, rect.width, rect.height)];
    }

    // Calculate tex coords
    float x1, x2, y1, y2;
    x1 = rect.x / self.sizeInPixels.width;
    y1 = rect.y / self.sizeInPixels.height;
    x2 = (rect.x + rect.width) / self.sizeInPixels.width;
    y2 = (rect.y + rect.height) / self.sizeInPixels.height;
    
    kmVec2 *texCoords = (kmVec2 *)malloc(sizeof(kmVec2)*4);
    if (rotated) {
        texCoords[0] = kmVec2Make(x1, y1);
        texCoords[2] = kmVec2Make(x1, y2);
        texCoords[1] = kmVec2Make(x2, y1);
        texCoords[3] = kmVec2Make(x2, y2);
    } else {
        texCoords[0] = kmVec2Make(x1, y1);
        texCoords[1] = kmVec2Make(x1, y2);
        texCoords[2] = kmVec2Make(x2, y1);
        texCoords[3] = kmVec2Make(x2, y2);
    }
    
    // Create ICTextureGlyph object
    kmVec2 size = kmVec2Make(ICFontPixelsToPoints(sizeInPixels.width),
                             ICFontPixelsToPoints(sizeInPixels.height));
    ICTextureGlyph *textureGlyph = [[[ICTextureGlyph alloc] initWithGlyphTextureAtlas:self
                                                                            texCoords:texCoords
                                                                                 size:size
                                                                         boundingRect:boundingRect
                                                                              rotated:rotated
                                                                                glyph:glyph
                                                                                 font:font] autorelease];
    return textureGlyph;
}

@end
