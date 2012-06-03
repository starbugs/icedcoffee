//  
//  Copyright (C) 2012 Tobias Lensing, http://icedcoffee-framework.org
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
 @brief Defines the root of a scene graph, manages its camera and visitors
 
 <h3>Overview</h3>
 The ICScene class defines the root of a scene graph composed of one or multiple ICNode
 objects. An ICScene instance is always associated with an ICHostViewController object.
 Scene objects may be nested, that is one scene graph rooted in ICScene may contain
 another sub scene graph rooted in another (descendant) ICScene object. This is
 particularly useful for implementing multiple scenes, each with an own camera and
 event flow.
 
 The most important features of ICScene are listed as follows:
 <ul>
    <li><b>Camera</b>: ICScene manages a camera object that is used to project the scene's
    contents on the framebuffer.</li>
    <li><b>Visitation</b>: ICScene provides two built-in default visitors for drawing
    and picking. The default drawing visitor is implemented in ICNodeVisitorDrawing,
    the default picking visitor is implemented in ICNodeVisitorPicking.</li>
    <li><b>Hit testing</b>: ICScene provides a method for performing hit tests on its
    scene graph. Hit tests are implemented using the picking visitor.</li>
 </ul>
 
 <h3>Using ICScene</h3>
 
 An ICScene object is manadatory if you wish to exploit IcedCoffee's internal drawing,
 hit testing and event management facilities.
 
 You instanciate an ICScene object by using the ICSCene::sceneWithHostViewController: convenience
 initializer. This class method returns an autoreleased instance bound to the given
 ICHostViewController. The returned instance is equipped with a default camera as defined
 in #ICDEFAULT_CAMERA. After instanciating an ICScene object, you may add nodes to the scene using
 the ICNode::addChild: method. Finally, you run the scene using  the
 ICHostViewController::runWithScene: method.
 
 <h3>Lifecycle</h3>
 
 When initializing an ICScene object with a given ICHostViewController instance, the
 host view controller object is assigned to the hostViewController property of the scene.
 Notice that ICScene does not retain the given ICHostViewController object on initialization.
 
 When running a scene on the ICHostViewController instance using the ICScene::runWithScene: method,
 the ICScene object is retained by the host view controller. ICHostViewController will 
 release the scene either if another scene is being run or the lifecycle of ICHostViewController
 ends.
 
 If you plan to work with multiple scenes, you should retain the created ICScene instances
 on your own, preferrably at some point in your application controller or in your custom
 ICHostViewController subclass.
 
 <h3>Subclassing</h3>
 
 You should consider subclassing ICScene as a standard pattern to build up and manage your
 custom scenes. Although this is not strictly required, it improves the structure of your
 code. If you choose to do so, you should override the ICScene::initWithHostViewController:camera:
 method to implement code required to build up your custom scene. If you require quick access to
 important nodes on your scene, you may add them as properties to your subclass. If you
 do so, it is recommended to retain these nodes as long as they are needed in your scene
 and release them in the dealloc method of your subclass.
 
 Subclassing ICScene is required if you plan to override or extend its default behavior.
 The following is a list of the most important points to remember when subclassing ICScene:
 <ul>
    <li>ICScene::initWithHostViewController:camera: is the designated initializer of the ICScene
    class. If you require custom initialization, you should override this method.</li>
    <li>You may customize the way scenes are set up and torn down by overriding the
    setUpSceneForDrawing, tearDownSceneForDrawing, setUpSceneForPickingWithPoint:viewport:,
    and tearDownSceneForPicking methods.</li>
    <li>You may implement custom hit testing by choosing another (custom) ICNodeVisitor
    class for drawing and/or picking, and/or by overriding the hitTest: method.</li>
 </ul>
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
}

/**
 @brief The ICHostViewController object associated with the scene
 */
@property (nonatomic, readonly, getter=hostViewController) ICHostViewController *hostViewController;

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

@property (nonatomic, assign) BOOL clearsColorBuffer;

@property (nonatomic, assign) BOOL clearsDepthBuffer;

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
 @brief Returns an autoreleased scene associated with the given ICHostViewController object
 @sa initWithHostViewController:
 */
+ (id)sceneWithHostViewController:(ICHostViewController *)hostViewController;

/**
 @brief Returns an autoreleased scene associated with the given ICHostViewController object
 and sets the specified camera on it
 @sa initWithHostViewController:camera:
 */
+ (id)sceneWithHostViewController:(ICHostViewController *)hostViewController
                           camera:(ICCamera *)camera;

/**
 @brief Initializes the scene and associates it with the given ICHostViewController object
 
 A default camera is instanciated and set as specified in #ICDEFAULT_CAMERA.
 */
- (id)initWithHostViewController:(ICHostViewController *)hostViewController;

/**
 @brief Initializes the scene, associates it with the given ICHostViewController object and
 sets the specified camera
 */
- (id)initWithHostViewController:(ICHostViewController *)hostViewController
                          camera:(ICCamera *)camera;

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
 @brief Sets up the scene's drawing environment, draws all its contents using the drawing visitor,
 and finally tears down the scene's drawing environment
 */
- (void)visit;

/**
 @brief Sets up the scene's drawing environment, draws the given node using the drawing visitor,
 and finally tears down the scene's drawing environment
 */
- (void)visitNode:(ICNode *)node;

/**
 @brief Performs a hit test on the scene's node hierarchy
 
 Sets up the scene's picking environment, performs a hit test using the picking visitor,
 and finally tears down the scene's picking environment.
 
 @param point A 2D location on the frame buffer in points
 
 @return Returns an NSArray containing all ICNode objects that passed the hit test, beginning
 with the respective top-most node rendered to the frame buffer.
 */
- (NSArray *)hitTest:(CGPoint)point;

- (CGRect)frameRect;

/**
 @brief Returns the size of the parent frame buffer in points
 */
- (CGSize)frameBufferSize;

@end
