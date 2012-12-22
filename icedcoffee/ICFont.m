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

#import <CoreText/CoreText.h>
#import "ICFont.h"

@interface ICFont ()
- (void)setName:(NSString *)name;
- (void)setSize:(CGFloat)size;
@end

@implementation ICFont

@synthesize name = _name;
@synthesize fontRef = _fontRef;
@synthesize size = _size;

- (id)initWithName:(NSString *)fontName size:(CGFloat)size
{
    if ((self = [super init])) {
        _fontRef = CTFontCreateWithName((CFStringRef)fontName, size, nil);
        self.name = fontName;
        self.size = size;
    }
    return self;
}

- (void)dealloc
{
    CFRelease(_fontRef);
    self.name = nil;
    
    [super dealloc];
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

@end
