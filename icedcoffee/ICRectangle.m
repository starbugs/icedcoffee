//
//  ICRectangle.m
//  icedcoffee-mac
//
//  Created by Marcus Tillmanns on 6/16/12.
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

- (id)initWithSize:(CGSize)size
{
    if ((self = [super initWithSize:size])) {
        _sprite = [ICSprite sprite];
        
        _borderWidth = 1; // pixel
        
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
    }
    return self;
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

    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithVec4:kmVec4Make(1.0, 1.0, 1.0, 1.0)] forUniform:@"u_innerColor"];
    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithVec4:kmVec4Make(0.7, 0.7, 0.7, 1.0)] forUniform:@"u_innerColor2"];
    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithVec4:kmVec4Make(0.0, 0.0, 0.0, 1.0)] forUniform:@"u_borderColor"];
}

@end
