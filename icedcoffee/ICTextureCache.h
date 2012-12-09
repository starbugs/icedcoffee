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
#import "icTypes.h"
#import "Platforms/icGL.h"
#import "ICAsyncTextureCacheDelegate.h"

@class ICTexture2D;
@class ICHostViewController;

/**
 @brief Provides texture caching and management
 
 The ICTextureCache class provides mechanisms to load, cache and release textures conveniently.
 
 Icedcoffee sets up one default texture cache for each OpenGL context controlled by the framework.
 You may retrieve the texture cache for the current OpenGL context using the
 ICTextureCache::currentTextureCache class method. Due to this mechanism, there usually is no need
 to instanciate a texture cache on your own.
 
 ### Using the Texture Cache ###
 
 The texture cache provides methods for loading textures synchronously and asynchronously. Once
 a texture is loaded, it is automatically cached in memory. When another component loads the same
 texture at a later time, the texture cache ensures that the cached texture is delivered without
 reloading it from its source medium.
 
 You may load textures from local files synchronously using the
 ICTextureCache::loadTextureFromFile:resolutionType: method. If you wish to load textures
 from local files in the background, you may use
 ICTextureCache::loadTextureFromFileAsync:resolutionType:withTarget:withObject:.
 
 If you need to unload a texture for a certain path or URL, use
 ICTextureCache::removeTextureForKey:. If you wish to remove all unused textures from the cache,
 call ICTextureCache::removeUnusedTextures. If you need to remove all textures from the cache,
 call ICTextureCache::removeAllTextures:. Removing a texture from the cache does not mean it is
 necessarily unloaded from memory. To make sure a texture's memory is freed, you must remove all
 references to that texture.
 */
@interface ICTextureCache : NSObject
{
@private
    NSMutableDictionary *_textures;
    dispatch_queue_t _dictQueue;
    dispatch_queue_t _loadingQueue;
    
    ICOpenGLContext *_auxGLContext;
    
    ICHostViewController *_hostViewController;
}

#pragma mark - Obtaining/Creating a Texture Cache
/** @name Obtaining/Creating a Texture Cache */

/**
 @brief Returns the texture cache associated with the current OpenGL context
 */
+ (id)currentTextureCache;

/** @cond */ // Exclude from docs
- (id)init __attribute__((unavailable("Must use initWithHostViewController: instead.")));
/** @endcond */

/**
 @brief Initializes the receiver with the given host view controller
 */
- (id)initWithHostViewController:(ICHostViewController *)hostViewController;


#pragma mark - Loading Textures into the Cache
/** @name Loading Textures into the Cache */

/**
 @brief Loads a texture from a file located at the given URL synchronously
 
 The loaded texture is added to the texture cache. If a texture with the same URL has already
 been loaded, the method will return the cached texture instead of reloading it from the file.
 The path parameter is used as the key to the texture in the texture cache.
 
 @param url An ``NSURL`` defining the URL of the file to be loaded
 
 @return If the texture could be loaded successfully, returns an ICTexture2D object representing
 the loaded texture. Otherwise returns nil.
 */
- (ICTexture2D *)loadTextureFromURL:(NSURL *)url;

/**
 @brief Loads a texture from a file located at the given URL synchronously using the
 specified resolution type
 
 The loaded texture is added to the texture cache. If a texture with the same URL has already
 been loaded, the method will return the cached texture instead of reloading it from the file.
 The path parameter is used as the key to the texture in the texture cache.
 
 @param url An ``NSURL`` defining the URL of the file to be loaded
 @param resolutionType An ICResolutionType enumerated value defining the resolution type of the
 texture
 
 @return If the texture could be loaded successfully, returns an ICTexture2D object representing
 the loaded texture. Otherwise returns nil.
 */
- (ICTexture2D *)loadTextureFromURL:(NSURL *)url
                     resolutionType:(ICResolutionType)resolutionType;

/**
 @brief Loads a texture from a file located at the given URL synchronously using the
 specified resolution type, returning error information upon failure
 
 The loaded texture is added to the texture cache. If a texture with the same URL has already
 been loaded, the method will return the cached texture instead of reloading it from the file.
 The path parameter is used as the key to the texture in the texture cache.
 
 @param url An ``NSURL`` defining the URL of the file to be loaded
 @param resolutionType An ICResolutionType enumerated value defining the resolution type of the
 texture
 @param error If an error occurs, upon return contains an ``NSError`` object that describes the
 problem
 
 @return If the texture could be loaded successfully, returns an ICTexture2D object representing
 the loaded texture. Otherwise returns nil.
 */
- (ICTexture2D *)loadTextureFromURL:(NSURL *)url
                     resolutionType:(ICResolutionType)resolutionType
                              error:(NSError **)error;

/**
 @brief Loads a texture from the given URL asynchronously using the given resolution type
 
 This method loads a texture asynchronously in the background while the calling thread's execution
 continues. You specify a ``target`` which implements the ICAsyncTextureCacheDelegate protocol.
 Once the texture has been loaded successfully, it is notified with a
 ICAsyncTextureCacheDelegate::textureDidLoad:object: message. If the texture could not be loaded
 because of an error, the target receives an
 ICAsyncTextureCacheDelegate::textureLoadingDidFailWithError: message along with an ``NSError``
 object describing the problem.
 
 @param path An ``NSURL`` defining the location of the texture file
 @param target An object conforming to the ICAsyncTextureCacheDelegate protocol. This object is
 notified once the texture has been loaded successfully or an error has occurred.
 @param object An arbitary object that is passed to the target when it is notified about the
 completion of the texture loading procedure. You may specify nil if this is not needed.
 
 @sa loadTextureFromURL:
 */
- (void)loadTextureFromURLAsync:(NSURL *)url
                     withTarget:(id<ICAsyncTextureCacheDelegate>)target
                     withObject:(id)object;

/**
 @brief Loads a texture from the given URL asynchronously using the given resolution type
 
 This method loads a texture asynchronously in the background while the calling thread's execution
 continues. You specify a ``target`` which implements the ICAsyncTextureCacheDelegate protocol.
 Once the texture has been loaded successfully, it is notified with a
 ICAsyncTextureCacheDelegate::textureDidLoad:object: message. If the texture could not be loaded
 because of an error, the target receives an
 ICAsyncTextureCacheDelegate::textureLoadingDidFailWithError: message along with an ``NSError``
 object describing the problem.
 
 @param path An ``NSURL`` defining the location of the texture file
 @param resolutionType An ICResolutionType enumerated value defining the resolution type of the
 texture
 @param target An object conforming to the ICAsyncTextureCacheDelegate protocol. This object is
 notified once the texture has been loaded successfully or an error has occurred.
 @param object An arbitary object that is passed to the target when it is notified about the
 completion of the texture loading procedure. You may specify nil if this is not needed.
 
 @sa loadTextureFromURL:resolutionType:
 */
- (void)loadTextureFromURLAsync:(NSURL *)url
                 resolutionType:(ICResolutionType)resolutionType
                     withTarget:(id<ICAsyncTextureCacheDelegate>)target
                     withObject:(id)object;

/**
 @brief Loads a texture from a file synchronously
 
 This method loads a texture from a file located on a locally mounted filesystem synchronously,
 thereby blocking the execution of the calling thread until the texture has been loaded.
 
 The loaded texture is added to the texture cache. If a texture with the same path has already
 been loaded, the method will return the cached texture instead of reloading it from the file.
 
 @param path The path of the texture file to be loaded
 
 @return If the texture could be loaded successfully, returns an ICTexture2D object representing
 the loaded texture. Otherwise returns nil.
 */
- (ICTexture2D *)loadTextureFromFile:(NSString *)path;

/**
 @brief Loads a texture from a file synchronously using the given resolution type

 This method loads a texture from a file located on a locally mounted filesystem synchronously,
 thereby blocking the execution of the calling thread until the texture has been loaded.

 The loaded texture is added to the texture cache. If a texture with the same path has already
 been loaded, the method will return the cached texture instead of reloading it from the file.
 
 @param path The path of the texture file to be loaded
 @param resolutionType An ICResolutionType enumerated value defining the resolution type of the
 texture
 
 @return If the texture could be loaded successfully, returns an ICTexture2D object representing
 the loaded texture. Otherwise returns nil.
 */
- (ICTexture2D *)loadTextureFromFile:(NSString *)path
                      resolutionType:(ICResolutionType)resolutionType;

/**
 @brief Loads a texture from a file synchronously using the given resolution type, returning
 error information upon failure

 This method loads a texture from a file located on a locally mounted filesystem synchronously,
 thereby blocking the execution of the calling thread until the texture has been loaded.

 The loaded texture is added to the texture cache. If a texture with the same path has already
 been loaded, the method will return the cached texture instead of reloading it from the file.
 
 @param path The path of the texture file to be loaded
 @param resolutionType An ICResolutionType enumerated value defining the resolution type of the
 texture
 @param error If an error occurs, upon return contains an ``NSError`` object that describes the
 problem
 
 @return If the texture could be loaded successfully, returns an ICTexture2D object representing
 the loaded texture. Otherwise returns nil and writes a pointer to an ``NSError`` object describing
 the problem to the ``error`` argument.
 */
- (ICTexture2D *)loadTextureFromFile:(NSString *)path
                      resolutionType:(ICResolutionType)resolutionType
                               error:(NSError **)error;


/**
 @brief Loads a texture from a file asynchronously

 This method loads a texture asynchronously in the background while the calling thread's execution
 continues. You specify a ``target`` which implements the ICAsyncTextureCacheDelegate protocol.
 Once the texture has been loaded successfully, it is notified with a
 ICAsyncTextureCacheDelegate::textureDidLoad:object: message. If the texture could not be loaded
 because of an error, the target receives an
 ICAsyncTextureCacheDelegate::textureLoadingDidFailWithError: message along with an ``NSError``
 object describing the problem.
 
 @param path An NSString defining the path to the texture file
 @param target An object conforming to the ICAsyncTextureCacheDelegate protocol. This object is
 notified once the texture has been loaded successfully or an error has occurred.
 @param object An arbitary object that is passed to the target when it is notified about the
 completion of the texture loading process. You may specify ``nil`` if such object is not required.
 
 @sa loadTextureFromFile:
 */
- (void)loadTextureFromFileAsync:(NSString *)path
                      withTarget:(id<ICAsyncTextureCacheDelegate>)target
                      withObject:(id)object;

/**
 @brief Loads a texture from a file asynchronously using the given resolution type
 
 This method loads a texture asynchronously in the background while the calling thread's execution
 continues. You specify a ``target`` which implements the ICAsyncTextureCacheDelegate protocol.
 Once the texture has been loaded successfully, it is notified with a
 ICAsyncTextureCacheDelegate::textureDidLoad:object: message. If the texture could not be loaded
 because of an error, the target receives an
 ICAsyncTextureCacheDelegate::textureLoadingDidFailWithError: message along with an ``NSError``
 object describing the problem.
 
 @param path An NSString defining the path to the texture file
 @param resolutionType An ICResolutionType enumerated value defining the resolution type of the
 texture
 @param target An object conforming to the ICAsyncTextureCacheDelegate protocol. This object is
 notified once the texture has been loaded successfully or an error has occurred.
 @param object An arbitary object that is passed to the target when it is notified about the
 completion of the texture loading procedure. You may specify nil if this is not needed.
 
 @sa loadTextureFromFile:resolutionType:
 */
- (void)loadTextureFromFileAsync:(NSString *)path
                  resolutionType:(ICResolutionType)resolutionType
                      withTarget:(id<ICAsyncTextureCacheDelegate>)target
                      withObject:(id)object;


#pragma mark - Managing Cached Textures
/** @name Managing Cached Textures */

/**
 @brief Returns the texture for the specified key
 */
- (ICTexture2D *)textureForKey:(NSString *)key;

/**
 @brief Removes the texture for the specified key
 
 @param key An ``NSString`` containing the absolute string of the URL used to load the texture.
 
 If you loaded your texture using a path to a local file, specify
 ``[[NSURL fileURLWithPath:texturePath] absoluteString]`` as ``key`` argument. If you loaded
 your texture using a URL, specify ``[url absoluteString]`` as ``key`` argument.
 */
- (void)removeTextureForKey:(NSString *)key;

/**
 @brief Removes all textures from the cache
 
 This method causes the texture cache to remove all textures from its internal dictionary, thereby
 giving up its strong references to these textures. Note that only the memory of those textures
 which are no longer referenced elsewhere will actually be freed.
 */
- (void)removeAllTextures;

/**
 @brief Removes unused textures from the cache
 
 This method removes all textures whose retain count is ``1`` from the texture cache.
 Note that only the memory of those textures which are no longer referenced elsewhere will
 actually be freed.
 */
- (void)removeUnusedTextures;


#pragma mark - Converting URLs and Paths to Keys
/** @name Converting URLs and Paths to Keys */

- (NSString *)keyFromURL:(NSURL *)url;

- (NSString *)keyFromPath:(NSString *)path;

@end
