//
//  Copyright (C) 2013 Tobias Lensing, Marcus Tillmanns
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
#import "icAvailability.h"

@class ICTextureCache;
@class ICShaderCache;
@class ICGlyphCache;

#ifdef __IC_PLATFORM_MAC
@class NSOpenGLContext;
#define IC_NATIVE_OPENGL_CONTEXT NSOpenGLContext
#elif defined(__IC_PLATFORM_IOS)
@class EAGLContext;
#define IC_NATIVE_OPENGL_CONTEXT EAGLContext
#endif

/**
 @brief Wraps an OpenGL context for icedcoffee

 The ICOpenGLContext class wraps a native OpenGL context to serve three main purposes:
 - Provide a unified interface for working with OpenGL contexts
 - Allow users to attach caches and arbitrary objects to an OpenGL context
 - Implement internal mechanisms for efficiently updating dependent contexts, such as
   kazmath matrix stack contexts
 */
@interface ICOpenGLContext : NSObject {
@protected
    IC_NATIVE_OPENGL_CONTEXT *_nativeContext;
    ICTextureCache *_textureCache;
    ICShaderCache *_shaderCache;
    ICGlyphCache *_glyphCache;
    NSMutableDictionary *_customObjects;
    float _contentScaleFactor;
}

/** @name Initialization */

/**
 @brief Creates a new autoreleased OpenGL context object with the given native context

 @sa initWithNativeOpenGLContext:
*/
+ (id)openGLContextWithNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext;

/**
 @brief Creates a new autoreleased OpenGL context object with the given native context and
 share context
 
 @sa initWithNativeOpenGLContext:shareContext:
 */
+ (id)openGLContextWithNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext
                              shareContext:(ICOpenGLContext *)shareContext;

/**
 @brief Initializes a new OpenGL context object with the given native context
 
 @param nativeContext The native OpenGL context to be represented by the receiver
 */
- (id)initWithNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext;

/**
 @brief Initializes a new OpenGL context object with the given native context and share context

 @param nativeContext The native OpenGL context to be represented by the receiver
 @param shareContext A context to share caches and custom objects with. Specifying ``nil`` will
 initialize the receiver without shared caches or cutom objects.
 
 If ``shareContext`` is set to a non-nil value, the receiver will copy all caches and custom
 objects from the given share context upon initialization.
 */
- (id)initWithNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext
                     shareContext:(ICOpenGLContext *)shareContext;


/** @name Registration */

/**
 @brief Registers the receiver with the default ICOpenGLContextManager object
 */
- (id)registerContext;

/**
 @brief Unregisters the receiver with the default ICOpenGLContextManager object
 */
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


/** @name Managing Caches Associated with an OpenGL context */

/**
 @brief The texture cache associated with the receiver
 */
@property (nonatomic, retain) ICTextureCache *textureCache;

/**
 @brief The shader cache associated with the receiver
 */
@property (nonatomic, retain) ICShaderCache *shaderCache;

/**
 @brief The glyph cache associated with the receiver
 */
@property (nonatomic, retain) ICGlyphCache *glyphCache;

/**
 @brief The content scale factor used by the receiver
 */
@property (nonatomic, assign) float contentScaleFactor;


/** @name Managing Custom Objects Associated with an OpenGL context */

/**
 @brief A dictionary of custom objects associated with the receiver
 */
@property (nonatomic, readonly) NSDictionary *customObjects;

/**
 @brief Sets a custom object for the given key on the receiver
 */
- (void)setCustomObject:(id)object forKey:(id)key;

/**
 @brief Retrieves the custom object for the given key from the receiver
 */
- (id)customObjectForKey:(id)key;

/**
 @brief Removes the custom object for the given key from the receiver
 */
- (void)removeCustomObjectForKey:(id)key;

/**
 @brief Removes all custom objects associated with the receiver
 */
- (void)removeAllCustomObjects;


/** @name Retrieving the Native OpenGL Context */

/**
 @brief The receiver's native OpenGL context
 */
@property (nonatomic, readonly) IC_NATIVE_OPENGL_CONTEXT *nativeContext;

@end
