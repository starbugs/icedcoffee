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

#import "ICOpenGLContextManager.h"
#import "Platforms/icGL.h"

ICOpenGLContextManager *g_defaultOpenGLContextManager = nil;

@implementation ICOpenGLContextManager

+ (id)defaultOpenGLContextManager
{
    @synchronized (self) {
        if (!g_defaultOpenGLContextManager) {
            g_defaultOpenGLContextManager = [[ICOpenGLContextManager alloc] init];
        }
    }
    return g_defaultOpenGLContextManager;
}

- (id)init
{
    if ((self = [super init])) {
        _contexts = [[NSMutableDictionary alloc] initWithCapacity:1];
        _currentContextByThread = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

- (void)dealloc
{
    [_contexts release];
    [_currentContextByThread release];
    [super dealloc];
}

- (void)registerOpenGLContext:(ICOpenGLContext *)context
       forNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext
{
    NSValue *contextAddress = [NSValue valueWithPointer:nativeContext];
    [_contexts setObject:context forKey:contextAddress];
#if IC_ENABLE_DEBUG_OPENGL_CONTEXTS
    ICLog(@"Registered OpenGL context for native context: %@", [contextAddress description]);
#endif
}

- (void)unregisterOpenGLContextForNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext
{
    NSValue *contextAddress = [NSValue valueWithPointer:nativeContext];
    [_contexts removeObjectForKey:contextAddress];
#if IC_ENABLE_DEBUG_OPENGL_CONTEXTS
    ICLog(@"Unregistered render context for OpenGL context: %@", [contextAddress description]);
#endif
}

- (ICOpenGLContext *)openGLContextForNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext
{
    return [_contexts objectForKey:[NSValue valueWithPointer:nativeContext]];
}

- (ICOpenGLContext *)openGLContextForCurrentNativeOpenGLContext
{
    return [self openGLContextForNativeOpenGLContext:[IC_NATIVE_OPENGL_CONTEXT currentContext]];
}

- (ICOpenGLContext *)currentContext
{
    return [_currentContextByThread objectForKey:[NSValue valueWithPointer:[NSThread currentThread]]];
}

- (void)currentContextDidChange:(ICOpenGLContext *)context
{
    if (context) {
        kmGLSetCurrentContext(context);
        [_currentContextByThread setObject:context
                                    forKey:[NSValue valueWithPointer:[NSThread currentThread]]];
    } else {
        kmGLSetCurrentContext(NULL);
        [_currentContextByThread removeObjectForKey:[NSValue valueWithPointer:[NSThread currentThread]]];
    }
}

@end
