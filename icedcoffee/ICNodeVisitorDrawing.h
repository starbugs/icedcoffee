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
#import "ICNodeVisitor.h"

/**
 @brief Node visitor for drawing a scene graph on an OpenGL framebuffer
 */
@interface ICNodeVisitorDrawing : ICNodeVisitor


#pragma mark - Visiting a Scene for Drawing
/** @name Visiting a Scene for Drawing */

/**
 @brief Sets up the node's model-view transform matrix and pushes it on the OpenGL matrix stack
 */
- (void)preVisitNode:(ICNode *)node;

/**
 @brief Draws a single node to the OpenGL framebuffer
 */
- (BOOL)visitSingleNode:(ICNode *)node;

/**
 @brief Performs visitation on the children of the given node
 */
- (void)visitChildrenOfNode:(ICNode *)node;

/**
 @brief Pops the node's model-view transform matrix from the OpenGL matrix stack
 */
- (void)postVisitNode:(ICNode *)node;

@end
