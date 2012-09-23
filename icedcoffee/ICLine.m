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

#import "ICLine.h"
#import "ICShaderProgram.h"
#import "ICShaderCache.h"

#define ICLINE_DEFAULT_LINE_WIDTH 1
#define ICLINE_DEFAULT_ANTIALIAS_STRENGTH 1.0f
#define ICLINE_DEFAULT_COLOR (icColor4B){0,0,0,255}
#define ICLINE_NUM_VERTICES 8
#define ICLINE_PROTOTYPE_VECT kmVec3Make(0,1,0)
#define ICLINE_PROTOTYPE_NORM kmVec3Make(1,0,0)

@implementation ICLine

@synthesize color = _color;
@synthesize origin = _origin;
@synthesize target = _target;
@synthesize lineWidth = _lineWidth;
@synthesize antialiasStrength = _antialiasStrength;

+ (id)line
{
    return [[[[self class] alloc] init] autorelease];
}

+ (id)lineWithOrigin:(kmVec3)origin target:(kmVec3)target lineWidth:(float)lineWidth
{
    return [[[[self class] alloc] initWithOrigin:origin target:target lineWidth:lineWidth] autorelease];
}

+ (id)lineWithOrigin:(kmVec3)origin
              target:(kmVec3)target
           lineWidth:(float)lineWidth
   antialiasStrength:(float)antialiasStrength
               color:(icColor4B)color
{
    return [[[[self class] alloc] initWithOrigin:origin
                                          target:target
                                       lineWidth:lineWidth
                               antialiasStrength:antialiasStrength
                                           color:color] autorelease];
}

- (id)init
{
    return [self initWithOrigin:kmVec3Make(0, 0, 0)
                         target:kmVec3Make(0, 1, 0)
                      lineWidth:ICLINE_DEFAULT_LINE_WIDTH
              antialiasStrength:ICLINE_DEFAULT_ANTIALIAS_STRENGTH
                          color:ICLINE_DEFAULT_COLOR];
}

- (id)initWithOrigin:(kmVec3)origin
              target:(kmVec3)target
           lineWidth:(float)lineWidth
{
    return [self initWithOrigin:origin
                         target:target
                      lineWidth:lineWidth
              antialiasStrength:ICLINE_DEFAULT_ANTIALIAS_STRENGTH
                          color:ICLINE_DEFAULT_COLOR];
}

- (id)initWithOrigin:(kmVec3)origin
              target:(kmVec3)target
           lineWidth:(float)lineWidth
   antialiasStrength:(float)antialiasStrength
               color:(icColor4B)color
{
    if ((self = [super init])) {
        self.origin = origin;
        self.target = target;
        self.lineWidth = lineWidth;
        self.antialiasStrength = antialiasStrength;
        self.color = color;
        self.shaderProgram = [[ICShaderCache currentShaderCache]
                              shaderProgramForKey:kICShader_PositionTextureColor];
    }
    return self;
}

- (void)dealloc
{
    if (_vertexBuffer)
        glDeleteBuffers(1, &_vertexBuffer);
    
    [super dealloc];
}

- (void)updateSize
{
    kmVec3 size;
    kmVec3Subtract(&size, &_target, &_origin);
    self.size = size;
}

- (void)setOrigin:(kmVec3)origin
{
    _origin = origin;
    self.position = origin;
    [self updateSize];
    _lineTransformDirty = YES;
}

- (void)setTarget:(kmVec3)target
{
    _target = target;
    [self updateSize];
    _lineTransformDirty = YES;
}

- (void)setLineWidth:(float)lineWidth
{
    _lineWidth = lineWidth;
    _lineVerticesDirty = YES;
}

- (void)setAntialiasStrength:(float)antialiasStrength
{
    _antialiasStrength = antialiasStrength;
    _lineVerticesDirty = YES;
}

- (void)setColor:(icColor4B)color
{
    _color = color;
    _lineVerticesDirty = YES;
}

- (void)updateLineVertices
{
    /*
          x1    x2          x3    x4
       y1  B+----D+----------F+----H+       x1 = 0
           |    /|         / |    /|        x2 = a
           |   / |       /   |   / |        x3 = a + w
           |1 / 2|  3  /  4  |5 / 6|        x4 = 2a + w
           | /   |   /       | /   |        y1 = 0
           |/    | /         |/    |        y2 = 1
       y2  A+----C+----------E+----G+
     */
    
    float hw = (2*_antialiasStrength + _lineWidth)/2;
    float x1 = -hw;
    float x2 = -hw + _antialiasStrength;
    float x3 = -hw +_antialiasStrength + _lineWidth;
    float x4 = -hw + 2*_antialiasStrength + _lineWidth;
    float y1 = 0;
    float y2 = 1;
    float z = 0;
    
    icV3F_C4F_T2F vertices[ICLINE_NUM_VERTICES];
    bzero(vertices, sizeof(icV3F_C4F_T2F) * ICLINE_NUM_VERTICES);
    
    // 01234567
    // BADCFEHG (ccw)
    vertices[0].vect = kmVec3Make(x1, y1, z);  // B
    vertices[1].vect = kmVec3Make(x1, y2, z);  // A
    vertices[2].vect = kmVec3Make(x2, y1, z);  // D
    vertices[3].vect = kmVec3Make(x2, y2, z);  // C
    vertices[4].vect = kmVec3Make(x3, y1, z);  // F
    vertices[5].vect = kmVec3Make(x3, y2, z);  // E
    vertices[6].vect = kmVec3Make(x4, y1, z);  // H
    vertices[7].vect = kmVec3Make(x4, y2, z);  // G
    
    icColor4F lineColor = color4FFromColor4B(_color);
    icColor4F overdrawColor = icColor4FMake(lineColor.r, lineColor.g, lineColor.b, 0);
    vertices[0].color = overdrawColor;
    vertices[1].color = overdrawColor;
    vertices[2].color = lineColor;
    vertices[3].color = lineColor;
    vertices[4].color = lineColor;
    vertices[5].color = lineColor;
    vertices[6].color = overdrawColor;
    vertices[7].color = overdrawColor;
    
    if (!_vertexBuffer)
        glGenBuffers(1, &_vertexBuffer);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(icV3F_C4F_T2F) * ICLINE_NUM_VERTICES, vertices, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);    
    IC_CHECK_GL_ERROR_DEBUG();
}

- (void)updateLineTransform
{
    kmVec3 t, x, p = ICLINE_PROTOTYPE_VECT, n = ICLINE_PROTOTYPE_NORM;
    kmVec3Subtract(&t, &_target, &_origin);
    float l = kmVec3Length(&t);
    kmVec3Normalize(&t, &t);
    
    // Calculate angle between p and t
    kmVec3Cross(&x, &p, &t);
    float s = kmVec3Length(&x);
    float c = kmVec3Dot(&p, &t);
    float d = kmVec3Dot(&n, &t);
    s = d < 0 ? s : -1*s;
    float theta = atan2(s, c);
    
    // Calculate transform matrix made up of rotation and scale
    kmMat4 matRotate, matScale;
    kmVec3 axis = kmVec3Make(0, 0, 1);
    kmMat4RotationAxisAngle(&matRotate, &axis, theta);
    kmMat4Scaling(&matScale, 1, l, 1);
//    _lineTransform = matRotate;
    kmMat4Multiply(&_lineTransform, &matRotate, &matScale);
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    if (_lineVerticesDirty) {
        [self updateLineVertices];
        _lineVerticesDirty = NO;
    }
    if (_lineTransformDirty) {
        [self updateLineTransform];
        _lineTransformDirty = NO;
    }
    
    kmGLPushMatrix();
    kmGLMultMatrix(&_lineTransform);
    
    [self applyStandardDrawSetupWithVisitor:visitor];
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glEnableVertexAttribArray(ICVertexAttribPosition);
    glEnableVertexAttribArray(ICVertexAttribColor);
    glEnableVertexAttribArray(ICVertexAttribTexCoords);
    IC_CHECK_GL_ERROR_DEBUG();
    
#define kVertexSize sizeof(icV3F_C4F_T2F)
    
	// vertex
	NSInteger diff = offsetof(icV3F_C4F_T2F, vect);
	glVertexAttribPointer(ICVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, kVertexSize, (void*)(diff));
    
	// color
	diff = offsetof(icV3F_C4F_T2F, color);
	glVertexAttribPointer(ICVertexAttribColor, 4, GL_FLOAT, GL_FALSE, kVertexSize, (void*)(diff));
    
	// texCoords
	diff = offsetof(icV3F_C4F_T2F, texCoords);
	glVertexAttribPointer(ICVertexAttribTexCoords, 2, GL_FLOAT, GL_FALSE, kVertexSize, (void*)(diff));
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, ICLINE_NUM_VERTICES);
    IC_CHECK_GL_ERROR_DEBUG();
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    kmGLPopMatrix();
}

@end
