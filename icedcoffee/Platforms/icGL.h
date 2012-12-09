/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#pragma once

//
// Common layer for OpenGL stuff
//

#import <Availability.h>

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>
#import "iOS/ICGLView.h"

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <Cocoa/Cocoa.h>	// needed for NSOpenGLView
#endif

#import "../icMacros.h"
#import "../icConfig.h"
#import "../../3rd-party/kazmath/kazmath/GL/matrix.h"

/**
 @addtogroup platform-macros Platform Macros
 @{
 */

#ifdef __IC_PLATFORM_MAC
#define IC_PLATFORM_GL_CONTEXT NSOpenGLContext
#elif defined(__IC_PLATFORM_IOS)
#define IC_PLATFORM_GL_CONTEXT EAGLContext
#endif

/** @} */

/**
 @addtogroup logging-and-debugging-macros Logging and Debugging Macros
 @{
 */

NSString *NSStringFromGLError(GLenum error);

#if DEBUG
#if IC_BREAK_ON_GL_ERRORS
#define IC_GL_ERROR_BREAK() NSAssert(nil, @"Configured to break on OpenGL error");
#else
#define IC_GL_ERROR_BREAK() do {} while(0)
#endif
#define IC_CHECK_GL_ERROR_DEBUG() \
    ({ \
        GLenum __error = glGetError(); \
        if(__error) { \
            NSLog(@"OpenGL error 0x%04X in %s %d: %@\n", __error, __FUNCTION__, __LINE__, \
                  NSStringFromGLError(__error)); \
            IC_GL_ERROR_BREAK(); \
        } \
    })
#else
#define IC_CHECK_GL_ERROR_DEBUG()
#endif

/** @} */

/**
 @defgroup opengl-redefinitions OpenGL Redefinitions
 @{
 */

// iOS
#ifdef __IC_PLATFORM_IOS

#define	glClearDepth				glClearDepthf
#define glDeleteVertexArrays		glDeleteVertexArraysOES
#define glGenVertexArrays			glGenVertexArraysOES
#define glBindVertexArray			glBindVertexArrayOES

// Mac
#elif defined(__IC_PLATFORM_MAC)

#define glDeleteVertexArrays		glDeleteVertexArraysAPPLE
#define glGenVertexArrays			glGenVertexArraysAPPLE
#define glBindVertexArray			glBindVertexArrayAPPLE

#endif

/** @} */

