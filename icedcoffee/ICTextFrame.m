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

#import "ICTextFrame.h"
#import "ICTextLine.h"
#import "icFontDefs.h"
#import "icFontUtils.h"
#import "icUtils.h"

@interface ICTextFrame ()
- (void)updateFrame;
@end

@implementation ICTextFrame

@synthesize lines = _lines;
@synthesize attributedString = _attributedString;

+ (id)textFrameWithSize:(kmVec2)size string:(NSString *)string font:(ICFont *)font
{
    return [[[[self class] alloc] initWithSize:size string:string font:font] autorelease];
}

+ (id)textFrameWithSize:(kmVec2)size attributedString:(NSAttributedString *)attributedString
{
    return [[[[self class] alloc] initWithSize:size attributedString:attributedString] autorelease];
}

- (id)initWithSize:(kmVec2)size string:(NSString *)string font:(ICFont *)font
{
    return [self initWithSize:size
                       string:string
                   attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                               font, ICFontAttributeName, nil]];
}

- (id)initWithSize:(kmVec2)size string:(NSString *)string attributes:(NSDictionary *)attributes
{
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string
                                                                           attributes:attributes];
    self = [self initWithSize:size attributedString:attributedString];
    [attributedString release];
    return self;
}

- (id)initWithSize:(kmVec2)size attributedString:(NSAttributedString *)attributedString
{
    if ((self = [super init])) {
        self.size = kmVec3Make(size.width, size.height, 0);
        self.attributedString = attributedString;
    }
    return self;
}

- (void)dealloc
{
    self.attributedString = nil;
    self.lines = nil;
    
    [super dealloc];
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
    [_attributedString release];
    _attributedString = [attributedString copy];
    [self updateFrame];
}

- (void)updateFrame
{
    [self removeAllChildren];
    
    CGRect frameRect = CGRectMake(ICFontPointsToPixels(self.origin.x),
                                  ICFontPointsToPixels(self.origin.y),
                                  ICFontPointsToPixels(self.size.width),
                                  ICFontPointsToPixels(self.size.height));
    CGPathRef path = CGPathCreateWithRect(frameRect, NULL);
    
    NSAttributedString *ctAttString = icCreateCTAttributedStringWithAttributedString(self.attributedString);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)ctAttString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);

    CFArrayRef lines = CTFrameGetLines(frame);
    CFIndex lineCount = CFArrayGetCount(lines);
    self.lines = [NSMutableArray arrayWithCapacity:lineCount];

    CGPoint *origins = (CGPoint *)malloc(sizeof(CGPoint) * lineCount);
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);

    for (CFIndex i=0; i<lineCount; i++) {
        CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, i);
        CFRange cfStringRange = CTLineGetStringRange(line);
        NSRange stringRange = NSMakeRange(cfStringRange.location, cfStringRange.length);
        NSAttributedString *attSubString = [self.attributedString attributedSubstringFromRange:stringRange];
        ICTextLine *textLine = [[ICTextLine alloc] initWithCoreTextLine:line
                                                     icAttributedString:attSubString
                                                            stringRange:stringRange];
        textLine.userInteractionEnabled = self.userInteractionEnabled;
        CGPoint origin = origins[i];
        origin.x = ICFontPixelsToPoints(origin.x);
        origin.y = roundf(ICFontPixelsToPoints(origin.y)+[textLine ascent]);
        //NSLog(@"origin: %f", origin.y);
        [textLine setPositionX:origin.x];
        [textLine setPositionY:self.size.height - origin.y];
        [(NSMutableArray *)self.lines addObject:textLine];
        [self addChild:textLine];
        [textLine release];
    }
    
    [ctAttString release];
    free(origins);
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(frame);
    
    [self setNeedsDisplay];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    
    for (ICTextLine *line in self.lines) {
        [line setUserInteractionEnabled:userInteractionEnabled];
    }
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    [super drawWithVisitor:visitor];
    //[self debugDrawBoundingBox];
}

- (NSInteger)stringIndexForPosition:(kmVec2)point
{
    ICTextLine *selectedLine = nil;
    for (ICTextLine *line in self.lines) {
        if (point.y > line.position.y &&
            point.y < line.position.y + line.descent + line.ascent)
        {
            selectedLine = line;
            break;
        }
    }
    
    if (selectedLine) {
        kmVec2 linePoint = kmVec2Make(point.x - selectedLine.position.x, point.y - selectedLine.position.y);
        //return selectedLine.stringRange.location + [selectedLine stringIndexForPosition:linePoint];
        return [selectedLine stringIndexForPosition:linePoint];
    }
    
    return 0; // fail
}

- (NSInteger)stringIndexForHorizontalOffset:(float)offset inLine:(ICTextLine *)line
{
    kmVec2 linePoint = kmVec2Make(offset - line.position.x, 0);
    return [line stringIndexForPosition:linePoint];
}

- (kmVec2)offsetForStringIndex:(NSInteger)stringIndex line:(ICTextLine **)outLine
{
    int i = 0;
    for (ICTextLine *line in self.lines) {
        NSUInteger location = line.stringRange.location;
        BOOL lineEndsWithLineBreak = [self lineEndsWithLineBreak:line];
        if (stringIndex >= location &&
            ((lineEndsWithLineBreak && stringIndex <= location + line.stringRange.length - 1) ||
            (!lineEndsWithLineBreak && stringIndex <= location + line.stringRange.length)))
        {
            // Within existing line
            if (outLine)
                *outLine = line;
            
            float offsetX;
            float offsetY;
            offsetX = [line offsetForStringIndex:stringIndex];
            offsetY = line.position.y;
            return kmVec2Make(offsetX, offsetY);
        } else if (i == [self.lines count] - 1 &&
                   stringIndex > location &&
                   lineEndsWithLineBreak && stringIndex == location + line.stringRange.length)
        {
            // Past end of last line
            if (outLine)
                *outLine = nil;

            float offsetX;
            float offsetY;
            offsetX = 0;
            offsetY = line.position.y + line.size.height;
            return kmVec2Make(offsetX, offsetY);
        }
        i++;
    }
    
    return kmVec2Make(0, 0);
}

- (BOOL)lineEndsWithLineBreak:(ICTextLine *)line
{
    return line.string && [line.string length] > 0 && [[line.string substringFromIndex:line.string.length - 1] isEqualToString:@"\n"];
}

@end
