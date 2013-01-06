//
//  Copyright (C) 2013 Tobias Lensing, Marcus Tillmanns
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

#import "ICTexture2D.h"

/**
 @brief Represents a mutable two-dimensional texture
 
 ICMutableTexture2D represents a mutable two-dimensional texture. It is based upon ICTexture2D
 and adds the following functionality:
 - Initializing a texture without immediately uploading its contents to OpenGL video memory
 - Keeping a copy of a texture's data in RAM
 - Uploading modified texture data to OpenGL at any time
 - Updating a rectangular area of a texture at any time
 */
@interface ICMutableTexture2D : ICTexture2D {
@protected
    void *_data;
    BOOL _ownsData;
    BOOL _dataDirty;
}

/**
 @brief Initializes a mutable texture
 
 @param data A buffer containing the data to be uploaded to the OpenGL texture. You may specify
 ``nil`` if the texture's data should not be uploaded immediately.
 @param pixelFormat An ``ICPixelFormat`` enumerated value defining the texture's pixel format
 @param textureSizeInPixels The size of the texture in pixels
 @param contentSizeInPixels The size of the texture's contents in pixels
 @param resolutionType An ``ICResolutionType`` enumerated value defining the texture's
 resolution type
 @param keepData A boolean flag indicating whether the given data should be kept in memory.
 If set to ``YES``, ICMutableTexture2D will claim ownership the memory pointed to by ``data``
 by referencing it in ICMutableTextur2D::data and setting ICMutableTexture2D::ownsData to ``YES``.
 This will free the block of memory pointed to be ``data`` implicitly upon deallocation.
 @param uploadImmediately A boolean flag indicating whether the given ``data`` should be uploaded
 to OpenGL video memory immediately upon initialization. If set to ``NO``, ICMutableTexture2D
 will neither create an OpenGL texture name nor upload any texture data before
 ICMutableTexture2D::upload is called.
 
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
- (id)initWithData:(void*)data
       pixelFormat:(ICPixelFormat)pixelFormat
       textureSize:(CGSize)textureSizeInPixels
       contentSize:(CGSize)contentSizeInPixels
    resolutionType:(ICResolutionType)resolutionType
          keepData:(BOOL)keepData
 uploadImmediately:(BOOL)uploadImmediately;

/**
 @brief A copy of the texture's pixel data in RAM
 
 If ICMutableTexture2D::ownsData is set to ``YES``, setting this property will free the previous
 block of memory pointed to by a non-nil value of ICMutableTexture2D::data.
 */
@property (nonatomic, assign, setter=setData:) void *data;

/**
 @brief Whether the receiver claims ownership of its copy of the ICMutableTexture2D::data.
 
 If set to ``YES``, the class will free ICMutableTexture2D::data upon deallocation or if
 ICMutableTexture2D::data is set to a new value.
 */
@property (nonatomic, assign) BOOL ownsData;

/**
 @brief Whether the receiver's current ICMutableTexture2D::data is in a dirty state (has not
 yet been uploaded to OpenGL)
 */
@property (nonatomic, assign) BOOL dataDirty;

/**
 @brief Uploads the receiver's ICMutableTexture2D::data to OpenGL video memory
 */
- (void)upload;

/**
 @brief Uploads the given data to the receiver's texture in OpenGL video memory
 */
- (void)uploadData:(const void *)data;

/**
 @brief Uploads the given data to the specified rectangle of the receiver's texture in OpenGL
 video memory
 */
- (void)uploadData:(const void *)data inRect:(CGRect)rect;

@end
