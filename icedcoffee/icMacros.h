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

/**
 @file icMacros.h
 @brief Preprocessor macros commonly used in icedcoffee
 */

#pragma once

#import "icAvailability.h"
#import "ICOpenGLContext.h"


// Constants

#define IC_HUGE 1.0e+38f


// Retina display support

/**
 @defgroup retina-display-support-macros Retina Display Support Macros
 @{
 */

/**
 @brief A global content scale factor used for scaling points to pixels on retina displays
 
 Use this macro to retrieve the current global content scale factor. Point coordinates must be
 multiplied by this factor to transform them to pixel coordinates. Consequently, pixel coordinates
 may be divided by this factor to yield point coordinates. For your convenience, icedcoffee
 provides two macros for doing exactly this: #ICPointsToPixels and #ICPixelsToPoints.
 
 The default content scale factor on all platforms is 1.0. On iOS, you may enable retina display
 support using ICHostViewController::enableRetinaDisplaySupport:. If the device's software and
 hardware support the retina display, the content scale factor will be set to 2.0.
 
 The default content scale factors are defined in #IC_DEFAULT_CONTENT_SCALE_FACTOR
 and #IC_DEFAULT_RETINA_CONTENT_SCALE_FACTOR.
 */
#define ICContentScaleFactor() ([[ICOpenGLContext currentContext] contentScaleFactor])

/**
 @brief Converts the given value from points to pixels
 */
#define ICPointsToPixels(points) (points*ICContentScaleFactor())

/**
 @brief Converts the given value from pixels to points
 */
#define ICPixelsToPoints(pixels) (pixels/ICContentScaleFactor())

/** @} */


/**
 @defgroup stringifaction-macros Stringification Macros
 @{
 */

// See http://gcc.gnu.org/onlinedocs/cpp/Stringification.html

/**
 @brief Creates a C string from the given argument
 */
#define IC_STRINGIFY(x) #x

/**
 @brief Macro for reusing #IC_STRINGIFY in other macros
 */
#define IC_STRINGIFY2(x) IC_STRINGIFY(x)

/**
 @brief Creates an Objective-C string from the given argument
 */
#define IC_STRINGIFY_OBJC(text) @ IC_STRINGIFY2(text)

/**
 @brief Creates a shader string from the given argument
 
 This macro should be used to embed GLSL shader source code in Objective-C/C/C++ source files.
 */
#define IC_SHADER_STRING(text) IC_STRINGIFY_OBJC(text)

/** @} */


/**
 @defgroup logging-and-debugging-macros Logging and Debugging Macros
 @{
 */

// Logging and Debugging

#if defined(DEBUG) && defined(ICEDCOFFEE_DEBUG)

// Macro for breaking into the debugger
#define ICDebugBreak() kill(getpid(), SIGINT)

// Macro for logging deallocations
#if IC_LOG_DEALLOCATIONS
#define ICLogDealloc(...) NSLog(__VA_ARGS__)
#else
#define ICLogDealloc(...) do {} while(0)
#endif // IC_LOG_DEALLOCATIONS

// Macro for general icedcoffee logging
#define ICLog(...) NSLog(__VA_ARGS__)

#else

#define ICDebugBreak() do {} while(0)
#define ICLog(...) do {} while(0)
#define ICLogDealloc(...) do {} while(0)

#endif // ICEDCOFEE_DEBUG

/** @} */


