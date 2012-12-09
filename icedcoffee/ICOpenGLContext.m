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

#import "ICOpenGLContext.h"
#import "ICOpenGLContextManager.h"

@implementation ICOpenGLContext

@synthesize nativeContext = _nativeContext;
@synthesize textureCache = _textureCache;
@synthesize shaderCache = _shaderCache;
@synthesize customObjects = _customObjects;

+ (id)openGLContextWithNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext
{
    return [[[[self class] alloc] initWithNativeOpenGLContext:nativeContext] autorelease];
}

+ (id)openGLContextWithNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext
                              shareContext:(ICOpenGLContext *)shareContext
{
    return [[[[self class] alloc] initWithNativeOpenGLContext:nativeContext
                                                 shareContext:shareContext] autorelease];
}

- (id)initWithNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext
{
    return [self initWithNativeOpenGLContext:nativeContext shareContext:nil];
}

- (id)initWithNativeOpenGLContext:(IC_NATIVE_OPENGL_CONTEXT *)nativeContext
                     shareContext:(ICOpenGLContext *)shareContext
{
    NSAssert([self class] != [ICOpenGLContext class], @"Instanciate a concrete ICOpenGLContext");
    
    if ((self = [super init])) {
        _nativeContext = [nativeContext retain];
        if (shareContext) {
            self.textureCache = shareContext.textureCache;
            self.shaderCache = shareContext.shaderCache;
            for (id key in shareContext.customObjects) {
                [self setCustomObject:[shareContext customObjectForKey:key] forKey:key];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [_customObjects release];
    [_nativeContext release];
    
    [super dealloc];
}

- (id)registerContext
{
    [[ICOpenGLContextManager defaultOpenGLContextManager] registerOpenGLContext:self
                                                         forNativeOpenGLContext:self.nativeContext];
    return self;
}

- (id)unregisterContext
{
    [[ICOpenGLContextManager defaultOpenGLContextManager] unregisterOpenGLContextForNativeOpenGLContext:self.nativeContext];
    return self;
}

+ (ICOpenGLContext *)currentContext
{
    return [[ICOpenGLContextManager defaultOpenGLContextManager] currentContext];
}

- (void)makeCurrentContext
{
    NSAssert([self class] != [ICOpenGLContext class], @"ICOpenGLContext is abstract, instantiate " \
                                                       "ICOpenGLContextMac or ICOpenGLContextIOS");
    // Override in platform-dependent subclass and call [super makeCurrentContext]
    [[ICOpenGLContextManager defaultOpenGLContextManager] currentContextDidChange:self];
}

+ (void)clearCurrentContext
{
    NSAssert([self class] != [ICOpenGLContext class], @"ICOpenGLContext is abstract, instantiate " \
                                                       "ICOpenGLContextMac or ICOpenGLContextIOS");
    // Override in platform-dependent subclass and call [super clearCurrentContext]
    [[ICOpenGLContextManager defaultOpenGLContextManager] currentContextDidChange:nil];
}

- (void)setCustomObject:(id)object forKey:(id)key
{
    if (!_customObjects) {
        _customObjects = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    [_customObjects setObject:object forKey:key];
}

- (void)removeCustomObjectForKey:(id)key
{
    [_customObjects removeObjectForKey:key];
}

- (void)removeAllCustomObjects
{
    [_customObjects removeAllObjects];
}

- (id)customObjectForKey:(id)key
{
    return [_customObjects objectForKey:key];
}

@end
