//
//  Copyright (C) 2012 Tobias Lensing, Marcus Tillmanns
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

#import "ICGLBuffer.h"

@implementation ICGLBuffer

@synthesize bufferObject = _bo;
@synthesize target = _target;
@synthesize count = _count;
@synthesize stride = _stride;

- (id)initWithTarget:(GLenum)target
                data:(const void *)data
               count:(GLuint)count
              stride:(GLuint)stride
               usage:(GLenum)usage
{
    if ((self = [super init])) {
        glGenBuffers(1, &_bo);
        glBindBuffer(target, _bo);
        GLsizeiptr size = count * stride;
        glBufferData(target, size, data, usage);
        glBindBuffer(target, 0);
        
        _target = target;
        _count = count;
        _stride = stride;
    }
    return self;
}

- (void)dealloc
{
    glDeleteBuffers(1, &_bo);
    [super dealloc];
}

- (void)bind
{
    glBindBuffer(_target, _bo);
}

- (void)unbind
{
    glBindBuffer(_target, 0);
}

@end
