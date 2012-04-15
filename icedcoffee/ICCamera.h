//  
//  Copyright (C) 2012 Tobias Lensing
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

#import "icMacros.h"

#ifdef __IC_PLATFORM_IOS
#import <CoreGraphics/CoreGraphics.h>
#elif __IC_PLATFORM_MAC
#import <QuartzCore/QuartzCore.h>
#endif

#import "Platforms/icGL.h"
#import "kazmath/kazmath.h"

/**
 @brief Camera base class providing standard 3D projection and model-view transforms
 
 <b>Overview</b>
 
 This class implements a basic camera performing OpenGL projection and model-view transforms
 based on a number of parameters specified by the user:
 
 <ul>
    <li><b><code>eye:</code></b> A 3D vector defining the position of the camera's eye</li>
    <li><b><code>lookAt:</code></b> A 3D vector defining the position of the point the camera
    should look at</li>
    <li><b><code>upVector:</code></b> A 3D vector defining the up direction</li>
    <li><b><code>fov:</code></b> The field of view angle of the camera, in degrees</li>
    <li><b><code>aspect:</code></b> The aspect ratio of the camera's frustum</li>
    <li><b><code>zNear:</code></b> The distance of the near plane to the camera's eye</li>
    <li><b><code>zFar:</code></b> The distance of the far plane to the camera's eye</li>
 </ul>
 
 For the settings to take effect, a camera must be applied to the OpenGL scene using the
 ICCamera::apply method. Cameras have a caching mechanism for their internal projection and
 look-at matrices. Whenever a parameter is changed, the look-at and/or projection matrices
 will be recalculated the next time ICCamera::apply is called.
 
 The ICScene class creates and manages a designated camera object for each scene by default.
 You should use this camera object instead of defining your own unless you really need to do so.
 
 <b>Subclassing</b>
 
 The ICCamera class may be used as a base class for specialized camera classes. If you add
 properties that may have an effect on the internal transform matrix calculations of ICCamera,
 you must call <code>setDirty:YES</code> in your property setter. You may also have to override
 the setupScreen method to implement custom transformation computation code.
 */
@interface ICCamera : NSObject
{
@protected
    kmVec3 _eye;
    kmVec3 _lookAt;
    kmVec3 _upVector;
    
    float _fov;
    float _aspect;
    float _zNear;
    float _zFar;
    
    kmMat4 _matProjection;
    kmMat4 _matLookAt;
    BOOL _dirty;
}

/**
 @brief The position of the camera's eye in world coordinates
 */
@property (nonatomic, assign, getter=eye, setter=setEye:) kmVec3 eye;

/**
 @brief The position of the camera's look-at point in world coordinates
 */
@property (nonatomic, assign, getter=lookAt, setter=setLookAt:) kmVec3 lookAt;

/**
 @brief The camera's up vector
 */
@property (nonatomic, assign, getter=upVector, setter=setUpVector:) kmVec3 upVector;

/**
 @brief The camera's field of view in degrees
 */
@property (nonatomic, assign) float fov;

/**
 @brief The camera's aspect ratio
 */
@property (nonatomic, assign) float aspect;

/**
 @brief The distance of the near clipping plane to the camera's eye
 */
@property (nonatomic, assign) float zNear;

/**
 @brief The distance of the far clipping plane to the camera's eye
 */
@property (nonatomic, assign) float zFar;

/**
 @brief The projection matrix of the camera
 */
@property (nonatomic, readonly) kmMat4 matProjection;

/**
 @brief The look-at matrix of the camera
 */
@property (nonatomic, readonly) kmMat4 matLookAt;

/**
 @brief A flag indicating whether the camera's projection and/or look-at matrices are outdated
 */
@property (nonatomic, assign) BOOL dirty;


/**
 @brief Convenience method returning an autoreleased ICCamera object
 */
+ (id)camera;

/**
 @brief Convenience method returning an autoreleased ICCamera object with the specified attributes
 */
+ (id)cameraWithEye:(kmVec3)eye
             lookAt:(kmVec3)lookAt
           upVector:(kmVec3)upVector
                fov:(float)fov
             aspect:(float)aspect
              zNear:(float)zNear
               zFar:(float)zFar;

/**
 @brief Initializes a default camera object
 */
- (id)init;

/**
 @brief Initializes a camera object with the given attributes
 */
- (id)initWithEye:(kmVec3)eye
           lookAt:(kmVec3)lookAt
         upVector:(kmVec3)upVector
              fov:(float)fov
           aspect:(float)aspect
            zNear:(float)zNear
             zFar:(float)zFar;

/**
 @brief Applies the camera's projection and look-at matrices to the projection and model-view
 matrix stacks
 
 The method first checks whether the camera's projection and/or look-at matrices are dirty and,
 if so, updates them by invoking ICCamera::setupScreen. Afterwards, the matrices are applied to the
 projection and model-view matrix stacks.
 */
- (void)apply;

/**
 @brief Sets up the camera's projection and look-at matrices
 */
- (void)setupScreen;

/**
 @brief Apply a pick matrix at the given point using the specified viewport
 
 @param point A location specified in points
 @param viewport The OpenGL viewport (in pixels) the pick matrix is applied on
 
 @remarks Converts the location expressed in points to pixels internally.
 */
- (void)applyPickMatrix:(CGPoint)point viewport:(GLint *)viewport;

/**
 @brief Unproject point in view coordinates to world coordinates using the camera's projection
 and look-at matrices
 */
- (BOOL)unprojectView:(kmVec3)viewVect toWorld:(kmVec3 *)resultVect viewport:(GLint *)viewport;

@end
