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
@class ICRenderContext;


#if defined(__IC_PLATFORM_MAC)
#define IC_VIEWCONTROLLER NSObject
#elif defined(__IC_PLATFORM_IOS)
#define IC_VIEWCONTROLLER UIViewController
#endif


/**
 @brief View controller base class for displaying and updating an IcedCoffee framebuffer
 
 ICHostViewController is a base class for view controllers for CocoaTouch and Cocoa host views.
 Host view controllers represent a means to integrate IcedCoffee into iOS and Mac OS X applications.
 They play a central role as they provide the foundation for drawing, scheduling and event handling
 for a given host view. The framework provides built-in view controller subclasses specialized for
 each supported platform: ICHostViewControllerIOS for use in CocoaTouch applications on iOS and
 ICHostViewControllerMac for use in Cocoa applications on Mac OS X. Host view controllers work in
 collaboration with the ICGLView class, which exists in two different versions for each platform
 as well.

 As a framework user, you should subclass the ICHostViewControllerIOS or ICHostViewControllerMac
 class to implement custom view controllers for managing your application's native OS views.
 See the respective class documentation for more information on subclassing and working with
 host view controllers on iOS and Mac OS X.
 */
@interface ICHostViewController : IC_VIEWCONTROLLER <EVENT_PROTOCOLS>
{
@protected
    ICScene *_scene;

    ICRenderContext *_renderContext;
    ICScheduler *_scheduler;
    ICTargetActionDispatcher *_targetActionDispatcher;
    
    ICResponder *_currentFirstResponder;
    
    BOOL _retinaDisplayEnabled;

    BOOL _isRunning;
    NSThread *_thread;

    icTime _deltaTime;
    struct timeval _lastUpdate;
    
    ICFrameUpdateMode _frameUpdateMode;
    BOOL _needsDisplay;
}


#pragma mark - Initialization
/** @name Initialization */

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


#pragma mark - Current Host View Controller
/** @name Current Host View Controller */

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

 This method uses a global dictionary to store a weak reference to the current host view controller.
 The receiver should be made the current host view controller before other framework code is about
 to be executed in its context. Usually you do not have to call this method on your own, since
 ICHostViewController itself takes care of making the receiver the current host view controller in
 appropriate situations. For example, this method is called automatically at the end of
 ICHostViewController initialization (before ICHostViewController::setupScene is called), before a
 scene is drawn in ICHostViewController::drawScene, and before an event is dispatched. This way,
 framework or user code written to set up, draw or interact in an IcedCoffee scene is usually
 guaranteed to retrieve the correct current host view controller via
 ICHostViewController::currentHostViewController.
 
 Note that this method is thread-safe.
 
 @sa currentHostViewController
 */
- (id)makeCurrentHostViewController;


#pragma mark - Event Handling
/** @name Event Handling */

/**
 @brief The receiver's current first responder
 */
@property (nonatomic, retain, setter=setCurrentFirstResponder:) ICResponder *currentFirstResponder;


#pragma mark - Caches and Management
/** @name Caches and Management */

/**
 @brief The receiver's render context
 */
@property (nonatomic, readonly) ICRenderContext *renderContext;

/**
 @brief The ICTextureCache object associated with the receiver
 */
@property (nonatomic, readonly, getter=textureCache) ICTextureCache *textureCache;


#pragma mark - Run Loop, Drawing and Animation
/** @name Run Loop, Drawing and Animation */

/**
 @brief Called by the framework to calculate the delta time between two consecutive frames
 */
- (void)calculateDeltaTime;

/**
 @brief The frame update mode used to present the receiver's scene
 
 An ICFrameUpdateMode enumerated value defining when the host view controller should draw
 the scene's contents. Setting this property to ICFrameUpdateModeSynchronized lets the
 host view controller draw the scene's contents continuously, synchronized with the display
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
@property (nonatomic, assign) ICFrameUpdateMode frameUpdateMode;

/**
 @brief Called by the framework to signal that the receiver's view contents need to be redrawn
 */
- (void)setNeedsDisplay;

/**
 @brief The thread used to draw the receiver's scene and process HID events
 */
@property (atomic, retain) NSThread *thread;

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
 
 To be overridden in subclasses. The default implementation does nothing.
 */
- (void)setupScene;

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


#pragma mark - Host View
/** @name Host View */

/**
 @brief Sets the view to be controlled by the receiver
 
 If view is set to a non-nil value, prepares the receiver's render context, initializes a texture
 cache if necessary, and calls ICHostViewController::setupScene on the receiver.
 */
- (void)setView:(ICGLView *)view;

#if defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
- (ICGLView *)view;
#endif

#ifdef __IC_PLATFORM_IOS
- (EAGLContext *)openGLContext;
#elif defined(__IC_PLATFORM_MAC)
- (NSOpenGLContext *)openGLContext;
#endif


#pragma mark - Hit Testing
/** @name Hit Test */

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


#pragma mark - Retina Display Support
/** @name Retina Display Support */

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


#ifdef __IC_PLATFORM_MAC

#pragma mark - Mouse Cursor
/** @name Mouse Cursor */

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

