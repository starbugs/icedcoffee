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

#import "ICContextManager.h"
#import "ICRenderContext.h"
#import "icConfig.h"

ICContextManager *g_defaultContextManager = nil;

@implementation ICContextManager

+ (id)defaultContextManager
{
    @synchronized (self) {
        if (!g_defaultContextManager) {
            g_defaultContextManager = [[ICContextManager alloc] init];
        }
        return g_defaultContextManager;
    }
}

- (id)init
{
    if ((self = [super init])) {
        _contexts = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

- (void)dealloc
{
    [_contexts release];
    [super dealloc];
}

- (void)registerRenderContext:(ICRenderContext *)renderContext
             forOpenGLContext:(IC_PLATFORM_GL_CONTEXT *)openGLContext
{
    NSValue *contextAddress = [NSValue valueWithPointer:openGLContext];
    [_contexts setObject:renderContext forKey:contextAddress];
#if IC_ENABLE_DEBUG_OPENGL_CONTEXTS
    ICLog(@"Registered render context for OpenGL context: %@", [contextAddress description]);
#endif
}

- (void)unregisterRenderContextForOpenGLContext:(IC_PLATFORM_GL_CONTEXT *)openGLContext
{
    NSValue *contextAddress = [NSValue valueWithPointer:openGLContext];
    [_contexts removeObjectForKey:contextAddress];
#if IC_ENABLE_DEBUG_OPENGL_CONTEXTS
    ICLog(@"Unregistered render context for OpenGL context: %@", [contextAddress description]);
#endif
}

- (ICRenderContext *)renderContextForOpenGLContext:(IC_PLATFORM_GL_CONTEXT *)openGLContext
{
    return [_contexts objectForKey:[NSValue valueWithPointer:openGLContext]];
}

- (ICRenderContext *)renderContextForCurrentOpenGLContext
{
    return [self renderContextForOpenGLContext:[IC_PLATFORM_GL_CONTEXT currentContext]];
}

@end
