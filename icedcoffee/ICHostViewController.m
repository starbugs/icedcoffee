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

#import "ICHostViewController.h"
#import "icDefaults.h"
#import "ICScene.h"
#import "ICRenderTexture.h"
#import "ICTextureCache.h"
#import "ICScheduler.h"
#import "ICCamera.h"
#import "ICEventDelegate.h"
#import "icDefaults.h"
#import "sys/time.h"

// Global content scale factor (applies to all ICHostViewController instances)
float g_icContentScaleFactor = ICDEFAULT_CONTENT_SCALE_FACTOR;


@interface ICHostViewController (Private)
- (void)setScene:(ICScene *)scene;
- (void)setIsRunning:(BOOL)isRunning;
- (void)setViewSize:(CGSize)viewSize;
@end


@implementation ICHostViewController

@synthesize eventDelegates = _eventDelegates;
@synthesize scene = _scene;
@synthesize isRunning = _isRunning;
@synthesize textureCache = _textureCache;
@synthesize viewSize = _viewSize;
@synthesize thread = _thread;
@synthesize currentFirstResponder = _currentFirstResponder;
@synthesize scheduler = _scheduler;

+ (ICHostViewController *)platformSpecificHostViewController
{
    return [[[IC_HOSTVIEWCONTROLLER alloc] init] autorelease];
}

- (id)init
{
    if ((self = [super init])) {
        _eventDelegates = [[NSMutableArray alloc] init];
        _scheduler = [[ICScheduler alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.scene = nil;
    [_currentFirstResponder release];
    [_eventDelegates release];
    [_textureCache release];
    [_scheduler release];
    
    [super dealloc];
}

- (void)addEventDelegate:(id<ICEventDelegate>)eventDelegate
{
    NSAssert(eventDelegate != nil, @"Attempted to add a nil event delegate");
    [_eventDelegates addObject:eventDelegate];
}

- (void)removeEventDelegate:(id<ICEventDelegate>)eventDelegate
{
    [_eventDelegates removeObject:eventDelegate];
}

- (void)calculateDeltaTime
{
    struct timeval now;
    if (gettimeofday(&now, NULL) != 0) {
        ICLOG(@"IcedCoffee: error occurred in gettimeofday");
        _deltaTime = 0;
        return;
    }
    
    _deltaTime = (now.tv_sec - _lastUpdate.tv_sec) + (now.tv_usec - _lastUpdate.tv_usec) / 1000000.0f;
    _deltaTime = MAX(0, _deltaTime);
    
    _lastUpdate = now;
}

- (void)drawScene
{
    // Override in subclass    
}

- (void)runWithScene:(ICScene *)scene
{
    self.scene = scene;
    [self startAnimation];
}

- (void)startAnimation
{
    // Override in subclass
}

- (void)stopAnimation
{
    // Override in subclass
}

- (void)reshape:(CGSize)newViewSize
{
    self.scene.camera.dirty = YES;
    [self setViewSize:newViewSize];
}

- (void)setView:(ICGLView *)view
{
#ifdef __IC_PLATFORM_IOS
    [super setView:view];
#endif
    // Mac host view controller implements this in its own subclass
    
    // Create a texture cache bound to this view (required for auxiliary OpenGL context)
    if (!_textureCache) {
        _textureCache = [[ICTextureCache alloc] initWithHostViewController:self];
    }
}

#if defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
- (ICGLView *)view
{
    // Must be overriden in Mac host view controller
    return nil;
}
#endif

- (void)setCurrentFirstResponder:(ICResponder *)currentFirstResponder
{
    [_currentFirstResponder resignFirstResponder];
    [_currentFirstResponder release];
    _currentFirstResponder = [currentFirstResponder retain];
    [_currentFirstResponder becomeFirstResponder];
}

- (float)contentScaleFactor
{
    return g_icContentScaleFactor;
}

- (void)setContentScaleFactor:(float)contentScaleFactor
{
    g_icContentScaleFactor = contentScaleFactor;
}

- (BOOL)retinaDisplaySupportEnabled
{
    return _retinaDisplayEnabled;
}

- (BOOL)enableRetinaDisplaySupport:(BOOL)retinaDisplayEnabled
{
#ifdef __IC_PLATFORM_IOS
    if (![[self view] respondsToSelector:@selector(setContentScaleFactor:)]) {
        return NO; // setContentScaleFactor not supported by software 
    }
    
	if ([[UIScreen mainScreen] scale] == 1.0)
		return NO; // SD device

    _retinaDisplayEnabled = retinaDisplayEnabled;
    [self setContentScaleFactor:retinaDisplayEnabled ? ICDEFAULT_RETINA_CONTENT_SCALE_FACTOR
                               : ICDEFAULT_CONTENT_SCALE_FACTOR];
    
    [[self view] setContentScaleFactor:[self contentScaleFactor]];
    return YES;
#else
    // Retina display not supported on other platforms
    return NO;
#endif
}


// Private

- (void)setIsRunning:(BOOL)isRunning
{
    _isRunning = isRunning;
}

- (void)setViewSize:(CGSize)viewSize
{
    _viewSize = viewSize;
}

- (NSArray *)hitTest:(CGPoint)point
{
    // Override in subclass
    return nil;
}


@end
