/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
 * Adapted for icedcoffee
 *
 */

// FIXME: bad codebase: code duplication, inconsistent, bad concept

#import "icGLState.h"
#import "icGL.h"
#import "ICShaderProgram.h"
#import "icConfig.h"
#import "ICShaderValue.h"

#if IC_ENABLE_GL_STATE_CACHE
static GLenum _icBlendingSource = -1;
static GLenum _icBlendingDest = -1;
static icGLServerState _icGLServerState = 0;
#endif // IC_ENABLE_GL_STATE_CACHE

void icGLPurgeStateCache()
{
    _icBlendingSource = -1;
    _icBlendingDest = -1;
    _icGLServerState = 0;
}

void icGLUniformModelViewProjectionMatrix(ICShaderProgram *shaderProgram)
{
	kmMat4 matrixP;
	kmMat4 matrixMV;
	kmMat4 matrixMVP;
    
	kmGLGetMatrix(KM_GL_PROJECTION, &matrixP );
	kmGLGetMatrix(KM_GL_MODELVIEW, &matrixMV );
    
	kmMat4Multiply(&matrixMVP, &matrixP, &matrixMV);
    
    [shaderProgram setShaderValue:[ICShaderValue shaderValueWithMat4: matrixMVP] forUniform:@"u_MVPMatrix"];
}

void icGLBlendFunc(GLenum sfactor, GLenum dfactor)
{
#if IC_ENABLE_GL_STATE_CACHE
	if( sfactor != _icBlendingSource || dfactor != _icBlendingDest ) {
		_icBlendingSource = sfactor;
		_icBlendingDest = dfactor;
		glBlendFunc( sfactor, dfactor );
	}
#else
	glBlendFunc( sfactor, dfactor );
#endif // IC_ENABLE_GL_STATE_CACHE
}

void icGLEnable(icGLServerState flags)
{
#if IC_ENABLE_GL_STATE_CACHE
    
	BOOL enabled = NO;
    
	/* GL_BLEND */
	if( (enabled=(flags & IC_GL_BLEND)) != (_icGLServerState & IC_GL_BLEND) ) {
		if( enabled ) {
			glEnable( GL_BLEND );
			_icGLServerState |= IC_GL_BLEND;
		} else {
			glDisable( GL_BLEND );
			_icGLServerState &= ~IC_GL_BLEND;
		}
	}
    
#else
	if (flags & IC_GL_BLEND)
		glEnable( GL_BLEND );
	else
		glDisable( GL_BLEND );
#endif
}

void icGLDisable(icGLServerState flags)
{
#if IC_ENABLE_GL_STATE_CACHE
    
	BOOL enabled = NO;
    
	/* GL_BLEND */
	if( (enabled=(flags & IC_GL_BLEND)) == (_icGLServerState & IC_GL_BLEND) ) {
		if( enabled ) {
			glDisable( GL_BLEND );
			_icGLServerState &= ~IC_GL_BLEND;
		} else {
			glEnable( GL_BLEND );
			_icGLServerState |= IC_GL_BLEND;
		}
	}
    
#else
	if (flags & IC_GL_BLEND)
		glDisable( GL_BLEND );
	else
		glEnable( GL_BLEND );
#endif    
}