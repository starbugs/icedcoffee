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

#import "icGL.h"

// Adapted from http://www.opengl.org/wiki/GL_Error_Codes
NSString *NSStringFromGLError(GLenum error) {
    switch (error) {
        case GL_INVALID_ENUM: {
            return @"GL_INVALID_ENUM: Invalid enumeration parameter given for a function";
        }
        case GL_INVALID_VALUE: {
            return @"GL_INVALID_VALUE: Invalid value parameter given for a function";
        }
        case GL_INVALID_OPERATION: {
            return @"GL_INVALID_OPERATION: The set of state for a command is not legal " \
            "for the parameters given to that command.";
        }
        case GL_OUT_OF_MEMORY: {
            return @"GL_OUT_OF_MEMORY: Memory cannot be allocated";
        }
        case GL_INVALID_FRAMEBUFFER_OPERATION: {
            return @"GL_INVALID_FRAMEBUFFER_OPERATION: Attempted to read from or write to " \
            "a frame buffer that is not complete";
        }
        case GL_STACK_OVERFLOW: {
            return @"GL_STACK_OVERFLOW: Stack pushing operation cannot be done, because it would " \
            "overflow the size limit of the stack";
        }
        case GL_STACK_UNDERFLOW: {
            return @"GL_STACK_UNDERFLOW: Stack popping operation cannot be done, because the " \
            "stack is already at its lowest point";
        }
    }
    return @"Unknown OpenGL error";
}
