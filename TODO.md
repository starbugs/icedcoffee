IcedCoffee Todos
================

* Fix setAliasTexParameters (produces side effects)
* Implement high resolution textures
* Texture loading convenience (+ @2x retina display support)
* Image and shader default bundles for framework resources
* Implement layouting
* Implement resizable views
* GL state management
* Implement full-blown touch event handling including control events
* Check location space conversion for retina display cases
* Full blown scheduler tests (including priorities)
* Prepare/check for retina display support on Mac
* Check/remove event delegates (useful or not, worth the overhead?)
* Implement texture masking in ICSprite

Known Bugs
==========

* When window is closed on Mac, renderer continues, gets crazy (0x506 OpenGL error)
