//
//  Copyright (C) 2016 Tobias Lensing, Marcus Tillmanns
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
#import "ICFont.h"
#import "ICFontCache.h"
#import "icFontDefs.h"

@interface ICFont ()

- (id)initWithName:(NSString *)fontName size:(CGFloat)size;
- (id)initWithCoreTextFont:(CTFontRef)ctFont;
- (void)setName:(NSString *)name;
- (void)setSize:(CGFloat)size;

- (CTFontRef)fontRef;
- (void)setFontRef:(CTFontRef)fontRef;

@end

@implementation ICFont

@synthesize name = _name;
@synthesize size = _size;

+ (id)fontWithName:(NSString *)fontName size:(CGFloat)size
{
    ICFont *cachedFont = [[ICFontCache sharedFontCache] fontForName:fontName size:size];
    if (!cachedFont) {
        cachedFont = [[[[self class] alloc] initWithName:fontName
                                                    size:size] autorelease];
    }
    return cachedFont;
}

+ (id)systemFontWithSize:(CGFloat)size
{
    CTFontRef systemFont = CTFontCreateUIFontForLanguage(kCTFontSystemFontType, ICFontPointsToPixels(size), NULL);
    ICFont * font = [[self class] fontWithCoreTextFont:systemFont];
    CFRelease(systemFont);
    return font;
}

+ (id)systemFontWithDefaultSize
{
    return [[self class] systemFontWithSize:IC_DEFAULT_SYSTEM_FONT_SIZE];
}

+ (id)fontWithCoreTextFont:(CTFontRef)ctFont
{
    NSString *fontName = (NSString *)CTFontCopyDisplayName(ctFont);
    CGFloat size = ICFontPixelsToPoints(CTFontGetSize(ctFont));
    ICFont *cachedFont = [[ICFontCache sharedFontCache] fontForName:fontName size:size];
    if (!cachedFont) {
        cachedFont = [[[[self class] alloc] initWithCoreTextFont:ctFont] autorelease];
    }
    [fontName release];
    return cachedFont;
}

- (void)setName:(NSString *)name
{
    [_name release];
    _name = [name copy];
}

- (void)setSize:(CGFloat)size
{
    _size = size;
}

- (CGFloat)size
{
    return _size;
}

- (CGFloat)sizeInPixels
{
    return ICFontPointsToPixels(_size);
}


// Private

- (id)initWithName:(NSString *)fontName size:(CGFloat)size
{
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)fontName, ICFontPointsToPixels(size), nil);
    self = [self initWithCoreTextFont:ctFont];
    CFRelease(ctFont);
    return self;
}

- (id)initWithCoreTextFont:(CTFontRef)ctFont
{
    if ((self = [super init])) {
        self.fontRef = ctFont;
        
        NSString *fontName = (NSString *)CTFontCopyDisplayName(self.fontRef);
        self.name = fontName;
        [fontName release];
        
        self.size = ICFontPixelsToPoints(CTFontGetSize(self.fontRef));
        
        // Register font upon initialization
        [[ICFontCache sharedFontCache] registerFont:self];
    }
    return self;
}

- (void)dealloc
{
    self.fontRef = nil;
    self.name = nil;
    
    [super dealloc];
}

- (CTFontRef)fontRef
{
    return _fontRef;
}

- (void)setFontRef:(CTFontRef)fontRef
{
    if (_fontRef)
        CFRelease(_fontRef);
    _fontRef = fontRef;
    if (_fontRef)
        CFRetain(_fontRef);
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ = %08X | name = %@ | size = %0.02f>",
            [self class], (uint)self, self.name, self.size];
}

@end
