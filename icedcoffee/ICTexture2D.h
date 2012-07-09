/*

===== IMPORTANT =====

This is sample code demonstrating API, technology or techniques in development.
Although this sample code has been reviewed for technical aICuracy, it is not
final. Apple is supplying this information to help you plan for the adoption of
the technologies and programming interfaces described herein. This information
is subject to change, and software implemented based on this sample code should
be tested with final operating system software and final documentation. Newer
versions of this sample code may be provided with future seeds of the API or
technology. For information about updates to this and other developer
documentation, view the New & Updated sidebars in subsequent documentation
seeds.

=====================

File: Texture2D.h
Abstract: Creates OpenGL 2D textures from images or text.

Version: 1.6

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes aICeptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import <Availability.h>

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>			// for UIImage
#endif

#import <Foundation/Foundation.h> //	for NSObject

#import "Platforms/ICGL.h" // OpenGL stuff
#import "Platforms/ICNS.h" // Next-Step stuff
#import "icMacros.h"
#import "icTypes.h"

/** ICTexture2D class.
 * This class allows to easily create OpenGL 2D textures from images, text or raw data.
 * The created ICTexture2D object will always have power-of-two dimensions. 
 * Depending on how you create the ICTexture2D object, the actual image area of the texture might be smaller than the texture dimensions i.e. "size" != (pixelsWide, pixelsHigh) and (maxS, maxT) != (1.0, 1.0).
 * Be aware that the content of the generated textures will be upside-down!
 */
@interface ICTexture2D : NSObject
{
	GLuint						name_;
	CGSize						size_;
	NSUInteger					width_,
								height_;
	ICPixelFormat		format_;
	GLfloat						maxS_,
								maxT_;
	BOOL						hasPremultipliedAlpha_;
}

/** Intializes with a texture2d with data */
- (id) initWithData:(const void*)data pixelFormat:(ICPixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height size:(CGSize)size;

/** These functions are needed to create mutable textures */
- (void) releaseData:(void*)data;
- (void*) keepData:(void*)data length:(NSUInteger)length;

/** pixel format of the texture */
@property(nonatomic,readonly) ICPixelFormat pixelFormat;
/** width in pixels */
@property(nonatomic,readonly) NSUInteger pixelsWide;
/** hight in pixels */
@property(nonatomic,readonly) NSUInteger pixelsHigh;

/** texture name */
@property(nonatomic,readonly) GLuint name;

/** returns content size of the texture in pixels */
@property(nonatomic,readonly, nonatomic) CGSize sizeInPixels;

/** texture max S */
@property(nonatomic,readwrite) GLfloat maxS;
/** texture max T */
@property(nonatomic,readwrite) GLfloat maxT;
/** whether or not the texture has their Alpha premultiplied */
@property(nonatomic,readonly) BOOL hasPremultipliedAlpha;

/** returns the content size of the texture in points */
-(CGSize) size;
@end

/**
Extensions to make it easy to create a ICTexture2D object from an image file.
Note that RGBA type textures will have their alpha premultiplied - use the blending mode (GL_ONE, GL_ONE_MINUS_SRC_ALPHA).
*/
@interface ICTexture2D (Image)
/** Initializes a texture from a UIImage object */
#ifdef __IC_PLATFORM_IOS
- (id) initWithCGImage:(CGImageRef)cgImage resolutionType:(ICResolutionType)resolution;
#elif defined(__IC_PLATFORM_MAC)
- (id) initWithCGImage:(CGImageRef)cgImage;
#endif
@end

/**
Extensions to make it easy to create a ICTexture2D object from a string of text.
Note that the generated textures are of type A8 - use the blending mode (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA).
*/
@interface ICTexture2D (Text)
/** Initializes a texture from a string with dimensions, alignment, font name and font size */
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(ICTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
/** Initializes a texture from a string with font name and font size */
- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size;
@end


/**
 Extension to set the Min / Mag filter
 */
typedef struct _ICTexParams {
	GLuint	minFilter;
	GLuint	magFilter;
	GLuint	wrapS;
	GLuint	wrapT;
} ICTexParams;

@interface ICTexture2D (GLFilter)
/** sets the min filter, mag filter, wrap s and wrap t texture parameters.
 If the texture size is NPOT (non power of 2), then in can only use GL_CLAMP_TO_EDGE in GL_TEXTURE_WRAP_{S,T}.
 @since v0.8
 */
-(void) setTexParameters: (ICTexParams*) texParams;

/** sets antialias texture parameters:
  - GL_TEXTURE_MIN_FILTER = GL_LINEAR
  - GL_TEXTURE_MAG_FILTER = GL_LINEAR

 @since v0.8
 */
- (void) setAntiAliasTexParameters;

/** sets alias texture parameters:
  - GL_TEXTURE_MIN_FILTER = GL_NEAREST
  - GL_TEXTURE_MAG_FILTER = GL_NEAREST
 
 @since v0.8
 */
- (void) setAliasTexParameters;


/** Generates mipmap images for the texture.
 It only works if the texture size is POT (power of 2).
 @since v0.99.0
 */
-(void) generateMipmap;


@end

@interface ICTexture2D (PixelFormat)
/** sets the default pixel format for UIImages that contains alpha channel.
 If the UIImage contains alpha channel, then the options are:
	- generate 32-bit textures: ICPixelFormatRGBA8888 (default one)
	- generate 16-bit textures: ICPixelFormatRGBA4444
	- generate 16-bit textures: ICPixelFormatRGB5A1
	- generate 16-bit textures: ICPixelFormatRGB565
	- generate 8-bit textures: ICPixelFormatA8 (only use it if you use just 1 color)

 How does it work ?
   - If the image is an RGBA (with Alpha) then the default pixel format will be used (it can be a 8-bit, 16-bit or 32-bit texture)
   - If the image is an RGB (without Alpha) then an RGB565 texture will be used (16-bit texture)
 
 This parameter is not valid for PVR images.
 
 @since v0.8
 */
+(void) setDefaultAlphaPixelFormat:(ICPixelFormat)format;

/** returns the alpha pixel format
 @since v0.8
 */
+(ICPixelFormat) defaultAlphaPixelFormat;
@end





