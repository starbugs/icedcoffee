/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Jason Booth
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
 *
 * Adapted and extended for IcedCoffee
 */

#import "ICNode.h"
#import "ICTexture2D.h"
#import "icTypes.h"

@class ICSprite;
@class ICScene;

typedef enum _ICRenderTextureDisplayMode {
    kICRenderTextureDisplayMode_Always = 0,
    kICRenderTextureDisplayMode_Conditional = 1
} ICRenderTextureDisplayMode;

/**
 @brief A node that renders a sub-scene to a texture render target and displays the result
 
 <h3>Overview</h3>
 
 The ICRenderTexture class implements a mechanism for rendering a scene represented by an
 ICScene object into a texture. The texture is displayed using an ICSprite object.
 ICRenderTexture itself is a subclass of ICNode, that is you add it to an arbitrary
 scene graph and do not have to care about further details.
 
 ICRenderTexture has been designed to integrate with IcedCofee's visitation system.
 Thus it supports picking and event handling via ICScene and ICHostViewController.
 
 ICRenderTexture objects may be nested in arbitrary sub scene graphs,
 which is particularly useful for implementing view hierarchies backed by OpenGL
 frame buffers. To make this concept even more powerful, ICRenderTexture adds functionality
 for conditional drawing (frame buffer updates on demand only) to the IcedCoffee scene
 graph framework. Conditional drawing can be configured using the <code>displayMode</code>
 property. If <code>displayMode</code> is set to
 <code>kICRenderTextureDisplayMode_Conditional</code>, the visitation system will draw
 the sub scene of the render texture only if <code>setNeedsDisplay</code> was called in
 the current run loop slice. If <code>displayMode</code> is set to
 <code>kICRenderTextureDisplayMode_Always</code>, the framework will render the sub scene
 to the render texture on each frame update of the current host view controller scene.
 */
@interface ICRenderTexture : ICNode {
@protected
	GLuint      _fbo;
	GLint		_oldFBO;
    GLint       _oldFBOViewport[4];
    GLuint      _depthRBO;
    GLint       _oldRBO;
	ICTexture2D *_texture;
	ICSprite    *_sprite;
    ICScene     *_subScene;
	GLenum		_pixelFormat;
    BOOL        _isInRenderTextureDrawContext;
    
    ICRenderTextureDisplayMode _displayMode;
    BOOL _needsDisplay;
}

/**
 @brief The texture object associated with the render texture node
 */
@property (nonatomic, readonly) ICTexture2D *texture;

/**
 @brief The sprite used to draw the texture on the frame buffer
 */
@property (nonatomic, readonly) ICSprite *sprite;

/**
 @brief The sub scene drawn into the render texture
 */
@property (nonatomic, retain, setter=setSubScene:) ICScene *subScene;

/**
 @brief A boolean flag indicating whether the render texture's FBO is currently set as the
 OpenGL target frame buffer
 */
@property (nonatomic, readonly) BOOL isInRenderTextureDrawContext;

/**
 @brief A display mode defining when to update the render texture contents
 */
@property (nonatomic, assign) ICRenderTextureDisplayMode displayMode;

/**
 @brief Returns an autoreleased render texture initialized with the given width, height,
 and pixel format
 @sa initWithWidth:height:pixelFormat:
 */
+ (id)renderTextureWithWidth:(int)w height:(int)h pixelFormat:(ICTexture2DPixelFormat)format;

+ (id)renderTextureWithWidth:(int)w
                      height:(int)h
                 pixelFormat:(ICTexture2DPixelFormat)format
           enableDepthBuffer:(BOOL)enableDepthBuffer;

/**
 @brief Initializes a render texture with the given width, height, and pixel format
 
 @param w The width of the texture in points
 @param h The height of the texture in points
 @param format An ICTexture2DPixelFormat enumerated type value indicating the texture's
 pixel format
 */
- (id)initWithWidth:(int)w height:(int)h pixelFormat:(ICTexture2DPixelFormat)format;

- (id)initWithWidth:(int)w
             height:(int)h
        pixelFormat:(ICTexture2DPixelFormat)format
  enableDepthBuffer:(BOOL)enableDepthBuffer;

/**
 @brief Sets the render texture's FBO as the current frame buffer and adjusts the current
 viewport accordingly
 */
- (void)begin;

/**
 @brief Sets the previously selected FBO as the current frame buffer and resets the current
 viewport accordingly
 */
- (void)end;

/**
 @brief Reads the color of the pixel at the given location (in pixels) in the texture's
 frame buffer
 */
- (icColor4B)colorOfPixelAtLocation:(CGPoint)location;

/**
 @brief Tells the framework that the texture's contents need to be redrawn
 */
- (void)setNeedsDisplay;

@end
