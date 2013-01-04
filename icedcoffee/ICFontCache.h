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

#import <Foundation/Foundation.h>
#import "ICFont.h"

NSString *icInternalFontNameForFontNameAndSize(NSString *name, CGFloat size);
NSString *icInternalFontNameForFont(ICFont *font);

/**
 @brief Implements a font cache
 
 You rarely work with font caches directly. Instead, you should use ICFont::fontWithName:size:
 to retrieve fonts for your application. See the ICFont class for more information on how to work
 with fonts in icedcoffee.
 */
@interface ICFontCache : NSObject {
@protected
    NSMutableDictionary *_fontsByName;
}

/**
 @brief Returns the globally shared font cache
 */
+ (id)sharedFontCache;

/**
 @brief Registeres a font with the receiver
 */
- (void)registerFont:(ICFont *)font;

/**
 @brief Retrieves a font for the given name and size from the receiver
 */
- (ICFont *)fontForName:(NSString *)name size:(CGFloat)size;

@end
