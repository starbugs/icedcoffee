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

#import "ICNodeVisitorProjectionPicking.h"
#import "ICNode.h"
#import "icDefaults.h"

@implementation ICNodeVisitorProjectionPicking

- (id)init
{
    if ((self = [super init])) {
        _resultNodeStack = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_resultNodeStack release];
    [super dealloc];
}

- (void)beginWithPickPoint:(CGPoint)point viewport:(GLint *)viewport
{
    [self pushPickContext:[ICPickContext pickContextWithPoint:point viewport:viewport]];

    // Initially, clear the result node stack as we are starting a new hit test
    [_resultNodeStack removeAllObjects];
}

- (void)end
{
    [self popPickContext];
}

- (NSArray *)hitNodes
{
    return _resultNodeStack;
}

- (void)visit:(ICNode *)node
{
#if IC_ENABLE_DEBUG_PICKING
    ICLog(@"Picking visitor visit: %@", [node description]);
#endif
    
    
    // Visit node's branch
    _currentRoot = node;
    [self visitNode:node];
}

- (BOOL)visitSingleNode:(ICNode *)node
{
    if ([node conformsToProtocol:@protocol(ICProjectionTransforms)]) {
        ICNode<ICProjectionTransforms> *transformable = (ICNode<ICProjectionTransforms> *)node;
        kmVec3 pointInNode = [transformable hostViewToNodeLocation:[self currentPickPoint]];
        if (pointInNode.x >= 0 && pointInNode.y >= 0 &&
            pointInNode.x < transformable.size.x && pointInNode.y < transformable.size.y) {
#if IC_ENABLE_DEBUG_PICKING
            ICLog(@"Picking visitor: hit node %@", [node description]);
#endif            
            [_resultNodeStack addObject:node];
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

@end
