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

#import "ICScene.h"
#import "icDefaults.h"
#import "ICHostViewController.h"
#import "ICRenderTexture.h"
#import "kazmath/vec4.h"
#import "icUtils.h"
#import "icGL.h"
#import "icMacros.h"
#import "icConfig.h"

#ifdef __IC_PLATFORM_IOS
#import "Platforms/iOS/ICGLView.h"
#elif defined(__IC_PLATFORM_MAC)
#import "Platforms/Mac/ICGLView.h"
#endif


@interface ICNode (Private)
- (void)setNeedsDisplayForNode:(ICNode *)node;
@end

@interface ICScene (Private)
- (void)adjustToFrameBufferSize;
@end


@implementation ICScene

@synthesize hostViewController = _hostViewController;
@synthesize camera = _camera;
@synthesize drawingVisitor = _drawingVisitor;
@synthesize pickingVisitor = _pickingVisitor;
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

- (id)init
{
    if ((self = [super init])) {
        // Note that initially, the scene is not assigned to a host view controller. This
        // must be done later so that it receives a valid size and viewport from a parent
        // frame buffer. A scene can be assigned to a host view controller directly using
        // ICHostViewController:runWithScene:, or indirectly, by adding it to an existing
        // scene graph using ICNode::addChild:.
        
        // Viewport of camera is set as soon as the scene is either added to an existing
        // scene graph or assigned to a host view controller
        ICCamera *camera = [[[ICDEFAULT_CAMERA alloc] initWithViewport:CGRectNull] autorelease];
        self.camera = camera;
        
        self.drawingVisitor = [[[ICDEFAULT_DRAWING_VISITOR alloc] init] autorelease];
        self.pickingVisitor = [[[ICDEFAULT_PICKING_VISITOR alloc] init] autorelease];
                
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

- (void)setUpSceneForDrawing
{
    icGLPurgeStateCache();
    CHECK_GL_ERROR_DEBUG();
    
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
    CHECK_GL_ERROR_DEBUG();
    
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

    CHECK_GL_ERROR_DEBUG();
    
    // Store old projection matrix, so we can revert to the previous projection when
    // drawing has been finished. This is essentially useful when dealing with nested
    // scenes that draw to the same frame buffer object.
    kmGLGetMatrix(KM_GL_PROJECTION, &_matOldProjection);

    // Set up projection and model-view matrix based on camera options
    [self.camera apply];
}

- (void)tearDownSceneForDrawing
{
    // Revert old projection matrix
    kmGLMatrixMode(KM_GL_PROJECTION);
    kmGLLoadMatrix(&_matOldProjection);
    kmGLMatrixMode(KM_GL_MODELVIEW);
    
    glDisable(GL_DEPTH_TEST);
}

- (void)setupSceneForPickingWithPoint:(CGPoint)point viewport:(GLint *)viewport;
{
    point.y = [self frameBufferSize].height - point.y;
    
    // Clear color and (optionally) depth buffers
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClearDepth(1.0f);
    glClearStencil(0);
    
    GLbitfield clearFlags = GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT;
    if (_performsDepthTesting)
        clearFlags |= GL_DEPTH_BUFFER_BIT;
    glClear(clearFlags);
    CHECK_GL_ERROR_DEBUG();

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
}

- (void)tearDownSceneForPicking
{
    // Revert old projection matrix
    kmGLMatrixMode(KM_GL_PROJECTION);
    kmGLLoadMatrix(&_matOldProjection);
    kmGLMatrixMode(KM_GL_MODELVIEW);
}

- (void)visit
{
    [self.drawingVisitor visit:self];
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    if (visitor.visitorType == kICDrawingNodeVisitor) {
        [self setUpSceneForDrawing];
    } else if(visitor.visitorType == kICPickingNodeVisitor) {
        CGPoint point = ((ICNodeVisitorPicking *)visitor).pickPoint;
        GLint *viewport = ((ICNodeVisitorPicking *)visitor).viewport;
        [self setupSceneForPickingWithPoint:point viewport:viewport];
    }
}

- (void)childrenDidDrawWithVisitor:(ICNodeVisitor *)visitor
{
    if (visitor.visitorType == kICDrawingNodeVisitor) {
        [self tearDownSceneForDrawing];
    } else if(visitor.visitorType == kICPickingNodeVisitor) {
        [self tearDownSceneForPicking];
    }
}

// Must be in valid GL context, point must conform to IcedCoffee view axes (Y points downwards)
- (NSArray *)hitTest:(CGPoint)point
{
#if IC_ENABLE_DEBUG_HITTEST
    ICLOG(@"Beginning hit test with point (%f,%f)", point.x, point.y);
#endif
    
    // Hit test must be called from the FBO context the scene is part of,
    // so we may retrieve the corresponding viewport from the GL state
    GLint viewport[4];
    glGetIntegerv(GL_VIEWPORT, viewport);
    
    if (point.x * IC_CONTENT_SCALE_FACTOR() < viewport[0] ||
        point.y * IC_CONTENT_SCALE_FACTOR() < viewport[1] ||
        point.x * IC_CONTENT_SCALE_FACTOR() > viewport[2] ||
        point.y * IC_CONTENT_SCALE_FACTOR() > viewport[3]) {
        // Point outside viewport
        return [NSArray array];
    }
    
    [(ICNodeVisitorPicking *)self.pickingVisitor beginWithPickPoint:point viewport:viewport];
    [self.pickingVisitor visit:self];
    [(ICNodeVisitorPicking *)self.pickingVisitor end];
    
    NSArray *hitNodes = ((ICNodeVisitorPicking *)self.pickingVisitor).resultNodeStack;
#if IC_ENABLE_DEBUG_HITTEST && defined(DEBUG) && defined(ICEDCOFFEE_DEBUG)
    if ([hitNodes count] > 0) {
        ICLOG(@"Hit test returned the following nodes:");
        for (ICNode *node in hitNodes) {
            ICLOG(@" - %@", [node description]);
        }
    } else {
        ICLOG(@"Hit test returned an empty result");
    }
#endif
    return hitNodes;
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
    
    // Adjust frame buffer size with respect to the new host view controller (this
    // will implicitly adjust the sizes of all sub scenes)
    [self adjustToFrameBufferSize];
}

// FIXME: this looks incorrect and may need fixing
- (CGRect)frameRect
{
    if (!_parent) {
        CGSize frameBufferSize = [self frameBufferSize];
        return CGRectMake(0, 0, frameBufferSize.width, frameBufferSize.height);
    }
    return [super frameRect];
}

- (CGSize)frameBufferSize
{    
    NSArray *renderTextureAncestors = [self ancestorsOfType:[ICRenderTexture class]];
    if ([renderTextureAncestors count]) {
        // Descendant of render texture, so we're dealing with a render texture FBO
        ICRenderTexture *parentRenderTexture = [renderTextureAncestors objectAtIndex:0];
        return CGSizeMake(parentRenderTexture.size.x, parentRenderTexture.size.y);
    }
    
    // Scene without render texture ancestor, so we're dealing with the root FBO
    if (self.hostViewController)
        return [[self.hostViewController view] bounds].size;
    
    return CGSizeMake(0, 0);
}

- (void)adjustToFrameBufferSize
{
    CGSize frameBufferSize = [self frameBufferSize];
    [self setSize:(kmVec3){frameBufferSize.width, frameBufferSize.height, 0}];    
}

- (void)setParent:(ICNode *)parent
{
    [super setParent:parent];
    
    // When the scene is added to another scene, the latter may be part of a different
    // frame buffer. Make sure both the camera's viewport and the size of the scene
    // are in line with the parent frame buffer.
    [self adjustToFrameBufferSize];
}

// Called by the framework. This should not be called directly, since the scene's size
// must be identical to the frame buffer size in order to get a correct projection.
- (void)setSize:(kmVec3)size
{
    if (size.x != self.size.x || size.y != self.size.y || size.z != self.size.z) {
        [super setSize:size];
        
        // Set the camera's viewport according to the new size of the scene
        CGRect viewport = CGRectMake(0, 0, size.x, size.y);
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
