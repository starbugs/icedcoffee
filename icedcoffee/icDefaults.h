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
 @file icDefaults.h
 @brief Provides preprocessor defines for global IcedCoffee compile-time defaults
 */

#pragma once

#import <Availability.h>

/**
 @def IC_DEFAULT_CONTENT_SCALE_FACTOR
 @brief The default content scale factor for non-retina displays
 */
#define IC_DEFAULT_CONTENT_SCALE_FACTOR 1.f

/**
 @def IC_DEFAULT_RETINA_CONTENT_SCALE_FACTOR
 @brief The default content scale factor for retina displays
 */
#define IC_DEFAULT_RETINA_CONTENT_SCALE_FACTOR 2.f

#import "ICUICamera.h"
/**
 @def IC_DEFAULT_CAMERA
 @brief The default camera instanciated and set by ICScene::initWithHostViewController:
 */
#define IC_DEFAULT_CAMERA ICUICamera

#if defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#import "Platforms/Mac/ICHostViewControllerMac.h"
#define IC_HOSTVIEWCONTROLLER ICHostViewControllerMac
#elif defined(__IPHONE_OS_VERSION_MAX_ALLOWED)
#import "Platforms/iOS/ICHostViewControllerIOS.h"
#define IC_HOSTVIEWCONTROLLER ICHostViewControllerIOS
#endif

#import "ICNodeVisitorDrawing.h"
/**
 @def IC_DEFAULT_DRAWING_VISITOR
 @brief The default drawing visitor class
 */
#define IC_DEFAULT_DRAWING_VISITOR ICNodeVisitorDrawing

#import "ICNodeVisitorPicking.h"
#import "ICNodeVisitorProjectionPicking.h" // experimental
/**
 @def IC_DEFAULT_PICKING_VISITOR
 @brief The default picking visitor class
 */
#define IC_DEFAULT_PICKING_VISITOR ICNodeVisitorPicking


