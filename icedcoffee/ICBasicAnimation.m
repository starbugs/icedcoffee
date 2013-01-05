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

#import "ICBasicAnimation.h"
#import "ICNode.h"

#define ANIMATE_NUMBER_PROPERTY(primitiveType, getterMethod, creationMethod, timeFactor) \
    primitiveType from = [self.fromValue getterMethod]; \
    primitiveType to = [self.toValue getterMethod]; \
    primitiveType value = from + timeFactor * (to - from); \
    [target setValue:[NSNumber creationMethod:value] forKeyPath:self.keyPath];


@implementation ICBasicAnimation

@synthesize fromValue = _fromValue;
@synthesize toValue = _toValue;
@synthesize duration = _duration;

- (id)initWithKeyPath:(NSString *)keyPath
{
    if ((self = [super initWithKeyPath:keyPath])) {
        self.duration = 1.0;
    }
    return self;
}

- (void)dealloc
{
    self.fromValue = nil;
    self.toValue = nil;
    
    [super dealloc];
}

- (void)processAnimationWithTarget:(ICNode *)target deltaTime:(icTime)dt
{
    NSAssert(self.keyPath != nil, @"keyPath must not be nil");
    NSAssert(self.fromValue != nil, @"fromValue must not be nil");
    NSAssert(self.toValue != nil, @"toValue must not be nil");
    
    _currentDeltaTime += dt;
    
    if (_currentDeltaTime > _duration)
        _currentDeltaTime = _duration;
    
    if (!_isAnimating) {
        if ([self.delegate respondsToSelector:@selector(animationDidStart:)])
            [self.delegate animationDidStart:self];
        _isAnimating = YES;
    }
    
    double timeFactor = _currentDeltaTime / _duration;
    if (self.timingFunction) {
        timeFactor = [self.timingFunction timeFactor:timeFactor];
    }

    if ([self.fromValue isKindOfClass:[NSNumber class]] &&
        [self.toValue isKindOfClass:[NSNumber class]]) {
        
        if (0 == strcmp([self.fromValue objCType], "f")) {
            ANIMATE_NUMBER_PROPERTY(float, floatValue, numberWithFloat, timeFactor);
        } else if (0 == strcmp([self.fromValue objCType], "d")) {
            ANIMATE_NUMBER_PROPERTY(double, doubleValue, numberWithDouble, timeFactor);
        }
        
    } else if ([self.fromValue isKindOfClass:[NSValue class]] &&
               [self.toValue isKindOfClass:[NSValue class]]) {
        
        const char *objCType = [self.fromValue objCType];
        const char *objCTypeTo = [self.toValue objCType];
        NSAssert(0 == strcmp(objCType, objCTypeTo),
                 @"objCType of fromValue and toValue must match");
        
        const char *vec2Type = @encode(kmVec2);
        const char *vec3Type = @encode(kmVec3);
        const char *color4BType = @encode(icColor4B);
        
        if (0 == strcmp(objCType, vec3Type)) {
            
            kmVec3 value, from, to;
            [self.fromValue getValue:&from];
            [self.toValue getValue:&to];
            value.x = from.x + timeFactor * (to.x - from.x);
            value.y = from.y + timeFactor * (to.y - from.y);
            value.z = from.z + timeFactor * (to.z - from.z);
            [target setValue:[NSValue valueWithBytes:&value objCType:vec3Type]
                  forKeyPath:self.keyPath];
            
        } else if(0 == strcmp(objCType, vec2Type)) {
            
            kmVec2 value, from, to;
            [self.fromValue getValue:&from];
            [self.toValue getValue:&to];
            value.x = from.x + timeFactor * (to.x - from.x);
            value.y = from.y + timeFactor * (to.y - from.y);
            [target setValue:[NSValue valueWithBytes:&value objCType:vec2Type]
                  forKeyPath:self.keyPath];
            
        } else if(0 == strcmp(objCType, color4BType)) {
            
            icColor4B value, from, to;
            [self.fromValue getValue:&from];
            [self.toValue getValue:&to];
            value.r = (float)from.r + (float)timeFactor * (float)(to.r - from.r);
            value.g = (float)from.g + (float)timeFactor * (float)(to.g - from.g);
            value.b = (float)from.b + (float)timeFactor * (float)(to.b - from.b);
            value.a = (float)from.a + (float)timeFactor * (float)(to.a - from.a);
            [target setValue:[NSValue valueWithBytes:&value objCType:color4BType]
                  forKeyPath:self.keyPath];
            
        }
        
    }
    
    if (_currentDeltaTime >= _duration) {
        _isFinished = YES;
        _isAnimating = NO;
        if ([self.delegate respondsToSelector:@selector(animationDidStop:finished:)])
            [self.delegate animationDidStop:self finished:YES];
    }
}

@end
