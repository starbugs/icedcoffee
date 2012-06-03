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

#import "ICNode.h"
#import "kazmath/kazmath.h"

/**
 @brief Base class for all planar nodes
 
 The ICPlanarNode class represents an abstract base class for all planar nodes (sprites, render
 textures, etc.) Subclasses should override the ICPlanarNode::plane method to return an
 appropriate plane.
 */
@interface ICPlanarNode : ICNode

/**
 @brief The normal of the node's plane
 */
- (kmVec3)planeNormal;

/**
 @brief A point on the node's plane
 */
- (kmVec3)planePoint;

/**
 @brief The node's plane in local coordinate space
 */
- (kmPlane)plane;

/**
 @brief The node's plane in world coordinate space
 */
- (kmPlane)worldPlane;

/**
 @brief Converts a location in the host view's coordinate space to a location in the node's
 coordinate space
 
 The method uses the node's plane to transform a location on the host view to a location in
 the node's local coordinate space. You may use it to transform mouse or touch locations
 received from the OS window system to appropriate locations within a the node's space.
 */
- (CGPoint)hostViewToNodeLocation:(CGPoint)hostViewLocation;

@end
