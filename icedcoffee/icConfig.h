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


#pragma once


#import "icMacros.h"

/**
 @defgroup icedcoffee-configuration Icedcoffee Configuration
 @{
 */


// General Configuration

// GL state cache (incomplete)
#ifndef IC_ENABLE_GL_STATE_CACHE
#define IC_ENABLE_GL_STATE_CACHE 1
#endif


// Extensions

#ifndef IC_ENABLE_GPUIMAGE_EXTENSIONS
/**
 @brief Activate to enable the GPUImage extensions
 
 Note that you may also add ``IC_ENABLE_GPUIMAGE_EXTENSIONS=1`` to the preprocessor build setting
 of your custom target to activate the GPUImage extensions selectively.
 */
#define IC_ENABLE_GPUIMAGE_EXTENSIONS 0
#endif


// Optimizations

#ifdef __IC_PLATFORM_IOS

#ifndef IC_ENABLE_CV_TEXTURE_CACHE
#define IC_ENABLE_CV_TEXTURE_CACHE 1
#endif

#ifndef IC_ENABLE_RAY_BASED_HIT_TESTS
#define IC_ENABLE_RAY_BASED_HIT_TESTS 1
#endif

#endif // __IC_PLATFORM_IOS


// Logging and Debugging

#ifndef IC_DEBUG_ICNODE_PARENTS
#define IC_DEBUG_ICNODE_PARENTS 0
#endif

#ifndef IC_BREAK_ON_GL_ERRORS
/**
 @brief Activate to break on GL errors when debugging
 */
#define IC_BREAK_ON_GL_ERRORS 0
#endif

#ifndef IC_DEBUG_OUTPUT_FPS_ON_CONSOLE
/**
 @brief Activate to output an FPS log message to the console once per second
 */
#define IC_DEBUG_OUTPUT_FPS_ON_CONSOLE 1
#endif

#ifndef IC_ENABLE_DEBUG_HITTEST
/**
 @brief Activate to output log messages for hit test results
 */
#define IC_ENABLE_DEBUG_HITTEST 0
#endif

#ifndef IC_ENABLE_DEBUG_PICKING
/**
 @brief Activate to output log messages for picking
 */
#define IC_ENABLE_DEBUG_PICKING 0
#endif

#ifndef IC_ENABLE_DEBUG_HOSTVIEWCONTROLLER
/**
 @brief Activate to output log messages for host view controllers
 */
#define IC_ENABLE_DEBUG_HOSTVIEWCONTROLLER 0
#endif

#ifndef IC_ENABLE_DEBUG_TOUCH_DISPATCHER
/**
 @brief Activate to output log messages when dispatching touch events (iOS only)
 */
#define IC_ENABLE_DEBUG_TOUCH_DISPATCHER 0
#endif

#ifndef IC_ENABLE_DEBUG_OPENGL_CONTEXTS
/**
 @brief Activate to output log messages pertaining to OpenGL context setup and management
 */
#define IC_ENABLE_DEBUG_OPENGL_CONTEXTS 0
#endif

#ifndef IC_ENABLE_DEBUG_TEXTURE_CACHE
#define IC_ENABLE_DEBUG_TEXTURE_CACHE 0
#endif

#ifndef IC_ENABLE_DEBUG_GLYPH_CACHE
#define IC_ENABLE_DEBUG_GLYPH_CACHE 0
#endif

#ifndef IC_ENABLE_DEBUG_GLYPH_RUN_METRICS
#define IC_ENABLE_DEBUG_GLYPH_RUN_METRICS 1
#endif

#ifndef IC_ENABLE_DEBUG_TEXTFRAME_DRAW_BOUNDING_BOX
#define IC_ENABLE_DEBUG_TEXTFRAME_DRAW_BOUNDING_BOX 1
#endif

/** @} */

