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

#import <Foundation/Foundation.h>

#import "icTypes.h"

/**
 @brief Represents an OpenGL framebuffer object
 */
@interface ICFramebuffer : NSObject {
@protected
	GLuint      _fbo;
	GLint		_oldFBO;
    GLint       _oldFBOViewport[4];
    GLuint      _colorRBO;
    GLuint      _depthRBO;
    GLuint      _stencilRBO;
    GLint       _oldRBO;
    CGSize      _size;
	GLenum		_pixelFormat;
    GLenum      _depthBufferFormat;
    GLenum      _stencilBufferFormat;
    BOOL        _isInFramebufferDrawContext;
}

#pragma mark - Creating a Framebuffer
/** @name Creating a Framebuffer */

+ (id)framebufferWithSize:(CGSize)size
              pixelFormat:(ICPixelFormat)pixelFormat
        depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
      stencilBufferFormat:(ICStencilBufferFormat)stencilBufferFormat;

-  (id)initWithSize:(CGSize)size
        pixelFormat:(ICPixelFormat)pixelFormat
  depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
stencilBufferFormat:(ICStencilBufferFormat)stencilBufferFormat;


#pragma mark - Managing the Framebuffer's Size
/** @name Managing the Framebuffer's Size */

@property (nonatomic, assign, setter=setSize:) CGSize size;

- (CGSize)sizeInPixels;


#pragma mark - Drawing to the Framebuffer
/** @name Drawing to the Framebuffer */

- (void)begin;

- (void)end;

@property (nonatomic, readonly) BOOL isInFramebufferDrawContext;


#pragma mark - Reading Back Pixel Colors
/** @name Reading Back Pixel Colors */

- (icColor4B)colorOfPixelAtLocation:(CGPoint)location;

@end
