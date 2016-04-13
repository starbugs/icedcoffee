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

#import "ICCaret.h"

@implementation ICCaret

- (id)init
{
    return [self initWithSize:kmNullVec3];
}

- (id)initWithSize:(kmVec3)size
{
    if ((self = [super init])) {
        _line = nil;
        self.size = size;
        return self;
    }
    return nil;
}

- (void)dealloc
{
    [_line release];
    [super dealloc];
}

- (void)setSize:(kmVec3)size
{
    if (!_line) {
        _line = [[ICLine2D lineWithOrigin:kmNullVec3
                                   target:kmNullVec3
                                lineWidth:1
                        antialiasStrength:0
                                    color:(icColor4B){255,255,255,255}] retain];
        [self addChild:_line];
    }
    _line.lineTarget = size;
}

@end
