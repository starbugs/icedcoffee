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
//  Note: node visitors have been inspired by those implemented in the cocos3d project.

#import <Foundation/Foundation.h>

@class ICNode;

/**
 @brief Abstract node visitor used for traversing an icedcoffee scene graph
 
 ICNodeVisitor is an abstract base class providing the foundation for icedcoffee's
 node visitation system. A node visitor is used to traverse a given scene graph and
 process its nodes for a certain purpose.
 
 icedcoffee ships with two built-in node visitors: ICNodeVisitorDrawing is used
 by the framework to draw scene graphs on a framebuffer whereas ICNodeVisitorPicking
 is used to perform hit tests.
 */
@interface ICNodeVisitor : NSObject {
@protected
    ICNode *_currentRoot;
    ICNode *_owner;
    BOOL _skipChildren;
}


#pragma mark - Initializing a Node Visitor
/** @name Initializing a Node Visitor */

/**
 @brief Initializes the receiver with the given owner node
 
 The owner is assigned to the receiver for its complete lifecycle. The receiver does not retain
 the owner so as to avoid retain cycles. It is the responsibility of the visitor's owner to
 deallocate the visitor before the owner is deallocated.
 
 @param owner An ICNode object representing the receiver's owner. You may specifiy nil for this
 parameter to indicate that the receiver does not have an owner.
 */
- (id)initWithOwner:(ICNode *)owner;


#pragma mark - Obtaining the Node Visitor's Owner
/** @name Obtaining the Node Visitor's Owner */

/**
 @brief The receiver's owner node
 */
@property (nonatomic, readonly) ICNode *owner;


#pragma mark - Performing Visitation
/** @name Performing Visitation */

/**
 @brief Performs visitation of the scene graph rooted in the given node
 
 This method invokes the visitor on a given scene graph rooted in <code>node</code>.
 It is the only method to be called from outside the class.
 
 @param node The root node of the scene graph to be traversed by the receiver.
 Typically this is an ICScene object.
 */
- (void)visit:(ICNode *)node;

/**
 @brief Instructs the receiver to skip visitation on the children of the currently visited node
 */
- (void)skipChildren;


// To be overridden in subclasses:

/**
 @brief Invokes visitation of the given node and its descendants
 
 Invokes the following methods sequentially:
 <ol>
    <li>ICNodeVisitor::preVisitNode:,</li>
    <li>ICNodeVisitor::visitSingleNode:,</li>
    <li>ICNodeVisitor::visitChildrenOfNode: (only if the previous call returned YES),</li>
    <li>ICNodeVisitor::postVisitNode:,</li>
 </ol>
 thereby traversing the <code>node</code>'s descendants recursively.
 */
- (void)visitNode:(ICNode *)node;

/**
 @brief Sets up the environment for visiting the given node
 
 Called by ICNodeVisitor::visitNode: before ICNodeVisitor::visitSingleNode: is called.
 Override this method in a subclass to set up the environment for visition of the given node.
 */
- (void)preVisitNode:(ICNode *)node;

/**
 @brief Performs visitation on the given node (and only on that single node)
 
 Called by ICNodeVisitor::visitNode: after ICNodeVisitor::preVisitNode: has been called.
 Override this method in a subclass to implement visitation of a single node.
 
 @return Overriding methods should return YES if the node's children should be visited by the
 receiver after this method completes or NO if the node's children should be skipped. The
 default implementation always returns YES.
 */
- (BOOL)visitSingleNode:(ICNode *)node;

/**
 @brief Performs visitation on the children of a node
 
 Called by ICNodeVisitor::visitNode: after ICNodeVisitor::visitSingleNode: has been called.
 Override this method in a subclass to implement visitation of the children of the given node.
 */
- (void)visitChildrenOfNode:(ICNode *)node;

/**
 @brief Cleans up the environment after visiting the given node
 
 Called by ICNodeVisitor::visitNode: after ICNodeVisitor::visitChildrenOfNode: has been called.
 Override this method in a subclass to clean up the environment after the given node and its
 descendants have been visited.
 */
- (void)postVisitNode:(ICNode *)node;


@end
