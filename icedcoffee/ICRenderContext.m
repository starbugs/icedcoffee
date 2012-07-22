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

#import "ICRenderContext.h"
#import "ICContextManager.h"

@implementation ICRenderContext

@synthesize textureCache = _textureCache;
@synthesize shaderCache = _shaderCache;

+ (id)currentRenderContext
{
    return [[ICContextManager defaultContextManager] renderContextForCurrentOpenGLContext];
}

- (id)init
{
    return [self initWithShareContext:nil];
}

- (id)initWithShareContext:(ICRenderContext *)shareContext
{
    if ((self = [super init])) {
        if (shareContext) {
            self.textureCache = shareContext.textureCache;
            self.shaderCache = shareContext.shaderCache;
        }
        _customObjects = nil; // lazy allocation
    }
    return self;
}

- (void)dealloc
{
    [_customObjects release];
    self.textureCache = nil;
    self.shaderCache = nil;
    [super dealloc];
}

- (void)setCustomObject:(id)object forKey:(id)key
{
    if (!_customObjects) {
        _customObjects = [[NSMutableDictionary alloc] init];
    }
    [_customObjects setObject:object forKey:key];
}

- (id)customObjectForKey:(id)key
{
    return [_customObjects objectForKey:key];
}

- (void)removeCustomObjectForKey:(id)key
{
    [_customObjects removeObjectForKey:key];
}

- (void)removeAllCustomObjects
{
    [_customObjects removeAllObjects];
}

@end
