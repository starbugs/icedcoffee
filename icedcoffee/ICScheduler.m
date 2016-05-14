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

#import "ICScheduler.h"
#import "ICHostViewController.h"
#import "ICAnimation.h"
#import "ICNode.h"

@interface ICScheduler (Private)
- (void)processAnimations:(icTime)dt;
@end

@implementation ICScheduler

+ (id)currentScheduler
{
    return [[ICHostViewController currentHostViewController] scheduler];
}

- (id)init
{
    if ((self = [super init])) {
        _targets = [[NSMutableArray alloc] init];
        _targetsWithHighPriority = [[NSMutableArray alloc] init];
        _targetsWithLowPriority = [[NSMutableArray alloc] init];
        _animations = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_targets release];
    [_targetsWithLowPriority release];
    [_targetsWithHighPriority release];
    [_animations release];
    
    [super dealloc];
}

- (void)scheduleUpdateForTarget:(id<ICUpdatable>)target
{
    [self scheduleUpdateForTarget:target withPriority:kICSchedulerPriority_Default];
}

- (void)scheduleUpdateForTarget:(id<ICUpdatable>)target withPriority:(ICSchedulerPriority)priority
{
    if (!target) {
        [NSException raise:NSInvalidArgumentException format:@"Target must not be nil"];
        return;
    }
    
    switch (priority) {
        case kICSchedulerPriority_Default:
            if (![_targets containsObject:target])
                [_targets addObject:target];
            break;
        case kICSchedulerPriority_Low:
            if (![_targetsWithLowPriority containsObject:target])
                [_targetsWithLowPriority addObject:target];
            break;
        case kICSchedulerPriority_High:
            if (![_targetsWithLowPriority containsObject:target])
                [_targetsWithHighPriority addObject:target];
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException
                        format:@"Invalid priority value"];
            break;
    }
}

- (void)unscheduleUpdateForTarget:(id<ICUpdatable>)target
{
    if ([_targets containsObject:target])
        [_targets removeObject:target];
    if ([_targetsWithLowPriority containsObject:target])
        [_targetsWithLowPriority removeObject:target];
    if ([_targetsWithHighPriority containsObject:target])
        [_targetsWithHighPriority removeObject:target];
}

- (void)update:(icTime)dt
{
    [self processAnimations:dt];
    
    for (id<ICUpdatable> target in _targetsWithHighPriority) {
        [target update:dt];
    }
    
    for (id<ICUpdatable> target in _targets) {
        [target update:dt];
    }

    for (id<ICUpdatable> target in _targetsWithLowPriority) {
        [target update:dt];
    }
}

// FIXME: this creates a new dictionary even if not required
- (NSArray *)animationsForNode:(ICNode *)node
{
    NSMutableArray *animations = [_animations objectForKey:[NSValue valueWithPointer:node]];
    if (!animations) {
        animations = [NSMutableArray arrayWithCapacity:1];
        [_animations setObject:animations forKey:[NSValue valueWithPointer:node]];
    }
    return animations;
}

- (void)addAnimation:(ICAnimation *)animation forNode:(ICNode *)node
{
    NSAssert(node != nil, @"node must not be nil");
    NSAssert(animation != nil, @"animation must not be nil");
    
    NSMutableArray *animations = (NSMutableArray *)[self animationsForNode:node];
    [animations addObject:animation];
}

- (void)removeAnimation:(ICAnimation *)animation forNode:(ICNode *)node
{
    NSAssert(node != nil, @"node must not be nil");
    NSAssert(animation != nil, @"animation must not be nil");
    
    NSMutableArray *animations = (NSMutableArray *)[self animationsForNode:node];
    [animations removeObject:animation];
    if ([animation.delegate respondsToSelector:@selector(animationDidStop:finished:)]) {
        [animation.delegate animationDidStop:animation finished:NO];
    }
}

- (void)removeAllAnimationsForNode:(ICNode *)node
{
    NSAssert(node != nil, @"node must not be nil");
    [_animations removeObjectForKey:[NSValue valueWithPointer:node]];
}

- (void)processAnimations:(icTime)dt
{
    NSDictionary *animations = [_animations copy];
    
    for (NSValue *nodeValue in animations) {
        NSArray *nodeAnimations = [[animations objectForKey:nodeValue] copy];
        for (NSInteger i=[nodeAnimations count] - 1; i>=0; i--) {
            ICNode *node = (ICNode *)[nodeValue pointerValue];
            ICAnimation *animation = [nodeAnimations objectAtIndex:i];
            [animation processAnimationWithTarget:node deltaTime:dt];
            [node setNeedsDisplay];
            if (animation.isFinished)
                [node removeAnimation:animation];
        }
        [nodeAnimations release];
    }
    
    [animations release];
}

@end
