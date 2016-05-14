icedcoffee Todos
================

Immediate:
* When in on demand update mode and redrawing via scheduler, FPS goes up beyond display
  refresh rate when window is invisible (OS X)
* Support trackpad events on OS X and implement proper scrolling in ICScrollView (wip)
* Full featured ICScrollView implementation (bouncing, gestures, etc.)
* Rename AutoResizingMask to AutoresizingMask in ICView
* Fix missing composition overrides in ICView and ICScrollView
* Fix issues with depth testing an ICView
* Remove large image assets from workspace, host those on icedcoffee-framework.org?

Near term:
* icedcoffee project templates for Xcode
* Solution for gesture recognizers in icedcoffee
* Improvements to font rendering based on CoreGraphics
* Check/improve KVC/KVO compliance of central framework classes
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

Long term (maybe):
* Bullet Physics integration
* Model loader integration (Open Asset Import?)
* What to do with partial GL state management/caching inherited from cocos2d (?)