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

#import "ICNodeVisitorPicking.h"
#import "ICNode.h"
#import "ICRenderTexture.h"
#import "icMacros.h"
#import "icConfig.h"

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
        _renderTexture = [[ICRenderTexture alloc] initWithWidth:1.0f/IC_CONTENT_SCALE_FACTOR()
                                                         height:1.0f/IC_CONTENT_SCALE_FACTOR()
                                                    pixelFormat:kICPixelFormat_RGBA8888
                                              depthBufferFormat:kICDepthBufferFormat_24
                                            stencilBufferFormat:kICStencilBufferFormat_8];
                
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

- (GLint *)viewport
{
    return _viewport;
}

- (void)setViewport:(GLint *)viewport
{
    memcpy(_viewport, viewport, sizeof(GLint)*4);
}

- (void)beginWithPickPoint:(CGPoint)point viewport:(GLint *)viewport
{
    self.pickPoint = point;
    self.viewport = viewport;
    [_renderTexture begin];
}

- (BOOL)isInPickingContext
{
    return [_renderTexture isInRenderTextureDrawContext];
}

- (void)end
{
    _pickPoint = CGPointMake(0, 0);
    [_renderTexture end];
}

- (void)visit:(ICNode *)node
{
#if IC_ENABLE_DEBUG_PICKING
    ICLOG(@"Picking visitor visit: %@", [node description]);
#endif
    
    [_resultNodeStack removeAllObjects];
    [super visit:node];
    _nodeIndex = 1;
}

// Note: called by ICNodeVisitor super class only if node is visible
- (void)visitSingleNode:(ICNode *)node
{
    if ([node userInteractionEnabled]) {
#if IC_ENABLE_DEBUG_PICKING
        ICLOG(@"Picking visitor visitSingleNode: %@", [node description]);
#endif
        
        [node drawWithVisitor:self];
        glFlush();
        
        icColor4B color = [_renderTexture colorOfPixelAtLocation:CGPointMake(0, 0)];
        ICNode *resultNode = [self nodeForPickColor:color];
        if (resultNode && ![_resultNodeStack containsObject:resultNode]) {
#if IC_ENABLE_DEBUG_PICKING
            ICLOG(@"Picking visitor: hit node %@", [resultNode description]);
#endif
            // Push result node on stack
            [_resultNodeStack addObject:resultNode];
            // Append nodes picked from a render texture FBO after adding the result node
            // to maintain correct order of pick results
            for (ICNode *appendNode in _appendNodesToStack) {
                [_resultNodeStack addObject:appendNode];
            }
            [_appendNodesToStack removeAllObjects];
        }                
    } else {
#if IC_ENABLE_DEBUG_PICKING
        ICLOG(@"Picking visitor: user interaction disabled for node: %@", [node description]);
#endif        
    }
    
    // Increment node index to get a different pick color for each node
    _nodeIndex++;
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
        // ICNodeVisitor super class calls visitSingleNode: only if node is visible -- we need
        // to resemble this here in order to yield correct node indices
        if (child.isVisible) {
            (*index)++; // index begins with 1
            ICNode *resultNode = [self findNodeForPickColor:color withNode:child index:index];
            if (resultNode) {
                return resultNode;
            }
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
