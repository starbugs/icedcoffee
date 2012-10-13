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
//  Inspired by cocos2d-iphone.org

#import "ICShaderCache.h"
#import "ICShaderFactory.h"
#import "ICShaderProgram.h"
#import "ICContextManager.h"
#import "ICRenderContext.h"

@interface ICShaderCache (Private)
- (void)loadDefaultShaderPrograms;
@end

@implementation ICShaderCache

@synthesize shaderFactory = _shaderFactory;

+ (id)currentShaderCache
{
    ICRenderContext *renderContext = [[ICContextManager defaultContextManager]
                                      renderContextForCurrentOpenGLContext];
    NSAssert(renderContext != nil, @"No render context available for current OpenGL context");
    ICShaderCache *shaderCache = renderContext.shaderCache;
    if (!shaderCache) {
        shaderCache = renderContext.shaderCache = [[[ICShaderCache alloc] init] autorelease];
    }
    return shaderCache;
}

+ (void)purgeCurrentShaderCache
{
    // FIXME: this is wrong
    [[[self class] currentShaderCache] release];
}

- (id)init
{
    if ((self = [super init])) {
        _programs = [[NSMutableDictionary alloc] init];
        _shaderFactory = [[ICShaderFactory alloc] init];
        [self loadDefaultShaderPrograms];
    }
    return self;
}

- (void)dealloc
{
    [_programs release];
    [_shaderFactory release];
    [super dealloc];
}

- (void)loadDefaultShaderPrograms
{
    NSDictionary *defaultShaderPrograms = [self.shaderFactory createDefaultShaderPrograms];
    for (NSString *key in defaultShaderPrograms) {
        [self setShaderProgram:[defaultShaderPrograms objectForKey:key] forKey:key];
    }
}

- (void)setShaderProgram:(ICShaderProgram *)program forKey:(id)key
{
    [_programs setObject:program forKey:key];
}

- (ICShaderProgram *)shaderProgramForKey:(id)key
{
    return [_programs objectForKey:key];
}


@end
