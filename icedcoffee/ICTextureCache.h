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
 In the IcedCoffee framework, there is one default texture cache for each OpenGL context.
 You may retrieve the texture cache for the current OpenGL context using the
 ICTextureCache::currentTextureCache method.
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

/**
 @brief Returns the texture cache associated with the current OpenGL context
 */
+ (id)currentTextureCache;

- (id)init __attribute__((unavailable("Must use initWithHostViewController: instead.")));

/**
 @brief Initializes the receiver with the given host view controller
 */
- (id)initWithHostViewController:(ICHostViewController *)hostViewController;

/**
 @brief Loads a texture from a file synchronously
 
 The loaded texture is added to the texture cache. If a texture with the same path has already
 been loaded, the method will return the cached texture instead of reloading it from the file.
 The path parameter is used as the key to the texture in the texture cache.
 */
- (ICTexture2D *)loadTextureFromFile:(NSString *)path;

/**
 @brief Loads a texture from a file asynchronously

 This method performs the ICTextureCache::loadTextureFromFile: method to load a texture on a
 separate thread. The texture is loaded asynchronously in the background while the calling thread
 continues execution. Once the texture is loaded, the
 ICAsyncTextureCacheDelegate::textureDidLoad:object: message is sent to the specified target.
 
 @param path An NSString defining the path to the texture file
 @param target An object conforming to the ICAsyncTextureCacheDelegate protocol. This object
 receives an ICAsyncTextureCacheDelegate::textureDidLoad:object: message once the texture has
 been loaded successfully.
 @param object An arbitary object that is passed to the target when it is notified about the
 completion of the texture loading procedure. You may specify nil if this is not needed.
 
 @sa loadTextureFromFile:
 */
- (void)loadTextureFromFileAsync:(NSString *)path
                      withTarget:(id<ICAsyncTextureCacheDelegate>)target
                      withObject:(id)object;

/**
 @brief Returns the texture for the specified key
 */
- (ICTexture2D *)textureForKey:(NSString *)key;

/**
 @brief Removes all textures from the cache
 */
- (void)removeAllTextures;

/**
 @brief Removes unused textures from the cache
 
 The method removes all textures whose retain count is 1.
 */
- (void)removeUnusedTextures;

@end
