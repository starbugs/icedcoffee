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

#import <Foundation/Foundation.h>


// Default shader key definitions

#define ICShaderPositionTextureColor			@"ShaderPositionTextureColor"
#define ICShaderPositionTextureColorAlphaTest	@"ShaderPositionTextureColorAlphaTest"
#define ICShaderPositionColor					@"ShaderPositionColor"
#define ICShaderPositionTexture                 @"ShaderPositionTexture"
#define ICShaderPositionTexture_uColor          @"ShaderPositionTexture_uColor"
#define ICShaderPositionTextureA8Color          @"ShaderPositionTextureA8Color"
#define ICShaderPicking                         @"ShaderPicking"
#define ICShaderSpriteTextureMask               @"ShaderSpriteTextureMask"


// Deprecated default shader key definitions

/**
 @deprecated Deprecated as of v0.6.7. Use #ICShaderPositionTextureColor instead.
 */
#define kICShader_PositionTextureColor			ICShaderPositionTextureColor

/**
 @deprecated Deprecated as of v0.6.7. Use #ICShaderPositionTextureColorAlphaTest instead.
 */
#define kICShader_PositionTextureColorAlphaTest	ICShaderPositionTextureColorAlphaTest

/**
 @deprecated Deprecated as of v0.6.7. Use #ICShaderPositionColor instead.
 */
#define kICShader_PositionColor					ICShaderPositionColor

/**
 @deprecated Deprecated as of v0.6.7. Use #ICShaderPositionTexture instead.
 */
#define kICShader_PositionTexture				ICShaderPositionTexture

/**
 @deprecated Deprecated as of v0.6.7. Use #ICShaderPositionTexture_uColor instead.
 */
#define kICShader_PositionTexture_uColor		ICShaderPositionTexture_uColor

/**
 @deprecated Deprecated as of v0.6.7. Use #ICShaderPositionTextureA8Color instead.
 */
#define kICShader_PositionTextureA8Color		ICShaderPositionTextureA8Color

/**
 @deprecated Deprecated as of v0.6.7. Use #ICShaderPicking instead.
 */
#define kICShader_Picking                       ICShaderPicking

/**
 @deprecated Deprecated as of v0.6.7. Use #ICShaderSpriteTextureMask instead.
 */
#define kICShader_SpriteTextureMask             ICShaderSpriteTextureMask


/**
 @brief Creates a dictionary defining how to set up a certain shader program
 
 @param defName The name of the variable used to store the ``NSDictionary`` defining the shader
 @param vshString An ``NSString`` containing the vertex shader source code
 @param fshString An ``NSString`` containing the fragment shader source code
 @param attributes An ``NSArray`` containing ``NSString`` attributes to add to the shader program
 before linking
 
 This macro creates an ``NSDictionary`` named ``defName`` and sets ``vshString``, ``fshString``
 and ``attributes`` on that dictionary with identically named keys. The dictionary may then be
 added to ICShaderFactory's internal shader definitions, so that the class can automatically
 create and set up shader programs for the given definitions when
 ICShaderFactory::createDefaultShaderPrograms or ICShaderFactory::createShaderProgramForKey:
 is called.
 */
#define IC_DEFINE_SHADER(defName, vshString, fshString, attributes) \
    NSDictionary *defName = [NSDictionary dictionaryWithObjectsAndKeys: \
                             vshString, @"vshString", \
                             fshString, @"fshString", \
                             attributes, @"attributes", nil];


@class ICShaderProgram;

/**
 @brief Creates default shader programs from built-in shader sources
 
 The ICShaderFactory class implements a class factory for generating default shader programs
 compiled from shader sources built into the icedcoffee framework's (or derivative) binary.
 It is thought for instantiating standard shader programs that are used among many different
 parts of the framework. Shaders written exclusively for a certain component should be
 instantiated in one of that component's classes instead of subclassing ICShaderFactory.
 
 Shaders are identified by a unique ``NSString`` key. The class comes with built-in shader
 sources for the following default shader keys:
 
 - #ICShaderPositionColor
 - #ICShaderPositionTexture
 - #ICShaderPositionTexture_uColor
 - #ICShaderPositionTextureColor
 - #ICShaderPositionTextureColorAlphaTest
 - #ICShaderPositionTextureA8Color
 - #ICShaderPicking
 - #ICShaderSpriteTextureMask
 
 The ICShaderCache class automatically creates, compiles and links the shaders listed above
 by calling ICShaderFactory::createDefaultShaderPrograms when first initialized.
 
 Usually there is no need to work with ICShaderFactory directly, unless you wish to subclass
 it or create a custom ICShaderCache class that requires more built-in default shaders.
 You should use ICShaderCache to retrieve and cache ICShaderProgram objects for use in your
 application.
 
 ### Subclassing ###
 
 As mentioned above, you should subclass ICShaderFactory only if you need to add more built-in
 standard shader programs, which are designed to be shared among lots of different classes of
 your application. If you need a custom shader for a certain component, you should embed and
 create it in a class of that component, then cache it using ICShaderCache.
 
 If you decide to subclass ICShaderFactory, override ICShaderFactory::init to extend the
 class' internal mutable dictionary of shader definitions. You may use the #IC_DEFINE_SHADER
 macro to create a definition telling ICShaderFactory how to set up a given shader program.
 You should then set the definition as object for a custom shader key in ICShaderFactory's
 ``_shaderDefinitions`` mutable dictionary. Shader program sources should be embedded in your
 subclass' ``.m`` file as global object variables using the #IC_SHADER_STRING macro.
 */
@interface ICShaderFactory : NSObject {
@protected
    NSMutableDictionary *_shaderDefinitions;
}

/**
 @brief Initializes a new shader factory
 */
- (id)init;

/**
 @brief Creates and returns all built-in default shader programs
 
 Returns an ``NSArray`` containing all built-in default ICShaderProgram instances. Upon return,
 the programs will be ready for use, that is, they will be compiled, linked and updated.
 */
- (NSDictionary *)createDefaultShaderPrograms;

/**
 @brief Creates and returns the shader program for the given shader key
 
 Returns an ICShaderProgram object for the given ``key``. Upon return, the program will be ready
 for use, that is, it will be compiled, linked and updated. If ``key`` is unknown, returns ``nil``.
 */
- (ICShaderProgram *)createShaderProgramForKey:(NSString *)key;

/**
 @brief Returns the vertex shader source code for the given shader key
 */
- (NSString *)vertexShaderStringForKey:(NSString *)key;

/**
 @brief Returns the fragment shader source code for the given shader key
 */
- (NSString *)fragmentShaderStringForKey:(NSString *)key;

@end
