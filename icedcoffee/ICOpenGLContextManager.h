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
#import "ICOpenGLContext.h"

/**
 @brief Manages ICOpenGLContext objects
 
 The ICOpenGLContextManager class provides methods for registering and retrieving ICOpenGLContext
 objects based on native OpenGL contexts and threads.
 */
@interface ICOpenGLContextManager : NSObject {
@protected
    NSMutableDictionary *_contexts;
    NSMutableDictionary *_currentContextByThread;
}

/** @name Initialization */

+ (id)defaultOpenGLContextManager;

- (id)init;


/** @name Registering and Unregistering OpenGL Contexts */

- (void)registerOpenGLContext:(ICOpenGLContext *)context
       forNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext;

- (void)unregisterOpenGLContextForNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext;


/** @name Retrieving OpenGL Contexts */

- (ICOpenGLContext *)openGLContextForNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext;

- (ICOpenGLContext *)openGLContextForCurrentNativeOpenGLContext;

- (ICOpenGLContext *)currentContext;


/** @name Tracking Context Changes */

- (void)currentContextDidChange:(ICOpenGLContext *)context;

@end
