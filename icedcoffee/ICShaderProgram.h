//
// Copyright 2011 Jeff Lamarche
//
// Redistribution and use in source and binary forms, with or without modification, are permitted provided
// that the following conditions are met:
//	1. Redistributions of source code must retain the above copyright notice, this list of conditions and
//		the following disclaimer.
//
//	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions
//		and the following disclaimer in the documentation and/or other materials provided with the
//		distribution.
//
//	THIS SOFTWARE IS PROVIDED BY THE FREEBSD PROJECT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE FREEBSD PROJECT
//	OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
//	OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
//	AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//
// Adapted for cocos2d http://www.cocos2d-iphone.org
// Then adapted for IcedCoffee http://www.icedcoffee-framework.org

#import "icGLState.h"
#import "icTypes.h"

enum {
	kICUniformMVPMatrix,
	kICUniformSampler,
    kICUniformSampler2,
    
	kICUniform_MAX,
};

#define kICShader_PositionTextureColor			@"ShaderPositionTextureColor"
#define kICShader_PositionTextureColorAlphaTest	@"ShaderPositionTextureColorAlphaTest"
#define kICShader_PositionColor					@"ShaderPositionColor"
#define kICShader_PositionTexture				@"ShaderPositionTexture"
#define kICShader_PositionTexture_uColor		@"ShaderPositionTexture_uColor"
#define kICShader_PositionTextureA8Color		@"ShaderPositionTextureA8Color"
#define kICShader_Picking                       @"ShaderPicking"
#define kICShader_StencilMask                   @"ShaderStencilMask"
#define kICShader_SpriteTextureMask             @"ShaderSpriteTextureMask"
#define kICShader_Rectangle                     @"ShaderRectangle"

// uniform names
#define kICUniformMVPMatrix_s			"u_MVPMatrix"
#define kICUniformSampler_s				"u_texture"
#define kICUniformSampler2_s            "u_texture2"
#define kICUniformAlphaTestValue		"u_alpha_value"

// Attribute names
#define	kICAttributeNameColor			@"a_color"
#define	kICAttributeNamePosition		@"a_position"
#define	kICAttributeNameTexCoord		@"a_texCoord"


@class ICShaderValue;

/**
 @brief Defines a GLSL vertex and fragment shader program
 */
@interface ICShaderProgram : NSObject {
@protected
	GLuint _program,
           _vertShader,
           _fragShader;
    
    NSMutableDictionary *_uniforms;
    
	//GLint _uniforms[kICUniform_MAX];    
}

@property (nonatomic, readonly, getter=program) const GLuint program;

- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename
            fragmentShaderFilename:(NSString *)fShaderFilename;

- (void)addAttribute:(NSString *)attributeName index:(GLuint)index;

- (BOOL)setShaderValue:(ICShaderValue *)shaderValue forUniform:(NSString *)uniformName;
- (ICShaderValue *)shaderValueForUniform:(NSString *)uniformName;

- (BOOL)link;

- (void)use;

- (void)updateUniforms;

- (NSString *)vertexShaderLog;

- (NSString *)fragmentShaderLog;

- (NSString *)programLog;

@end
