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

#import "ICTextureGlyph.h"

@implementation ICTextureGlyph

@synthesize textureAtlas = _textureAtlas;
@synthesize font = _font;
@synthesize glyph = _glyph;
@synthesize texCoords = _texCoords;
@synthesize size = _size;
@synthesize boundingRect = _boundingRect;

- (id)initWithGlyphTextureAtlas:(ICGlyphTextureAtlas *)textureAtlas
                      texCoords:(kmVec2 *)texCoords
                           size:(kmVec2)size
                   boundingRect:(CGRect)boundingRect
                        rotated:(BOOL)rotated
                          glyph:(ICGlyph)glyph
                           font:(ICFont *)font
{
    if ((self = [super init])) {
        _textureAtlas = textureAtlas;
        _texCoords = texCoords;
        _glyph = glyph;
        _font = [font retain];
        _size = size;
        _boundingRect = boundingRect;
        _rotated = rotated;
    }
    return self;
}

- (void)dealloc
{
    if (_texCoords) {
        free(_texCoords);
    }
    
    [_font release];
    
    [super dealloc];
}

@end
