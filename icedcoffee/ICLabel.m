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

#import "ICLabel.h"
#import "ICSprite.h"
#import "ICTexture2D.h"
#import "ICShaderCache.h"
#import "ICShaderProgram.h"
#import "ICFont.h"
#import "ICTextLine.h"
#import "ICTextFrame.h"
#import "icUtils.h"

// FIXME: ICLabel support for 32-bit textures (?)

@interface ICLabel ()

+ (NSAttributedString *)attributedTextWithText:(NSString *)text
                                          font:(ICFont *)font
                                         color:(icColor4B)color
                                         gamma:(float)gamma;
+ (void)measureTextForAutoresizing:(NSString *)text
                              font:(ICFont *)font
                            origin:(kmVec3 *)origin size:(kmVec3 *)size;
- (void)autoresizeToText;
- (void)updateFrame;
- (void)setText:(NSString *)text updateAttributedText:(BOOL)updateAttributedText;
- (void)updateAttributedTextWithBasicProperties;
- (void)updateFontWithBasicFontProperties;
- (void)updateBasicFontPropertiesWithFont;

@property (nonatomic, retain) ICTextFrame *textFrame;

@end


@implementation ICLabel

@synthesize textFrame = _textFrame;

@synthesize text = _text;
@synthesize attributedText = _attributedText;
@synthesize font = _font;
@synthesize fontName = _fontName;
@synthesize fontSize = _fontSize;
@synthesize color = _color;
@synthesize autoresizesToTextSize = _autoresizesToTextSize;

+ (id)label
{
    return [[[[self class] alloc] init] autorelease];
}

+ (id)labelWithSize:(CGSize)size
{
    return [[[[self class] alloc] initWithSize:size] autorelease];
}

+ (id)labelWithSize:(CGSize)size attributedText:(NSAttributedString *)attributedText
{
    return [[[[self class] alloc] initWithSize:size attributedText:attributedText] autorelease];
}

+ (id)labelWithText:(NSString *)text
{
    return [[[[self class] alloc] initWithText:text] autorelease];
}

+ (id)labelWithText:(NSString *)text font:(ICFont *)font
{
    return [[[[self class] alloc] initWithText:text font:font] autorelease];
}

+ (id)labelWithText:(NSString *)text fontName:(NSString *)fontName fontSize:(CGFloat)fontSize
{
    return [[[[self class] alloc] initWithText:text fontName:fontName fontSize:fontSize] autorelease];
}

- (id)init
{
    return [super init];
}

- (id)initWithSize:(CGSize)size
{
    if ((self = [super initWithSize:size])) {
        self.font = [ICFont systemFontWithDefaultSize];
        self.color = (icColor4B){0,0,0,255};
        self.gamma = 1.0f;
    }
    return self;
}

- (id)initWithSize:(CGSize)size attributedText:(NSAttributedString *)attributedText
{
    if ((self = [self initWithSize:size])) {
        self.attributedText = attributedText;
    }
    return self;
}

- (id)initWithText:(NSString *)text
{
    if ((self = [self initWithSize:CGSizeMake(0, 0)])) {
        self.autoresizesToTextSize = YES;
        self.text = text;
    }
    return self;
}

- (id)initWithText:(NSString *)text font:(ICFont *)font
{
    if ((self = [self initWithSize:CGSizeMake(0, 0)])) {
        self.autoresizesToTextSize = YES;
        self.font = font;
        self.text = text;
    }
    return self;
}

- (id)initWithText:(NSString *)text fontName:(NSString *)fontName fontSize:(CGFloat)fontSize
{
    // Initialize with designated initializer
    if ((self = [self initWithSize:CGSizeMake(0, 0)])) {
        self.autoresizesToTextSize = YES;
        self.fontName = fontName;
        self.fontSize = fontSize;
        self.text = text;
    }
    
    return self;
}

- (void)dealloc
{
    self.textFrame = nil;
    self.attributedText = nil;
    self.font = nil;
    self.fontName = nil;
    
    [super dealloc];
}

- (void)updateAttributedTextWithBasicProperties
{
    if (!_shouldNotApplyPropertiesFromBasicText) {
        BOOL isNullColor = self.color.r == 0 && self.color.g == 0 &&
        self.color.b == 0 && self.color.a == 0;
        
        if (self.font && self.text && !isNullColor) {
            _shouldNotApplyPropertiesFromAttributedText = YES;
            self.attributedText = [[self class] attributedTextWithText:self.text
                                                                  font:self.font
                                                                 color:self.color
                                                                 gamma:self.gamma];
            _shouldNotApplyPropertiesFromAttributedText = NO;
        }
    }
}

- (void)setText:(NSString *)text
{
    [self setText:text updateAttributedText:!_shouldNotApplyPropertiesFromBasicText];
}

- (void)setText:(NSString *)text updateAttributedText:(BOOL)updateAttributedText
{
    [_text release];
    _text = [text copy];

    if (updateAttributedText)
        [self updateAttributedTextWithBasicProperties];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [_attributedText release];
    _attributedText = [attributedText copy];
    
    // Apply attributes to label properties if setting attributedText from outside
    if (!_shouldNotApplyPropertiesFromAttributedText) {
        
        __block ICFont *font = nil;
        __block BOOL colorSet = NO;
        __block icColor4B color = self.color;
        __block BOOL gammaSet = NO;
        __block float gamma = self.gamma;
        
        // This is a potentially lossy conversion, i.e. the first attribute always wins
        [self.attributedText enumerateAttributesInRange:NSMakeRange(0, [self.attributedText length])
                                                options:0
                                             usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            if (!font) {
                font = [attrs objectForKey:ICFontAttributeName];
            }
            if (!colorSet) {
                NSValue *colorValue = [attrs objectForKey:ICForegroundColorAttributeName];
                if (colorValue) {
                    [colorValue getValue:&color];
                    colorSet = YES;
                }
            }
            if (!gammaSet) {
                NSNumber *gammaNumber = [attrs objectForKey:ICGammaAttributeName];
                if (gammaNumber) {
                    gamma = [gammaNumber floatValue];
                    gammaSet = YES;
                }
            }
            if (font && colorSet && gammaSet) {
                *stop = YES;
            }
        }];
        
        _shouldNotApplyPropertiesFromBasicText = YES;
        
        if (font) {
            [self setFontName:font.name];
            [self setFontSize:font.size];
        }
        if (colorSet) {
            self.color = color;
        }
        if (gammaSet) {
            self.gamma = gamma;
        }
        
        [self setText:[self.attributedText string]];
        
        _shouldNotApplyPropertiesFromBasicText = NO;
    }

    // Update internal text frame
    [self updateFrame];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ICLabelTextDidChange object:self];
    
    [self setNeedsDisplay];
}

- (void)updateFontWithBasicFontProperties
{
    if (self.fontName && self.fontSize && (![self.fontName isEqualToString:self.font.name] ||
        self.fontSize != self.font.size)) {
        self.font = [ICFont fontWithName:self.fontName size:self.fontSize];
        [self updateBasicFontPropertiesWithFont];
    }
}

- (void)updateBasicFontPropertiesWithFont
{
    if (![self.fontName isEqualToString:self.font.name])
        self.fontName = self.font.name;
    if (self.fontSize != self.font.size)
        self.fontSize = self.font.size;
}

- (void)setFontName:(NSString *)fontName
{
    [_fontName release];
    _fontName = [fontName copy];
    
    [self updateFontWithBasicFontProperties];

    [[NSNotificationCenter defaultCenter] postNotificationName:ICLabelFontDidChange object:self];
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    
    [self updateFontWithBasicFontProperties];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ICLabelFontDidChange object:self];    
}

- (void)setFont:(ICFont *)font
{
    [_font release];
    _font = [font retain];
    
    [self updateBasicFontPropertiesWithFont];
    [self updateAttributedTextWithBasicProperties];
}

- (void)setColor:(icColor4B)color
{
    _color = color;
    
    [self updateAttributedTextWithBasicProperties];
}

- (void)setGamma:(float)gamma
{
    _gamma = gamma;
    
    [self updateAttributedTextWithBasicProperties];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [self.textFrame setUserInteractionEnabled:userInteractionEnabled];
}

+ (NSAttributedString *)attributedTextWithText:(NSString *)text
                                          font:(ICFont *)font
                                         color:(icColor4B)color
                                         gamma:(float)gamma
{
    NSValue *foregroundColorValue = [NSValue valueWithBytes:&color objCType:@encode(icColor4B)];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, ICFontAttributeName,
                                foregroundColorValue, ICForegroundColorAttributeName,
                                [NSNumber numberWithFloat:gamma], ICGammaAttributeName,
                                nil];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                         attributes:attributes];
    return [attributedText autorelease];
}

+ (void)measureTextForAutoresizing:(NSString *)text
                              font:(ICFont *)font
                            origin:(kmVec3 *)origin
                              size:(kmVec3 *)size
{
    // Measure each text line contained in text
    NSArray *lines = [text componentsSeparatedByString:@"\n"];
    NSMutableArray *textLines = [[NSMutableArray alloc] initWithCapacity:[lines count]];
    for (NSString *line in lines) {
        ICTextLine *textLine = [[ICTextLine alloc] initWithString:line font:font];
        [textLines addObject:textLine];
        [textLine release];
    }
    
    kmAABB aabb = icComputeAABBContainingAABBsOfNodes(textLines);
    if (origin) {
        *origin = aabb.min;
    }
    if (size) {
        *size = kmVec3Make(aabb.max.x - aabb.min.x,
                           aabb.max.y - aabb.min.y,
                           aabb.max.z - aabb.min.z);
    }
    
    [textLines release];
}

- (void)autoresizeToText
{
    kmVec3 origin, size;
    ICFont *font = [ICFont fontWithName:self.fontName size:self.fontSize];
    [[self class] measureTextForAutoresizing:self.text font:font origin:&origin size:&size];
    self.origin = origin;
    self.size = size;
}

- (void)updateFrame
{
    if (self.autoresizesToTextSize) {
        [self autoresizeToText];
    }
    
    if (!self.textFrame) {
        ICTextFrame *textFrame = [[ICTextFrame alloc] initWithSize:kmVec2Make(self.size.width, self.size.height)
                                                  attributedString:self.attributedText];
        [self addChild:textFrame];
        self.textFrame = textFrame;
        [textFrame release];
    } else {
        self.textFrame.size = self.size;
        self.textFrame.attributedString = self.attributedText;
    }
}

@end
