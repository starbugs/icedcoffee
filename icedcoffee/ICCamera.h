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

#import "icMacros.h"

#ifdef __IC_PLATFORM_IOS
#import <CoreGraphics/CoreGraphics.h>
#elif __IC_PLATFORM_MAC
#import <QuartzCore/QuartzCore.h>
#endif

#import "Platforms/icGL.h"
#import "../3rd-party/kazmath/include/kazmath/kazmath.h"

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
 
 <b>Setup</b>

 ICCamera should be initialized using the
 ICCamera::initWithEye:lookAt:upVector:fov:aspect:zNear:zFar:viewport: method. The ICScene
 class by default creates an ICUICamera camera object for you. If
 you need a different camera, instanciate your own ICCamera object and initialize ICScene
 using ICScene::initWithHostViewController:camera:.
 
 <b>Subclassing</b>
 
 The ICCamera class may be used as a base class for specialized camera classes. The designated
 initializer for ICCamera is ICCamera::initWithEye:lookAt:upVector:fov:aspect:zNear:zFar:viewport:
 for generic cameras or ICCamera::initWithViewport: for cameras setting up projection and look-at
 based on internal computations. The framework will always call ICCamera::initWithViewport: to
 initialize newly created cameras.
 
 If you add properties that may have an effect on the internal transform matrix calculations
 of ICCamera, you must call <code>setDirty:YES</code> in your property setter. You may also have
 to override the ICCamera::setUpScreen method to implement custom transformations.
 */
@interface ICCamera : NSObject
{
@protected
    GLint _viewport[4];
    
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
 @brief Convenience method returning an autoreleased ICCamera object with the given viewport
 */
+ (id)cameraWithViewport:(CGRect)viewport;

/**
 @brief Convenience method returning an autoreleased ICCamera object with the specified attributes
 */
+ (id)cameraWithEye:(kmVec3)eye
             lookAt:(kmVec3)lookAt
           upVector:(kmVec3)upVector
                fov:(float)fov
             aspect:(float)aspect
              zNear:(float)zNear
               zFar:(float)zFar
           viewport:(CGRect)viewport;

/**
 @brief Initializes a default camera object with the given viewport
 */
- (id)initWithViewport:(CGRect)viewport;

/**
 @brief Initializes a camera object with the given attributes
 */
- (id)initWithEye:(kmVec3)eye
           lookAt:(kmVec3)lookAt
         upVector:(kmVec3)upVector
              fov:(float)fov
           aspect:(float)aspect
            zNear:(float)zNear
             zFar:(float)zFar
         viewport:(CGRect)viewport;

/**
 @brief Sets the camera's viewport (viewport coordinates are in points)
 */
- (void)setViewport:(CGRect)viewport;

/**
 @brief Returns the camera's viewport (viewport coordinates are in points)
 */
- (CGRect)viewport;

/**
 @brief Applies the camera's projection and look-at matrices to the projection and model-view
 matrix stacks
 
 The method first checks whether the camera's projection and/or look-at matrices are dirty and,
 if so, updates them by invoking ICCamera::setUpScreen. Afterwards, the matrices are applied to the
 projection and model-view matrix stacks.
 */
- (void)apply;

/**
 @brief Sets up the camera's projection and look-at matrices
 
 @deprecated Deprecated as of v0.6.6. Use setUpScreen instead.
 */
- (void)setupScreen DEPRECATED_ATTRIBUTE /*v0.6.6*/;

/**
 @brief Sets up the camera's projection and look-at matrices
*/
- (void)setUpScreen;

/**
 @brief Apply a pick matrix at the given point in the specified viewport
 
 @param point A location specified in points
 @param viewport The OpenGL viewport (in pixels) the pick matrix is applied on
 
 @remarks Converts the location expressed in points to pixels internally.
 */
- (void)applyPickMatrix:(CGPoint)point viewport:(GLint *)viewport;

- (void)applyPickMatrixToFrame:(CGRect)pickFrame viewport:(GLint *)viewport;

/**
 @brief Unproject point in view coordinates to world coordinates using the camera's projection
 and look-at matrices
 
 @param viewVect A kmVec3 pointer referencing the point in the view's coordinate system (pixels)
 @param resultVect A kmVec3 pointer referencing the object receiving the resulting unprojected
 point in world coordinates

 @return Returns YES on success or NO otherwise. The resulting world vector is written into
 resultVect.
 
 @remarks View coordinates are to be understood as framebuffer coordinates in pixels.
 */
- (BOOL)unprojectView:(kmVec3)viewVect toWorld:(kmVec3 *)resultVect;

/**
 @brief Project the given vector in world coordinates to view coordinates using the camera's
 projection and look-at matrices
 
 @param worldVect A kmVec3 pointer referencing the point to project in world coordinates
 @param resultVect A kmVec3 pointer referencing the object receiving the resulting vector in
 view coordinates (pixels)
 
 @return Returns YES on success or NO otherwise. The resulting view vector is written into
 resultVect. Note that you may need to round its coordinates so as to compensate for limited
 floating point precision.
 
 @remarks View coordinates are to be understood as framebuffer coordinates in pixels.
 */
- (BOOL)projectWorld:(kmVec3)worldVect toView:(kmVec3 *)resultVect;

@end
