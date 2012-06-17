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

#import "ICCamera.h"
#import "ICHostViewController.h"
#import "icGL.h"
#import "icUtils.h"

@implementation ICCamera

@synthesize eye = _eye;
@synthesize lookAt = _lookAt;
@synthesize upVector = _upVector;
@synthesize fov = _fov;
@synthesize aspect = _aspect;
@synthesize zNear = _zNear;
@synthesize zFar = _zFar;
@synthesize matProjection = _matProjection;
@synthesize matLookAt = _matLookAt;
@synthesize dirty = _dirty;

+ (id)cameraWithViewport:(CGRect)viewport
{
    return [[[[self class] alloc] initWithViewport:viewport] autorelease];
}

+ (id)cameraWithEye:(kmVec3)eye
             lookAt:(kmVec3)lookAt
           upVector:(kmVec3)upVector
                fov:(float)fov
             aspect:(float)aspect
              zNear:(float)zNear
               zFar:(float)zFar
           viewport:(CGRect)viewport
{
    return [[[[self class] alloc] initWithEye:eye
                                       lookAt:lookAt
                                     upVector:upVector
                                          fov:fov
                                       aspect:aspect
                                        zNear:zNear
                                         zFar:zFar
                                     viewport:viewport] autorelease];
}

- (id)init
{
    NSAssert(nil, @"ICCamera must be initialized using initWithViewport:");
    return nil;
}

- (id)initWithViewport:(CGRect)viewport
{
    kmVec3 eye, lookAt, upVector;
    kmVec3Fill(&eye, 0, 1, 0);
    kmVec3Fill(&lookAt, 0, 0, 0);
    kmVec3Fill(&upVector, 0, 1, 0);
    
    float w = viewport.size.width;
    float h = viewport.size.height;
    float aspect = w != 0 ? h / w : 0;
    
    return [self initWithEye:eye
                      lookAt:lookAt
                    upVector:upVector
                         fov:90.0f
                      aspect:aspect
                       zNear:0.1f
                        zFar:1500.0f
                    viewport:viewport];
}

- (id)initWithEye:(kmVec3)eye
           lookAt:(kmVec3)lookAt
         upVector:(kmVec3)upVector
              fov:(float)fov
           aspect:(float)aspect
            zNear:(float)zNear
             zFar:(float)zFar
         viewport:(CGRect)viewport
{
    if ((self = [super init])) {
        kmMat4Identity(&_matProjection);
        kmMat4Identity(&_matLookAt);

        [self setViewport:viewport];

        self.eye = eye;
        self.lookAt = lookAt;
        self.upVector = upVector;
        self.fov = fov;
        self.aspect = aspect;
        self.zNear = zNear;
        self.zFar = zFar;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


- (void)setViewport:(CGRect)viewport
{
    _viewport[0] = (GLint)viewport.origin.x * IC_CONTENT_SCALE_FACTOR();
    _viewport[1] = (GLint)viewport.origin.y * IC_CONTENT_SCALE_FACTOR();
    _viewport[2] = _viewport[0] + (GLint)viewport.size.width * IC_CONTENT_SCALE_FACTOR();
    _viewport[3] = _viewport[1] + (GLint)viewport.size.height * IC_CONTENT_SCALE_FACTOR();
    float w = _viewport[2] - _viewport[0];
    float h = _viewport[3] - _viewport[1];
    self.aspect = w != 0 ? h / w : 0;
    _dirty = YES;
}

- (CGRect)viewport
{
    return CGRectMake(_viewport[0] / IC_CONTENT_SCALE_FACTOR(),
                      _viewport[1] / IC_CONTENT_SCALE_FACTOR(),
                      (_viewport[2] - _viewport[0]) / IC_CONTENT_SCALE_FACTOR(),
                      (_viewport[3] - _viewport[1]) / IC_CONTENT_SCALE_FACTOR());
}

- (void)setEye:(kmVec3)eye
{
    _eye = eye;
    _dirty = YES;
}

- (void)setLookAt:(kmVec3)lookAt
{
    _lookAt = lookAt;
    _dirty = YES;
}

- (void)setUpVector:(kmVec3)upVector
{
    _upVector = upVector;
    _dirty = YES;
}

- (void)apply
{
    if(_dirty) {
        [self setupScreen];
        _dirty = NO;
    }

    kmGLMatrixMode(KM_GL_PROJECTION);
    kmGLLoadIdentity();
    kmGLMultMatrix(&_matProjection);
    
    kmGLMatrixMode(KM_GL_MODELVIEW);
    kmGLLoadIdentity();
    kmGLMultMatrix(&_matLookAt);
}

- (void)applyPickMatrix:(CGPoint)point viewport:(GLint *)viewport
{
    kmGLMatrixMode(KM_GL_PROJECTION);
    kmGLLoadIdentity();
    
    // Point is in points, fbo is in pixels
    point.x *= IC_CONTENT_SCALE_FACTOR();
    point.y *= IC_CONTENT_SCALE_FACTOR();

    icPickMatrix(point.x, point.y, 1, 1, viewport);

    if(_dirty) {
        [self setupScreen];
        _dirty = NO;
    }

    kmGLMultMatrix(&_matProjection);
    
    kmGLMatrixMode(KM_GL_MODELVIEW);
    kmGLLoadIdentity();
    kmGLMultMatrix(&_matLookAt);
}

- (void)applyPickMatrixToFrame:(CGRect)pickFrame viewport:(GLint *)viewport
{
    kmGLMatrixMode(KM_GL_PROJECTION);
    kmGLLoadIdentity();
    
    // Point is in points, fbo is in pixels
    pickFrame.origin.x *= IC_CONTENT_SCALE_FACTOR();
    pickFrame.origin.y *= IC_CONTENT_SCALE_FACTOR();
    pickFrame.size.width *= IC_CONTENT_SCALE_FACTOR();
    pickFrame.size.height *= IC_CONTENT_SCALE_FACTOR();
    
    icPickMatrix(pickFrame.origin.x, pickFrame.origin.y, pickFrame.size.width, pickFrame.size.height, viewport);
    
    if(_dirty) {
        [self setupScreen];
        _dirty = NO;
    }
    
    kmGLMultMatrix(&_matProjection);
    
    kmGLMatrixMode(KM_GL_MODELVIEW);
    kmGLLoadIdentity();
    kmGLMultMatrix(&_matLookAt);    
}

- (void)setupScreen
{
    kmMat4PerspectiveProjection(&_matProjection, _fov, _aspect, _zNear, _zFar);
    kmMat4LookAt(&_matLookAt, &_eye, &_lookAt, &_upVector);
}

- (BOOL)unprojectView:(kmVec3)viewVect toWorld:(kmVec3 *)resultVect
{
    if (_dirty) {
        [self setupScreen];
        _dirty = NO;
    }
    
    return icUnproject(&viewVect, resultVect, _viewport, &_matProjection, &_matLookAt);
}

- (BOOL)projectWorld:(kmVec3)worldVect toView:(kmVec3 *)resultVect
{
    if (_dirty) {
        [self setupScreen];
        _dirty = NO;
    }
    
    return icProject(&worldVect, resultVect, _viewport, &_matProjection, &_matLookAt);
}

@end
