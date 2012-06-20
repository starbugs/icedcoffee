Changelog
=========

*v0.6.1*

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

*v0.6*

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

*v0.5*

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

*v0.4*

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

*v0.3*

* First pre-release