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

#import "ICNodeVisitor.h"
#import "ICNode.h"

@implementation ICNodeVisitor

@synthesize visitorType = _visitorType;

- (id)init
{
    if ((self = [super init])) {
        _visitorType = kICUnknownNodeVisitor;
    }
    return self;
}

- (void)visit:(ICNode *)node
{
    _currentRoot = node;
    [self visitNode:node];
}

- (void)visitNode:(ICNode *)node
{
    if (node.isVisible) {
        [self preVisitNode:node];
        [self visitSingleNode:node];
        [self visitChildrenOfNode:(ICNode *)node];
        [self postVisitNode:node];
    }
}

- (void)preVisitNode:(ICNode *)node
{
    // Implement in subclass
}

- (void)postVisitNode:(ICNode *)node
{
    // Implement in subclass    
}

- (void)visitSingleNode:(ICNode *)node
{
    // Implement in subclass
}

- (void)visitChildrenOfNode:(ICNode *)node
{
    // Important: using ICNode's _children ivar for enumeration since ICView may re-route
    // ICNode::children (and other composition related methods) to its render texture
    // backing scene's children.    
    for (ICNode *child in node->_children) {
        [self visitNode:child];
    }    
}

@end
