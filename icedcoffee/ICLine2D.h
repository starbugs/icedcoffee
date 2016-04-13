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

#import "ICPlanarNode.h"

// FIXME: uses textured vertices with PositionColor shader
@interface ICLine2D : ICPlanarNode {
@protected
    icColor4B   _color;
    GLuint      _vertexBuffer;
    kmVec3      _lineOrigin;
    kmVec3      _lineTarget;
    float       _lineWidth;
    float       _antialiasStrength;
    kmMat4      _lineTransform;
    BOOL        _lineTransformDirty;
    BOOL        _lineVerticesDirty;
}

@property (nonatomic, assign) icColor4B color;

@property (nonatomic, assign, setter=setLineOrigin:) kmVec3 lineOrigin;

@property (nonatomic, assign, setter=setLineTarget:) kmVec3 lineTarget;

@property (nonatomic, assign, setter=setLineWidth:) float lineWidth;

@property (nonatomic, assign, setter=setAntialiasStrength:) float antialiasStrength;

+ (id)line;

+ (id)lineWithOrigin:(kmVec3)origin
              target:(kmVec3)target
           lineWidth:(float)lineWidth;

+ (id)lineWithOrigin:(kmVec3)origin
              target:(kmVec3)target
           lineWidth:(float)lineWidth
   antialiasStrength:(float)antialiasStrength
               color:(icColor4B)color;

- (id)init;

- (id)initWithOrigin:(kmVec3)origin
              target:(kmVec3)target
           lineWidth:(float)lineWidth;

- (id)initWithOrigin:(kmVec3)origin
              target:(kmVec3)target
           lineWidth:(float)lineWidth
   antialiasStrength:(float)antialiasStrength
               color:(icColor4B)color;

@end
