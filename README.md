IcedCoffee v0.6.1
=================

IcedCoffee is a lightweight framework for building stunning user interfaces based on OpenGL ES 2.
It is written in Objective-C and runs on iOS and Mac OS X.

IcedCoffee is designed to be clean, minimalistic, consistent and reusable for different purposes.
Its main focus is on user interfaces in the context of games, but of course you may use it for
all kinds of rich and dynamic application frontends.

IcedCoffee is open source and free for both non-commercial and commercial use (MIT license.)

	Note: This is an early release meaning that some things aren't quite finished yet.


Getting Started
---------------

1. Download the code from github

2. Open icedcoffee.xcworkspace using Xcode 4.2+

3. Run the tests and have fun!


Documentation
-------------

Find a work-in-progress version of the [IcedCoffee API reference](http://icedcoffee-framework.org/docs)
on [icedcoffee-framework.org](http://icedcoffee-framework.org).


Main Features
-------------

  * Minimalistic scene graph: scene node infrastructure with arbitrary 3D transforms,
    easily extensible via node visitation
  * Full event handling support for nodes (touch, mouse, keyboard, motion), responder
    chain design similar to that found in Cocoa/CocoaTouch
  * Perspective GUI rendering (XY world plane matches the screen plane)
  * Shader-based picking/selection of nodes (support for arbitrary picking shapes)
  * Render to texture, picking through (potentially nested) texture FBOs
  * Render to texture and picking with depth and stencil buffer support
  * View hierarchy with stencil-based clipping, optionally backed by render textures
  * Font rendering via CoreGraphics
  * Scale9 sprites for scaling background images and sprite textures
  * Texture loading on a separate thread via GCD
  * Rendering via dedicated display link thread
  * Retina display support for all suitable devices
  * View/view controller architecture for easy integration with Cocoa/CocoaTouch
  * Minimalistic design with little dependencies: very easy to integrate into existing
    OpenGL and non-OpenGL applications or games


Copyright and License
---------------------

Copyright 2012 Tobias Lensing

Licensed under an MIT license (see LICENSE_icedcoffee.txt for details.)


Third-party Sources
-------------------

  * Portions of cocos2d's source code have been reused/refactored (see respective
	  header files and LICENSE_cocos2d.txt for details.)
  * The Kazmath project has been included to provide math structures and
	  routines for IcedCoffee's linear algebra (see LICENSE_Kazmath.txt.)
  * Creative Commons licensed images have been reused for demo purposes (see
	  the respective license files in resource folders.)
