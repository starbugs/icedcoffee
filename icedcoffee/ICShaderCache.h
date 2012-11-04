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
//  Inspired by cocos2d-iphone.org

#import <Foundation/Foundation.h>
#import "ICShaderFactory.h"

@class ICShaderProgram;

/** @brief Shader caching and management
 
 <h3>Overview</h3>
 
 The ICShaderCache class provides caching and management for ICShaderProgram objects.
 In the icedcoffee framework, there is one default shader cache for each OpenGL context.
 The shader cache for the current OpenGL context may be retrieved using the
 ICShaderCache::currentShaderCache method.
 
 On initialization, ICShaderCache loads a couple of standard shader programs which are
 required by different core classes of the framework. These standard programs are defined
 in and produced by the ICShaderFactory class. The shader programs for the following keys
 will be created and set up automatically:
 
 - #ICShaderPositionColor
 - #ICShaderPositionTexture
 - #ICShaderPositionTexture_uColor
 - #ICShaderPositionTextureColor
 - #ICShaderPositionTextureColorAlphaTest
 - #ICShaderPositionTextureA8Color
 - #ICShaderPicking
 - #ICShaderSpriteTextureMask
 
 All other shader programs should be managed by the component that requires them.
 
 Shader programs are cached by a unique key, which in icedcoffee usually is an ``NSString``
 constant naming the respective shader program. It is good practice to create a preprocessor
 define for these string constants in the header file of the class that defines the program
 (confer to ICRectangle for example).
 
 Shader programs may be set on the shader cache using ICShaderCache::setShaderProgram:forKey:.
 A cached shader program may be retrieved using ICShaderCache::shaderProgramForKey:.
 
 Shader programs set on ICShaderCache are cached until the cache is released or purged using
 ICShaderCache::purgeCurrentShaderCache.
 
 <h3>Subclassing</h3>
 
 While usually subclassing is not required, it might make sense to subclass ICShaderCache
 in order to implement custom initialization or shader management. If you plan to implement
 custom initialization, override the init method. If you plan to customize shader program
 management, override ICShaderCache::setShaderProgram:forKey: and
 ICShaderCache::shaderProgramForKey:. If you plan to add shared standard shader programs
 embedded in your application's source code, please see the ICShaderFactory class reference.
 */
@interface ICShaderCache : NSObject {
@private
    NSMutableDictionary *_programs;
    ICShaderFactory *_shaderFactory;
}

#pragma mark - Obtaining/Creating a Shader Cache
/** @name Obtaining/Creating a Shader Cache */

/**
 @brief Returns the shader cache associated with the current OpenGL context
 */
+ (id)currentShaderCache;

/**
 @brief Initializes the ICShaderCache class and loads default shaders
 
 This method initializes the ICShaderCache class and loads a number of default shaders.
 The following shader keys may be used to retrieve default programs:
 
 - #ICShaderPositionColor
 - #ICShaderPositionTexture
 - #ICShaderPositionTexture_uColor
 - #ICShaderPositionTextureColor
 - #ICShaderPositionTextureColorAlphaTest
 - #ICShaderPositionTextureA8Color
 - #ICShaderPicking
 - #ICShaderSpriteTextureMask
 */
- (id)init;


#pragma mark - Managing Shader Programs
/** @name Managing Shader Programs */

/**
 @brief Sets a shader program for a given key
 
 Sets an ICShaderProgram instance for a given key, which can later be retrieved using
 the shaderProgramForKey: method. NSMutableDictionary is used for internal storage and
 hashing.
 
 @param program An ICShaderProgram instance representing the shader program to set
 @param key An arbitrary key identifying the shader program for later retrieval
 
 @remarks It is recommended to use NSString keys. The default keys available in IcedCoffee
 are defined in ICShaderProgram.h.
 */
- (void)setShaderProgram:(ICShaderProgram *)program forKey:(id)key;

/**
 @brief Returns the shader for a given key
 
 @return Returns an ICShaderProgram instance deposited for the given key, or nil, if for
 the given key no shader program is found.
 */
- (ICShaderProgram *)shaderProgramForKey:(id)key;

/**
 @brief Purges the internal shader cache
 */
+ (void)purgeCurrentShaderCache;

- (void)removeAllShaderPrograms;

- (void)removeUnusedShaderPrograms;

#pragma mark - Accessing the Shader Factory

@property (nonatomic, readonly) ICShaderFactory *shaderFactory;


@end
