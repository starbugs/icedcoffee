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

#import "ICView.h"
#import "kazmath/kazmath.h"

/**
 @brief A scrollable view for displaying content exceeding the view's bounds
 
 <h3>Overview</h3>
 
 The ICScrollView class defines a view for displaying content that is larger than the
 scroll view's own size. It allows the user to scroll its contents using the mouse wheel,
 scrollers or touch gestures (the latter two are not implemented yet). Scrolling is
 implemented by offsetting the view's sub scene position by a given delta defined by
 user input.
 
 <h3>Setup</h3>
 
 You initialize an ICScrollView instance using the ICScrollView::initWithSize: method.
 By default, ICScrollView is not backed by a render texture, which means that clipping
 is performed by means of the stencil buffer. Consequently, the framebuffer rendering
 the scroll view must be endued with a stencil buffer attachment.
 
 After the scroll view has been initialized, you may define its contents by adding
 children nodes to it. ICScrollView will automatically calculate the size of the
 content and store it in its ICScrollView::contentSize property. The calculated
 content size is then used for scrolling internally.
 
 <h3>Subclassing</h3>
 
 You may want to subclass ICScrollView to implement custom scroll views that extend
 the scroll view's basic functionality or draw their contents programmatically.
 
 Keep in mind the following points when doing so:
 <ul>
    <li>All rules for subclassing ICView also apply to ICScrollView subclasses.</li>
    <li>The scroll view may operate in unbacked or backed mode. Scroll views
    operating in unbacked mode offset their children by overriding ICNode::drawWithVisitor:
    and ICNode::childrenDidDrawWithVisitor:. They do so by pushing and popping an
    additional transformation matrix that translates the view's children so as to
    offset its content visually for the user. In contrast, scroll views operating
    in backed mode simply offset their contents by changing the position of the
    backing's sub scene. Both modes are transparent to the view's children, but
    need to be taken care of when subclassing ICScrollView.</li>
 </ul>
 
 */
@interface ICScrollView : ICView {
@protected
    kmVec3 _contentSize;
    kmVec3 _contentOffset;
    kmVec3 _contentMin;
    kmVec3 _contentMax;
    ICView *_contentView;
    BOOL _automaticallyCalculatesContentSize;
}

#pragma mark - Working with the Scroll View's Content Size and Offset
/** @name Working with the Scroll View's Content Size and Offset */

/**
 @brief The size of the scroll view's contents
 */
@property (nonatomic, assign, setter=setContentSize:) kmVec3 contentSize;

/**
 @brief The current offset of the scroll view's contents
 */
@property (nonatomic, assign, setter=setContentOffset:) kmVec3 contentOffset;

@property (nonatomic, assign) BOOL automaticallyCalculatesContentSize;

- (void)calculateContentSize;

@end
