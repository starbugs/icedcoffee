/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <Availability.h>

#import "icMacros.h"

#ifdef __IC_PLATFORM_IOS
#import <UIKit/UIKit.h>		// Needed for UIDevice
#endif

#import "Platforms/ICGL.h"
#import "ICConfiguration.h"
#import "icConfig.h"

@implementation ICConfiguration

@synthesize maxTextureSize = _maxTextureSize;
@synthesize supportsPVRTC = _supportsPVRTC;
@synthesize supportsNPOT = _supportsNPOT;
@synthesize supportsBGRA8888 = _supportsBGRA8888;
@synthesize supportsDiscardFramebuffer = _supportsDiscardFramebuffer;
@synthesize supportsPixelBufferObject = _supportsPixelBufferObject;
@synthesize OSVersion = _OSVersion;

//
// singleton stuff
//
static ICConfiguration *g_sharedConfiguration = nil;

static char * glExtensions;

+ (ICConfiguration *)sharedConfiguration
{
	if (!g_sharedConfiguration)
		g_sharedConfiguration = [[self alloc] init];
    
	return g_sharedConfiguration;
}

+ (id)alloc
{
	NSAssert(g_sharedConfiguration == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
- (NSString*)getMacVersion
{
    SInt32 versionMajor, versionMinor, versionBugFix;
	Gestalt(gestaltSystemVersionMajor, &versionMajor);
	Gestalt(gestaltSystemVersionMinor, &versionMinor);
	Gestalt(gestaltSystemVersionBugFix, &versionBugFix);
	
	return [NSString stringWithFormat:@"%d.%d.%d", versionMajor, versionMinor, versionBugFix];
}
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED

- (id)init
{
	if( (self=[super init])) {
		
		// Obtain OS version
		_OSVersion = 0;
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		NSLog(@"icedcoffee on iOS");        
		NSString *OSVer = [[UIDevice currentDevice] systemVersion];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		NSLog(@"icedcoffee on OS X");        
		NSString *OSVer = [self getMacVersion];
#endif
		NSArray *arr = [OSVer componentsSeparatedByString:@"."];		
		int idx=0x01000000;
		for (NSString *str in arr) {
			int value = [str intValue];
			_OSVersion += value * idx;
			idx = idx >> 8;
		}
		NSLog(@"icedcoffee: OS version: %@ (0x%08x)", OSVer, _OSVersion);
		
		NSLog(@"icedcoffee: GL_VENDOR:   %s", glGetString(GL_VENDOR));
		NSLog(@"icedcoffee: GL_RENDERER: %s", glGetString(GL_RENDERER));
		NSLog(@"icedcoffee: GL_VERSION:  %s", glGetString(GL_VERSION));
		
		glExtensions = (char *)glGetString(GL_EXTENSIONS);
		
		glGetIntegerv(GL_MAX_TEXTURE_SIZE, &_maxTextureSize);
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		if (_OSVersion >= ICIOSVersion_4_0)
			glGetIntegerv(GL_MAX_SAMPLES_APPLE, &_maxSamplesAllowed);
		else
			_maxSamplesAllowed = 0;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		glGetIntegerv(GL_MAX_SAMPLES, &_maxSamplesAllowed);
#endif
		
		_supportsPVRTC = [self checkForGLExtension:@"GL_IMG_texture_compression_pvrtc"];
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		_supportsNPOT = YES; // see cocos2d2
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		_supportsNPOT = [self checkForGLExtension:@"GL_ARB_texture_non_power_of_two"];
#endif
		// It seems that somewhere between firmware iOS 3.0 and 4.2 Apple renamed
		// GL_IMG_... to GL_APPLE.... So we should check both names
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		BOOL bgra8a = [self checkForGLExtension:@"GL_IMG_texture_format_BGRA8888"];
		BOOL bgra8b = [self checkForGLExtension:@"GL_APPLE_texture_format_BGRA8888"];
		_supportsBGRA8888 = bgra8a | bgra8b;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		_supportsBGRA8888 = [self checkForGLExtension:@"GL_EXT_bgra"];
#endif
		
		_supportsDiscardFramebuffer = [self checkForGLExtension:@"GL_EXT_discard_framebuffer"];
        
        _supportsPixelBufferObject = [self checkForGLExtension:@"GL_ARB_pixel_buffer_object"];
        
		NSLog(@"icedcoffee: GL_MAX_TEXTURE_SIZE: %d", _maxTextureSize);
		NSLog(@"icedcoffee: GL_MAX_SAMPLES: %d", _maxSamplesAllowed);
		NSLog(@"icedcoffee: GL supports PVRTC: %s", (_supportsPVRTC ? "YES" : "NO") );
		NSLog(@"icedcoffee: GL supports BGRA8888 textures: %s", (_supportsBGRA8888 ? "YES" : "NO") );
		NSLog(@"icedcoffee: GL supports NPOT textures: %s", (_supportsNPOT ? "YES" : "NO") );
		NSLog(@"icedcoffee: GL supports discard_framebuffer: %s", (_supportsDiscardFramebuffer ? "YES" : "NO") );
		NSLog(@"icedcoffee: GL supports ARB_pixel_buffer_object: %s", (_supportsPixelBufferObject ? "YES" : "NO") );
		
		IC_CHECK_GL_ERROR_DEBUG();
	}
	
	return self;
}

- (BOOL)checkForGLExtension:(NSString *)extensionName
{
	// For best results, extensionsNames should be stored in your renderer so that it does not
	// need to be recreated on each invocation.
    NSString *extensionsString = [NSString stringWithCString:glExtensions encoding:NSASCIIStringEncoding];
    NSArray *extensionsNames = [extensionsString componentsSeparatedByString:@" "];
    return [extensionsNames containsObject:extensionName];
}

- (BOOL)supportsCVOpenGLESTextureCache
{
#if defined(__IC_PLATFORM_IOS) && !(TARGET_IPHONE_SIMULATOR) && (IC_ENABLE_CV_TEXTURE_CACHE)
    return (CVOpenGLESTextureCacheCreate != NULL);
#else
    // Fast texture upload not supported on Mac/iOS simulator or if disabled via icConfig.h
    return NO;
#endif
}

@end
