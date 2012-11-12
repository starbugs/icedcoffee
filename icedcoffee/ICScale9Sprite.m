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

#import "ICScale9Sprite.h"
#import "ICTexture2D.h"
#import "ICNodeVisitorPicking.h"

@interface ICScale9Sprite (Private)
- (void)updateMultiQuad;
@end

@implementation ICScale9Sprite

@synthesize scale9Rect = _scale9Rect;

+ (id)spriteWithTexture:(ICTexture2D *)texture scale9Rect:(CGRect)scale9Rect
{
    return [[[[self class] alloc] initWithTexture:texture scale9Rect:scale9Rect] autorelease];
}

- (id)init
{
    return [self initWithTexture:nil scale9Rect:CGRectNull];
}

- (id)initWithTexture:(ICTexture2D *)texture
{
    return [self initWithTexture:texture scale9Rect:CGRectNull];
}

- (id)initWithTexture:(ICTexture2D *)texture scale9Rect:(CGRect)scale9Rect
{
    if ((self = [super initWithTexture:texture])) {
        [self setScale9Rect:scale9Rect];
    }
    return self;
}

- (void)dealloc
{
    if (_scale9VertexBuffer)
        glDeleteBuffers(1, &_scale9VertexBuffer);
    if (_indexBuffer)
        glDeleteBuffers(1, &_indexBuffer);
    
    [super dealloc];
}

#define NUM_VERTICES 16
#define NUM_INDICES 54      // 9*2*3

- (void)updateMultiQuad
{
    if (_size.x == 0 && _size.y == 0)
        return;
    if (_scale9Rect.origin.x == 0 && _scale9Rect.origin.y == 0 &&
        _scale9Rect.size.width == 0 && _scale9Rect.size.height == 0)
        return;
    
    /*
     x1      x2               x3      x4
     y1  0+------2+---------------8+-----10+            Scale9 grid consisting of 16 vertices,
          |   0   |       3        |   6   |            9 quads (or 18 triangles).
     y2  1+------3+---------------9+-----11+
          |       |                |       |            
          |   1   |       4        |   7   |            
          |       |                |       |            
          |       |                |       |            
     y3  4+------6+--------------12+-----14+
          |   2   |       5        |   8   |
     y4  5+------7+--------------13+-----15+
     */
    
    icV3F_C4F_T2F vertices[NUM_VERTICES];
    
    CGSize textureDisplaySize = [_texture displayContentSize];
    
    float x1 = 0;
    float y1 = 0;
    float x2 = _scale9Rect.origin.x;
    float y2 = _scale9Rect.origin.y;
    float x3 = _size.x - (textureDisplaySize.width - _scale9Rect.origin.x - _scale9Rect.size.width);
    float y3 = _size.y - (textureDisplaySize.height - _scale9Rect.origin.y - _scale9Rect.size.height);
    float x4 = _size.x;
    float y4 = _size.y;
    float z = 0;
    
    // icedcoffee's UI camera inverts the Y axis, so the texture must be flipped vertically
    float tx4 = 0;
    float ty4 = 1.0f;
    float tx3 = _scale9Rect.origin.x / textureDisplaySize.width;
    float ty3 = (_scale9Rect.origin.y + _scale9Rect.size.height) / textureDisplaySize.height;
    float tx2 = (_scale9Rect.origin.x + _scale9Rect.size.width) / textureDisplaySize.width;
    float ty2 = _scale9Rect.origin.y / textureDisplaySize.height;
    float tx1 = 1.0f;
    float ty1 = 0.0f;
    
    vertices[ 0].vect = (kmVec3){x1, y1, z};
    vertices[ 1].vect = (kmVec3){x1, y2, z};
    vertices[ 2].vect = (kmVec3){x2, y1, z};
    vertices[ 3].vect = (kmVec3){x2, y2, z};
    
    vertices[ 4].vect = (kmVec3){x1, y3, z};
    vertices[ 5].vect = (kmVec3){x1, y4, z};
    vertices[ 6].vect = (kmVec3){x2, y3, z};
    vertices[ 7].vect = (kmVec3){x2, y4, z};
    
    vertices[ 8].vect = (kmVec3){x3, y1, z};
    vertices[ 9].vect = (kmVec3){x3, y2, z};
    vertices[10].vect = (kmVec3){x4, y1, z};
    vertices[11].vect = (kmVec3){x4, y2, z};

    vertices[12].vect = (kmVec3){x3, y3, z};
    vertices[13].vect = (kmVec3){x3, y4, z};
    vertices[14].vect = (kmVec3){x4, y3, z};
    vertices[15].vect = (kmVec3){x4, y4, z};
    
    vertices[ 0].texCoords = (kmVec2){tx1, ty1};
    vertices[ 1].texCoords = (kmVec2){tx1, ty2};
    vertices[ 2].texCoords = (kmVec2){tx2, ty1};
    vertices[ 3].texCoords = (kmVec2){tx2, ty2};

    vertices[ 4].texCoords = (kmVec2){tx1, ty3};
    vertices[ 5].texCoords = (kmVec2){tx1, ty4};
    vertices[ 6].texCoords = (kmVec2){tx2, ty3};
    vertices[ 7].texCoords = (kmVec2){tx2, ty4};

    vertices[ 8].texCoords = (kmVec2){tx3, ty1};
    vertices[ 9].texCoords = (kmVec2){tx3, ty2};
    vertices[10].texCoords = (kmVec2){tx4, ty1};
    vertices[11].texCoords = (kmVec2){tx4, ty2};

    vertices[12].texCoords = (kmVec2){tx3, ty3};
    vertices[13].texCoords = (kmVec2){tx3, ty4};
    vertices[14].texCoords = (kmVec2){tx4, ty3};
    vertices[15].texCoords = (kmVec2){tx4, ty4};
    
    for (int i=0; i<NUM_VERTICES; i++) {
        vertices[i].color = color4FFromColor4B(_color);
    }
    
    // Note: as the Y axis is inverted by the IcedCoffe UI camera, we provide CCW indices
    // here so that OpenGL standard culling continues to work correctly
    GLushort indices[] = {
        // left-top (x1,y1,x2,y2)
        1, 2, 0,
        3, 2, 1,
        
        // left-middle (x1,y2,x2,y3)
        4, 3, 1,
        6, 3, 4,
        
        // left-bottom (x1,y3,x2,y4)
        5, 6, 4,
        7, 6, 5,
        
        // middle-top (x2,y1,x3,y1)
        3, 8, 2,
        9, 8, 3,
        
        // middle-middle (x2,y2,x3,y3)
        6, 9, 3,
        12, 9, 6,
        
        // middle-bottom (x2,y3,x3,y4)
        7, 12, 6,
        13, 12, 7,
        
        // right-top (x3,y1,x4,y2)
        9, 10, 8,
        11, 10, 9,
        
        // right-middle (x3,y2,x4,y3)
        12, 11, 9,
        14, 11, 12,
        
        // right-bottom (x3,y3,x4,y4)
        13, 14, 12,
        15, 14, 13
    };
    
    if (_scale9VertexBuffer)
        glDeleteBuffers(1, &_scale9VertexBuffer);
    if (_indexBuffer)
        glDeleteBuffers(1, &_indexBuffer);
    
    glGenBuffers(1, &_scale9VertexBuffer);
    glGenBuffers(1, &_indexBuffer);
    
    glBindBuffer(GL_ARRAY_BUFFER, _scale9VertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(icV3F_C4F_T2F) * NUM_VERTICES, vertices, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort) * NUM_INDICES, indices, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

- (void)setScale9Rect:(CGRect)scale9Rect
{
    _scale9Rect = scale9Rect;
    [self updateMultiQuad];
}

- (void)setColor:(icColor4B)color
{
    [super setColor:color];
    [self updateMultiQuad];
}

- (void)setSize:(kmVec3)size
{
    [super setSize:size];
    [self updateMultiQuad];
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    if ([visitor isKindOfClass:[ICNodeVisitorPicking class]] ||
        (_scale9Rect.origin.x == 0 && _scale9Rect.origin.y == 0 &&
        _scale9Rect.size.width == 0 && _scale9Rect.size.height == 0)) {
        // Optimization/fallback: use ICSprite's drawWithVisitor: implementation for picking.
        // If scale9 rect equals a null rect, just use ICSprite's implementation always (fallback).
        [super drawWithVisitor:visitor];
        return;
    }

    if (!self.isVisible)
        return;
    
    [self applyStandardDrawSetupWithVisitor:visitor];
    
    if (![visitor isKindOfClass:[ICNodeVisitorPicking class]] && _texture)
        glBindTexture(GL_TEXTURE_2D, [_texture name]);
    
    // FIXME: support for textured picking?
    if ([visitor isKindOfClass:[ICNodeVisitorPicking class]]) {
        icGLDisable(GL_BLEND);
    } else {
        icGLBlendFunc(_blendFunc.src, _blendFunc.dst);
        icGLEnable(IC_GL_BLEND);
    }    
    
    // FIXME: needs to go into icGLState
    glEnableVertexAttribArray(ICVertexAttribPosition);
    glEnableVertexAttribArray(ICVertexAttribColor);
    glEnableVertexAttribArray(ICVertexAttribTexCoords);
    IC_CHECK_GL_ERROR_DEBUG();

    glBindBuffer(GL_ARRAY_BUFFER, _scale9VertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);

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
    
	glDrawElements(GL_TRIANGLES, NUM_INDICES, GL_UNSIGNED_SHORT, NULL);
    IC_CHECK_GL_ERROR_DEBUG();
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    IC_CHECK_GL_ERROR_DEBUG();
}

@end
