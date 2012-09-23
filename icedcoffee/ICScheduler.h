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
#import "ICUpdatable.h"

typedef enum _ICSchedulerPriority {
    kICSchedulerPriority_Default,
    kICSchedulerPriority_High,
    kICSchedulerPriority_Low,
} ICSchedulerPriority;

/**
 @brief A scheduler used for continuously updating animated objects in a scene
 
 A scheduler continuously updates registered objects for animation purposes. 
 Schedulers work in collaboration with host view controllers to issue pending updates to
 registered objects.
 
 Note that ICScheduler updates will only work as expected if the host view
 controller's ICHostViewController:frameUpdateMode is set to ICFrameUpdateModeSynchronized.
 Scenes usnig host view controllers that update their host view frame on demand should
 use NSTimer to perform updates.
 */
@interface ICScheduler : NSObject {
@protected
    NSMutableArray *_targets;
    NSMutableArray *_targetsWithLowPriority;
    NSMutableArray *_targetsWithHighPriority;
}


#pragma mark - Accessing the Current Scheduler
/** @name Accessing the Current Scheduler */

/**
 @brief Returns the scheduler for the current host view controller
 
 This method internally retrieves the current host view controller for the current thread by calling
 ICHostViewController::currentHostViewController and then returns a reference to the current
 scheduler as stored in the ICHostViewController::scheduler property.
 
 Note that this method is thread-safe while all other methods of this class are not.
 */
+ (id)currentScheduler;


#pragma mark - Scheduling Updates
/** @name Scheduling Update */

/**
 @brief Schedule a frame-wise update for the given target
 
 This method schedules frame-wise updates for the given target with default priority.
  
 @param target An object implementing the ICUpdatable protocol. The object will be retained
 by this method.
  
 @sa unscheduleUpdateForTarget:withPriority:
 */
- (void)scheduleUpdateForTarget:(id<ICUpdatable>)target;

/**
 @brief Schedule a frame-wise update for the given target with the specified priority
 
 This method schedules frame-wise updates for the given target with the specified priority.
 
 Each time the host view draws its scene, the target will receive an ICUpdatable::update: message.
 The messages are dispatched after the host view's OpenGL context has been locked and before the
 actual scene contents are drawn.
 
 @param target An object implementing the ICUpdatable protocol. The object will be retained
 by this method.

 @param priority A ICSchedulerPriority value indicating the priority of the updatable target.

 @remarks The scheduled update message will only be dispatched continuously when the respective
 ICHostViewController object that draws the scene is set to synchronized frame update mode. See
 ICHostViewController::frameUpdateMode.
 
 @exception Raises an NSInvalidArgumentException if target is nil or if priority is not a valid
 ICSchedulerPriority enumerated value.
 
 @sa unscheduleUpdateForTarget:
 */
- (void)scheduleUpdateForTarget:(id<ICUpdatable>)target withPriority:(ICSchedulerPriority)priority;

/**
 @brief Unschedule a previously scheduled update for the given target
 
 @param target An object that was previously scheduled for updates. The object will be released
 by this method.
 */
- (void)unscheduleUpdateForTarget:(id<ICUpdatable>)target;

/**
 @brief Called by the framework to update the scheduler internally
 
 Enumerates all targets added to the scheduler and dispatches an ICUpdatable::update: message
 to each of them, starting with targets scheduled with high priority and ending with targets
 scheduled with low priority.
 */
- (void)update:(icTime)dt;

@end
