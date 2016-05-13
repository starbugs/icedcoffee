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

#import "icFontUtils.h"
#import "icTypes.h"
#import "ICParagraphStyle.h"

NSDictionary *icCreateTextAttributesWithCTAttributes(NSDictionary *ctAttrs)
{
    if (!ctAttrs)
        return nil;
    
    NSMutableDictionary *icAttrs = [[NSMutableDictionary alloc] initWithCapacity:[ctAttrs count]];
    
    
    // Font
    
    CTFontRef ctFont = CFDictionaryGetValue((CFDictionaryRef)ctAttrs, kCTFontAttributeName);
    if (ctFont) {
        ICFont *font = [ICFont fontWithCoreTextFont:ctFont];
        [icAttrs setObject:font forKey:ICFontAttributeName];
    }
    
    
    // Foreground color
    
    CGColorRef cgForegroundColor = (CGColorRef)CFDictionaryGetValue((CFDictionaryRef)ctAttrs,
                                                                    kCTForegroundColorAttributeName);
    if (cgForegroundColor) {
        const CGFloat *components = CGColorGetComponents(cgForegroundColor);
        icColor4B foregroundColor = (icColor4B){
            (GLbyte)(components[0]*255.0f),
            (GLbyte)(components[1]*255.0f),
            (GLbyte)(components[2]*255.0f),
            (GLbyte)(components[3]*255.0f),
        };
        [icAttrs setObject:[NSValue valueWithBytes:&foregroundColor objCType:@encode(icColor4B)]
                    forKey:ICForegroundColorAttributeName];
    }
    
    
    // Tracking
    
    NSNumber *trackingNumber = (NSNumber *)CFDictionaryGetValue((CFDictionaryRef)ctAttrs,
                                                                kCTKernAttributeName);
    if (trackingNumber) {
        [icAttrs setObject:trackingNumber forKey:ICTrackingAttributeName];
    }
    
    
    // Superscript
    
    NSNumber *superscriptNumber = (NSNumber *)CFDictionaryGetValue((CFDictionaryRef)ctAttrs,
                                                                   kCTSuperscriptAttributeName);
    if (superscriptNumber) {
        [icAttrs setObject:superscriptNumber forKey:ICSuperscriptAttributeName];
    }
    
    
    // Ligature
    
    NSNumber *ligatureNumber = (NSNumber *)CFDictionaryGetValue((CFDictionaryRef)ctAttrs,
                                                                kCTLigatureAttributeName);
    if (ligatureNumber) {
        [icAttrs setObject:ligatureNumber forKey:ICLigatureAttributeName];
    }
    
    
    // Paragraph style
    
    CTParagraphStyleRef ctParagraphStyle = (CTParagraphStyleRef)CFDictionaryGetValue(
        (CFDictionaryRef)ctAttrs, kCTParagraphStyleAttributeName
    );
    if (ctParagraphStyle) {
        ICParagraphStyle *paragraphStyle = [[ICParagraphStyle alloc]
                                            initWithCoreTextParagraphStyle:ctParagraphStyle];
        [icAttrs setObject:paragraphStyle forKey:ICParagraphStyleAttributeName];
        [paragraphStyle release];
    }    
    
    return icAttrs;
}

NSDictionary *icCreateCTAttributesWithTextAttributes(NSDictionary *icAttrs)
{
    if (!icAttrs)
        return nil;

    NSMutableDictionary *ctAttrs = [[NSMutableDictionary alloc] initWithCapacity:[icAttrs count]];
    
    
    // Font
    
    ICFont *font = [icAttrs objectForKey:ICFontAttributeName];
    if (font) {
        [ctAttrs setObject:(id)font.fontRef forKey:(NSString *)kCTFontAttributeName];
    }
    
    
    // Foreground color
    
    icColor4B foregroundColor;
    NSValue *foregroundColorValue = [icAttrs objectForKey:ICForegroundColorAttributeName];
    if (foregroundColorValue) {
        [foregroundColorValue getValue:&foregroundColor];
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[4];
        components[0] = (CGFloat)foregroundColor.r/255.0f;
        components[1] = (CGFloat)foregroundColor.g/255.0f;
        components[2] = (CGFloat)foregroundColor.b/255.0f;
        components[3] = (CGFloat)foregroundColor.a/255.0f;
        CGColorRef cgForegroundColor = CGColorCreate(colorSpace, components);
        [ctAttrs setObject:(id)cgForegroundColor forKey:(NSString *)kCTForegroundColorAttributeName];
        CFRelease(cgForegroundColor);
        CFRelease(colorSpace);
    }
    
    
    // Tracking
    
    NSNumber *trackingNumber = [icAttrs objectForKey:ICTrackingAttributeName];
    if (trackingNumber) {
        [ctAttrs setObject:(id)trackingNumber forKey:(NSString *)kCTKernAttributeName];
    }
    
    
    // Superscript
    
    NSNumber *superscriptNumber = [icAttrs objectForKey:ICSuperscriptAttributeName];
    if (superscriptNumber) {
        [ctAttrs setObject:(id)superscriptNumber forKey:(NSString *)kCTSuperscriptAttributeName];
    }
    
    
    // Ligature
    
    NSNumber *ligatureNumber = [icAttrs objectForKey:ICLigatureAttributeName];
    if (ligatureNumber) {
        [ctAttrs setObject:(id)ligatureNumber forKey:(NSString *)kCTLigatureAttributeName];
    }
    
    
    // Paragraph style
    
    ICParagraphStyle *paragraphStyle = [icAttrs objectForKey:ICParagraphStyleAttributeName];
    if (paragraphStyle) {
        [ctAttrs setObject:(id)[paragraphStyle ctParagraphStyle]
                    forKey:(NSString *)kCTParagraphStyleAttributeName];
    }
    
    
    return ctAttrs;
}

NSAttributedString *icCreateAttributedStringWithCTAttributedString(NSAttributedString *ctAttString)
{
    __block NSMutableAttributedString *icAttString;
    icAttString = [[NSMutableAttributedString alloc] initWithString:[ctAttString string]];

    [ctAttString enumerateAttributesInRange:NSMakeRange(0, [ctAttString length])
                                    options:0
                                 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSDictionary *icAttrs = icCreateTextAttributesWithCTAttributes(attrs);
        [icAttString addAttributes:icAttrs range:range];
        [icAttrs release];
    }];
    
    return icAttString;
}

NSAttributedString *icCreateCTAttributedStringWithAttributedString(NSAttributedString *icAttString)
{
    __block NSMutableAttributedString *ctAttString;
    ctAttString = [[NSMutableAttributedString alloc] initWithString:[icAttString string]];
    
    [icAttString enumerateAttributesInRange:NSMakeRange(0, [icAttString length])
                                    options:0
                                 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSDictionary *ctAttrs = icCreateCTAttributesWithTextAttributes(attrs);
        [ctAttString addAttributes:ctAttrs range:range];
        [ctAttrs release];
    }];
    
    return ctAttString;
}

