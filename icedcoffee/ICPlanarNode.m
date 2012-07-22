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

#import "ICPlanarNode.h"
#import "ICCamera.h"
#import "ICScene.h"
#import "ICRenderTexture.h"
#import "ICHostViewController.h"
#import "ICGLView.h"
#import "icTypes.h"
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

// Assumes that parentScene is the correct match for unprojection with the parent framebuffer
- (kmVec3)parentFramebufferToNodeLocation:(CGPoint)location
{
    ICScene *parentScene = [self parentScene];
    icRay3 worldRay = [parentScene worldRayFromFramebufferLocation:location];
    kmPlane p = [self worldPlane];
    kmVec3 worldIntersection, localIntersection;
    kmMat4 worldToNodeTransform = [self worldToNodeTransform];
    kmPlaneIntersectLine(&worldIntersection, &p, &worldRay.origin, &worldRay.direction);
    kmVec3Transform(&localIntersection, &worldIntersection, &worldToNodeTransform);
    localIntersection.x = roundf(localIntersection.x);
    localIntersection.y = roundf(localIntersection.y);
    
    return localIntersection;
}

- (kmVec3)hostViewToNodeLocation:(CGPoint)location
{
    NSArray *ancestors = [self ancestorsFilteredUsingBlock:
                          ^(ICNode *node, BOOL *stop) {
                              if ([node conformsToProtocol:@protocol(ICFramebufferProvider)] &&
                                  [node conformsToProtocol:@protocol(ICProjectionTransforms)]) {
                                  return YES;
                              }
                              return NO;
                          }];
    
    NSEnumerator *e = [ancestors reverseObjectEnumerator];
    ICNode<ICProjectionTransforms> *node = nil;
    while (node = [e nextObject]) {
        location = kmVec3ToCGPoint([node parentFramebufferToNodeLocation:location]);
    }
    
    location = kmVec3ToCGPoint([self parentFramebufferToNodeLocation:location]);
    
    return kmVec3Make(location.x, location.y, 0.0f);
}

- (ICHitTestResult)localRayHitTest:(icRay3)ray
{
    CGRect bounds = [self bounds];
    kmPlane p = [self plane];
    kmVec3 intersection;
    kmPlaneIntersectLine(&intersection, &p, &ray.origin, &ray.direction);
    return (intersection.x >= bounds.origin.x &&
            intersection.y >= bounds.origin.y &&
            intersection.x <= bounds.origin.x + bounds.size.width &&
            intersection.y <= bounds.origin.y + bounds.size.height) ? ICHitTestHit : ICHitTestFailed;
}

@end
