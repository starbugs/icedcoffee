/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Jason Booth
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * Adapted and extended for IcedCoffee
 */

#import "ICRenderTexture.h"
#import "ICSprite.h"
#import "icMacros.h"
#import "icGL.h"
#import "icUtils.h"
#import "icConfig.h"
#import "ICConfiguration.h"
#import "ICScene.h"
#import "ICCamera.h"
#import "ICHostViewController.h"
#import "ICNodeVisitorPicking.h"
#import "icGL.h"

@interface ICNode (Private)
- (void)setNeedsDisplayForNode:(ICNode *)node;
@end

@implementation ICRenderTexture

@synthesize texture = _texture;
@synthesize sprite = _sprite;
@synthesize subScene = _subScene;
@synthesize isInRenderTextureDrawContext = _isInRenderTextureDrawContext;
@synthesize frameUpdateMode = _frameUpdateMode;

+ (id)renderTextureWithWidth:(float)w height:(float)h
{
    return [[[[self class] alloc] initWithWidth:w height:h] autorelease];
}

+ (id)renderTextureWithWidth:(float)w height:(float)h depthBuffer:(BOOL)depthBuffer
{
    return [[[[self class] alloc] initWithWidth:w height:h depthBuffer:depthBuffer] autorelease];
}

+ (id)renderTextureWithWidth:(float)w
                      height:(float)h
                 depthBuffer:(BOOL)depthBuffer
               stencilBuffer:(BOOL)stencilBuffer
{
    return [[[[self class] alloc] initWithWidth:w
                                         height:h
                                    depthBuffer:depthBuffer
                                  stencilBuffer:stencilBuffer] autorelease];
}

+ (id)renderTextureWithWidth:(float)w height:(float)h pixelFormat:(ICPixelFormat)format
{
    return [[[[self class] alloc] initWithWidth:w height:h pixelFormat:format] autorelease];
}

+ (id)renderTextureWithWidth:(float)w
                      height:(float)h
                 pixelFormat:(ICPixelFormat)pixelFormat
           depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
{
    return [[[[self class] alloc] initWithWidth:w
                                         height:h
                                    pixelFormat:pixelFormat
                              depthBufferFormat:depthBufferFormat]
            autorelease];
}

+ (id)renderTextureWithWidth:(float)w
                      height:(float)h
                 pixelFormat:(ICPixelFormat)pixelFormat
           depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
         stencilBufferFormat:(ICStencilBufferFormat)stencilBufferFormat
{
    return [[[[self class] alloc] initWithWidth:w
                                         height:h
                                    pixelFormat:pixelFormat
                              depthBufferFormat:depthBufferFormat
                            stencilBufferFormat:stencilBufferFormat]
            autorelease];    
}

- (id)initWithWidth:(float)w height:(float)h
{
    return [self initWithWidth:w height:h pixelFormat:ICPixelFormatDefault];
}

- (id)initWithWidth:(float)w height:(float)h depthBuffer:(BOOL)depthBuffer
{
    return [self initWithWidth:w
                        height:h
                   pixelFormat:ICPixelFormatDefault
             depthBufferFormat:depthBuffer ? ICDepthBufferFormatDefault : ICDepthBufferFormatNone];
}

- (id)initWithWidth:(float)w height:(float)h depthBuffer:(BOOL)depthBuffer stencilBuffer:(BOOL)stencilBuffer
{
    return [self initWithWidth:w
                        height:h
                   pixelFormat:ICPixelFormatDefault
             depthBufferFormat:depthBuffer ? ICDepthBufferFormatDefault : ICDepthBufferFormatNone
           stencilBufferFormat:stencilBuffer ? ICStencilBufferFormatDefault : ICStencilBufferFormatNone];
}

- (id)initWithWidth:(float)w height:(float)h pixelFormat:(ICPixelFormat)format
{
    return [self initWithWidth:w
                        height:h
                   pixelFormat:format
             depthBufferFormat:ICDepthBufferFormatNone];
}

- (id)initWithWidth:(float)w
             height:(float)h
        pixelFormat:(ICPixelFormat)format
  depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
{
    return [self initWithWidth:w
                        height:h
                   pixelFormat:format
             depthBufferFormat:depthBufferFormat
           stencilBufferFormat:ICStencilBufferFormatNone];
}

- (id)initWithWidth:(float)w
             height:(float)h
        pixelFormat:(ICPixelFormat)pixelFormat
  depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
stencilBufferFormat:(ICStencilBufferFormat)stencilBufferFormat
{
	if ((self = [super init])) {
		NSAssert(pixelFormat != ICPixelFormatA8,
                 @"Only RGB and RGBA formats are valid for a render texture");
        
        // Store formats
        if ([[ICConfiguration sharedConfiguration] supportsCVOpenGLESTextureCache]) {
            // Only RGBA8888 is supported for CV pixel buffers currently
            _pixelFormat = ICPixelFormatRGBA8888;
        } else {
            _pixelFormat = pixelFormat;
        }
        _depthBufferFormat = depthBufferFormat;
        _stencilBufferFormat = stencilBufferFormat;

        // Set the render texture's content size -- this implicitly creates the required FBO
        [self setSize:(kmVec3){w, h, 0}];
        
        // Set up a sprite for displaying the render texture in the scene
		_sprite = [[ICSprite alloc] initWithTexture:_texture];
        [_sprite setSize:self.size];
        [_sprite flipTextureVertically];
		[self addChild:_sprite];        
        
        // By default, set the display mode to ICFrameUpdateModeSynchronized
        self.frameUpdateMode = ICFrameUpdateModeSynchronized;
	}
	return self;
}

- (void)dealloc
{
    self.subScene = nil;
    [_sprite release];
    [_texture release];

    if (_fbo) {
        glDeleteFramebuffers(1, &_fbo);
        _fbo = 0;
    }
    if (_depthRBO) {
        glDeleteRenderbuffers(1, &_depthRBO);
    }
    if (_stencilRBO) {
        glDeleteRenderbuffers(1, &_stencilRBO);
    }
    
	[super dealloc];
}

- (void)setSize:(kmVec3)size
{
    float w = size.x;
    float h = size.y;

    if (w == _size.x &&
        h == _size.y)
        return; // content size not changed -- do nothing
    
    [super setSize:size];

    if (w == 0 || h == 0) {
        // If size x*y==0, just give up the texture and FBO
        [_texture release];
        _texture = nil;
        if (_fbo) {
            glDeleteFramebuffers(1, &_fbo);
            _fbo = 0;
        }
        return;
    }

    w = ICPointsToPixels(w);
    h = ICPointsToPixels(h);
    
    // Textures must be power of two unless we have NPOT support
    NSUInteger textureWidth;
    NSUInteger textureHeight;
    
    if ([[ICConfiguration sharedConfiguration] supportsNPOT]) {
        textureWidth = w;
        textureHeight = h;
    } else {
        textureWidth = icNextPOT(w);
        textureHeight = icNextPOT(h);
    }        
    
    // Store current FBO
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFBO);
    
    // Delete previous render texture FBO, if applicable
    if (_fbo) {
        glDeleteFramebuffers(1, &_fbo);
    }
        
    // Generate an FBO
    glGenFramebuffers(1, &_fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
    
    ICHostViewController *hostViewController = [self hostViewController];
    if (!hostViewController)
        hostViewController = [ICHostViewController currentHostViewController];
    ICResolutionType resolutionType = [hostViewController bestResolutionTypeForCurrentScreen];

    [_texture release];

#ifdef __IC_PLATFORM_IOS
    // Optimize render texture for iOS devices
    _texture = [[ICTexture2D alloc] initAsCoreVideoRenderTextureWithTextureSize:CGSizeMake(textureWidth, textureHeight)
                                                                 resolutionType:resolutionType];
#else
    NSUInteger surfaceSize = textureWidth * textureHeight * 4;
    void *data = malloc(surfaceSize);
    memset(data, 0, surfaceSize);
    
    _texture = [[ICTexture2D alloc] initWithData:data
                                     pixelFormat:_pixelFormat
                                     textureSize:CGSizeMake(textureWidth, textureHeight)
                                     contentSize:CGSizeMake(w, h)
                                  resolutionType:resolutionType];
    free(data);
#endif
    
    // Associate texture with FBO
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           GL_TEXTURE_2D,
                           _texture.name,
                           0);
    
    // Attach a depth (and stencil) buffer if required
    if (_depthBufferFormat || _stencilBufferFormat) {
        GLint depthFormat = 0;
        
        if (!_stencilBufferFormat) {
            // Depth buffer only formats
            switch (_depthBufferFormat) {
                case ICDepthBufferFormat16: {
                    depthFormat = GL_DEPTH_COMPONENT16;
                    break;
                }
                case ICDepthBufferFormat24: {
#ifdef __IC_PLATFORM_MAC
                    depthFormat = GL_DEPTH_COMPONENT24;
#elif defined(__IC_PLATFORM_IOS)
                    depthFormat = GL_DEPTH_COMPONENT24_OES;                    
#endif
                    break;
                }
                default: {
                    [NSException raise:NSInvalidArgumentException format:@"Invalid depth buffer format"];
                    break;
                }
            }
        } else {
            // Depth-stencil packed format, the only supported format is GL_DEPTH24_STENCIL8
            _depthBufferFormat = ICDepthBufferFormat24;
#ifdef __IC_PLATFORM_MAC
            depthFormat = GL_DEPTH24_STENCIL8;
#elif defined(__IC_PLATFORM_IOS)
            depthFormat = GL_DEPTH24_STENCIL8_OES;
#endif
        }

        GLint oldRBO;
        glGetIntegerv(GL_RENDERBUFFER_BINDING, &oldRBO);
                        
        glGenRenderbuffers(1, &_depthRBO);
        glBindRenderbuffer(GL_RENDERBUFFER, _depthRBO);
        glRenderbufferStorage(GL_RENDERBUFFER, depthFormat, (GLsizei)textureWidth, (GLsizei)textureHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRBO);
        if (_stencilBufferFormat) {
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depthRBO);
        }
        
        glBindRenderbuffer(GL_RENDERBUFFER, oldRBO);
    }
    
    GLenum fboStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(fboStatus == GL_FRAMEBUFFER_COMPLETE,
             @"Could not attach texture to framebuffer (fbo status: %x", fboStatus);
    
    // Bind old framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
    IC_CHECK_GL_ERROR_DEBUG();
    
    //[_texture setAliasTexParameters];    
    
    [_sprite setTexture:_texture];
    [_sprite setSize:self.size];
    [_subScene setSize:self.size];
        
    [self setNeedsDisplay];
}

- (CGSize)textureSizeInPixels
{
    return CGSizeMake(ICPointsToPixels(_size.x), ICPointsToPixels(_size.y));
}

- (void)pushRenderTextureMatrices
{
	// Save current matrices
    kmGLMatrixMode(GL_PROJECTION);
    kmGLPushMatrix();
    kmGLMatrixMode(GL_MODELVIEW);
	kmGLPushMatrix();    
}

- (void)popRenderTextureMatrices
{
	// Restore previous matrices
    kmGLMatrixMode(GL_PROJECTION);
    kmGLPopMatrix();
    kmGLMatrixMode(GL_MODELVIEW);
	kmGLPopMatrix();    
}

- (void)begin
{
    [self pushRenderTextureMatrices];

    // Save current FBO viewport
    glGetIntegerv(GL_VIEWPORT, _oldFBOViewport);
        
	// Adjust the viewport to the render texture's size
	CGSize texSize = [_texture contentSizeInPixels];
	glViewport(0, 0, texSize.width, texSize.height);

    // Save the current framebuffer and switch to the render texture's framebuffer
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFBO);
	glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
    
    IC_CHECK_GL_ERROR_DEBUG();
    
    _isInRenderTextureDrawContext = YES;
}

- (void)end
{
    // Restore the old framebuffer
	glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
    IC_CHECK_GL_ERROR_DEBUG();

    [self popRenderTextureMatrices];
    
	// Restore viewport
	glViewport(_oldFBOViewport[0], _oldFBOViewport[1], _oldFBOViewport[2], _oldFBOViewport[3]);
    
    _isInRenderTextureDrawContext = NO;
}

- (icColor4B)colorOfPixelAtLocation:(CGPoint)location
{
    icColor4B color;
    [self readPixels:&color inRect:CGRectMake(location.x, location.y, 1, 1)];
    return color;
}

- (void)readPixels:(void *)data inRect:(CGRect)rect
{
    BOOL performBeginEnd = NO;
    
    if (!self.isInRenderTextureDrawContext) {
        performBeginEnd = YES;
        [self begin];
    }
    
    if ([[ICConfiguration sharedConfiguration] supportsCVOpenGLESTextureCache]) {
#ifdef __IC_PLATFORM_IOS
        glFlush();
        
        // Optimize readbacks for iOS devices
        CVReturn err = CVPixelBufferLockBaseAddress(_texture.cvRenderTarget, kCVPixelBufferLock_ReadOnly);
        if (err == kCVReturnSuccess) {
            uint textureWidth = CVPixelBufferGetWidth(_texture.cvRenderTarget);
            uint textureHeight = CVPixelBufferGetHeight(_texture.cvRenderTarget);
            uint8_t *pixels = (uint8_t *)CVPixelBufferGetBaseAddress(_texture.cvRenderTarget);
            uint sx = rect.origin.x, sy = rect.origin.y;
            uint w = (uint)rect.size.width;
            uint h = (uint)rect.size.height;
            if (sx + w <= textureWidth && sy + h <= textureHeight) {
                uint i = 0, j;
                for (; i<h; i++) {
                    for (j=0; j<w; j++) {
                        uint x = sx + j;
                        uint y = sy + i;
                        uint8_t *dest = data + i*w*4 + j*4;
                        uint8_t *src = pixels + y*textureWidth*4 + x*4;
                        // Convert BGRA to RGBA
                        memcpy(dest+0, src+2, 1);
                        memcpy(dest+1, src+1, 1);
                        memcpy(dest+2, src+0, 1);
                        memcpy(dest+3, src+3, 1);
                    }
                }
            }
            CVPixelBufferUnlockBaseAddress(_texture.cvRenderTarget, kCVPixelBufferLock_ReadOnly);
        }
#endif
    } else {
        // Standard readback; most likely stalls the OpenGL pipeline
        glReadPixels(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height,
                     GL_RGBA, GL_UNSIGNED_BYTE, data);
    }
    
    if (performBeginEnd)
        [self end];
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    if (![visitor isKindOfClass:[ICNodeVisitorPicking class]] &&
        (self.frameUpdateMode == ICFrameUpdateModeSynchronized ||
        (self.frameUpdateMode == ICFrameUpdateModeOnDemand && _needsDisplay))) {
        
        if (_fbo && _texture) {
            // Enter render texture context
            [self begin];
            
            // Visit inner scene for drawing
            [self.subScene visit];
            
            // Reset needsDisplay property if applicable
            if (self.frameUpdateMode == ICFrameUpdateModeOnDemand && _needsDisplay) {
                _needsDisplay = NO;
            }
            
            // Exit render texture context
            [self end];
        }
    } else if ([visitor isKindOfClass:[ICNodeVisitorPicking class]]) {
        [self pushRenderTextureMatrices];
    }
}

- (void)childrenDidDrawWithVisitor:(ICNodeVisitor *)visitor
{
    if ([visitor isKindOfClass:[ICNodeVisitorPicking class]]) {
        [self popRenderTextureMatrices];
    }
}

// Note: the render texture's sprite is not used for picking
- (NSArray *)pickingChildren
{
    return [NSArray arrayWithObjects:self.subScene, nil];
}

- (void)setSubScene:(ICScene *)subScene
{
    [_subScene release];
    _subScene = [subScene retain];
    
    // Bind parent of scene to self.sprite to enable correct mouseEntered and mouseExited
    // events on the inner scene and the outer scene's nodes. This is kind of a weird
    // relationship as the scene is not a child of self.sprite, but self.sprite is the
    // scene's parent. This is essntially an edge case. Don't do this at home ;)
    [_subScene setParent:self.sprite];
    
    // Assign self as render texture to sub scene
    [_subScene setRenderTexture:self];
}

- (void)setNeedsDisplayForNode:(ICNode *)node
{
    // Note that this render texture needs to redraw its contents
    _needsDisplay = YES;
    [super setNeedsDisplayForNode:node];
}

- (void)setParent:(ICNode *)parent
{
    [super setParent:parent];
    [self setNeedsDisplay];
}

- (kmPlane)plane
{
    return [self.sprite plane];
}

- (CGSize)framebufferSize
{
    return kmVec3ToCGSize(self.size);
}

@end
