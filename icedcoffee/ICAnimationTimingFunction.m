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

// Some values taken from
// http://blog.greweb.fr/2012/02/bezier-curve-based-easing-functions-from-concept-to-implementation/

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

- (icTime)timeFactor:(icTime)t
{
    // Adapted from http://devmag.org.za/2011/04/05/bzier-curves-a-tutorial/
    
    kmVec2 p0 = kmVec2Make(0, 0);
    kmVec2 p1 = kmVec2Make(1, 1);
    
    float u = 1 - t;
    float tt = t*t;
    float uu = u*u;
    float uuu = uu * u;
    float ttt = tt * t;
    
    kmVec2 m, n, o, p;
    kmVec2Scale(&p, &p0, uuu);
    kmVec2Scale(&m, &_c0, 3 * uu * t);
    kmVec2Add(&p, &p, &m);
    kmVec2Scale(&n, &_c1, 3 * u * tt);
    kmVec2Add(&p, &p, &n);
    kmVec2Scale(&o, &p1, ttt);
    kmVec2Add(&p, &p, &o);

    //NSLog(@"t: %f tf:%f", t, p.y);

    return p.y;
}

@end
