//  
//  Copyright (C) 2016 Tobias Lensing, Marcus Tillmanns
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
#import "ICUpdatable.h"
#import "../3rd-party/kazmath/kazmath/kazmath.h"

/**
 @brief A scrollable view for displaying content exceeding a view's bounds
 
 <h3>Overview</h3>
 
 The ICScrollView class defines a view for displaying content that is larger than its own size.
 Scroll views automatically clip their children and employ an internal content view to offset
 their contents with regard to their own position. The contents' offset can be controlled using
 the ICScrollView::contentOffset property. The contents' size can be changed using the
 ICScrollView::contentSize property.
 
 By default, scroll views automatically calculate their ICScrollView::contentSize when children
 are added to the view using ICScrollView::addChild:. This behavior may be changed by setting
 the ICScrollView::automaticallyCalculatesContentSize property.
 
 @note Note that this class is currently under development and does not yet (correctly) handle
 user interface events like scroll wheel or touch gestures. What is more, it does not yet display
 scrollers or other means to let the user interact with the scroll view itself.
 */
@interface ICScrollView : ICView <ICUpdatable> {
@protected
    kmVec3 _contentSize;
    kmVec3 _contentOffset;
    kmVec3 _contentMin;
    kmVec3 _contentMax;
    ICView *_contentView;
    BOOL _automaticallyCalculatesContentSize;
    
#ifdef __IC_PLATFORM_MAC
    NSTouch *_initialTouches[2];
    NSTouch *_currentTouches[2];
    BOOL _isTracking;
    NSMutableArray *_positionBuffer;
    kmVec3 _initialOffset;
    kmVec3 _lastNormalizedPosition;
    kmVec3 _restingPosition;
    kmVec3 _scrollVelocity;
    BOOL _isMoving;
#endif
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
