//  
//  Copyright (C) 2012 Tobias Lensing
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

//  Inspired by cocos2d's CCTextureCache class

#import <Foundation/Foundation.h>
#import "icMacros.h"
#import "Platforms/icGL.h"
#import "ICAsyncTextureCacheDelegate.h"

@class ICTexture2D;
@class ICHostViewController;

/**
 @brief Provides texture caching and management
 
 The ICTextureCache class should be used to load and unload textures in your application.
 It provides mechanisms to load, cache and unload textures synchronously or asynchronously.
 
 ICTextureCache instances are always bound to an ICHostViewController object and should
 thus not be instanciated manually. ICHostViewController instanciates an associated
 ICTextureCache object when an ICGLView is set on it. You may access that texture cache
 object using the ICHostViewController's textureCache property.
 */
@interface ICTextureCache : NSObject
{
@private
    NSMutableDictionary *_textures;
    dispatch_queue_t _dictQueue;
    dispatch_queue_t _loadingQueue;
    
#ifdef __IC_PLATFORM_MAC
    NSOpenGLContext *_auxGLContext;
#elif defined(__IC_PLATFORM_IOS)
    EAGLContext *_auxGLContext;
#endif
}

- (id)initWithHostViewController:(ICHostViewController *)hostViewController;

- (ICTexture2D *)loadTextureFromFile:(NSString *)path;

- (void)loadTextureFromFileAsync:(NSString *)path
                      withTarget:(id<ICAsyncTextureCacheDelegate>)target
                      withObject:(id)object;

- (ICTexture2D *)textureForKey:(NSString *)key;

- (void)removeAllTextures;

- (void)removeUnusedTextures;

@end
