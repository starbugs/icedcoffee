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

#import "ICOSXEvent.h"

@implementation ICOSXEvent

@synthesize nativeEvent = _nativeEvent;
@synthesize hostView = _hostView;

+ (id)eventWithNativeEvent:(NSEvent *)event hostView:(NSView *)hostView
{
    return [[[[self class] alloc] initWithNativeEvent:event hostView:hostView] autorelease];
}

- (id)initWithNativeEvent:(NSEvent *)event hostView:(NSView *)hostView
{
    if ((self = [super init])) {
        _nativeEvent = [event retain];
        _hostView = [hostView retain];
    }
    return self;
}

- (void)dealloc
{
    [_nativeEvent release];
    [_hostView release];
    [super dealloc];
}

- (NSGraphicsContext *)context
{
    return [_nativeEvent context];
}

- (CGPoint)locationInWindow
{
    return [_nativeEvent locationInWindow];
}

- (NSUInteger)modifierFlags
{
    return [_nativeEvent modifierFlags];
}

- (NSTimeInterval)timestamp
{
    return [_nativeEvent timestamp];
}

- (ICOSXEventType)type
{
    return (ICOSXEventType)[_nativeEvent type];
}

- (NSWindow *)window
{
    return [_nativeEvent window];
}

- (NSInteger)windowNumber
{
    return [_nativeEvent windowNumber];
}

- (const void *)eventRef
{
    return [_nativeEvent eventRef];
}

- (CGEventRef)CGEvent
{
    return [_nativeEvent CGEvent];
}

@end
