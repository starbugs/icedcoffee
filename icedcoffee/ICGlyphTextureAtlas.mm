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
                              withSize:(CGSize)sizeInPixels
                              forGlyph:(ICGlyph)glyph
                                  font:(ICFont *)font
                     uploadImmediately:(BOOL)uploadImmediately
{
    RectangleBinPack::Rect rect = _skylineBinPack->Insert(sizeInPixels.width,
                                                          sizeInPixels.height,
                                                          SkylineBinPack::LevelBottomLeft);
    if (rect.x == 0 && rect.y == 0 && rect.width == 0 && rect.height == 0) {
        // Rectangle won't fit into this texture
        return nil;
    }
    
    if (!uploadImmediately) {
        // If we're not uploading immediately, allocate pixel data for the whole texture atlas if
        // not already available
        if (!self.data)
            self.data = malloc(self.sizeInPixels.width * self.sizeInPixels.height * 4);

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
        
        // Copy bitmap data to texture pixel data
        int i, j;
        int textureWidth = (int)self.sizeInPixels.width;
        uint8_t *glyphPixels = (uint8_t *)bitmapData;
        uint8_t *texturePixels = (uint8_t *)self.data;
        for (i=0; i<sizeInPixels.height; i++) {
            for (j=0; j<sizeInPixels.width; j++) {
                texturePixels[j*stride] = glyphPixels[j*stride];
            }
            glyphPixels += rect.width * stride;
            texturePixels += textureWidth * stride;
        }
    } else {
        // Upload immediately without storing data in RAM
        [self uploadData:bitmapData inRect:CGRectMake(rect.x, rect.y, rect.width, rect.height)];
    }

    // Calculate tex coords
    kmVec2 *texCoords = (kmVec2 *)malloc(sizeof(kmVec2)*2);
    texCoords[0] = kmVec2Make(rect.x / self.sizeInPixels.width,
                              rect.y / self.sizeInPixels.height);
    texCoords[1] = kmVec2Make((rect.x + rect.width) / self.sizeInPixels.width,
                              (rect.y + rect.height) / self.sizeInPixels.height);
    
    // Create ICTextureGlyph object
    ICTextureGlyph *textureGlyph = [[[ICTextureGlyph alloc] initWithGlyphTextureAtlas:self
                                                                     texCoordsMinMax:texCoords
                                                                               glyph:glyph
                                                                                font:font] autorelease];
    return textureGlyph;
}

@end
