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

#import "ICSprite.h"
#import "ICShaderProgram.h"
#import "ICShaderCache.h"
#import "icMacros.h"
#import "ICNodeVisitorPicking.h"
#import "icGLState.h"
#import "icUtils.h"


#define NUM_VERTICES 4


@interface ICSprite (Private)
- (void)setDefaultTexCoords;
@end

@implementation ICSprite

@synthesize color = _color;
@synthesize texture = _texture;
@synthesize maskTexture = _maskTexture;
@synthesize blendFunc = _blendFunc;

+ (id)sprite
{
    return [[[[self class] alloc] init] autorelease];
}

+ (id)spriteWithTexture:(ICTexture2D *)texture
{
    return [[[[self class] alloc] initWithTexture:texture] autorelease];
}

- (id)init
{
    return [self initWithTexture:nil];
}

- (id)initWithTexture:(ICTexture2D *)texture
{
    if ((self = [super init])) {
        [self setDefaultTexCoords];
        [self setColor:(icColor4B){255,255,255,255}];
        self.texture = texture;
		[self setBlendFunc:(icBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];
    }
    return self;    
}

- (void)dealloc
{
    ICLogDealloc(@"Deallocing ICSprite");
    
    if (_vertexBuffer)
        glDeleteBuffers(1, &_vertexBuffer);    
    
    self.texture = nil;
    
    [super dealloc];
}

- (void)setDefaultTexCoords
{
    _texCoords[0] = kmVec2Make(0, 1);
    _texCoords[1] = kmVec2Make(1, 1);
    _texCoords[2] = kmVec2Make(0, 0);
    _texCoords[3] = kmVec2Make(1, 0);    
}

- (void)updateQuadPositionsWithVertices:(icV3F_C4F_T2F *)vertices
{
    float x1 = 0.0f;
    float x2 = _size.x;
    float y1 = 0.0f;
    float y2 = _size.y;
    
    // Note: Y-axis inverted by icedcoffee UI camera, so we need to do this in CCW order
    kmVec3Fill(&vertices[0].vect, x1, y2, 0);
    kmVec3Fill(&vertices[1].vect, x2, y2, 0);
    kmVec3Fill(&vertices[2].vect, x1, y1, 0);
    kmVec3Fill(&vertices[3].vect, x2, y1, 0);
}

- (void)updateQuadTexCoordsWithVertices:(icV3F_C4F_T2F *)vertices
{
    // .. and flip the texture coordinates vertically
    kmVec2Fill(&vertices[0].texCoords, _texCoords[0].x, _texCoords[0].y);
    kmVec2Fill(&vertices[1].texCoords, _texCoords[1].x, _texCoords[1].y);
    kmVec2Fill(&vertices[2].texCoords, _texCoords[2].x, _texCoords[2].y);
    kmVec2Fill(&vertices[3].texCoords, _texCoords[3].x, _texCoords[3].y);
}

- (void)updateQuadColorsWithVertices:(icV3F_C4F_T2F *)vertices
{
    vertices[0].color = color4FFromColor4B(_color);
    vertices[1].color = color4FFromColor4B(_color);
    vertices[2].color = color4FFromColor4B(_color);
    vertices[3].color = color4FFromColor4B(_color);
}

- (void)updateQuad
{
    icV3F_C4F_T2F vertices[NUM_VERTICES];    

    [self updateQuadPositionsWithVertices:vertices];
    [self updateQuadTexCoordsWithVertices:vertices];
    [self updateQuadColorsWithVertices:vertices];
    
    if (!_vertexBuffer)
        glGenBuffers(1, &_vertexBuffer);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(icV3F_C4F_T2F) * NUM_VERTICES, vertices, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);    
}

- (icColor4B)color
{
    return _color;
}

- (void)setColor:(icColor4B)color
{
    _color = color;
    [self updateQuad];
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    [self applyStandardDrawSetupWithVisitor:visitor];
    
    // Set texture (unless we're in picking mode)
    if (_texture && ![visitor isKindOfClass:[ICNodeVisitorPicking class]]) {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, [_texture name]);
        if (_maskTexture) {
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D, [_maskTexture name]);
        }
        IC_CHECK_GL_ERROR_DEBUG();
    }
    
    // FIXME: support for textured picking?
    if ([visitor isKindOfClass:[ICNodeVisitorPicking class]]) {
        icGLDisable(GL_BLEND);
    } else {
        icGLBlendFunc(_blendFunc.src, _blendFunc.dst);
        icGLEnable(IC_GL_BLEND);
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);

    // FIXME: needs to go into icGLState
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
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    IC_CHECK_GL_ERROR_DEBUG();

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    if (_maskTexture) {
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    IC_CHECK_GL_ERROR_DEBUG();
}

- (void)setTexture:(ICTexture2D *)texture
{
    [_texture release];
    _texture = [texture retain];

    CGSize displaySize = [texture displayContentSize];
    [self setSize:(kmVec3){displaySize.width, displaySize.height, 0}];
        
    NSString *shaderKey = texture ? kICShader_PositionTextureColor : kICShader_PositionColor;
    self.shaderProgram = [[ICShaderCache currentShaderCache]
                          shaderProgramForKey:shaderKey];
}

- (void)setMaskTexture:(ICTexture2D *)maskTexture
{
    [_maskTexture release];
    _maskTexture = [maskTexture retain];
    
    if (_maskTexture) {
        self.shaderProgram = [[ICShaderCache currentShaderCache]
                              shaderProgramForKey:kICShader_SpriteTextureMask];
    } else {
        self.shaderProgram = [[ICShaderCache currentShaderCache]
                              shaderProgramForKey:kICShader_PositionTextureColor];
    }
}

- (void)setSize:(kmVec3)size
{
    if (_size.x != size.x || _size.y != size.y || _size.z != size.z) {
        [super setSize:size];
        [self updateQuad];
    }
}

- (void)flipTextureHorizontally
{
    float min = 1.0f, max = 0.0f;
    int i=0;
    for(; i<NUM_VERTICES; i++) {
        if(_texCoords[i].x < min)
            min = _texCoords[i].x;
        if(_texCoords[i].x > max)
            max = _texCoords[i].x;
    }
    for(i=0; i<NUM_VERTICES; i++) {
        _texCoords[i].x = (_texCoords[i].x == min) ? max : min; 
    }
    [self updateQuad];
}

- (void)flipTextureVertically
{
    float min = 1.0f, max = 0.0f;
    int i=0;
    for(; i<NUM_VERTICES; i++) {
        if(_texCoords[i].y < min)
            min = _texCoords[i].y;
        if(_texCoords[i].y > max)
            max = _texCoords[i].y;
    }
    for(i=0; i<NUM_VERTICES; i++) {
        _texCoords[i].y = (_texCoords[i].y == min) ? max : min; 
    }
    [self updateQuad];
}

- (void)rotateTextureCW
{
    kmVec2 oldTexCoords[4];
    memcpy(oldTexCoords, _texCoords, sizeof(kmVec2)*NUM_VERTICES);
    _texCoords[1] = oldTexCoords[0];
    _texCoords[3] = oldTexCoords[1];
    _texCoords[0] = oldTexCoords[2];
    _texCoords[2] = oldTexCoords[3];
    [self updateQuad];
}

- (void)rotateTextureCCW
{
    kmVec2 oldTexCoords[4];
    memcpy(oldTexCoords, _texCoords, sizeof(kmVec2)*NUM_VERTICES);
    _texCoords[0] = oldTexCoords[1];
    _texCoords[1] = oldTexCoords[3];
    _texCoords[2] = oldTexCoords[0];
    _texCoords[3] = oldTexCoords[2];
    [self updateQuad];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

@end
