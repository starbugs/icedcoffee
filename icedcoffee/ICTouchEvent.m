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

#import "UIKit/UIKit.h"
#import "ICTouchEvent.h"
#import "ICNodeRef.h"

#ifdef __IC_PLATFORM_IOS

@implementation ICTouchEvent

@synthesize nativeEvent = _nativeEvent;

+ (id)touchEventWithNativeEvent:(UIEvent *)nativeEvent touchesForNodes:(NSDictionary *)touchesForNodes
{
    return [[[[self class] alloc] initWithNativeEvent:nativeEvent touchesForNodes:touchesForNodes] autorelease];
}

- (id)initWithNativeEvent:(UIEvent *)nativeEvent touchesForNodes:(NSDictionary *)touchesForNodes
{
    if ((self = [super init])) {
        _nativeEvent = [nativeEvent retain];
        _touchesForNodes = [touchesForNodes retain];
    }
    return self;
}

- (void)dealloc
{
    [_nativeEvent release];
    [_touchesForNodes release];
    [super dealloc];
}

- (NSSet *)allTouches
{
    NSMutableSet *allTouches = [NSMutableSet set];
    NSEnumerator *e = [_touchesForNodes objectEnumerator];
    NSArray *touches = nil;
    while (touches = [e nextObject]) {
        for (UITouch *touch in touches)
            [allTouches addObject:touch];
    }
    return allTouches;
}

- (NSSet *)touchesForNode:(ICNode *)node
{
    return [NSSet setWithArray:[_touchesForNodes objectForKey:[ICNodeRef refWithNode:node]]];
}

@end

#endif // __IC_PLATFORM_IOS

