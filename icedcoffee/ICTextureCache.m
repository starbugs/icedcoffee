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
#import "ICContextManager.h"
#import "ICRenderContext.h"
#import "icUtils.h"

@interface ICTextureCache (Private)
- (void)notifyAsyncTextureDidLoad:(NSDictionary *)textureInfo;
@end

@implementation ICTextureCache

+ (id)currentTextureCache
{
    return [[[ICContextManager defaultContextManager]
             renderContextForCurrentOpenGLContext]
            textureCache];
}

- (id)initWithHostViewController:(ICHostViewController *)hostViewController
{
    if ((self = [super init])) {
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
    [self removeAllTextures];
    
    [_auxGLContext release];
    _auxGLContext = nil;
    
    dispatch_release(_loadingQueue);
    dispatch_release(_dictQueue);
    
    [super dealloc];
}

- (ICTexture2D *)loadTextureFromFile:(NSString *)path
{
    return [self loadTextureFromFile:path resolutionType:ICResolutionTypeUnknown];
}

- (ICTexture2D *)loadTextureFromFile:(NSString *)path
                      resolutionType:(ICResolutionType)resolutionType
{
    ICTexture2D *texture = [ICTextureLoader loadTextureFromFile:path resolutionType:resolutionType];
    NSAssert(texture, @"Texture object is nil, most likely the texture file could not be loaded");
    dispatch_sync(_dictQueue, ^{
        [_textures setObject:texture forKey:path];
    });
    return texture;
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

// Called on HVC thread to perform notification of async texture delegate
- (void)notifyAsyncTextureDidLoad:(NSDictionary *)textureInfo
{
    id<ICAsyncTextureCacheDelegate> target = [textureInfo objectForKey:@"target"];
    id object = [textureInfo objectForKey:@"object"];
    ICTexture2D *texture = [textureInfo objectForKey:@"asyncTexture"];
    [target textureDidLoad:texture object:object];
}

- (void)loadTextureFromFileAsync:(NSString *)path
                  resolutionType:(ICResolutionType)resolutionType
                      withTarget:(id<ICAsyncTextureCacheDelegate>)target
                      withObject:(id)object
{
    NSAssert(path != nil, @"Path cannot be nil");
    NSAssert(target != nil, @"Target cannot be nil");
    
    __block ICTexture2D *texture;
    
    // Check whether the texture file has been cached already
    dispatch_sync(_dictQueue, ^{
        texture = [_textures objectForKey:path]; 
    });
    
    if (texture) {
        // Texture has already been cached
        [target textureDidLoad:texture object:object];
        return;
    }
    
    // Queue asynchronous loading of texture
    dispatch_async(_loadingQueue, ^{
        ICTexture2D *asyncTexture;
        
#ifdef __IC_PLATFORM_MAC
		[_auxGLContext makeCurrentContext];
                
		asyncTexture = [self loadTextureFromFile:path resolutionType:resolutionType];
        
		glFlush();
        
        NSDictionary *textureInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                     target, @"target",
                                     asyncTexture, @"asyncTexture",
                                     object, @"object",
                                     nil];
        [self performSelector:@selector(notifyAsyncTextureDidLoad:)
                     onThread:_hostViewController.thread
                   withObject:textureInfo
                waitUntilDone:NO];
        
		[NSOpenGLContext clearCurrentContext];
        
#elif __IC_PLATFORM_IOS
		if ([EAGLContext setCurrentContext:_auxGLContext]) {
			asyncTexture = [self loadTextureFromFile:path];
            
			glFlush();
            
            NSDictionary *textureInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                         target, @"target",
                                         asyncTexture, @"asyncTexture",
                                         object, @"object",
                                         nil];
            [self performSelector:@selector(notifyAsyncTextureDidLoad:)
                         onThread:_hostViewController.thread
                       withObject:textureInfo
                    waitUntilDone:NO];
            
			[EAGLContext setCurrentContext:nil];
		} else {
			ICLog(@"IcedCoffee: ERROR: TextureCache: Could not set EAGLContext");
		}
        
#endif // __IC_PLATFORM_MAC
        
    });
}

- (ICTexture2D *)textureForKey:(NSString *)key
{
	__block ICTexture2D *texture = nil;
    
	dispatch_sync(_dictQueue, ^{
		texture = [_textures objectForKey:key];
	});
    
	return texture;
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
				ICLog(@"IcedCoffee: ICTextureCache: removing unused texture: %@", key);
				[_textures removeObjectForKey:key];
			}
		}
	});
}

@end
