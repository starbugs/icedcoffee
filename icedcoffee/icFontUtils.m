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

#import "icFontUtils.h"

NSDictionary *icCreateTextAttributesWithCTAttributes(NSDictionary *ctAttrs)
{
    if (!ctAttrs)
        return nil;
    
    NSMutableDictionary *icAttrs = [[NSMutableDictionary alloc] initWithCapacity:[ctAttrs count]];
    CTFontRef ctFont = CFDictionaryGetValue((CFDictionaryRef)ctAttrs, kCTFontAttributeName);
    ICFont *font = [ICFont fontWithCoreTextFont:ctFont];
    [icAttrs setObject:font forKey:ICFontAttributeName];
    
    return icAttrs;
}

NSDictionary *icCreateCTAttributesWithTextAttributes(NSDictionary *icAttrs)
{
    if (!icAttrs)
        return nil;

    NSMutableDictionary *ctAttrs = [[NSMutableDictionary alloc] initWithCapacity:[icAttrs count]];
    ICFont *font = [icAttrs objectForKey:ICFontAttributeName];
    [ctAttrs setObject:(id)font.fontRef forKey:(NSString *)kCTFontAttributeName];
    
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

