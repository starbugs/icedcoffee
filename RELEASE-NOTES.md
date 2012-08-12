Release Notes
=============

icedcoffee v0.6.6
-----------------

New Features:
* Support for integration with Interface Builder on iOS
* Support for high resolution fonts on retina displays on iOS

Deprecations:
* ICCamera::setupScreen is deprecated due to misspelling. Use ICCamera::setUpScreen from now on.
* ICHostViewController::setupScene is deprecated due to misspelling. Use
  ICHostViewController::setUpScene from now on.
* ICTexture2D::initWithData:pixelFormat:pixelsWide:pixelsHigh:size: is deprecated as it does not
  support differen resolution types and is kind of misleading. Use
  initWithData:pixelFormat:textureSize:contentSize:resolutionType: from now on.
* ICTexture2D::size is deprecated. Use ICTexture2D::contentSize or ICTexture2D::displayContentSize
  instead. See the changelog for details.
* ICTexture2D::sizeInPixels is deprecated. Use ICTexture2D::contentSizeInPixels instead.

Removed methods:
* ICScene::setupSceneForPickingWithVisitor: has been removed and was replaced with
  ICScene::setUpSceneForPickingWithVisitor:. The semantics of the method were not changed.