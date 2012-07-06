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

#import "icMacros.h"

#ifdef __IC_PLATFORM_IOS

#import "ICTouchEventDispatcher.h"
#import "ICTouchEvent.h"
#import "ICTouch.h"
#import "ICHostViewController.h"
#import "ICNode.h"
#import "ICNodeRef.h"


@implementation ICTouchEventDispatcher

- (id)initWithHostViewController:(ICHostViewController *)hostViewController
{
    if ((self = [super init])) {
        _hostViewController = hostViewController;
        _touchesForDispatchTargets = [[NSMutableDictionary alloc] init];
        _dispatchTargetsForTouches = [[NSMutableDictionary alloc] init];
        _icTouchesForNativeTouches = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_touchesForDispatchTargets release];
    [_dispatchTargetsForTouches release];
    [_icTouchesForNativeTouches release];
    [super dealloc];
}

#if IC_ENABLE_DEBUG_TOUCH_DISPATCHER
// Debugging
- (void)debugLogCacheDicts
{
    ICLOG(@"touchesForDispatchTargets:\n%@", [_touchesForDispatchTargets description]);
    ICLOG(@"dispatchTargetsForTouches:\n%@", [_dispatchTargetsForTouches description]);
}
#endif // IC_ENABLE_DEBUG_TOUCH_DISPATCHER

- (ICTouch *)icTouchForNativeTouch:(UITouch *)touch
{
    NSValue *touchAddress = [NSValue valueWithPointer:touch];
    ICTouch *icTouch = [_icTouchesForNativeTouches objectForKey:touchAddress];
    if (!icTouch) {
        ICNode *node = [_dispatchTargetsForTouches objectForKey:touchAddress];
        icTouch = [ICTouch touchWithNativeTouch:touch node:node];
        [_icTouchesForNativeTouches setObject:icTouch forKey:touchAddress];
    }
    return icTouch;
}

- (void)setTouch:(UITouch *)touch forDispatchTarget:(ICNode *)dispatchTarget withCachedTouches:(NSMutableDictionary *)cachedTouches
{
    ICNodeRef *dispatchTargetRef = [ICNodeRef refWithNode:dispatchTarget];
    
    // Assign touches to dispatch targets, so we know which dispatch target receives what touches
    // for the actual event dispatch
    NSMutableDictionary *touches = [cachedTouches objectForKey:dispatchTargetRef];
    if (!touches) {
        touches = [NSMutableDictionary dictionary];
        [cachedTouches setObject:touches forKey:dispatchTargetRef];
    }
    [touches setObject:touch forKey:[NSValue valueWithPointer:touch]];
}

- (void)setTouch:(UITouch *)touch forDispatchTarget:(ICNode *)dispatchTarget
{
    [self setTouch:touch forDispatchTarget:dispatchTarget withCachedTouches:_touchesForDispatchTargets];
    
    // Assign dispatch targets to individual touch objects, so we can later efficiently map
    // an incoming touch to the already known dispatch target
    [_dispatchTargetsForTouches setObject:dispatchTarget
                                   forKey:[NSValue valueWithPointer:touch]];
}

- (void)removeTouch:(UITouch *)touch
{
    NSValue *touchAddress = [NSValue valueWithPointer:touch];
    ICNode *dispatchTarget = [_dispatchTargetsForTouches objectForKey:touchAddress];
    
    if (dispatchTarget) {
        ICNodeRef *dispatchTargetRef = [ICNodeRef refWithNode:dispatchTarget];
        
        // Remove touch from touches for the given dispatch target
        NSMutableDictionary *touches = [_touchesForDispatchTargets objectForKey:dispatchTargetRef];
        [touches removeObjectForKey:touchAddress];
        // If there are no more touches for the dispatch target, remove the whole entry from the dict
        if ([touches count] == 0) {
            [_touchesForDispatchTargets removeObjectForKey:dispatchTargetRef];
        }
    }
    
    // Remove dispatch target for the given touch in our second mapping
    [_dispatchTargetsForTouches removeObjectForKey:touchAddress];
    
    // Remove converted ICTouch for corresponding native UITouch
    [_icTouchesForNativeTouches removeObjectForKey:touchAddress];
}

- (NSDictionary *)convertNativeCachedTouchesToICTouches:(NSDictionary *)cachedTouches
{
    NSMutableDictionary *convertedCachedTouches = [NSMutableDictionary dictionaryWithCapacity:[cachedTouches count]];
    NSEnumerator *e = [cachedTouches keyEnumerator];
    ICNodeRef *dispatchTargetRef = nil;
    while (dispatchTargetRef = [e nextObject]) {
        NSDictionary *nativeTouches = [cachedTouches objectForKey:dispatchTargetRef];
        NSMutableDictionary *convertedTouches = [NSMutableDictionary dictionaryWithCapacity:[nativeTouches count]];
        [convertedCachedTouches setObject:convertedTouches forKey:dispatchTargetRef];
        NSEnumerator *nativeTouchEnumerator = [nativeTouches objectEnumerator];
        UITouch *nativeTouch = nil;
        while (nativeTouch = [nativeTouchEnumerator nextObject]) {
            ICTouch *icTouch = [self icTouchForNativeTouch:nativeTouch];
            [convertedTouches setObject:icTouch forKey:[NSValue valueWithPointer:icTouch]];
        }
    }
    return convertedCachedTouches;
}

- (void)dispatchCachedTouches:(NSDictionary *)cachedTouches withEvent:(UIEvent *)event selector:(SEL)selector
{
    // Dispatch event message with touches for each dispatch target
    NSDictionary *convertedTouches = [self convertNativeCachedTouchesToICTouches:cachedTouches];
    ICTouchEvent *touchEvent = [ICTouchEvent touchEventWithNativeEvent:event touchesForNodes:convertedTouches];
    NSEnumerator *dispatchTargetEnumerator = [convertedTouches keyEnumerator];
    ICNodeRef *dispatchTargetRef = nil;
    while (dispatchTargetRef = [dispatchTargetEnumerator nextObject]) {
        ICNode *dispatchTarget = [dispatchTargetRef node];
        NSDictionary *touchesDict = [convertedTouches objectForKey:dispatchTargetRef];
        NSEnumerator *touchesEnumerator = [touchesDict objectEnumerator];
        ICTouch *touch = nil;
        NSMutableSet *touches = [NSMutableSet setWithCapacity:[touchesDict count]];
        while (touch = [touchesEnumerator nextObject]) {
            [touches addObject:touch];
        }
        if ([dispatchTarget respondsToSelector:selector]) {
            [dispatchTarget performSelector:selector
                                 withObject:touches
                                 withObject:touchEvent];
        }
    }    
}

// To be called when processing touchesBegan:withEvent:, adds new incoming touches to the mappings.
// Returns a dictionary which maps touches to dispatch targets.
- (NSDictionary *)cacheNewTouches:(NSSet *)touches
{
    // Assign touches to dispatch targets (ICNode objects hit by the respective touches).
    // Also, assign dispatch targets to touches in a distinct dictionary so we can later
    // efficiently match incoming touch objects to dispatch targets that are already cached.
    // Assignment is implemented in the setTouch:forDispatchTarget: method.
    NSArray *allTouches = [touches allObjects];
    for (UITouch *touch in allTouches) {
        CGPoint touchLocation = [touch locationInView:[_hostViewController view]];
        // Perform a hit test with each touch location to compute dispatch targets
        ICNode *dispatchTarget = [[_hostViewController hitTest:touchLocation] lastObject];
        if (dispatchTarget)
            [self setTouch:touch forDispatchTarget:dispatchTarget];
    }
    
    return _touchesForDispatchTargets;
}

// To be called when processing touchesMoved:withEvent:, touchesEnded:withEvent, or
// touchesCancelled:withEvent:, filters cached touches. Returns a dictionary which maps
// filtered touches to dispatch targets.
- (NSDictionary *)filterCachedTouchesWithTouches:(NSSet *)touches
{
    NSMutableDictionary *filteredTouchesForDispatchTargets =
        [NSMutableDictionary dictionaryWithCapacity:[touches count]];
    
    NSArray *allTouches = [touches allObjects];
    for (UITouch *touch in allTouches) {
        // Find dispatch targets in mapping using the touches' address
        ICNode *dispatchTarget = [_dispatchTargetsForTouches objectForKey:[NSValue valueWithPointer:touch]];
        // Assign each touch to its respective dispatch target in our filtered mapping
        [self setTouch:touch forDispatchTarget:dispatchTarget withCachedTouches:filteredTouchesForDispatchTargets];
    }
    
    return filteredTouchesForDispatchTargets;
}

// To be called after processing touchesEnded:withEvent: or touchesCancelled:withEvent:, removes
// obsolete touches that were ended or cancelled from the cache.
- (void)removeObsoleteCachedTouchesWithTouches:(NSSet *)touches
{
    NSArray *allTouches = [touches allObjects];
    for (UITouch *touch in allTouches) {
        [self removeTouch:touch];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
#if IC_ENABLE_DEBUG_TOUCH_DISPATCHER
    ICLOG(@"Handling %@ (%d touches)", NSStringFromSelector(_cmd), [touches count]);
#endif
    NSDictionary *cachedTouches = [self cacheNewTouches:touches];
    [self dispatchCachedTouches:cachedTouches withEvent:event selector:@selector(touchesBegan:withTouchEvent:)];
#if IC_ENABLE_DEBUG_TOUCH_DISPATCHER
    [self debugLogCacheDicts];
#endif
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
#if IC_ENABLE_DEBUG_TOUCH_DISPATCHER
    ICLOG(@"Handling %@ (%d touches)", NSStringFromSelector(_cmd), [touches count]);
#endif
    NSDictionary *cachedTouches = [self filterCachedTouchesWithTouches:touches];
    [self dispatchCachedTouches:cachedTouches withEvent:event selector:@selector(touchesMoved:withTouchEvent:)];
#if IC_ENABLE_DEBUG_TOUCH_DISPATCHER
    [self debugLogCacheDicts];
#endif
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
#if IC_ENABLE_DEBUG_TOUCH_DISPATCHER
    ICLOG(@"Handling %@ (%d touches)", NSStringFromSelector(_cmd), [touches count]);
#endif
    NSDictionary *cachedTouches = [self filterCachedTouchesWithTouches:touches];
    [self dispatchCachedTouches:cachedTouches withEvent:event selector:@selector(touchesCancelled:withTouchEvent:)];    
    [self removeObsoleteCachedTouchesWithTouches:touches];
#if IC_ENABLE_DEBUG_TOUCH_DISPATCHER
    [self debugLogCacheDicts];
#endif
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
#if IC_ENABLE_DEBUG_TOUCH_DISPATCHER
    ICLOG(@"Handling %@ (%d touches)", NSStringFromSelector(_cmd), [touches count]);
#endif
    NSDictionary *cachedTouches = [self filterCachedTouchesWithTouches:touches];
    [self dispatchCachedTouches:cachedTouches withEvent:event selector:@selector(touchesEnded:withEvent:)];    
    [self removeObsoleteCachedTouchesWithTouches:touches];
#if IC_ENABLE_DEBUG_TOUCH_DISPATCHER
    [self debugLogCacheDicts];
#endif
}

@end

#endif // __IC_PLATFORM_IOS
