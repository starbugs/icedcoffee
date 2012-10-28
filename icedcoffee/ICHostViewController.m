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

#import "ICHostViewController.h"
#import "icDefaults.h"
#import "ICScene.h"
#import "ICRenderTexture.h"
#import "ICTextureCache.h"
#import "ICScheduler.h"
#import "ICCamera.h"
#import "ICRenderContext.h"
#import "ICContextManager.h"
#import "ICTargetActionDispatcher.h"
#import "icDefaults.h"
#import "icConfig.h"
#import "ICConfiguration.h"
#import "sys/time.h"

// Global content scale factor (applies to all ICHostViewController instances)
float g_icContentScaleFactor = IC_DEFAULT_CONTENT_SCALE_FACTOR;

// Globally current host view controller (weak references via NSValue with pointers)
NSMutableDictionary *g_currentHVCForThread = nil; // lazy allocation
NSLock *g_hvcDictLock = nil; // lazy allocation


@interface ICHostViewController (Private)
- (void)setScene:(ICScene *)scene;
- (void)setIsRunning:(BOOL)isRunning;
- (void)setViewSize:(CGSize)viewSize;
@end


// FIXME: render contexts must be shared if host view's OpenGL context is shared
@implementation ICHostViewController

@synthesize scene = _scene;
@synthesize isRunning = _isRunning;
@synthesize thread = _thread;
@synthesize renderContext = _renderContext;
@synthesize currentFirstResponder = _currentFirstResponder;
@synthesize scheduler = _scheduler;
@synthesize targetActionDispatcher = _targetActionDispatcher;
@synthesize frameUpdateMode = _frameUpdateMode;
@synthesize frameCount = _frameCount;
@synthesize didAlreadyCallViewDidLoad = _didAlreadyCallViewDidLoad;

+ (id)platformSpecificHostViewController
{
    return [[[IC_HOSTVIEWCONTROLLER alloc] init] autorelease];
}

+ (id)hostViewController
{
    return [[[[self class] alloc] init] autorelease];
}

- (id)init
{
    if ((self = [super init])) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _scheduler = [[ICScheduler alloc] init];
    _targetActionDispatcher = [[ICTargetActionDispatcher alloc] init];
    _lastUpdate.tv_sec = 0;
    _lastUpdate.tv_usec = 0;
    _frameUpdateMode = ICFrameUpdateModeSynchronized;
    _needsDisplay = YES;
    _didDrawFirstFrame = NO;
    
    // Make current host view controller regardless of which initializer was called
    [self makeCurrentHostViewController];
}

- (void)dealloc
{
#ifdef __IC_PLATFORM_MAC
    [[ICContextManager defaultContextManager]
     unregisterRenderContextForOpenGLContext:[[self view] openGLContext]];
#elif defined(__IC_PLATFORM_IOS)
    [[ICContextManager defaultContextManager]
     unregisterRenderContextForOpenGLContext:[((ICGLView *)[self view]) context]];
#endif
    
    self.scene = nil;
    [_currentFirstResponder release];
    [_scheduler release];
    [_renderContext release];
    [_targetActionDispatcher release];
    [_continuousFrameUpdateExpiryDate release];

    // Make sure no bad access can occur with the current host view controller
    ICHostViewController *currentHVC = [[self class] currentHostViewController];
    if (currentHVC == self) {
        NSValue *threadAddress = [NSValue valueWithPointer:[NSThread currentThread]];
        [g_hvcDictLock lock];
        [g_currentHVCForThread removeObjectForKey:threadAddress];
        [g_hvcDictLock unlock];
    }
    
    [super dealloc];
}

+ (id)currentHostViewController
{
    ICHostViewController *currentHostViewController;
    NSValue *threadAddress = [NSValue valueWithPointer:[NSThread currentThread]];
    
    if (!g_hvcDictLock)
        g_hvcDictLock = [[NSLock alloc] init];
    
    [g_hvcDictLock lock];
    currentHostViewController = [[g_currentHVCForThread objectForKey:threadAddress] pointerValue];
    [g_hvcDictLock unlock];
    
    return currentHostViewController;
}

- (id)makeCurrentHostViewController
{
    NSValue *threadAddress = [NSValue valueWithPointer:[NSThread currentThread]];
    
    if (!g_hvcDictLock)
        g_hvcDictLock = [[NSLock alloc] init];
    
    [g_hvcDictLock lock];
    if (!g_currentHVCForThread)
        g_currentHVCForThread = [[NSMutableDictionary alloc] initWithCapacity:1];
    [g_currentHVCForThread setObject:[NSValue valueWithPointer:self] forKey:threadAddress];
    [g_hvcDictLock unlock];
    
    return self;
}

- (void)calculateDeltaTime
{
    @synchronized (self) {
        struct timeval now;
        if (gettimeofday(&now, NULL) != 0) {
            ICLog(@"IcedCoffee: error occurred in gettimeofday");
            _deltaTime = 0;
            return;
        }
        
        if (_lastUpdate.tv_sec == 0 && _lastUpdate.tv_usec == 0) {
            _deltaTime = 0;
        } else {
            _deltaTime = (now.tv_sec - _lastUpdate.tv_sec) + (now.tv_usec - _lastUpdate.tv_usec) / 1000000.0f;
            _deltaTime = MAX(0, _deltaTime);
        }
        
        _lastUpdate = now;
        _frameCount++;
        
#if IC_DEBUG_OUTPUT_FPS_ON_CONSOLE
        // FIXME: this needs to be refactored so that it works generically and for multiple HVCs
        static int numFrames = 0;
        static float dtsum = 0.0f;
        dtsum += _deltaTime;
        numFrames++;
        if (dtsum >= 1.0f) {
            ICLog(@"FPS: %f", (float)numFrames / dtsum);
            dtsum -= 1.0f;
            numFrames = 0;
        }
#endif
    }
}

- (void)continuouslyUpdateFramesUntilDate:(NSDate *)date
{
    if (!_continuousFrameUpdateExpiryDate ||
        ((_continuousFrameUpdateExpiryDate) &&
         [_continuousFrameUpdateExpiryDate compare:date] != NSOrderedDescending))
    {
        [_continuousFrameUpdateExpiryDate release];
        _continuousFrameUpdateExpiryDate = [date retain];
    }
}

- (void)setNeedsDisplay
{
    _needsDisplay = YES;
}

- (void)willDrawFirstFrame
{
    // Implement in super class
}

- (void)drawScene
{
    // Override in subclass, call base implementation before drawing
    
    // Make the receiver the current host view controller before drawing the scene
    [self makeCurrentHostViewController];
    
    if (!_didDrawFirstFrame) {
        _didDrawFirstFrame = YES;
        [self willDrawFirstFrame];
    }
}

// Deprecated as of v0.6.6
- (void)setupScene
{
    [self setUpScene];
}

- (void)setUpScene
{
    // Override in subclass, set up an ICScene object, then call [self runWithScene:scene]
    // to start animation with the prepared scene
}

- (void)runWithScene:(ICScene *)scene
{
    self.scene = scene;
    scene.hostViewController = self;
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
    // Adjust the root scene to the new size of the host view
    [self.scene setSize:kmVec3Make(newViewSize.width, newViewSize.height, 0)];
}

- (void)setView:(ICGLView *)view
{
#ifdef __IC_PLATFORM_IOS
    // Issue #3: iOS ICGLView -setHostViewController: calls this method for old style view
    // instantiation and wiring. Ignore calls to setView: if the view instance being set
    // is identical to that in the view property.
    if (![self isViewLoaded] || self.view != view) {
        // iOS UIViewController implements setView:, so we simply use that
        [super setView:view];
        _didAlreadyCallViewDidLoad = NO;
    }
#endif
    // Mac SDK doesn't know view controllers, so ICHostViewControllerMac implements this
    // in its own subclass
}

#if defined(__IC_PLATFORM_MAC)
- (ICGLView *)view
{
    // Must be overriden in Mac host view controller to load and return the associated view
    return nil;
}
#endif

// Issue #3: iOS Interface Builder integration
// As Apple decided to put instantiation code into the view property getter, we cannot use that
// for testing whether a view was already associated with the view controller internally...
- (BOOL)isViewLoaded
{
#ifdef __IC_PLATFORM_IOS
    return [super isViewLoaded];
#endif
    
    // Overridden by ICHostViewControllerMac
    return NO;
}

// Issue #3: iOS Interface Builder integration
// UIViewController will call loadView when a nil view property is requested -- this mechanism
// is resembled in ICHostViewControllerMac also
- (void)loadView
{
    // Override this method in your custom view controller to programatically instantiate
    // an ICGLView object. Overriding this method is not necessary if you're using a nib.
    // You must call the [super loadView] in your override.
    
#ifdef __IC_PLATFORM_IOS
    // Let UIViewController load the view from its associated nib file, if applicable
    [super loadView];
#elif defined(__IC_PLATFORM_MAC)
    if ([self isViewLoaded]) {
        [self viewDidLoad];
    }
#endif
}

// Issue #3: iOS Interface Builder integration
// This method is called either by UIViewController -loadView or by ICHostViewController -loadView
// when a view has been instanciated.
- (void)viewDidLoad
{
    // Issue #3: make sure we don't run into stack overflows with old style view instantiation
    if (_didAlreadyCallViewDidLoad) {
        return;
    } else {
        _didAlreadyCallViewDidLoad = YES;        
    }
    
    NSAssert(self.view != nil, @"view property must not be nil at this point");
    
    // OpenGL context became available: if the view's OpenGL context doesn't have a corresponding
    // render context yet, create and register a new render context for it, so it's possible
    // for other components to retrieve it via the OpenGL context globally
    ICContextManager *contextManager = [ICContextManager defaultContextManager];
    _renderContext = [contextManager renderContextForOpenGLContext:[self openGLContext]];
    if (!_renderContext) {
        _renderContext = [[ICRenderContext alloc] init];
        [contextManager registerRenderContext:_renderContext
                             forOpenGLContext:[self openGLContext]];
    }
    
    // If not already existing, create a texture cache bound to our OpenGL context
    // (required for auxiliary OpenGL contexts)
    if (!self.textureCache) {
        _renderContext.textureCache =
        [[[ICTextureCache alloc] initWithHostViewController:self] autorelease];
    }
    
    // Allow subclasses to set up their custom scene
    [self setUpScene];
}

#ifdef __IC_PLATFORM_IOS
- (EAGLContext *)openGLContext
{
    return [(ICGLView *)[self view] context];
}
#elif defined(__IC_PLATFORM_MAC)
- (NSOpenGLContext *)openGLContext
{
    return [[self view] openGLContext];
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
    [self setContentScaleFactor:retinaDisplayEnabled ? IC_DEFAULT_RETINA_CONTENT_SCALE_FACTOR
                                : IC_DEFAULT_CONTENT_SCALE_FACTOR];
    
    [[self view] setContentScaleFactor:[self contentScaleFactor]];
    return YES;
#else
    // Retina display not supported on other platforms
    return NO;
#endif
}

- (ICResolutionType)bestResolutionTypeForCurrentScreen
{
    return [self contentScaleFactor] != 1.f ? ICResolutionTypeRetinaDisplay : ICResolutionTypeStandard;
}

- (ICTextureCache *)textureCache
{
    return _renderContext.textureCache;
}


#ifdef __IC_PLATFORM_MAC

- (void)setCursor:(NSCursor *)cursor
{
    [(ICGLView *)[self view] setCursor:cursor];
}

#endif // __IC_PLATFORM_MAC


- (CGSize)framebufferSize
{
    return [[self view] bounds].size;
}


// Private

- (void)setIsRunning:(BOOL)isRunning
{
    _isRunning = isRunning;
}

- (NSArray *)hitTest:(CGPoint)point
{
    return [self hitTest:point deferredReadback:NO];
}

- (NSArray *)hitTest:(CGPoint)point deferredReadback:(BOOL)deferredReadback
{
    // Override in subclass
    return nil;
}

- (NSArray *)performHitTestReadback
{
    // Override in subclass
    return nil;
}

- (BOOL)canPerformDeferredReadbacks
{
    return [[ICConfiguration sharedConfiguration] supportsPixelBufferObject];
}


@end
