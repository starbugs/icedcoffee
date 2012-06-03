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

#import "ICScene.h"
#import "icDefaults.h"
#import "ICHostViewController.h"
#import "ICRenderTexture.h"
#import "kazmath/vec4.h"
#import "icUtils.h"
#import "icGL.h"
#import "icMacros.h"

#ifdef __IC_PLATFORM_IOS
#import "Platforms/iOS/ICGLView.h"
#elif defined(__IC_PLATFORM_MAC)
#import "Platforms/Mac/ICGLView.h"
#endif


@interface ICNode (Private)
- (void)setNeedsDisplayForNode:(ICNode *)node;
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

+ (id)sceneWithHostViewController:(ICHostViewController *)hostViewController
{
    return [[[[self class] alloc] initWithHostViewController:hostViewController] autorelease];
}

+ (id)sceneWithHostViewController:(ICHostViewController *)hostViewController
                           camera:(ICCamera *)camera
{
    return [[[[self class] alloc] initWithHostViewController:hostViewController camera:camera] autorelease];    
}

- (id)init
{
    NSAssert(nil, @"You must initialize ICScene using initWithHostViewController:");
    return nil;
}

- (id)initWithHostViewController:(ICHostViewController *)hostViewController
{
    // Prepare a viewport for the scene's camera. Note that this may be reset later on when
    // the scene is added to another scene
    CGRect viewport = CGRectMake(0, 0,
                                 hostViewController.view.bounds.size.width,
                                 hostViewController.view.bounds.size.height);
    
    ICCamera *camera = [[[ICDEFAULT_CAMERA alloc] initWithViewport:viewport] autorelease];
    return [self initWithHostViewController:hostViewController camera:camera];
}

- (id)initWithHostViewController:(ICHostViewController *)hostViewController
                          camera:(ICCamera *)camera
{
    if ((self = [super init])) {
        _hostViewController = hostViewController; // assign
        self.camera = camera;
        self.drawingVisitor = [[[ICDEFAULT_DRAWING_VISITOR alloc] init] autorelease];
        self.pickingVisitor = [[[ICDEFAULT_PICKING_VISITOR alloc] init] autorelease];
        [self setContentSize:(kmVec3){hostViewController.view.bounds.size.width,
                                      hostViewController.view.bounds.size.height,
                                      0}];
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
    
    // FIXME
    
/*    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);*/
    
    /*glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);*/
    
    // Set up pixel alignment
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    
    // Set up alpha blending
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    if (_performsDepthTesting) {
        // Enable depth testing
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
    }

    CHECK_GL_ERROR_DEBUG();

    // Set up projection and model-view matrix based on camera options
    [self.camera apply];
}

- (void)tearDownSceneForDrawing
{
    glDisable(GL_DEPTH_TEST);
}

- (void)setupSceneForPickingWithPoint:(CGPoint)point viewport:(GLint *)viewport;
{
    // Clear color and (optionally) depth buffers
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClearDepth(1.0f);
    
    GLbitfield clearFlags = GL_COLOR_BUFFER_BIT;
    if (_performsDepthTesting)
        clearFlags |= GL_DEPTH_BUFFER_BIT;
    glClear(clearFlags);
    CHECK_GL_ERROR_DEBUG();

    // Disable alpha blending
    glDisable(GL_BLEND);
    
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

- (void)visit
{
    [self visitNode:self];
}

- (void)visitNode:(ICNode *)node
{
    [self setUpSceneForDrawing];
    if ([node parent] && ![node isKindOfClass:[ICScene class]]) {
        kmMat4 matTransform = [[node parent] nodeToWorldTransform];
        kmGLPushMatrix();
        kmGLMultMatrix(&matTransform);
    }
    [self.drawingVisitor visit:node];
    if ([node parent] && ![node isKindOfClass:[ICScene class]]) {
        kmGLPopMatrix();
    }
    [self tearDownSceneForDrawing];    
}

// Must be in valid GL context
- (NSArray *)hitTest:(CGPoint)point
{
    GLint viewport[4];
    glGetIntegerv(GL_VIEWPORT, viewport);
    
    if (point.x < viewport[0] || point.y < viewport[1] ||
        point.x > viewport[2] || point.y > viewport[3]) {
        // Point outside viewport
        return [NSArray array];
    }
    
    [(ICNodeVisitorPicking *)self.pickingVisitor beginWithPickPoint:point];
    [self setupSceneForPickingWithPoint:point viewport:viewport];
    [self.pickingVisitor visit:self];
    [(ICNodeVisitorPicking *)self.pickingVisitor end];
    
    return ((ICNodeVisitorPicking *)self.pickingVisitor).resultNodeStack;
}

- (ICHostViewController *)hostViewController
{
    if (!_hostViewController)
        return [[self parent] hostViewController];
    return _hostViewController;
}

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
    if (self.parent == nil) {
        // Root scene
        return [[self.hostViewController view] bounds].size;
    }
    
    NSArray *renderTextureAncestors = [self ancestorsWithType:[ICRenderTexture class]];
    ICRenderTexture *parentRenderTexture = [renderTextureAncestors objectAtIndex:0];
    return parentRenderTexture.texture.contentSize;
}

- (void)setParent:(ICNode *)parent
{
    [super setParent:parent];
    
    CGSize frameBufferSize = [self frameBufferSize];
    CGRect viewport = CGRectMake(0, 0,
                                 frameBufferSize.width * IC_CONTENT_SCALE_FACTOR(),
                                 frameBufferSize.height * IC_CONTENT_SCALE_FACTOR());
    [self.camera setViewport:viewport];
    
    [self setContentSize:(kmVec3){frameBufferSize.width, frameBufferSize.height, 0}];
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
