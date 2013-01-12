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

#import <Foundation/Foundation.h>

#import "ICNode.h"
#import "Platforms/icNS.h"
#import "icTypes.h"

@class ICNodeVisitor;
@class ICNodeVisitorDrawing;
@class ICNodeVisitorPicking;
@class ICCamera;
@class ICHostViewController;
@class ICRenderTexture;

/**
 @brief Defines the root of a scene graph, manages a camera and visitors for drawing nodes
 
 <h3>Overview</h3>
 
 The ICScene class defines a node that acts as the root of a scene graph by providing
 functionality that allows you to easily draw the scene's contents to a framebuffer.
 
 In particular, ICScene fulfills the following tasks:
 <ul>
    <li>Managing a scene camera (see ICCamera) that takes care of setting up the scene's
    projection and model-view matrices for presentation.</lI>
    <li>Setting up the scene's OpenGL states for drawing and picking.</li>
    <li>Managing visitors that are responsible for drawing and picking the
    scene's contents.</li>
    <li>Performing hit tests on the scene conveniently.</li>
    <li>Intelligently resizing the scene when its parent framebuffer size changes.</li>
 </ul>
 
 <h3>Root Scenes</h3>

 Scenes play a central role in the icedcoffee framework. In order to benefit from icedcoffee's
 event handling and user interface rendering capabilities, your application must provide at least
 one scene, called the root scene. The root scene represents the origin of all contents that
 are drawn on the OpenGL framebuffer of the host view that is managed by your application's
 host view controller (see ICHostViewController).
  
 <h3>Setting up a Root Scene</h3>
 
 You set up a root scene with a default camera by initializing ICScene using ICScene::init
 or ICScene::scene. You then define the scene's contents by adding nodes to it using
 ICNode::addChild:. Finally, as your scene is supposed to be the root scene of a host
 view in your application, you hand it to that host view controller using
 ICHostViewController::runWithScene:.
 
 <h3>Sub Scenes</h3>
 
 In addition to the root scene, you may add further scenes to your existing scene graph.
 However, when doing so, you should take care of the following conventions:
 <ol>
    <li>Scenes may be added as an immediate child of another scene. In this case, the sub
    scene inherits the framebuffer target of the parent scene and uses the parent scene's
    visitors to perform drawing and picking. Hit tests should always be performed on the
    parent scene in this scenario. Nesting scenes directly in each other may be useful to
    animate the camera of the sub scene without influencing the appearance of the nodes
    rendered by the parent scene, for instance.</li>
    <li>Scenes may be used by ICRenderTexture to present sub scenes on a framebuffer backed
    by a render texture. It is important to note that such sub scenes are not part of the
    scene graph's node hierarchy as ICRenderTexture disconnects them from the normal drawing
    mechanism of its parent scene. Instead these scenes act as the root scene of the
    render texture's framebuffer.</li>
    <li>Scenes may be added as immediate children of an ICView instance. This can be used
    to present a scene's contents in a user interface view with built-in clipping and
    layouting functionality. However, special rules apply for this kind of scene nesting.
    The nested scene will always have the size of the parent framebuffer. If the view is
    not backed by a render texture, this is the size of the host view's framebuffer.
    Consequently, the scene's children live in world coordinate space. If the so-nested
    scene's contents should be aligned to the parent view's origin on screen, you must
    perform the necessary transformations yourself. What is more, scenes nested this way
    may interfere with the parent view's clipping mechanism if they clear the stencil
    buffer. You should thus deactivate automatic stencil buffer clearing by setting the
    ICScene::clearsStencilBuffer property to <code>NO</code> for such kind of sub scenes.
 </ol>
 
 <h3>Setting up a Sub Scene</h3>
 
 You set up a sub scene exactly the way you set up a root scene, as described in "Setting
 up a Root Scene". The only difference is that you add the scene as a child of another node
 or set it as the ICRenderTexture::subScene property of a render texture.
 
 <h3>Scene Sizes and The Relation of Scenes to Framebuffers</h3>
 
 Newly initialized scenes have zero size until they are added to an existing scene graph
 or assigned to a host view controller. If you need a valid size for the scene in order to set
 up its contents, you should add it to your existing scene graph or assign it to a host view
 controller immediately after initialization.
 
 When a root scene is assigned to a host view controller, it immediately resizes itself so as
 to fit the size of the host view's OpenGL framebuffer in points.
 
 When a sub scene is added to an existing scene or set as the sub scene of a render texture,
 it immediately resizes itself to fit the size of its parent framebuffer. The parent frame
 buffer of a scene is defined by its first ancestor defining a render target, or, if no such
 node exists, the host view controller.
 
 When a scene is resized (explicitly or implicitly), it attempts to resize its descendant
 scenes to its own size, following the third convention described in "Sub Scenes". This does,
 however, not have an effect on descendant render texture sub scenes, since these are
 disconnected from the drawing mechanism of their parent scenes as discussed above.
 
 <h3>Standard Scenes (ICScene) versus User Interface Scenes (ICUIScene)</h3>
 
 Along with the standard scene implemented in the ICScene class, Icedcoffe provides a
 special subclass that is designed to host user interfaces, named ICUIScene. ICUIScene
 essentially provides a content view (ICView) child whose size is synchronized automatically
 with the UI scene's size. This allows for automatic resizing and layouting of the content
 view's subviews. See the ICUIScene documentation for more details.
 
 <h3>Subclassing</h3>
 
 You may subclass ICScene to create scenes with custom behavior and/or content. If you
 wish to implement a custom user interface scene, you should consider subclassing ICUIScene
 instead.

 Generally, the following points should be respected when subclassing ICScene:
 
 <ol>
    <li>ICScene's designated initializer is ICScene::initWithCamera:. You may override
    it to implement custom initialization. You may also set up predefined scene
    content in ICScene::initWithCamera:. However, remember that ICScene is initialized with zero
    size, so automatic positioning behaviors, implemented in e.g. ICNode::centerNode, will
    not work unless you define a size on your own.</li>
    <li>ICScene overrides ICNode::drawWithVisitor: to set up the scene for drawing or
    picking according to the type of the visitor that calls the method. Thus, you should
    call <code>[super drawWithVisitor:visitor]</code> if you override <code>drawWithVisitor:</code>
    in your subclass <i>before</i> performing any drawing operation. Likewise, if you override
    ICScene::childrenDidDrawWithVisitor:, you should call
    <code>[super childrenDidDrawWithVisitor:visitor];</code> <i>after</i> your custom code.</li>
    <li>If you need to customize scene setup and tear down you may override
    ICScene::setUpSceneForDrawingWithVisitor:, ICScene::tearDownSceneAfterDrawingWithVisitor:,
    ICScene::setUpSceneForPickingWithVisitor:, and ICScene::tearDownSceneAfterPickingWithVisitor:.</li>
    <li>ICScene overrides ICNode::setParent: in order to adjust its size to the parent
    framebuffer's size. If you override, setParent: call <code>[super setParent:parent]</code>
    before implementing your own code.</li>
    <li>ICScene overrides ICNode::setSize: to adjust its camera's viewport and resize
    descendant scenes. You need to call <code>[super setSize:size]</code> to preserve
    this behavior.</li>
 </ol>
 */
@interface ICScene : ICNode
{
@protected
    ICHostViewController *_hostViewController;
    ICCamera *_camera;
    
    ICNodeVisitorDrawing *_drawingVisitor;
    ICNodeVisitorPicking *_pickingVisitor;
    ICRenderTexture *_renderTexture;
    
    icColor4B _clearColor;
    BOOL _clearsColorBuffer;
    BOOL _clearsDepthBuffer;
    BOOL _clearsStencilBuffer;
    BOOL _performsDepthTesting;
    BOOL _performsFaceCulling;
    
    kmMat4 _matOldProjection;
    GLint _oldViewport[4];
}


#pragma mark - Creating a Scene
/** @name Creating a Scene */

/**
 @brief Returns an autoreleased scene object initialized with a default camera
 
 @sa init:
 */
+ (id)scene;

/**
 @brief Returns an autoreleased scene object initialized with the given camera
 
 @sa initWithCamera:
 */
+ (id)sceneWithCamera:(ICCamera *)camera;

/**
 @brief Initializes the receiver with a default camera
 
 This method initializes the receiver with a default camera as specified in #IC_DEFAULT_CAMERA.
 */
- (id)init;

/**
 @brief Initializes the receiver with the given camera
 */
- (id)initWithCamera:(ICCamera *)camera;


#pragma mark - Managing the Host View Controller
/** @name Managing the Host View Controller */

/**
 @brief The ICHostViewController object associated with the receiver
 */
@property (nonatomic, assign, getter=hostViewController, setter=setHostViewController:)
    ICHostViewController *hostViewController;


#pragma mark - Managing the Camera
/** @name Managing the Camera */

/**
 @brief An ICCamera object used to define the receiver's projection and model-view matrices
 */
@property (nonatomic, retain) ICCamera *camera;


#pragma mark - Working with Visitors and Render Textures
/** @name Working with Visitors and Render Textures */

/**
 @brief An ICNodeVisitor object defining the visitor used to draw the receiver's contents
 */
@property (nonatomic, retain) ICNodeVisitorDrawing *drawingVisitor;

/**
 @brief An ICNodeVisitor object defining the visitor used to perform hit tests on the receiver
 */
@property (nonatomic, retain) ICNodeVisitorPicking *pickingVisitor;

@property (nonatomic, assign) ICRenderTexture *renderTexture;


#pragma mark - Clearing the Scene's Framebuffer
/** @name Clearing the Scene's Framebuffer */

/**
 @brief An icColor4B value defining the clear color used to clear the receiver's framebuffer
 before drawing its contents
 */
@property (nonatomic, assign) icColor4B clearColor;

/**
 @brief A boolean value indicating whether the receiver automatically clears the color buffer
 before drawing its contents
 */
@property (nonatomic, assign) BOOL clearsColorBuffer;

/**
 @brief A boolean value indicating whether the receiver automatically clears the depth buffer
 before drawing its contents
 */
@property (nonatomic, assign) BOOL clearsDepthBuffer;

/**
 @brief A boolean value indicating whether the receiver automatically clears the stencil buffer
 before drawing its contents
 */
@property (nonatomic, assign) BOOL clearsStencilBuffer;


#pragma mark - Managing OpenGL-specific Scene Setup Properties
/** @name Managing OpenGL-specific Scene Setup Properties */

/**
 @brief A boolean flag indicating whether depth testing is performed by the receiver
 
 If depth testing is enabled, ICScene will clear the depth buffer contents and enable the
 ``GL_DEPTH_TEST`` state before drawing the scene's contents. The default value for this flag
 is ``NO``.
 */
@property (nonatomic, assign) BOOL performsDepthTesting;

/**
 @brief A boolean flag indicating whether face culling is performed by the receiver

 If face culling is enabled, ICScene will enable the ``GL_CULL_FACE`` state before drawing the
 scene's contents. The default value for this flag is ``YES``.
 */
@property (nonatomic, assign) BOOL performsFaceCulling;


#pragma mark - Checking the Scene's Status
/** @name Checking the Scene's Status */

/**
 @brief Returns a boolean flag indicating whether the receiver is the root scene
 
 The receiver is a root scene if it has been assigned to a host view controller and does
 not have a parent node.
 */
- (BOOL)isRootScene;


#pragma mark - Drawing the Scene
/** @name Drawing the Scene */

/**
 @brief Sets up the drawing environment for the receiver before drawing
 */
- (void)setUpSceneForDrawingWithVisitor:(ICNodeVisitorDrawing *)visitor;

/**
 @brief Resets the drawing environment of the receiver after drawing
 */
- (void)tearDownSceneAfterDrawingWithVisitor:(ICNodeVisitorDrawing *)visitor;

/**
 @brief Sets up the drawing environment for the receiver before picking
 */
- (void)setUpSceneForPickingWithVisitor:(ICNodeVisitorPicking *)visitor;

/**
 @brief Resets the drawing environment of the receiver after picking
 */
- (void)tearDownSceneAfterPickingWithVisitor:(ICNodeVisitorPicking *)picking;

/**
 @brief Sets up the receiver's drawing environment, draws all its contents using the
 drawing visitor, and finally tears down the scene's drawing environment
 */
- (void)visit;


#pragma mark - Performing Hit Tests
/** @name Performing Hit Tests */

/**
 @brief Performs a hit test on the receiver's node hierarchy
 
 Sets up the receiver's picking environment, performs a synchronous hit test using the picking
 visitor (see ICScene::pickingVisitor), and finally tears down the receiver's picking environment.
 
 @param point A 2D location on the framebuffer in points (Y axis points downwards)
 
 @return Returns an NSArray containing the ICNode objects that passed the hit test. If one or
 multiple nodes pass the hit test, the last object in the returned array represents the "final
 hit", the node that visually appears as the front-most object to the user (incorporating depth
 and stencil tests). If no nodes pass the hit test, an empty array is returned.
 */
- (NSArray *)hitTest:(CGPoint)point;

/**
 @brief Performs a hit test on the receiver's node hierarchy
 
 Sets up the receiver's picking environment, performs a hit test using the picking
 visitor (see ICScene::pickingVisitor), and finally tears down the receiver's picking environment.
 
 @param point A 2D location on the framebuffer in points (Y axis points downwards)
 @param deferredReadback (Mac OS X only.) A boolean flag indicating whether the hit test's
 results should be readback asynchronously. If set to YES, you must use
 ICScene::performHitTestReadback to obtain the hit test's results at a later point in time.
 Note that asynchronous readbacks are available only if the OpenGL hardware supports pixel
 buffer objects.
 
 @return If deferredReadback is set to NO, returns an NSArray containing the ICNode objects that
 passed the hit test. If one or multiple nodes pass the hit test, the last object in the returned
 array represents the "final hit", the node that visually appears as the front-most object to the
 user (incorporating depth and stencil tests). If no nodes pass the hit test, an empty array is
 returned. If deferredReadback is set to YES, this method always returns nil.
 */
- (NSArray *)hitTest:(CGPoint)point deferredReadback:(BOOL)deferredReadback;

/**
 @brief Performs an asynchronous readback for the previous hit test and returns the corresponding
 hit nodes
 
 This method should be called after performing a picking test with deferred readback using
 ICScene::hitTest:point:deferredReadback: to perform the actual readback on the picking visitor's
 render texture and return the corresponding hit nodes.
 
 @return Returns an NSArray containing ICNode objects representing the nodes that passed the
 picking test. If no nodes passed the test, an empty array is returned. If one or more nodes
 passed the test, the last object in the array always represents the final hit. The final hit is
 defined as the node that visually appears to the user as the front-most object at the pick point
 given to the receiver. If that node is part of a hierarchy of drawable nodes, it is simultaneously
 the "deepest" node of that hierarchy which has passed the picking test.
 
 @remarks Asynchronous readbacks are only available on Mac OS X and if the graphics hardware
 supports OpenGL pixel buffer objects. See 
 ICNodeVisitorPicking::performPickingTestWithNode:point:viewport:deferredReadback:.
 */
- (NSArray *)performHitTestReadback;

/**
 @brief Computes a ray in world coordinates for the given framebuffer location using the
 receiver's camera
 */
- (icRay3)worldRayFromFramebufferLocation:(CGPoint)location;


#pragma mark - Managing the Scene's Size
/** @name Managing the Scene's Size */

/**
 @brief Sets the size of the receiver, adjusts the viewport of the camera and sets the size of
 descendant scenes to the specified value
 */
- (void)setSize:(kmVec3)size;

/**
 @brief Adjusts the receiver's size to the size of its parent framebuffer
 */
- (void)adjustToFramebufferSize;

- (CGRect)frameRect;

/**
 @brief Returns the size of the receiver's parent framebuffer in points
 */
- (CGSize)framebufferSize;

@end
