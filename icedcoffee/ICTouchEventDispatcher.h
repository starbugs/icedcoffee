//  
//  Copyright (C) 2013 Tobias Lensing, Marcus Tillmanns
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
#import "icMacros.h"
#import "Platforms/icGL.h"

#ifdef __IC_PLATFORM_IOS

@class ICHostViewController;

/**
 @brief Multitouch event dispatcher for iOS
 
 ICTouchEventDispatcher dispatches incoming touches to ICNode objects in an icedcoffee scene.
 ICNode objects receive corresponding ICResponder::touchesBegan:withTouchEvent:,
 ICResponder::touchesMoved:withTouchEvent:, ICResponder::touchesEnded:withTouchEvent:, and
 ICResponder::touchesCancelled:withTouchEvent: messages.
 
 Touch dispatch is performed conforming to the following rules:
 
    * When the dispatcher receives a touchesBegan:withEvent: message, for each individual touch,
      it computes the touches' dispatch target by performing a hit test, then internally caches
      the touch-dispatch target pair in a dictionary.
    * When a touchesMoved:withEvent: message is received, the dispatcher filters the previously
      cached touches with the incoming touches and dispatches the resulting touches to the
      dispatch targets computed in the previous phase.
    * When a touchesEnded:withEvent: or touchesCancelled:withEvent: message is received, the
      dispatcher first performs the same action as described in the previous point, then
      removes the incoming touches from the cache.
 
 The behavior implemented here is similar to that of the UIKit dispatcher. That is, before
 ICResponder::touchesBegan:withTouchEvent: is dispatched, the framework computes the dispatch
 targets for the incoming touches. In the following touch phases, the dispatch targets doesn't
 change. In other words, the object on which a given touch began continuously receives events
 for that touch until the user releases her corresponding finger from the surface.
 
 @note As of v0.6.3, icedcoffee converts UIEvent and UITouch objects to ICTouchEvent and
 ICTouch objects.
 */
@interface ICTouchEventDispatcher : NSObject
{
@private
    ICHostViewController *_hostViewController;
    NSMutableDictionary *_touchesForDispatchTargets;
    NSMutableDictionary *_dispatchTargetsForTouches;
    NSMutableDictionary *_icTouchesForNativeTouches;
    NSMutableDictionary *_draggingTouches;
    uint64_t _currentControlDispatchFrame;
}

- (id)initWithHostViewController:(ICHostViewController *)hostViewController;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end

#endif // __IC_PLATFORM_IOS
