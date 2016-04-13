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

#import "ShaderTestViewController.h"

NSString *coolBackgroundShaderFSH = IC_SHADER_STRING(
#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 resolution;


void main( void )
{
    vec2 uPos = ( gl_FragCoord.xy / resolution.xy );//normalize wrt y axis
    //suPos -= vec2((resolution.x/resolution.y)/2.0, 0.0);//shift origin to center
    
    uPos.x -= 0.5;
    uPos.y -= 0.5;
    
    float vertColor = 0.0;
    //for( float i = 0.0; i < 10.0; ++i )
    {
        float t = time * ( 0.5 );
        
        uPos.x += sin( uPos.y * 1.0 + t ) * 0.5;
        uPos.y += cos( uPos.x * 1.0 + t ) * 0.5;
        
        float fTemp = abs(1.0 / uPos.x/uPos.y / 50.0);
        vertColor += fTemp;
    }
    
    vec4 color = vec4( vertColor * 2.5, vertColor * 0.5, 0.2+ vertColor * 2.0, 1.0 );
    gl_FragColor = color;
}
);


@implementation ShaderTestViewController

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    kmVec3 size;
    [[change objectForKey:NSKeyValueChangeNewKey] getValue:&size];
    ICSprite *shaderSprite = (ICSprite *)[self.scene childForTag:1];
    shaderSprite.size = size;
    [shaderSprite.shaderProgram setShaderValue:[ICShaderValue shaderValueWithVec2:kmVec2Make(self.scene.size.width, self.scene.size.height)]
                                    forUniform:@"resolution"];
}

- (void)setUpScene
{
    ICScene *scene = [ICScene scene];

    [scene addObserver:self forKeyPath:@"size" options:NSKeyValueObservingOptionNew context:nil];

    ICShaderCache *shaderCache = [ICShaderCache currentShaderCache];
    ICAnimatedShaderProgram *shader =
    [ICAnimatedShaderProgram shaderProgramWithName:@"CoolBackgroundShader"
                                vertexShaderString:[shaderCache.shaderFactory vertexShaderStringForKey:ICShaderPositionTextureColor]
                              fragmentShaderString:coolBackgroundShaderFSH];
    [shader addAttribute:ICAttributeNamePosition index:0];
    [shader addAttribute:ICAttributeNameColor index:1];
    [shader addAttribute:ICAttributeNameTexCoord index:2];
    [shader link];
    
    ICSprite *shaderSprite = [ICSprite sprite];
    shaderSprite.size = scene.size;
    shaderSprite.shaderProgram = shader;
    shaderSprite.tag = 1;
    [scene addChild:shaderSprite];
    
    [self runWithScene:scene];
}

@end
