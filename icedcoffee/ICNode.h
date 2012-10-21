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
#import "kazmath/kazmath.h"
#import "Platforms/icGL.h"

#import "ICResponder.h"
#import "ICNodeVisitor.h"
#import "ICFramebufferProvider.h"

#import "icConfig.h"

@class ICNodeVisitor;
@class ICShaderProgram;
@class ICScene;
@class ICHostViewController;

/**
 @brief Block type for filtering nodes
 */
typedef BOOL(^ICNodeFilterBlockType)(ICNode *node, BOOL *stop);

/**
 @brief Base class for drawable nodes in a scene
 
 The ICNode class represents a low-level drawable object which is capable of receiving user
 interaction events from the framework. Each node provides an array of strong references to its
 children nodes and a weak reference to its parent node. A collection of linked nodes forms a
 tree-like structure, called a scene graph. A scene graph must be rooted in an ICScene object
 in order to exploit all capabilities of the framework.
 
 A node has a transform matrix used to transform coordinates from parent space to its own
 local space. Nodes provide convenience methods for manipulating their transform matrix based
 on ICNode::position, ICNode::scale, rotation (ICNode::getRotationAngle:axis:,
 ICNode::setRotationAngle:axis:) and ICNode::anchorPoint properties. Furthermore, nodes provide
 methods for calculating inverse and world transforms.
 
 Nodes have implicit order, that is, their order is defined by the index they occupy in their
 parent's children array. ICNode provides convenience methods for manipulating this order, e.g.
 ICNode::orderFront, ICNode::orderForward, ICNode::orderBackward and ICNode::orderBack.
 
 Visitors are used to traverse a given scene graph for drawing on a framebuffer. A visitor is
 an external object of class ICNodeVisitor. The framework ships with two built-in visitor classes,
 ICNodeVisitorDrawing for drawing nodes on screen and ICNodeVisitorPicking for drawing nodes
 on an invisible framebuffer for picking.
 
 Since IcedCoffee is based on GLES2, each node uses shader programs for drawing. Shader programs
 are managed using the ICShaderProgram and ICShaderCache classes.
 
 Nodes provide the basis for user interaction event handling for mice, touch, and keyboard
 devices. Event handling is implemented on top of the scene graph in the ICScene, ICResponder, and
 ICHostViewController classes amongst others.

 ### Subclassing ###
 
 ICNode may be subclassed to implement custom nodes. Most likely, you will want to implement
 custom drawing and/or custom event handling (based on ICResponder.)
 
 #### Custom Drawing ####
 
  - ICNode's designated initializer is ICNode::init. You should override ICNode::init
    to implement custom initialization on top of ICNode.
  - Set a custom shader program in the subclasses' initializer if necessary.
  - ICNode::drawWithVisitor: is called by the framework when the node needs to be drawn into
    a framebuffer. It is used for both drawing and picking.
  - When you override ICNode::drawWithVisitor:, first check whether the node is visible and
    skip any drawing if it is not.
  - IcedCoffee does by default provide two different visitors. ICNodeVisitorDrawing is
    used for rendering objects on screen while ICNodeVisitorPicking is used to draw objects
    on an internal picking framebuffer. ICNode provides a standard way of setting up shaders
    for drawing and picking. Hence, after checking for visibility, you should call
    ICNode::applyStandardDrawSetupWithVisitor: . This will automatically activate the node's shader
    program for drawing or the default picker shader program for picking.
  - You may implement custom picking shapes or optimized drawing code for picking by checking
    the class of the visitor object given when ICNode::drawWithVisitor: is called. If visitor is
    kind of class ICNodeVisitorDrawing, provide code to draw the object's visible shape on screen.
    If visitor is kind of class ICNodeVisitorPicking, provide code to draw the object's
    pickable shape.
  - You may also implement your drawing code without taking care of picking. In this
    case the framework will automatically use the object's drawn shape as a picking shape
    provided that you employ ICNode::applyStandardDrawSetupWithVisitor: to set up drawing.
 
 #### Custom Event Handling ####
 
  - Event handling is based on the ICResponder super class. You implement event handlers
    by overriding one of the event handler methods defined there, e.g. by implementing
    ICResponder::mouseDown:. You may override both touch and mouse event handler methods in one
    ICNode subclass. On Mac OS X the node will receive mouse events and on iOS it will receive
    touch events.
  - By default, events received but not handled by your node will be passed on to the next
    responder in the responder chain. The next responder is by default set to the parent of the
    node. You may choose to override this default by implementing ICNode::init and setting
    ICResponder::nextResponder to some other object. You may suppress event forwarding by
    implementing the respective event handler with an empty body in your subclass. If you
    implement a certain event handler method for performing a specific task, you may choose to
    pass the event to the next responder by calling the respective event method on
    <code>self.nextResponder</code> at the end of your method implementation.
 */
@interface ICNode : ICResponder
{
@protected
    // Graph linkage
    NSMutableArray *_children;    
    ICNode *_parent;
    
    // Transform
    kmMat4 _transform;
    kmVec3 _position;
    kmVec3 _anchorPoint;
    kmVec3 _origin;
    kmVec3 _size;
    kmVec3 _scale;
    kmVec3 _rotationAxis;
    float _rotationAngle;
    BOOL _transformDirty;
    BOOL _computesTransform;
    BOOL _autoCenterAnchorPoint;
    
    // Z sorting
    int _zIndex;
    NSMutableArray *_childrenSortedByZIndex;
    BOOL _childrenSortedByZIndexDirty;
    
    // Drawing
    ICShaderProgram *_shaderProgram;
    BOOL _isVisible;
    
    // User interaction support
    BOOL _userInteractionEnabled;
}


#pragma mark - Initializing a Node
/** @name Initializing a Node */

/**
@brief Initializes the receiver
 
@note This is the designated initializer of the ICNode class.
*/
- (id)init;


#pragma mark - Compositing Nodes
/** @name Compositing Nodes */

/**
 @brief Returns an array containing the receiver's children nodes
 
 @sa
    - drawingChildren
    - pickingChildren
    - hasChildren
    - childForTag:
    - childrenOfType:
    - descendants
 */
@property (nonatomic, readonly, getter=children) NSArray *children;

/**
 @brief Returns an array containing the receiver's children nodes to be used for drawing
 
 @sa
    - pickingChildren
    - children
 */
- (NSArray *)drawingChildren;

/**
 @brief Returns an array containing the receiver's children nodes to be used for picking
 
 @sa
    - drawingChildren
    - children
 */
- (NSArray *)pickingChildren;

/**
 @brief The receiver's parent node
 
 The parent property is nil for root nodes. Usually, there is no need to set this
 property manually, it is set automatically by ICNode::addChild.
 
 Subclasses that need to be notified when the node's parent changes may override
 ICNode::setParent: to implement custom program logic. When overriding, you should
 always call <code>[super setParent:parent]</code> to ensure the parent is set
 appropriately in ICNode.
 
 @sa
    - ancestors
    - children
 */
@property (nonatomic, assign, setter=setParent:) ICNode *parent;

/**
 @brief Adds a child node to the receiver's children array
 
 @param child A reference to a valid ICNode object. When added, the object is retained.
 
 @sa
    - insertChild:atIndex:
    - removeChild:
    - children
 */
- (void)addChild:(ICNode *)child;

/**
 @brief Inserts a child node at a specific index in the receiver's children array
 
 @param child A reference to a valid ICNode object. When inserted, the object is retained.
 @param index An int specifying an index position into the node's children array.
 
 @sa
    - addChild:
    - children
 */
- (void)insertChild:(ICNode *)child atIndex:(uint)index;

/**
 @brief Removes a child node from the receiver's children array
 
 @param child A reference to a valid ICNode object. When removed, the object is released.
 
 @sa
    - removeChildAtIndex:
    - removeAllChildren:
    - children
 */
- (void)removeChild:(ICNode *)child;

/**
 @brief Removes a child node specified by an index into the receiver's children array
 
 @param index An int specifying the index of the child node to be removed. When removed,
 the object will be released.
 
 @sa
    - removeChild:
    - removeAllChildren:
    - children
 */
- (void)removeChildAtIndex:(uint)index;

/**
 @brief Removes all children from the receiver
 
 @sa
    - removeChild:
    - removeChildAtIndex:
    - children
 */
- (void)removeAllChildren;

/**
 @brief A boolean value indicating whether the receiver has children
 
 @return Returns YES when the receiver has children or NO if it does not have any children.
 
 @sa
    - children
 */
- (BOOL)hasChildren;

/**
 @brief Returns the receiver's immediate child for the specified tag
 
 @sa
    - children
 */
- (ICNode *)childForTag:(uint)tag;

/**
 @brief Returns all children of the receiver that are kind of the specified class
 
 @sa
    - childrenNotOfType:
    - children
 */
- (NSArray *)childrenOfType:(Class)classType;

/**
 @brief Returns all children of the receiver that are not kind of the specified class
 
 @sa
    - childrenOfType:
    - children
 */
- (NSArray *)childrenNotOfType:(Class)classType;

/**
 @brief Returns an array containing all ancestor nodes
 
 @return Returns an NSArray of ICNode objects, ordered ascending beginning with the first
 ancestor node.
 
 @sa
    - ancestorsOfType:
    - ancestorsNotOfType:
    - ancestorsConformingToProtocol:
    - ancestorsFilteredUsingBlock:
 */
- (NSArray *)ancestors;

/**
 @brief Returns an array of ancestor nodes filtered by the given filter block
 
 @param filterBlock A block that accepts an ICNode object and a pointer to a BOOL value.
 The block must return a BOOL value indicating whether the given node passes the filter or not.
 Additionally, if the block sets the stop flag to YES, the method stops collecting ancestors
 immediately after adding the last ancestor that passed the filter test.
 
 @return Returns an NSArray containg zero or more ICNode objects, ordered ascending
 beginning with the first ancestor node of the receiver that matches the filter rules.
 */
- (NSArray *)ancestorsFilteredUsingBlock:(ICNodeFilterBlockType)filterBlock;

/**
 @brief Returns an array containing ancestor nodes which are kind of the given class type
 
 @return Returns an NSArray of ICNode objects, ordered ascending beginning with the first
 ancestor node of the receiver that matches the given class type.
 */
- (NSArray *)ancestorsOfType:(Class)classType;

/**
 @brief Returns an array containing ancestor nodes which are not kind of the given class type
 
 @return Returns an NSArray of ICNode objects, ordered ascending beginning with the first
 ancestor node of the receiver that matches the given class type.
 */
- (NSArray *)ancestorsNotOfType:(Class)classType;

/**
 @brief Returns an array containing ancestor nodes which conform to the given protocol
 
 @return Returns an NSArray of ICNode objects, ordered ascending beginning with the first
 ancestor node of the receiver that conforms to the given protocol.
 */
- (NSArray *)ancestorsConformingToProtocol:(Protocol *)protocol;

- (ICNode *)firstAncestorConformingToProtocol:(Protocol *)protocol;

/**
 @brief Returns the first ancestor which is kind of the given class type
 */
- (ICNode *)firstAncestorOfType:(Class)classType;

/**
 @brief An array containing all descendant nodes
 
 @return Returns an NSArray of ICNode objects, ordered descending beginning with the
 first child of the receiver.
 
 @sa
    - descendantsOfType:
    - descendantsNotOfType:
    - descendantsConformingToProtocol:
    - descendantsFilteredUsingBlock:
 */
- (NSArray *)descendants;

/**
 @brief Returns an array of descendant nodes filtered by the given filter block

 @param filterBlock A block that accepts an ICNode object and a pointer to a BOOL value.
 The block must return a BOOL value indicating whether the given node passes the filter or not.
 Additionally, if the block sets the stop flag to YES, the method stops collecting descendants
 immediately after adding the last ancestor that passed the filter test.
 
 @return Returns an NSArray containg zero or more ICNode objects, order descending
 beginning with the first descendant of the receiver that matches the filter rules.
 */
- (NSArray *)descendantsFilteredUsingBlock:(ICNodeFilterBlockType)filterBlock;

/**
 @brief Returns an array of descendant nodes which are kind of the given class type

 @return Returns an NSArray of ICNode objects, ordered descending beginning with the
 first matching descendant.
 */
- (NSArray *)descendantsOfType:(Class)classType;

/**
 @brief Returns an array of descendant nodes which are not kind of the given class type
 
 @return Returns an NSArray of ICNode objects, ordered descending beginning with the
 first matching descendant.
 */
- (NSArray *)descendantsNotOfType:(Class)classType;

/**
 @brief Returns an array containing descendant nodes which conform to the given protocol
 
 @return Returns an NSArray of ICNode objects, ordered descending beginning with the first
 descendant node of the receiver that conforms to the given protocol.
 */
- (NSArray *)descendantsConformingToProtocol:(Protocol *)protocol;

/**
 @brief Returns the first descendant which is kind of the given class type
 */
- (ICNode *)firstDescendantOfType:(Class)classType;

/**
 @brief Returns the level of the receiver on the scene graph
 
 The level is basically the number of ancestors of the receiver, that is, the root node's
 level is always zero, the root scene's children's level is always one, and so on.
 */
- (uint)level;

/**
 @brief The root node terminating the receiver's branch
 
 This method returns the root node of the receiver's branch.
 
 @return Returns an ICNode object representing the root node.
 */
- (ICNode *)root;

/**
 @brief The root scene of the receiver's branch
 
 This method invokes root, checks whether the resulting object is of class ICScene, and if so,
 returns the resulting ICScene object. If root is not of class ICScene, nil is returned.
 
 @note The root scene is not available until the receiver has been added to a scene.

 @return Returns an ICScene object representing the root scene of the node. If no root scene
 is available, nil is returned.
 */
- (ICScene *)rootScene;

/**
 @brief The parent scene of the receiver

 @note The parent scene is not available until the receiver has been added to a scene.

 @return Returns an ICScene object representing the parent scene of the receiver. If no parent
 scene is available, nil is returned.
 */
- (ICScene *)parentScene;

/**
 @brief The scene of the receiver
 
 If the receiver is of class ICScene, returns the receiver. Otherwise, returns the parent scene
 of the receiver.
 
 @note The scene may not be available until the receiver has been added to a scene.
 
 @return Returns an ICScene object representing the scene of the receiver. If no scene
 is available, nil is returned.
 */
- (ICScene *)scene;

/**
 @brief Returns the node that directly provides a framebuffer for drawing the receiver
 
 This method returns the first ancestor node that conforms to the ICFramebufferProvider protocol.
 */
- (ICNode<ICFramebufferProvider> *)framebufferProvider;

/**
 @brief The host view controller of the receiver's root scene
 
 This method invokes rootScene, asks it for its ICHostViewController object and returns the result.
 Consequently, if the receiver has not yet been added to a scene, the method returns ``nil``.
 */
- (ICHostViewController *)hostViewController;


#pragma mark - Transforming a Node
/** @name Transforming a Node */

/**
 @brief The transform matrix of the receiver
 
 The transform matrix is a 4x4 matrix which may be used for arbitrary 3D transforms.
 The utilized matrix is of type kmMat4 and may be manipulated using the functions provided by the
 kazmath library. If the ICNode::computesTransform property is set to YES, the transform matrix
 will be calculated automatically when the node is being visited by an ICNodeVisitor object. This
 will also happen for some of the transform and vector conversion methods provided by ICNode.
 
 @note Retrieving the transform from the receiver via this property will copy the matrix.
 In performance criticial code you may access the transform for reading without copying it
 using the ICNode::transformPtr method.
 */
@property (nonatomic, assign) kmMat4 transform;

/**
 @brief A const pointer to the receiver's transform matrix
 
 Use this method in performance critical code to get fast read access the receiver's
 transform matrix.
 */
- (const kmMat4 *)transformPtr;

/**
 @brief A transform matrix used to transform coordinates from the receiver's local node space
 to the receiver's parent node space
  
 If the receiver's transform matrix is dirty and ICNode::computesTransform is set to YES, this
 method will invoke computeTransform to update the receiver's transform matrix before returning
 the result.
 */
- (kmMat4)nodeToParentTransform;

/**
 @brief A transform matrix used to transform coordinates from the receiver's parent node space to
 the receiver's local node space

 This method invokes nodeToParentTransform, calculates its inverse and returns the result.
 The resulting matrix may be used to transform coordinates from parent node space to local
 node space.
  */
- (kmMat4)parentToNodeTransform;

/**
 @brief A transform matrix used to transform coordinates from the receiver's local node space
 to world space
 
 This method multiplies all ancestor transform matrices, starting with the receiver's direct
 parent, until an ICScene object's parent (or nil) is reached. It invokes nodeToParentTransform
 on all ancestor nodes to retrieve their updated transform matrices.
 
 Note that in IcedCoffee the world space of a given node is represented by its nearest ICScene
 ancestor's local coordinate space. This is done to ensure that nested scenes are represented
 as nested worlds, each having its own world coordinate space.
 */
- (kmMat4)nodeToWorldTransform;

/**
 @brief A transform matrix used to transform coordinates from world space to the receiver's
 local node space

 This method invokes nodeToWorldTransform, calculates its inverse and returns the result.
 The resulting matrix may be used to transform coordinates from world space to local node space.
 */
- (kmMat4)worldToNodeTransform;

/**
 @brief Converts a given vector from world space to the receiver's local node space
 */
- (kmVec3)convertToNodeSpace:(kmVec3)worldVect;

/**
 @brief Converts a given vector from the receiver's local node space to world space
 */
- (kmVec3)convertToWorldSpace:(kmVec3)nodeVect;

/**
 @brief The position of the receiver
 */
@property (nonatomic, assign, getter=position, setter=setPosition:) kmVec3 position;

/**
 @brief Sets the x coordinate of the position of the receiver
 */
- (void)setPositionX:(float)positionX;

/**
 @brief Sets the y coordinate of the position of the receiver
 */
- (void)setPositionY:(float)positionY;

/**
 @brief Sets the z coordinate of the position of the receiver
 */
- (void)setPositionZ:(float)positionZ;

/**
 @brief Returns the receiver's center in local coordinate space
 
 The local center is calculated based on the receiver's local axis-aligned bounding box as
 retrieved via ICNode::localAABB.
 
 @sa center
 */
- (kmVec3)localCenter;

- (kmVec3)localCenterRounded:(BOOL)rounded;

- (kmVec3)localOpticalCenter;

- (kmVec3)localOpticalCenterRounded:(BOOL)rounded;

/**
 @brief Returns the receiver's center in parent coordinate space
 
 This method retrieves the receiver's local center by invoking ICNode::localCenter, then transforms
 the received coordinates to parent coordinate space using the node's ICNode::transform matrix.
 
 @sa
 - setCenter:
 - localCenter
 */
- (kmVec3)center;

- (kmVec3)centerRounded:(BOOL)rounded;

- (kmVec3)opticalCenter;

- (kmVec3)opticalCenterRounded:(BOOL)rounded;

/**
 @brief Sets the receiver's position so as to move its contents to the given center in
 parent coordinate space
 
 @sa
 - position
 */
- (void)setCenter:(kmVec3)center;

- (void)setCenter:(kmVec3)center rounded:(BOOL)rounded;

/**
 @brief Sets the receiver's X position so as to move its contents to the given center's X in
 parent coordinate space
 */
- (void)setCenterX:(float)centerX;

- (void)setCenterX:(float)centerX rounded:(BOOL)rounded;

/**
 @brief Sets the receiver's Y position so as to move its contents to the given center's Y in
 parent coordinate space
 */
- (void)setCenterY:(float)centerY;

- (void)setCenterY:(float)centerY rounded:(BOOL)rounded;

/**
 @brief Sets the receiver's Z position so as to move its contents to the given center's Z in
 parent coordinate space
 */
- (void)setCenterZ:(float)centerZ;

- (void)setCenterZ:(float)centerZ rounded:(BOOL)rounded;

/**
 @brief Sets the position of the receiver so as to center it in its parent node's coordinate space
 
 @note The receiver must have been added as a child of a parent node for this method to work.
 
 @sa
 - setCenter:
 */
- (void)centerNode;

- (void)centerNodeRounded:(BOOL)rounded;

- (void)centerNodeOptically;

- (void)centerNodeOpticallyRounded:(BOOL)rounded;

/**
 @brief Sets the position of the receiver so as to center it horizontally in parent node's space
 
 @note The receiver must have been added as a child of a parent node for this method to work.
 
 @sa
 - setCenterX:
 */
- (void)centerNodeHorizontally;

- (void)centerNodeHorizontallyRounded:(BOOL)rounded;

/**
 @brief Sets the position of the receiver so as to center it vertically in parent node's space
 
 @note The receiver must have been added as a child of a parent node for this method to work.

 @sa
 - setCenterY:
 */
- (void)centerNodeVertically;

- (void)centerNodeVerticallyRounded:(BOOL)rounded;

/**
 @brief The anchor point of the receiver in local coordinate space
 */
@property (nonatomic, assign, getter=anchorPoint, setter=setAnchorPoint:) kmVec3 anchorPoint;

/**
 @brief Sets the receiver's anchor point to its local center
 */
- (void)centerAnchorPoint;

/**
 @brief The origin of the receiver's contents in local node space
 */
@property (nonatomic, assign) kmVec3 origin;

/**
 @brief The size of the receiver
 */
@property (nonatomic, assign, getter=size, setter=setSize:) kmVec3 size;

/**
 @brief Sets the width of the receiver
 */
- (void)setWidth:(float)width;

/**
 @brief Sets the height of the receiver
 */
- (void)setHeight:(float)height;

/**
 @brief Sets the depth of the receiver
 */
- (void)setDepth:(float)depth;

/**
 @brief The scale of the receiver
 */
@property (nonatomic, assign, getter=scale, setter=setScale:) kmVec3 scale;

/**
 @brief Sets the receiver's x scale
 */
- (void)setScaleX:(float)scaleX;

/**
 @brief Sets the receiver's y scale
 */
- (void)setScaleY:(float)scaleY;

/**
 @brief Sets the receiver's x and y scale
 */
- (void)setScaleXY:(float)scaleXY;

/**
 @brief Sets the receiver's z scale
 */
- (void)setScaleZ:(float)scaleZ;

/**
 @brief Sets the rotation angle and axis of the receiver
 */
- (void)setRotationAngle:(float)angle axis:(kmVec3)axis;

/**
 @brief Gets the rotation angle and axis of the receiver
 */
- (void)getRotationAngle:(float *)angle axis:(kmVec3 *)axis;

/**
 @brief A BOOL property indicating whether the receiver should compute its transform based on
 position, scale, rotation and anchor point as specified
 */
@property (nonatomic, assign) BOOL computesTransform;

/**
 @brief Computes the receiver's transform based on its position, scale, rotation and anchor point
 properties
 */
- (void)computeTransform;

/**
 @brief A BOOL property indicating whether the anchor point should be auto-centered based on
 the receiver's size property
 */
@property (nonatomic, assign) BOOL autoCenterAnchorPoint;


#pragma mark - Managing Order
/** @name Managing Order */

@property (nonatomic, assign, setter=setZIndex:) int zIndex;

/**
 @brief The index of the receiver in its parent's children array
 */
- (NSUInteger)order;

/**
 @brief Exchanges the receiver with the last node of its parent's children array
 */
- (void)orderFront;

/**
 @brief Exchanges the receiver with the next node of its parent's children array
 */
- (void)orderForward;

/**
 @brief Exchanges the receiver with the previous node of its parent's children array
 */
- (void)orderBackward;

/**
 @brief Exchanges the receiver with the first node of its parent's children array
 */
- (void)orderBack;


#pragma mark - Managing a Node's Bounds
/** @name Managing a Node's Bounds */

/**
 @brief Returns the receiver's axis-aligned bounding box in local coordinate space
 
 The default implementation returns an axis-aligned bounding box based upon the node's
 ICNode::origin and ICNode::size properties. Subclasses may override this method if their
 bounding box needs to be calculated differently.
 
 @return Returns a kmAABB object defining the node's axis aligned bounding box in local
 coordinate space. If the method fails to calculate the node's bounding box, a zero kmAABB
 is returned.
 */
- (kmAABB)localAABB;

/**
 @brief Returns the receiver's axis-aligned bounding box in parent coordinate space
 
 This method internally invokes ICNode::localAABB, then transforms the returned ``min``
 and ``max`` vectors into parent space using the receiver's ICNode::transform matrix. Finally,
 the axis-aligned bounding box in parent space is computed based on the transformed vectors.
 
 @return Returns a kmAABB object defining the node's axis-aligned bounding box in parent
 coordinate space. If the method fails to calculate the node's bounding box, a zero kmAABB
 is returned.
 */
- (kmAABB)aabb;

/**
 @brief The rectangle occupied by the receiver on its parent scene's framebuffer
 
 This method calculates the origin and size of the rectangle occupied by the node on its parent
 scene's framebuffer. The rectangle is always aligned to the framebuffer's axes. All coordinates
 are expressed in points rather than pixels.

 @remarks The calculations performed by this method are based on the ICNode::position and
 ICNode::size properties. For this method to work correctly, the following preconditions
 must be met:
 - The receiver's ICNode::size property must be set correctly, that is, covering
   the whole (cubic) space occupied by the receiver's visible contents.
 - The receiver must have been added to a valid ICScene object before this method is
   called.
 - The parent scene of the receiver must have a valid target framebuffer.
 
 @return Returns a ``CGRect`` defining the rectangle (in points) occupied by the node's visible
 contents. If the method fails to calculate the node's frame rect, a zero ``CGRect`` is returned.
 When this happens, most likely one or many of the preconditions outlined above have not been met.
 */
- (CGRect)frameRect;


#pragma mark - Drawing and Picking
/** @name Drawing and Picking */

/**
 @brief The receiver's shader program for drawing, including a vertex and a fragment shader
 */
@property (nonatomic, retain) ICShaderProgram *shaderProgram;

/**
 @brief A BOOL property indicating whether the receiver is visible
 
 Invisible nodes are not drawn and do not receive user interaction events by the framework.
 The default value for this property is ``YES``.
 */
@property (nonatomic, assign) BOOL isVisible;

/**
 @brief Applies a standard draw setup with the specified visitor
 
 This method should be called at the beginning of ICNode::drawWithVisitor: to ensure that an
 appropriate standard drawing setup is applied to the current OpenGL context. The default
 implementation sets up vertex and fragment shader programs pertaining to the specified
 visitor. For non-picking visitors, the method applies the shader set in ICNode::shaderProgram,
 for picking visitors the method looks up the default picking shader (keyed ICShaderPicking)
 using ICShaderCache and uses it on the current OpenGL context.
 */
- (void)applyStandardDrawSetupWithVisitor:(ICNodeVisitor *)visitor;

/**
 @brief Draws the receiver's contents
 
 @param visitor The ICNodeVisitor instance used to visit the node

 This method is called by the framework to draw the receiver using a visitor. You should
 never call this method directly unless you know what you are doing.
 
 The default implementation does nothing.
 
 You should override this method in drawable node subclasses to implement your custom drawing code.
 You may want to pply a standard drawing setup using the ICNode::applyStandardDrawSetupWithVisitor:
 method.
 
 Example:
 @code
 - (void)drawWithVisitor:(ICNodeVisitor *)visitor
 {
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
 @brief Called when all children of the receiver have been drawn
 
 Called by the framework when all children of the receiver have been drawn.
 
 You may override this method to reset states that have been set in ICNode::drawWithVisitor:
 and were not reset for drawing the receiver's children.
 */
- (void)childrenDidDrawWithVisitor:(ICNodeVisitor *)visitor;

/**
 @brief Informs the framework that the receiver needs to be redrawn
 
 This method must be called when the receiver's contents need to be redrawn and the receiver
 is part of an ICScene object which is rendered on demand only. For instance, if the receiver
 is a descendant of an ICRenderTexture's ICRenderTexture::subScene and the render texture's
 ICRenderTexture::frameUpdateMode is set to ICFrameUpdateModeOnDemand, then you have to call
 this method to ensure that the render texture's contents are redrawn to reflect a change
 in the appearance of the receiver. Likewise, if the receiver's ICNode::hostViewController's
 ICHostViewController::frameUpdateMode is set to ICFrameUpdateModeOnDemand, this method needs
 to be called so that the whole scene is redrawn on the host view controller's view.
 
 Note that this method does not actually redraw the receiver. Instead, it informs the framework
 to redraw the content's of the receiver's parent frame buffer the next time it enters the
 ICHostViewController::drawScene or ICRenderTexture::drawWithVisitor: method.
 
 @sa
 - ICHostViewController::frameUpdateMode
 - ICRenderTexture::frameUpdateMode
 */
- (void)setNeedsDisplay;


#pragma mark - Performing Ray-based Hit Testing
/** @name Performing Ray-based Hit Testing */

/**
 @brief Performs a local ray-based hit test on the receiver
 
 @param ray An icRay3 object defining the ray to be used for hit testing in the receiver's local
 coordinate space.

 To be implemented in subclasses. The default implementation does nothing and returns
 ``ICHitTestUnsupported``.
 
 Subclasses implementing this method should perform a hit test based on an appropriate
 approximation of the node's geometry and the specified ray, then return an ICHitTestResult
 enumerated value defining whether the hit test succeeded or not.
 
 @sa
 - ICPlanarNode
 - ICNodeVisitorPicking
 */
- (ICHitTestResult)localRayHitTest:(icRay3)ray;


#pragma mark - Managing User Interaction Support
/** @name Managing User Interaction Support */

/**
 @brief Indicates whether the receiver should receive user interaction events from the event
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

#ifdef DEBUG

#pragma mark - Debugging
/** @name Debugging */

/**
 @brief Prints a debug log of the node's branch on the console (only available in debug mode)
 */
- (void)debugLogBranch;

#endif

@end
