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
//
// Originally written by:
//
// Copyright 2011 Jeff Lamarche
//
// Redistribution and use in source and binary forms, with or without modification, are permitted
// provided that the following conditions are met:
//	1. Redistributions of source code must retain the above copyright notice, this list of
//     conditions and the following disclaimer.
//
//	2. Redistributions in binary form must reproduce the above copyright notice, this list of
//     conditions and the following disclaimer in the documentation and/or other materials
//     provided with the distribution.
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
// Then adapted for icedcoffee http://www.icedcoffee-framework.org

#import "icGLState.h"
#import "icTypes.h"


// Uniform names
#define ICUniformMVPMatrix              "u_MVPMatrix"
#define ICUniformSampler                "u_texture"
#define ICUniformSampler2               "u_texture2"
#define ICUniformAlphaTestValue         "u_alpha_value"

// Uniform names (deprecated)
#define kICUniformMVPMatrix_s			ICUniformMVPMatrix
#define kICUniformSampler_s				ICUniformSampler
#define kICUniformSampler2_s            ICUniformSampler2
#define kICUniformAlphaTestValue		ICUniformAlphaTestValue

// Vertex attribute names
#define	ICAttributeNameColor			@"a_color"
#define	ICAttributeNamePosition         @"a_position"
#define	ICAttributeNameTexCoord         @"a_texCoord"

// Vertex attribute names (deprecated)
#define	kICAttributeNameColor           ICAttributeNameColor
#define	kICAttributeNamePosition		ICAttributeNamePosition
#define	kICAttributeNameTexCoord		ICAttributeNameTexCoord


@class ICShaderValue;

/**
 @brief Defines a GLSL shader program
 
 The ICShaderProgram class represents a GLSL shader program consisting of a vertex and a fragment
 shader. Besides compiling, linking and providing access to program logs, the class also allows
 you to add attributes and manage shader uniforms conveniently.
 
 ### Creating a Shader Program ###
 
 ICShaderProgram allows you to create a shader program either from ``NSString``s containing the
 vertex and fragment shaders' source code using the
 ICShaderProgram::shaderProgramWithName:vertexShaderString:fragmentShaderString: method, or from
 files on a local drive using the
 ICShaderProgram::shaderProgramWithVertexShaderFilename:fragmentShaderFilename: method.
 
 The first method is thought to be used with shaders whose source code is embedded in your
 application's binary as a string constant while the second is designed to be used with shader
 sources stored in files shipped with your application bundle.
 
 If you choose to embed your shader's source in your application's or component's source code,
 you may use the #IC_SHADER_STRING method to stringify embedded shader sources.
 
 ### Setting up a Shader Program ###
 
 Shader programs operate on attributes defining vertex properties, e.g. position, color and
 texture coordinates. You must add those attribute names pertaining to the given vertex shader
 to make the shader program operable using the ICShaderProgram::addAttribute:index: method.
 icedcoffee defines three default attribute variable names: #ICAttributeNamePosition,
 #ICAttributeNameColor and #ICAttributeNameTexCoord.
 
 ### Linking a Shader Program ###
 
 After you have added all required attributes, you must link the program using the
 ICShaderProgram::link method. ICShaderProgram::link combines both the vertex and the fragment
 shader and makes them available for ICShaderProgram::use in OpenGL.
 
 In debug mode, ICShaderProgram::link will validate the program and output an error message
 if linking failed.
 
 ### Managing Uniforms ###
 
 Shader programs may define uniforms to pass values from your application running on the CPU to
 the shader program running on the GPU. These uniforms are defined within the vertex or fragment
 shader's source code and ICShaderProgram will automatically make them available for you once
 the shader program has been linked.
 
 Uniforms are identified by their variable name in the shader's source, which is called the uniform
 name in this class. To set a value on a given uniform, you may use the
 ICShaderProgram::setShaderValue:forUniform: method. To retrieve the current value of a
 given uniform, you may use the ICShaderProgram::shaderValueForUniform: method.
 
 In the icedcoffee framework, shader uniforms are represented by the ICShaderUniform class and
 the values you may set on them are represented by the ICShaderValue class. You may retrieve a
 full list of all ICShaderUniform objects fetched from the shader program's source using the
 ICShaderProgram::uniforms property.
 
 ### Updating Uniforms ###
 
 After linking a program or setting values on the program's uniforms, you have to call
 ICShaderProgram::updateUniforms to update the uniforms in the shaders. This will upload the
 values to the program and make them available for processing on the GPU.
 
 ### Retrieving Program Logs ###
 
 You may access the vertex and fragment shader's logs using the ICShaderProgram::vertexShaderLog
 and ICShaderProgram::fragmentShaderLog methods. You may retrieve the program log using the
 ICShaderProgram::programLog method.
 
 ### Using Shader Programs ###
 
 Shader programs may be used in OpenGL using the ICShaderProgram::use method. This method will
 automatically update the program's uniforms. Subsequent drawing calls in OpenGL will use the
 set shader program until another program is used.
 
 ### Caching and Reusing Shader Programs ###
 
 Shader programs should be cached using ICShaderCache based on a unique ``NSString`` key.
 It is good practice to keep this key identical to the ICShaderProgram::programName.
 
 Before creating and setting up a new ICShaderProgram instance, applications should check
 whether the shader program is already cached using ICShaderCache::shaderProgramForKey:.
 If the program is already cached, the program returned by the shader cache should be used.
 Otherwise, applications should create and set up the program, then set it on the cache using
 ICShaderCache::setShaderProgram:forKey:.
 */
@interface ICShaderProgram : NSObject {
@protected
	GLuint _program,
           _vertShader,
           _fragShader;
    
    NSString *_programName;
    NSMutableDictionary *_uniforms;
}

#pragma mark - Creating a Shader Program
/** @name Creating a Shader Program */

/**
 @brief Returns a new autoreleased shader program initialized with the given vertex
 and fragment shader filenames
 
 @param vShaderFilename An ``NSString`` containing a path to the vertex shader file
 @param fShaderFilename An ``NSString`` containing a path to the fragment shader file

 This method automatically compiles the shader sources. You will need to add attributes,
 link the program and update it's uniforms before it can be used.

 @sa initWithVertexShaderFilename:fragmentShaderFilename:
 */
+ (id)shaderProgramWithVertexShaderFilename:(NSString *)vShaderFilename
                     fragmentShaderFilename:(NSString *)fShaderFilename;

/**
 @brief Returns a new autoreleased shader program initialized with the given vertex
 and fragment shader strings
 
 @param programName An ``NSString`` containing a name identifying the program. This will be
 used in log output messages and may be retrieved using ICShaderProgram::programName. It is
 good practice to keep the program name identical to the key used for caching the program
 in ICShaderCache.
 @param vShaderString An ``NSString`` containing the source code of the vertex shader
 @param fShaderString An ``NSString`` containing the source code of the fragment shader
 
 This method automatically compiles the shader sources. You will need to add attributes,
 link the program and update it's uniforms before it can be used.
 
 @sa initWithName:vertexShaderString:fragmentShaderString:
 */
+ (id)shaderProgramWithName:(NSString *)programName
         vertexShaderString:(NSString *)vShaderString
       fragmentShaderString:(NSString *)fShaderString;

/**
 @brief Initializes a shader program with the given vertex and fragment shader filenames

 @param vShaderFilename An ``NSString`` containing a path to the vertex shader file
 @param fShaderFilename An ``NSString`` containing a path to the fragment shader file

 This method automatically compiles the shader sources. You will need to add attributes,
 link the program and update it's uniforms before it can be used.

 @param vShaderFilename An NSString defining a path to the vertex shader's GLSL source file
 @param fShaderFilename An NSString defining a path to the fragment shader's GLSL source file
 */
- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename
            fragmentShaderFilename:(NSString *)fShaderFilename;

/**
 @brief Initializes a shader program with the given vertex and fragment shader strings

 @param programName An ``NSString`` containing a name identifying the program. This will be
 used in log output messages and may be retrieved using ICShaderProgram::programName. It is
 good practice to keep the program name identical to the key used for caching the program
 in ICShaderCache.
 @param vShaderString An ``NSString`` containing the source code of the vertex shader
 @param fShaderString An ``NSString`` containing the source code of the fragment shader

 This method automatically compiles the shader sources. You will need to add attributes,
 link the program and update it's uniforms before it can be used.
 */
-   (id)initWithName:(NSString *)programName
  vertexShaderString:(NSString *)vShaderString
fragmentShaderString:(NSString *)fShaderString;


#pragma mark - Managing Attributes and Uniforms
/** @name Managing Attributes and Uniforms */

/**
 @brief Adds an attribute to the shader program
 
 @param attributeName An ``NSString`` defining the attribute's name
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
 @brief Updates the shader's uniform values
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


#pragma mark - Obtaining Detailed Program Information
/** @name Obtaining Detailed Program Information */

/**
 @brief A human readable program name
 */
@property (nonatomic, readonly) NSString *programName;

/**
 @brief A ``GLuint`` value identifying the program in OpenGL
 */
@property (nonatomic, readonly) const GLuint program;

@end
