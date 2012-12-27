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

@interface ICTextLine ()
- (void)updateLine;
@property (nonatomic, retain) NSMutableArray *runs;
@end

@implementation ICTextLine

@synthesize runs = _runs;
@synthesize attributedString = _attributedString;
@synthesize baseline = _baseline;

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

- (void)dealloc
{
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

- (void)updateLine
{
    [self removeAllChildren];
    self.runs = [NSMutableArray arrayWithCapacity:1];
    
    __block float maxBaseline = 0.f;
    [self.attributedString enumerateAttributesInRange:NSMakeRange(0, self.attributedString.length)
                                              options:0
                                           usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSString *subString = [[self string] substringWithRange:range];
        ICGlyphRun *run = [ICGlyphRun glyphRunWithString:subString attributes:attrs];
        ICGlyphRun *prevRun = [self.runs lastObject];
        if (prevRun) {
            // FIXME: glyph advance orientation could be non-X
            kmAABB prevRunAABB = [prevRun aabb];
            [run setPositionX:prevRunAABB.max.x];
        }
        [self.runs addObject:run];
        [self addChild:run];

        if ([run baseline] > maxBaseline) {
           maxBaseline = [run baseline];
        }
    }];
    
    [self willChangeValueForKey:@"baseline"];
    _baseline = maxBaseline;
    [self didChangeValueForKey:@"baseline"];
    
    for (ICGlyphRun *run in self.runs) {
        [run setPositionY:run.position.y + maxBaseline - [run baseline]];
    }
}

@end
