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

#import <CoreText/CoreText.h>
#import "ICGlyphCache.h"
#import "ICOpenGLContext.h"
#import "ICFont.h"
#import "ICGlyphTextureAtlas.h"
#import "ICHostViewController.h"
#import "ICTextureGlyph.h"

#define TEXTURE_ATLAS_SIZE CGSizeMake(2048.0f, 2048.0f)

@implementation ICGlyphCache

+ (id)currentGlyphCache
{
    ICOpenGLContext *openGLContext = [ICOpenGLContext currentContext];
    NSAssert(openGLContext != nil, @"No OpenGL context available for current native OpenGL context");
    ICGlyphCache *glyphCache = openGLContext.glyphCache;
    if (!glyphCache) {
        glyphCache = openGLContext.glyphCache = [[[ICGlyphCache alloc] init] autorelease];
    }
    return glyphCache;
}

- (id)init
{
    if ((self = [super init])) {
        _textureGlyphs = [[NSMutableDictionary alloc] init];
        _textures = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (void)dealloc
{
    [_textureGlyphs release];
    [_textures release];

    [super dealloc];
}

- (ICGlyphTextureAtlas *)newTextureAtlas
{
    ICGlyphTextureAtlas *currentTextureAtlas = [_textures lastObject];
    // Upload current texture atlas data if necessary
    if ([currentTextureAtlas dataDirty]) {
        [currentTextureAtlas upload];
    }
    // Free RAM copy of texture data for current texture atlas
    [currentTextureAtlas setData:nil];
    
    // Create new texture atlas
    ICGlyphTextureAtlas *textureAtlas;
    ICResolutionType bestResolutionType = [[ICHostViewController currentHostViewController]
                                           bestResolutionTypeForCurrentScreen];
    textureAtlas = [[[ICGlyphTextureAtlas alloc] initWithSize:TEXTURE_ATLAS_SIZE
                                                  pixelFormat:ICPixelFormatA8
                                               resolutionType:bestResolutionType] autorelease];
    [_textures addObject:textureAtlas];
    return textureAtlas;
}

- (ICGlyphTextureAtlas *)vacantTextureAtlas
{
    ICGlyphTextureAtlas *candidate = [_textures lastObject];
    if (!candidate) {
        candidate = [self newTextureAtlas];
    }
    
    return candidate;
}

- (void)cacheTextureGlyph:(ICTextureGlyph *)textureGlyph
{
    NSMutableDictionary *glyphsForFont = [_textureGlyphs objectForKey:textureGlyph.font.name];
    if (!glyphsForFont) {
        glyphsForFont = [NSMutableDictionary dictionaryWithCapacity:1];
        [_textureGlyphs setObject:glyphsForFont forKey:textureGlyph.font.name];
    }
    [glyphsForFont setObject:textureGlyph forKey:[NSNumber numberWithUnsignedShort:textureGlyph.glyph]];
}

- (void)cacheGlyphsWithRun:(CTRunRef)run font:(ICFont *)font
{
    CFIndex glyphCount = CTRunGetGlyphCount(run);
    CGGlyph *glyphs = (CGGlyph *)malloc(sizeof(CGGlyph)*glyphCount);
    CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);
    for (CFIndex i=0; i<glyphCount; i++) {
        CGFloat ascent, descent;
        float width = CTRunGetTypographicBounds(run, CFRangeMake(i, 1), &ascent, &descent, NULL);
        float height = ascent + descent;
        size_t w = ceilf(height) + 2, h = ceilf(height) + 2;
        
        void *data = calloc(h, w);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGContextRef context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
        CGColorSpaceRelease(colorSpace);
        
        NSAssert(context != nil, @"Unable to create CoreGraphics bitmap context");
        
        if (!context) {
            free(data);
            return;
        }
        
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
        CGContextSetTextPosition(context, 1, 1);
        CGContextSetFont(context, cgFont);
        CGContextSetFontSize(context, CTFontGetSize(runFont));
        CGContextSetGrayFillColor(context, 1, 1);
        CGContextShowGlyphsAtPoint(context, 0, 0, glyphs, 1);
        CFRelease(cgFont);
        
        ICGlyphTextureAtlas *textureAtlas = [self vacantTextureAtlas];
        ICTextureGlyph *textureGlyph = [textureAtlas addGlyphBitmapData:data
                                                               withSize:CGSizeMake(w,h)
                                                               forGlyph:glyphs[i]
                                                                   font:font
                                                      uploadImmediately:NO];
        
        if (!textureGlyph) {
            // No more space left in vacant texture atlas
            textureAtlas = [self newTextureAtlas];
            textureGlyph = [textureAtlas addGlyphBitmapData:data
                                                   withSize:CGSizeMake(w, h)
                                                   forGlyph:glyphs[i]
                                                       font:font
                                          uploadImmediately:NO];
        }
        
        NSAssert(textureGlyph != nil, @"Something went terribly wrong here");
        
        [self cacheTextureGlyph:textureGlyph];
        
        CGContextRelease(context);
        free(data);
    }
    
}

- (void)cacheGlyphsWithString:(NSString *)string forFont:(ICFont *)font
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (id)font.fontRef, (NSString *)kCTFontAttributeName, nil];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string
                                                                           attributes:attributes];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runs);
    for (CFIndex i=0; i<runCount; i++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runs, i);
        [self cacheGlyphsWithRun:run font:font];
    }
    CFRelease(line);
    [attributedString release];
}

- (ICTextureGlyph *)textureGlyphForGlyph:(ICGlyph)glyph font:(ICFont *)font
{
    NSMutableDictionary *glyphsForFont = [_textureGlyphs objectForKey:font.name];
    ICTextureGlyph *textureGlpyh = [glyphsForFont objectForKey:[NSNumber numberWithUnsignedShort:glyph]];
    if (textureGlpyh.textureAtlas.dataDirty) {
        [textureGlpyh.textureAtlas upload];
    }
    return textureGlpyh;
}

@end
