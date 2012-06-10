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

#import "ICNodeVisitorPicking.h"
#import "ICNode.h"
#import "ICRenderTexture.h"

@interface ICNodeVisitorPicking (Private)
- (ICNode *)findNodeForPickColor:(icColor4B)color withNode:(ICNode *)node index:(uint32_t *)index;
- (ICNode *)nodeForPickColor:(icColor4B)color;
@end

@implementation ICNodeVisitorPicking

@synthesize resultNodeStack = _resultNodeStack;
@synthesize pickPoint = _pickPoint;

- (id)init
{
    if ((self = [super init])) {
        _visitorType = kICPickingNodeVisitor;
        _nodeIndex = 1;
        // FIXME: enable depth buffer only if host view controller provides depth buffer support(?)
        _renderTexture = [[ICRenderTexture alloc] initWithWidth:1
                                                         height:1
                                                    pixelFormat:kICPixelFormat_RGBA8888
                                              depthBufferFormat:kICDepthBufferFormat_16];
        _resultNodeStack = [[NSMutableArray alloc] init];
        _appendNodesToStack = [[NSMutableArray alloc] init];
        _pickPoint = CGPointMake(0, 0);
    }
    return self;    
}

- (void)dealloc
{
    [_renderTexture release];
    [_resultNodeStack release];
    [_appendNodesToStack release];
    [super dealloc];
}

- (void)beginWithPickPoint:(CGPoint)point
{
    _pickPoint = point;
    [_renderTexture begin];
}

- (void)end
{
    _pickPoint = CGPointMake(0, 0);
    [_renderTexture end];
}

- (void)visit:(ICNode *)node
{
    //NSLog(@"Picking visitor visit: %@", [node description]);
    
    [_resultNodeStack removeAllObjects];
    [super visit:node];
    _nodeIndex = 1;
}

- (void)visitSingleNode:(ICNode *)node
{
    if ([node isVisible] && [node userInteractionEnabled]) {
        //NSLog(@"Picking visitor visitSingleNode: %@", [node description]);
        
        [node drawWithVisitor:self];
        glFlush();
        
        icColor4B color = [_renderTexture colorOfPixelAtLocation:CGPointMake(0, 0)];
        ICNode *resultNode = [self nodeForPickColor:color];
        if (resultNode && ![_resultNodeStack containsObject:resultNode]) {
            //NSLog(@"Picking visitor: hit node %@", [resultNode description]);
            // Push result node on stack
            [_resultNodeStack addObject:resultNode];
            // Append nodes picked from a render texture FBO after adding the result node
            // to maintain correct order of pick results
            for (ICNode *appendNode in _appendNodesToStack) {
                [_resultNodeStack addObject:appendNode];
            }
            [_appendNodesToStack removeAllObjects];
        }
                
        _nodeIndex++;
    }
}

- (icColor4B)pickColor
{
    icColor4B result = *((icColor4B *)&_nodeIndex);
    return result;
}

- (ICNode *)findNodeForPickColor:(icColor4B)color withNode:(ICNode *)node index:(uint32_t *)index
{
    if (memcmp(index, &color, sizeof(icColor4B)) == 0) {
        // Colors are equal
        return node;
    }
    
    // Important: using ICNode's _children ivar for enumeration since ICView may re-route
    // ICNode::children (and other composition related methods) to its render texture
    // backing scene's children.
    for (ICNode *child in node->_children) {
        (*index)++;
        ICNode *resultNode = [self findNodeForPickColor:color withNode:child index:index];
        if (resultNode) {
            return resultNode;
        }
    }
    
    // No node with matching color code found
    return nil;
}

- (ICNode *)nodeForPickColor:(icColor4B)color
{
    uint32_t index = 1;
    return [self findNodeForPickColor:color withNode:_currentRoot index:&index];
}

- (void)appendNodesToResultStack:(NSArray *)nodes
{
    for (ICNode *node in nodes) {
        [_appendNodesToStack addObject:node];
    }
}

@end
