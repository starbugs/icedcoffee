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

#import "ICUICamera.h"
#import "ICHostViewController.h"
#import "icGL.h"
#import "icTypes.h"
#import "icMacros.h"

@implementation ICUICamera

@synthesize zoomFactor = _zoomFactor;
@synthesize eyeOffset = _eyeOffset;
@synthesize lookAtOffset = _lookAtOffset;

- (id)initWithViewport:(CGRect)viewport
{
    if ((self = [super initWithViewport:viewport])) {
        self.zoomFactor = 1;
    }
    return self;
}

- (void)setViewport:(CGRect)viewport
{
    [super setViewport:viewport];
    
    float w = _viewport[2] - _viewport[0];
    float h = _viewport[3] - _viewport[1];
    self.aspect = w != 0 ? h / w : 0;
    _dirty = YES;
}

- (void)setUpScreen
{    
    float w = _viewport[2];
    float h = _viewport[3];
        
    float halfFov, theTan, screenFov, aspectRatio;
    screenFov 		= 60.0f;
    float eyeX 		= (float)w / 2.0;
    float eyeY 		= (float)h / 2.0;
    halfFov 		= M_PI * screenFov / 360.0;
    theTan 			= tanf(halfFov);
    float eyeZ 		= eyeY / theTan;
    float nearDist 	= eyeZ / 10.0;
    float farDist 	= eyeZ * 10.0;
    aspectRatio 	= (float)w/(float)h;
    
    kmVec3 eye, lookAt, upVector;
    
    kmVec3Fill(&eye, eyeX, eyeY, eyeZ);
    kmVec3Add(&eye, &eye, &_eyeOffset);
    kmVec3Fill(&lookAt, eyeX, eyeY, 0.0f);
    kmVec3Add(&lookAt, &lookAt, &_lookAtOffset);
    kmVec3Fill(&upVector, 0, 1, 0);
    
    self.eye = eye;
    self.lookAt = lookAt;
    self.upVector = upVector;
    
    self.fov = screenFov/self.zoomFactor;
    self.aspect = aspectRatio;
    self.zNear = nearDist;
    self.zFar = farDist;
    
    [super setUpScreen];
    
    // Flip the vertical axis of the projection
    kmMat4 matFlip;
    kmMat4Scaling(&matFlip, 1, -1, 1);
    kmMat4Multiply(&_matProjection, &_matProjection, &matFlip);
    
    // Scale the model-view matrix according to the device display's content scale factor;
    // this effectively makes camera coordinates screen coordinates in points
    kmMat4 matContentScale;
    kmMat4Scaling(&matContentScale,
                  ICContentScaleFactor(), 
                  ICContentScaleFactor(),
                  ICContentScaleFactor());
    kmMat4Multiply(&_matLookAt, &_matLookAt, &matContentScale);
}

- (float)zoomFactor
{
    return _zoomFactor;
}

- (void)setZoomFactor:(float)zoomFactor
{
    _zoomFactor = zoomFactor;
    self.dirty = YES;
}

- (kmVec3)eyeOffset
{
    return _eyeOffset;
}

- (void)setEyeOffset:(kmVec3)offset
{
    _eyeOffset = offset;
    self.dirty = YES;
}

- (kmVec3)lookAtOffset
{
    return _lookAtOffset;
}

- (void)setLookAtOffset:(kmVec3)offset
{
    _lookAtOffset = offset;
    self.dirty = YES;
}

@end
