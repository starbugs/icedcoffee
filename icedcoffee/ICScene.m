//  
//  Copyright (C) 2012 Tobias Lensing
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


@implementation ICScene

@synthesize hostViewController = _hostViewController;
@synthesize camera = _camera;
@synthesize drawingVisitor = _drawingVisitor;
@synthesize pickingVisitor = _pickingVisitor;
@synthesize clearColor = _clearColor;
@synthesize depthTestingEnabled = _depthTestingEnabled;

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
    return [self initWithHostViewController:hostViewController
                                     camera:[[[ICDEFAULT_CAMERA alloc] init] autorelease]];
}

- (id)initWithHostViewController:(ICHostViewController *)hostViewController
                          camera:(ICCamera *)camera
{
    if ((self = [super init])) {
        _hostViewController = hostViewController; // assign
        self.camera = camera;
        self.drawingVisitor = [[[ICDEFAULT_DRAWING_VISITOR alloc] init] autorelease];
        self.pickingVisitor = [[[ICDEFAULT_PICKING_VISITOR alloc] init] autorelease];
        _clearColor = (icColor4B){255,255,255,255};
        _depthTestingEnabled = NO;
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
    
    glClearColor((float)_clearColor.r/255.0f,
                 (float)_clearColor.g/255.0f,
                 (float)_clearColor.b/255.0f,
                 (float)_clearColor.a/255.0f);
    glClearDepth(1.0f);
    
    GLbitfield clearFlags = GL_COLOR_BUFFER_BIT;
    if (_depthTestingEnabled)
        clearFlags |= GL_DEPTH_BUFFER_BIT;
    glClear(clearFlags);
    CHECK_GL_ERROR_DEBUG();
    
    glEnable(GL_CULL_FACE);
    
    // FIXME
    
/*    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);*/
    
    /*glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);*/
    
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
            
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    if (self.depthTestingEnabled) {
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
    }

    CHECK_GL_ERROR_DEBUG();

    [self.camera apply];
}

// FIXME: needed?
- (void)tearDownSceneForDrawing
{
    glDisable(GL_DEPTH_TEST);
}

- (void)setupSceneForPickingWithPoint:(CGPoint)point viewport:(GLint *)viewport;
{
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearDepth(1.0f);
    
    glDisable(GL_BLEND);
    
    [self.camera applyPickMatrix:point viewport:viewport];
    
    kmGLMatrixMode(GL_MODELVIEW);

    // FIXME: code duplication
    if (self.depthTestingEnabled) {
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
    }
}

- (void)visit
{
    [self setUpSceneForDrawing];
    [self.drawingVisitor visit:self];
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

@end
