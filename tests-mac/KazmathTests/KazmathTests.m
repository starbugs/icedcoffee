//  
//  Copyright (C) 2012 Tobias Lensing, http://icedcoffee-framework.org
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

#import "KazmathTests.h"
#import "kazmath/kazmath.h"

@implementation KazmathTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testPlaneLineIntersectionParallel
{
    kmPlane p;
    p.a = 0;
    p.b = 1;
    p.c = 0;
    p.d = 0;
    
    kmVec3 v1;
    v1.x = 0;
    v1.y = 0;
    v1.z = 0;
    
    kmVec3 v2;
    v2.x = 1;
    v2.y = 0;
    v2.z = 0;
    
    kmVec3 intersection;
    STAssertFalse((BOOL)kmPlaneIntersectLine(&intersection, &p, &v1, &v2),
                  @"Line parallel, no intersection");
}

- (void)testPlaneLineIntersection
{
    kmVec3 p1 = (kmVec3){0,2,0};
    kmVec3 p2 = (kmVec3){1,2,0};
    kmVec3 p3 = (kmVec3){1,2,1};
    
    kmPlane p;
    kmPlaneFromPoints(&p, &p1, &p2, &p3);
    
    kmVec3 v1;
    v1.x = 0;
    v1.y = -1;
    v1.z = 0;
    
    kmVec3 v2;
    v2.x = 0;
    v2.y = 1;
    v2.z = 0;
    
    kmVec3 intersection;
    kmVec3 *result = kmPlaneIntersectLine(&intersection, &p, &v1, &v2);
    if (!result)
        STFail(@"Line did not intersect");
    
    if (intersection.x != 0 || intersection.y != 2 || intersection.z != 0)
        STFail(@"Intersection should equal (0,2,0), but is (%f,%f,%f)",
               intersection.x, intersection.y, intersection.z);
    
    NSLog(@"Line interesected at (%f,%f,%f)", intersection.x, intersection.y, intersection.z);
}

@end
