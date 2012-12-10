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
#import "icMacros.h"

@class NSOpenGLContext;
@class EAGLContext;
@class ICTextureCache;
@class ICShaderCache;

#ifdef __IC_PLATFORM_MAC
#define IC_NATIVE_OPENGL_CONTEXT NSOpenGLContext
#elif defined(__IC_PLATFORM_IOS)
#define IC_NATIVE_OPENGL_CONTEXT EAGLContext
#endif

/**
 @brief Wraps an OpenGL context for icedcoffee

 ICOpenGLContext is an abstract base class wrapping a native OpenGL context object.
 
 The class serves three main purposes:
 - Provide a unified interface for working with OpenGL contexts
 - Allow users to attach caches and arbitrary objects to an OpenGL context
 - Implement internal mechanisms for efficiently updating dependent contexts, such as
   kazmath matrix stack contexts

 You will almost always work with ICPlatformOpenGLContext rather than using ICOpenGLContext
 directly. ICPlatformOpenGLContext provides the OpenGL context implementation suitable
 for the target platform of your application.
 */
@interface ICOpenGLContext : NSObject {
@protected
    IC_NATIVE_OPENGL_CONTEXT *_nativeContext;
    ICTextureCache *_textureCache;
    ICShaderCache *_shaderCache;
    NSMutableDictionary *_customObjects;
    float _contentScaleFactor;
}

/** @name Initialization */

/**
 @brief Creates a new autoreleased OpenGL context object with the given native context
 */
+ (id)openGLContextWithNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext;

/**
 @brief Creates a new autoreleased OpenGL context object with the given native context and
 share context
 */
+ (id)openGLContextWithNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext
                              shareContext:(ICOpenGLContext *)shareContext;

/**
 @brief Initializes a new OpenGL context object with the given native context
 */
- (id)initWithNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext;

/**
 @brief Initializes a new OpenGL context object with the given native context and share context
 */
- (id)initWithNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext
                     shareContext:(ICOpenGLContext *)shareContext;


/** @name Registration */

- (id)registerContext;

- (id)unregisterContext;


/** @name Retrieving and Setting the Current OpenGL Context */

/**
 @brief Returns the current OpenGL context
 */
+ (ICOpenGLContext *)currentContext;

/**
 @brief Makes the receiver the current context
 */
- (void)makeCurrentContext;

/**
 @brief Clears the current OpenGL context
 */
+ (void)clearCurrentContext;


/** @name Managing Objects Associated with an OpenGL context */

/**
 @brief The texture cache associated with the receiver
 */
@property (nonatomic, retain) ICTextureCache *textureCache;

/**
 @brief The shader cache associated with the receiver
 */
@property (nonatomic, retain) ICShaderCache *shaderCache;

@property (nonatomic, assign) float contentScaleFactor;

@property (nonatomic, readonly) NSDictionary *customObjects;

- (void)setCustomObject:(id)object forKey:(id)key;

- (id)customObjectForKey:(id)key;

- (void)removeCustomObjectForKey:(id)key;

- (void)removeAllCustomObjects;


/** @name Retrieving the Native OpenGL Context */

/**
 @brief The receiver's native OpenGL context
 */
@property (nonatomic, readonly) IC_NATIVE_OPENGL_CONTEXT *nativeContext;

@end
