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

#import "ICCamera.h"
#import "../3rd-party/kazmath/kazmath/kazmath.h"

/**
 @brief Camara mapping world coordinates in points to framebuffer coordinates in pixels
 
 The ICUICamera class provides a world coordinate system in points
 and maps these point locations to framebuffer pixels using a non-orthogonal 3D projection
 matrix. The world coordinate system is designed to reflect the framebuffers's coordinate
 system, that is, the X-axis is the horizontal framebuffer axis, the Y-axis is the vertical
 framebuffer axis and the Z-axis is used to represent screen depth. By default, the origin
 of the camera's coordinate system is the lower left corner of the target framebuffer, so
 the XY-plane of the camera maps point coordinates to pixel coordinates.
 
 For standard resolution displays, the camera will effectively map model-view coordinates
 to framebuffer pixel coordinates. For example, specifying a sprite with position (0,0,0)
 and content size (200,200,0) will result in the sprite covering a quadratic region of
 200 pixels at position (0,0) of the framebuffer.
 
 For high resolution displays, the pixel coordinate system differs from the point coordinate
 system. On iOS devices supporting the retina display, a special content scale factor is
 defined, which is used to internally scale the point coordinate system to the right pixel
 positions of the framebuffer. See ICHostViewController::enableRetinaDisplaySupport: for details. 
 */
@interface ICUICamera : ICCamera
{
@private
    float _zoomFactor;
    kmVec3 _eyeOffset;
    kmVec3 _lookAtOffset;
}

/**
 @brief A zoom factor applied to the camera's projection
 
 The camera internally divides ICCamera::fov by zoomFactor in ICCamera::setUpScreen.
 */
@property (nonatomic, assign) float zoomFactor;

/**
 @brief An offset vector applied on the camera's ICCamera::eye
 */
@property (nonatomic, assign, getter=eyeOffset, setter=setEyeOffset:) kmVec3 eyeOffset;

/**
 @brief An offset vector applied on the camera's ICCamera::lookAt
 */
@property (nonatomic, assign, getter=lookAtOffset, setter=setLookAtOffset:) kmVec3 lookAtOffset;

- (id)initWithViewport:(CGRect)viewport;

@end
