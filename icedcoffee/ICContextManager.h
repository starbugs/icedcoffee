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

#import "icGL.h"

@class ICRenderContext;

/**
 @brief Render context management
 
 The ICContextManager class is used to register ICRenderContext objects for OpenGL contexts.
 It enables the framework to bind arbitrary objects to given OpenGL contexts.
 */
@interface ICContextManager : NSObject {
@protected
    NSMutableDictionary *_contexts;
}

#pragma mark - Obtaining the Default Context Manager
/** @name Obtaining the Default Context Manager */

/**
 @brief Returns the default context manager
 */
+ (id)defaultContextManager;


#pragma mark - Registering and Unregistering Render Contexts
/** @name Registering and Unregistering Render Contexts */

/**
 @brief Registers the given render context for the specified OpenGL context
 */
- (void)registerRenderContext:(ICRenderContext *)renderContext
             forOpenGLContext:(IC_PLATFORM_GL_CONTEXT *)openGLContext;

/**
 @brief Unregisters the render context for the given OpenGL context
 */
- (void)unregisterRenderContextForOpenGLContext:(IC_PLATFORM_GL_CONTEXT *)openGLContext;


#pragma mark - Obtaining Render Contexts for OpenGL Contexts
/** @name Obtaining Render Contexts for OpenGL Contexts */

/**
 @brief Returns the render context for the given OpenGL context
 */
- (ICRenderContext *)renderContextForOpenGLContext:(IC_PLATFORM_GL_CONTEXT *)openGLContext;

/**
 @brief Returns the render context for the current OpenGL context
 */
- (ICRenderContext *)renderContextForCurrentOpenGLContext;

@end
