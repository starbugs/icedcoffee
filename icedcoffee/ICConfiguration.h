/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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

#import <Foundation/Foundation.h>
#import "Platforms/ICGL.h"

enum {
	ICIOSVersion_4_0   = 0x04000000,
	ICIOSVersion_4_0_1 = 0x04000100,
	ICIOSVersion_4_1   = 0x04010000,
	ICIOSVersion_4_2   = 0x04020000,
	ICIOSVersion_4_2_1 = 0x04020100,
	ICIOSVersion_4_3   = 0x04030000,
	ICIOSVersion_4_3_1 = 0x04030100,
	ICIOSVersion_4_3_2 = 0x04030200,
	ICIOSVersion_4_3_3 = 0x04030300,
	ICIOSVersion_4_3_4 = 0x04030400,
	ICIOSVersion_4_3_5 = 0x04030500,
	ICIOSVersion_5_0   = 0x05000000,
	ICIOSVersion_5_0_1 = 0x05000100,
	ICIOSVersion_5_1_0 = 0x05010000,
	ICIOSVersion_6_0_0 = 0x06000000,
    
	ICMacOSXVersion_10_5  = 0x0a050000,
	ICMacOSXVersion_10_6  = 0x0a060000,
	ICMacOSXVersion_10_7  = 0x0a070000,
	ICMacOSXVersion_10_8  = 0x0a080000,
};
/**
 @brief OS version definitions. Includes both iOS and Mac OS versions
 */
typedef uint ICOSVersion;

/**
 @brief Provides information about the system's configuration
 */
@interface ICConfiguration : NSObject {
    
	GLint			_maxTextureSize;
	BOOL			_supportsPVRTC;
	BOOL			_supportsNPOT;
	BOOL			_supportsBGRA8888;
	BOOL			_supportsDiscardFramebuffer;
    BOOL            _supportsPixelBufferObject;
	unsigned int	_OSVersion;
	GLint			_maxSamplesAllowed;
}


/** @name Obtaining the Configuration */

/**
 @brief Returns a globally shared instance of ICConfiguration
 */
+ (ICConfiguration *)sharedConfiguration;


/** @name Retrieving Configuration Information */

/**
 @brief The maximum texture size allowed by the current graphics hardware
 */
@property (nonatomic, readonly) GLint maxTextureSize;

/** @brief Whether or not the GPU supports NPOT (Non Power Of Two) textures.
 NPOT textures have the following limitations:
 - They can't have mipmaps
 - They only accept ``GL_CLAMP_TO_EDGE`` in ``GL_TEXTURE_WRAP_{S,T}``
 */
@property (nonatomic, readonly) BOOL supportsNPOT;

/** @brief Whether or not PVR texture compression is supported
 */
@property (nonatomic, readonly) BOOL supportsPVRTC;

/** @brief Whether or not ``BGRA8888`` textures are supported.
 */
@property (nonatomic, readonly) BOOL supportsBGRA8888;

/** @brief Whether or not ``glDiscardFramebufferEXT`` is supported
 */
@property (nonatomic, readonly) BOOL supportsDiscardFramebuffer;

/** @brief Whether or not OpenGL supports PBOs (Pixel Buffer Objects)
 */
@property (nonatomic, readonly) BOOL supportsPixelBufferObject;

/** @brief Returns the OS version.
 
 On iOS devices, returns the firmware version. On Mac OS X, returns the OS version.
 */
@property (nonatomic, readonly) unsigned int OSVersion;

/** @name Checking for OpenGL Extensions */

/** @brief Returns whether or not the given OpenGL extension is supported */
- (BOOL)checkForGLExtension:(NSString *)extensionName;

@end
