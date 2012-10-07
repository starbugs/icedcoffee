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

#import "ICShaderFactory.h"
#import "ICShaderProgram.h"
#import "icMacros.h"

//
// Built-in shader programs (adapted from cocos2d-iphone.org)
//

// ICShaderPositionTextureColor

NSString *__positionTextureColorVSH = IC_SHADER_STRING
(
    attribute vec4 a_position;
    attribute vec2 a_texCoord;
    attribute vec4 a_color;

    uniform mat4 u_MVPMatrix;

    #ifdef GL_ES
    varying lowp vec4 v_fragmentColor;
    varying mediump vec2 v_texCoord;
    #else
    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;
    #endif

    void main()
    {
        gl_Position = u_MVPMatrix * a_position;
        v_fragmentColor = a_color;
        v_texCoord = a_texCoord;
    }
);

NSString *__positionTextureColorFSH = IC_SHADER_STRING
(
    #ifdef GL_ES
    precision lowp float;
    #endif

    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;
    uniform sampler2D u_texture;

    void main()
    {
        gl_FragColor = v_fragmentColor * texture2D(u_texture, v_texCoord);
    }
);


// ICShaderPositionTextureColorAlphaTest

NSString *__positionTextureColorAlphaTestVSH = IC_SHADER_STRING
(
    attribute vec4 a_position;
    attribute vec2 a_texCoord;
    attribute vec4 a_color;

    uniform	mat4 u_MVPMatrix;

    #ifdef GL_ES
    varying lowp vec4 v_fragmentColor;
    varying mediump vec2 v_texCoord;
    #else
    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;
    #endif

    void main()
    {
        gl_Position = u_MVPMatrix * a_position;
        v_fragmentColor = a_color;
        v_texCoord = a_texCoord;
    }
);

NSString *__positionTextureColorAlphaTestFSH = IC_SHADER_STRING
(
    #ifdef GL_ES
    precision lowp float;
    #endif

    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;
    uniform sampler2D u_texture;

    void main()
    {
        gl_FragColor = vec4(v_fragmentColor.rgb,									// RGB from uniform
                            v_fragmentColor.a * texture2D(u_texture, v_texCoord).a	// A from texture & uniform
                            );
    }
);


// ICShaderPositionColor

NSString *__positionColorVSH = IC_SHADER_STRING
(
    attribute vec4 a_position;
    attribute vec4 a_color;

    uniform mat4 u_MVPMatrix;

    #ifdef GL_ES
    varying lowp vec4 v_fragmentColor;
    #else
    varying vec4 v_fragmentColor;
    #endif

    void main()
    {
        gl_Position = u_MVPMatrix * a_position;
        v_fragmentColor = a_color;
    }
);

NSString *__positionColorFSH = IC_SHADER_STRING
(
    #ifdef GL_ES
    precision lowp float;
    #endif

    varying vec4 v_fragmentColor;

    void main()
    {
        gl_FragColor = v_fragmentColor;
    }
);


// ICShaderPositionTexture

NSString *__positionTextureVSH = IC_SHADER_STRING
(
    attribute vec4 a_position;
    attribute vec2 a_texCoord;

    uniform mat4 u_MVPMatrix;

    #ifdef GL_ES
    varying mediump vec2 v_texCoord;
    #else
    varying vec2 v_texCoord;
    #endif

    void main()
    {
        gl_Position = u_MVPMatrix * a_position;
        v_texCoord = a_texCoord;
    }
);

NSString *__positionTextureFSH = IC_SHADER_STRING
(
    #ifdef GL_ES
    precision lowp float;
    #endif

    varying vec2 v_texCoord;
    uniform sampler2D u_texture;

    void main()
    {
        gl_FragColor = texture2D(u_texture, v_texCoord);
    }
);


// ICShaderPositionTexture_uColor


// ICShaderPositionTextureA8Color

NSString *__positionTextureA8ColorVSH = IC_SHADER_STRING
(
    attribute vec4 a_position;
    attribute vec2 a_texCoord;
    attribute vec4 a_color;

    uniform		mat4 u_MVPMatrix;

    #ifdef GL_ES
    varying lowp vec4 v_fragmentColor;
    varying mediump vec2 v_texCoord;
    #else
    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;
    #endif

    void main()
    {
        gl_Position = u_MVPMatrix * a_position;
        v_fragmentColor = a_color;
        v_texCoord = a_texCoord;
    }
);

NSString *__positionTextureA8ColorFSH = IC_SHADER_STRING
(
    #ifdef GL_ES
    precision lowp float;
    #endif

    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;
    uniform sampler2D u_texture;

    void main()
    {
        gl_FragColor = vec4(v_fragmentColor.rgb,										// RGB from uniform
                            v_fragmentColor.a * texture2D(u_texture, v_texCoord).a		// A from texture & uniform
                            );
    }
);


// ICShaderPicking

NSString *__pickingFSH = IC_SHADER_STRING
(
    #ifdef GL_ES
    precision highp float;
    #endif

    uniform vec4 u_pickColor;

    void main()
    {
        gl_FragColor = u_pickColor;
    }
);


// ICShaderSpriteTextureMask

NSString *__spriteTextureMaskFSH = IC_SHADER_STRING
(
#ifdef GL_ES
    precision lowp float;
#endif

    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;
    uniform sampler2D u_texture;
    uniform sampler2D u_texture2;

    void main()
    {
        vec4 tex1 = texture2D(u_texture, v_texCoord);
        vec4 tex2 = texture2D(u_texture2, v_texCoord);
        tex1.a *= tex2.a;
        gl_FragColor = v_fragmentColor * tex1;
    }
);



@interface ICShaderFactory (Private)
- (ICShaderProgram *)setupShaderProgramWithName:(NSString *)name
                             vertexShaderString:(NSString *)vshString
                           fragmentShaderString:(NSString *)fshString
                                     attributes:(NSArray *)attributes;
@end


@implementation ICShaderFactory

- (id)init
{
    if ((self = [super init])) {
        NSArray *positionTextureColorAttributes = [NSArray arrayWithObjects:
                                                   ICAttributeNamePosition,
                                                   ICAttributeNameColor,
                                                   ICAttributeNameTexCoord, nil];
        NSArray *positionColorAttributes        = [NSArray arrayWithObjects:
                                                   ICAttributeNamePosition,
                                                   ICAttributeNameColor, nil];
        NSArray *positionTextureAttributes      = [NSArray arrayWithObjects:
                                                   ICAttributeNamePosition,
                                                   ICAttributeNameTexCoord, nil];
        
        IC_DEFINE_SHADER(positionTextureColorDef,
                         __positionTextureColorVSH,
                         __positionTextureColorFSH,
                         positionTextureColorAttributes);
        
        IC_DEFINE_SHADER(positionTextureColorAlphaTestDef,
                         __positionTextureColorAlphaTestVSH,
                         __positionTextureColorAlphaTestFSH,
                         positionTextureColorAttributes);
        
        IC_DEFINE_SHADER(positionTextureA8ColorDef,
                         __positionTextureA8ColorVSH,
                         __positionTextureA8ColorFSH,
                         positionTextureColorAttributes);
        
        IC_DEFINE_SHADER(positionTextureDef,
                         __positionTextureVSH,
                         __positionTextureFSH,
                         positionTextureAttributes);
        
        IC_DEFINE_SHADER(positionColorDef,
                         __positionColorVSH,
                         __positionColorFSH,
                         positionColorAttributes);
        
        IC_DEFINE_SHADER(pickingDef,
                         __positionTextureColorVSH,
                         __pickingFSH,
                         positionTextureColorAttributes);
        
        IC_DEFINE_SHADER(spriteTextureMaskDef,
                         __positionTextureColorVSH,
                         __spriteTextureMaskFSH,
                         positionTextureColorAttributes);
        
        _shaderDefinitions = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              positionTextureColorDef, ICShaderPositionTextureColor,
                              positionTextureA8ColorDef, ICShaderPositionTextureA8Color,
                              positionTextureColorAlphaTestDef, ICShaderPositionTextureColorAlphaTest,
                              positionTextureDef, ICShaderPositionTexture,
                              positionColorDef, ICShaderPositionColor,
                              pickingDef, ICShaderPicking,
                              spriteTextureMaskDef, ICShaderSpriteTextureMask,
                              nil];
    }
    return self;
}

- (ICShaderProgram *)setupShaderProgramWithName:(NSString *)name
                             vertexShaderString:(NSString *)vshString
                           fragmentShaderString:(NSString *)fshString
                                     attributes:(NSArray *)attributes
{
    ICShaderProgram *program = [ICShaderProgram shaderProgramWithName:name
                                                   vertexShaderString:vshString
                                                 fragmentShaderString:fshString];
    uint i=0;
    for (NSString *attribute in attributes) {
        [program addAttribute:attribute index:i++];
    }
    [program link];
    [program updateUniforms];
    return program;
}

- (NSDictionary *)createDefaultShaderPrograms
{
    NSMutableDictionary *programs = [NSMutableDictionary dictionaryWithCapacity:[_shaderDefinitions count]];
    for (NSString *key in _shaderDefinitions) {
        ICShaderProgram *program = [self createShaderProgramForKey:key];
        [programs setObject:program forKey:key];
    }
    return programs;
}

- (ICShaderProgram *)createShaderProgramForKey:(NSString *)key
{
    NSDictionary *shaderDef = [_shaderDefinitions objectForKey:key];
    if (shaderDef) {
        return [self setupShaderProgramWithName:key
                             vertexShaderString:[shaderDef objectForKey:@"vshString"]
                           fragmentShaderString:[shaderDef objectForKey:@"fshString"]
                                     attributes:[shaderDef objectForKey:@"attributes"]];
    }
    return nil;
}

- (NSString *)vertexShaderStringForKey:(NSString *)key
{
    return [[_shaderDefinitions objectForKey:key] objectForKey:@"vshString"];
}

- (NSString *)fragmentShaderStringForKey:(NSString *)key
{
    return [[_shaderDefinitions objectForKey:key] objectForKey:@"fshString"];
}

@end
