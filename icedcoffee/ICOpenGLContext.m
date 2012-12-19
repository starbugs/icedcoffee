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
#import "icDefaults.h"

@implementation ICOpenGLContext

@synthesize nativeContext = _nativeContext;
@synthesize textureCache = _textureCache;
@synthesize shaderCache = _shaderCache;
@synthesize glyphCache = _glyphCache;
@synthesize customObjects = _customObjects;
@synthesize contentScaleFactor = _contentScaleFactor;

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
    if ((self = [super init])) {
        _nativeContext = [nativeContext retain];
        if (shareContext) {
            self.textureCache = shareContext.textureCache;
            self.shaderCache = shareContext.shaderCache;
            self.contentScaleFactor = shareContext.contentScaleFactor;
            for (id key in shareContext.customObjects) {
                [self setCustomObject:[shareContext customObjectForKey:key] forKey:key];
            }
        } else {
            self.contentScaleFactor = IC_DEFAULT_CONTENT_SCALE_FACTOR;
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
#ifdef __IC_PLATFORM_IOS
    [EAGLContext setCurrentContext:self.nativeContext];
#elif defined(__IC_PLATFORM_MAC)
    [self.nativeContext makeCurrentContext];
#endif
    
    [[ICOpenGLContextManager defaultOpenGLContextManager] currentContextDidChange:self];
}

+ (void)clearCurrentContext
{
#ifdef __IC_PLATFORM_IOS
    [EAGLContext setCurrentContext:nil];
#elif defined(__IC_PLATFORM_MAC)
    [NSOpenGLContext clearCurrentContext];
#endif
    
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
