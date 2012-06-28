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

#import "ICScheduler.h"
#import "ICContextManager.h"
#import "ICRenderContext.h"

@implementation ICScheduler

+ (id)currentScheduler
{
    return [[[ICContextManager defaultContextManager]
             renderContextForCurrentOpenGLContext]
            scheduler];
}

- (id)init
{
    if ((self = [super init])) {
        _targets = [[NSMutableArray alloc] init];
        _targetsWithHighPriority = [[NSMutableArray alloc] init];
        _targetsWithLowPriority = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_targets release];
    [_targetsWithLowPriority release];
    [_targetsWithHighPriority release];
    
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
            [_targets addObject:target];
            break;
        case kICSchedulerPriority_Low:
            [_targetsWithLowPriority addObject:target];
            break;
        case kICSchedulerPriority_High:
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

@end
