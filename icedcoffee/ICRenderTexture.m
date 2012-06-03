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

+ (id)renderTextureWithWidth:(int)w height:(int)h
{
    return [[[[self class] alloc] initWithWidth:w height:h] autorelease];
}

+ (id)renderTextureWithWidth:(int)w height:(int)h depthBuffer:(BOOL)depthBuffer
{
    return [[[[self class] alloc] initWithWidth:w height:h depthBuffer:depthBuffer] autorelease];
}

+ (id)renderTextureWithWidth:(int)w
                      height:(int)h
                 depthBuffer:(BOOL)depthBuffer
               stencilBuffer:(BOOL)stencilBuffer
{
    return [[[[self class] alloc] initWithWidth:w
                                         height:h
                                    depthBuffer:depthBuffer
                                  stencilBuffer:stencilBuffer] autorelease];
}

+ (id)renderTextureWithWidth:(int)w height:(int)h pixelFormat:(ICPixelFormat)format
{
    return [[[[self class] alloc] initWithWidth:w height:h pixelFormat:format] autorelease];
}

+ (id)renderTextureWithWidth:(int)w
                      height:(int)h
                 pixelFormat:(ICPixelFormat)pixelFormat
           depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
{
    return [[[[self class] alloc] initWithWidth:w
                                         height:h
                                    pixelFormat:pixelFormat
                              depthBufferFormat:depthBufferFormat]
            autorelease];
}

+ (id)renderTextureWithWidth:(int)w
                      height:(int)h
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

- (id)initWithWidth:(int)w height:(int)h
{
    return [self initWithWidth:w height:h pixelFormat:kICPixelFormat_Default];
}

- (id)initWithWidth:(int)w height:(int)h depthBuffer:(BOOL)depthBuffer
{
    return [self initWithWidth:w
                        height:h
                   pixelFormat:kICPixelFormat_Default
             depthBufferFormat:depthBuffer ? kICDepthBufferFormat_Default : kICDepthBufferFormat_None];
}

- (id)initWithWidth:(int)w height:(int)h depthBuffer:(BOOL)depthBuffer stencilBuffer:(BOOL)stencilBuffer
{
    return [self initWithWidth:w
                        height:h
                   pixelFormat:kICPixelFormat_Default
             depthBufferFormat:depthBuffer ? kICDepthBufferFormat_Default : kICDepthBufferFormat_None
           stencilBufferFormat:stencilBuffer ? kICStencilBufferFormat_Default : kICStencilBufferFormat_None];
}

- (id)initWithWidth:(int)w height:(int)h pixelFormat:(ICPixelFormat)format
{
    return [self initWithWidth:w
                        height:h
                   pixelFormat:format
             depthBufferFormat:kICDepthBufferFormat_None];
}

- (id)initWithWidth:(int)w
             height:(int)h
        pixelFormat:(ICPixelFormat)format
  depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
{
    return [self initWithWidth:w
                        height:h
                   pixelFormat:format
             depthBufferFormat:depthBufferFormat
           stencilBufferFormat:kICStencilBufferFormat_None];
}

- (id)initWithWidth:(int)w
             height:(int)h
        pixelFormat:(ICPixelFormat)pixelFormat
  depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
stencilBufferFormat:(ICStencilBufferFormat)stencilBufferFormat
{
	if ((self = [super init])) {
		NSAssert(pixelFormat != kICPixelFormat_A8,
                 @"Only RGB and RGBA formats are valid for a render texture");
        
        // Store formats
        _pixelFormat = pixelFormat;
        _depthBufferFormat = depthBufferFormat;
        _stencilBufferFormat = stencilBufferFormat;

        // Set the render texture's content size -- this implicitly creates the required FBO
        [self setContentSize:(kmVec3){w, h, 0}];

        // Set up a sprite for displaying the render texture in the scene
		_sprite = [ICSprite spriteWithTexture:_texture];
        [_sprite flipTextureVertically];
		[self addChild:_sprite];
        
        // By default, set the display mode to kICFrameUpdateMode_Synchronized
        self.frameUpdateMode = kICFrameUpdateMode_Synchronized;
	}
	return self;
}

- (void)dealloc
{
	glDeleteFramebuffers(1, &_fbo);
    self.subScene = nil;
    
    [_texture release];
    
	[super dealloc];
}

- (void)setContentSize:(kmVec3)contentSize
{
    NSUInteger w = contentSize.x;
    NSUInteger h = contentSize.y;
    
    if (w == (NSUInteger)_contentSize.x &&
        h == (NSUInteger)_contentSize.y)
        return; // content size not changed -- do nothing

    [super setContentSize:contentSize];
    
    w *= IC_CONTENT_SCALE_FACTOR();
    h *= IC_CONTENT_SCALE_FACTOR();
    
    // Textures must be power of two unless we have NPOT support
    NSUInteger powW;
    NSUInteger powH;
    
    if( [[ICConfiguration sharedConfiguration] supportsNPOT] ) {
        powW = w;
        powH = h;
    } else {
        powW = icNextPOT(w);
        powH = icNextPOT(h);
    }        
    
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFBO);
    
    // Generate an FBO
    glGenFramebuffers(1, &_fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
    
    void *data = malloc((int)(powW * powH * 4));
    memset(data, 0, (int)(powW * powH * 4));
    
    _texture = [[ICTexture2D alloc] initWithData:data
                                     pixelFormat:_pixelFormat
                                      pixelsWide:powW
                                      pixelsHigh:powH
                                     contentSize:CGSizeMake(w, h)];
    free(data);
    
    // Associate texture with FBO
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           GL_TEXTURE_2D,
                           _texture.name,
                           0);
    
    // Attach a depth buffer if required
    if (_depthBufferFormat) {
        GLint depthComponent;
        switch (_depthBufferFormat) {
            case kICDepthBufferFormat_16:
                depthComponent = GL_DEPTH_COMPONENT16;
                break;
            case kICDepthBufferFormat_24:
#ifdef __IC_PLATFORM_MAC
                depthComponent = GL_DEPTH_COMPONENT24;
#elif defined(__IC_PLATFORM_IOS)
                depthComponent = GL_DEPTH_COMPONENT24_OES;                    
#endif
                break;
            default:
                [NSException raise:NSInvalidArgumentException format:@"Invalid depth buffer format"];
                break;
        }
        
        GLint oldRBO;
        glGetIntegerv(GL_RENDERBUFFER_BINDING, &oldRBO);
        glGenRenderbuffers(1, &_depthRBO);
        glBindRenderbuffer(GL_RENDERBUFFER, _depthRBO);
        glRenderbufferStorage(GL_RENDERBUFFER, depthComponent, (GLsizei)powW, (GLsizei)powH);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                                  GL_DEPTH_ATTACHMENT,
                                  GL_RENDERBUFFER,
                                  _depthRBO);
        glBindRenderbuffer(GL_RENDERBUFFER, oldRBO);
    }
    
    // Attach a stencil buffer if required
    if (_stencilBufferFormat) {
        GLint oldRBO;
        glGetIntegerv(GL_RENDERBUFFER_BINDING, &oldRBO);
        glGenRenderbuffers(1, &_stencilRBO);
        glBindRenderbuffer(GL_RENDERBUFFER, _stencilRBO);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_STENCIL_INDEX8, (GLsizei)powW, (GLsizei)powH);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                                  GL_STENCIL_ATTACHMENT,
                                  GL_RENDERBUFFER,
                                  _stencilRBO);
        glBindRenderbuffer(GL_RENDERBUFFER, oldRBO);            
    }
    
    NSAssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE,
             @"Could not attach texture to framebuffer");
    
    // Bind old frame buffer
    glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
    CHECK_GL_ERROR_DEBUG();
    
    [_texture setAliasTexParameters];    
    
    if (_sprite) {
        [_sprite setTexture:_texture];
    }
    
    [self setNeedsDisplay];
}

- (void)begin
{
	// Save the current matrices
    kmGLMatrixMode(GL_PROJECTION);
    kmGLPushMatrix();
    kmGLMatrixMode(GL_MODELVIEW);
	kmGLPushMatrix();

    // Save current FBO viewport
    glGetIntegerv(GL_VIEWPORT, _oldFBOViewport);
        
	// Adjust the viewport
	CGSize texSize = [_texture contentSizeInPixels];
	glViewport(0, 0, texSize.width, texSize.height);

	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFBO);
	glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
    
    CHECK_GL_ERROR_DEBUG();
    
    _isInRenderTextureDrawContext = YES;
}

- (void)end
{
	glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
    CHECK_GL_ERROR_DEBUG();
    
	// Restore previous matrices
    kmGLMatrixMode(GL_PROJECTION);
    kmGLPopMatrix();
    kmGLMatrixMode(GL_MODELVIEW);
	kmGLPopMatrix();
    
	// Restore viewport
	glViewport(_oldFBOViewport[0], _oldFBOViewport[1], _oldFBOViewport[2], _oldFBOViewport[3]);
    
    _isInRenderTextureDrawContext = NO;
}

- (icColor4B)colorOfPixelAtLocation:(CGPoint)location
{
    icColor4B color;
    BOOL      performBeginEnd = NO;
    
    if (!self.isInRenderTextureDrawContext) {
        performBeginEnd = YES;
        [self begin];
    }
    
	glReadPixels(location.x, location.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, &color);
    
    if (performBeginEnd)
        [self end];
    
    return color;
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    [self begin];
    if (visitor.visitorType == kICPickingNodeVisitor) {
        
        // Perform picking on inner texture scene
        
        // Get and transform pick point (frame buffer space)
        CGPoint pickPoint = ((ICNodeVisitorPicking *)visitor).pickPoint;
        CGPoint localPoint = [self hostViewToNodeLocation:pickPoint];
        
        // Perform the inner hit test
        NSArray *innerHitTestNodes = [self.subScene hitTest:localPoint];
        
        // Append nodes after(!) the next successful hit in the parent scene, which will be
        // the hit of the render texture's sprite
        [(ICNodeVisitorPicking *)visitor appendNodesToResultStack:innerHitTestNodes];
        
    } else if (self.frameUpdateMode == kICFrameUpdateMode_Synchronized ||
              (self.frameUpdateMode == kICFrameUpdateMode_OnDemand && _needsDisplay)) {
        
        // Visit inner scene for drawing
        [self.subScene visit];
        
        // Reset needsDisplay property if applicable
        if (self.frameUpdateMode == kICFrameUpdateMode_OnDemand && _needsDisplay) {
            _needsDisplay = NO;
        }
        
    }
    [self end];

    [super drawWithVisitor:visitor];
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

@end
