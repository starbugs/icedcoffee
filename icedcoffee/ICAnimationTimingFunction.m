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

#import "ICAnimationTimingFunction.h"


// Inspired by
// http://blog.greweb.fr/2012/02/bezier-curve-based-easing-functions-from-concept-to-implementation/


static float icTermA(float u, float v)
{
    return 1.f - 3.f * v + 3.f * u;
}

static float icTermB(float u, float v)
{
    return 3.f * v - 6.f * u;
}

static float icTermC(float u)
{
    return 3.f * u;
}

static float icBezier(float t, float u, float v)
{
    return ((icTermA(u, v)*t + icTermB(u, v))*t + icTermC(u))*t;
}

static float icSlope(float t, float u, float v)
{
    return 3.f * icTermA(u, v)*t*t + 2.f * icTermB(u, v) * t + icTermC(u);
}

static float icTForX(float x, kmVec2 c0, kmVec2 c1)
{
    float t = x;
    for (int i=0; i<8; i++) {
        float slope = icSlope(t, c0.x, c1.x);
        if (slope == 0.f)
            return t;
        float currentX = icBezier(t, c0.x, c1.x) - x;
        t -= currentX / slope;
    }
    return t;
}


@implementation ICAnimationTimingFunction

+ (id)linearTimingFunction
{
    return [[self class] timingFunctionWithControlPoints:kmVec2Make(0.f, 0.f)
                                                        :kmVec2Make(1.f, 1.f)];
}

+ (id)easeInTimingFunction
{
    return [[self class] timingFunctionWithControlPoints:kmVec2Make(0.42f, 0.f)
                                                        :kmVec2Make(1.f, 1.f)];
}

+ (id)easeOutTimingFunction
{
    return [[self class] timingFunctionWithControlPoints:kmVec2Make(0.f, 0.f)
                                                        :kmVec2Make(0.58f, 1.f)];
}

+ (id)timingFunctionWithControlPoints:(kmVec2)c0 :(kmVec2)c1
{
    return [[[[self class] alloc] initWithControlPoints:c0 :c1] autorelease];
}

- (id)initWithControlPoints:(kmVec2)c0 :(kmVec2)c1
{
    if ((self = [super init])) {
        _c0 = c0;
        _c1 = c1;
    }
    return self;
}

- (icTime)timeFactor:(icTime)x
{
    if (_c0.x == _c0.y && _c1.x == _c1.y) {
        return x; // linear
    }
    
    float t = icTForX(x, _c0, _c1);
    if (t < 0 || t > 1) {
        int brk = 1;
    }
    float y = icBezier(t, _c0.y, _c1.y);
    //NSLog(@"y: %f", y);
    return y;
}

@end
