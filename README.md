Icedcoffee v0.7.2
=================

Icedcoffee is a lightweight framework for building stunning, accelerated 2D and 3D user interfaces
based on OpenGL ES 2. It is written in Objective-C and runs on iOS and Mac OS X. Among its most
notable features are: perspective UI rendering, sophisticated shader-based picking and hit tests,
full event handling for all drawable objects, buffering of views via OpenGL render textures, and
advanced font rendering and typesetting using a crossover of CoreText and GL-backed glyph caches.

Icedcoffee essentially gives you full control of what's on screen by unlocking the power
of graphics hardware without forcing you to deal with the details of OpenGL – it's a perfect match
for every developer reaching the limits of UIKit and CoreAnimation.

Icedcoffee is designed to be clean, minimalistic, consistent and reusable for different purposes.
It may be used to build interfaces for games, full application frontends or to extend existing
applications with new OpenGL-based components such as infinitely scrollable views, animated
overlays, and so on. Icedcoffee emphasizes easy integration and doesn't hijack your application.
Promised!

Icedcoffee is open source and free for both non-commercial and commercial use (MIT license).

	Note: This is an early release, which means that some things aren't quite finished yet.


Getting Started
---------------

1. Pull the code from github: the easiest way to stay updated is to use *Git Read-only*
   by typing `git clone git://github.com/starbugs/icedcoffee.git` on the terminal.

2. Open `icedcoffee.xcworkspace` using Xcode.

3. Pick and run some of the test apps and have fun!



Documentation
-------------

Find a work-in-progress version of the [Icedcoffee API reference](http://icedcoffee-framework.org/reference/)
on [icedcoffee-framework.org](http://icedcoffee-framework.org). If you have questions or want to
receive updates and release notes via email, please join the [Icedcoffee Google Group](https://groups.google.com/d/forum/icedcoffee).


Main Features
-------------

  * View hierarchy with stencil-based clipping, optionally backed by render textures
  * Font rendering via OpenGL-backed glyph caches, typesetting and framesetting via CoreText
  * Easy and convenient property animations
  * Full event handling support for all nodes, views and controls (multi-touch, mouse, keyboard),
    responder chain design similar to that found in Cocoa/CocoaTouch
  * Target-action control event handling for user interface controls
  * Shader-based picking/selection (arbitrary picking shapes)
  * Render to texture, picking through (potentially nested) texture FBOs
  * Render to texture and picking with depth and stencil buffer support
  * Perspective UI rendering via UI cameras (XY world plane matches the screen plane)
  * Scale9 sprites for scaling background images and sprite textures
  * Asynchronous texture loading
  * Rendering via display link or timers (dedicated thread or main thread)
  * Retina display support
  * GPUImage integration for efficiently displaying and filtering camera inputs and movie files
  * View/view controller architecture for easy integration with Cocoa/CocoaTouch
  * Drawing to multiple AppKit/UIKit host views using multiple OpenGL contexts
  * Minimalistic scene graph: scene node infrastructure with arbitrary 3D transforms,
    easily extensible via node visitation
  * Little dependencies: very easy to integrate into existing OpenGL and non-OpenGL
    applications or games


Copyright and License
---------------------

Copyright 2013–2016 Tobias Lensing, Marcus Tillmanns

Licensed under an MIT license (see LICENSE_icedcoffee.txt for details).


Third-party Sources
-------------------

  * The Kazmath project has been included to provide math structures and
	  routines for IcedCoffee's linear algebra (see LICENSE_Kazmath.txt).
  * The GPUImage project has been included as an extension to provide live fideo filtering,
      access to the camera and movie files (see LICENSE_GPUImage.txt).
  * The RectangleBinPack project has been included as a solution for computing texture atlases
      in icedcoffee (RectangleBinPack is public domain, see the respective header files
      for more information).
  * Portions of cocos2d's source code have been reused/refactored (see respective
	  header files and LICENSE_cocos2d.txt for details).
  * Creative Commons licensed images have been reused for demo purposes (see
	  the respective license files in resource folders).
