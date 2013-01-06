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

#import "ICScene.h"
#import "icDefaults.h"
#import "ICHostViewController.h"
#import "ICRenderTexture.h"
#import "kazmath/vec4.h"
#import "icUtils.h"
#import "icGL.h"
#import "icMacros.h"
#import "icConfig.h"
#import "icGLState.h"

#ifdef __IC_PLATFORM_IOS
#import "Platforms/iOS/ICGLView.h"
#elif defined(__IC_PLATFORM_MAC)
#import "Platforms/Mac/ICGLView.h"
#endif


@interface ICNode (Private)
- (void)setNeedsDisplayForNode:(ICNode *)node;
- (ICNodeVisitorDrawing *)defaultDrawingVisitor;
- (ICNodeVisitorPicking *)defaultPickingVisitor;
@end

@interface ICScene (Private)
- (void)adjustToFramebufferSize;
@end


@implementation ICScene

@synthesize hostViewController = _hostViewController;
@synthesize camera = _camera;
@synthesize drawingVisitor = _drawingVisitor;
@synthesize pickingVisitor = _pickingVisitor;
@synthesize renderTexture = _renderTexture;
@synthesize clearColor = _clearColor;
@synthesize clearsColorBuffer = _clearsColorBuffer;
@synthesize clearsDepthBuffer = _clearsDepthBuffer;
@synthesize clearsStencilBuffer = _clearsStencilBuffer;
@synthesize performsDepthTesting = _performsDepthTesting;
@synthesize performsFaceCulling = _performsFaceCulling;

+ (id)scene
{
    return [[[[self class] alloc] init] autorelease];
}

+ (id)sceneWithCamera:(ICCamera *)camera
{
    return [[[[self class] alloc] initWithCamera:camera] autorelease];
}

- (id)init
{
    ICCamera *camera = [[[IC_DEFAULT_CAMERA alloc] initWithViewport:CGRectNull] autorelease];
    return [self initWithCamera:camera];
}

- (id)initWithCamera:(ICCamera *)camera
{
    if ((self = [super init])) {
        // Note that initially, the scene is not assigned to a host view controller. This
        // must be done later so that it receives a valid size and viewport from a parent
        // framebuffer. A scene can be assigned to a host view controller directly using
        // ICHostViewController:runWithScene:, or indirectly, by adding it to an existing
        // scene graph using ICNode::addChild:.
        
        // Viewport of camera is set as soon as the scene is either added to an existing
        // scene graph or assigned to a host view controller
        self.camera = camera;
        
        _clearColor = (icColor4B){255,255,255,255};
        _clearsColorBuffer = YES;
        _clearsDepthBuffer = YES;
        _clearsStencilBuffer = YES;
        _performsDepthTesting = NO;
        _performsFaceCulling = YES;
    }
    return self;
}

- (void)dealloc
{
    self.camera = nil;
    self.drawingVisitor = nil;
    self.pickingVisitor = nil;
    
    [super dealloc];
}

- (ICNodeVisitorDrawing *)defaultDrawingVisitor
{
    return [[[IC_DEFAULT_DRAWING_VISITOR alloc] initWithOwner:self] autorelease];
}

- (ICNodeVisitorPicking *)defaultPickingVisitor
{
    return [[[IC_DEFAULT_PICKING_VISITOR alloc] initWithOwner:self] autorelease];
}

- (BOOL)isRootScene
{
    return (self.parent == nil && self.hostViewController != nil);
}

- (void)setUpSceneForDrawingWithVisitor:(ICNodeVisitorDrawing *)visitor
{
    icGLPurgeStateCache();
    IC_CHECK_GL_ERROR_DEBUG();
    
    // Clear buffers as configured
    if (_clearsColorBuffer)
        glClearColor((float)_clearColor.r/255.0f,
                     (float)_clearColor.g/255.0f,
                     (float)_clearColor.b/255.0f,
                     (float)_clearColor.a/255.0f);
    if (_clearsDepthBuffer)
        glClearDepth(1.0f);
    if (_clearsStencilBuffer)
        glClearStencil(0);
    
    GLbitfield clearFlags = GL_COLOR_BUFFER_BIT;
    if (_clearsDepthBuffer)
        clearFlags |= GL_DEPTH_BUFFER_BIT;
    if (_clearsStencilBuffer)
        clearFlags |= GL_STENCIL_BUFFER_BIT;
    glClear(clearFlags);
    IC_CHECK_GL_ERROR_DEBUG();
    
    // Enable face culling by default
    if (_performsFaceCulling)
        glEnable(GL_CULL_FACE);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
    // Set up alpha blending
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    if (_performsDepthTesting) {
        // Enable depth testing
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
    }

    IC_CHECK_GL_ERROR_DEBUG();
    
    // Store old projection matrix, so we can revert to the previous projection when
    // drawing has been finished. This is essentially useful when dealing with nested
    // scenes that draw to the same framebuffer object.
    kmGLGetMatrix(KM_GL_PROJECTION, &_matOldProjection);

    // Set up projection and model-view matrix based on camera options
    [self.camera apply];
}

- (void)tearDownSceneAfterDrawingWithVisitor:(ICNodeVisitorDrawing *)visitor
{
    // Revert old projection matrix
    kmGLMatrixMode(KM_GL_PROJECTION);
    kmGLLoadMatrix(&_matOldProjection);
    kmGLMatrixMode(KM_GL_MODELVIEW);
    
    glDisable(GL_DEPTH_TEST);
}

- (void)setUpSceneForPickingWithVisitor:(ICNodeVisitorPicking *)visitor
{
    CGPoint point;
    GLint *viewport;
    
    if (_renderTexture) {
        
        // This is a render texture scene, so we need to transform the current pick point
        // from parent framebuffer space to local node space
        CGPoint pickPoint = [((ICNodeVisitorPicking *)visitor) currentPickPoint];
        point = kmVec3ToCGPoint([_renderTexture parentFramebufferToNodeLocation:pickPoint]);
        
#if IC_ENABLE_DEBUG_PICKING
        ICLog(@"Picking within subscene of render texture: pickPoint=(%f,%f) localPoint=(%f,%f)",
              pickPoint.x, pickPoint.y, point.x, point.y);
#endif
        
        viewport = malloc(sizeof(GLint)*4);
        viewport[0] = viewport[1] = 0;
        viewport[2] = ICPointsToPixels(_renderTexture.size.width);
        viewport[3] = ICPointsToPixels(_renderTexture.size.height);
        
        if (ICPointsToPixels(point.x) < viewport[0] ||
            ICPointsToPixels(point.y) < viewport[1] ||
            ICPointsToPixels(point.x) > viewport[2] ||
            ICPointsToPixels(point.y) > viewport[3]) {
            
#if IC_ENABLE_DEBUG_PICKING
            ICLog(@"Point (%f,%f) outside viewport (%d,%d,%d,%d) for node %@",
                  point.x, point.y, viewport[0], viewport[1], viewport[2], viewport[3],
                  [self description]);
#endif            
            
            [visitor skipChildren];
            
        } else {
            
            ICPickContext *innerPickContext = [ICPickContext pickContextWithPoint:point
                                                                         viewport:viewport];
            [(ICNodeVisitorPicking *)visitor pushPickContext:innerPickContext];
            
        }
        
    } else {
        
        point = [((ICNodeVisitorPicking *)visitor) currentPickPoint];
        viewport = [((ICNodeVisitorPicking *)visitor) currentViewport];
        
    }
    
    icRay3 worldRay = [self worldRayFromFramebufferLocation:point];
    [((ICNodeVisitorPicking *)visitor) pushRay:worldRay];
    
    point.y = [self framebufferSize].height - point.y;
    
    // Disable alpha blending
    glDisable(GL_BLEND);
    
    kmGLGetMatrix(KM_GL_PROJECTION, &_matOldProjection);
    
    // Apply the camera with an additional pick matrix that scales the viewport to a 1x1
    // area at the given point
    [self.camera applyPickMatrix:point viewport:viewport];
    
    kmGLMatrixMode(GL_MODELVIEW);

    // FIXME: code duplication
    if (_performsDepthTesting) {
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
    }
    
    if (_renderTexture) {
        free(viewport);
    }
}

// Called only if visitation of children has not been skipped
- (void)tearDownSceneAfterPickingWithVisitor:(ICNodeVisitorPicking *)visitor
{
    // Revert old projection matrix
    kmGLMatrixMode(KM_GL_PROJECTION);
    kmGLLoadMatrix(&_matOldProjection);
    kmGLMatrixMode(KM_GL_MODELVIEW);
    
    if (_renderTexture) {
        [visitor popPickContext];
        NSAssert([visitor currentPickContext] != nil, @"Popped too many pick contexts");
    }
    
    [visitor popRay];    
}

- (void)visit
{
    if (!self.drawingVisitor) {
        // In case there is no drawing visitor yet, create a default one
        self.drawingVisitor = [self defaultDrawingVisitor];
    }
    // Visit the receiver for drawing
    [self.drawingVisitor visit:self];
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    if (![visitor isKindOfClass:[ICNodeVisitorPicking class]]) {
        [self setUpSceneForDrawingWithVisitor:(ICNodeVisitorDrawing *)visitor];
    } else {
        [self setUpSceneForPickingWithVisitor:(ICNodeVisitorPicking *)visitor];
    }
}

- (void)childrenDidDrawWithVisitor:(ICNodeVisitor *)visitor
{
    if (![visitor isKindOfClass:[ICNodeVisitorPicking class]]) {
        [self tearDownSceneAfterDrawingWithVisitor:(ICNodeVisitorDrawing *)visitor];
    } else {
        // Called only if visitation of children has not been skipped
        [self tearDownSceneAfterPickingWithVisitor:(ICNodeVisitorPicking *)visitor];
    }
}

// Must be in valid GL context, point must conform to icedcoffee view axes (Y points downwards)
- (NSArray *)hitTest:(CGPoint)point
{
    // Perform synchronous hit test
    return [self hitTest:point deferredReadback:NO];
}

// Must be in valid GL context, point must conform to icedcoffee view axes (Y points downwards)
- (NSArray *)hitTest:(CGPoint)point deferredReadback:(BOOL)deferredReadback
{
#if IC_ENABLE_DEBUG_HITTEST
    ICLog(@"Beginning hit test with point (%f,%f)", point.x, point.y);
#endif
    
    if (!self.pickingVisitor) {
        self.pickingVisitor = [self defaultPickingVisitor];
    }
    
    // Hit test must be called with the FBO bound which the scene is drawn to,
    // so we may retrieve the corresponding viewport from the GL state
    GLint viewport[4];
    glGetIntegerv(GL_VIEWPORT, viewport);
    
    if (ICPointsToPixels(point.x) < viewport[0] ||
        ICPointsToPixels(point.y) < viewport[1] ||
        ICPointsToPixels(point.x) > viewport[2] ||
        ICPointsToPixels(point.y) > viewport[3]) {
        // Point outside viewport
        return [NSArray array];
    }
    
    NSArray *hitNodes = [self.pickingVisitor performPickingTestWithNode:self
                                                                  point:point
                                                               viewport:viewport
                                                       deferredReadback:deferredReadback];
    
#if IC_ENABLE_DEBUG_HITTEST && defined(DEBUG) && defined(ICEDCOFFEE_DEBUG)
    if (!deferredReadback) {
        if ([hitNodes count] > 0) {
            ICLog(@"Hit test returned the following nodes:");
            for (ICNode *node in hitNodes) {
                ICLog(@" - %@", [node description]);
            }
        } else {
            ICLog(@"Hit test returned an empty result");
        }
    } else {
        ICLog(@"Hit test results deferred");
    }
#endif
    return hitNodes;
}

- (NSArray *)performHitTestReadback
{
    return [self.pickingVisitor readHitNodesAsync];
}

- (icRay3)worldRayFromFramebufferLocation:(CGPoint)location
{
    // location is based on the upper left corner of the parent framebuffer, which doesn't
    // match the OpenGL view coordinate system -- so we have to invert the Y axis here
    float framebufferHeight = [self framebufferSize].height;
    location.y = framebufferHeight - location.y;
    
    // Projected points are in framebuffer coordinates (pixels)
    icRay3 fbRay;
    fbRay.origin    = kmVec3Make(ICPointsToPixels(location.x),
                                 ICPointsToPixels(location.y), 0);
    fbRay.direction = kmVec3Make(ICPointsToPixels(location.x),
                                 ICPointsToPixels(location.y), 1);
    
    // Unprojected points are in world coordinates (points)
    icRay3 worldRay;
    [[self camera] unprojectView:fbRay.origin
                         toWorld:&worldRay.origin];
    [[self camera] unprojectView:fbRay.direction
                         toWorld:&worldRay.direction];
    
    return worldRay;
}

- (ICHostViewController *)hostViewController
{
    if (!_hostViewController)
        return [[self parent] hostViewController];
    return _hostViewController;
}

- (void)setHostViewController:(ICHostViewController *)hostViewController
{
    _hostViewController = hostViewController;
    
    // Adjust framebuffer size with respect to the new host view controller (this
    // will implicitly adjust the sizes of all sub scenes)
    [self adjustToFramebufferSize];
}

// FIXME: this looks incorrect and may need fixing
- (CGRect)frameRect
{
    if (!_parent) {
        CGSize framebufferSize = [self framebufferSize];
        return CGRectMake(0, 0, framebufferSize.width, framebufferSize.height);
    }
    return [super frameRect];
}

- (CGSize)framebufferSize
{    
    NSArray *fboAncestors = [self ancestorsConformingToProtocol:@protocol(ICFramebufferProvider)];
    if ([fboAncestors count]) {
        // Descendant of render texture, so we're dealing with a render texture FBO
        ICNode<ICFramebufferProvider> *parentFBOProvider = [fboAncestors objectAtIndex:0];
        return [parentFBOProvider framebufferSize];
    }
    
    // Scene without render texture ancestor, so we're dealing with the root FBO
    if (self.hostViewController)
        return [self.hostViewController framebufferSize];
    
    return CGSizeMake(0, 0);
}

- (void)adjustToFramebufferSize
{
    CGSize framebufferSize = [self framebufferSize];
    [self setSize:(kmVec3){framebufferSize.width, framebufferSize.height, 0}];    
}

- (void)setParent:(ICNode *)parent
{
    [super setParent:parent];
    
    if (parent) {
        // The scene is directly or indirectly a sub scene of another scene. For performance
        // reasons, we re-use the picking visitor of the parent scene in this case.
        self.pickingVisitor = [[self parentScene] pickingVisitor];
    } else {
        // The scene does no longer have a parent. In this case, we get rid of the picking visitor
        // if we are not the owner.
        if (self.pickingVisitor.owner != self) {
            self.pickingVisitor = nil;
        }
    }
    
    // When the scene is added to another scene, the latter may be part of a different
    // framebuffer. Make sure both the camera's viewport and the size of the scene
    // are in line with the parent framebuffer.
    [self adjustToFramebufferSize];
}

// Called by the framework. This should not be called directly, since the scene's size
// must be identical to the framebuffer size in order to get a correct projection.
- (void)setSize:(kmVec3)size
{
    if (size.width != self.size.width || size.height != self.size.height || size.depth != self.size.depth) {
        [super setSize:size];
        
        // Set the camera's viewport according to the new size of the scene
        CGRect viewport = CGRectMake(0, 0, size.width, size.height);
        [self.camera setViewport:viewport];
        [self setNeedsDisplay];
        
        // Ensure that descendant scenes adjust to the correct sizes respectively.
        // Note that this will not touch render texture scene's as those are not part of the
        // scene graph hierarchy when traversing the graph in descending direction.
        NSArray *descendantScenes = [self descendantsOfType:[ICScene class]];
        for (ICScene *scene in descendantScenes) {
            [scene setSize:size];
        }
    }
}

- (void)setNeedsDisplayForNode:(ICNode *)node
{
    if (!_parent) {
        [self.hostViewController setNeedsDisplay];
    } else {
        [super setNeedsDisplayForNode:node];
    }
}

@end
