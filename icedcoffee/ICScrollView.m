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

#import "ICScrollView.h"
#import "ICScene.h"
#import "ICCamera.h"
#import "ICScheduler.h"

@interface ICScrollView (Private)
- (ICView *)contentView;
- (void)releaseTouches;
- (void)cancelTracking;
@end

@implementation ICScrollView

@synthesize contentSize = _contentSize;
@synthesize contentOffset = _contentOffset;
@synthesize automaticallyCalculatesContentSize = _automaticallyCalculatesContentSize;

- (id)initWithSize:(kmVec3)size
{
    if ((self = [super initWithSize:size])) {
        self.clipsChildren = YES;
        self.automaticallyCalculatesContentSize = YES;
        _scrollVelocity = kmNullVec3;
        
#ifdef __IC_PLATFORM_MAC
        memset(_initialTouches, 0, sizeof(NSTouch *)*2);
        memset(_currentTouches, 0, sizeof(NSTouch *)*2);
        _isTracking = NO;
#endif
    }
    return self;
}

- (void)dealloc
{
    [_contentView release];
    [_positionBuffer release];
    
#ifdef __IC_PLATFORM_MAC
    [self releaseTouches];
#endif
    
    [super dealloc];
}

- (ICView *)contentView
{
    if (self.backing) {
        return [self backingContentView];
    }
    
    if (!_contentView) {
        _contentView = [[ICView alloc] initWithSize:self.size];
        _contentView.name = @"Content view";
        [super addChild:_contentView];
    }
    
    return _contentView;
}

#ifdef __IC_PLATFORM_MAC
- (void)scrollWheel:(ICMouseEvent *)event
{
    //NSLog(@"smx: %f smy: %f", _scrollMovement.x, _scrollMovement.y);
    // Do not handle touch events as scroll events
    if (!event.nativeEvent.hasPreciseScrollingDeltas) {
        [self setContentOffset:kmVec3Make(_contentOffset.x + [event deltaX],
                                          _contentOffset.y + [event deltaY],
                                          0)];
    }
}

- (void)touchesBeganWithEvent:(ICTouchEvent *)event
{
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseTouching];
    
    if ([touches count] == 2) {
        //NSLog(@"BEGIN");
        [[ICScheduler currentScheduler] unscheduleUpdateForTarget:self];

        [_positionBuffer release];
        _positionBuffer = [[NSMutableArray alloc] initWithCapacity:10];

        NSArray *array = [touches allObjects];
        _initialTouches[0] = [[array objectAtIndex:0] retain];
        _initialTouches[1] = [[array objectAtIndex:1] retain];
        _currentTouches[0] = [_initialTouches[0] retain];
        _currentTouches[1] = [_initialTouches[1] retain];
        
        _scrollVelocity = kmNullVec3;
        _initialOffset = self.contentOffset;
        _lastNormalizedPosition = kmVec3Make([_initialTouches[0] normalizedPosition].x, [_initialTouches[0] normalizedPosition].y, 0);
        _restingPosition = _lastNormalizedPosition;
        [_positionBuffer addObject:[NSData dataWithBytes:&_lastNormalizedPosition length:sizeof(kmVec3)]];
        
        _isTracking = YES;
    } else {
        [self releaseTouches];
    }
}

- (void)touchesMovedWithEvent:(ICTouchEvent *)event
{
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseTouching];
    if (touches.count == 2 && _initialTouches[0]) {
        NSArray<NSTouch *> *array = [touches allObjects];
        [_currentTouches[0] release];
        [_currentTouches[1] release];
        
        NSTouch *touch;
        touch = [array objectAtIndex:0];
        if ([touch.identity isEqual:_initialTouches[0].identity]) {
            _currentTouches[0] = [touch retain];
        } else {
            _currentTouches[1] = [touch retain];
        }
        touch = [array objectAtIndex:1];
        if ([touch.identity isEqual:_initialTouches[0].identity]) {
            _currentTouches[0] = [touch retain];
        } else {
            _currentTouches[1] = [touch retain];
        }
        
        kmVec3 initialPosition = kmVec3Make([_initialTouches[0] normalizedPosition].x, [_initialTouches[0] normalizedPosition].y, 0);
        kmVec3 normalizedPosition = kmVec3Make([_currentTouches[0] normalizedPosition].x, [_currentTouches[0] normalizedPosition].y, 0.0f);
        
        kmVec3 direction;
        kmVec3Subtract(&direction, &normalizedPosition, &initialPosition);
        kmVec3Scale(&direction, &direction, 400);
        direction.x *= -1; // flip horizontal access for natural scrolling
        
        kmVec3 contentOffset;
        kmVec3Subtract(&contentOffset, &_initialOffset, &direction);
        self.contentOffset = contentOffset;

        kmVec3 diff;
        kmVec3Subtract(&diff, &normalizedPosition, &_lastNormalizedPosition);
        kmVec3Scale(&diff, &diff, 100);
        diff.x *= -1;
        [_positionBuffer addObject:[NSData dataWithBytes:&diff length:sizeof(kmVec3)]];
        _lastNormalizedPosition = normalizedPosition;
        if ([_positionBuffer count] > 9) {
            [_positionBuffer removeObjectAtIndex:0];
        }
    }
}

- (void)touchesEndedWithEvent:(ICTouchEvent *)event
{
    if ([_positionBuffer count] > 0) {
        kmVec3 scrollVelocity = kmNullVec3;
        //NSLog(@"PosBuf count: %lu", (unsigned long)[_positionBuffer count]);
        for (NSData *vectorData in _positionBuffer) {
            kmVec3 vec;
            [vectorData getBytes:&vec];
            kmVec3Add(&scrollVelocity, &scrollVelocity, &vec);
            //NSLog(@"%@", kmVec3Description(scrollVelocity));
        }
        _scrollVelocity = scrollVelocity;
        float d = kmVec3Length(&_scrollVelocity);
        kmVec3Scale(&_scrollVelocity, &_scrollVelocity, d/((float)([_positionBuffer count])));
        [_positionBuffer removeAllObjects];
    }
    
    //_scrollVelocity.x *= -1;
    
    //NSLog(@"END");
    [[ICScheduler currentScheduler] scheduleUpdateForTarget:self];
    [self setNeedsDisplay];
    //NSLog(@"%@", kmVec3Description(_scrollVelocity));
    _isMoving = YES;
    [self releaseTouches];
}

- (void)touchesCancelledWithEvent:(ICTouchEvent *)event
{
    NSLog(@"CANCEL");
    [self releaseTouches];
}

- (void)update:(icTime)dt
{
    //NSLog(@"Upd %f", dt);
    kmVec3 contentOffset = self.contentOffset;
    kmVec3Subtract(&contentOffset, &contentOffset, &_scrollVelocity);
    kmVec3Scale(&_scrollVelocity, &_scrollVelocity, 0.96f);
    self.contentOffset = contentOffset;
    
    if (kmVec3Length(&_scrollVelocity) <= 0.01) {
        [[ICScheduler currentScheduler] unscheduleUpdateForTarget:self];
    }
}

- (void)releaseTouches
{
    [_initialTouches[0] release];
    [_initialTouches[1] release];
    [_currentTouches[0] release];
    [_currentTouches[1] release];
    
    memset(_initialTouches, 0, sizeof(NSTouch *)*2);
    memset(_currentTouches, 0, sizeof(NSTouch *)*2);
}

- (void)cancelTracking
{
    _isTracking = NO;
    [self releaseTouches];
}
#endif

- (void)setContentOffset:(kmVec3)contentOffset
{
    kmVec3 offsetMax = kmVec3Make(-_contentMax.x + _size.width,
                                  -_contentMax.y + _size.height,
                                  -_contentMax.z + _size.depth);
    contentOffset.x = MAX(offsetMax.x, contentOffset.x);
    contentOffset.y = MAX(offsetMax.y, contentOffset.y);
    contentOffset.z = MAX(offsetMax.z, contentOffset.z);
    contentOffset.x = MIN(-_contentMin.x, contentOffset.x);
    contentOffset.y = MIN(-_contentMin.y, contentOffset.y);
    contentOffset.z = MIN(-_contentMin.z, contentOffset.z);
    
    _contentOffset = contentOffset;

    [[self contentView] setPosition:_contentOffset];
    [self setNeedsLayout];
}

// FIXME (negative min)
- (void)setContentSize:(kmVec3)contentSize
{
    _contentSize = contentSize;
    _contentMin = kmNullVec3;
    _contentMax = _contentSize;
    [[self contentView] setSize:contentSize];
    [self setNeedsLayout];
}

- (void)setSize:(kmVec3)size
{
    [super setSize:size];
}

// FIXME (negative min)
// FIXME: replace with icComputeAABBContainingAABBsOfNodes()?
- (void)calculateContentSize
{
    _contentMin = kmNullVec3;
    _contentMax = kmNullVec3;
    
    // FIXME: this should be generalized to support arbitrary transforms
    for (ICNode *child in [self contentView].children) {
        kmAABB aabb = [child aabb];
        _contentMin.x = MIN(_contentMin.x, aabb.min.x);
        _contentMin.y = MIN(_contentMin.y, aabb.min.y);
        _contentMin.z = MIN(_contentMin.z, aabb.min.z);
        _contentMax.x = MAX(_contentMax.x, aabb.max.x);
        _contentMax.y = MAX(_contentMax.y, aabb.max.y);
        _contentMax.z = MAX(_contentMax.z, aabb.max.z);
    }
    
    kmVec3Subtract(&_contentSize, &_contentMax, &_contentMin);
    [[self contentView] setOrigin:_contentMin];
    [[self contentView] setSize:_contentSize];
    [self setNeedsLayout];
}


// Composition overrides

// FIXME: missing overrides

- (void)addChild:(ICNode *)child
{
    [[self contentView] addChild:child];
    
    if (self.automaticallyCalculatesContentSize)
        [self calculateContentSize];
}

- (void)insertChild:(ICNode *)child atIndex:(uint)index
{
    [[self contentView] insertChild:child atIndex:index];
}

- (void)removeChild:(ICNode *)child
{
    [[self contentView] removeChild:child];
}

- (void)removeChildAtIndex:(uint)index
{
    [[self contentView] removeChildAtIndex:index];
}

- (void)removeAllChildren
{
    [[self contentView] removeAllChildren];
}

- (NSArray *)children
{
    return [[self contentView] children];
}

// FIXME: childrenNotOfType missing
- (NSArray *)childrenOfType:(Class)classType
{
    return [[self contentView] childrenOfType:classType];
}

- (ICNode *)childForTag:(uint)tag
{
    return [[self contentView] childForTag:tag];
}


@end
