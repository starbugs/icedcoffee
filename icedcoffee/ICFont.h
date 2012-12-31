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
#import <CoreText/CoreText.h>

/**
 @brief Represents a font
 
 You don't create ICFont objects using the ``alloc`` and ``init`` methods. Instead, you use
 ICFont::fontWithName:size: to retrieve a font from the framework.
 */
@interface ICFont : NSObject {
@protected
    CTFontRef _fontRef;
    NSString *_name;
    CGFloat _size;
}

/**
 @brief Retrieves a font object for the given font name and size
 */
+ (id)fontWithName:(NSString *)fontName size:(CGFloat)size;

/**
 @brief Retrieves a font object for the given CoreText font
 */
+ (id)fontWithCoreTextFont:(CTFontRef)ctFont;

/**
 @brief The name of the font represented by the receiver
 */
@property (nonatomic, readonly) NSString *name;

/**
 @brief The size in points of the font represented by the receiver
 */
@property (nonatomic, readonly) CGFloat size;

/**
 @brief The CoreText font used by the receiver
 */
@property (nonatomic, readonly) CTFontRef fontRef;

@end
