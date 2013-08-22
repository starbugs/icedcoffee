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

#import "ICControl.h"
#import "ICHostViewController.h"
#import "ICTargetActionDispatcher.h"

#ifdef __IC_PLATFORM_MAC
ICControlEvents ICConcreteControlEvent(ICMouseButton mouseButton,
                                       ICAbstractControlEvents abstractControlEvent)
{
    NSUInteger buttonIndex;
    switch (mouseButton) {
        case ICLeftMouseButton: buttonIndex = 0; break;
        case ICRightMouseButton: buttonIndex = 1; break;
        case ICOtherMouseButton: buttonIndex = 2; break;
        default: {
            [NSException raise:NSInvalidArgumentException format:@"mouseButton is invalid"];
            break;
        }
    }
    return abstractControlEvent << buttonIndex*8;
}
#endif

@implementation ICAction

@synthesize target = _target;
@synthesize action = _action;

- (id)initWithTarget:(id)target action:(SEL)action
{
    if ((self = [super init])) {
        self.target = target;
        self.action = action;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[ICAction class]]) {
        ICAction *compareAction = (ICAction *)object;
        if (compareAction.action == self.action && compareAction.target == self.target) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

@end


@implementation ICControl

- (id)initWithSize:(kmVec3)size
{
    if ((self = [super initWithSize:size])) {
        _actions = [[NSMutableDictionary alloc] init];
        _state = ICControlStateNormal;
    }
    return self;
}

- (void)dealloc
{
    [_actions release];
    
    [super dealloc];
}

#ifdef __IC_PLATFORM_MAC
- (void)sendAction:(SEL)action to:(id)target forEvent:(ICOSXEvent *)event
#elif defined(__IC_PLATFORM_IOS)
- (void)sendAction:(SEL)action to:(id)target forEvent:(ICTouchEvent *)event
#endif
{
    ICAction *actionObject = [[ICAction alloc] initWithTarget:target action:action];
    NSDictionary *actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                self, @"sender", event, @"event", actionObject, @"action", nil];
    [actionObject release];
    
    ICTargetActionDispatcher *taDispatcher = [[self hostViewController] targetActionDispatcher];
    [taDispatcher performSelector:@selector(dispatchActionWithActionDictionary:)
                         onThread:[[self hostViewController] thread]
                       withObject:actionDict
                    waitUntilDone:NO];
}

#ifdef __IC_PLATFORM_MAC
- (void)sendActionsForControlEvent:(ICControlEvents)controlEvent forEvent:(ICOSXEvent *)event
#elif defined(__IC_PLATFORM_IOS)
- (void)sendActionsForControlEvent:(ICControlEvents)controlEvent forEvent:(ICTouchEvent *)event
#endif
{
    NSArray *actions = [_actions objectForKey:[NSNumber numberWithLong:controlEvent]];
    for (ICAction *action in actions) {
        [self sendAction:action.action to:action.target forEvent:event];
    }    
}

- (void)sendActionsForControlEvents:(ICControlEvents)controlEvents
{
    for (NSUInteger flag=1; controlEvents>=flag; flag*=2) {
        if (controlEvents & flag) {
            NSArray *actions = [_actions objectForKey:[NSNumber numberWithLong:flag]];
            for (ICAction *action in actions) {
                [self sendAction:action.action to:action.target forEvent:nil];
            }
        }
    }
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(ICControlEvents)controlEvents
{
    for (NSUInteger flag=1; controlEvents>=flag; flag*=2) {
        if (controlEvents & flag) {
            NSNumber *flagNumber = [NSNumber numberWithLong:flag];
            NSMutableArray *actions = [_actions objectForKey:flagNumber];
            if (!actions) {
                actions = [NSMutableArray arrayWithCapacity:1];
                [_actions setObject:actions forKey:flagNumber];
            }
            ICAction *actionObject = [[ICAction alloc] initWithTarget:target action:action];
            if (![actions containsObject:actionObject])
                [actions addObject:actionObject];
            [actionObject release];
        }
    }
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(ICControlEvents)controlEvents
{
    for (NSUInteger flag=1; controlEvents>=flag; flag*=2) {
        if (controlEvents & flag) {
            NSNumber *flagNumber = [NSNumber numberWithLong:flag];
            NSMutableArray *actions = [_actions objectForKey:flagNumber];
            if (actions) {
                for (ICAction *theAction in actions) {
                    if (theAction.target == target && theAction.action == action) {
                        [actions removeObject:theAction];
                        break;
                    }
                }
            }
        }
    }
}

- (NSArray *)actionsForTarget:(id)target forControlEvent:(ICControlEvents)controlEvent
{
    NSMutableArray *resultActions = [NSMutableArray array];
    NSArray *actions = [_actions objectForKey:[NSNumber numberWithLong:controlEvent]];
    if (actions) {
        for (ICAction *action in actions) {
            if (action.target == target) {
                [resultActions addObject:NSStringFromSelector(action.action)];
            }
        }
    }
    return resultActions;
}

- (ICControlEvents)allControlEvents
{
    ICControlEvents controlEvents = 0x0;
    for (NSNumber *flagNumber in [_actions allKeys]) {
        controlEvents |= [flagNumber longLongValue];
    }
    return controlEvents;
}

- (NSArray *)allTargets
{
    NSMutableArray *targets = [NSMutableArray array];
    for (NSArray *actions in [_actions allValues]) {
        for (ICAction *action in actions) {
            [targets addObject:action.target];
        }
    }
    return targets;
}

- (BOOL)enabled
{
    return !(_state & ICControlStateDisabled);
}

- (void)setEnabled:(BOOL)enabled
{
    if (enabled) {
        _state &= ~ICControlStateDisabled;
    } else {
        _state |= ICControlStateDisabled;
    }
}

- (BOOL)highlighted
{
    return (_state & ICControlStateHighlighted);
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        _state |= ICControlStateHighlighted;
    } else {
        _state &= ~ICControlStateHighlighted;
    }
}

- (BOOL)selected
{
    return (_state & ICControlStateSelected);
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        _state |= ICControlStateSelected;
    } else {
        _state &= ~ICControlStateSelected;
    }
}

- (ICControlState)state
{
    return _state;
}

- (void)setState:(ICControlState)state
{
    _state = state;
    [self setNeedsDisplay];
}

@end
