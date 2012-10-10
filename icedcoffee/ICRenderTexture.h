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
 * Adapted and extended for IcedCoffee by Tobias Lensing, mail@tlensing.org
 */

#import "ICPlanarNode.h"
#import "ICFramebufferProvider.h"
#import "ICTexture2D.h"
#import "icTypes.h"
#import "icConfig.h"

@class ICSprite;
@class ICScene;

/**
 @brief A node that renders a sub-scene to a texture render target and displays the result
 using a built-in sprite
 
 <h3>Overview</h3>
 
 The ICRenderTexture class implements a mechanism for rendering a scene represented by an
 ICScene object into a framebuffer object (FBO) backed by a texture. The class comes with
 built-in support for depth and stencil buffer attachments to the FBO. It supports picking
 and event handling implicitly, i.e. all nodes added to the render texture's sub scene
 will be capable of picking and handling user interaction events automatically. The
 ICRenderTexture class furthermore allows for conditional ('on-demand') redrawing of its
 contents.
 
 <h3>Setup</h3>
 
 You set up an ICRenderTexture by initializing it with the desired size and, optionally,
 buffer formats. You then define the sub scene that presents the contents of the render texture.
 The render texture itself is finally added to a scene. It then automatically draws the contents
 defined in the sub scene to its texture and displays it using a built-in sprite.
 
 Example:
 @code
 // Initialize an autoreleased render texture object with a size of 320x240 points.
 // As we did not specify any buffer formats, the render texture will be created with a
 // default (RGBA8888) color buffer and no depth/stencil buffers.
 ICRenderTexture *myRenderTexture = [ICRenderTexture renderTextureWithWidth:320 height:240];
 
 // Now specify the scene the render texture should present on screen. We will just add an
 // examplary sprite to the scene here
 myRenderTexture.subScene = [ICScene sceneWithHostViewController:(self.hostViewController)];
 ICSprite *mySprite = [ICSprite spriteWithTexture:someTexture];
 [myRenderTexture.subScene addChild:mySprite];
 
 // Finally, add the render texture to our scene
 [self.scene addChild:myRenderTexture];
 @endcode
 
 @note The example above assumes that you have set up an ICTexture2D object named
 <code>someTexture</code>, that <code>self.hostViewController</code> is a valid reference
 to the host view controller used to present the scene and that <code>self.scene</code>
 is a reference to the scene the render texture should be added to as a child.
 
 <h3>Resizing</h3>
 
 You may resize an ICRenderTexture object by changing its ICRenderTexture::size property.
 The render texture will then re-create its internal buffers automatically.
 
 <h3>Conditional Drawing</h3>
 
 ICRenderTexture adds functionality for conditional drawing (framebuffer updates on demand only)
 to the IcedCoffee scene graph. Conditional drawing can be configured using the
 ICRenderTexture::frameUpdateMode property. If ICRenderTexture::frameUpdateMode is set to
 <code>ICFrameUpdateModeOnDemand</code>, the visitation system will draw the sub scene of
 the render texture only if ICNode::setNeedsDisplay was called within the current run loop
 slice. If <code>frameUpdateMode</code> is set to <code>ICFrameUpdateModeSynchronized</code>,
 the framework will render the sub scene to the render texture on each time the parent
 scene is drawn.
 
 Note that by default render textures are initialized with
 <code>ICFrameUpdateModeSynchronized</code>. For sub scenes that do not change frequently,
 you should set the frame update mode to on demand drawing.
 
 @code
 // As the sprite we have added in the previous example isn't updated frequently, improve
 // rendering performance by only drawing it when really required:
 myRenderTexture.frameUpdateMode = ICFrameUpdateModeOnDemand;
 @endcode
 
 At a later point in your application code, when the render texture's contents are changed,
 you must call ICNode::setNeedsDisplay on the object that was changed. This tells the framework
 that the render texture's contents must be redrawn the next time its parent scene is rendered:
 
 @code
 // Assume we are at a position in your code where changing the position of the sprite in
 // the render texture's sub scene is required...
 
 // First, set the sprite's position:
 [mySprite setPositionX:10];
 
 // Now tell the framework to update the render texture's contents to reflect the sprite's
 // position change inside the render texture's framebuffer.
 [mySprite setNeedsDisplay];
 @endcode
 
 <h3>Nesting Render Textures</h3>
 
 ICRenderTexture objects may be nested in arbitrary sub scene graphs, which is particularly
 useful for implementing view hierarchies backed by OpenGL framebuffers. Nesting works out
 of the box, intuitively and without any further settings required:
 
 @code
 // Add a new render texture inside our existing one:
 ICRenderTexture *innerRenderTexture = [ICRenderTexture renderTextureWithWidth:120 height:20];
 [myRenderTexture addChild:innerRenderTexture];
 
 // Add contents to the inner render texture
 innerRenderTexture.subScene = [ICScene sceneWithHostViewController:self.hostViewController];
 ICSprite *anotherSprite = [ICSprite spriteWithTexture:anotherTexture];
 [innerRenderTexture addChild:anotherSprite];
 @endcode
 
 <h3>Depth and Stencil Buffers</h3>
 
 ICRenderTexture supports depth buffer and packed depth-stencil buffer attachments.
 There are a number of convenience initializers available you may use to create render
 textures with depth or depth-stencil buffer attachments:
 
 <ul>
    <li>ICRenderTexture::initWithWidth:height:depthBuffer: creates a default depth buffer
    attachment if depthBuffer is set to YES.</li>
    <li>ICRenderTexture::initWithWidth:height:depthBuffer:stencilBuffer: creates a default
    depth-stencil buffer if stencilBuffer is set to YES.</li>
    <li>ICRenderTexture::initWithWidth:height:pixelFormat:depthBufferFormat:stencilBufferFormat:
    allows you to exactly define the formats for each buffer.</li>
 </ul>
 
 Note that due to compatibility reasons, ICRenderTexture does only support stencil buffers
 as part of a packed depth-stencil buffer.
 
 <h3>Subclassing</h3>
 
 You may subclass ICRenderTexture to extend or customize the render texture's functionality.
 Subclasses providing customized initialization should override the
 ICRenderTexture::initWithWidth:height:pixelFormat:depthBufferFormat:stencilBufferFormat:
 method, which is the designated initializer of ICRenderTexture.
 */
@interface ICRenderTexture : ICPlanarNode <ICFramebufferProvider> {
@protected
	GLuint      _fbo;
	GLint		_oldFBO;
    GLint       _oldFBOViewport[4];
    GLuint      _depthRBO;
    GLuint      _stencilRBO;
    GLint       _oldRBO;
	ICTexture2D *_texture;
	ICSprite    *_sprite;
    ICScene     *_subScene;
	GLenum		_pixelFormat;
    GLenum      _depthBufferFormat;
    GLenum      _stencilBufferFormat;
    BOOL        _isInRenderTextureDrawContext;
    
    ICFrameUpdateMode _frameUpdateMode;
    
    BOOL _needsDisplay;
}

#pragma mark - Creating a Render Texture
/** @name Creating a Render Texture */

/**
 @brief Returns an autoreleased render texture initialized with the given width and height
 
 @sa initWithWidth:height:
 */
+ (id)renderTextureWithWidth:(float)w height:(float)h;

/**
 @brief Returns an autoreleased render texture initialized with the given width, height and
 and an optional depth buffer
 
 @sa initWithWidth:height:depthBuffer:
 */
+ (id)renderTextureWithWidth:(float)w height:(float)h depthBuffer:(BOOL)depthBuffer;

/**
 @brief Returns an autoreleased render texture initialized with the given width, height and
 and an optional stencil and/or depth buffer
 
 @sa initWithWidth:height:depthBuffer:stencilBuffer:
 */
+ (id)renderTextureWithWidth:(float)w
                      height:(float)h
                 depthBuffer:(BOOL)depthBuffer
               stencilBuffer:(BOOL)stencilBuffer;

/**
 @brief Returns an autoreleased render texture initialized with the given width, height,
 and pixel format
 
 @sa initWithWidth:height:pixelFormat:
 */
+ (id)renderTextureWithWidth:(float)w height:(float)h pixelFormat:(ICPixelFormat)format;

/**
 @brief Returns an autoreleased render texture initialized with the given width, height,
 pixel format and depth buffer format
 
 @sa initWithWidth:height:pixelFormat:depthBufferFormat:
 */
+ (id)renderTextureWithWidth:(float)w
                      height:(float)h
                 pixelFormat:(ICPixelFormat)pixelFormat
           depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat;

/**
 @brief Returns an autoreleased render texture initialized with the given width, height,
 pixel format, depth buffer format and stencil buffer format
 
 @sa initWithWidth:height:pixelFormat:depthBufferFormat:stencilBufferFormat:
 */
+ (id)renderTextureWithWidth:(float)w
                      height:(float)h
                 pixelFormat:(ICPixelFormat)pixelFormat
           depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
         stencilBufferFormat:(ICStencilBufferFormat)stencilBufferFormat;

/**
 @brief Initializes a render texture with the given width and height
 
 @param w The width of the texture in points
 @param h The height of the texture in points
 
 The render texture will be initialized with a color buffer backing only. Neither a depth buffer
 nor a stencil buffer will be attached. The render texture's pixel format will be set to
 ICPixelFormatDefault.
 */
- (id)initWithWidth:(float)w height:(float)h;

/**
 @brief Initializes a render texture with the given width and height and optionally attaches
 a default depth buffer
 
 @param w The width of the texture in points
 @param h The height of the texture in points
 @param depthBuffer A boolean flag indicating whether a depth buffer should be attached to the
 texture
 
 The render texture will be initialized with a default color buffer and, if depthBuffer is set
 to YES, with a default depth buffer. No stencil buffer will be attached.
 */
- (id)initWithWidth:(float)w height:(float)h depthBuffer:(BOOL)depthBuffer;

/**
 @brief Initializes a render texture with the given width and height and optionally attaches
 a default depth buffer and/or stencil buffer
 
 @param w The width of the texture in points
 @param h The height of the texture in points
 @param depthBuffer A boolean flag indicating whether a depth buffer should be attached to the
 texture
 @param stencilBuffer A boolean flag indicating whether a stencil buffer should be attached
 to the texture
 
 The render texture will be initialized with a default color buffer and, if depthBuffer is set
 to YES, with a default depth buffer. If stencilBuffer is set to YES, a default depth-stencil
 buffer will be created.
 
 @sa initWithWidth:height:pixelFormat:depthBufferFormat:stencilBufferFormat:
 */
- (id)initWithWidth:(float)w height:(float)h depthBuffer:(BOOL)depthBuffer stencilBuffer:(BOOL)stencilBuffer;

/**
 @brief Initializes a render texture with the given width, height, and pixel format
 
 @param w The width of the texture in points
 @param h The height of the texture in points
 @param format An ICPixelFormat enumerated type value indicating the texture's pixel format
 
 The render texture will be initialized with a color buffer backing only. Neither a depth buffer
 nor a stencil buffer will be attached.
 */
- (id)initWithWidth:(float)w height:(float)h pixelFormat:(ICPixelFormat)format;

/**
 @brief Initializes a render texture with the given width, height, pixel format, and depth
 buffer format
 
 @param w The width of the texture in points
 @param h The height of the texture in points
 @param pixelFormat An ICPixelFormat enumerated type value indicating the texture's pixel format
 @param depthBufferFormat An ICDepthBufferFormat enumerated type value defining the texture's
 depth buffer format
 
 The render texture will be initialized with a color and depth buffer. No stencil buffer will
 be attached.
 */
- (id)initWithWidth:(float)w
             height:(float)h
        pixelFormat:(ICPixelFormat)pixelFormat
  depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat;

/**
 @brief Initializes a render texture with the given width, height, pixel format, depth
 buffer format, and stencil buffer format
 
 @param w The width of the texture in points
 @param h The height of the texture in points
 @param pixelFormat An ICPixelFormat enumerated type value indicating the texture's pixel format
 @param depthBufferFormat An ICDepthBufferFormat enumerated type value defining the texture's
 depth buffer format
 @param stencilBufferFormat An ICStencilBufferFormat enumerated type value defining the texture's
 stencil buffer format
 
 The render texture will be initialized with a color, depth and stencil buffer as specified
 by the format arguments. Due to compatibility reasons, it is not possible to create a
 render texture with a stencil buffer if no depth buffer is attached. Therefore, if a
 stencil buffer format is defined, a packed depth-stencil buffer will be attached to the
 render texture. In this case, the depth format will default to ICDepthBufferFormat24 and
 the stencil buffer format will be ICStencilBufferFormat8.
 */
- (id)initWithWidth:(float)w
             height:(float)h
        pixelFormat:(ICPixelFormat)pixelFormat
  depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
stencilBufferFormat:(ICStencilBufferFormat)stencilBufferFormat;


#pragma mark - Obtaining the Associated Texture and Sprite
/** @name Obtaining the Associated Texture and Sprite */

/**
 @brief The texture object associated with the render texture node
 */
@property (nonatomic, readonly) ICTexture2D *texture;

/**
 @brief The sprite used to draw the texture on the framebuffer
 */
@property (nonatomic, readonly) ICSprite *sprite;


#pragma mark - Working with the Render Texture's Sub Scene
/** @name Working with the Render Texture's Sub Scene */

/**
 @brief The sub scene drawn into the render texture
 */
@property (nonatomic, retain, setter=setSubScene:) ICScene *subScene;


#pragma mark - Defining When to Update a Frame
/** @name Defining When to Update a Frame */

/**
 @brief A mode defining when to update the render texture's contents
 */
@property (nonatomic, assign) ICFrameUpdateMode frameUpdateMode;


#pragma mark - Managing the Render Texture's Size
/** @name Managing the Render Texture's Size */

/**
 @brief Sets the size of the render texture and automatically re-creates its buffers
 if necessary
 */
- (void)setSize:(kmVec3)size;

- (CGSize)textureSizeInPixels;

/**
 @brief The size of the receiver's framebuffer, in points
 */
- (CGSize)framebufferSize;



#pragma mark - Drawing to the Render Texture
/** @name Drawing to the Render Texture */

/**
 @brief Sets up the receiver's framebuffer for drawing
 
 This method saves the current framebuffer and viewport, then pushes identity projection and
 model-view matrices, binds the receiver's framebuffer and sets the render texture's viewport
 on the current OpenGL context. After this method has been called, you may use OpenGL commands
 to draw to the receiver's framebuffer. When drawing is finished, you must call
 ICRenderTexture::end in order to restore the old framebuffer, viewport and matrices.
 */
- (void)begin;

/**
 @brief Restores the old OpenGL framebuffer after drawing to the receiver's surface

 This method restores the framebuffer, viewport, projection and model-view matrices that were
 saved in a previous call to ICRenderTexture::begin.
 */
- (void)end;

/**
 @brief A boolean flag indicating whether the render texture's FBO is currently set as the
 OpenGL target framebuffer
 */
@property (nonatomic, readonly) BOOL isInRenderTextureDrawContext;


#pragma mark - Managing the Render Texture's Internal Matrices
/** @name Managing the Render Texture's Internal Matrices */

- (void)pushRenderTextureMatrices;

- (void)popRenderTextureMatrices;


#pragma mark - Reading Back Pixel Colors
/** @name Reading Back Pixel Colors */

/**
 @brief Reads the color of the pixel at the given location in the receiver's framebuffer
 */
- (icColor4B)colorOfPixelAtLocation:(CGPoint)location;

/**
 @brief Reads back pixels from the given rectangle
 */
- (void)readPixels:(void *)data inRect:(CGRect)rect;


#pragma mark - Retrieving the Render Texture's Plane
/** @name Retrieving the Render Texture's Plane */

/**
 @brief The receiver's plane in local coordinate space
 
 This method essentially returns the render texture's sprite plane.
 */
- (kmPlane)plane;

@end
