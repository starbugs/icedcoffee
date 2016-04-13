//  
//  Copyright (C) 2016 Tobias Lensing, Marcus Tillmanns
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

@interface ICShaderCache (Private)
- (void)loadDefaultShaderPrograms;
@end

@implementation ICShaderCache

@synthesize shaderFactory = _shaderFactory;

+ (id)currentShaderCache
{
    ICOpenGLContext *openGLContext = [ICOpenGLContext currentContext];
    NSAssert(openGLContext != nil, @"No OpenGL context available for current native OpenGL context");
    NSAssert(openGLContext.shaderCache != nil, @"No shader cache created yet for this context");
    return openGLContext.shaderCache;
}

+ (void)purgeCurrentShaderCache
{
    [[[self class] currentShaderCache] removeAllShaderPrograms];
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

- (void)removeAllShaderPrograms
{
    [_programs removeAllObjects];
}

- (void)removeUnusedShaderPrograms
{
    NSArray *keys = [_programs allKeys];
    for (id key in keys) {
        id value = [_programs objectForKey:key];
        if ([value retainCount] == 1) {
            ICLog(@"icedcoffee: ICShaderCache: removing unused shader program: %@", key);
            [_programs removeObjectForKey:key];
        }
    }
}


@end
