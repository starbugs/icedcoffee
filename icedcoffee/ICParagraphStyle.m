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

#import "ICParagraphStyle.h"
#import "icTypes.h"
#import "icFontDefs.h"
#import "ICTextTab.h"


ICTextAlignment ICTextAlignmentFromCTTextAlignment(CTTextAlignment textAlignment)
{
    switch (textAlignment) {
        case kCTTextAlignmentLeft: return ICTextAlignmentLeft;
        case kCTTextAlignmentCenter: return ICTextAlignmentCenter;
        case kCTTextAlignmentRight: return ICTextAlignmentRight;
        case kCTTextAlignmentJustified: return ICTextAlignmentJustified;
        case kCTTextAlignmentNatural: return ICTextAlignmentNatural;
    }
    assert(nil && @"Invalid text alignment value");
    return ICTextAlignmentNatural;
}

CTTextAlignment CTTextAlignmentFromICTextAlignment(ICTextAlignment textAlignment)
{
    switch (textAlignment) {
        case ICTextAlignmentLeft: return kCTTextAlignmentLeft;
        case ICTextAlignmentCenter: return kCTTextAlignmentCenter;
        case ICTextAlignmentRight: return kCTTextAlignmentRight;
        case ICTextAlignmentJustified: return kCTTextAlignmentJustified;
        case ICTextAlignmentNatural: return kCTTextAlignmentNatural;
    }
    assert(nil && @"Invalid text alignment value");
    return kCTTextAlignmentNatural;
}

ICLineBreakMode ICLineBreakModeFromCTLineBreakMode(CTLineBreakMode lineBreakMode)
{
    switch (lineBreakMode) {
        case kCTLineBreakByCharWrapping: return ICLineBreakByCharWrapping;
        case kCTLineBreakByClipping: return ICLineBreakByClipping;
        case kCTLineBreakByTruncatingHead: return ICLineBreakByTruncatingHead;
        case kCTLineBreakByTruncatingMiddle: return ICLineBreakByTruncatingMiddle;
        case kCTLineBreakByTruncatingTail: return ICLineBreakByTruncatingTail;
        case kCTLineBreakByWordWrapping: return ICLineBreakByWordWrapping;
    }
    assert(nil && @"Invalid line break mode value");
    return ICLineBreakByWordWrapping;
}

CTLineBreakMode CTLineBreakModeFromICLineBreakMode(ICLineBreakMode lineBreakMode)
{
    switch (lineBreakMode) {
        case ICLineBreakByCharWrapping: return kCTLineBreakByCharWrapping;
        case ICLineBreakByClipping: return kCTLineBreakByClipping;
        case ICLineBreakByTruncatingHead: return kCTLineBreakByTruncatingHead;
        case ICLineBreakByTruncatingMiddle: return kCTLineBreakByTruncatingMiddle;
        case ICLineBreakByTruncatingTail: return kCTLineBreakByTruncatingTail;
        case ICLineBreakByWordWrapping: return kCTLineBreakByWordWrapping;
    }
    assert(nil && @"Invalid line break mode value");
    return kCTLineBreakByWordWrapping;
}

ICWritingDirection ICWritingDirectionFromCTWritingDirection(CTWritingDirection writingDirection)
{
    switch (writingDirection) {
        case kCTWritingDirectionLeftToRight: return ICWritingDirectionLeftToRight;
        case kCTWritingDirectionNatural: return ICWritingDirectionNatural;
        case kCTWritingDirectionRightToLeft: return ICWritingDirectionRightToLeft;
    }
    assert(nil && @"Invalid writing direction value");
    return ICWritingDirectionNatural;
}

CTWritingDirection CTWritingDirectionFromICWritingDirection(ICWritingDirection writingDirection)
{
    switch (writingDirection) {
        case ICWritingDirectionLeftToRight: return kCTWritingDirectionLeftToRight;
        case ICWritingDirectionNatural: return kCTWritingDirectionNatural;
        case ICWritingDirectionRightToLeft: return kCTWritingDirectionRightToLeft;
    }
    assert(nil && @"Invalid writing direction value");
    return kCTWritingDirectionNatural;
}

NSArray *ICCreateTextTabsFromCTTextTabs(NSArray *ctTextTabs)
{
    if (ctTextTabs) {
        NSMutableArray *textTabs = [[NSMutableArray alloc] initWithCapacity:[ctTextTabs count]];
        
        for (id idTextTab in ctTextTabs) {
            CTTextTabRef ctTextTab = (CTTextTabRef)idTextTab;
            ICTextAlignment textAlignment = ICTextAlignmentFromCTTextAlignment(CTTextTabGetAlignment(ctTextTab));
            double location = CTTextTabGetLocation(ctTextTab);
            ICTextTab *textTab = [[ICTextTab alloc] initWithTextAlignment:textAlignment
                                                                 location:location];
            [textTabs addObject:textTab];
            [textTab release];
        }
        
        return textTabs;
    }
    
    return nil;
}

NSArray *ICCreateCTTextTabsFromICTextTabs(NSArray *icTextTabs)
{
    if (icTextTabs) {
        NSMutableArray *ctTextTabs = [[NSMutableArray alloc] initWithCapacity:[icTextTabs count]];
        
        for (ICTextTab *textTab in icTextTabs) {
            CTTextAlignment textAlignment = CTTextAlignmentFromICTextAlignment(textTab.textAlignment);
            CTTextTabRef ctTextTab = CTTextTabCreate(textAlignment, textTab.location, NULL);
            [ctTextTabs addObject:(id)ctTextTab];
            CFRelease(ctTextTab);
        }
        
        return ctTextTabs;
    }
    
    return nil;
}


@interface ICParagraphStyle ()

- (void)setCTParagraphStyle:(CTParagraphStyleRef)ctParagraphStyle;
- (CTParagraphStyleRef)ctParagraphStyle;

@end

@implementation ICParagraphStyle

@synthesize textAlignment = _textAlignment,
            lineBreakMode = _lineBreakMode,
            baseWritingDirection = _baseWritingDirection,
            firstLineHeadIndent = _firstLineHeadIndent,
            headIndent = _headIndent,
            tailIndent = _tailIndent,
            tabStops = _tabStops,
            defaultTabInterval = _defaultTabInterval,
            lineHeightMultiple = _lineHeightMultiple,
            maximumLineHeight = _maximumLineHeight,
            minimumLineHeight = _minimumLineHeight,
            paragraphSpacing = _paragraphSpacing,
            paragraphSpacingBefore = _paragraphSpacingBefore,
            maximumLineSpacing = _maximumLineSpacing,
            minimumLineSpacing = _minimumLineSpacing,
            lineSpacingAdjustment = _lineSpacingAdjustment;

+ (id)paragraphStyle
{
    return [[[[self class] alloc] init] autorelease];
}

+ (id)paragraphStyleWithTextAlignment:(ICTextAlignment)textAlignment
{
    return [[[[self class] alloc] initWithTextAlignment:textAlignment] autorelease];
}

- (id)init
{
    if ((self = [super init])) {
        // This default configuration is supposed to match the defaults in CTParagraphStyle.h
        self.textAlignment = ICTextAlignmentNatural;
        self.lineBreakMode = ICLineBreakByWordWrapping;
        self.baseWritingDirection = ICWritingDirectionNatural;
        self.maximumLineSpacing = IC_HUGE;
    }
    return self;
}

- (id)initWithTextAlignment:(ICTextAlignment)textAlignment
{
    if ((self = [self init])) {
        self.textAlignment = textAlignment;
    }
    return self;
}

- (id)initWithCoreTextParagraphStyle:(CTParagraphStyleRef)ctParagraphStyle
{
    if ((self = [super init])) {
        [self setCTParagraphStyle:ctParagraphStyle];
        
        CTTextAlignment textAlignment;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierAlignment,
                                             sizeof(CTTextAlignment), &textAlignment);
        self.textAlignment = ICTextAlignmentFromCTTextAlignment(textAlignment);
        
        CTLineBreakMode lineBreakMode;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierLineBreakMode,
                                             sizeof(CTLineBreakMode), &lineBreakMode);
        self.lineBreakMode = ICLineBreakModeFromCTLineBreakMode(lineBreakMode);
        
        CTWritingDirection baseWritingDirection;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierBaseWritingDirection,
                                             sizeof(CTWritingDirection), &baseWritingDirection);
        self.baseWritingDirection = ICWritingDirectionFromCTWritingDirection(baseWritingDirection);
        
        CGFloat firstLineHeadIndent;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierFirstLineHeadIndent,
                                             sizeof(CGFloat), &firstLineHeadIndent);
        self.firstLineHeadIndent = (float)ICFontPixelsToPoints(firstLineHeadIndent);
        
        CGFloat headIndent;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierHeadIndent,
                                             sizeof(CGFloat), &headIndent);
        self.headIndent = (float)ICFontPixelsToPoints(headIndent);
        
        CGFloat tailIndent;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierTailIndent,
                                             sizeof(CGFloat), &tailIndent);
        self.tailIndent = (float)ICFontPixelsToPoints(tailIndent);
        
        CFArrayRef tabStops = nil;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierTabStops,
                                             sizeof(CGFloat), &tabStops);
        NSArray *textTabs = ICCreateTextTabsFromCTTextTabs((NSArray *)tabStops);
        self.tabStops = textTabs;
        [textTabs release];
        
        
        CGFloat defaultTapInterval;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierDefaultTabInterval,
                                             sizeof(CGFloat), &defaultTapInterval);
        self.defaultTabInterval = (float)ICFontPixelsToPoints(defaultTapInterval);
        
        CGFloat lineHeightMultiple;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierLineHeightMultiple,
                                             sizeof(CGFloat), &lineHeightMultiple);
        self.lineHeightMultiple = (float)lineHeightMultiple;
        
        CGFloat maximumLineHeight;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierMaximumLineHeight,
                                             sizeof(CGFloat), &maximumLineHeight);
        self.maximumLineHeight = (float)ICFontPixelsToPoints(maximumLineHeight);
        
        CGFloat minimumLineHeight;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierMinimumLineHeight,
                                             sizeof(CGFloat), &minimumLineHeight);
        self.minimumLineHeight = (float)ICFontPixelsToPoints(minimumLineHeight);
        
        CGFloat paragraphSpacing;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierParagraphSpacing,
                                             sizeof(CGFloat), &paragraphSpacing);
        self.paragraphSpacing = (float)ICFontPixelsToPoints(paragraphSpacing);
        
        CGFloat paragraphSpacingBefore;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierParagraphSpacingBefore,
                                             sizeof(CGFloat), &paragraphSpacingBefore);
        self.paragraphSpacingBefore = (float)ICFontPixelsToPoints(paragraphSpacingBefore);
        
        CGFloat maximumLineSpacing;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierMaximumLineSpacing,
                                             sizeof(CGFloat), &maximumLineSpacing);
        self.maximumLineSpacing = (float)ICFontPixelsToPoints(maximumLineSpacing);
        
        CGFloat minimumLineSpacing;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierMinimumLineSpacing,
                                             sizeof(CGFloat), &minimumLineSpacing);
        self.minimumLineSpacing = (float)ICFontPixelsToPoints(minimumLineSpacing);
        
        CGFloat lineSpacingAdjustment;
        CTParagraphStyleGetValueForSpecifier(ctParagraphStyle, kCTParagraphStyleSpecifierLineSpacingAdjustment,
                                             sizeof(CGFloat), &lineSpacingAdjustment);
        self.lineSpacingAdjustment = (float)ICFontPixelsToPoints(lineSpacingAdjustment);
    }
    return self;
}


// Private

- (void)setCTParagraphStyle:(CTParagraphStyleRef)ctParagraphStyle
{
    if (_ctParagraphStyle)
        CFRelease(_ctParagraphStyle);
    _ctParagraphStyle = ctParagraphStyle;
    if (_ctParagraphStyle)
        CFRetain(_ctParagraphStyle);
}

- (CTParagraphStyleRef)ctParagraphStyle
{
    if (!_ctParagraphStyle) {
        CTTextAlignment textAlignment = CTTextAlignmentFromICTextAlignment(self.textAlignment);
        CTParagraphStyleSetting textAlignmentSetting = {
            kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &textAlignment
        };
        
        CTLineBreakMode lineBreakMode = CTLineBreakModeFromICLineBreakMode(self.lineBreakMode);
        CTParagraphStyleSetting lineBreakModeSetting = {
            kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode
        };
        
        CTWritingDirection baseWritingDirection = CTWritingDirectionFromICWritingDirection(self.baseWritingDirection);
        CTParagraphStyleSetting baseWritingDirectionSetting = {
            kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(CTWritingDirection), &baseWritingDirection
        };
        
        CGFloat firstLineHeadIndent = (CGFloat)ICFontPointsToPixels(self.firstLineHeadIndent);
        CTParagraphStyleSetting firstLineHeadIndentSetting = {
            kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &firstLineHeadIndent
        };

        CGFloat headIndent = (CGFloat)ICFontPointsToPixels(self.headIndent);
        CTParagraphStyleSetting headIndentSetting = {
            kCTParagraphStyleSpecifierHeadIndent, sizeof(CGFloat), &headIndent
        };
        
        CGFloat tailIndent = (CGFloat)ICFontPointsToPixels(self.tailIndent);
        CTParagraphStyleSetting tailIndentSetting = {
            kCTParagraphStyleSpecifierTailIndent, sizeof(CGFloat), &tailIndent
        };
        
        CFArrayRef tabStops = (CFArrayRef)ICCreateCTTextTabsFromICTextTabs(self.tabStops);
        CTParagraphStyleSetting tabStopsSetting = {
            kCTParagraphStyleSpecifierTabStops, sizeof(CFArrayRef), &tabStops
        };
        
        CGFloat defaultTabInterval = (CGFloat)ICFontPointsToPixels(self.defaultTabInterval);
        CTParagraphStyleSetting defaultTabIntervalSetting = {
            kCTParagraphStyleSpecifierDefaultTabInterval, sizeof(CGFloat), &defaultTabInterval
        };
        
        CGFloat lineHeightMultiple = (CGFloat)self.lineHeightMultiple;
        CTParagraphStyleSetting lineHeightMultipleSetting = {
            kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(CGFloat), &lineHeightMultiple
        };
        
        CGFloat maximumLineHeight = (CGFloat)ICFontPointsToPixels(self.maximumLineHeight);
        CTParagraphStyleSetting maximumLineHeightSetting = {
            kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &maximumLineHeight
        };

        CGFloat minimumLineHeight = (CGFloat)ICFontPointsToPixels(self.minimumLineHeight);
        CTParagraphStyleSetting minimumLineHeightSetting = {
            kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minimumLineHeight
        };

        CGFloat paragraphSpacing = (CGFloat)ICFontPointsToPixels(self.paragraphSpacing);
        CTParagraphStyleSetting paragraphSpacingSetting = {
            kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing
        };

        CGFloat paragraphSpacingBefore = (CGFloat)ICFontPointsToPixels(self.paragraphSpacingBefore);
        CTParagraphStyleSetting paragraphSpacingBeforeSetting = {
            kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore
        };
        
        CGFloat maximumLineSpacing = (CGFloat)ICFontPointsToPixels(self.maximumLineSpacing);
        CTParagraphStyleSetting maximumLineSpacingSetting = {
            kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &maximumLineSpacing
        };        

        CGFloat minimumLineSpacing = (CGFloat)ICFontPointsToPixels(self.minimumLineSpacing);
        CTParagraphStyleSetting minimumLineSpacingSetting = {
            kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &minimumLineSpacing
        };

        CGFloat lineSpacingAdjustment = (CGFloat)ICFontPointsToPixels(self.lineSpacingAdjustment);
        CTParagraphStyleSetting lineSpacingAdjustmentSetting = {
            kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacingAdjustment
        };
        
        const size_t settingCount = 16;
        CTParagraphStyleSetting settings[] = {
            textAlignmentSetting,
            lineBreakModeSetting,
            baseWritingDirectionSetting,
            firstLineHeadIndentSetting,
            headIndentSetting,
            tailIndentSetting,
            tabStopsSetting,
            defaultTabIntervalSetting,
            lineHeightMultipleSetting,
            maximumLineHeightSetting,
            minimumLineHeightSetting,
            paragraphSpacingSetting,
            paragraphSpacingBeforeSetting,
            maximumLineSpacingSetting,
            minimumLineSpacingSetting,
            lineSpacingAdjustmentSetting
        };
        
        CTParagraphStyleRef ctParagraphStyle = CTParagraphStyleCreate(settings, settingCount);
        [self setCTParagraphStyle:ctParagraphStyle];
        CFRelease(ctParagraphStyle);
        
        if (tabStops)
            CFRelease(tabStops);
    }
    
    return _ctParagraphStyle;
}

@end
