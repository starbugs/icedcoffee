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
#import "ICShaderValue.h"
#import "ICShaderUniform.h"
#import "icMacros.h"
#import "icGL.h"


uint glTypeForShaderValueType(ICShaderValueType valueType)
{
    switch (valueType) {
        case ICShaderValueTypeInt:
            return GL_INT;
        case ICShaderValueTypeFloat:
            return GL_FLOAT;
        case ICShaderValueTypeVec2:
            return GL_FLOAT_VEC2;
        case ICShaderValueTypeVec3:
            return GL_FLOAT_VEC3;
        case ICShaderValueTypeVec4:
            return GL_FLOAT_VEC4;
        case ICShaderValueTypeMat4:
            return GL_FLOAT_MAT4;
        case ICShaderValueTypeSampler2D:
            return GL_SAMPLER_2D;
        default:
            assert(nil && "Type not supported"); // not reached
            break;
    }
    return 0; // not reached
}

ICShaderValueType shaderValueTypeForGLType(GLenum type)
{
    switch (type) {
        case GL_INT:
            return ICShaderValueTypeInt;
        case GL_FLOAT:
            return ICShaderValueTypeFloat;
        case GL_FLOAT_VEC2:
            return ICShaderValueTypeVec2;
        case GL_FLOAT_VEC3:
            return ICShaderValueTypeVec3;
        case GL_FLOAT_VEC4:
            return ICShaderValueTypeVec4;
        case GL_FLOAT_MAT4:
            return ICShaderValueTypeMat4;
        case GL_SAMPLER_2D:
            return ICShaderValueTypeSampler2D;
        default:
            assert(nil && "Type not supported"); // not reached
            break;
    }
    return ICShaderValueTypeInvalid;
}


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
               source:(NSString *)sourceString;
- (NSString *)logForOpenGLObject:(GLuint)object
                    infoCallback:(GLInfoFunction)infoFunc
                         logFunc:(GLLogFunction)logFunc;
- (void)fetchUniforms;
@end

@implementation ICShaderProgram

@synthesize program = _program;
@synthesize programName = _programName;
@synthesize uniforms = _uniforms;

+ (id)shaderProgramWithName:(NSString *)programName
         vertexShaderString:(NSString *)vShaderString
       fragmentShaderString:(NSString *)fShaderString
{
    return [[[[self class] alloc] initWithName:programName
                            vertexShaderString:vShaderString
                          fragmentShaderString:fShaderString] autorelease];
}

+ (id)shaderProgramWithVertexShaderFilename:(NSString *)vShaderFilename
                     fragmentShaderFilename:(NSString *)fShaderFilename
{
    return [[[[self class] alloc] initWithVertexShaderFilename:vShaderFilename
                                        fragmentShaderFilename:fShaderFilename] autorelease];
}

- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename
            fragmentShaderFilename:(NSString *)fShaderFilename
{
    NSString *programName = [[vShaderFilename lastPathComponent] stringByDeletingPathExtension];
    
    NSString *vShaderString = nil;
    NSString *fShaderString = nil;
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if (vShaderFilename && [fileManager fileExistsAtPath:vShaderFilename]) {
        vShaderString = [NSString stringWithContentsOfFile:vShaderFilename
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    } else {
        ICLog(@"Could not load vertex shader from file %@", vShaderFilename);
    }
    
    if (fShaderFilename && [fileManager fileExistsAtPath:fShaderFilename]) {
        fShaderString = [NSString stringWithContentsOfFile:fShaderFilename
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    } else {
        ICLog(@"Could not load fragment shader from file %@", fShaderFilename);
    }
    
    [fileManager release];
    
    return [self initWithName:programName
           vertexShaderString:vShaderString
         fragmentShaderString:fShaderString];
}

-   (id)initWithName:(NSString *)programName
  vertexShaderString:(NSString *)vShaderString
fragmentShaderString:(NSString *)fShaderString
{
    if ((self = [super init]))
    {
        _programName = [programName copy];
        
        _uniforms = [[NSMutableDictionary alloc] init];
        
        _program = glCreateProgram();
        
		_vertShader = _fragShader = 0;
        
		if (vShaderString) {
			if (![self compileShader:&_vertShader type:GL_VERTEX_SHADER source:vShaderString]) {
				ICLog(@"IcedCoffee: ERROR: Failed to compile vertex shader: %@", _programName);
            }
		}
        
        // Create and compile fragment shader
		if (fShaderString) {
			if (![self compileShader:&_fragShader type:GL_FRAGMENT_SHADER source:fShaderString]) {
				ICLog(@"IcedCoffee: ERROR: Failed to compile fragment shader: %@", _programName);
            }
		}
        
		if (_vertShader)
			glAttachShader(_program, _vertShader);
        
		if (_fragShader)
			glAttachShader(_program, _fragShader);
        
        IC_CHECK_GL_ERROR_DEBUG();
    }
    
    return self;
}

- (void)dealloc
{
	ICLogDealloc(@"IcedCoffee: deallocing %@", self);
    
    [_uniforms release];
    
	// There is no need to delete the shaders. They should have been already deleted.
	NSAssert(_vertShader == 0, @"Vertex Shaders should have been already deleted");
	NSAssert(_fragShader == 0, @"Fragment Shaders should have been already deleted");
    
    if (_program) {
        glDeleteProgram(_program);
    }
    
    [_programName release];
    
    [super dealloc];
}

- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
               source:(NSString *)sourceString
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[sourceString UTF8String];
    if (!source)
        return NO;
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    
	if (!status) {
		if (type == GL_VERTEX_SHADER)
			ICLog(@"IcedCoffee: %@: %@", _programName, [self vertexShaderLog]);
		else
			ICLog(@"IcedCoffee: %@: %@", _programName, [self fragmentShaderLog]);
        
	}
    
    IC_CHECK_GL_ERROR_DEBUG();
    
    return status == GL_TRUE;
}

- (void)addAttribute:(NSString *)attributeName index:(GLuint)index
{
	glBindAttribLocation(_program, index, [attributeName UTF8String]);
    IC_CHECK_GL_ERROR_DEBUG();    
}

- (BOOL)setShaderValue:(ICShaderValue *)shaderValue forUniform:(NSString *)uniformName
{
    ICShaderUniform *uniform = [_uniforms objectForKey:uniformName];
    return [uniform setToShaderValue:shaderValue];
}

- (ICShaderValue *)shaderValueForUniform:(NSString *)uniformName
{
    return [_uniforms objectForKey:uniformName];
}

- (void)updateUniforms
{
    glUseProgram(_program);
    NSEnumerator* e = [_uniforms objectEnumerator];
    
    ICShaderUniform* u;
    
    while(u = (ICShaderUniform*)[e nextObject])
    {
        switch(u.type)
        {
            case ICShaderValueTypeInt:
                glUniform1i(u.location, [u intValue]);
                IC_CHECK_GL_ERROR_DEBUG();
                break;
            case ICShaderValueTypeFloat:
                glUniform1f(u.location, [u floatValue]);
                IC_CHECK_GL_ERROR_DEBUG();
                break;
            case ICShaderValueTypeVec2:
            {
                kmVec2 v = [u vec2Value];  
                glUniform2fv(u.location, 1, (GLfloat*)&v);
                IC_CHECK_GL_ERROR_DEBUG();
                break;
            }
            case ICShaderValueTypeVec3:
            {
                kmVec3 v = [u vec3Value];  
                glUniform3fv(u.location, 1, (GLfloat*)&v);
                IC_CHECK_GL_ERROR_DEBUG();
                break;
            }
            case ICShaderValueTypeVec4:
            {
                kmVec4 v = [u vec4Value];  
                glUniform4fv(u.location, 1, (GLfloat*)&v);
                IC_CHECK_GL_ERROR_DEBUG();
                break;
            }
            case ICShaderValueTypeMat4:
            {
                glUniformMatrix4fv(u.location, 1, GL_FALSE, [u mat4Value].mat);
                IC_CHECK_GL_ERROR_DEBUG();
                break;
            }
 
            case ICShaderValueTypeSampler2D:
            {
                glUniform1i(u.location, [u intValue]);
                IC_CHECK_GL_ERROR_DEBUG();
                break;
            }
            default:
                break;
        }
    }
        
    IC_CHECK_GL_ERROR_DEBUG();
}

// Adapted from http://stackoverflow.com/questions/4783912/how-can-i-find-a-list-of-all-the-uniforms-in-opengl-es-2-0-vertex-shader-pro
- (void)fetchUniforms
{
    GLint numUniforms;
    glGetProgramiv(_program, GL_ACTIVE_UNIFORMS, &numUniforms);
    for(int i=0; i<numUniforms; ++i)  {
        int name_len=-1, num=-1;
        GLenum type = GL_ZERO;
        char name[100];
        glGetActiveUniform(_program, i, sizeof(name)-1,
                           &name_len, &num, &type, name);
        name[name_len] = 0;
        GLuint location = glGetUniformLocation(_program, name);
        ICShaderValueType shaderValueType = shaderValueTypeForGLType(type);
        if (shaderValueType == ICShaderValueTypeInvalid) {
            NSLog(@"Invalid shader value type for uniform %s", name);
        }
        [_uniforms setObject:[ICShaderUniform shaderUniformWithType:shaderValueType location:location]
                                                             forKey:[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
    }
    
    if ([_uniforms objectForKey:@"u_texture"]) {
        [self setShaderValue:[ICShaderValue shaderValueWithInt:0] forUniform:@"u_texture"];
    }
    if ([_uniforms objectForKey:@"u_texture2"]) {
        [self setShaderValue:[ICShaderValue shaderValueWithInt:1] forUniform:@"u_texture2"];
    }
}

- (BOOL)link
{
    glLinkProgram(_program);
    
#if DEBUG
	GLint status;
    glValidateProgram(_program);
    
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
		ICLog(@"IcedCoffee: ERROR: Failed to link program: %i", _program);
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
    
    IC_CHECK_GL_ERROR_DEBUG();
    
    [self fetchUniforms];
    
    return YES;
}

- (void)use
{
    glUseProgram(_program);
    [self updateUniforms];
    IC_CHECK_GL_ERROR_DEBUG();    
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

@end
