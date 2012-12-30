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

#ifdef bool
#undef bool
#define bool bool
#endif

NSString *__rectangleFSH = IC_SHADER_STRING
(
    // Maddi
     
#ifdef GL_ES
    precision highp float;
#endif
     
    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;
    uniform sampler2D u_texture;
     
    uniform float u_roundness;
    uniform vec2 u_size;
     
    uniform float u_borderWidth;
    uniform vec4 u_innerColor;
    uniform vec4 u_innerColor2;
     
    uniform vec4 u_borderColor;
    uniform bool u_debug;
     
     
    float distanceGenerator(vec2 texcoord, vec2 _u_size, float _u_roundness)
    {
        vec2 aspect=normalize(_u_size);//u_aspect;
        aspect -= min(aspect.x, aspect.y);
        vec2 centroid = abs(texcoord-0.5)*2.0;
        
        centroid -= aspect;
        aspect *= vec2( 1.0/(_u_size.y/_u_size.x), 1.0/(_u_size.x/_u_size.y));
        centroid *= (1.0+(aspect));
        
        centroid = max(centroid, vec2(0,0));
        
        float dc = length(centroid-_u_roundness)+_u_roundness;
        float dr = max(centroid.x, centroid.y);
        
        float d = dc;
        
        float g = _u_roundness;
        
        bool bx = centroid.x < g;
        bool by = centroid.y < g;
        
        if(bx || by)
            d = dr;
        
        return d;
    }
     
    vec3 colorFromDist(float d, float stop, float borderWidth)
    {
        vec3 r = vec3(0.0, 0.0, 0.0);
        
        
#ifdef GL_ES
        float dd = 0.01;//fwidth(d)*0.5;
#else
        float dd = fwidth(d)*0.5;
        borderWidth *= 1.0/u_size.y;
#endif
        if(d > stop+dd)
            r.x = 1.0;
        else if(d < stop-dd)
        {
            if( d > stop-borderWidth + dd)
                r.y = 1.0;
            else
                r.y = smoothstep(stop-borderWidth - dd, stop-borderWidth+dd, d);
        }
        else
        {
            r.x = smoothstep(stop-dd, stop+dd, d);
            r.y = smoothstep(stop+dd, stop-dd, d);
        }
        
        return r;
    }
     
     
    void main()
    {
        float x = v_texCoord.x;
        float y = v_texCoord.y;
        
        float borderWidth = u_borderWidth * (1.0/u_size.y); //u_borderWidth;
        float stop = 0.5 + borderWidth;
        
        vec2 _u_size = u_size;
        float _u_roundness = u_roundness;
        vec4 _u_innerColor = mix(u_innerColor, u_innerColor2, y);
        
        vec4 _u_borderColor = u_borderColor;
        
        float s0 = 1.0-distanceGenerator(v_texCoord.xy, _u_size, _u_roundness);
        
        vec3 r0 = colorFromDist(s0, stop, u_borderWidth);
        
        gl_FragColor = _u_borderColor * r0.y;//min(r0.y,r0.z);
        gl_FragColor += _u_innerColor * r0.x;
        
        //gl_FragColor = vec4(1.0,0.0,0.0,1.0);
        //	if(u_debug)
        //	{
        //		gl_FragColor *= 0.25;
        //		gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0)*(s0);
        //	}
    }
);

#ifdef bool
#undef bool
#define bool _Bool
#endif


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
        
        float posDelta = -((size.height/2.0));
        float roundedPosDelta = posDelta; // roundf(posDelta);
        
        //float dd = roundedPosDelta - posDelta;
        
        
        [_sprite setPosition:kmVec3Make(roundedPosDelta, roundedPosDelta, 0.0)];//-((size.height/2.0)-_borderSize), -((size.height/2.0)-_borderSize), 0.0)];
        [_sprite setSize: kmVec3Make(size.width+(size.height), (size.height*2.0), 1.0)];// + (size.height*2.0), (size.height*2.0)-_borderSize, 0)];
        [_sprite setBlendFunc:(icBlendFunc){GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
        [self addChild:_sprite];
        
        // Rectangle shader
        ICShaderCache *shaderCache = [ICShaderCache currentShaderCache];
        ICShaderProgram *p = [shaderCache shaderProgramForKey:ICShaderRectangle];
        
        if (!p) {
            ICShaderFactory *shaderFactory = [shaderCache shaderFactory];
            
            NSString *positionTextureColorVSH = [shaderFactory vertexShaderStringForKey:ICShaderPositionTextureColor];
            
            p = [ICShaderProgram shaderProgramWithName:ICShaderRectangle
                                    vertexShaderString:positionTextureColorVSH
                                  fragmentShaderString:__rectangleFSH];
            
            [p addAttribute:ICAttributeNamePosition index:ICVertexAttribPosition];
            [p addAttribute:ICAttributeNameColor index:ICVertexAttribColor];
            [p addAttribute:ICAttributeNameTexCoord index:ICVertexAttribTexCoords];
            
            [p link];
            [p updateUniforms];
            
            [shaderCache setShaderProgram:p forKey:ICShaderRectangle];
        }
        
        [_sprite setShaderProgram:p];
        
        _gradientStartColor = color4BFromKmVec4(kmVec4Make(1.0, 1.0, 1.0, 1.0));
        _gradientEndColor = color4BFromKmVec4(kmVec4Make(0.7, 0.7, 0.7, 1.0));
        _borderColor = color4BFromKmVec4(kmVec4Make(0.0, 0.0, 0.0, 1.0));
    }
    return self;
}

- (void)setBorderWidth:(float)borderWidth
{
    _borderWidth = ICPointsToPixels(borderWidth);
}

- (float)borderWidth
{
    return ICPixelsToPoints(_borderWidth);
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    if (!self.isVisible)
        return;
    
    [super drawWithVisitor:visitor];
    
    float distOnePixel = 1.0;//(self.size.height);
    
    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithFloat:_borderWidth*distOnePixel] forUniform:@"u_borderWidth"];
    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithFloat:0.4] forUniform:@"u_roundness"];
    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithVec2:kmVec2Make(_sprite.size.width, _sprite.size.height)] forUniform:@"u_size"];

    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithVec4:kmVec4FromColor4B(_gradientStartColor)] forUniform:@"u_innerColor"];
    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithVec4:kmVec4FromColor4B(_gradientEndColor)] forUniform:@"u_innerColor2"];
    [_sprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithVec4:kmVec4FromColor4B(_borderColor)] forUniform:@"u_borderColor"];    
}

@end
