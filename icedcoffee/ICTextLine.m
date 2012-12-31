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

#import "ICTextLine.h"
#import "icFontTypes.h"
#import "icFontUtils.h"
#import "ICGlyphCache.h"
#import "icUtils.h"

@interface ICTextLine ()

- (NSAttributedString *)coreTextAttributedString;
- (void)updateLine;

@property (nonatomic, retain) NSMutableArray *runs;

- (CTLineRef)ctLine;
- (void)setCtLine:(CTLineRef)ctLine;

@end

@implementation ICTextLine

@synthesize runs = _runs;
@synthesize attributedString = _attributedString;

+ (id)textLineWithString:(NSString *)string font:(ICFont *)font
{
    return [[[[self class] alloc] initWithString:string font:font] autorelease];
}

+ (id)textLineWithString:(NSString *)string attributes:(NSDictionary *)attributes
{
    return [[[[self class] alloc] initWithString:string attributes:attributes] autorelease];
}

+ (id)textLineWithAttributedString:(NSAttributedString *)attributedString
{
    return [[[[self class] alloc] initWithAttributedString:attributedString] autorelease];
}

- (id)initWithString:(NSString *)string font:(ICFont *)font
{
    return [self initWithString:string
                     attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                 font, ICFontAttributeName, nil]];
}

- (id)initWithString:(NSString *)string attributes:(NSDictionary *)attributes
{
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string
                                                                           attributes:attributes];
    self = [self initWithAttributedString:attributedString];
    [attributedString release];
    return self;
}

- (id)initWithAttributedString:(NSAttributedString *)attributedString
{
    if ((self = [super init])) {
        [self addObserver:self
               forKeyPath:@"attributedString"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
        self.attributedString = attributedString;
    }
    return self;
}

- (id)initWithCoreTextLine:(CTLineRef)ctLine
        icAttributedString:(NSAttributedString *)icAttString
               stringRange:(NSRange)stringRange
{
    self.ctLine = ctLine;
    _stringRange = stringRange;
    return [self initWithAttributedString:icAttString];
}

- (void)dealloc
{
    self.ctLine = nil;
    self.attributedString = nil;
    [self removeObserver:self forKeyPath:@"attributedString"];

    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"attributedString"]) {
        [self updateLine];
    }
}

- (NSString *)string
{
    return [self.attributedString string];
}

- (NSAttributedString *)coreTextAttributedString
{
    NSAttributedString *ctAttString = icCreateCTAttributedStringWithAttributedString(self.attributedString);
    [ctAttString autorelease];
    return ctAttString;
}

- (CTLineRef)ctLine
{
    return _ctLine;
}

- (void)setCtLine:(CTLineRef)ctLine
{
    if (_ctLine)
        CFRelease(_ctLine);
    _ctLine = ctLine;
    if (_ctLine)
        CFRetain(_ctLine);
}

- (void)updateLine
{
    [self removeAllChildren];
    
    CTLineRef ctLine = nil;
    if (self.ctLine) {
        ctLine = self.ctLine;
        CFRetain(self.ctLine);
    }
    if (!ctLine) {
        NSAttributedString *ctAttString = icCreateCTAttributedStringWithAttributedString(self.attributedString);
        ctLine = CTLineCreateWithAttributedString((CFAttributedStringRef)ctAttString);
        [ctAttString release];
    }
    
    CFArrayRef runs = CTLineGetGlyphRuns(ctLine);
    CFIndex runCount = CFArrayGetCount(runs);
    
    CTLineGetTypographicBounds(ctLine, &_ascent, &_descent, &_leading);
    
    _ascent = ICFontPixelsToPoints(_ascent);
    _descent = ICFontPixelsToPoints(_descent);
    _leading = ICFontPixelsToPoints(_leading);
    
    float lineAscent = roundf(_ascent);
    
    self.runs = [NSMutableArray arrayWithCapacity:runCount];
    
    for (CFIndex i=0; i<runCount; i++) {
        CTRunRef ctRun = (CTRunRef)CFArrayGetValueAtIndex(runs, i);
        
        CFRange stringRange = CTRunGetStringRange(ctRun);
        stringRange.location -= _stringRange.location;
        
        __block NSMutableDictionary *extendedAttrs = [[NSMutableDictionary alloc] init];
        NSAttributedString *attSubString = [self.attributedString attributedSubstringFromRange:
                                            NSMakeRange(stringRange.location, stringRange.length)];
        [attSubString enumerateAttributesInRange:NSMakeRange(0, [attSubString length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            for (NSString *attrName in attrs) {
                if ([attrName isEqualToString:ICGammaAttributeName]) {
                    [extendedAttrs setObject:[attrs objectForKey:attrName] forKey:attrName];
                }
            }
        }];
        
        ICGlyphRun *run = [[ICGlyphRun alloc] initWithCoreTextRun:ctRun
                                               extendedAttributes:extendedAttrs];
        float runAscent = roundf([run ascent]);
        [run setPositionY:lineAscent - runAscent];
        [self.runs addObject:run];
        [self addChild:run];
        [run release];
        
        [extendedAttrs release];
    }
    
    CFRelease(ctLine);
    
    // Set line bounds
    kmAABB aabb = icComputeAABBContainingAABBsOfNodes(self.runs);
    kmVec3 size;
    kmVec3Subtract(&size, &aabb.max, &aabb.min);
    self.origin = aabb.min;
    self.size = size;
    
    [self setNeedsDisplay];
}

- (float)ascent
{
    return (float)_ascent;
}

- (float)descent
{
    return (float)_descent;
}

- (float)leading
{
    return (float)_leading;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    
    for (ICGlyphRun *run in self.runs) {
        [run setUserInteractionEnabled:userInteractionEnabled];
    }
}

@end
