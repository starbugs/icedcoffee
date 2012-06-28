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
//  Note: node visitors have been inspired by those implemented in the cocos3d project.

#import <Foundation/Foundation.h>

@class ICNode;

typedef enum _ICNodeVisitorType {
    kICUnknownNodeVisitor,
    kICPickingNodeVisitor,
    kICDrawingNodeVisitor
} ICNodeVisitorType;

/**
 @brief Abstract node visitor used for traversing an IcedCoffee scene graph
 
 ICNodeVisitor is an abstract base class providing the foundation for IcedCoffee's
 node visitation system. A node visitor is used to traverse a scene graph and
 process its nodes.
 
 IcedCoffee ships with two built-in node visitors: ICNodeVisitorDrawing is used
 by the framework to draw scene graphs on a frame buffer whereas ICNodeVisitorPicking
 is used to perform hit tests.
 */
@interface ICNodeVisitor : NSObject {
@protected
    ICNodeVisitorType _visitorType;
    ICNode *_currentRoot;
}

@property (nonatomic, readonly) ICNodeVisitorType visitorType;

/**
 @brief Performs visitation starting with the specified node
 
 This method invokes the visitor on a given scene graph rooted in <code>node</code>.
 It is the only method to be called from outside the class.
 
 @param node The root node of the scene graph to traverse using the visitor. Typically this
 is an ICScene object.
 */
- (void)visit:(ICNode *)node;


// To be overridden in subclasses

/**
 @brief Invokes visitation of the given node internally
 
 Invokes the following methods (with argument <code>self</code>) sequentially:
 <ol>
    <li>ICNodeVisitor::preVisitNode:,</li>
    <li>ICNodeVisitor::visitSingleNode:,</li>
    <li>ICNodeVisitor::visitChildrenOfNode:,</li>
    <li>ICNodeVisitor::postVisitNode:,</li>
 </ol>
 thereby traversing the <code>node</code>'s descendants recursively.
 */
- (void)visitNode:(ICNode *)node;

/**
 @brief Called by ICNodeVisitor::visitNode: before ICNodeVisitor::visitSingleNode is called
 */
- (void)preVisitNode:(ICNode *)node;

/**
 @brief Called by ICNodeVisitor::visitNode: after ICNodeVisitor::preVisitNode: has been called
 */
- (void)visitSingleNode:(ICNode *)node;

/**
 @brief Called by ICNodeVisitor::visitNode: after ICNodeVisitor::visitSingleNode: has been called
 */
- (void)visitChildrenOfNode:(ICNode *)node;

/**
 @brief Called by ICNodeVisitor::visitNode: after ICNodeVisitor::visitChildrenOfNode: has been
 called
 */
- (void)postVisitNode:(ICNode *)node;


@end
