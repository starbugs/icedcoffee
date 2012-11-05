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

@class ICTextureCache;
@class ICShaderCache;

/**
 @brief A class for binding arbitrary objects to a native OpenGL context in icedcoffee
 
 The ICRenderContext class allows for attaching arbitrary objects to a native OpenGL context
 object. This is useful for "extending" OpenGL contexts without forcing developers to change
 existing code which is based on native context objects such as ``EAGLContext`` on iOS or
 ``NSOpenGLContext`` on Mac OS X.
 
 Render contexts are primarily designed to provide an ICTextureCache and an ICShaderCache
 object for each OpenGL context. However, they can also be used to hold custom objects
 for a given OpenGL context.
 
 Render contexts are managed by the ICContextManager class. In a standard icedcoffee setup,
 ICHostViewController creates and registers a render context for the OpenGL context of its
 associated ICHostViewController::view. Also, each auxiliary OpenGL context created by
 the framework is equipped with a render context automatically.
 
 If you wish to use icedcoffee with an OpenGL context that was not created by the framework,
 you must create and register a render context for that OpenGL context, then set up the required
 caches manually.
 */
@interface ICRenderContext : NSObject {
@protected
    ICTextureCache *_textureCache;
    ICShaderCache *_shaderCache;
    NSMutableDictionary *_customObjects;
}


#pragma mark - Obtaining the Current Render Context
/** @name Obtaining the Current Render Context */

/**
 @brief Returns the render context for the current OpenGL context
 */
+ (id)currentRenderContext;


#pragma mark - Creating a Render Context
/** @name Creating a Render Context */

/**
 @brief Initializes the receiver
 */
- (id)init;

/**
 @brief Initializes the receiver with the texture and shader caches from the given share context
 */
- (id)initWithShareContext:(ICRenderContext *)shareContext;


#pragma mark - Retrieving Caches
/** @name Retrieving Caches */

/**
 @brief The receiver's texture cache
 */
@property (nonatomic, retain) ICTextureCache *textureCache;

/**
 @brief The receiver's shader cache
 */
@property (nonatomic, retain) ICShaderCache *shaderCache;


#pragma mark - Manging Custom Objects
/** @name Managing Custom Objects */

/**
 @brief Sets a custom object for the given key
 */
- (void)setCustomObject:(id)object forKey:(id)key;

/**
 @brief Returns the custom object set for the given key
 */
- (id)customObjectForKey:(id)key;

/**
 @brief Removes the custom object set for the given key
 */
- (void)removeCustomObjectForKey:(id)key;

/**
 @brief Removes all custom objects from the receiver
 */
- (void)removeAllCustomObjects;

@end
