Changelog
=========

v0.6.6
------

New Features:

* Integration with Interface Builder on iOS: added IBIntegrationTest to
  icedcofeee-tests-ios which provides a master-detail sample with a custom subclass
  of ICGLView. The custom subclass is required for Interface Builder to accept the
  ICGLView (see DetailViewController XIBs). Detailed changed for this feature can be
  reviewed at https://github.com/starbugs/icedcoffee/issues/3.
* Integration with Interface Builder on Mac: added IBIntegrationTest to
  icedcoffee-tests-mac which provides a sample Cocoa application with a custom subclass
  of ICHostViewControllerMac and a xib file containing the applications window,
  host view controller and ICGLView. The new feature involves the following changes:
  * The ICGLView::hostViewController property is now marked with IBOutlet, so as to
    be utilizable as an outlet for connecting ICGLView instances to ICHostViewController
    instances.
  * ICGLView for Mac does now perform follow-up logic for view-host view controller
    wiring in setHostViewController: instead of
    initWithFrame:shareContext:hostViewController:.
  * The ICHostViewControllerMac::view property is now marked with IBOutlet, so as to
    be utilizable as an outlet for connecting ICHostViewController instances to ICGLView
    instances.

Changes and Improvements:

* ICCamera::setupScreen is deprecated due to misspelling. It is replaced by
  ICCamera::setUpScreen. Framework users should simply rename their setupScreen
  overrides to setUpScreen.
* ICHostViewController::setupScene is deprecated due to misspelling. It is
  replaced by ICHostViewController::setUpScene. Framework users should simply
  rename overrides to setUpScene.
* Renamed ICScene::setupSceneForPickingWithVisitor: to
  ICScene::setUpSceneForPickingWithVisitor:.
* Refactored and improved ICTexture2D (see RELEASE_NOTES.md):
  * initWithData:pixelFormat:pixelsWide:pixelsHigh:size: is marked deprecated
    as of this version of icedcoffee. You should use
    initWithData:pixelFormat:textureSize:contentSize:resolutionType: as a
    replacement from now on. The framework itself was refactored to use
    the new initializer.
  * Added the initWithData:pixelFormat:textureSize:contentSize:resolutionType:
    initializer.
  * Added support for high resolution font rendering. Fonts are now drawn with
    double resolution on retina displays (iOS only).
  * Changed initWithCGImage: for Mac to to initWithCGImage:resolutionType, re-added
    initWithCGImage:, which does now default to ICResolutionTypeUnknown.
  * Renamed the sizeInPixels property to contentSizeInPixels
  * sizeInPixels was re-added as a depcreated method for backwards compatibility.
    It returns the value of contentSizeInPixels.
  * Renamed the size method to contentSize (size was misleading) and changed
    its semantics (!), which were wrong previously. The contentSize method does
    now return the actual content size of the texture in points. Previously, it
    returned the pixel size of the texture, which yielded the correct results on
    retina displays when working with SD resolution textures, but still isn't
    semantically correct.
  * The size method was re-added and marked deprecated for backwards compatibility.
    It calls displayContentSize internally (see below).
  * Added the displayContentSize method, which does now return the correct scaled
    content size in points of a texture, taking into account the current content
    scale factor and resolution type of the texture. That is, for a 128x128
    low resolution texture on both SD and retina displays, it will return (128,128),
    and for a 256x256 high resolution texture, it will also return (128,128).
    This method should be used to retrieve the correct display size in points of
    a texture regardless of which content scale factor is currently set, i.e.
    regardless on whether you are on an SD or a retina display.
  * Added the resolutionType property plus _resolutionType ivar.
  * Made all ivars @protected.
  * Renamed size_ to _contentSizeInPixels (_size was misleading).
  * Renamed all other ivars to _<ivarName> instead of <ivarName>_ to match the
    general icedcoffee naming conventions.
* Added ICTextureLoader::loadTextureFromFile:resolutionType:.
* Added ICTextureCache::loadTextureFromFile:resolutionType and
  ICTextureCache::loadTextureFromFileAsync:resolutionType:withTarget:withObject:.
* Renamed kICiOS... version enum values to ICIOS...
* Renamed kICMac... version enum values to ICMacOSX...
* Refactored the ICConfiguration class
* Added and refined the header documentation
* Created a new API reference site at http://icedcoffee-framework.org
    
Fixes:

* Fixed Issue #3: Interface Builder integration on iOS
  (see https://github.com/starbugs/icedcoffee/issues/3)
* Fixed ICGLView::initWithCoder:, depth buffer format now defaults to
  GL_DEPTH24_STENCIL8_OES when using Interface Builder views.
* Fixed DepthBufferTest for iOS: depth buffer format must be GL_DEPTH24_STENCIL8_OES
  instead of GL_DEPTH_COMPONENT24_OES.
* Partially fixed Issue #7: Performance problem with control events based on touchesMoved on iOS.
  The fix is incomplete and will be continued in the next version.
* Fixed a couple of warnings that occurred as of Xcode 4.4.


v0.6.5
------

* Completely rewrote ICNodeVisitorPicking to optimize performance. The class does
  now perform preliminary ray-based hit tests on each node and only runs further
  color-based picking tests if that ray-based test either succeeds or is
  unsupported by a given node. Furthermore, ICNodeVisitorPicking now uses a 256x256
  render texture to successively draw each node to one distinct pixel and perform
  only one readback at the end of the picking test run. What is more, on Mac OS X
  machines that support pixel buffer objects, the visitor now supports asynchronous
  readbacks using PBOs.
* Added the icRay3 struct which from now on represents 3D-rays in IcedCoffee.
* Added ICNode::localRayHitTest:, which by default returns ICHitTestUnsupported.
  The method is to be overridden in subclasses.
* Implemented ICPlanarNode::localRayHitTest:. The method performs a hit test by
  calculating the intersection of the given ray with the receiver's plane and then
  testing whether that intersection lies within the receiver's bounds.
* ICMouseEventDispatcher and ICHostViewControllerMac do now perform optimized
  hit testing for continuous hit tests required for computing enter/exit events.
* Added ICScene::hitTest:deferredReadback: and
  ICHostViewController::hitTest:deferredReadback:. On Mac OS X and if supported
  by OpenGL hardware, deferredReadback may be set to YES in order to perform
  asynchronous readbacks using pixel buffer objects.
* Added ICScene::performHitTestReadback and
  ICHostViewController::performHitTestReadback. These methods are used to
  perform a previously issued asynchronous readback on the picking visitor's
  render texture on systems supporting PBOs.
* Added ICHostViewController::setupScene which is from now on called by
  ICHostViewController::setView: and may be overridden by subclasses implementing
  custom host view controllers.
* Added the ICTestHostViewController class which provides a standard test bed for
  IcedCoffee test applications.
* Redesigned The PickingTest (Mac) project to use the new test bed infrastructure.
* Added background property of type ICSprite to ICView. Additionally a
  drawsBackground property was added. By default no background is drawn.
* Added ICLabel::autoresizesToTextSize property. If set to YES (default), the label
  automatically resizes to its text's size when the text is set or font properties
  are changed.
* Changed the ICHostViewController::makeCurrentHostViewController to set the current
  host view controller for the current thread using a global dictionary with weak
  references to ICHostViewController objects. Changed
  ICHostViewController::currentHostViewController to return the current host view
  controller for the current thread respectively.
* All event handler methods of ICHostViewControllerMac and ICHostViewControllerIOS
  do now make their corresponding receivers the current host view controller on
  the thread that handles the event before dispatching.
* Added the ICHostViewController::renderContext property in order to make render
  contexts accessible from the outside.
* Added the ICRenderContext::initWithShareContext: initializer, which initializes
  an ICRenderContext object with the caches defined in the given share context.
* Fixed a bug with auto resizing masks that were set to left margin flexible,
  but not right margin flexible, or to top margin flexible, but not bottom margin
  flexible.
* Fixed a bug in ICView which did not resize its clipping mask when ICView::setSize:
  was called.
* Renamed ICFrameBufferProvider to ICFramebufferProvider.
* Renamed ICFrameBuffer to ICFramebuffer.
* Renamed all frameBuffer and FrameBuffer occurrences to framebuffer and Framebuffer.


v0.6.4
------

* Implemented touch control event dispatch in ICTouchEventDispatcher.
* Fixed a bug with pixel alignment for font rendering in ICGLView on iOS.
  Labels are now displayed correctly on iOS.
* ICButton does now use font "Lucida Grande" on Mac OS X and "Helvetica"
  on iOS by default.
* Implemented multi touch sprite test.
* Removed ICNodeVisitor::visitorType property and corresponding enumerated type.
  Nodes should use reflection from now on to check for the visitor's type. E.g.,
  if ([visitor isKindOfClass:[ICNodeVisitorPicking class]]) ...
* Macro name refactoring to improve consistency according to the following rules:
  Framework macros defining constants start with "IC_" and follow with
  underscore-separated multi-word identifier parts. The same applies to framework
  macros that unfold to multiple code statements. Function macros start with
  "IC" and continue with camel case multi-word identifiers starting with a capital
  letter.
    * Renamed IC_CONTENT_SCALE_FACTOR() to ICContentScaleFactor()
    * Added ICPointsToPixels() and ICPixelsToPoints() macros and refactored
      all code that previoulsy used IC_CONTENT_SCALE_FACTOR() to transform
      point values to pixel values or vice versa.
    * Renamed IC_DEBUG_BREAK() to ICDebugBreak().
    * Renamed ICLOG_DEALLOC() to ICLogDealloc().
    * Renamed ICLOG() to ICLog().
    * Renamed ICDEFAULT_* to IC_DEFAULT_*.
    * Renamed CHECK_GL_ERROR_DEBUG() to IC_CHECK_GL_ERROR_DEBUG().
* Typedef enum refactoring to improve consistency according to the following
  rules: Framework enums start with "IC" and follow with camel case multi-word
  identifiers starting with a capital letter. Enumerated constants do no longer
  used artifacts of hungarian notation (no kICSomeEnumConstant). Instead they
  start with the name of the type followed by a camel case multi-word identifier
  starting with a capital letter.
    * Renamed kICFrameUpdateMode_* to ICFrameUpdateMode*.
    * Renamed kICPixelFormat_* to ICPixelFormat*.
    * Renamed kICDepthBufferFormat_ to ICDepthBufferFormat*.
    * Renamed kICStencilBufferFormat_ to ICStencilBufferFormat*.
    * Renamed icResolutionType to ICResolutionType.
    * Renamed kICResolution* to ICResolutionType*.
    * Renamed ICShaderValueType_* to ICShaderValueType*.
    * Renamed kICVertexAttrib_* to ICVertexAttrib*.
* Added ICHostViewController::currentHostViewController and
  ICHostViewController::makeCurrentHostViewController. The former retrieves the
  globally current host view controller while the latter makes the receiver the
  current host view controller.
* ICHostViewController::init now makes the receiver the current host view controller.
* ICHostViewController::drawScene now makes the receiver the current host view
  controller and is to be called by subclasses in their corresponding drawScene
  implementations before drawing to the OpenGL context.
* Removed the scheduler from ICRenderContext and bound it to ICHostViewController
  instead. ICScheduler::currentScheduler now returns the scheduler bound to the
  current host view controller. This change was required to make schedulers unique
  for each host view controller. Previously they were bound to OpenGL contexts,
  however, it is possible to share one OpenGL context between multiple host views.
  In this case the scheduler could have fired updates multiple times for the
  same objects.
* Added ICHostViewController::openGLContext which retrieves the host view's
  OpenGL context (EAGLContext on iOS, NSOpenGLContext on Mac OS X).
* Added ICNode::descendantsFilteredUsingBlock:, ICNode::ancestorsFilteredUsingBlock:.
* Rewrote methods for descendants and ancestors retrieval of ICNode. These methods
  do now use ICNode::descendantsFilteredUsingBlock: and
  ICNode::ancestorsFilteredUsingBlock:.
* Rewrote ICNode::root to optimize performance.
* Fixed a bug which registered wrong render contexts under certain circumstances.
  Render contexts are now created and registered in ICHostViewController::setView:,
  only if no render context for the given OpenGL context is existing yet. Otherwise,
  the existing render context is reused.
* Added ICFrameBufferProvider::frameBufferSize.
* ICHostViewController now conforms to the ICFrameBufferProvider protocol by
  implementing ICFrameBufferProvider::frameBufferSize.
* ICRenderTexture now conforms to the ICFrameBufferProvider protocol by
  implementing ICFrameBufferProvider::frameBufferSize.
* Changed ICScene::frameBufferSize to look for ancestors conforming to the
  ICFrameBufferProvider protocol instead of looking for ICRenderTexture objects.
  Also, the method now uses ICFrameBufferProvider::frameBufferSize to retrieve the
  size of the corresponding frame buffer for a scene.
* Extended the ICRenderContext class to hold references to custom objects using
  the ICRenderContext::setCustomObject:forKey:, ICRenderContext::customObjectForKey:,
  ICRenderContext::removeCustomObject:forKey:, and
  ICRenderContext::removeAllCustomObjects: methods.
* Added support for repeated mouse down control events to ICMouseEventDispatcher.
* Fixed a bug in ICMouseEventDispatcher: mouse down control events were sent as
  for the left mouse button always. The framework now sends mouse down control
  events for the correct mouse buttons.
* Fixed some issues with the icedcoffee-ios Xcode project regarding linked frameworks.
* Removed version number from LICENSE_icedcoffee.txt.
  
  
v0.6.3
------

* ICView does now draw its clipping mask shape when visited by the picking visitor.
  Thus, ICView objects from now on receive mouseEntered and mouseExited events.
* Made ICButton customizable by adding the ability to set custom backgrounds per state.
* Fully implemented ICTouchEventDispatcher for the IcedCoffee iOS version. The new
  touch dispatcher now processes individual touches, repackages them and then dispatches
  touchesBegan:withTouchEvent:, touchesMoved:withTouchEvent:,
  touchesCancelled:withTouchEvent: and touchesEnded:withTouchEvent: to the objects in
  the scene.
* Touch events are represented by a new class, ICTouchEvent, which allows to
  access all touches (ICTouchEvent::allTouches) and touches for individual nodes
  (ICTouchEvent::touchesForNode:). ICResponder and ICTouchResponder have been changed
  to support the new touch event class. Nodes must now override
  touchesBegan:withTouchEvent:, touchesMoved:withTouchEvent:, and so on in order to
  handle touch events properly.
* Within IcedCoffee, touches are now represented by ICTouch objects instead of UITouch
  objects. The ICTouch class aggregates an UITouch object and provides convenience
  methods for getting the location of a touch in a given node. Consequently, the
  previously discussed touchesBegan:withTouchEvent: etc. methods now receive a set
  of ICTouch objects instead of a set with UITouch objects.
* Changed ICMouseEventDispatcher to dispatch mouse up events to the node that received
  the corresponding mouse down event. The dispatcher previously sent mouse up events
  to the node over the mouse cursor.
* Added the ICOSXEvent class which aggregates an NSEvent object and binds it to
  a host view (NSView).
* Added the ICMouseEvent class (subclass of ICOSXEvent) which from now on represents
  mouse events in the IcedCoffee framework. ICMouseEvent aggregates NSEvent via
  ICOSXEvent and adds convenience methods for retrieving locations in a given
  node's local coordinate space (see ICMouseEvent::locationInNode:).
* Refactored ICMouseEventDispatcher to dispatch ICMouseEvent objects instead of
  NSEvent objects.
* Refactored ICMouseEventDispatcher to dispatch ICMouseEvent during control event
  dispatch.
* Refactored ICControl and ICTargetActionDispatcher to work with ICOSXEvent objects
  instead of NSEvent objects.
* Refactored all event handlers to accept ICMouseEvent instead of NSEvent objects.
* Removed the ICEventDelegate class and also removed event delegates from
  ICHostViewController and ICMouseEventDispatcher. Event delegate concept was unclear
  and deprecated since v0.6.
* Added the ICFrameBufferProvider protocol. All classes conforming to the this protocol
  must provide a frame buffer. Currently, ICRenderTexture is the only class that conforms
  to this protocol.
* Added the ICProjectionTransforms protocol. All classes conforming to this protocol
  must be capable of transforming between frame buffer coordinates and local node
  coordinates using camera-based (un)projection or similar mechanisms.
* Fixed a bug in ICPlanarNode::hostViewToNodeLocation:. The method was implemented
  incorrectly before. It has been renamed to ICPlanarNode::parentFrameBufferToNodeLocation:
  as it is only capable of converting between a parent frame buffer space to a node's
  local space when there are no other frame buffers (and scenes) in between.
  ICPlanarNode::hostViewToNodeLocation: does now what it is supposed to do: convert
  from the host view's coordinate system to a given node's coordinate system by reverse
  traversing all ancestor frame buffer providers that conform to the ICProjectionTransforms
  protocol of that node and calling
  ICNode<ICProjectionTransforms>::parentFrameBufferToNodeLocation: on each of them
  subsequently, providing the location from the corresponding previous transform.
* Changed the method signature of ICPlanarNode::hostViewToNodeLocation: conforming to the
  new method signature defined in ICProjectionTransforms. The method does now return a
  kmVec3 instead of a CGPoint to generalize for future 2D to 3D transforms.
* ICPlanarNode::hostViewToNodeLocation: now expects a host view location whose coordinate
  space has a Y axis pointing downwards. The same applies to ICHostViewController:hitTest:.
* Added switchable debug logging to ICNodeVisitorPicking, ICScene::hitTest:, and
  ICTouchEventDispatcher. Switching debug logging on and off can be done in icConfig.h.
* Fixed a bug in ICNodeVisitor which caused the framework to draw visible children of
  invisible nodes. Setting a node's isVisible flag to NO now means that the node is not
  processed by (built-in) visitors, so the entire descendant branch whose ancestor is
  set to invisible will not be drawn. As a side effect, it is no longer necessary to
  check for visibility in ICNode::drawWithVisitor: overrides.
* Fixed a bug in ICNodeVisitorPicking which yielded incorrect picking results when
  having invisible nodes in a scene.
* Fixed a bug with control events dispatch that could lead to wrong mouseUpInside/
  mouseUpOutside control events under certain circumstances.
* Extended and reworked parts of the header documentation.


v0.6.2
------

*New core contributor*: Marcus Tillmanns has joined the IcedCoffe project. Marcus works
at Avid Technology, Inc. and has a strong background in Nokia's Qt and other user
interface frameworks. His first contribution is a shader based button along with some
code modifications and important architectural decisions regarding IcedCoffee's shader
subsystem.

* Added ICRectangle, a view that renders a parameterized rounded rectangle using a
  fragment shader.
* Changed ICButton to work with the new rounded rectangle shader.
* Added the ICShaderUniform and ICShaderValue classes. ICShaderValue defines a uniform
  value with a specific type (ICShaderValueType) and allows for convenient initialization
  and retrieval of that value. ICShaderUniform defines a shader uniform with a specific
  type and allows you to set a value on that uniform.  Together these classes form the
  basis for a more flexible shader subsystem in IcedCoffee.
* Reworked ICShaderProgram to support arbitrary shader uniforms by incorporating the
  ICShaderUniform and ICShaderValue classes. ICShaderProgram now automatically fetches
  available uniforms from a given shader program at the end of the linker phase.
  You may use the uniforms property to retrieve them. Uniform values may be set using
  the setShaderValue:forUniform: method. Likewise, they may be retrieved using the
  shaderValueForUniform: method.


v0.6.1
------

* Added support for multiple Cocoa views via render contexts that are bound to the OpenGL
  context of each view. Added a test project (MultipleCocoaViewsTest) that draws two
  scenes in two separate Cocoa windows.
* Added support for concurrent drawing or drawing on the main thread on the Mac
  (ICHostViewControllerMac).
* Added support for on demand frame update mode on iOS (ICHostViewControllerIOS).
* Added ICShaderCache to ICRenderContext.
* Added ICShaderCache::currentShaderCache, which retrieves a shader cache valid for the
  current OpenGL context (via ICRenderContext).
* Removed ICShaderCache::defaultShaderCache, use ICShaderCache::currentShaderCache instead.


v0.6
----

* Renamed ICCameraPointsToPixelsPerspective to ICUICamera
* Changed IcedCoffee's UI coordinate system to invert the OpenGL Y axis. This means that y=0
  is now the frame buffer's bottom for all scenes using projection scaling in ICUICamera.
  Adapted ICSprite, ICScale9Sprite and ICPlanarNode sources to conform to this change.
* Refactored ICScene so that it is no longer necessary to initialize it with a host
  view controller. Host view controllers are now assigned by the framework when a scene
  is set on the respective host view controller. The following methods were removed
  to simplify ICScene initialization and subclassing: ICScene::initWithHostViewController:,
  ICScene::initWithCamera:.
* Added the ability to nest ICScene objects directly (without render textures) by changing
  the way ICScene and node visitors work together. ICScene now overrides drawWithVisitor:
  and childrenDidDrawWithVisitor: to perform internal setup logic and allow for nested
  drawing and picking. See PickingTest (Mac) project.
* Added the ability to nest ICScene objects in ICView objects (both for unbacked and buffer
  backed views).
* Added the ICContextManager and ICRenderContext classes which work in collaboration with
  ICHostViewController, ICTextureCache and ICScheduler to provide texture caches and
  schedulers for a given OpenGL context. This way you may access the texture cache and
  scheduler object without a reference to the host view controller.
* Added convenience methods to retrieve the texture cache or scheduler for the current
  OpenGL context (ICTextureCache::currentTextureCache, ICScheduler::currentScheduler).
* Introduced a layouting mechanism similar to that implemented in Cocoa, where you send
  a setNeedsLayout message to an ICView receiver in order to mark it for layouting.
  The actual layouting is implemented in subclasses of ICView by overriding the
  layoutChildren instance method. Views marked with needsLayout are layouted the next time
  the scene is drawn.
* Added autoresizing masks as known from Cocoa to ICView. Superviews whose autoresizesSubViews
  property is set to YES (default), do now automatically autoresize their subviews if they
  have a non-nil autoresizing mask set.
* Added the ICUIScene class, which adds a content view (ICView) to ICScene and syncs that
  content view's size with the size of the scene.
* ICLabel now inherits from ICView instead of ICSprite. It renders its contents using
  an internal sprite instead of setting a texture on itself. This change was required to
  make labels part of a layoutable view hierarchy.
* Changed ICButton to conform to the new layouting mechanism
* Changed ICButton to use the texture cache
* Renamed ICNode::descendantsWithType: to ICNode::descendantsOfType:.
* Renamed ICNode::ancestorsWithType: to ICNode::ancestorsOfType:.
* Renamed ICNode::firstAncestorWithType: to ICNode::firstAncestorOfType:.
* Refactored ICScene::setParent and ICScene::setSize to adjusts its camera's viewport
  in setSize.
* Refactored ICHostViewController::reshape to simply call setSize on the root scene.
* Refactored ICRenderTexture::setSize: so it resizes the size of the sub scene according
  to its own size.
* Added ICNode::childrenOfType: and ICNode::childrenNotOfType:.
* Added ICNode::debugLogBranch to output the scene graph hierarchy starting with the
  receiver on the console (only in debug mode).
* Added misc. functions and macros for better OpenGL error reporting and logging
* Fixed a bug in ICView::setBacking: that led to wrong reordering of children and leaking
  of render textures when switching the backing to nil.
* Fixed a bug in ICNode::descendantsOfType: that yielded a wrong list of descendants for
  the specified class type.
* Fixed a bug in ICNodeVisitorPicking which did not have a render texture backing with a stencil
  buffer, so unbacked ICScrollViews (and other stencil-based nodes) would not be processed
  correctly when picking.
* Fixed a bug in ICMouseEventDispatcher which sent scroll events to too many responders.
  From now on, scroll events are sent to the deepest node the mouse cursor is over currently
  only and may be propagated through the responder chain from there.
* Fixed floor correction of transformed result location in ICPlanarNode::hostViewToNodeLocation:.
* Fixed a bug in ICGLView for Mac and ICHostViewControllerMac that led to OpenGL errors
  by drawing to an incomplete frame buffer. ICHostViewControllerMac::drawScene does now
  check for frame buffer completeness before drawing.
* Fixed a bug in ICGLView for iOS and ICHostViewControllerIOS that led to OpenGL errors
  by drawing to an incomplete frame buffer. ICHostViewControllerIOS::drawScene does now
  check for frame buffer completeness before drawing.
* Fixed a bug in ICHostViewControllerIOS which called reshape too early (in viewWillAppear).
  This caused the root scene to resize without a complete OpenGL frame buffer in place.
* Pixel unpack and pack alignments are now set in the ICGLView::init... methods. ICTexture2D
  can now be used with texture formats that require alignments of 1, e.g. alpha textures for
  font rendering. The string drawing code in ICTexture2D was adapted accordingly.
* Fixed a memory leak in ICSprite (did not release its texture)
* Fixed a couple of minor bugs all accross the framework
* Grouped source files in icedcoffee-mac and icedcoffee-ios Xcode projects
* Updated PickingTest for Mac: you can now switch render texture backings and animation off and on.
* Added and rewrote parts of the documentation.


v0.5
----

* Redesigned the ICView class to allow for buffer backed and unbacked (direct) drawing,
  including stencil based clipping for unbacked views.
* Added the ICScrollView class which extends ICView so as to enable scrolling the view's contents.
* Fixed a bug in ICRenderTexture that would not allow for the stencil buffer attachments.
  ICRenderTexture does now support packed depth-stencil buffers of format GL_DEPTH24_STENCIL8.
* Fixed a bug in ICScene::frameBufferSize that would return the wrong size of render texture
  parents on retina displays.
* Fixed a bug in ICPlanarNode::hostViewToNodeLocation: that would cause wrong transformation
  results on retina displays.
* Added and reworked parts of the documentation.


v0.4
----

* Introduced full depth buffer support in ICRenderTexture, refactored initializers for
  convenient setup of render textures with or without depth buffers
* Refactored the ICView class to better work in collaboration with its ICRenderTexture super class
* Added the ICControl class which introduces the target-action design pattern to IcedCoffee
  (alongside with the ICTargetActionDispatcher class)
* Added the ICButton class as a first user interface control based on ICControl
* Added the ICScale9Sprite class which aids you in scaling background images and sprite textures
* Refactored view-to-world coordinate transformation by introducing the ICPlanarNode subclass
* Added the ICScheduler class for scheduling update notifications from the framework to arbitrary
  updatable objects
* Added support for texture masks based on multitexturing and a masking shader in ICSprite
* Added support for stencil buffers
* Fixed a bug that caused the framework to freeze on view resize on Mac OS X
* Added and reworked parts of the inline documentation


v0.3
----

* First pre-release