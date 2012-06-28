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

#import "ICNode.h"
#import "Platforms/icNS.h"
#import "icTypes.h"

@class ICNodeVisitor;
@class ICCamera;
@class ICHostViewController;

/**
 @brief Defines the root of a scene graph, manages a camera and visitors for drawing the scene
 
 <h3>Overview</h3>
 
 The ICScene class defines a node that acts as the root of a scene graph by providing
 functionality that allows you to easily draw the scene's contents to a frame buffer.
 
 In particular, ICScene fulfills the following tasks:
 <ul>
    <li>Managing a scene camera (see ICCamera) that takes care of setting up the scene's
    projection and model-view matrices for presentation.</lI>
    <li>Setting up the scene's OpenGL states for drawing and picking.</li>
    <li>Managing visitors that are responsible for drawing and picking the
    scene's contents.</li>
    <li>Performing hit tests on the scene conveniently.</li>
    <li>Intelligently resizing the scene when its parent frame buffer size changes.</li>
 </ul>
 
 <h3>Root Scenes</h3>

 Scenes play a central role in the IcedCoffee framework. In order to benefit from IcedCoffee's
 event handling and user interface rendering capabilities, your application must provide at least
 one scene, called the root scene. The root scene represents the origin of all contents that
 are drawn on the OpenGL frame buffer of the host view that is managed by your application's
 host view controller (see ICHostViewController).
  
 <h3>Setting up a Root Scene</h3>
 
 You set up a root scene with a default camera by initializing ICScene using ICScene::init
 or ICScene::scene. You then define the scene's contents by adding nodes to it using
 ICNode::addChild:. Finally, as your scene is supposed to be the root scene of a host
 view in your application, you hand it to that host view controller using
 ICHostViewController::runWithScene:.
 
 <h3>Sub Scenes</h3>
 
 In addition to the root scene, you may add furhter scenes to your existing scene graph.
 However, when doing so, you should take care of the following conventions:
 <ol>
    <li>Scenes may be added as an immediate child of another scene. In this case, the sub
    scene inherits the frame buffer target of the parent scene and uses the parent scene's
    visitors to perform drawing and picking. Hit tests should always be performed on the
    parent scene in this scenario. Nesting scenes directly in each other may be useful to
    animate the camera of the sub scene without influencing the appearance of the nodes
    rendered by the parent scene, for instance.</li>
    <li>Scenes are used by ICRenderTexture to present sub scenes on a frame buffer backed
    by a render texture. It is important to note that such sub scenes are not part of the
    scene graph's node hierarchy as ICRenderTexture disconnects them from the normal drawing
    mechanism of its parent scene. Instead these scenes act as the root scene of the
    render texture's frame buffer.</li>
    <li>Scenes may be added as immediate children of an ICView instance. This can be used
    to present a scene's contents in a user interface view with built-in clipping and
    layouting functionality. However, special rules apply for this kind of scene nesting.
    The nested scene will always have the size of the parent frame buffer. If the view is
    not backed by a render texture, this is the size of the host view's frame buffer.
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
 
 <h3>Scene Sizes and The Relation of Scenes to Frame Buffers</h3>
 
 Newly initialized scenes have zero size until they are added to an existing scene graph
 or assigned to a host view controller. If you need a valid size for the scene in order to set
 up its contents, you should add it to your existing scene graph or assign it to a host view
 controller immediately after initialization.
 
 When a root scene is assigned to a host view controller, it immediately resizes itself so as
 to fit the size of the host view's OpenGL frame buffer in points.
 
 When a sub scene is added to an existing scene or set as the sub scene of a render texture,
 it immediately resizes itself to fit the size of its parent frame buffer. The parent frame
 buffer of a scene is defined by its first ancestor defining a render target, or, if no such
 node exists, the host view controller.
 
 When a scene is resized (explicitly or implicitly) it attempts to resize its descendant
 scenes to its own size, following the third convention described in "Sub Scenes". This does,
 however, not have an effect on descendant render texture sub scenes, since these are
 disconnected from the drawing mechanism of their parent scenes as discussed above.
 
 <h3>Standard Scenes (ICScene) versus User Interface Scenes (ICUIScene)</h3>
 
 Along with the standard scene implemented in the ICScene class, IcedCoffe provides a
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
    <li>ICScene's designated initializer is ICScene::init. You may override <code>init</code>
    to implement custom initialization. For instance, you may set a different camera or
    different visitors by default in your subclass. You may also set up predefined scene
    content in <code>init</code>, however, remember that ICScene is initialized with zero
    size, so automatic positioning behaviors implement in e.g. ICNode::centerNode will
    not work unless you define a size on your own.</li>
    <li>ICScene overrides ICNode::drawWithVisitor: to set up the scene for drawing or
    picking according to the type of the visitor that calls the method. Thus, you should
    call <code>[super drawWithVisitor:visitor]</code> if you override <code>drawWithVisitor:</code>
    in your subclass <i>before</i> performing any drawing operation. Likewise, if you override
    ICScene::childrenDidDrawWithVisitor:, you should call
    <code>[super childrenDidDrawWithVisitor:visitor];</code> <i>after</i> your custom code.</li>
    <li>If you need to customize scene setup and tear down you may override
    ICScene::setUpSceneForDrawing, ICScene::tearDownSceneForDrawing,
    ICScene::setUpSceneForPickingWithPoint:, and ICScene::tearDownSceneForPicking.</li>
    <li>ICScene overrides ICNode::setParent: in order to adjust its size to the parent
    frame buffer's size. If you override, setParent: call <code>[super setParent:parent]</code>
    before implementing your own code.</li>
    <li>ICScene overrides ICNode::setSize: to adjust its camera's viewport and resize
    descendant scenes. You need to call <code>[super setSize:size]</code> to preserve
    this behavior.</li>
 </ol>
 */
@interface ICScene : ICNode
{
@private
    ICHostViewController *_hostViewController;
    ICCamera *_camera;
    
    ICNodeVisitor *_drawingVisitor;
    ICNodeVisitor *_pickingVisitor;
    
    icColor4B _clearColor;
    BOOL _clearsColorBuffer;
    BOOL _clearsDepthBuffer;
    BOOL _clearsStencilBuffer;
    BOOL _performsDepthTesting;
    BOOL _performsFaceCulling;
    
    kmMat4 _matOldProjection;
}

/**
 @brief The ICHostViewController object associated with the scene
 */
@property (nonatomic, assign, getter=hostViewController, setter=setHostViewController:)
    ICHostViewController *hostViewController;

/**
 @brief An ICCamera object used to define the scene's projection and model-view matrices
 */
@property (nonatomic, retain) ICCamera *camera;

/**
 @brief An ICNodeVisitor object defining the visitor used to draw the scene's contents
 */
@property (nonatomic, retain) ICNodeVisitor *drawingVisitor;

/**
 @brief An ICNodeVisitor object defining the visitor used to perform hit tests on the scene
 */
@property (nonatomic, retain) ICNodeVisitor *pickingVisitor;

/**
 @brief An icColor4B value defining the clear color used to clear the scene's frame buffer
 before drawing its contents
 */
@property (nonatomic, assign) icColor4B clearColor;

/**
 @brief A boolean value indicating whether the scene automatically clears the color buffer
 before drawing its contents
 */
@property (nonatomic, assign) BOOL clearsColorBuffer;

/**
 @brief A boolean value indicating whether the scene automatically clears the depth buffer
 before drawing its contents
 */
@property (nonatomic, assign) BOOL clearsDepthBuffer;

/**
 @brief A boolean value indicating whether the scene automatically clears the stencil buffer
 before drawing its contents
 */
@property (nonatomic, assign) BOOL clearsStencilBuffer;

/**
 @brief A boolean flag indicating whether depth testing is performed
 
 If depth testing is enabled, ICScene will clear the depth buffer contents and enable the
 GL_DEPTH_TEST state before drawing the scene's contents. The default value for this flag is NO.
 */
@property (nonatomic, assign) BOOL performsDepthTesting;

/**
 @brief A boolean flag indicating whether face culling is performed

 If face culling is enabled, ICScene will enable the GL_CULL_FACE state before drawing the
 scene's contents. The default value for this flag is YES.
 */
@property (nonatomic, assign) BOOL performsFaceCulling;

/**
 @brief Returns an autoreleased scene object initialized with a default camera and
 default visitors
 
 @sa init:
 */
+ (id)scene;

/**
 @brief Initializes the receiver with a default camera and default visitors.
 
 This method initializes the receiver with a default camera as specified
 in #ICDEFAULT_CAMERA, a default drawing visitor as specified in ICDEFAULT_DRAWING_VISITOR,
 and a default picking visitor as specified in ICDEFAULT_PICKING_VISITOR.
 */
- (id)init;

/**
 @brief Sets up the drawing environment for the scene before drawing
 */
- (void)setUpSceneForDrawing;

/**
 @brief Resets the drawing environment of the scene after drawing
 */
- (void)tearDownSceneForDrawing;

/**
 @brief Sets up the drawing environment for the scene before picking
 */
- (void)setupSceneForPickingWithPoint:(CGPoint)point viewport:(GLint *)viewport;

/**
 @brief Resets the drawing environment of the scene after picking
 */
- (void)tearDownSceneForPicking;

/**
 @brief Sets up the scene's drawing environment, draws all its contents using the drawing visitor,
 and finally tears down the scene's drawing environment
 */
- (void)visit;

/**
 @brief Performs a hit test on the scene's node hierarchy
 
 Sets up the scene's picking environment, performs a hit test using the picking visitor,
 and finally tears down the scene's picking environment.
 
 @param point A 2D location on the frame buffer in points
 
 @return Returns an NSArray containing all ICNode objects that passed the hit test, beginning
 with the respective top-most node rendered to the frame buffer.
 */
- (NSArray *)hitTest:(CGPoint)point;

/**
 @brief Sets the size of the scene, adjusts the viewport of the camera and sets the size of
 descendant scenes to the specified value
 */
- (void)setSize:(kmVec3)size;

/**
 @brief Adjusts the scene's size to the size of its parent frame buffer
 */
- (void)adjustToFrameBufferSize;

- (CGRect)frameRect;

/**
 @brief Returns the size of the parent frame buffer in points
 */
- (CGSize)frameBufferSize;

@end
