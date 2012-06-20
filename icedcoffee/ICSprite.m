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

#import "ICSprite.h"
#import "ICShaderProgram.h"
#import "ICShaderCache.h"
#import "icMacros.h"
#import "ICNodeVisitorPicking.h"
#import "icGLState.h"

@interface ICSprite (Private)
- (void)resetQuad;
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
        [self resetQuad];
        [self setColor:(icColor4B){255,255,255,255}];
        self.texture = texture;
		[self setBlendFunc:(icBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];
    }
    return self;    
}

- (void)dealloc
{
    ICLOG_DEALLOC(@"Deallocing ICSprite");
    self.texture = nil;
    
    [super dealloc];
}

- (void)resetQuad
{
    bzero(&_quad, sizeof(icQuad));
    
    float x1 = 0.0f;
    float x2 = 1.0f;
    float y1 = 0.0f;
    float y2 = 1.0f;
    
    // Note: Y-axis inverted by IcedCoffe UI camera, so we need to do this in CCW order
    kmVec3Fill(&_quad.tl.vect, x1, y1, 0);
    kmVec3Fill(&_quad.tr.vect, x2, y1, 0);
    kmVec3Fill(&_quad.bl.vect, x1, y2, 0);
    kmVec3Fill(&_quad.br.vect, x2, y2, 0);
    
    // .. and flip the texture coordinates vertically
    kmVec2Fill(&_quad.tl.texCoords, 0, 1);
    kmVec2Fill(&_quad.tr.texCoords, 1, 1);
    kmVec2Fill(&_quad.bl.texCoords, 0, 0);
    kmVec2Fill(&_quad.br.texCoords, 1, 0);
}

- (icColor4B)color
{
    return _color;
}

- (void)setColor:(icColor4B)color
{
    _color = color;
    _quad.tl.color = _color;
    _quad.tr.color = _color;
    _quad.bl.color = _color;
    _quad.br.color = _color;    
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    if (!self.isVisible)
        return;
    
    [self applyStandardDrawSetupWithVisitor:visitor];
    
    // Set texture (unless we're in picking mode)
    if (_texture && visitor.visitorType != kICPickingNodeVisitor) {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, [_texture name]);
        if (_maskTexture) {
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D, [_maskTexture name]);
        }
        CHECK_GL_ERROR_DEBUG();
    }
    
    // FIXME: support for textured picking?
    if (visitor.visitorType == kICPickingNodeVisitor) {
        icGLDisable(GL_BLEND);
    } else {
        icGLBlendFunc(_blendFunc.src, _blendFunc.dst);
        icGLEnable(IC_GL_BLEND);
    }
    
    // FIXME: needs to go into icGLState
    glEnableVertexAttribArray(kICVertexAttrib_Position);
    glEnableVertexAttribArray(kICVertexAttrib_Color);
    glEnableVertexAttribArray(kICVertexAttrib_TexCoords);
    CHECK_GL_ERROR_DEBUG();
    
#define kQuadSize sizeof(_quad.bl)    
    long offset = (long)&_quad;
    
	// vertex
	NSInteger diff = offsetof(icV3F_C4B_T2F, vect);
	glVertexAttribPointer(kICVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
    
	// color
	diff = offsetof(icV3F_C4B_T2F, color);
	glVertexAttribPointer(kICVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
    
	// texCoords
	diff = offsetof(icV3F_C4B_T2F, texCoords);
	glVertexAttribPointer(kICVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
            
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    CHECK_GL_ERROR_DEBUG();

    if (_maskTexture) {
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    CHECK_GL_ERROR_DEBUG();
}

- (void)setTexture:(ICTexture2D *)texture
{
    [_texture release];
    _texture = [texture retain];

    [self setSize:(kmVec3){[texture size].width, [texture size].height, 0}];
        
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
    [self setQuadSize:CGSizeMake(size.x, size.y)];
    [super setSize:size];
}

- (void)setQuadSize:(CGSize)size
{
    float x1 = 0.0f;
    float x2 = size.width;
    float y1 = 0.0f;
    float y2 = size.height;
    
    kmVec3Fill(&_quad.bl.vect, x1, y1, 0);
    kmVec3Fill(&_quad.br.vect, x2, y1, 0);
    kmVec3Fill(&_quad.tl.vect, x1, y2, 0);
    kmVec3Fill(&_quad.tr.vect, x2, y2, 0);    
}

- (void)flipTextureHorizontally
{
    float min = 1.0f, max = 0.0f;
    icV3F_C4B_T2F *vertices = (icV3F_C4B_T2F *)&_quad;
    int i=0;
    for(; i<4; i++) {
        if(vertices[i].texCoords.x < min)
            min = vertices[i].texCoords.x;
        if(vertices[i].texCoords.x > max)
            max = vertices[i].texCoords.x;
    }
    _quad.tl.texCoords.x = (_quad.tl.texCoords.x == min) ? max : min; 
    _quad.tr.texCoords.x = (_quad.tr.texCoords.x == min) ? max : min; 
    _quad.bl.texCoords.x = (_quad.bl.texCoords.x == min) ? max : min; 
    _quad.br.texCoords.x = (_quad.br.texCoords.x == min) ? max : min; 
}

- (void)flipTextureVertically
{
    float min = 1.0f, max = 0.0f;
    icV3F_C4B_T2F *vertices = (icV3F_C4B_T2F *)&_quad;
    int i=0;
    for(; i<4; i++) {
        if(vertices[i].texCoords.y < min)
            min = vertices[i].texCoords.y;
        if(vertices[i].texCoords.y > max)
            max = vertices[i].texCoords.y;
    }
    _quad.tl.texCoords.y = (_quad.tl.texCoords.y == min) ? max : min; 
    _quad.tr.texCoords.y = (_quad.tr.texCoords.y == min) ? max : min; 
    _quad.bl.texCoords.y = (_quad.bl.texCoords.y == min) ? max : min; 
    _quad.br.texCoords.y = (_quad.br.texCoords.y == min) ? max : min; 
}

- (void)rotateTextureCW
{
    icQuad oldQuad = _quad;
    _quad.tr.texCoords = oldQuad.tl.texCoords;
    _quad.br.texCoords = oldQuad.tr.texCoords;
    _quad.tl.texCoords = oldQuad.bl.texCoords;
    _quad.bl.texCoords = oldQuad.br.texCoords;
}

- (void)rotateTextureCCW
{
    icQuad oldQuad = _quad;
    _quad.tl.texCoords = oldQuad.tr.texCoords;
    _quad.tr.texCoords = oldQuad.br.texCoords;
    _quad.bl.texCoords = oldQuad.tl.texCoords;
    _quad.br.texCoords = oldQuad.bl.texCoords;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

@end
