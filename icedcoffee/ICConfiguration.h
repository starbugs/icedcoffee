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

// FIXME: certain parts inherited from cocos2d, but not (yet) used in IcedCoffee

/** OS version definitions. Includes both iOS and Mac OS versions
 */
enum {
	kICiOSVersion_3_0   = 0x03000000,
	kICiOSVersion_3_1   = 0x03010000,
	kICiOSVersion_3_1_1 = 0x03010100,
	kICiOSVersion_3_1_2 = 0x03010200,
	kICiOSVersion_3_1_3 = 0x03010300,
	kICiOSVersion_3_2   = 0x03020000,
	kICiOSVersion_3_2_1 = 0x03020100,
	kICiOSVersion_4_0   = 0x04000000,
	kICiOSVersion_4_0_1 = 0x04000100,
	kICiOSVersion_4_1   = 0x04010000,
    
	kICMacVersion_10_5  = 0x0a050000,
	kICMacVersion_10_6  = 0x0a060000,
	kICMacVersion_10_7  = 0x0a070000,
};

/**
 CCConfiguration contains some openGL variables
 @since v0.99.0
 */
@interface ICConfiguration : NSObject {
    
	GLint			maxTextureSize_;
	GLint			maxModelviewStackDepth_;        // FIXME: not required with GLES2
	BOOL			supportsPVRTC_;
	BOOL			supportsNPOT_;
	BOOL			supportsBGRA8888_;
	BOOL			supportsDiscardFramebuffer_;
	unsigned int	OSVersion_;
	GLint			maxSamplesAllowed_;
}

/** OpenGL Max texture size. */
@property (nonatomic, readonly) GLint maxTextureSize;

/** OpenGL Max Modelview Stack Depth. */
@property (nonatomic, readonly) GLint maxModelviewStackDepth;

/** Whether or not the GPU supports NPOT (Non Power Of Two) textures.
 NPOT textures have the following limitations:
 - They can't have mipmaps
 - They only accept GL_CLAMP_TO_EDGE in GL_TEXTURE_WRAP_{S,T}
 
 @since v0.99.2
 */
@property (nonatomic, readonly) BOOL supportsNPOT;

/** Whether or not PVR Texture Compressed is supported */
@property (nonatomic, readonly) BOOL supportsPVRTC;

/** Whether or not BGRA8888 textures are supported.
 
 @since v0.99.2
 */
@property (nonatomic, readonly) BOOL supportsBGRA8888;

/** Whether or not glDiscardFramebufferEXT is supported
 
 @since v0.99.2
 */
@property (nonatomic, readonly) BOOL supportsDiscardFramebuffer;

/** returns the OS version.
 - On iOS devices it returns the firmware version.
 - On Mac returns the OS version
 
 @since v0.99.5
 */
@property (nonatomic, readonly) unsigned int OSVersion;

/** returns a shared instance of the CCConfiguration */
+ (ICConfiguration *) sharedConfiguration;

/** returns whether or not an OpenGL is supported */
- (BOOL) checkForGLExtension:(NSString *)searchName;



@end
