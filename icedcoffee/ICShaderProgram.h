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
}

#pragma mark - Creating a Shader Program
/** @name Creating a Shader Program */

/**
 @brief Initializes a shader program with the given vertex and fragment shader filenames
 
 @param vShaderFilename An NSString defining a path to the vertex shader's GLSL source file
 @param fShaderFilename An NSString defining a path to the fragment shader's GLSL source file
 */
- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename
            fragmentShaderFilename:(NSString *)fShaderFilename;


#pragma mark - Managing Attributes and Uniforms
/** @name Managing Attributes and Uniforms */

/**
 @brief Adds an attribute to the shader program
 
 @param attributeName An NSString defining the attribute's name
 @param index A ``GLuint`` value defining the index of the attribute
 */
- (void)addAttribute:(NSString *)attributeName index:(GLuint)index;

/**
 @brief Returns a dictionary of shader uniforms defined in the shader program
 
 @return Returns an ``NSDictionary`` containing ICShaderUniform objects for ``NSString`` keys.
 The keys identify each contained uniform by its name as defined in the GLSL program's source code.
 */
@property (nonatomic, readonly) NSDictionary *uniforms;

/**
 @brief Sets the specified uniform to the given shader value
 */
- (BOOL)setShaderValue:(ICShaderValue *)shaderValue forUniform:(NSString *)uniformName;

/**
 @brief Returns the shader value for the given uniform name
 */
- (ICShaderValue *)shaderValueForUniform:(NSString *)uniformName;


#pragma mark - Linking and Using a Shader Program
/** @name Linking and Using a Shader Program */

/**
 @brief Links the shader program
 */
- (BOOL)link;

/**
 @brief Uses the shader program in OpenGL
 */
- (void)use;

/**
 @brief Updates the shader's uniforms
 */
- (void)updateUniforms;


#pragma mark - Obtaining Shader Program Logs
/** @name Obtaining Shader Program Logs */

/**
 @brief Returns the vertex shader log
 */
- (NSString *)vertexShaderLog;

/**
 @brief Returns the fragment shader log
 */
- (NSString *)fragmentShaderLog;

/**
 @brief Returns the program log
 */
- (NSString *)programLog;


#pragma mark - Obtaining OpenGL Information about the Program
/** @name Obtaining OpenGL Information about the Program */

/**
 @brief A ``GLuint`` value identifying the program in OpenGL
 */
@property (nonatomic, readonly) const GLuint program;

@end
