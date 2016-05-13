//  
//  Copyright (C) 2016 Tobias Lensing, Marcus Tillmanns
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
//  Note: Parts of ICHostViewController were inspired by CCDirector's design from
//  the cocos2d-iphone.org project.

#import <Foundation/Foundation.h>

#import "ICResponder.h"
#import "ICFramebufferProvider.h"
#import "icMacros.h"
#import "icTypes.h"

@class ICScene;
@class ICGLView;
@class ICTextureCache;
@class ICRenderTexture;
@class ICResponder;
@class ICScheduler;
@class ICTargetActionDispatcher;


#if defined(__IC_PLATFORM_MAC)
#define IC_VIEWCONTROLLER NSObject
#elif defined(__IC_PLATFORM_IOS)
#define IC_VIEWCONTROLLER UIViewController
#endif


#ifdef __IC_PLATFORM_IOS
/**
 @brief View controller base class integrating icedcoffee into Cocoa/CocoaTouch applications
 
 ICHostViewController is an abstract base class that defines an interface for platform and
 application specific view controllers managing an icedcoffee host view. Host view controllers
 provide the foundation for drawing, animation and event handling within an icedcoffee view
 (see ICGLView) in your iOS or Mac OS X application.
 
 On iOS, the standard way of integrating a host view controller into your application is
 subclassing ICHostViewControllerIOS, which is the platform specific implementation for
 integration with UIKit.
 */
#elif defined(__IC_PLATFORM_MAC)
/**
 @brief View controller base class integrating icedcoffee into Cocoa/CocoaTouch applications
 
 ICHostViewController is an abstract base class that defines an interface for platform and
 application specific view controllers managing an icedcoffee host view. Host view controllers
 provide the foundation for drawing, animation and event handling within an icedcoffee view
 (see ICGLView) in your iOS or Mac OS X application.
 
 On Mac OS X, the standard way of integrating a host view controller into your application is
 subclassing ICHostViewControllerMac, which is the platform specific implementation for
 integration with AppKit.
 */
#endif
@interface ICHostViewController : IC_VIEWCONTROLLER <EVENT_PROTOCOLS>
{
@protected
    ICScene *_scene;

    ICOpenGLContext *_openGLContext;
    ICScheduler *_scheduler;
    ICTargetActionDispatcher *_targetActionDispatcher;
    
    ICResponder *_currentFirstResponder;
    
    BOOL _retinaDisplayEnabled;
    float _desiredContentScaleFactor;

    BOOL _isRunning;
    NSThread *_thread;
    BOOL _didDrawFirstFrame;

    icTime _deltaTime;
    icTime _elapsedTime;
    struct timeval _lastUpdate;
    uint64_t _frameCount;
    
    icTime _fpsDelta;
    uint _fpsNumFrames;
    float _fps;
    
    ICFrameUpdateMode _frameUpdateMode;
    NSDate *_continuousFrameUpdateExpiryDate;
    BOOL _needsDisplay;
    
    // Issue #3
    BOOL _didAlreadyCallViewDidLoad;
}


#pragma mark - Creating a Host View Controller
/** @name Creating a Host View Controller */

/**
 @brief Returns a new autoreleased default ICHostViewController subclass suitable for use with
 the target platform
 
 Use this method to instanciate an autoreleased host view controller for the target platform
 if you do not use a custom view controller by subclassing either ICHostViewControllerIOS or
 ICHostViewControllerMac.
 */
+ (id)platformSpecificHostViewController;

/**
 @brief Returns a new autoreleased host view controller
 
 Use this method to instanciate an autoreleased host view controller if you created a custom view
 controller by subclassing either ICHostViewControllerIOS or ICHostViewControllerMac.
 */
+ (id)hostViewController;

/**
 @brief Initializes the receiver and makes it the current host view controller
 
 @sa makeCurrentHostViewController
 */
- (id)init;

/**
 @brief Performs common initialization internally
 
 This method should be called by all initializers to perform common initialization. Subclasses
 should override this method in order to implement custom common initialization.
 */
- (void)commonInit;


#pragma mark - Managing the Current Host View Controller
/** @name Managing the Current Host View Controller */

/**
 @brief Returns the current host view controller for the current thread
 
 The current host view controller is determined by the framework automatically or it is explicitly
 set by the user utilizing ICHostViewController::makeCurrentHostViewController. One can safely
 assume the current host view controller to be the last host view controller initialized on the
 current thread or the host view controller that is currently drawing or handling events on the
 current thread, even if ICHostViewController::makeCurrentHostViewController is never called
 manually by the framework user.
 
 Please note that the mechanism employed here for managing a current host view controller imposes
 a global state on your application process, which is mostly transparent to you since any framework
 or user code may rely on this method. Others may not know that code or they may not even be able to
 read it if they do not have access to its source files. In most situations there are better (more
 secure) ways to gain access to the appropriate host view controller. For example, each ICNode
 object on a scene graph is capable of returning a pointer to its corresponding host view controller
 without directly relying on this method. Not using this method makes your code more secure and
 easier to debug.
 
 Note that this method is thread-safe.
 
 @sa makeCurrentHostViewController
 */
+ (id)currentHostViewController;

/**
 @brief Makes the receiver the current host view controller for the current thread

 This method uses a global variable to store a weak reference to the current host view controller.
 The receiver should be made the current host view controller before other framework code is about
 to be executed in its context. Usually you do not have to call this method on your own, since
 ICHostViewController itself takes care of making the receiver the current host view controller in
 appropriate situations. For example, this method is called automatically at the end of
 ICHostViewController initialization (before ICHostViewController::setupScene is called), before a
 scene is drawn in ICHostViewController::drawScene, and before an event is dispatched. This way,
 framework or user code written to set up, draw or interact in an icedcoffee scene is usually
 guaranteed to retrieve the correct current host view controller via
 ICHostViewController::currentHostViewController.
 
 Note that this method is thread-safe.
 
 @sa currentHostViewController
 */
- (id)makeCurrentHostViewController;


#pragma mark - Managing the First Responder
/** @name Managing the First Responder */

/**
 @brief The receiver's current first responder
 
 Setting this property to an ICResponder object will first check whether that object accepts
 first responder status by calling ICResponder::acceptsFirstResponder. If so, the setter checks
 whether the current first responder is willing to resign first responder status by sending it
 an ICResponder::resignFirstResponder message. If the current first responder resigns first
 responder, the setter finally sets the given responder as new current first responder of the
 receiver.
 */
@property (nonatomic, retain, setter=setCurrentFirstResponder:) ICResponder *currentFirstResponder;

/**
 @brief Attempts to make the given responder new current first responder of the receiver
 
 This method sets the ICHostViewController::currentFirstResponder property to the given responder
 on the receiver.
 
 @return If setting the given responder as the new first responder succeeds, the method
 returns ``YES``. Otherwise ``NO`` is returned.
 */
- (BOOL)makeFirstResponder:(ICResponder *)newFirstResponder;


#pragma mark - Obtaining Caches and Contexts
/** @name Obtaining Caches and Contexts */

/**
 @brief The receiver's OpenGL context
 */
@property (nonatomic, readonly) ICOpenGLContext *openGLContext;

/**
 @brief The ICTextureCache object associated with the receiver
 */
@property (nonatomic, readonly, getter=textureCache) ICTextureCache *textureCache;


#pragma mark - Managing the Run Loop, Drawing and Animation
/** @name Managing the Run Loop, Drawing and Animation */

/**
 @brief Called by the framework to calculate the delta time between two consecutive frames
 */
- (void)calculateDeltaTime;

/**
 @brief The number of seconds passed since the first frame was rendered by the receiver
 */
@property (nonatomic, readonly) icTime elapsedTime;

/**
 @brief The number of frames drawn by the receiver so far
 */
@property (nonatomic, readonly) uint64_t frameCount;

/**
 @brief The number of frames per second currently presented by the receiver
 
 If the receiver's ICHostViewController::frameUpdateMode is set to ICFrameUpdateModeSynchronized,
 this property is updated approximately once a second. For other frame update modes, this property
 might not report accurate results and should not be used.
 
 If you want to refresh a user interface control displaying the current framerate, you should use
 key-value observation to observe updates on this property.
 
 Note that the receiver's framerate will never exceed the display's refresh rate, which typically
 is 60 FPS on all modern displays.
 */
@property (nonatomic, readonly) float fps;

/**
 @brief The frame update mode used to present the receiver's scene
 
 An ICFrameUpdateMode enumerated value defining when the host view controller should redraw
 the scene's contents. Setting this property to ICFrameUpdateModeSynchronized lets the
 host view controller draw the scene's contents continuously, synchronized with the display's
 refresh rate. Setting it to ICFrameUpdateModeOnDemand lets the host view controller draw
 the scene's contents on demand only, when one or multiple nodes' ICNode::setNeedsDisplay
 method has been called.
 
 The default value for this property is ICFrameUpdateModeSynchronized.
 
 @remarks You should use synchronized updates for scenes that change frequently and on demand
 updates for those that change rarely. Setting the frame update mode to on demand drawing
 has effects on update messages scheduled with ICHostViewController::scheduler. Update messages
 will only be sent when a frame is acutally drawn, that is, you cannot rely on ICScheduler
 for scheduling animation updates in this case.
 */
@property (nonatomic, assign, getter=frameUpdateMode, setter=setFrameUpdateMode:) ICFrameUpdateMode frameUpdateMode;

- (void)continuouslyUpdateFramesUntilDate:(NSDate *)date;

/**
 @brief Called by the framework to signal that the receiver's view contents need to be redrawn
 */
- (void)setNeedsDisplay;

@property (nonatomic, readonly) BOOL needsDisplay;

@property (nonatomic, readonly) BOOL willPerformDisplayUpdate;

/**
 @brief The thread used to draw the receiver's scene and process HID events
 */
@property (atomic, retain) NSThread *thread;

/**
 @brief Called before the first frame is drawn by the receiver
 */
- (void)willDrawFirstFrame;

/**
 @brief The scene that is currently managed by the receiver
 */
@property (nonatomic, retain) ICScene *scene;

/**
 @brief Draws the scene in the receiver's host view
 */
- (void)drawScene;

/**
 @brief Called by the framework to set up the receiver's scene
 
 @deprecated Deprecated as of v0.6.6. Use ICHostViewController::setUpScene instead.
 */
- (void)setupScene DEPRECATED_ATTRIBUTE /*v0.6.6*/;

/**
 @brief Called by the framework to set up the receiver's scene
 
 To be overridden in subclasses. The default implementation does nothing.
 */
- (void)setUpScene;

/**
 @brief Sets the given scene as the receiver's current scene and starts animation
 */
// FIXME: runWithScene is deprecated, should assign scene, then start animation if necessary
// only. On iOS, animation is started automatically via UIViewController::viewWillAppear.
- (void)runWithScene:(ICScene *)scene;

/**
 @brief A boolean flag indicating whether the receiver is currently running
 */
@property (nonatomic, readonly) BOOL isRunning;

/**
 @brief Starts continuous drawing of the currently set scene
 */
- (void)startAnimation;

/**
 @brief Stops continuous drawing of the currently set scene
 */
- (void)stopAnimation;

/**
 @brief Updates the view's size internally and invalidates the current scene's camera
 */
- (void)reshape:(CGSize)newViewSize;


#pragma mark - Update Scheduling and Target-Action Dispatch
/** @name Update Scheduling and Target-Action Dispatch */

@property (nonatomic, readonly) ICScheduler *scheduler;

@property (nonatomic, readonly) ICTargetActionDispatcher *targetActionDispatcher;


#pragma mark - Managing the Host View
/** @name Managing the Host View */

/**
 @brief Sets the view to be controlled by the receiver
 
 If view is set to a non-nil value, prepares the receiver's render context, initializes a texture
 cache if necessary, and calls ICHostViewController::setUpScene on the receiver.
 */
- (void)setView:(ICGLView *)view;

#if defined(__IC_PLATFORM_MAC)
- (ICGLView *)view;
#endif

- (BOOL)isViewLoaded;

// Issue #3: make sure we don't run into stack overflows with old style view instantiation
@property (nonatomic, readonly) BOOL didAlreadyCallViewDidLoad;

// Issue #3: iOS Interface Builder integration
- (void)loadView;

// Issue #3: iOS Interface Builder integration
- (void)viewDidLoad;

#ifdef __IC_PLATFORM_IOS
- (EAGLContext *)nativeOpenGLContext;
#elif defined(__IC_PLATFORM_MAC)
- (NSOpenGLContext *)nativeOpenGLContext;
#endif


#pragma mark - Performing Hit Tests
/** @name Performing Hit Tests */

/**
 @brief Performs a hit test on the current scene
 
 @param point A CGPoint defining the location to use for the hit test. The location must be
 relative to the host view's frame origin, the Y axis' origin is the upper left corner of the view.
 
 @sa ICScene::hitTest:
 */
- (NSArray *)hitTest:(CGPoint)point;

- (NSArray *)hitTest:(CGPoint)point deferredReadback:(BOOL)deferredReadback;

- (NSArray *)performHitTestReadback;

- (BOOL)canPerformDeferredReadbacks;


#pragma mark - Supporting Retina Displays
/** @name Supporting Retina Displays */

/**
 @brief Enables or disables retina display support (iOS only)
 
 @param retinaDisplayEnabled Set to YES to enable retina display support or to NO to disable it.
 
 @remarks Retina display support can only be enabled when appropriate hardware and software
 are available on the device.
 
 @return Returns YES if retina display support could be enabled or NO otherwise.
 */
- (BOOL)enableRetinaDisplaySupport:(BOOL)retinaDisplayEnabled;

/**
 @brief Returns YES when retina display support is enabled, NO otherwise
 */
- (BOOL)retinaDisplaySupportEnabled;

/**
 @brief Returns the current content scale factor used to map points to pixels internally
 */
- (float)contentScaleFactor;

/**
 @brief Sets the current content scale factor
 
 @param contentScaleFactor A float value defining the new content scale factor
 */
- (void)setContentScaleFactor:(float)contentScaleFactor;

/**
 @brief Returns the best resolution type for the receiver's current screen
 */
- (ICResolutionType)bestResolutionTypeForCurrentScreen;


#ifdef __IC_PLATFORM_MAC

#pragma mark - Changing the Mouse Cursor
/** @name Changing the Mouse Cursor */

/**
 @brief Sets the mouse cursor (Mac only)
 
 Use this method to change the mouse cursor over the host view's frame. The set mouse cursor
 will only appear when the application is active and the host view's window is key.
 
 @param cursor An NSCursor object defining the cursor to be set.
 */
- (void)setCursor:(NSCursor *)cursor;

#endif // __IC_PLATFORM_MAC


#pragma mark - Frame Buffer
/** @name Frame Buffer */

/**
 @brief The size of the receiver's framebuffer, in points
 */
- (CGSize)framebufferSize;

@end

