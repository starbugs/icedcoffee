icedcoffee Todos
================

Immediate:
* Support GPU switching during runtime
* Rename AutoResizingMask to AutoresizingMask in ICView
* Fix missing composition overrides in ICView and ICScrollView
* Fix issues with depth testing an ICView
* Remove large image assets from workspace, host those on icedcoffee-framework.org?

Near term:
* icedcoffee project templates for Xcode
* Solution for gesture recognizers in icedcoffee
* Improvements to font rendering based on CoreGraphics
* Check/improve KVC/KVO compliance of central framework classes
* Simple property animations and transitions (interfaces similar to CA)
* Full featured ICScrollView implementation (bouncing, gestures, etc.)
* Enable ICUICamera to do orthogonal projection if perspective is not desired
* Texture loading convenience (+ @2x retina display support)
* Full blown scheduler tests (including priorities)

Medium term:
* icedcoffee view controllers
* Simple widgets:
  * Slider
  * Checkbox (switch button)
  * Progress bar
  * Tab bars
* Bullet Physics integration
* Model loader integration (Open Asset Import?)
* What to do with partial GL state management/caching inherited from cocos2d (?)


Known Bugs
==========

* When window is closed on Mac, renderer continues, gets crazy (0x506 OpenGL error)
  => This should be solved, check?
