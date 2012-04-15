//
// Copyright 2011 Jeff Lamarche
//
// Redistribution and use in source and binary forms, with or without modification, are permitted provided
// that the following conditions are met:
//	1. Redistributions of source code must retain the above copyright notice, this list of conditions and
//		the following disclaimer.
//
//	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions
//		and the following disclaimer in the documentation and/or other materials provided with the
//		distribution.
//
//	THIS SOFTWARE IS PROVIDED BY THE FREEBSD PROJECT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE FREEBSD PROJECT
//	OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
//	OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
//	AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//
// Adapted for cocos2d http://www.cocos2d-iphone.org
// Then adapted for IcedCoffee

#import "ICShaderProgram.h"
#import "icMacros.h"
#import "icGL.h"

typedef void (*GLInfoFunction)(GLuint program,
                               GLenum pname,
                               GLint* params);
typedef void (*GLLogFunction) (GLuint program,
                               GLsizei bufsize,
                               GLsizei* length,
                               GLchar* infolog);


@interface ICShaderProgram (Private)
- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file;
- (NSString *)logForOpenGLObject:(GLuint)object
                    infoCallback:(GLInfoFunction)infoFunc
                         logFunc:(GLLogFunction)logFunc;
@end

@implementation ICShaderProgram

- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename
            fragmentShaderFilename:(NSString *)fShaderFilename
{
    if ((self = [super init]))
    {
        _program = glCreateProgram();
        
		_vertShader = _fragShader = 0;
        
		if( vShaderFilename ) {
			if (![self compileShader:&_vertShader type:GL_VERTEX_SHADER file:vShaderFilename]) {
				ICLOG(@"IcedCoffee: ERROR: Failed to compile vertex shader: %@", vShaderFilename);
            }
		}
        
        // Create and compile fragment shader
		if (fShaderFilename) {
			if (![self compileShader:&_fragShader type:GL_FRAGMENT_SHADER file:fShaderFilename]) {
				ICLOG(@"IcedCoffee: ERROR: Failed to compile fragment shader: %@", fShaderFilename);
            }
		}
        
		if (_vertShader)
			glAttachShader(_program, _vertShader);
        
		if (_fragShader)
			glAttachShader(_program, _fragShader);
        
    }
    
    return self;
}

- (void)dealloc
{
	ICLOG_DEALLOC(@"IcedCoffee: deallocing %@", self);
    
	// There is no need to delete the shaders. They should have been already deleted.
	NSAssert(_vertShader == 0, @"Vertex Shaders should have been already deleted");
	NSAssert(_fragShader == 0, @"Fragment Shaders should have been already deleted");
    
    if (_program) {
        glDeleteProgram(_program);
    }
    
    [super dealloc];
}

- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source =
    (GLchar *)[[NSString stringWithContentsOfFile:file
                                         encoding:NSUTF8StringEncoding
                                            error:nil] UTF8String];
    if (!source)
        return NO;
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    
	if (!status) {
		if (type == GL_VERTEX_SHADER)
			ICLOG(@"IcedCoffee: %@: %@", file, [self vertexShaderLog]);
		else
			ICLOG(@"IcedCoffee: %@: %@", file, [self fragmentShaderLog]);
        
	}
    return status == GL_TRUE;
}

- (void)addAttribute:(NSString *)attributeName index:(GLuint)index
{
	glBindAttribLocation(_program, index, [attributeName UTF8String]);
}

- (void)updateUniforms
{
	// Since sample most probably won't change, set it to 0 now.
    
	_uniforms[kICUniformMVPMatrix] = glGetUniformLocation(_program, kICUniformMVPMatrix_s);
	_uniforms[kICUniformSampler] = glGetUniformLocation(_program, kICUniformSampler_s);
        
	glUseProgram(_program);
	glUniform1i(_uniforms[kICUniformSampler], 0);
}

- (BOOL)link
{
    glLinkProgram(_program);
    
#if DEBUG
	GLint status;
    glValidateProgram(_program);
    
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
		ICLOG(@"IcedCoffee: ERROR: Failed to link program: %i", _program);
		if (_vertShader)
			glDeleteShader(_vertShader);
		if (_fragShader)
			glDeleteShader(_fragShader);
		glDeleteProgram(_program);
		_vertShader = _fragShader = _program = 0;
        return NO;
	}
#endif
    
    if (_vertShader)
        glDeleteShader(_vertShader);
    if (_fragShader)
        glDeleteShader(_fragShader);
    
	_vertShader = _fragShader = 0;
    
    return YES;
}

- (void)use
{
    glUseProgram(_program);
}

- (NSString *)logForOpenGLObject:(GLuint)object
                    infoCallback:(GLInfoFunction)infoFunc
                         logFunc:(GLLogFunction)logFunc
{
    GLint logLength = 0, charsWritten = 0;
    
    infoFunc(object, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength < 1)
        return nil;
    
    char *logBytes = malloc(logLength);
    logFunc(object, logLength, &charsWritten, logBytes);
    NSString *log = [[[NSString alloc] initWithBytes:logBytes
                                              length:logLength
                                            encoding:NSUTF8StringEncoding]
                     autorelease];
    free(logBytes);
    return log;
}

- (NSString *)vertexShaderLog
{
    return [self logForOpenGLObject:_vertShader
                       infoCallback:(GLInfoFunction)&glGetProgramiv
                            logFunc:(GLLogFunction)&glGetProgramInfoLog];
    
}

- (NSString *)fragmentShaderLog
{
	return [self logForOpenGLObject:_fragShader
					   infoCallback:(GLInfoFunction)&glGetShaderiv
							logFunc:(GLLogFunction)&glGetShaderInfoLog];
}

- (NSString *)programLog
{
    return [self logForOpenGLObject:_program
                       infoCallback:(GLInfoFunction)&glGetProgramiv
                            logFunc:(GLLogFunction)&glGetProgramInfoLog];
}

- (const GLint *)uniforms
{
    return _uniforms;
}

- (const GLuint)program
{
    return _program;
}

@end
