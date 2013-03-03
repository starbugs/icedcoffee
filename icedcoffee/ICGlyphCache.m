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

#import <CoreText/CoreText.h>
#import "ICGlyphCache.h"
#import "ICOpenGLContext.h"
#import "ICFont.h"
#import "ICGlyphTextureAtlas.h"
#import "ICHostViewController.h"
#import "ICTextureGlyph.h"
#import "icMacros.h"
#import "icConfig.h"
#import "ICFontCache.h"


@interface ICGlyphCache ()
- (ICGlyphTextureAtlas *)newTextureAtlas;
- (ICGlyphTextureAtlas *)vacantTextureAtlas;
- (ICTextureGlyph *)cacheGlyph:(ICGlyph)glyph font:(ICFont *)font;
- (void)cacheGlyphsWithRun:(CTRunRef)run font:(ICFont *)font;
- (ICTextureGlyph *)retrieveCachedTextureGlyph:(ICGlyph)glyph font:(ICFont *)font;
@end

@implementation ICGlyphCache

@synthesize textures = _textures;
@synthesize textureSize = _textureSize;

+ (id)currentGlyphCache
{
    ICOpenGLContext *openGLContext = [ICOpenGLContext currentContext];
    NSAssert(openGLContext != nil, @"No OpenGL context available for current native OpenGL context");
    NSAssert(openGLContext.glyphCache != nil, @"No glyph cache created yet for this context");
    return openGLContext.glyphCache;
}

- (id)init
{
    if ((self = [super init])) {
        _textureGlyphs = [[NSMutableDictionary alloc] init];
        _textures = [[NSMutableArray alloc] initWithCapacity:1];
        _textureSize = IC_DEFAULT_GLYPH_TEXTURE_ATLAS_SIZE;
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
    ICPixelFormat pixelFormat = IC_GLYPH_CACHE_TEXTURE_DEPTH == 1 ? ICPixelFormatA8 : ICPixelFormatRGBA8888;
    textureAtlas = [[[ICGlyphTextureAtlas alloc] initWithSize:self.textureSize
                                                  pixelFormat:pixelFormat
                                               resolutionType:bestResolutionType] autorelease];
    [_textures addObject:textureAtlas];

#if IC_ENABLE_DEBUG_GLYPH_CACHE
    NSLog(@"Glyph cache: new texture atlas allocated");
#ifdef __IC_PLATFORM_MAC
    NSLog(@"Glyph cache: number of atlases in use: %ld", [_textures count]);
#elif defined(__IC_PLATFORM_IOS)
    NSLog(@"Glyph cache: number of atlases in use: %d", [_textures count]);
#endif
#endif
    
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
    NSString *internalFontName = icInternalFontNameForFont(textureGlyph.font);
    NSMutableDictionary *glyphsForFont = [_textureGlyphs objectForKey:internalFontName];
    if (!glyphsForFont) {
        glyphsForFont = [NSMutableDictionary dictionaryWithCapacity:1];
        [_textureGlyphs setObject:glyphsForFont forKey:internalFontName];
    }
    [glyphsForFont setObject:textureGlyph forKey:[NSNumber numberWithUnsignedShort:textureGlyph.glyph]];
}

- (void)rasterizeGlyph:(ICGlyph)glyph
                  font:(ICFont *)font
               xOffset:(float)xOffset
               yOffset:(float)yOffset
               context:(CGContextRef)context
{
    CGFontRef cgFont = CTFontCopyGraphicsFont(font.fontRef, NULL);
    //CGContextSetAllowsAntialiasing(context, NO);
    //CGContextSetShouldAntialias(context, NO);
    CGContextSetAllowsFontSmoothing(context, NO);
    CGContextSetShouldSmoothFonts(context, NO);
    CGContextSetShouldSubpixelPositionFonts(context, YES);
    CGContextSetShouldSubpixelQuantizeFonts(context, YES);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextSetFont(context, cgFont);
    CGContextSetFontSize(context, CTFontGetSize(font.fontRef));
    CGContextSetGrayFillColor(context, 1, 1);
    CGContextShowGlyphsAtPoint(context,
                               IC_GLYPH_RECTANGLE_MARGIN + xOffset,
                               IC_GLYPH_RECTANGLE_MARGIN + yOffset,
                               &glyph, 1);
    CFRelease(cgFont);
    
    /*CGContextSetLineWidth(context, 1);
     CGContextSetGrayStrokeColor(context, 1, 1);
     CGContextStrokeRect(context, CGRectMake(0, 0, w, h));*/
}

- (ICTextureGlyph *)rasterizeAndCacheGlyph:(ICGlyph)glyph boundingRect:(CGRect *)boundingRect font:(ICFont *)font
{
    ICTextureGlyph *textureGlyph = [self retrieveCachedTextureGlyph:glyph font:font];
    
    // Only extract new glyph texture if glyph has not already been cached
    if (!textureGlyph) {
        size_t deltaW = 0;
        size_t deltaH = 0;
        size_t brWidth = (size_t)ceilf(boundingRect->size.width);
        size_t brHeight = (size_t)ceilf(boundingRect->size.height);
        if (ICFontContentScaleFactor() == 2.f) {
            deltaW = brWidth % 2;
            deltaH = brHeight % 2;
        }
        
        size_t w = brWidth + deltaW + IC_GLYPH_RECTANGLE_MARGIN * 2;
        size_t h = brHeight + deltaH + IC_GLYPH_RECTANGLE_MARGIN * 2;
        
        CGColorSpaceRef colorSpace;
        CGImageAlphaInfo alphaInfo;
        
        int depth = IC_GLYPH_CACHE_TEXTURE_DEPTH;
        if (depth != 4 && depth != 1) {
            NSLog(@"Only RGBA and alpha texture depths are supported, falling back to RGBA");
            depth = 4;
        }
        
        if (depth == 4) {
            colorSpace = CGColorSpaceCreateDeviceRGB();
            alphaInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
        } else if (depth == 1) {
            colorSpace = CGColorSpaceCreateDeviceGray();
            alphaInfo = kCGImageAlphaNone;
        }
        
        void *data = calloc(h, w * depth);
        CGContextRef context = CGBitmapContextCreate(data, w, h, 8, w * depth, colorSpace, alphaInfo);
        CGColorSpaceRelease(colorSpace);
        
        NSAssert(context != nil, @"Unable to create CoreGraphics bitmap context");
        
        if (!context) {
            free(data);
            [NSException raise:NSInternalInconsistencyException format:@"Invalid bitmap context"];
            return nil;
        }
        
        float xOffset = -boundingRect->origin.x;
        float yOffset = -boundingRect->origin.y;
        
        [self rasterizeGlyph:glyph font:font xOffset:xOffset yOffset:yOffset context:context];
        
        ICGlyphTextureAtlas *textureAtlas = [self vacantTextureAtlas];
        textureGlyph = [textureAtlas addGlyphBitmapData:data
                                               forGlyph:glyph
                                           sizeInPixels:CGSizeMake(w,h)
                                           boundingRect:*boundingRect
                                                 offset:0.0f
                                                   font:font
                                      uploadImmediately:NO];
        
        if (!textureGlyph) {
            // No more space left in vacant texture atlas
            textureAtlas = [self newTextureAtlas];
            textureGlyph = [textureAtlas addGlyphBitmapData:data
                                                   forGlyph:glyph
                                               sizeInPixels:CGSizeMake(w,h)
                                               boundingRect:*boundingRect
                                                     offset:0.0f
                                                       font:font
                                          uploadImmediately:NO];
        }
        
        NSAssert(textureGlyph != nil, @"Something went terribly wrong here");
        
        [self cacheTextureGlyph:textureGlyph];
        
        CGContextRelease(context);
        free(data);
    }
    
    return textureGlyph;
}

// FIXME: do not cache spaces!?
- (NSArray *)cacheGlyphs:(ICGlyph *)glyphs count:(NSInteger)count font:(ICFont *)font
{
#if IC_ENABLE_DEBUG_GLYPH_CACHE
    NSMutableString *glyphString = [[NSMutableString alloc] initWithCapacity:count];
    CGFontRef cgFont = CTFontCopyGraphicsFont(font.fontRef, NULL);
    for (CFIndex i=0; i<count; i++) {
        NSString *glyphName = (NSString *)CGFontCopyGlyphNameForGlyph(cgFont, glyphs[i]);
        [glyphString appendString:glyphName];
        [glyphName release];
    }
    CFRelease(cgFont);
    NSLog(@"Caching glyphs '%@'", glyphString);
    [glyphString release];
#endif
    
    NSMutableArray *textureGlyphs = [NSMutableArray arrayWithCapacity:count];
    
    CGRect *boundingRects = (CGRect *)malloc(sizeof(CGRect) * count);
    CTFontGetBoundingRectsForGlyphs(font.fontRef, kCTFontDefaultOrientation, glyphs, boundingRects, count);
    
    for (CFIndex i=0; i<count; i++) {
        [textureGlyphs addObject:[self rasterizeAndCacheGlyph:glyphs[i]
                                                 boundingRect:&boundingRects[i]
                                                         font:font]];
    }
    
    free(boundingRects);
    
    if ([textureGlyphs count] > 0)
        return textureGlyphs;
    
    return nil; // something went wrong
}

- (ICTextureGlyph *)cacheGlyph:(ICGlyph)glyph font:(ICFont *)font
{
    NSArray *textureGlyphs = [self cacheGlyphs:&glyph count:1 font:font];
    if ([textureGlyphs count] > 0) {
        return [textureGlyphs objectAtIndex:0];
    }
    return nil;
}

- (void)cacheGlyphsWithRun:(CTRunRef)run font:(ICFont *)font
{
    CFIndex glyphCount = CTRunGetGlyphCount(run);
    CGGlyph *glyphs = (CGGlyph *)malloc(sizeof(CGGlyph)*glyphCount);
    CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);
    [self cacheGlyphs:glyphs count:glyphCount font:font];
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

- (ICTextureGlyph *)retrieveCachedTextureGlyph:(ICGlyph)glyph font:(ICFont *)font
{
    NSString *internalFontName = icInternalFontNameForFont(font);
    NSMutableDictionary *glyphsForFont = [_textureGlyphs objectForKey:internalFontName];
    return [glyphsForFont objectForKey:[NSNumber numberWithUnsignedShort:glyph]];
}

// FIXME: caching lots of single glyphs using this method may be terribly inefficient
// if data is kept by texture atlas (as it is currently)
- (ICTextureGlyph *)textureGlyphForGlyph:(ICGlyph)glyph font:(ICFont *)font
{
    ICTextureGlyph *textureGlyph = [self retrieveCachedTextureGlyph:glyph font:font];
    
    // If glyph not already cached, cache it now
    if (!textureGlyph) {
        textureGlyph = [self cacheGlyph:glyph font:font];
    }
    
    // Upload texture if data is dirty
    if (textureGlyph.textureAtlas.dataDirty) {
        [textureGlyph.textureAtlas upload];
    }
    
    return textureGlyph;
}

- (NSArray *)textureGlyphsForGlyphs:(ICGlyph *)glyphs count:(NSInteger)count font:(ICFont *)font
{
    NSMutableArray *resultTextureGlyphs = [NSMutableArray arrayWithCapacity:count];
    
    NSString *internalFontName = icInternalFontNameForFont(font);
    NSMutableDictionary *glyphsForFont = [_textureGlyphs objectForKey:internalFontName];
    if (!glyphsForFont) {
        glyphsForFont = [NSMutableDictionary dictionaryWithCapacity:count];
        [_textureGlyphs setObject:glyphsForFont forKey:internalFontName];
    }
    NSNumber *notFoundMarker = [NSNumber numberWithInteger:NSNotFound];
    
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:count];
    NSInteger i=0;
    for (; i<count; i++) {
        [keys addObject:[NSNumber numberWithUnsignedShort:glyphs[i]]];
    }
    
    i = 0;
    NSArray *textureGlyphs = [glyphsForFont objectsForKeys:keys notFoundMarker:notFoundMarker];
    for (id object in textureGlyphs) {
        ICTextureGlyph *textureGlyph = (ICTextureGlyph *)object;
        
        if ([object isKindOfClass:[NSNumber class]] &&
            [object integerValue] == NSNotFound) {
            // Hit a not found marker -- this glyph has not been cached yet, so cache it
            textureGlyph = [self cacheGlyph:glyphs[i] font:font];
        }
        
        [resultTextureGlyphs addObject:textureGlyph];
        
        i++;
    }
    
    // Upload all dirty textures
    for (ICTextureGlyph *textureGlyph in resultTextureGlyphs) {
        if (textureGlyph.textureAtlas.dataDirty) {
            [textureGlyph.textureAtlas upload];
        }
    }
    
    return resultTextureGlyphs;
}

- (NSDictionary *)textureGlyphsSeparatedByTextureForGlyphs:(ICGlyph *)glyphs
                                                     count:(NSInteger)count
                                                      font:(ICFont *)font
{
    NSInteger i = 0;
    NSMutableDictionary *glyphsByTexture = [NSMutableDictionary dictionary];
    NSArray *textureGlyphs = [self textureGlyphsForGlyphs:glyphs count:count font:font];
    for (ICTextureGlyph *textureGlyph in textureGlyphs) {
        NSValue *textureKey = [NSValue valueWithPointer:textureGlyph.textureAtlas];
        NSMutableArray *glyphsForTexture = [glyphsByTexture objectForKey:textureKey];
        if (!glyphsForTexture) {
            glyphsForTexture = [[NSMutableArray alloc] initWithCapacity:1];
            [glyphsByTexture setObject:glyphsForTexture forKey:textureKey];
        }
        NSArray *glyphEntry = [NSArray arrayWithObjects:[NSNumber numberWithInteger:i], textureGlyph, nil];
        [glyphsForTexture addObject:glyphEntry];
        i++;
    }
    
    return glyphsByTexture;
}

- (void)purge
{
    [_textureGlyphs release];
    _textureGlyphs = nil;
    [_textures release];
    _textures = nil;
}

@end
