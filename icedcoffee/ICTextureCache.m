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

//  Inspired by cocos2d's CCTextureCache class, some portions of code borrowed and refactored

#import "ICTextureCache.h"
#import "ICTextureLoader.h"
#import "ICHostViewController.h"
#import "icUtils.h"
#import "icConfig.h"

@interface ICTextureCache (Private)
- (void)notifyAsyncTextureDidLoad:(NSDictionary *)textureInfo;
@end

@implementation ICTextureCache

+ (id)currentTextureCache
{
    ICOpenGLContext *openGLContext = [ICOpenGLContext currentContext];
    NSAssert(openGLContext != nil, @"No OpenGL context available for current native OpenGL context");
    return [openGLContext textureCache];
}

- (id)initWithHostViewController:(ICHostViewController *)hostViewController
{
    if ((self = [super init])) {
#if IC_ENABLE_DEBUG_TEXTURE_CACHE
        ICLog(@"Initializing texture cache for HVC %@", [hostViewController description]);
#endif
        _textures = [[NSMutableDictionary alloc] init];
        
        // Setup GCD queues
        _loadingQueue = dispatch_queue_create("org.icedcoffee.texturecacheloading", NULL);
        _dictQueue = dispatch_queue_create("org.icedcoffee.texturecachedict", NULL);
        
        // Set up an auxiliary OpenGL context for asynchronous texture loading
        ICGLView *view = (ICGLView *)[hostViewController view];
        NSAssert(view, @"View needs to be initialized before texture cache");

        _auxGLContext = icCreateAuxGLContextForView(view, YES);
		NSAssert(_auxGLContext, @"Could not create OpenGL context");
        
        _hostViewController = hostViewController;
    }
    return self;
}

- (void)dealloc
{
#if IC_ENABLE_DEBUG_TEXTURE_CACHE
    ICLog(@"Deallocating texture cache for HVC %@", [_hostViewController description]);
#endif

    [self removeAllTextures];
    
    [_auxGLContext release];
    _auxGLContext = nil;
    
    dispatch_release(_loadingQueue);
    dispatch_release(_dictQueue);
    
    [super dealloc];
}

- (ICTexture2D *)loadTextureFromURL:(NSURL *)url
{
    return [self loadTextureFromURL:url resolutionType:ICResolutionTypeUnknown];
}

- (ICTexture2D *)loadTextureFromURL:(NSURL *)url
                     resolutionType:(ICResolutionType)resolutionType
{
    return [self loadTextureFromURL:url resolutionType:resolutionType error:nil];
}

- (ICTexture2D *)loadTextureFromURL:(NSURL *)url
                     resolutionType:(ICResolutionType)resolutionType
                              error:(NSError **)error
{
#if IC_ENABLE_DEBUG_TEXTURE_CACHE
    ICLog(@"Loading texture %@", [url absoluteString]);
#endif
    __block ICTexture2D *texture;
    dispatch_sync(_dictQueue, ^{
        texture = [_textures objectForKey:[url absoluteString]];
    });
    if (!texture) {
        texture = [ICTextureLoader loadTextureFromURL:url
                                       resolutionType:resolutionType
                                                error:error];
    }
    NSAssert(texture, @"Texture object is nil, most likely the texture file could not be loaded");
    dispatch_sync(_dictQueue, ^{
        [_textures setObject:texture forKey:[url absoluteString]];
    });
    return texture;
}

- (void)loadTextureFromURLAsync:(NSURL *)url
                     withTarget:(id<ICAsyncTextureCacheDelegate>)target
                     withObject:(id)object
{
    [self loadTextureFromURLAsync:url
                   resolutionType:ICResolutionTypeUnknown
                       withTarget:target
                       withObject:object];
}

// Called on HVC thread to perform notification of async texture delegate
- (void)notifyAsyncTextureDidLoad:(NSDictionary *)textureInfo
{
    // Ensure the associated host view controller's OpenGL context is set
    [_hostViewController.openGLContext makeCurrentContext];
    
    // Ensure the associated host view controller is current
    [_hostViewController makeCurrentHostViewController];
    
    id<ICAsyncTextureCacheDelegate> target = [textureInfo objectForKey:@"target"];
    id object = [textureInfo objectForKey:@"object"];
    ICTexture2D *texture = [textureInfo objectForKey:@"asyncTexture"];
    
#if IC_ENABLE_DEBUG_TEXTURE_CACHE
    ICLog(@"Notifying textureDidLoad:object: for texture %@", [texture description]);
#endif
    
    if ([target respondsToSelector:@selector(textureDidLoad:object:)])
        [target textureDidLoad:texture object:object];
}

- (void)notifyAsyncTextureLoadingDidFail:(NSDictionary *)textureInfo
{
    // Ensure the associated host view controller's OpenGL context is set
    [_hostViewController.openGLContext makeCurrentContext];

    // Ensure the associated host view controller is current
    [_hostViewController makeCurrentHostViewController];

    id<ICAsyncTextureCacheDelegate> target = [textureInfo objectForKey:@"target"];
    id object = [textureInfo objectForKey:@"object"];
    NSError *error = [textureInfo objectForKey:@"error"];
    
#if IC_ENABLE_DEBUG_TEXTURE_CACHE
    ICLog(@"Notifying textureLoadingDidFail:object: for error %@", [error description]);
#endif
    
    if ([target respondsToSelector:@selector(textureLoadingDidFailWithError:object:)])
        [target textureLoadingDidFailWithError:error object:object];
}

- (void)loadTextureFromURLAsync:(NSURL *)url
                 resolutionType:(ICResolutionType)resolutionType
                     withTarget:(id<ICAsyncTextureCacheDelegate>)target
                     withObject:(id)object
{
    NSAssert(url != nil, @"URL cannot be nil");
    NSAssert(target != nil, @"Target cannot be nil");
    
#if IC_ENABLE_DEBUG_TEXTURE_CACHE
    ICLog(@"Loading texture async: %@", [url absoluteString]);
#endif
    
    __block ICTexture2D *texture;
    
    // Check whether the texture file has been cached already
    dispatch_sync(_dictQueue, ^{
        texture = [_textures objectForKey:[url absoluteString]];
    });
    
    if (texture) {
#if IC_ENABLE_DEBUG_TEXTURE_CACHE
        ICLog(@"Texture already cached for key %@", [url absoluteString]);
#endif
        // Texture has already been cached
        NSDictionary *textureInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                     target, @"target",
                                     texture, @"asyncTexture",
                                     object, @"object",
                                     nil];
        [self performSelector:@selector(notifyAsyncTextureDidLoad:)
                     onThread:_hostViewController.thread
                   withObject:textureInfo
                waitUntilDone:YES];
        return;
    }
    
    // Queue asynchronous loading of texture
    dispatch_async(_loadingQueue, ^{
#if IC_ENABLE_DEBUG_TEXTURE_CACHE
        ICLog(@"Perform async load for texture %@", [url absoluteString]);
#endif
        ICTexture2D *asyncTexture;
        
		[_auxGLContext makeCurrentContext];
        
        NSError *error = nil;
		asyncTexture = [self loadTextureFromURL:url resolutionType:resolutionType error:&error];
        
		glFlush();
        
        if (asyncTexture) {
#if IC_ENABLE_DEBUG_TEXTURE_CACHE
            ICLog(@"Issuing async notifyAsyncTextureDidLoad: for texture %@", [url absoluteString]);
#endif
            NSDictionary *textureInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                         target, @"target",
                                         asyncTexture, @"asyncTexture",
                                         object, @"object",
                                         nil];
            NSThread *hvcThread = _hostViewController.thread;
            NSAssert(hvcThread != nil, @"HVC thread must be running for this to work");
            [self performSelector:@selector(notifyAsyncTextureDidLoad:)
                         onThread:hvcThread
                       withObject:textureInfo
                    waitUntilDone:YES];
        } else {
#if IC_ENABLE_DEBUG_TEXTURE_CACHE
            ICLog(@"Texture loading failed, issuing async notifyAsyncTextureLoadingDidFail: " \
                   "for texture %@", [url absoluteString]);
#endif
            NSDictionary *textureInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                         target, @"target",
                                         error, @"error",
                                         object, @"object",
                                         nil];
            NSThread *hvcThread = _hostViewController.thread;
            NSAssert(hvcThread != nil, @"HVC thread must be running for this to work");
            [self performSelector:@selector(notifyAsyncTextureLoadingDidFail:)
                         onThread:hvcThread
                       withObject:textureInfo
                    waitUntilDone:YES];
        }
        
		[ICPlatformOpenGLContext clearCurrentContext];
    });
}

- (ICTexture2D *)loadTextureFromFile:(NSString *)path
{
    return [self loadTextureFromFile:path resolutionType:ICResolutionTypeUnknown];
}

- (ICTexture2D *)loadTextureFromFile:(NSString *)path
                      resolutionType:(ICResolutionType)resolutionType
{
    return [self loadTextureFromFile:path resolutionType:resolutionType error:nil];
}

- (ICTexture2D *)loadTextureFromFile:(NSString *)path
                      resolutionType:(ICResolutionType)resolutionType
                               error:(NSError **)error
{
    return [self loadTextureFromURL:[NSURL fileURLWithPath:path]
                     resolutionType:resolutionType
                              error:error];
}

- (void)loadTextureFromFileAsync:(NSString *)path
                      withTarget:(id)target
                      withObject:(id)object
{
    return [self loadTextureFromFileAsync:path
                           resolutionType:ICResolutionTypeUnknown
                               withTarget:target
                               withObject:object];
}

- (void)loadTextureFromFileAsync:(NSString *)path
                  resolutionType:(ICResolutionType)resolutionType
                      withTarget:(id<ICAsyncTextureCacheDelegate>)target
                      withObject:(id)object
{
    [self loadTextureFromURLAsync:[NSURL fileURLWithPath:path]
                   resolutionType:resolutionType
                       withTarget:target
                       withObject:object];
}

- (ICTexture2D *)textureForKey:(NSString *)key
{
	__block ICTexture2D *texture = nil;
    
	dispatch_sync(_dictQueue, ^{
		texture = [_textures objectForKey:key];
	});
    
	return texture;
}

- (void)removeTextureForKey:(NSString *)key
{
    dispatch_sync(_dictQueue, ^{
        [_textures removeObjectForKey:key];
    });
}

- (void)removeAllTextures
{
    dispatch_sync(_dictQueue, ^{
        [_textures release];        
    });    
}

- (void)removeUnusedTextures
{
	dispatch_sync(_dictQueue, ^{
		NSArray *keys = [_textures allKeys];
		for (id key in keys) {
			id value = [_textures objectForKey:key];
			if ([value retainCount] == 1) {
				ICLog(@"icedcoffee: ICTextureCache: removing unused texture: %@", key);
				[_textures removeObjectForKey:key];
			}
		}
	});
}

- (NSString *)keyFromURL:(NSURL *)url
{
    return [url absoluteString];
}

- (NSString *)keyFromPath:(NSString *)path
{
    return [self keyFromURL:[NSURL fileURLWithPath:path]];
}

@end
