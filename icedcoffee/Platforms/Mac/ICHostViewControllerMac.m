//  
// Copyright (C) 2016 Tobias Lensing
//  
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//  
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//  
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//  
/* BASED ON:
 *
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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

#import "ICHostViewControllerMac.h"
#import "ICScene.h"
#import "ICRenderTexture.h"
#import "icGL.h"
#import "ICScheduler.h"
#import "icConfig.h"


#ifdef __IC_PLATFORM_MAC

#define IC_HVC_TIME_INTERVAL_CONTINUOUS 0.01666     // display rate ensured via vsync
#define IC_HVC_TIME_INTERVAL_IDLE DBL_MAX           // prevent runloop from exiting

#define DISPATCH_MOUSE_EVENT(eventMethod) \
    - (void)eventMethod:(NSEvent *)event { \
        [self makeCurrentHostViewController]; \
        [_mouseEventDispatcher eventMethod:event]; \
    }

#define DISPATCH_KEY_EVENT(eventMethod) \
    - (void)eventMethod:(NSEvent *)event { \
        [self makeCurrentHostViewController]; \
        [_keyEventDispatcher eventMethod:event]; \
    }

@interface ICHostViewControllerMac (Private)
- (void)setIsRunning:(BOOL)isRunning;
- (void)scheduleRenderTimer;
@end


@implementation ICHostViewControllerMac

@synthesize view = _view;
@synthesize usesDisplayLink = _usesDisplayLink;
@synthesize drawsConcurrently = _drawsConcurrently;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// Lifecycle
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

- (id)init
{
    if ((self = [super init])) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [super commonInit];
    
    _mouseEventDispatcher = [[ICMouseEventDispatcher alloc] initWithHostViewController:self];
    _keyEventDispatcher = [[ICKeyEventDispatcher alloc] initWithHostViewController:self];
    _usesDisplayLink = YES;
    _drawsConcurrently = YES;
    _pendingMouseMovedEvent = nil;
    
    // Ensure ICGLView is linked when using nib files
    // See http://stackoverflow.com/questions/1725881/unknown-class-myclass-in-interface-builder-file-error-at-runtime
    [ICGLView class];
}

- (void)dealloc
{
    [self stopAnimation];
    [_mouseEventDispatcher release];
    [_keyEventDispatcher release];
    
    if (_thread && _isThreadOwner) {
        [self.thread cancel];
        self.thread = nil;
    }    

    [super dealloc];
}


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// Animation and Drawing
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

// Only used with display link drawing
- (CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime
{
    // It appears as if current thread may change on a running display link as of OS X 10.9
    NSThread *currentThread = [NSThread currentThread];
	if (self.thread != currentThread) {
        // Use display link thread as host view controller's thread
		self.thread = currentThread;
    }
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	[self drawScene];
    
	// Process timers and other events
	[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantPast]];

	[pool release];
        
    return kCVReturnSuccess;
}

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink,
                                      const CVTimeStamp* now,
                                      const CVTimeStamp* outputTime,
                                      CVOptionFlags flagsIn,
                                      CVOptionFlags* flagsOut,
                                      void* displayLinkContext)
{
    return [(ICHostViewControllerMac *)displayLinkContext getFrameForTime:outputTime];
}

- (void)setupDisplayLink
{
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    
    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(_displayLink, &MyDisplayLinkCallback, self);
    
    // Set the display link for the current renderer
    ICGLView *openGLview = (ICGLView*) self.view;
    CGLContextObj cglContext = [[openGLview openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [[openGLview pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
    
    // Activate the display link
    CVDisplayLinkStart(_displayLink);    
}

- (void)threadMainLoop
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self scheduleRenderTimer];
    [[NSRunLoop currentRunLoop] run];
    [pool release];
}

- (void)timerFired:(id)sender
{
    [self drawScene];
}

- (void)scheduleRenderTimer
{
    double suitableTimeInterval;
    
    // Set the render timer's time interval based on the receiver's frame update mode.
    if (_frameUpdateMode == ICFrameUpdateModeSynchronized) {
        // Continuous frame updates use a very low time interval. Vsync ensures that the timer will
        // fire in sync with the display framerate.
        suitableTimeInterval = IC_HVC_TIME_INTERVAL_CONTINUOUS;
    } else {
        // On demand frame updates do not require a render timer, but we need to prevent the runloop
        // from exiting, so we set up a timer with a really large time interval (DBL_MAX)
        suitableTimeInterval = IC_HVC_TIME_INTERVAL_IDLE;
    }
    
    _renderTimer = [[NSTimer timerWithTimeInterval:suitableTimeInterval
                                            target:self
                                          selector:@selector(timerFired:)
                                          userInfo:nil
                                           repeats:YES] retain];
                   
   [[NSRunLoop currentRunLoop] addTimer:_renderTimer 
                                forMode:NSDefaultRunLoopMode];
   [[NSRunLoop currentRunLoop] addTimer:_renderTimer 
                                forMode:NSEventTrackingRunLoopMode]; // Ensure timer fires during resize
}

// TODO: restart animation/schedule render timer when switching from on demand
// to continuous drawing during runtime
- (void)startAnimation
{
    if (_frameUpdateMode == ICFrameUpdateModeSynchronized && _usesDisplayLink) {
        [self setupDisplayLink];
    } else {
        if (!_thread) {
            if (_drawsConcurrently) {
                // Create a thread for concurrent drawing
                _isThreadOwner = YES;
                self.thread = [[[NSThread alloc] initWithTarget:self
                                                       selector:@selector(threadMainLoop) 
                                                         object:nil] autorelease];
                [self.thread start];
            } else {
                // Use main thread for drawing
                self.thread = [NSThread mainThread];
                [self scheduleRenderTimer];
            }
        } else {
            // Thread already existing, schedule a timer for drawing on the specified thread
            [self performSelector:@selector(scheduleRenderTimer)
                         onThread:_thread
                       withObject:nil
                    waitUntilDone:YES];
        }
    }
}

- (void)stopAnimation
{
    if (_usesDisplayLink) {
        if (_displayLink) {
            CVDisplayLinkStop(_displayLink);
            CVDisplayLinkRelease(_displayLink);
            _displayLink = NULL;
        }
    } else {
        [_renderTimer invalidate]; // must be called from hvc thread
        [_renderTimer release];
    }
}

- (void)drawScene
{
    //NSLog(@"drawScene");
    
    // FIXME
    /*if (_frameUpdateMode == ICFrameUpdateModeOnDemand &&
        !_needsDisplay &&
        (!_continuousFrameUpdateExpiryDate ||
         [_continuousFrameUpdateExpiryDate compare:[NSDate date]] == NSOrderedAscending)
        ) {
        //NSLog(@"Nothing to draw, needsDisplay: %d", _needsDisplay);
        return; // nothing to draw
    }*/
    
    // We draw on a secondary thread through the display link
    // When resizing the view, -reshape is called automatically on the main thread
    // Add a mutex around to avoid the threads accessing the context simultaneously when resizing
    
    ICGLView *openGLview = (ICGLView*)self.view;
    CGLLockContext([self.nativeOpenGLContext CGLContextObj]);
    [self.openGLContext makeCurrentContext];
    
    //NSLog(@"drawScene on thread: %s, w: %f", dispatch_queue_get_label(dispatch_get_current_queue()), openGLview.bounds.size.width);
    
    // Base only prepares drawing, does not perform any actual drawing
    [super drawScene];
    
    [self calculateDeltaTime];
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE) {
        if (_frameUpdateMode == ICFrameUpdateModeOnDemand) {
            _needsDisplay = NO;
        }
        
        //NSLog(@"Scheduler update");
        [[self scheduler] update:_deltaTime];    

        glViewport(0, 0,
                   openGLview.bounds.size.width * self.contentScaleFactor,
                   openGLview.bounds.size.height * self.contentScaleFactor);

        BOOL performUpdateMouseOverState = NO;
        BOOL performDeferredReadback = NO;
        if ([NSThread currentThread] == self.thread) {
            _mouseOverStateDeltaTime += _deltaTime;
            if (_mouseOverStateDeltaTime > 0.033f) {
                if ([self canPerformDeferredReadbacks]) {
                    // Prepare deferred readback for hit test in mouse event dispatcher's
                    // updateMouseOverState
                    [_mouseEventDispatcher prepareUpdateMouseOverState];
                    performDeferredReadback = YES;
                }
                performUpdateMouseOverState = YES;
                _mouseOverStateDeltaTime = 0;
            }
        }
        
        // Render scene
        [self.scene visit];
        
        if (performUpdateMouseOverState) {
            // Let mouse event dispatcher update state for mouseEntered/mouseExited events
            [_mouseEventDispatcher updateMouseOverState:performDeferredReadback];
        }
        
        // Handle pending mouse moved event for on demand frame updates
        if (_pendingMouseMovedEvent) {
            [_mouseEventDispatcher handleMouseMoved:_pendingMouseMovedEvent];
            [_pendingMouseMovedEvent release];
            _pendingMouseMovedEvent = nil;
        }
        
        // Flush OpenGL buffer
        [[openGLview openGLContext] flushBuffer];
    }
    
    if (!_didDrawFirstFrame) {
        _didDrawFirstFrame = YES;
    }
    
    CGLUnlockContext([self.nativeOpenGLContext CGLContextObj]);
    
    //NSLog(@"END drawScene on thread: %s", dispatch_queue_get_label(dispatch_get_current_queue()));
}

- (NSArray *)hitTest:(CGPoint)point deferredReadback:(BOOL)deferredReadback
{
    NSArray *resultNodeStack;
    
    ICGLView *openGLview = (ICGLView*)self.view;    
    CGLLockContext([self.nativeOpenGLContext CGLContextObj]);
    [self.openGLContext makeCurrentContext];

	glViewport(0, 0,
               ICPointsToPixels(openGLview.bounds.size.width),
               ICPointsToPixels(openGLview.bounds.size.height));
    
    resultNodeStack = [self.scene hitTest:point deferredReadback:deferredReadback];
    
    CGLUnlockContext([self.nativeOpenGLContext CGLContextObj]);
    
    return resultNodeStack;
}

- (NSArray *)performHitTestReadback
{
    return [self.scene performHitTestReadback];
}

- (void)setAcceptsMouseMovedEvents:(BOOL)acceptsMouseMovedEvents
{
    _mouseEventDispatcher.acceptsMouseMovedEvents = acceptsMouseMovedEvents;
}

- (BOOL)acceptsMouseMovedEvents
{
    return _mouseEventDispatcher.acceptsMouseMovedEvents;
}

- (void)setUpdatesMouseEnterExitEventsContinuously:(BOOL)updatesMouseEnterExitEventsContinuously
{
    _mouseEventDispatcher.updatesEnterExitEventsContinuously = updatesMouseEnterExitEventsContinuously;
}

- (BOOL)updatesMouseEnterExitEventsContinuously
{
    return [_mouseEventDispatcher updatesEnterExitEventsContinuously];
}

- (void)handlePendingMouseMovedEventOnNextFrameUpdate:(NSEvent *)event
{
    _pendingMouseMovedEvent = [event retain];
}

// Issue #3: Interface Builder integration
- (BOOL)isViewLoaded
{
    return _view != nil;
}

- (ICGLView *)view
{
    // Issue #3: Interface Builder integration
    // If _view is nil, call loadView
    if (!_view) {
        [self loadView];
    }
    return _view;
}

- (void)setView:(ICGLView *)view
{
    if (_view != view) {
        [_view release];
        _view = [view retain];
        
        // Issue #3: make sure we don't run into stack overflows with old style view instantiation
        _didAlreadyCallViewDidLoad = NO;
    }
    
    [super setView:view];
}


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// ICMouseResponder Protocol Implementation
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

DISPATCH_MOUSE_EVENT(mouseDown)
DISPATCH_MOUSE_EVENT(mouseDragged)
DISPATCH_MOUSE_EVENT(mouseEntered)
DISPATCH_MOUSE_EVENT(mouseExited)
DISPATCH_MOUSE_EVENT(mouseMoved)
DISPATCH_MOUSE_EVENT(mouseUp)

DISPATCH_MOUSE_EVENT(rightMouseDown)
DISPATCH_MOUSE_EVENT(rightMouseDragged)
DISPATCH_MOUSE_EVENT(rightMouseUp)

DISPATCH_MOUSE_EVENT(otherMouseDown)
DISPATCH_MOUSE_EVENT(otherMouseDragged)
DISPATCH_MOUSE_EVENT(otherMouseUp)

DISPATCH_MOUSE_EVENT(scrollWheel)
DISPATCH_MOUSE_EVENT(touchesBeganWithEvent)
DISPATCH_MOUSE_EVENT(touchesMovedWithEvent)
DISPATCH_MOUSE_EVENT(touchesEndedWithEvent)
DISPATCH_MOUSE_EVENT(touchesCancelledWithEvent)

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// ICKeyResponder Protocol Implementation
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DISPATCH_KEY_EVENT(keyDown)
DISPATCH_KEY_EVENT(keyUp)

@end

#endif // __IC_PLATFORM_MAC
