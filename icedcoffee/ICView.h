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

#import <Foundation/Foundation.h>

#import "ICSprite.h"
#import "ICRenderTexture.h"
#import "ICContainer.h"


enum {
    /** @brief The view is not resizable */
    ICAutoResizingMaskNotSizable           = 0x00,
    /** @brief The view's left margin is flexible */
    ICAutoResizingMaskLeftMarginFlexible   = 0x01,
    /** @brief The view's width is resizable */
    ICAutoResizingMaskWidthSizable         = 0x02,
    /** @brief The view's right margin is flexible */
    ICAutoResizingMaskRightMarginFlexible  = 0x04,
    /** @brief The view's top margin is flexible */
    ICAutoResizingMaskTopMarginFlexible    = 0x08,
    /** @brief The view's height is resizable */
    ICAutoResizingMaskHeightSizable        = 0x10,
    /** @brief The view's bottom margin is flexible */
    ICAutoResizingMaskBottomMarginFlexible = 0x20
};
/**
 @brief Constants used to define the ICView::autoresizingMask property
 */
typedef NSUInteger ICAutoResizingMask;

/**
 @brief Represents an icedcoffee user interface view

 The ICView class implements the fundamental functionality of user interface views in the
 icedcoffee framework. Like all other drawable elements in icedcoffee, ICView is based on
 the ICNode class. It adds functionality that is commonly required when building user
 interface elements, such as clipping, buffering and layouting the view's contents.
 
 The following is a list of the most notable features introduced by the ICView class:
 
 - Buffering a view's contents in a rectangular area using a render texture backing
 - Clipping the view's children both in normal and in buffer backed mode
 - Providing an interface for layouting the view's children
 - Providing a system to autoresize views based on autoresizing masks
 - Allowing you to conveniently draw a 2D background based on ICSprite
  
 ### Setup ###
 
 A view must be initialized with a predefined size using the ICView::initWithSize: method.
 After initialization, you define the contents of the view by adding children to it using
 the ICView::addChild: method.
 
 By default, freshly initialized views will have no render texture backing. If your view
 requires such backing, send it an ICView::setWantsRenderTextureBacking: message specifying
 ``YES`` for the ``wantsRenderTextureBacking`` argument. The view will then automatically
 create a render texture along with a corresponding sub scene and reorganize its contents
 so as to draw its children to the backing render texture FBO. Backings generated using
 ICView::setWantsRenderTextureBacking: are simple ICRenderTexture nodes providing a color
 buffer and a stencil buffer. If you need a backing with more capabilities, you may create
 it on your own and set it on the view using the ICView::backing property.
 
 If a view uses a render texture backing, it will automatically clip its children to 
 its backing's bounds. Otherwise, the view will not clip its children unless you
 explicitly set ICView::clipsChildren to ``YES``. Unbacked views clip their
 children using stencil masks. Hence, the FBO the view is rendered to must provide a
 stencil buffer. If no stencil buffer is present, no clipping will occur.
 
 ### Subclassing ###
 
 You should subclass ICView to implement classes representing user interface views.
 The following points should be considered when subclassing the ICView class:

 - ICView's designated initializer is ICView::initWithSize:. If you need to implement
   custom initialization logic, override this method instead of ICNode::init.
 - As mentioned before, ICView allows for buffered rendering using a render texture
   backing. When ICView::backing is set, ICView automatically moves its children to the
   backing's sub scene. However, since ICView overrides all methods related to scene graph
   composition, its children still appear as its own children to the outside. Usually,
   you do not have to care about this explicitly, but there are exceptions to that rule.
   Just in case, keep in mind that ICView::addChild:, ICView::insertChild:atIndex:,
   ICView::removeChild:, ICView::removeChildAtIndex:, ICView::removeAllChildren, and
   ICView::children are overriden by ICView.
 - As ICView may operate in buffer backed mode, you need to call ICNode::setNeedsDisplay
   if a descendant node changes its appearance. Calling ICView::setNeedsDisplay on ICView
   also marks the view's contents for redrawing.
 - You may implement custom layouting by overriding the ICView::layoutChildren method.
 */
@interface ICView : ICPlanarNode <ICContainer> {
@protected
    ICRenderTexture *_backing;
    ICSprite *_clippingMask;
    BOOL _clipsChildren;
    ICSprite *_background;
    BOOL _drawsBackground;
    ICAutoResizingMask _autoresizingMask;
}

#pragma mark - Creating a View
/** @name Creating a View */

/**
 @brief Creates a new autoreleased view with the given size
 
 @sa initWithSize:
 */
+ (id)viewWithSize:(CGSize)size;

/**
 @brief Initializes a view with the given size
 
 @param size A CGSize value defining the size of the view in points
  */
- (id)initWithSize:(CGSize)size;


#pragma mark - Clipping the View's Contents
/** @name Clipping the View's Contents */

/**
 @brief Whether the view clips its children
 */
@property (nonatomic, assign, getter=clipsChildren, setter=setClipsChildren:) BOOL clipsChildren;


#pragma mark - Controlling the View's Backing
/** @name Controlling the View's Backing */

/**
 @brief Creates or removes a standard render texture backing
 
 If ``wantsRenderTextureBacking`` is set to ``YES``, this method will create a
 standard render texture backing along with a corresponding sub scene for the view
 and reorganize the view's children as described in ICView::backing.
 
 @param wantsRenderTextureBacking A ``BOOL`` value indicating whether the view should
 have a render texture backing
 
 @remarks Using this method is essentially a shortcut to creating an ICRenderTexture
 object on your own. The render texture created by this method provides a color
 buffer for drawing and a stencil buffer for clipping unbacked sub views. If you
 need more control over the backing, create your own and set it on the ICView::backing
 property.
 */
- (void)setWantsRenderTextureBacking:(BOOL)wantsRenderTextureBacking;

/**
 @brief An ICRenderTexture object representing the backing of the view
 
 When the backing property is set to a non-nil value, ICView will operate in buffer backed
 mode. When setting the backing to a non-nil value, the view's children are automatically
 moved to the backing's sub scene. Likewise, if the backing property is set to nil, its
 children are moved back from the backing's sub scene to the view itself.
 
 @note Switching a non-nil backing to another non-nil backing is not supported currently.
 You should always switch the backing to nil before you replace it with another backing.
 */
@property (nonatomic, retain, setter=setBacking:) ICRenderTexture *backing;

- (ICView *)backingContentView;


#pragma mark - Drawing a Background Sprite
/** @name Drawing a Background Sprite */

/**
 @brief The view's background sprite
 */
@property (nonatomic, retain) ICSprite *background;

/**
 @brief Whether or not the view draws its background sprite
 */
@property (nonatomic, assign, setter=setDrawsBackground:) BOOL drawsBackground;


#pragma mark - Manipulating the View Hierarchy
/** @name Manipulating the View Hierarchy */

/**
 @brief Returns the superview of the receiver
 
 This method traverses the view's ancestor nodes and returns the first ancestor that is
 a view (kind of class ICView).
 */
- (ICView *)superview;

/**
 @brief Returns all immediate subviews of the receiver
 
 This method enumerates all children of the view, checks whether a child is a view (kind of
 class ICView) and returns an array with all children that passed the test.
 */
- (NSArray *)subviews;

/**
 @brief Adds a child node to the receiver
 */
- (void)addChild:(ICNode *)child;

/**
 @brief Inserts a child at the specified index to the receiver
 */
- (void)insertChild:(ICNode *)child atIndex:(uint)index;

/**
 @brief Removes the given child from the receiver
 */
- (void)removeChild:(ICNode *)child;

/**
 @brief Removes the child at the specified index from the receiver
 */
- (void)removeChildAtIndex:(uint)index;

- (NSArray *)childrenOfType:(Class)classType;

/**
 @brief Returns the receiver's children
 */
- (NSArray *)children;


#pragma mark - Layouting Subviews
/** @name Layouting Subviews */

/**
 @brief Whether the receiver's layout needs to be udpated
 */
@property (nonatomic, assign, setter=setNeedsLayout:) BOOL needsLayout;

/**
 @brief The receiver's autoresizing mask
 */
@property (nonatomic, assign, setter=setAutoResizingMask:) ICAutoResizingMask autoresizingMask;

/**
 @brief Whether the receiver should autoresize its subviews or not
 */
@property (nonatomic, assign) BOOL autoresizesSubviews;

/**
 @brief Short hand for ICView::setNeedsLayout:YES
 */
- (void)setNeedsLayout;

/**
 @brief Layouts the receiver's children
 
 When the receiver's ICView::needsLayout property is set to ``YES``, this method is called by
 ICView::drawWithVisitor: before the view is drawn. You should implement this method in subclasses
 that need to perform custom layouting of their children.
 
 You should not call this method directly. Instead, mark the view for layouting by setting
 its ICView::needsLayout property to ``YES``.
 */
- (void)layoutChildren;

@end
