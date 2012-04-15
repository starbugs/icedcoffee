//  
//  Copyright (C) 2012 Tobias Lensing
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
 @brief Preprocessor macros commonly used in IcedCoffee
 */

#pragma once

#import <Availability.h>


// Platform Defines

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
/**
 @brief Defined when compiled for the iOS platform
 */
#define __IC_PLATFORM_IOS 1
/**
 @brief Defined when compiled for a touch platform
 */
#define __IC_PLATFORM_TOUCH 1
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
/**
 @brief Defined when compiled for the Mac platform
 */
#define __IC_PLATFORM_MAC 1
/**
 @brief Defined when compiled for a desktop platform
 */
#define __IC_PLATFORM_DESKTOP 1
#endif


#import "icGLState.h"
#import "ICNodeVisitorPicking.h"


// Retina display support

extern float g_icContentScaleFactor;

/**
 @brief A global content scale factor used for scaling points to pixels on retina displays
 
 Use this macro to retrieve the current global content scale factor. Point coordinates must be
 multiplied by this factor to transform them to pixel coordinates. Consequently, pixel coordinates
 may be divided by this factor to yield point coordinates.
 
 The default content scale factors on all platforms is 1.0. On iOS, you may enable retina display
 support using ICHostViewController::enableRetinaDisplaySupport:. If the device's software and
 hardware support the retina display, the content scale factor will be set to 2.0.
 
 The default content scale factors are defined in #ICDEFAULT_CONTENT_SCALE_FACTOR
 and #ICDEFAULT_RETINA_CONTENT_SCALE_FACTOR.
 */
#define IC_CONTENT_SCALE_FACTOR() g_icContentScaleFactor


// Logging

#if defined(ICEDCOFFEE_DEBUG)

#if IC_LOG_DEALLOCATIONS
#define ICLOG_DEALLOC(...) NSLog(__VA_ARGS__)
#else
#define ICLOG_DEALLOC(...) do {} while(0)
#endif // IC_LOG_DEALLOCATIONS

#define ICLOG(...) NSLog(__VA_ARGS__) 

#else

#define ICLOG(...) do {} while(0)
#define ICLOG_DEALLOC(...) do {} while(0)

#endif // ICEDCOFEE_DEBUG



