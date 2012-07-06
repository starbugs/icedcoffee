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

#import "ICRectangle.h"

#import "ICSprite.h"
#import "ICTexture2D.h"
#import "ICShaderCache.h"
#import "ICShaderProgram.h"
#import "ICShaderValue.h"
#import "icTypes.h"

@implementation ICRectangle

@synthesize borderWidth = _borderWidth;
@synthesize borderColor = _borderColor;
@synthesize gradientStartColor = _gradientStartColor;
@synthesize gradientEndColor = _gradientEndColor;

- (id)initWithSize:(CGSize)size
{
    if ((self = [super initWithSize:size])) {
        _sprite = [ICSprite sprite];
        _sprite.name = @"Rectangle sprite";
        
        self.borderWidth = 1; // points
        
        [_sprite setPosition:kmVec3Make(-(size.height/2.0), -size.height/2.0, 0.0)];//-((size.height/2.0)-_borderSize), -((size.height/2.0)-_borderSize), 0.0)];
        [_sprite setSize: kmVec3Make(size.width+(size.height), size.height*2.0, 1.0)];// + (size.height*2.0), (size.height*2.0)-_borderSize, 0)];
        [_sprite setBlendFunc:(icBlendFunc){GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
        [self addChild:_sprite];
        
        // Rectangle shader
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *positionTextureColorVSH = [resourcePath stringByAppendingPathComponent:@"PositionTextureColor.vsh"];        
        NSString *rectangleFSH = [resourcePath stringByAppendingPathComponent:@"Rectangle.fsh"];        
        ICShaderProgram *p = [[ICShaderProgram alloc] initWithVertexShaderFilename:positionTextureColorVSH
                                                            fragmentShaderFilename:rectangleFSH];
        
        [p addAttribute:kICAttributeNamePosition index:kICVertexAttrib_Position];
        [p addAttribute:kICAttributeNameColor index:kICVertexAttrib_Color];
        [p addAttribute:kICAttributeNameTexCoord index:kICVertexAttrib_TexCoords];
        
        [p link];
        [p updateUniforms];
        
        [[ICShaderCache currentShaderCache] setShaderProgram:p forKey:kICShader_Rectangle];
        [p release];        
        
        [_sprite setShaderProgram:[[ICShaderCache currentShaderCache] shaderProgramForKey:kICShader_Rectangle]]; 
        
        _gradientStartColor = colorFromKmVec4(kmVec4Make(1.0, 1.0, 1.0, 1.0));
        _gradientEndColor = colorFromKmVec4(kmVec4Make(0.7, 0.7, 0.7, 1.0));
        _borderColor = colorFromKmVec4(kmVec4Make(0.0, 0.0, 0.0, 0.5));
    }
    return self;
}

- (void)setBorderWidth:(float)borderWidth
{
    _borderWidth = borderWidth * IC_CONTENT_SCALE_FACTOR();
}

- (float)borderWidth
{
    return _borderWidth / IC_CONTENT_SCALE_FACTOR();
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    if (!self.isVisible)
        return;
    
    [super drawWithVisitor:visitor];
    
    float distOnePixel = 1.0/(self.size.y);
    
    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithFloat:_borderWidth*distOnePixel] forUniform:@"u_borderWidth"];
    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithFloat:0.4] forUniform:@"u_roundness"];
    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithVec2:kmVec2Make(_sprite.size.x, _sprite.size.y)] forUniform:@"u_size"];

    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithVec4:kmVec4FromColor(_gradientStartColor)] forUniform:@"u_innerColor"];
    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithVec4:kmVec4FromColor(_gradientEndColor)] forUniform:@"u_innerColor2"];
    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithVec4:kmVec4FromColor(_borderColor)] forUniform:@"u_borderColor"];    
}

@end
