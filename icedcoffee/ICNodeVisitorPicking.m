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

#import "ICNodeVisitorPicking.h"
#import "ICNode.h"
#import "ICHostViewController.h"
#import "ICRenderTexture.h"
#import "icMacros.h"
#import "icConfig.h"
#import "ICConfiguration.h"
#import "icUtils.h"
#import "ICScene.h"
#import "ICCamera.h"

enum {
    InternalModeSingleNodes = 1,
    InternalModeContainers = 2,
    InternalModeFinalNode = 3
};

@interface ICNodeVisitorPicking (Private)
- (void)begin;
- (BOOL)isInPickingContext;
- (void)end;
- (NSArray *)hitNodes;
- (ICNode *)nodeForPickColor:(icColor4B)color;
- (CGPoint)pixelLocationForNodeIndex:(uint32_t)nodeIndex;
- (void)setUpScissorTestForPixelAtLocation:(CGPoint)location;
- (void)tearDownScissorTest;
- (void)pushRay:(icRay3)ray;
- (void)popRay;
- (icRay3 *)currentRay;
@end

@implementation ICNodeVisitorPicking

@synthesize renderTextureSizeInPixels = _renderTextureSizeInPixels;
@synthesize usesAuxiliaryOpenGLContext = _usesAuxiliaryOpenGLContext;

- (id)initWithOwner:(ICNode *)owner
{
    return [self initWithOwner:owner useAuxiliaryOpenGLContext:YES];
}

- (id)initWithOwner:(ICNode *)owner useAuxiliaryOpenGLContext:(BOOL)useAuxContext
{
    if ((self = [super initWithOwner:owner])) {
        _nodeCount = 0;
        _nodeIndex = 0;
        _renderTextureSizeInPixels = CGSizeMake(0, 0);
        _pickContextStack = [[NSMutableArray alloc] init];
        _rayStack = [[NSMutableArray alloc] init];
        _usesAuxiliaryOpenGLContext = useAuxContext;
        
        ICHostViewController *hostViewController = owner.hostViewController;
        NSAssert(hostViewController != nil,
                 @"No host view controller could be determined. " \
                 "This occurs if the owner has not yet been added to a scene or " \
                 "the owner's scene has not yet been assigned to a host view controller.");
        
        if (_usesAuxiliaryOpenGLContext) {
            // Create an auxiliary OpenGL context which will be used for writing pick colors
            // to a render texture and performing readbacks
            _auxGLContext = icCreateAuxGLContextForView((ICGLView *)hostViewController.view, YES);
        }
    }
    return self;
}

- (void)dealloc
{
    [_auxGLContext unregisterContext];
    [_auxGLContext release];
    _auxGLContext = nil;
    
    [_renderTexture release];
    [_pickContextStack release];
    [_rayStack release];
    
    if (_clientData) {
        free(_clientData);
    }
    
    [super dealloc];
}

- (void)pushRay:(icRay3)ray
{
    icRay3 *rayToPush = malloc(sizeof(icRay3));
    memcpy(rayToPush, &ray, sizeof(icRay3));
    [_rayStack addObject:[NSValue valueWithPointer:rayToPush]];
}

- (void)popRay
{
    icRay3 *rayToPop = [self currentRay];
    if (rayToPop) {
        free(rayToPop);
        [_rayStack removeLastObject];
    }
}

- (icRay3 *)currentRay
{
    return [[_rayStack lastObject] pointerValue];
}

- (void)setRenderTextureSizeInPixels:(CGSize)renderTextureSizeInPixels
{
    if (renderTextureSizeInPixels.width != _renderTextureSizeInPixels.width ||
        renderTextureSizeInPixels.height != _renderTextureSizeInPixels.height) {
        
        _renderTextureSizeInPixels = renderTextureSizeInPixels;
        
        [_renderTexture release];
        _renderTexture = [[ICRenderTexture alloc] initWithWidth:ICPixelsToPoints(renderTextureSizeInPixels.width)
                                                         height:ICPixelsToPoints(renderTextureSizeInPixels.height)
                                                    pixelFormat:ICPixelFormatRGBA8888
                                              depthBufferFormat:ICDepthBufferFormat24
                                            stencilBufferFormat:ICStencilBufferFormat8];
        
        if (_clientData) {
            free(_clientData);
            _clientData = NULL;
        }
        
        if (![[ICConfiguration sharedConfiguration] supportsCVOpenGLESTextureCache]) {
            _clientData = malloc([self renderTextureMemorySize]);
        }
        
        [_pickNodes release];
        _pickNodes = [[NSMutableArray alloc] init];
    }
}

- (uint)renderTextureCapacity
{
    return _renderTextureSizeInPixels.width * _renderTextureSizeInPixels.height;
}

- (uint)renderTextureMemorySize
{
    return [self renderTextureCapacity] * 4;
}

- (GLint *)viewport
{
    return _viewport;
}

- (void)setViewport:(GLint *)viewport
{
    memcpy(_viewport, viewport, sizeof(GLint)*4);
}

- (void)pushPickContext:(ICPickContext *)pickContext
{
    [_pickContextStack addObject:pickContext];
}

- (void)popPickContext
{
    [_pickContextStack removeLastObject];
}

- (ICPickContext *)currentPickContext
{
    return [_pickContextStack lastObject];
}

- (CGPoint)currentPickPoint
{
    return [(ICPickContext *)[_pickContextStack lastObject] point];
}

- (GLint *)currentViewport
{
    return [(ICPickContext *)[_pickContextStack lastObject] viewport];
}

- (void)begin
{    
    if (!_renderTexture) {
        [self setRenderTextureSizeInPixels:IC_DEFAULT_PICKING_RT_SIZE_IN_PIXELS];
    }
            
    [_renderTexture begin];
}

- (BOOL)isInPickingContext
{
    return [_renderTexture isInRenderTextureDrawContext];
}

- (void)end
{    
    [_renderTexture end];
}

- (NSArray *)performPickingTestWithNode:(ICNode *)node
                                  point:(CGPoint)point
                               viewport:(GLint *)viewport
                       deferredReadback:(BOOL)deferredReadback
{
    NSArray *hitNodes = nil;
    
    ICOpenGLContext *oldContext = nil;
    if (_usesAuxiliaryOpenGLContext) {
        oldContext = [ICOpenGLContext currentContext];
        [_auxGLContext makeCurrentContext];
    }
    
    if ([node isKindOfClass:[ICScene class]]) {
        // Compute initial ray for ray-based hit testing
        [self pushRay:[((ICScene *)node) worldRayFromFramebufferLocation:point]];
    }
    
    // Push a pick context consisting of the given point and viewport
    [self pushPickContext:[ICPickContext pickContextWithPoint:point viewport:viewport]];
    // Bind the render texture's framebuffer
    [self begin];
    // Perform visitation
    [self visit:node];
    if (!deferredReadback) {
        // Retrieve hit nodes synchronously
        hitNodes = [self hitNodes];
    } else {
#ifdef __IC_PLATFORM_MAC
        uint pboMemorySize = ICPointsToPixels(_renderTexture.size.width) *
                             ICPointsToPixels(_renderTexture.size.height) * 4;
        if (!_pbo) {
            glGenBuffers(1, &_pbo);
            glBindBuffer(GL_PIXEL_PACK_BUFFER, _pbo);
            glBufferData(GL_PIXEL_PACK_BUFFER, pboMemorySize, 0, GL_STREAM_READ);
            glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);
            IC_CHECK_GL_ERROR_DEBUG();    
        }
        glBindBuffer(GL_PIXEL_PACK_BUFFER, _pbo);
        glReadPixels(0, 0,
                     ICPointsToPixels(_renderTexture.size.width),
                     ICPointsToPixels(_renderTexture.size.height),
                     GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, 0);
        glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);
        IC_CHECK_GL_ERROR_DEBUG();
        _asyncReadbackIssued = YES;
#elif defined(__IC_PLATFORM_IOS)
        NSAssert(nil, @"Asynchronous readback is not available on iOS");
#endif
    }
    // Bind the old framebuffer
    [self end];
    // Pop the pick context
    [self popPickContext];
    
    if (_usesAuxiliaryOpenGLContext) {
        if (oldContext)
            [oldContext makeCurrentContext];
        else
            [ICOpenGLContext clearCurrentContext];
    }
    
    return hitNodes;
}

- (void)visit:(ICNode *)node
{
    // Reset node index for next run
    _nodeIndex = 0;
    
    // Reset pick nodes
    [_pickNodes removeAllObjects];
    
#if IC_ENABLE_DEBUG_PICKING
    ICLog(@"Picking visitor visit: %@", [node description]);
#endif

    // Clear color and (optionally) depth buffers
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClearDepth(1.0f);
    glClearStencil(0);
    
    GLbitfield clearFlags = GL_COLOR_BUFFER_BIT |  GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT;
    glClear(clearFlags);
    IC_CHECK_GL_ERROR_DEBUG();

#if IC_ENABLE_DEBUG_PICKING
    ICLog(@"=====================");
    ICLog(@"Computing single hits");
    ICLog(@"=====================");
#endif
    
    // Visit each node in node's branch
    _internalMode = InternalModeSingleNodes;
    [super visit:node];
    
    // Note count of nodes from this run
    _nodeCount = _nodeIndex;
    
#if IC_ENABLE_DEBUG_PICKING
    ICLog(@"===================");
    ICLog(@"Computing final hit");
    ICLog(@"===================");
#endif

    // Reset node index for next run
    _nodeIndex = 0;

    _internalMode = InternalModeFinalNode;
    [self setUpScissorTestForPixelAtLocation:[self pixelLocationForNodeIndex:_nodeCount]];
    [super visit:node];
    [self tearDownScissorTest];
}

// Note: called by ICNodeVisitor super class only if node is visible
- (BOOL)visitSingleNode:(ICNode *)node
{
    if ([node userInteractionEnabled]) {
        
        ICHitTestResult hitTestResult = ICHitTestUnsupported;
        
#if IC_ENABLE_RAY_BASED_HIT_TESTS
        if ([self currentRay]) {
            icRay3 transformedRay = *[self currentRay];
            transformedRay.origin = [node convertToNodeSpace:transformedRay.origin];
            transformedRay.direction = [node convertToNodeSpace:transformedRay.direction];
            hitTestResult = [node localRayHitTest:transformedRay];
#if IC_ENABLE_DEBUG_PICKING
            if (hitTestResult == ICHitTestFailed) {
                ICLog(@"Picking visitor ray hit test failed for node: %@", [node description]);
            }
#endif // IC_ENABLE_DEBUG_PICKING
        }
#endif // IC_ENABLE_RAY_BASED_HIT_TESTS
        
        if (hitTestResult != ICHitTestFailed) {
            
            // Simple ray-based hit test succeeded, proceed with picking test
            CGPoint nodePixelLocation;
            if (_internalMode == InternalModeSingleNodes) {
                // Set up scissor test, so we draw only to the pixel reserved for the node while picking
                nodePixelLocation = [self pixelLocationForNodeIndex:_nodeIndex];
                [self setUpScissorTestForPixelAtLocation:nodePixelLocation];
            } else {
#if IC_ENABLE_DEBUG_PICKING
                nodePixelLocation = [self pixelLocationForNodeIndex:_nodeCount];
#endif
            }

#if IC_ENABLE_DEBUG_PICKING
            GLint *viewport = [self currentViewport];
            CGPoint point = [self currentPickPoint];
            ICLog(@"Picking visitor color-based picking (i=%d, c=%04X, x=%f, y=%f, point=(%f,%f), viewport=(%d,%d,%d,%d)): %@",
                  _nodeIndex, _nodeIndex, nodePixelLocation.x, nodePixelLocation.y,
                  point.x, point.y, viewport[0], viewport[1], viewport[2], viewport[3],
                  [node description]);
#endif
            
            // Draw the node for picking
            [node drawWithVisitor:self];
            
#if IC_ENABLE_DEBUG_PICKING
            icColor4B color = [_renderTexture colorOfPixelAtLocation:nodePixelLocation];
            ICLog(@"Color after drawing is: %04X", *((uint *)&color));
#endif
            
            if (_internalMode == InternalModeSingleNodes) {
                // Assign node to color
                [_pickNodes addObject:node];
                
                // Tear down scissor test
                [self tearDownScissorTest];
            }

            // Increment node index to get a different pick color for each visited node
            _nodeIndex++;
            
        } else {
            // Simple hit test failed, skip tests on children
            [self skipChildren];
        }

    } else {
        
#if IC_ENABLE_DEBUG_PICKING
        ICLog(@"Picking visitor: user interaction disabled for node: %@", [node description]);
#endif  
        
    }
    
    if (_skipChildren) {
        _skipChildren = NO;
        return NO;
    }
    
    return YES;
}

- (void)visitChildrenOfNode:(ICNode *)node
{
    for (ICNode *child in [node pickingChildren]) {
        [self visitNode:child];
    }
    [node childrenDidDrawWithVisitor:self];
}

- (icColor4B)pickColor
{
    icColor4B result = *((icColor4B *)&_nodeIndex);
    return result;
}

- (ICNode *)nodeForPickColor:(icColor4B)color
{
    uint index = *((uint *)&color);
    if (index < [_pickNodes count]) {
        return [_pickNodes objectAtIndex:index];
    }
    return nil;
}

- (void)collectHitNodesIntoArray:(NSMutableArray *)resultNodes pixelData:(void *)data
{
    // Iterate over all pixels stored in the receiver's render texture. Each pixel represents
    // a node that was processed during picking visitation. The color of the respective pixel
    // identifies the corresponding ICNode object.
    uint32_t i = 0;
    for (; i<_nodeCount+1; i++) {
        icColor4B *color = (icColor4B *)&data[i*4];
        if ([[ICConfiguration sharedConfiguration] supportsCVOpenGLESTextureCache]) {
            // Convert BGRA to RGBA when using CoreVideo
            GLbyte r = color->r;
            color->r = color->b;
            color->b = r;
        }
        ICNode *node = [self nodeForPickColor:*color];
        if (node) {
            if (i == _nodeCount) {
                // Make sure the final hit is the last object in our result array
                if ([resultNodes containsObject:node]) {
                    [resultNodes removeObject:node];
                }
                [resultNodes addObject:node];
#if IC_ENABLE_DEBUG_PICKING
                ICLog(@"Picking visitor: final hit i=%d, color=%04X, %@",
                      i, *((uint32_t *)color), [node description]);
#endif            
            } else {
                if (![resultNodes containsObject:node]) {
#if IC_ENABLE_DEBUG_PICKING
                    ICLog(@"Picking visitor: hit i=%d, color=%04X, %@",
                          i, *((uint32_t *)color), [node description]);
#endif            
                    [resultNodes addObject:node];
                }
                
            }
        } else {
#if IC_ENABLE_DEBUG_PICKING
            ICLog(@"Picking visitor: no hit i=%d, color=%04X", i, *((uint32_t *)color));
#endif            
        }
    }
}

- (NSArray *)hitNodes
{
    NSMutableArray *resultNodes = [NSMutableArray array];    
    
#if IC_ENABLE_DEBUG_PICKING
    ICLog(@"Picking visitor: fetch hit nodes from render texture");
#endif

    // Read pixels from OpenGL framebuffer associated with our render texture
    if ([[ICConfiguration sharedConfiguration] supportsCVOpenGLESTextureCache]) {
#ifdef __IC_PLATFORM_IOS
        glFlush();
        
        // Optimized for iOS devices using CoreVideo
        CVReturn err = CVPixelBufferLockBaseAddress(_renderTexture.texture.cvRenderTarget, kCVPixelBufferLock_ReadOnly);
        if (err == kCVReturnSuccess) {
            uint8_t *pixels = (uint8_t *)CVPixelBufferGetBaseAddress(_renderTexture.texture.cvRenderTarget);
            [self collectHitNodesIntoArray:resultNodes pixelData:pixels];
        }
        CVPixelBufferUnlockBaseAddress(_renderTexture.texture.cvRenderTarget, kCVPixelBufferLock_ReadOnly);
#endif
    } else {
        // Standard readback on Mac or iOS simulator
        NSAssert(_clientData != NULL, @"No client buffer");
        
        CGRect rect = CGRectMake(0, 0, _renderTextureSizeInPixels.width, _renderTextureSizeInPixels.height);
        [_renderTexture readPixels:_clientData inRect:rect];
        
        [self collectHitNodesIntoArray:resultNodes pixelData:_clientData];
    }
    
    return resultNodes;
}

- (NSArray *)readHitNodesAsync
{
#ifdef __IC_PLATFORM_MAC
    NSMutableArray *resultNodes = [NSMutableArray array];
    
    if (_asyncReadbackIssued) {
        NSOpenGLContext *oldContext = nil;
        if (_usesAuxiliaryOpenGLContext) {
            oldContext = [NSOpenGLContext currentContext];
            [_auxGLContext makeCurrentContext];
        }    

#if IC_ENABLE_DEBUG_PICKING
        ICLog(@"Picking visitor: async fetch hit nodes from render texture");
#endif
        
        [_renderTexture begin];
        glBindBuffer(GL_PIXEL_PACK_BUFFER, _pbo);
        void *data = glMapBuffer(GL_PIXEL_PACK_BUFFER, GL_READ_ONLY);
        if (data) {
            [self collectHitNodesIntoArray:resultNodes pixelData:data];
            glUnmapBuffer(GL_PIXEL_PACK_BUFFER);
        }
        
        glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);
        IC_CHECK_GL_ERROR_DEBUG();    
        [_renderTexture end];
        
        // Reset async readback flag
        _asyncReadbackIssued = NO;
        
        if (_usesAuxiliaryOpenGLContext) {
            if (oldContext)
                [oldContext makeCurrentContext];
            else
                [NSOpenGLContext clearCurrentContext];
        }    
    } else {
#if IC_ENABLE_DEBUG_PICKING
        ICLog(@"Picking visitor: async readback not issued");
#endif        
    }
    
    return resultNodes;
    
#elif defined(__IC_PLATFORM_IOS)
    NSAssert(nil, @"Asynchronous readback is not available on iOS");
    return nil;
#endif
}

- (CGPoint)pixelLocationForNodeIndex:(uint32_t)nodeIndex
{
    float width = ICPointsToPixels(_renderTexture.size.width);
    int row = nodeIndex / width;
    int column = nodeIndex - row * width;
    return CGPointMake(column, row);
}

- (void)setUpScissorTestForPixelAtLocation:(CGPoint)location
{
    glScissor(location.x, location.y, 1, 1);
    glEnable(GL_SCISSOR_TEST);
}

- (void)tearDownScissorTest
{
    glDisable(GL_SCISSOR_TEST);
}

@end
