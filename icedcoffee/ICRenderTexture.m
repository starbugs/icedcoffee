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
#import "icGL.h"

@implementation ICRenderTexture

@synthesize texture = _texture;
@synthesize sprite = _sprite;
@synthesize subScene = _subScene;
@synthesize isInRenderTextureDrawContext = _isInRenderTextureDrawContext;
@synthesize displayMode = _displayMode;

+ (id)renderTextureWithWidth:(int)w height:(int)h pixelFormat:(ICTexture2DPixelFormat)format
{
    return [[[[self class] alloc] initWithWidth:w height:h pixelFormat:format] autorelease];
}

+ (id)renderTextureWithWidth:(int)w
                      height:(int)h
                 pixelFormat:(ICTexture2DPixelFormat)format
           enableDepthBuffer:(BOOL)enableDepthBuffer
{
    return [[[[self class] alloc] initWithWidth:w
                                         height:h
                                    pixelFormat:format
                              enableDepthBuffer:enableDepthBuffer]
            autorelease];
}

- (id)initWithWidth:(int)w height:(int)h pixelFormat:(ICTexture2DPixelFormat)format
{
    return [self initWithWidth:w height:h pixelFormat:format enableDepthBuffer:NO];
}

- (id)initWithWidth:(int)w
             height:(int)h
        pixelFormat:(ICTexture2DPixelFormat)format
  enableDepthBuffer:(BOOL)enableDepthBuffer
{
	if ((self = [super init]))
	{
		NSAssert(format != kICTexture2DPixelFormat_A8,
                 @"Only RGB and RGBA formats are valid for a render texture");
        
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
		_pixelFormat = format;
        
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
        
        if (enableDepthBuffer) {
            GLint oldRBO;
            glGetIntegerv(GL_RENDERBUFFER_BINDING, &oldRBO);
            glGenRenderbuffers(1, &_depthRBO);
            glBindRenderbuffer(GL_RENDERBUFFER, _depthRBO);
            glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, (GLsizei)powW, (GLsizei)powH);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                                      GL_DEPTH_ATTACHMENT,
                                      GL_RENDERBUFFER,
                                      _depthRBO);
            glBindRenderbuffer(GL_RENDERBUFFER, oldRBO);
        }

		NSAssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE,
                 @"Could not attach texture to framebuffer");
        
		[_texture setAliasTexParameters];
        
		_sprite = [ICSprite spriteWithTexture:_texture];
        
		[_texture release];
        [_sprite flipTextureVertically];
		[self addChild:_sprite];
        
        // FIXME: need to set blend func (?)
//		[_sprite setBlendFunc:(ccBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];
        
		glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
        
        CHECK_GL_ERROR_DEBUG();
        
        // By default, set the display mode to kICRenderTextureDisplayMode_Always
        self.displayMode = kICRenderTextureDisplayMode_Always;
        
        // Render the sub scene on first call to draw (only applies when displayMode is set
        // to kICRenderTextureDisplayMode_Conditional)
        [self setNeedsDisplay];
	}
	return self;
}

- (void)dealloc
{
	glDeleteFramebuffers(1, &_fbo);
    self.subScene = nil;
    
	[super dealloc];
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
        
        // Get pick point (frame buffer space)
        kmVec3 pickVect;
        CGPoint pickPoint = ((ICNodeVisitorPicking *)visitor).pickPoint;
        kmVec3Fill(&pickVect, pickPoint.x, pickPoint.y, 0);
        
        // FIXME: this is rather ineffecient and should be encapsulated somewhere
        // can we have something like view:toWorld:withPlane:withViewport:?
        // Transform point from frame buffer space to world space
        kmVec3 projectPoint1, projectPoint2;
        kmVec3 unprojectPoint1, unprojectPoint2;
        projectPoint1 = pickVect;
        projectPoint2 = pickVect;
        projectPoint2.z = 1;
        
        ICScene *parentScene = [self parentScene];
        GLint parentFBOViewport[4];
        parentFBOViewport[0] = parentFBOViewport[1] = 0;
        parentFBOViewport[2] = [parentScene frameBufferSize].width * IC_CONTENT_SCALE_FACTOR();
        parentFBOViewport[3] = [parentScene frameBufferSize].height * IC_CONTENT_SCALE_FACTOR();
        [[parentScene camera] unprojectView:projectPoint1
                                    toWorld:&unprojectPoint1
                                   viewport:parentFBOViewport];
        [[parentScene camera] unprojectView:projectPoint2
                                    toWorld:&unprojectPoint2
                                   viewport:parentFBOViewport];
        
        // FIXME: assumes XY-plane at Z=0, this should essentially be the plane in
        // sprite used to present the render texture in the parent node space of the
        // render texture(?)
        kmVec3 p1 = (kmVec3){0,0,0};
        kmVec3 p2 = (kmVec3){1,0,0};
        kmVec3 p3 = (kmVec3){1,1,0};
        
        kmPlane p;
        kmPlaneFromPoints(&p, &p1, &p2, &p3);
        kmVec3 intersection;
        kmPlaneIntersectLine(&intersection, &p, &unprojectPoint1, &unprojectPoint2);
        
        // Transform pick point from world to local node space
        kmVec3 transformedPickVect;
        transformedPickVect = [self convertToNodeSpace:intersection];
        
        // Perform the inner hit test
        NSArray *innerHitTestNodes = [self.subScene hitTest:CGPointMake(transformedPickVect.x, transformedPickVect.y)];
        
        // Append nodes after(!) the next successful hit in the parent scene, which will be
        // the hit of the render texture's sprite
        [(ICNodeVisitorPicking *)visitor appendNodesToResultStack:innerHitTestNodes];
        
    } else if(self.displayMode == kICRenderTextureDisplayMode_Always ||
              (self.displayMode == kICRenderTextureDisplayMode_Conditional && _needsDisplay)) {
        
        // Visit inner scene for drawing
        [self.subScene visit];
        
        // Reset needsDisplay property if applicable
        if (self.displayMode == kICRenderTextureDisplayMode_Conditional && _needsDisplay) {
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

- (void)setNeedsDisplay
{
    _needsDisplay = YES;
    [super setNeedsDisplay];
}

@end
