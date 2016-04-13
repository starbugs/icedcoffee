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

#import "ICNode.h"
#import "ICProjectionTransforms.h"
#import "../3rd-party/kazmath/kazmath/kazmath.h"

/**
 @brief Base class for all planar nodes
 
 The ICPlanarNode class represents an abstract base class for all planar nodes (sprites, render
 textures, etc.) ICPlanarNode provides methods to calculate the node's plane based on a plane
 normal and a point on the plane. Furthermore it implements the ICProjectionTransforms protocol
 for transforming parent framebuffer and host view locations to local node locations via
 unprojection using the node's scene camera.
 
 ICPlanarNode defines a default node plane which faces the user interace camera (ICUICamera).
 Hence, the default plane normal is [0,0,1] and the default plane point is [0,0,0]. Subclasses
 may override ICPlanarNode::planeNormal and ICPlanarNode::planePoint in order to customize
 the plane.
 */
@interface ICPlanarNode : ICNode <ICProjectionTransforms>

#pragma mark - Retrieving Information about a Node's Plane
/** @name Retrieving Information about a Node's Plane */

/**
 @brief The normal of the receiver's plane
 */
- (kmVec3)planeNormal;

/**
 @brief A point on the receiver's plane
 */
- (kmVec3)planePoint;

/**
 @brief The receiver's plane in local coordinate space
 */
- (kmPlane)plane;

/**
 @brief The receiver's plane in world coordinate space
 */
- (kmPlane)worldPlane;


#pragma mark - Transforming Points to a Node's Coordinate Space
/** @name Transforming Points to a Node's Coordinate Space */

/**
 @brief Converts a location in the parent scene's framebuffer coordinate space to a location in
 the node's coordinate space

 @param location A CGPoint defining the location in the parent framebuffer's coordinate space
 in points; the Y axis points downwards.

 The method uses the node's plane to transform a location in the parent scene's framebuffer
 coordinate space to a location in the node's local coordinate space.
 */
- (kmVec3)parentFramebufferToNodeLocation:(CGPoint)location;

/**
 @brief Converts a location in the host view's coordinate space to a location in the node's
 coordinate space
 
 @param location A CGPoint defining the location in the host view's coordinate space
 in points; the Y axis points downwards.
 
 The method uses the node's plane to transform a location on the host view to a location in
 the node's local coordinate space. You may use it to transform mouse or touch locations
 received from the OS window system to appropriate locations within the node's space.
 */
- (kmVec3)hostViewToNodeLocation:(CGPoint)location;


#pragma mark - Getting the Node's Bounds
/** @name Getting the Node's Bounds */

// FIXME
/**
 @brief Returns the two-dimensional rectangular bounds of the receiver in local coordinate space
 
 Returns a ``CGRect`` defining the bounds of the receiver based on its ICNode::localAABB.
 */
- (CGRect)bounds;


#pragma mark - Performing Ray-based Hit Tests
/** @name Performing Ray-based Hit Tests */

/**
 @brief Performs a ray-based hit test on the receiver
 
 @param ray An icRay3 defining the ray to use for the hit test
 
 This method performs a ray-based hit test by calculating the intersection of the given ray
 with the receiver's ICPlanarNode::plane, then checking whether that intersection lies within
 the receiver's ICNode::bounds.
 
 @sa
 - ICNode::localRayHitTest:
 */
- (ICHitTestResult)localRayHitTest:(icRay3)ray;

@end
