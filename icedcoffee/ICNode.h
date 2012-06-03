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
#import "kazmath/kazmath.h"
#import "Platforms/icGL.h"

#import "ICResponder.h"
#import "ICNodeVisitor.h"

#import "icConfig.h"

@class ICNodeVisitor;
@class ICShaderProgram;
@class ICScene;
@class ICHostViewController;

/**
 @brief Base class for drawable nodes in a scene
 
 <h3>Overview</h3>
 
 The ICNode class represents a drawable object on a scene graph. A scene graph is usually rooted
 in an ICScene object. Each node has an array of child nodes and a reference to its parent node.
 
 A node has a transform matrix used to transform coordinates from parent space to its own
 local space. Nodes provide convenience methods for manipulating their transform matrix based
 on ICNode::position, ICNode::scale, rotation (ICNode::getRotationAngle:axis:,
 ICNode::setRotationAngle:axis:) and ICNode::anchorPoint properties. Furthermore, nodes provide
 methods for calculating inverse and world transforms.
 
 Nodes have implicit order, that is, their order is defined by the index they occupy in their
 parent's children array. ICNode provides convenience methods for manipulating this order, e.g.
 ICNode::orderFront, ICNode::orderForward, ICNode::orderBackward and ICNode::orderBack.
 
 Visitors are used to traverse a given scene graph for drawing on a frame buffer. A visitor is
 an external object of class ICNodeVisitor. The framework ships with two built-in visitor classes,
 ICNodeVisitorDrawing for drawing nodes on screen and ICNodeVisitorPicking for drawing nodes
 on an invisible framebuffer for picking.
 
 Since IcedCoffee is based on GLES2, each node uses shader programs for drawing. Shader programs
 are managed using the ICShaderProgram and ICShaderCache classes.
 
 Nodes provide the basis for user interaction event handling for mice, touch, and keyboard
 devices. Event handling is implemented on top of the scene graph in the ICScene, ICResponder, and
 ICHostViewController classes amongst others.

 <h3>Subclassing</h3>
 
 ICNode may be subclassed to implement custom nodes. Most likely, you will want to implement
 custom drawing and/or custom event handling (based on ICResponder.)
 
 <h4>Custom Drawing</h4>
 
 <ul>
    <li>ICNode's designated initializer is ICNode::init. You should override ICNode::init
    to implement custom initialization on top of ICNode.</li>
    <li>Set a custom shader program in the subclasses' initializer if necessary.</li>
    <li>ICNode::drawWithVisitor: is called by the framework when the node needs to be drawn into
    a framebuffer. It is used for both drawing and picking.</li>
    <li>When you override ICNode::drawWithVisitor:, first check whether the node is visible and
    skip any drawing if it is not.</li>
    <li>IcedCoffee does by default provide two different visitors. ICNodeVisitorDrawing is
    used for rendering objects on screen while ICNodeVisitorPicking is used to draw objects
    on an internal picking frame buffer. ICNode provides a standard way of setting up shaders
    for drawing and picking. Hence, after checking for visibility, you should call
    ICNode::applyStandardDrawSetupWithVisitor: . This will automatically activate the node's shader
    program for drawing or the default picker shader program for picking.</li>
    <li>You may implement custom picking shapes or optimized drawing code for picking by checking
    the class of the visitor object given when ICNode::drawWithVisitor: is called. If visitor is
    kind of class ICNodeVisitorDrawing, provide code to draw the object's visible shape on screen.
    If visitor is kind of class ICNodeVisitorPicking, provide code to draw the object's
    pickable shape.</li>
    <li>You may also implement your drawing code without taking care of picking. In this
    case the framework will automatically use the object's drawn shape as a picking shape
    provided that you employ ICNode::applyStandardDrawSetupWithVisitor: to set up drawing.</li>
 </ul>
 
 <h4>Custom Event Handling</h4>
 
 <ul>
    <li>Event handling is based on the ICResponder super class. You implement event handlers
    by overriding one of the event handler methods defined there, e.g. by implementing
    ICResponder::mouseDown:. You may override both touch and mouse event handler methods in one
    ICNode subclass. On Mac OS X the node will receive mouse events and on iOS it will receive
    touch events.</li>
    <li>By default, events received but not handled by your node will be passed on to the next
    responder in the responder chain. The next responder is by default set to the parent of the
    node. You may choose to override this default by implementing ICNode::init and setting
    ICResponder::nextResponder to some other object. You may suppress event forwarding by
    implementing the respective event handler with an empty body in your subclass. If you
    implement a certain event handler method for performing a specific task, you may choose to
    pass the event to the next responder by calling the respective event method on
    <code>self.nextResponder</code> at the end of your method implementation.</li>
 </ul>
 
 <h3>Popular Subclasses</h3>
 
 IcedCoffee provides a number of 'popular' subclasses of ICNode that are equipped with special
 capabilities which you may find useful.
 
 <ul>
    <li>ICSprite renders a textured 2D quad.</li>
    <li>ICRenderTexture serves as a low-level FBO. It renders a sub scene into a texture and
    displays that texture on screen utilizing ICSprite.</li>
    <li>ICView provides a view hierarchy based on render textures (using ICRenderTexture.)</li>
    <li>ICControl provides user interface control capabilities on top of ICView.</li>
 </ul>
 */
@interface ICNode : ICResponder
{
@protected
    // Composition
    ICNode *_parent;
    NSMutableArray *_children;
    
    // Transform
    kmMat4 _transform;
    kmVec3 _position;
    kmVec3 _anchorPoint;
    kmVec3 _contentSize;
    kmVec3 _scale;
    kmVec3 _rotationAxis;
    float _rotationAngle;
    BOOL _transformDirty;
    BOOL _computesTransform;
    BOOL _autoCenterAnchorPoint;
    
    // Drawing
    ICShaderProgram *_shaderProgram;
    BOOL _isVisible;
    
    // User interaction support
    BOOL _userInteractionEnabled;
}


#pragma mark - Lifecycle
/** @name Lifecycle */

/**
@brief Initializes a node
@note This is the designated initializer of the ICNode class.
*/
- (id)init;


#pragma mark - Composition
/** @name Composition */

/**
 @brief An NSArray containing the node's children
 */
@property (nonatomic, readonly) NSArray *children;

/**
 @brief The node's parent
 
 The parent property is nil for root nodes. Usually, there is no need to set this
 property from the outside manually; it it set automatically by the addChild method.
 */
@property (nonatomic, assign, setter=setParent:) ICNode *parent;

/**
 @brief Adds a child node to the node's children array
 
 @param child A reference to a valid ICNode object. When added, the object is retained.
 */
- (void)addChild:(ICNode *)child;

/**
 @brief Inserts a child node at a specific index in the node's children array
 
 @param child A reference to a valid ICNode object. When inserted, the object is retained.
 @param index An int specifying an index position into the node's children array.
 */
- (void)insertChild:(ICNode *)child atIndex:(uint)index;

/**
 @brief Removes a child node from the node's children array
 
 @param child A reference to a valid ICNode object. When removed, the object is released.
 */
- (void)removeChild:(ICNode *)child;

/**
 @brief Removes a child node specified by an index into the node's children array
 
 @param index An int specifying the index of the child node to be removed. When removed,
 the object will be released.
 */
- (void)removeChildAtIndex:(uint)index;

/**
 @brief A boolean value indicating whether the node has children
 
 @return Returns YES when the node has children or NO if it does not have any children.
 */
- (BOOL)hasChildren;

/**
 @brief An array containing all ancestor nodes, ordered ascending beginning with the parent node
 
 @return Returns an NSArray of ICNode objects
 */
- (NSArray *)ancestors;

/**
 @brief An array containing ancestor nodes of a specific class type, ordered ascending
 beginning with the parent node or the first matching node which is found starting from the
 parent node
 
 @return Returns an NSArray of ICNode objects
 */
- (NSArray *)ancestorsWithType:(Class)classType;

- (ICNode *)firstAncestorWithType:(Class)classType;

/**
 @brief An array containing all descendant nodes, ordered descending beginning with the first child
 
 @return Returns an NSArray of ICNode objects
 */
- (NSArray *)descendants;

/**
 @brief An array containing descendant nodes of a specific class type, ordered descending
 beginning with the first matching child

 @return Returns an NSArray of ICNode objects
 */
- (NSArray *)descendantsWithType:(Class)classType;

/**
 @brief An array containing descendant nodes which are not of a specific class type, ordered
 descending beginning with the first matching child
 
 @return Returns an NSArray of ICNode objects
 */
- (NSArray *)descendantsNotOfType:(Class)classType;

/**
 @brief The root node terminating the node's branch
 
 This method returns the root node of the node's branch. This is identical to calling
 <code>[[node ancestors] lastObject]</code>.
 
 @return Returns an ICNode object representing the root node.
 */
- (ICNode *)root;

/**
 @brief The root scene of the node's branch
 
 This method invokes root, checks whether the resulting object is of class ICScene, and if so,
 returns the resulting ICScene object. If root is not of class ICScene, nil is returned.
 
 @note The root scene is not available until the receiver has been added to a scene.

 @return Returns an ICScene object representing the root scene of the node. If no root scene
 is available, nil is returned.
 */
- (ICScene *)rootScene;

/**
 @brief The parent scene of the node

 @note The parent scene is not available until the receiver has been added to a scene.

 @return Returns an ICScene object representing the parent scene of the node. If no parent scene
 is available, nil is returned.
 */
- (ICScene *)parentScene;

/**
 @brief The host view controller of the node's root scene
 
 This method invokes rootScene, asks it for its ICHostViewController object and returns the result.
 */
- (ICHostViewController *)hostViewController;


#pragma mark - Transforms
/** @name Transforms */

/**
 @brief The transform matrix of the node
 
 The transform matrix is a 4x4 matrix which may be used for arbitrary 3D space transformations.
 The utilized matrix is of type kmMat4 and may be manipulated using functions provided by the
 kazmath library. If the computesTransform property is set to YES, the transform matrix will
 be calculated automatically when the node is being visited by an ICNodeVisitor object. This
 will also happen for some of the transform and vector conversion methods provided by ICNode.
 */
@property (nonatomic, assign) kmMat4 transform;

/**
 @brief A const pointer to the node's transform matrix
 */
- (const kmMat4 *)transformPtr;

/**
 @brief The transform matrix used to transform coordinates from node space to parent node space
  
 If the node's transform matrix is dirty and computesTransform is set to YES, this method
 will invoke computeTransform to update the node's transform matrix before returning the result.
 */
- (kmMat4)nodeToParentTransform;

/**
 @brief The transform matrix used to transform coordinates from parent node space to node space

 This method invokes nodeToParentTransform, calculates its inverse and returns the result.
 The resulting matrix may be used to transform coordinates from parent node space to local
 node space.
  */
- (kmMat4)parentToNodeTransform;

/**
 @brief The transform matrix used to transform coordinates from node space to world space
 
 This method multiplies all ancestor transform matrices, starting with the receiver's direct
 parent, until an ICScene object's parent (or nil) is reached. It invokes nodeToParentTransform
 on all ancestor nodes to retrieve their updated transform matrices.
 
 Note that in IcedCoffee the world space of a given node is represented by its nearest ICScene
 ancestor's local coordinate space. This is done to ensure that nested scenes are represented
 as nested worlds, each having its own world coordinate space.
 */
- (kmMat4)nodeToWorldTransform;

/**
 @brief The transform matrix used to transform coordinates from world space to node space

 This method invokes nodeToWorldTransform, calculates its inverse and returns the result.
 The resulting matrix may be used to transform coordinates from world space to local node space.
 */
- (kmMat4)worldToNodeTransform;

/**
 @brief Converts a given vector from world to node space using worldToNodeTransform
 */
- (kmVec3)convertToNodeSpace:(kmVec3)worldVect;

/**
 @brief Converts a given vector from node to world space using nodeToWorldTransform
 */
- (kmVec3)convertToWorldSpace:(kmVec3)nodeVect;

/**
 @brief Sets the position of the node in its parent space
 */
- (void)setPosition:(kmVec3)position;

/**
 @brief Sets the x coordinate of the position of the node in its parent space
 */
- (void)setPositionX:(float)positionX;

/**
 @brief Sets the y coordinate of the position of the node in its parent space
 */
- (void)setPositionY:(float)positionY;

/**
 @brief Sets the z coordinate of the position of the node in its parent space
 */
- (void)setPositionZ:(float)positionZ;

/**
 @brief Sets the position of the node so as to center it in its parent node's space
 
 @note The parent node must have a valid ICNode::contentSize for this method to work correctly.
 */
- (void)centerNodeInParentNodeSpace;

/**
 @brief Returns the position of the node in the parent node space
 */
- (kmVec3)position;

/**
 @brief Sets the anchor point of the node in its own untransformed space
 */
- (void)setAnchorPoint:(kmVec3)anchorPoint;

/**
 @brief Centers the anchor point of the node based on its ICNode::contentSize property
 */
- (void)centerAnchorPoint;

/**
 @brief The anchor point of the node in its own untransformed space
 */
- (kmVec3)anchorPoint;

/**
 @brief Sets the content size of the node in its own untransformed space
 */
- (void)setContentSize:(kmVec3)contentSize;

/**
 @brief Returns the content size of the node in its own untransformed space
 */
- (kmVec3)contentSize;

/**
 @brief Sets the node's scale
 */
- (void)setScale:(kmVec3)scale;

/**
 @brief Sets the node's x scale
 */
- (void)setScaleX:(float)scaleX;

/**
 @brief Sets the node's y scale
 */
- (void)setScaleY:(float)scaleY;

/**
 @brief Sets the node's x and y scale
 */
- (void)setScaleXY:(float)scaleXY;

/**
 @brief Sets the node's z scale
 */
- (void)setScaleZ:(float)scaleZ;

/**
 @brief Returns the scale of the node
 */
- (kmVec3)scale;

/**
 @brief Sets the rotation angle and axis of the node
 */
- (void)setRotationAngle:(float)angle axis:(kmVec3)axis;

/**
 @brief Gets the rotation angle and axis of the node
 */
- (void)getRotationAngle:(float *)angle axis:(kmVec3 *)axis;

/**
 @brief A BOOL property indicating whether the node should compute its transform based on
 position, scale, rotation and anchor point as specified
 */
@property (nonatomic, assign) BOOL computesTransform;

/**
 @brief Computes the node's transform based on its position, scale, rotation and acnhor point
 properties
 */
- (void)computeTransform;

/**
 @brief A BOOL property indicating whether the anchor point should be auto-centered based on
 the node's contentSize property
 */
@property (nonatomic, assign) BOOL autoCenterAnchorPoint;


#pragma mark - Order
/** @name Order */

/**
 @brief The index of the node in its parent's children array
 */
- (NSUInteger)order;

/**
 @brief Exchanges the node with the last node of its parent's children array
 */
- (void)orderFront;

/**
 @brief Exchanges the node with the next node of its parent's children array
 */
- (void)orderForward;

/**
 @brief Exchanges the node with the previous node of its parent's children array
 */
- (void)orderBackward;

/**
 @brief Exchanges the node with the first node of its parent's children array
 */
- (void)orderBack;


#pragma mark - Bounds
/** @name Bounds */

/**
 @brief The node's axis-aligned bounding box
 
 This method calculates the node's axis-aligned bounding box in its parent node's coordinate space.
 
 @remarks The calculations performed by this method are based on the ICNode::position and
 ICNode::contentSize properties. For this method to work correctly, the following preconditions
 must be met:
 <ul>
     <li>The receiver's ICNode::contentSize property must be set correctly, that is, covering
     the whole (cubic) space occupied by the receiver's visible contents.</li>
     <li>The receiver must have been added to a valid ICScene object before this method is
     called.</li>
 </ul>
 
 @return Returns an kmAABB object defining the node's axis-aligned bounding box. If the method
 fails to calculate the node's bounding box, a zero kmAABB is returned. When this happens,
 most likely one or many of the preconditions mentioned above have not been met.
 */
- (kmAABB)aabb;

/**
 @brief The rectangle occupied by the node on its parent scene's frame buffer
 
 This method calculates the origin and size of the rectangle occupied by the node on its parent
 scene's frame buffer. The rectangle is always aligned to the frame buffer's axes. All coordinates
 are expressed in points rather than pixels.

 @remarks The calculations performed by this method are based on the ICNode::position and
 ICNode::contentSize properties. For this method to work correctly, the following preconditions
 must be met:
 <ul>
    <li>The receiver's ICNode::contentSize property must be set correctly, that is, covering
    the whole (cubic) space occupied by the receiver's visible contents.</li>
    <li>The receiver must have been added to a valid ICScene object before this method is
    called.</li>
    <li>The parent scene of the receiver must have a valid target frame buffer.</li>
 </ul>
 
 @return Returns a CGRect defining the rectangle (in points) occupied by the node's visible
 contents. If the method fails to calculate the node's frame rect, a zero CGRect is returned.
 When this happens, most likely one or many of the preconditions outlined above have not been met.
 */
- (CGRect)frameRect;


#pragma mark - Drawing and Picking
/** @name Drawing and Picking */

/**
 @brief The node's shader program, including vertex and fragment shader
 */
@property (nonatomic, retain) ICShaderProgram *shaderProgram;

/**
 @brief A BOOL property indicating whether the node is visible
 
 Invisible nodes will not be drawn. They may receive HID events, but will not be selectable
 using pointer or touch input devices as they are not drawn for picking.
 */
@property (nonatomic, assign) BOOL isVisible;

/**
 @brief Applies the standard draw setup with the specified visitor
 
 This method should be called at the beginning of ICNode::drawWithVisitor: to ensure that an
 appropriate standard drawing setup is applied to the current OpenGL context. The default
 implementation sets up vertex and fragment shader programs pertaining to the specified
 visitor. For visitors of type kICDrawingNodeVisitor, the method applies the shader set
 in ICNode::shaderProgram, for visitors of type kICPickingNodeVisitor the method looks up
 the default picking shader (keyed kICShader_Picking) using ICShaderCache and applies it.
 */
- (void)applyStandardDrawSetupWithVisitor:(ICNodeVisitor *)visitor;

/**
 @brief Draws the node
 
 This method is called by the framework to draw the node using a visitor. You should never call
 this method directly.
 
 The default implementation does nothing.

 @param visitor The ICNodeVisitor instance used to visit the node
 
 You should override this method in drawable node subclasses to implement your custom drawing code.
 At the beginning of your method implementation, check whether the node is visible and cancel
 drawing if it is not. Additionally, apply a standard drawing setup using the
 ICNode::applyStandardDrawSetupWithVisitor: method.
 
 Example:
 @code
 - (void)drawWithVisitor:(ICNodeVisitor *)visitor
 {
    if (!self.visible)
        return; // cancel drawing
    
    [self applyStandardDrawSetupWithVisitor:visitor];
 
    // Your custom drawing code goes here
 }
 @endcode
 
 @note If necessary, you should implement a specialized drawing setup for picking. You may do
 so by checking whether the specified visitor is kind of class ICNodeVisitorPicking. If so,
 you may want to deactivate texturing to improve performance or to provide custom picking shapes
 for clicks, mouse overs, and touches.

 @sa ICSprite::drawWithVisitor:
 */
- (void)drawWithVisitor:(ICNodeVisitor *)visitor;

/**
 @brief Called when all children of the node have been drawn
 
 Called by the framework when all children nodes have been drawn completely. You may override
 this method to reset states that have been set in ICNode::drawWithVisitor: and were not reset
 for drawing the node's children.
 */
- (void)childrenDidDrawWithVisitor:(ICNodeVisitor *)visitor;

/**
 @brief Informs the framework that the node needs to be redrawn
 
 This method needs to be called only if the node is part of a drawing environment that does not
 redraw all its contents continuously. The default implementation simply calls
 ICNode::setNeedsDisplay on its parent. Specialized classes implementing updatable frame buffers
 such as ICRenderTexture should override this method in order to implement conditional redrawing.
 */
- (void)setNeedsDisplay;


#pragma mark - User Interaction Support
/** @name User Interaction Support */

/**
 @brief Indicates whether the node should receive user interaction events from the event
 processing system
 
 If set to YES, the node will be drawn by the picking visitor (see ICNodeVisitorPicking) and
 respond to mouse, touch, and keyboard events. Setting this property to NO makes it unresponsive
 for user interaction events dispatched directly to the node otherwise.
 
 User interaction is enabled by default. You should disable it if the node does not need to
 receive user interaction events to improve performance. If you subclass ICNode, you may
 disable user interaction by default by overriding ICNode::init.
 
 @note Even if ICNode::userInteractionEnabled is set to NO, the node may still receive events
 indirectly as a result of the responder chain implemented in IcedCoffee's event processing
 system. The default ICResponder implementation will forward events to the next responder if they
 are not handled by the node itself. Event forwarding as part of the responder chain is not
 influenced by the ICNode::userInteractionEnabled property.
 */
@property (nonatomic, assign) BOOL userInteractionEnabled;


@end
