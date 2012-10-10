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

/*
 
ORIGINAL LICENSE:

===== IMPORTANT =====

This is sample code demonstrating API, technology or techniques in development.
Although this sample code has been reviewed for technical accuracy, it is not
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

#import "icMacros.h"

#ifdef __IC_PLATFORM_IOS
#import <UIKit/UIKit.h>	// for UIImage
#endif

#import <Foundation/Foundation.h>

#import "Platforms/ICGL.h"
#import "Platforms/ICNS.h"
#import "icTypes.h"


typedef struct _ICTexParams {
	GLuint minFilter;
	GLuint magFilter;
	GLuint wrapS;
	GLuint wrapT;
} ICTexParams;


/**
 @brief Represents an immutable two-dimensional OpenGL texture
 
 The ICTexture2D class provides methods allowing you to conveniently create and work with
 immutable two-dimensional OpenGL textures. In particular, ICTexture2D provides the following
 features:
 
 - Create textures from arbitrary pixel data, ``CGImage``s and from text strings
 - Manage the size of a texture with respect to SD and HD images and display devices
 - Set texture parameters for texture filtering on the OpenGL state
 
 The most common use case in most applications is loading a texture from a file. However,
 this is not directly supported by ICTexture2D. The ICTextureLoader class provides many methods
 that allow you to easily load textures from image files. The ICTextureCache class adds
 functionality to asynchronously load and cache textures in your application.
 */
@interface ICTexture2D : NSObject
{
@protected
	GLuint				_name;
    BOOL                _wrapsForeignOpenGLTexture;
	CGSize				_contentSizeInPixels;
    CGSize              _sizeInPixels;
	ICPixelFormat		_format;
	GLfloat				_maxS,
						_maxT;
	BOOL				_hasPremultipliedAlpha;
    ICResolutionType    _resolutionType;
    
#ifdef __IC_PLATFORM_IOS
    CVImageBufferRef _cvRenderTarget;
    CVOpenGLESTextureCacheRef _cvTextureCache;
    CVOpenGLESTextureRef _cvTexture;
#endif
}

/** @cond */ // Exclude from docs
- (id)init __attribute__((unavailable));
/** @endcond */

#pragma mark - Initializing a Texture with Data
/** @name Initializing a Texture with Data */

/**
 @brief Initializes a texture with the given data, pixel format, size and resolution type
 
 @param data A buffer containing the data to be uploaded to the OpenGL texture
 @param pixelFormat An ``ICPixelFormat`` enumerated value defining the texture's pixel format
 @param textureSizeInPixels The size of the texture in pixels
 @param contentSizeInPixels The size of the texture's contents in pixels
 @param resolutionType An ``ICResolutionType`` enumerated value defining the texture's
 resolution type
 
 The given ``data`` must contain pixels formatted as defined by the specified ``pixelFormat``.
 The most common pixel format in icedcoffee is ``ICPixelFormatRGBA8888``.
  ``textureSizeInPixels`` may differ from ``contentSizeInPixels`` in cases where power of two
 textures must be used to store non-power of two (NPOT) contents. The former defines the size of
 the texture in memory whereas the latter defines the size of the content stored in the texture.
  The ``resolutionType`` argument specifies the native resolution of the texture. If the texture
 represents a high resolution (retina display) image, you should set this to
 ``ICResolutionTypeRetinaDisplay``. Otherwise, this should be set to ``ICResolutionTypeStandard``.
 
 Note that this method calls ICTexture2D::setAntiAliasTexParameters before uploading the texture
 and that it binds the texture to ``GL_TEXTURE_2D`` on the current OpenGL context.
 */
- (id)initWithData:(const void*)data
       pixelFormat:(ICPixelFormat)pixelFormat
       textureSize:(CGSize)textureSizeInPixels
       contentSize:(CGSize)contentSizeInPixels
    resolutionType:(ICResolutionType)resolutionType;

/**
 @brief Initializes a texture with the given data, pixel format, width, height and content size
 in pixels
 
 @param data A buffer containing the data to be uploaded to the OpenGL texture
 @param pixelFormat An ``ICPixelFormat`` enumerated value defining the texture's pixel format
 @param pixelsWide The width of the texture in pixels
 @param pixelsHigh The height of the texture in pixels
 @param size The size of the contents in pixels
 
 @deprecated Deprecated as of v0.6.6. Use
 ICTexture2D::initWithData:pixelFormat:textureSize:contentSize:resolutionType: instead.
 */
- (id)initWithData:(const void*)data
       pixelFormat:(ICPixelFormat)pixelFormat
        pixelsWide:(NSUInteger)width
        pixelsHigh:(NSUInteger)height
              size:(CGSize)contentSizeInPixels DEPRECATED_ATTRIBUTE /*v0.6.6*/;

#ifdef __IC_PLATFORM_IOS
/**
 @brief Initializes a texture as a CoreVideo OpenGLES render target (iOS only)
 */
- (id)initAsCoreVideoRenderTextureWithTextureSize:(CGSize)textureSizeInPixels
                                   resolutionType:(ICResolutionType)resolutionType;
#endif // __IC_PLATFORM_IOS


#pragma mark - Initializing a Texture with a CGImage
/** @name Initializing a Texture with a CGImage */

/*
 FIXME: this needs to go into the docs
 Note that RGBA type textures will have their alpha premultiplied - use the blending mode (GL_ONE, GL_ONE_MINUS_SRC_ALPHA).
 */

#ifdef __IC_PLATFORM_MAC

/**
 @brief Initializes a texture with the given ``CGImageRef``
 
 This method internally calls ICTexture2D::initWithCGImage:resolutionType: and specifies
 ICResolutionTypeUnknown as the resolution type.
 */
- (id)initWithCGImage:(CGImageRef)cgImage;

#endif

/**
 @brief Initializes a texture with the given ``CGImageRef`` and resolution type
 */
- (id)initWithCGImage:(CGImageRef)cgImage resolutionType:(ICResolutionType)resolution;


#pragma mark - Initializing a Texture with Text
/** @name Initializing a Texture with Text */

/**
 @brief Initializes a texture from a string with dimensions, alignment, font name and font size
 */
- (id)initWithString:(NSString*)string
          dimensions:(CGSize)dimensions
           alignment:(ICTextAlignment)alignment
            fontName:(NSString*)name fontSize:(CGFloat)size;

/**
 @brief Initializes a texture from a string with font name and font size
 */
- (id)initWithString:(NSString*)string
            fontName:(NSString*)name
            fontSize:(CGFloat)size;


#pragma mark - Initializing a Texture with an OpenGL Texture
/** @name Initializing a Texture with an OpenGL Texture */

/**
 @brief Initializes the receiver with the given OpenGL texture
 */
- (id)initWithOpenGLName:(GLuint)name size:(CGSize)sizeInPixels;


#pragma mark - Retrieving Information about the Texture's Format
/** @name Retrieving Information about the Texture's Format */

/**
 @brief The pixel format of the receiver
 */
@property (nonatomic, readonly) ICPixelFormat pixelFormat;

/**
 @brief Whether the receiver's color values are premultiplied with their respective alpha values
 */
@property (nonatomic, readonly) BOOL hasPremultipliedAlpha;

/**
 @brief The receiver's resolution type
 */
@property (nonatomic, readonly) ICResolutionType resolutionType;


#pragma mark - Retrieving Size Information from a Texture
/** @name Retrieving Size Information from a Texture */

/**
 @brief The content size of the receiver in pixels
 */
@property (nonatomic, readonly) CGSize contentSizeInPixels;

/**
 @brief Returns the size of the receiver's contents in points
 */
- (CGSize)contentSize;

/**
 @brief Returns the size of the receiver contents in points scaled with regard to its resolution
 type and the current global content scale factor
 */
- (CGSize)displayContentSize;

/**
 @brief Returns the receiver's size in points
 
 This method returns the size of the texture surface in points. If you need to know the size of
 the texture's contents, use ICTexture2D::contentSize or ICTexture2D::displayContentSize instead.
 */
- (CGSize)size;

/**
 @brief The receiver's size in pixels

 This property defines the size of the texture surface in pixels. If you need to know the size of
 the texture's contents, use ICTexture2D::contentSize or ICTexture2D::displayContentSize instead.
 */
@property (nonatomic, readonly) CGSize sizeInPixels;

/**
 @brief Returns the width of the receiver in pixels
 */
- (NSUInteger)pixelsWide;

/**
 @brief Returns the height of the receiver in pixels
 */
- (NSUInteger)pixelsHigh;


#pragma mark - Working with Texture Coordinate Information
/** @name Working with Texture Coordinate Information */

/**
 @brief The texture max S coordinate
 */
@property (nonatomic, readwrite) GLfloat maxS;

/**
 @brief The texture max T coordinate
 */
@property (nonatomic, readwrite) GLfloat maxT;


#pragma mark - Generating Mipmaps
/** @name Generating Mipmaps */

/**
 @brief Generates mipmap images for the receiver
 
 This only works if the texture size is power of 2 (POT).
 
 Note that this method binds the texture to ``GL_TEXTURE_2D`` in the current OpenGL context.
 */
- (void)generateMipmap;


#pragma mark - Setting Texture Parameters on the OpenGL State
/** @name Setting Texture Parameters on the OpenGL State */

/**
 @brief Sets the min filter, mag filter, wrap s and wrap t texture parameters
 
 If the texture size is NPOT (non power of 2), then it can only use ``GL_CLAMP_TO_EDGE`` in
 ``GL_TEXTURE_WRAP_{S,T}``.

 Note that this method binds the texture to ``GL_TEXTURE_2D`` in the current OpenGL context.
 */
- (void)setTexParameters:(ICTexParams*)texParams;

/**
 @brief Sets texture parameters for antialiasing
 
 This method sets ``GL_TEXTURE_MIN_FILTER`` to ``GL_LINEAR`` and ``GL_TEXTURE_MAG_FILTER``
 to ``GL_LINEAR``.

 Note that this method binds the texture to ``GL_TEXTURE_2D`` in the current OpenGL context.
 */
- (void)setAntiAliasTexParameters;

/**
 @brief Sets alias texture parameters
 
 This method sets ``GL_TEXTURE_MIN_FILTER`` to ``GL_NEAREST`` and ``GL_TEXTURE_MAG_FILTER``
 to ``GL_NEAREST``.

 Note that this method binds the texture to ``GL_TEXTURE_2D`` in the current OpenGL context.
 */
- (void)setAliasTexParameters;


#pragma mark - Retrieving OpenGL Parameters
/** @name Retrieving OpenGL Parameters */

/**
 @brief The OpenGL texture name of the receiver
 */
@property (nonatomic, readonly) GLuint name;

#ifdef __IC_PLATFORM_IOS
@property (nonatomic, readonly) CVPixelBufferRef cvRenderTarget;
#endif


#pragma mark - Changing the Default Alpha Pixel Format
/** @name Changing the Default Alpha Pixel Format */

/**
 @brief Sets the global default pixel format for creating textures from images that contain an
 alpha channel
 
 If the image contains an alpha channel, then the options are:
 - generate 32-bit textures: ICPixelFormatRGBA8888 (default one)
 - generate 16-bit textures: ICPixelFormatRGBA4444
 - generate 16-bit textures: ICPixelFormatRGB5A1
 - generate 16-bit textures: ICPixelFormatRGB565
 - generate 8-bit textures: ICPixelFormatA8 (only use it if you use just 1 color)
 
 Note that if the image is RGBA (with alpha) then the default pixel format will be used
 (it can be a 8-bit, 16-bit or 32-bit texture). If the image is RGB (without alpha) then an
 RGB565 texture will be used (16-bit texture).
 
 Also note that this method is currently not thread-safe.
 */
+ (void)setDefaultAlphaPixelFormat:(ICPixelFormat)format;

/**
 @brief Returns the global default alpha pixel format
 */
+ (ICPixelFormat)defaultAlphaPixelFormat;

@end
