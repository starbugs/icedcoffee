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

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>		// Needed for UIDevice
#endif

#import "Platforms/ICGL.h"
#import "ICConfiguration.h"
#import "icConfig.h"

@implementation ICConfiguration

@synthesize maxTextureSize = maxTextureSize_;
@synthesize supportsPVRTC = supportsPVRTC_;
@synthesize maxModelviewStackDepth = maxModelviewStackDepth_;
@synthesize supportsNPOT = supportsNPOT_;
@synthesize supportsBGRA8888 = supportsBGRA8888_;
@synthesize supportsDiscardFramebuffer = supportsDiscardFramebuffer_;
@synthesize OSVersion = OSVersion_;

//
// singleton stuff
//
static ICConfiguration *_sharedConfiguration = nil;

static char * glExtensions;

+ (ICConfiguration *)sharedConfiguration
{
	if (!_sharedConfiguration)
		_sharedConfiguration = [[self alloc] init];
    
	return _sharedConfiguration;
}

+(id)alloc
{
	NSAssert(_sharedConfiguration == nil, @"Attempted to allocate a second instance of a singleton.");
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

-(id) init
{
	if( (self=[super init])) {
		
		// Obtain iOS version
		OSVersion_ = 0;
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		NSLog(@"IcedCoffee on iOS");        
		NSString *OSVer = [[UIDevice currentDevice] systemVersion];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		NSLog(@"IcedCoffee on OS X");        
		NSString *OSVer = [self getMacVersion];
#endif
		NSArray *arr = [OSVer componentsSeparatedByString:@"."];		
		int idx=0x01000000;
		for( NSString *str in arr ) {
			int value = [str intValue];
			OSVersion_ += value * idx;
			idx = idx >> 8;
		}
		NSLog(@"IcedCoffee: OS version: %@ (0x%08x)", OSVer, OSVersion_);
		
		NSLog(@"IcedCoffee: GL_VENDOR:   %s", glGetString(GL_VENDOR));
		NSLog(@"IcedCoffee: GL_RENDERER: %s", glGetString(GL_RENDERER));
		NSLog(@"IcedCoffee: GL_VERSION:  %s", glGetString(GL_VERSION));
		
		glExtensions = (char *)glGetString(GL_EXTENSIONS);
		
		glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize_);
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		if( OSVersion_ >= kICiOSVersion_4_0 )
			glGetIntegerv(GL_MAX_SAMPLES_APPLE, &maxSamplesAllowed_);
		else
			maxSamplesAllowed_ = 0;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		glGetIntegerv(GL_MAX_SAMPLES, &maxSamplesAllowed_);
#endif
		
		supportsPVRTC_ = [self checkForGLExtension:@"GL_IMG_texture_compression_pvrtc"];
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		supportsNPOT_ = YES; // see cocos2d2
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		supportsNPOT_ = [self checkForGLExtension:@"GL_ARB_texture_non_power_of_two"];
#endif
		// It seems that somewhere between firmware iOS 3.0 and 4.2 Apple renamed
		// GL_IMG_... to GL_APPLE.... So we should check both names
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		BOOL bgra8a = [self checkForGLExtension:@"GL_IMG_texture_format_BGRA8888"];
		BOOL bgra8b = [self checkForGLExtension:@"GL_APPLE_texture_format_BGRA8888"];
		supportsBGRA8888_ = bgra8a | bgra8b;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		supportsBGRA8888_ = [self checkForGLExtension:@"GL_EXT_bgra"];
#endif
		
		supportsDiscardFramebuffer_ = [self checkForGLExtension:@"GL_EXT_discard_framebuffer"];
        
		NSLog(@"IcedCoffee: GL_MAX_TEXTURE_SIZE: %d", maxTextureSize_);
		NSLog(@"IcedCoffee: GL_MAX_SAMPLES: %d", maxSamplesAllowed_);
		NSLog(@"IcedCoffee: GL supports PVRTC: %s", (supportsPVRTC_ ? "YES" : "NO") );
		NSLog(@"IcedCoffee: GL supports BGRA8888 textures: %s", (supportsBGRA8888_ ? "YES" : "NO") );
		NSLog(@"IcedCoffee: GL supports NPOT textures: %s", (supportsNPOT_ ? "YES" : "NO") );
		NSLog(@"IcedCoffee: GL supports discard_framebuffer: %s", (supportsDiscardFramebuffer_ ? "YES" : "NO") );
		
		//CHECK_GL_ERROR();
	}
	
	return self;
}

- (BOOL) checkForGLExtension:(NSString *)searchName
{
	// For best results, extensionsNames should be stored in your renderer so that it does not
	// need to be recreated on each invocation.
    NSString *extensionsString = [NSString stringWithCString:glExtensions encoding: NSASCIIStringEncoding];
    NSArray *extensionsNames = [extensionsString componentsSeparatedByString:@" "];
    return [extensionsNames containsObject: searchName];
}
@end
