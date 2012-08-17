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

#import "ICLabel.h"
#import "ICSprite.h"
#import "ICTexture2D.h"
#import "ICShaderCache.h"
#import "ICShaderProgram.h"

// FIXME: ICLabel support for 32-bit textures

@implementation ICLabel

@synthesize text = _text;
@synthesize fontName = _fontName;
@synthesize fontSize = _fontSize;
@synthesize color = _color;
@synthesize autoresizesToTextSize = _autoresizesToTextSize;

+ (id)labelWithText:(NSString *)text fontName:(NSString *)fontName fontSize:(CGFloat)fontSize
{
    return [[[[self class] alloc] initWithText:text fontName:fontName fontSize:fontSize] autorelease];
}

- (id)initWithText:(NSString *)text fontName:(NSString *)fontName fontSize:(CGFloat)fontSize
{
    if ((self = [super init])) {
        _autoresizesToTextSize = YES;
        
        _sprite = [[ICSprite alloc] init];
        _sprite.name = @"Label sprite";
        [_sprite setBlendFunc:(icBlendFunc){GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
        [self addChild:_sprite];
        
        self.fontName = fontName;
        self.fontSize = fontSize;
        self.text = text;
    }
    return self;
}

- (void)dealloc
{
    [_sprite release];
    [super dealloc];
}

- (void)setSpriteTexture:(ICTexture2D *)texture
{
    [_sprite setTexture:texture];
    [_sprite setShaderProgram:[[ICShaderCache currentShaderCache] shaderProgramForKey:kICShader_PositionTextureA8Color]];    
}

- (void)setText:(NSString *)text
{
    [_text release];
    _text = [text copy];
    
    ICTexture2D *texture = [[ICTexture2D alloc] initWithString:_text fontName:self.fontName fontSize:self.fontSize];
    [self setSpriteTexture:texture];
    [texture release];
    
    if (_autoresizesToTextSize)
        self.size = _sprite.size;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ICLabelTextDidChange object:self];
    
    [self setNeedsDisplay];
}

- (void)setFontName:(NSString *)fontName
{
    [_fontName release];
    _fontName = [fontName copy];

    [[NSNotificationCenter defaultCenter] postNotificationName:ICLabelFontDidChange object:self];
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ICLabelFontDidChange object:self];    
}

- (icColor4B)color
{
    return _sprite.color;
}

- (void)setColor:(icColor4B)color
{
    [_sprite setColor:color];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    [_sprite setUserInteractionEnabled:userInteractionEnabled];
}

@end
