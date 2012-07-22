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
 @brief Base class for drawable nodes in a scene
 
 <h3>Overview</h3>
 
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
    on an internal picking framebuffer. ICNode provides a standard way of setting up shaders
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
    kmVec3 _size;
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
@brief Initializes the receiver
 
@note This is the designated initializer of the ICNode class.
*/
- (id)init;


#pragma mark - Composition
/** @name Composition */

/**
 @brief Returns an array containing the receiver's children nodes
 */
@property (nonatomic, readonly, getter=children) NSArray *children;

/**
 @brief Returns an array containing the receiver's children nodes to be used for drawing
 */
- (NSArray *)drawingChildren;

/**
 @brief Returns an array containing the receiver's children nodes to be used for picking
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
 */
@property (nonatomic, assign, setter=setParent:) ICNode *parent;

/**
 @brief Adds a child node to the receiver's children array
 
 @param child A reference to a valid ICNode object. When added, the object is retained.
 */
- (void)addChild:(ICNode *)child;

/**
 @brief Inserts a child node at a specific index in the receiver's children array
 
 @param child A reference to a valid ICNode object. When inserted, the object is retained.
 @param index An int specifying an index position into the node's children array.
 */
- (void)insertChild:(ICNode *)child atIndex:(uint)index;

/**
 @brief Removes a child node from the receiver's children array
 
 @param child A reference to a valid ICNode object. When removed, the object is released.
 */
- (void)removeChild:(ICNode *)child;

/**
 @brief Removes a child node specified by an index into the receiver's children array
 
 @param index An int specifying the index of the child node to be removed. When removed,
 the object will be released.
 */
- (void)removeChildAtIndex:(uint)index;

/**
 @brief Removes all children from the receiver
 */
- (void)removeAllChildren;

/**
 @brief A boolean value indicating whether the receiver has children
 
 @return Returns YES when the receiver has children or NO if it does not have any children.
 */
- (BOOL)hasChildren;

/**
 @brief Returns the receiver's immediate child for the specified tag
 */
- (ICNode *)childForTag:(uint)tag;

/**
 @brief Returns all children of the receiver that are kind of the specified class
 */
- (NSArray *)childrenOfType:(Class)classType;

/**
 @brief Returns all children of the receiver that are not kind of the specified class
 */
- (NSArray *)childrenNotOfType:(Class)classType;

/**
 @brief Returns an array containing all ancestor nodes
 
 @return Returns an NSArray of ICNode objects, ordered ascending beginning with the first
 ancestor node.
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
- (NSArray *)ancestorsFilteredUsingBlock:(BOOL (^)(ICNode *node, BOOL *stop))filterBlock;

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
- (NSArray *)descendantsFilteredUsingBlock:(BOOL (^)(ICNode *node, BOOL *stop))filterBlock;

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

- (ICNode<ICFramebufferProvider> *)framebufferProvider;

/**
 @brief The host view controller of the receiver's root scene
 
 This method invokes rootScene, asks it for its ICHostViewController object and returns the result.
 */
- (ICHostViewController *)hostViewController;


#pragma mark - Transforms
/** @name Transforms */

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
 @brief Sets the position of the receiver
 
 @param position A kmVec3 defining the position of the receiver relative to its parent's node space
 */
- (void)setPosition:(kmVec3)position;

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
 @brief Sets the position of the receiver so as to center it in its parent node's space
 
 @note Both the receiver and its parent must have a valid ICNode::size for this method
 to work correctly.
 */
- (void)centerNode;

/**
 @brief Sets the position of the receiver so as to center it vertically in its parent node's space
 
 @note Both the receiver and its parent must have a valid ICNode::size for this method
 to work correctly.
 */
- (void)centerNodeVertically;

/**
 @brief Sets the position of the receiver so as to center it horizontally in its parent node's space
 
 @note Both the receiver and its parent must have a valid ICNode::size for this method
 to work correctly.
 */
- (void)centerNodeHorizontally;

/**
 @brief Returns the position of the receiver
 */
- (kmVec3)position;

/**
 @brief Sets the anchor point of the receiver in its local node space
 */
- (void)setAnchorPoint:(kmVec3)anchorPoint;

/**
 @brief Centers the anchor point of the receiver based on its ICNode::size property
 */
- (void)centerAnchorPoint;

/**
 @brief The anchor point of the receiver in its own local node space
 */
- (kmVec3)anchorPoint;

/**
 @brief Sets the size of the receiver
 */
- (void)setSize:(kmVec3)size;

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
 @brief Returns the size of the receiver
 */
- (kmVec3)size;

/**
 @brief Sets the receiver's scale
 */
- (void)setScale:(kmVec3)scale;

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
 @brief Returns the scale of the node
 */
- (kmVec3)scale;

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


#pragma mark - Order
/** @name Order */

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


#pragma mark - Bounds
/** @name Bounds */

/**
 @brief The receiver's axis-aligned bounding box
 
 This method calculates the receiver's axis-aligned bounding box in its parent node
 coordinate space.
 
 @remarks The calculations performed by this method are based on the ICNode::position and
 ICNode::size properties. For this method to work correctly, the following preconditions
 must be met:
 <ul>
     <li>The receiver's ICNode::size property must be set correctly, that is, covering
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
 @brief Returns the rectangular bounds of the receiver
 
 By default, the bounds of the receiver are defined as a rectangle with origin (0,0) and
 size (size.x,size.y). Subclasses may override this method to define custom bounds.
 */
- (CGRect)bounds;

/**
 @brief The rectangle occupied by the receiver on its parent scene's framebuffer
 
 This method calculates the origin and size of the rectangle occupied by the node on its parent
 scene's framebuffer. The rectangle is always aligned to the framebuffer's axes. All coordinates
 are expressed in points rather than pixels.

 @remarks The calculations performed by this method are based on the ICNode::position and
 ICNode::size properties. For this method to work correctly, the following preconditions
 must be met:
 <ul>
    <li>The receiver's ICNode::size property must be set correctly, that is, covering
    the whole (cubic) space occupied by the receiver's visible contents.</li>
    <li>The receiver must have been added to a valid ICScene object before this method is
    called.</li>
    <li>The parent scene of the receiver must have a valid target framebuffer.</li>
 </ul>
 
 @return Returns a CGRect defining the rectangle (in points) occupied by the node's visible
 contents. If the method fails to calculate the node's frame rect, a zero CGRect is returned.
 When this happens, most likely one or many of the preconditions outlined above have not been met.
 */
- (CGRect)frameRect;


#pragma mark - Drawing and Picking
/** @name Drawing and Picking */

/**
 @brief The receiver's shader program, including vertex and fragment shader
 */
@property (nonatomic, retain) ICShaderProgram *shaderProgram;

/**
 @brief A BOOL property indicating whether the receiver is visible
 
 Invisible nodes are not drawn and do not receive user interaction events by the framework.
 */
@property (nonatomic, assign) BOOL isVisible;

/**
 @brief Applies a standard draw setup with the specified visitor
 
 This method should be called at the beginning of ICNode::drawWithVisitor: to ensure that an
 appropriate standard drawing setup is applied to the current OpenGL context. The default
 implementation sets up vertex and fragment shader programs pertaining to the specified
 visitor. For non-picking visitors, the method applies the shader set in ICNode::shaderProgram,
 for picking visitors the method looks up the default picking shader (keyed kICShader_Picking)
 using ICShaderCache and applies it.
 */
- (void)applyStandardDrawSetupWithVisitor:(ICNodeVisitor *)visitor;

/**
 @brief Draws the receiver
 
 This method is called by the framework to draw the receiver using a visitor. You should
 never call this method directly unless you know what you are doing.
 
 The default implementation does nothing.

 @param visitor The ICNodeVisitor instance used to visit the node
 
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
 
 Called by the framework when all children nodes have been drawn completely. You may override
 this method to reset states that have been set in ICNode::drawWithVisitor: and were not reset
 for drawing the receiver's children.
 */
- (void)childrenDidDrawWithVisitor:(ICNodeVisitor *)visitor;

/**
 @brief Informs the framework that the receiver needs to be redrawn
 
 This method needs to be called only if the node is part of a drawing environment that does not
 redraw all its contents continuously. The default implementation simply calls
 ICNode::setNeedsDisplay on its parent. Specialized classes implementing updatable framebuffers
 such as ICRenderTexture should override this method in order to implement conditional redrawing.
 */
- (void)setNeedsDisplay;


#pragma mark - Ray-based Hit Testing
/** @name Ray-based Hit Testing */

/**
 @brief Performs a local ray-based hit test on the receiver
 
 To be implemented in subclasses. The default implementation does nothing and returns
 ICHitTestUnsupported.
 
 Subclasses implementing this method should perform a hit test based on some approximation
 of the node's geometry and the specified ray.
 
 @param ray An icRay3 object defining the ray to be used for hit testing in the receiver's local
 coordinate space.
 */
- (ICHitTestResult)localRayHitTest:(icRay3)ray;


#pragma mark - User Interaction Support
/** @name User Interaction Support */

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
