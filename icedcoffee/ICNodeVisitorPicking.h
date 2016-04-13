//  
//  Copyright (C) 2016 Tobias Lensing, Marcus Tillmanns
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

#ifdef __IC_PLATFORM_IOS
#import <CoreGraphics/CoreGraphics.h>
#elif __IC_PLATFORM_MAC
#import <QuartzCore/QuartzCore.h>
#endif

#import "ICNodeVisitorDrawing.h"
#import "ICPickContext.h"
#import "icTypes.h"

#define IC_PICK_COLOR_RESOLUTION                255.0f
#define IC_DEFAULT_PICKING_RT_SIZE_IN_PIXELS    CGSizeMake(256,256)

@class ICRenderTexture;
@class ICScene;
@class ICOpenGLContext;

/**
 @brief Node visitor for color-based picking using GLSL shaders
 
 The ICNodeVisitorPicking class implements a node visitor for picking nodes on a scene graph
 at a given point location on an OpenGL framebuffer. It may be used to effectively perform
 hit tests that return all nodes drawn to the given point location, taking into account depth
 and stencil tests.
 
 The mechanism implemented in this class basically works as follows. First, for each visited node,
 a ray-based hit test is performed if this is supported by the given node. If this hit test
 succeeds, the visitor draws a pixel of the node's shape at the given pick point in a unique solid
 color using a special picking shader. If a node's shape lies under the pick point, the pixel's
 color is overwritten with the node's unique pick color. Otherwise, the pixel's color does not
 change, indicating that the node does not lie under the pick point. The visitor draws these pixels
 to an offscreen framebuffer, so they are not visible to the user. Finally, it reads back all
 pixels from that framebuffer and resolves them to the corresponding ICNode objects.
 
 ICNodeVisitorPicking represents a fairly powerful and elegant solution for picking. In contrast
 to other color-based picking solutions, it allows you to retrieve all nodes under a given pick
 point, even if they are covered by other nodes or contained in an ICRenderTexture sub scene.
 Along with the list of nodes that lie under the point, the class always delivers a final hit node,
 the node that ultimately appears to the user as the visual node under the pick point. It does so
 correctly even if depth tests and/or stencil tests are involved in the drawing process and it
 requires no or relatively little work to be integrated with new drawable nodes.
 
 The following characteristics and limitations should be remembered when working with this class:
 
  * A render texture is used as an offscreen framebuffer for collecting pick colors for each node.
    The size of that render texture determines the capacity of the picking visitor. In other words,
    you may run into problems if your scene has more nodes than the visitor's render texture has
    pixels. The default size of the render texture is set to 256x256 pixels, yielding a total
    capacity of 65535 nodes. (One pixel is reserved for determining the final hit.)
  * The visitor uses OpenGL scissor tests to limit rendering to one pixel of its render texture.
    This means that, if the picking visitor is used, scissor tests cannot be employed for drawing.
  * The visitor assumes the given node hierarchy to be static for the duration of a call to
    ICNodeVisitorPicking::visit:. That is, you must not add, move or remove nodes while the
    hierarchy is being visited for picking. If you still do so, the picking result may be
    incorrect.
  * For performance reasons, the visitor attempts to perform a preliminary ray-based hit test
    on each node by calling ICNode::localRayHitTest:. If a node supports such hit test, it must
    implement this method to compute whether the given ray intersects with the node's
    (approximated) geometry. If a node does not support the ray-based hit test, it must return
    ICHitTestUnsupported in order to indicate that the visitor should perform a color-based
    picking test even though no ray-based hit test succeeded.
 
 */
@interface ICNodeVisitorPicking : ICNodeVisitorDrawing {
@protected
    uint32_t _nodeIndex;
    uint32_t _nodeCount;
    ICRenderTexture *_renderTexture;
    CGSize _renderTextureSizeInPixels;
    void *_clientData;
    NSMutableArray *_pickNodes;
    NSMutableArray *_pickContextStack;
    NSMutableArray *_rayStack;
    GLint _viewport[4];
    int _internalMode;
    BOOL _usesAuxiliaryOpenGLContext;
    GLuint _pbo;
    BOOL _asyncReadbackIssued;
    
    ICOpenGLContext *_auxGLContext;
}

#pragma mark - Initializing a Picking Node Visitor
/** @name Initializing a Picking Node Visitor */

/**
 @brief Initializes the receiver with the given owner node

 Calls ICNodeVisitorPicking::initWithOwner:useAuxiliaryOpenGLContext: internally, with the
 ``useAuxiliaryOpenGLContext`` parameter set to ``YES``.
 
 @sa initWithOwner:useAuxiliaryOpenGLContext:
 */
- (id)initWithOwner:(ICNode *)owner;

/**
 @brief Initializes the receiver with the given owner node
 
 The owner is assigned to the receiver for its complete lifecycle. The receiver does not retain
 the owner so as to avoid retain cycles. It is the responsibility of the visitor's owner to
 deallocate the visitor before the owner is deallocated.
 
 @param owner An ICNode object representing the receiver's owner. You may specifiy ``nil`` for this
 parameter to indicate that the receiver does not have an owner.
 @param useAuxiliaryContext If set to ``YES``, creates and uses an auxiliary OpenGL context for
 drawing to the visitor's render texture. This should always be set to ``YES`` for maximum
 performance.
 */
- (id)initWithOwner:(ICNode *)owner useAuxiliaryOpenGLContext:(BOOL)useAuxContext;


#pragma mark - Using an Auxiliary OpenGL Context
/** @name Using an Auxiliary OpenGL Context */

/**
 @brief A boolean flag indicating whether the receiver uses an auxiliary OpenGL context for picking
 */
@property (nonatomic, readonly) BOOL usesAuxiliaryOpenGLContext;


#pragma mark - Managing the Visitor's Render Texture
/** @name Managing the Visitor's Render Texture */

/**
 @brief The receiver's render texture size in pixels
 */
@property (nonatomic, assign, setter=setRenderTextureSizeInPixels:) CGSize renderTextureSizeInPixels;

/**
 @brief Returns the number of pixels of the receiver's render texture
 */
- (uint)renderTextureCapacity;

/**
 @brief Returns the size of the receiver's render texture surface in bytes
 */
- (uint)renderTextureMemorySize;


#pragma mark - Using the Pick Context Stack
/** @name Using the Pick Context Stack */

/**
 @brief Pushes the given pick context to the receiver's pick context stack
 */
- (void)pushPickContext:(ICPickContext *)pickContext;

/**
 @brief Pops the top of the receiver's pick context stack
 */
- (void)popPickContext;

/**
 @brief Returns the top pick context of the receiver's pick context stack
 */
- (ICPickContext *)currentPickContext;

/**
 @brief Returns the top pick point of the receiver's pick context stack
 */
- (CGPoint)currentPickPoint;

/**
 @brief Returns the top pick viewport of the receiver's pick context stack
 */
- (GLint *)currentViewport;


#pragma mark - Using the Ray Stack
/** @name Using the Ray Stack */

/**
 @brief Pushes a ray to the receiver's ray stack
 */
- (void)pushRay:(icRay3)ray;

/**
 @brief Pops the top ray of the receiver's ray stack
 */
- (void)popRay;

/**
 @brief Returns the current top ray of the receiver's ray stack
 */
- (icRay3 *)currentRay;


#pragma mark - Performing Picking Tests
/** @name Performing Picking Tests */

/**
 @brief Performs a picking test and returns the resulting nodes
 
 This method performs a picking test on the scene graph rooted in the given node. It returns all
 nodes that pass a ray-based hit test and are drawn at the specified point. The last object in
 the returned array always corresponds to the node perceived as the front-most object by the user.
 
 @param node The root node to start visitation with. The receiver traverses the whole branch of
 the node to collect picking results. This usually is an ICScene object.
 @param point The location to be used for picking, in points.
 @param viewport The OpenGL viewport to be used for picking.
 @param deferredReadback (Mac OS X only.) If pixel buffer objects are supported by the OpenGL
 hardware, issues an asynchronous glReadPixels command and defers the actual readback of pixels
 to a later point in time. You should use ICNodeVisitorPicking::readHitNodesAsync to perform
 the deferred readback and retrieve the corresponding hit nodes. If this parameter is set to YES,
 the method always returns nil.
  
 @return If deferredReadback is set to NO, returns an NSArray containing ICNode objects
 representing the nodes that passed the picking test. If no nodes passed the test, an empty array
 is returned. If one or more nodes passed the test, the last object in the array always represents
 the final hit. The final hit is defined as the node that visually appears to the user as the
 front-most object at the pick point given to the receiver. If that node is part of a hierarchy
 of drawable nodes, it is simultaneously the "deepest" node of that hierarchy which has passed
 the picking test. If deferredReadback is set to YES, the method always returns nil.
  */
- (NSArray *)performPickingTestWithNode:(ICNode *)node
                                  point:(CGPoint)point
                               viewport:(GLint *)viewport
                       deferredReadback:(BOOL)deferredReadback;

/**
 @brief Performs an asynchronous readback operation and returns the corresponding hit nodes
 
 This method should be called after performing a picking test with deferred readback using
 ICNodeVisitorPicking::performPickingTestWithNode:point:viewport:deferredReadback: to perform
 the actual readback on the visitor's render texture and return the corresponding hit nodes.
 
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
- (NSArray *)readHitNodesAsync;

/**
 @brief Returns the pick color of the node which is currently being visited by the receiver
 */
- (icColor4B)pickColor;

@end
