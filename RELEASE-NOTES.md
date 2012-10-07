Release Notes
=============

icedcoffee v0.6.7
-----------------

New Features:
* GPUImage integration: OpenGL ES based video filtering, camera and movie file access
* Default framework shaders are now embedded in the icedcoffee binary and do no longer
  need file-based build phase integration
* Added support for loading texture images from URLs in ICTextureCache and ICTextureLoader

Deprecations:
* ICTexture2D::size and ICTexture2D::sizeInPixels are no longer deprecated, as we've decided
  to allow for differing texture surface/content sizes in ICTexture2D.
  
Important Changes:
* The semantics of ICTexture2D::size have changed; developers should replace occurrences of
  ICTexture2D::size with ICTexture2D::displayContentSize in their application code.
* The keys used by ICTextureCache have changed: the class does now use [NSURL absoluteString]
  as the key for textures loaded from files or URLs. File paths are converted to file urls
  internally.


icedcoffee v0.6.6
-----------------

New Features:
* Support for integration with Interface Builder (on both iOS and Mac OS X)
* Support for high resolution fonts on retina displays on iOS

Deprecations:
* ICCamera::setupScreen is deprecated due to misspelling. Use ICCamera::setUpScreen from now on.
* ICHostViewController::setupScene is deprecated due to misspelling. Use
  ICHostViewController::setUpScene from now on.
* ICTexture2D::initWithData:pixelFormat:pixelsWide:pixelsHigh:size: is deprecated as it does not
  support differen resolution types and is kind of misleading. Use
  initWithData:pixelFormat:textureSize:contentSize:resolutionType: from now on.
* ICTexture2D::size is deprecated. Use ICTexture2D::contentSize or ICTexture2D::displayContentSize
  instead. The semantics of ICTexture2D::size were incorrect. See the changelog for details.
* ICTexture2D::sizeInPixels is deprecated. Use ICTexture2D::contentSizeInPixels instead.

Replaced methods (possible backwards incompatibility):
* ICScene::setupSceneForPickingWithVisitor: has been removed and was replaced with
  ICScene::setUpSceneForPickingWithVisitor:. The semantics of the method were not changed.