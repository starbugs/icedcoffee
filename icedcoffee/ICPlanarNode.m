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

#import "ICPlanarNode.h"
#import "ICCamera.h"
#import "ICScene.h"
#import "kazmath/vec4.h"

@implementation ICPlanarNode

- (kmVec3)planeNormal
{
    return (kmVec3){0,0,1};
}

- (kmVec3)planePoint
{
    return (kmVec3){0,0,0};
}

- (kmPlane)plane
{
    kmVec3 planeNormal = [self planeNormal];;
    kmVec3 planePoint = [self planePoint];
    
    kmPlane plane;
    kmPlaneFromPointNormal(&plane, &planePoint, &planeNormal);
    
    return plane;
}

- (kmPlane)worldPlane
{
    // http://stackoverflow.com/questions/7685495/transforming-a-3d-plane-by-4x4-matrix,
    // http://www.songho.ca/opengl/gl_normaltransform.html
    
    // TODO: extensive testing

    kmVec3 planeNormal = [self planeNormal];;
    kmVec3 planePoint = [self planePoint];
    kmMat4 nodeToWorldTransform = [self nodeToWorldTransform];
    kmMat4 inverseTransform, normalTransform;
    kmMat4Inverse(&inverseTransform, &nodeToWorldTransform);    
    kmMat4Transpose(&normalTransform, &inverseTransform);
    kmVec3Transform(&planeNormal, &planeNormal, &normalTransform);
    kmVec3Transform(&planePoint, &planePoint, &nodeToWorldTransform);
    kmVec3Normalize(&planeNormal, &planeNormal);
    
    kmPlane plane;
    kmPlaneFromPointNormal(&plane, &planePoint, &planeNormal);
    
    return plane;
}

- (CGPoint)hostViewToNodeLocation:(CGPoint)hostViewLocation
{
    kmVec3 projectPoint1, projectPoint2;
    kmVec3 unprojectPoint1, unprojectPoint2;
    projectPoint1 = (kmVec3){hostViewLocation.x, hostViewLocation.y, 0};
    projectPoint2 = (kmVec3){hostViewLocation.x, hostViewLocation.y, 1};
    
    // FIXME: check for points vs. pixels with retina display
    ICScene *parentScene = [self parentScene];
    [[parentScene camera] unprojectView:projectPoint1
                                toWorld:&unprojectPoint1];
    [[parentScene camera] unprojectView:projectPoint2
                                toWorld:&unprojectPoint2];
    
    kmPlane p = [self worldPlane];
    kmVec3 intersection, localIntersection;
    kmPlaneIntersectLine(&intersection, &p, &unprojectPoint1, &unprojectPoint2);
    kmMat4 worldToNodeTransform = [self worldToNodeTransform];
    localIntersection.x = floorf(localIntersection.x);
    localIntersection.y = floorf(localIntersection.y);
    kmVec3Transform(&localIntersection, &intersection, &worldToNodeTransform);
    
    return CGPointMake(localIntersection.x, localIntersection.y);
}

@end
