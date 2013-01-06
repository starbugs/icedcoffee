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

#import "ICFramebuffer.h"

@implementation ICFramebuffer

@synthesize size = _size;
@synthesize isInFramebufferDrawContext = _isInFramebufferDrawContext;

+ (id)framebufferWithSize:(CGSize)size
              pixelFormat:(ICPixelFormat)pixelFormat
        depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
      stencilBufferFormat:(ICStencilBufferFormat)stencilBufferFormat
{
    return [[[[self class] alloc] initWithSize:size
                                   pixelFormat:pixelFormat
                             depthBufferFormat:depthBufferFormat
                           stencilBufferFormat:stencilBufferFormat] autorelease];
}

- (id)initWithSize:(CGSize)size
       pixelFormat:(ICPixelFormat)pixelFormat
 depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
stencilBufferFormat:(ICStencilBufferFormat)stencilBufferFormat
{
    if ((self = [super init])) {
        // Store formats
        _pixelFormat = pixelFormat;
        _depthBufferFormat = depthBufferFormat;
        _stencilBufferFormat = stencilBufferFormat;
        
        // Set size (automatically generates buffers)
        self.size = size;
    }
    return self;
}

- (void)dealloc
{
    if (_fbo) {
        glDeleteFramebuffers(1, &_fbo);
    }
    
    [super dealloc];
}

- (void)setSize:(CGSize)size
{
    if (size.width != _size.width || size.height != _size.height) {
        _size = size;
        
        float width = ICPointsToPixels(size.width);
        float height = ICPointsToPixels(size.height);
        
        // Store old FBO
        glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFBO);

        // Delete old FBO, if any
        if (_fbo) {
            glDeleteFramebuffers(1, &_fbo);
        }
        
        // Generate an FBO
        glGenFramebuffers(1, &_fbo);
        glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
        
        // Generate color render buffer
        glGenRenderbuffers(1, &_colorRBO);
        glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRBO);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA, (GLsizei)width, (GLsizei)height);        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRBO);
        
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
            glRenderbufferStorage(GL_RENDERBUFFER, depthFormat, (GLsizei)width, (GLsizei)height);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRBO);
            if (_stencilBufferFormat) {
                glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depthRBO);
            }
            
            glBindRenderbuffer(GL_RENDERBUFFER, oldRBO);
        }
        
        GLenum fboStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        NSAssert(fboStatus == GL_FRAMEBUFFER_COMPLETE,
                 @"Could not create framebuffer (fbo status: %x", fboStatus);
        
        // Bind old framebuffer
        glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
        IC_CHECK_GL_ERROR_DEBUG();
    }
}

- (CGSize)sizeInPixels
{
    return CGSizeMake(ICPointsToPixels(_size.width), ICPointsToPixels(_size.height));
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
	glViewport(0, 0, self.sizeInPixels.width, self.sizeInPixels.height);
    
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFBO);
	glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
    
    IC_CHECK_GL_ERROR_DEBUG();
    
    _isInFramebufferDrawContext = YES;    
}

- (void)end
{
	glBindFramebuffer(GL_FRAMEBUFFER, _oldFBO);
    IC_CHECK_GL_ERROR_DEBUG();
    
	// Restore previous matrices
    kmGLMatrixMode(GL_PROJECTION);
    kmGLPopMatrix();
    kmGLMatrixMode(GL_MODELVIEW);
	kmGLPopMatrix();
    
	// Restore viewport
	glViewport(_oldFBOViewport[0], _oldFBOViewport[1], _oldFBOViewport[2], _oldFBOViewport[3]);
    
    _isInFramebufferDrawContext = NO;    
}

- (icColor4B)colorOfPixelAtLocation:(CGPoint)location
{
    icColor4B color;
    BOOL      performBeginEnd = NO;
    
    if (!self.isInFramebufferDrawContext) {
        performBeginEnd = YES;
        [self begin];
    }
    
    glReadPixels(location.x, location.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, &color);
    //glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, 1, 1, 0);
    //glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE, &color);
    
    if (performBeginEnd)
        [self end];
    
    return color;    
}

@end
