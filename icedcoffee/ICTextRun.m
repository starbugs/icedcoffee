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

#import "ICTextRun.h"
#import "icTypes.h"
#import "ICGlyphCache.h"
#import "ICTextureGlyph.h"
#import "ICNodeVisitorPicking.h"
#import "Platforms/icGL.h"

@interface ICTextRun ()
- (void)updateBuffers;
@end

@implementation ICTextRun

@synthesize text = _text;
@synthesize font = _font;

- (id)initWithText:(NSString *)text font:(ICFont *)font
{
    if ((self = [super init])) {
        [self addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:nil];
        
        self.text = text;
        self.font = font;
    }
    return self;
}

- (void)dealloc
{
    self.text = nil;
    self.font = nil;
    
    [self removeObserver:self forKeyPath:@"text"];
    [self removeObserver:self forKeyPath:@"font"];
    
    if (_vbo)
        glDeleteBuffers(1, &_vbo);
    if (_ibo)
        glDeleteBuffers(1, &_ibo);
    
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (([keyPath isEqualToString:@"text"] && self.font != nil) ||
        ([keyPath isEqualToString:@"font"] && self.text != nil)) {
        _buffersDirty = YES;
    }
}

- (void)updateBuffers
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (id)self.font.fontRef, (NSString *)kCTFontAttributeName, nil];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.text
                                                                           attributes:attributes];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runs);
    NSAssert(runCount == 1, @"Shouldn't be more than 1 run");
    for (CFIndex i=0; i<runCount; i++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runs, i);
        
        //CGFloat ascent, descent;
        //CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
        
        CFIndex glyphCount = CTRunGetGlyphCount(run);
        
        CGGlyph *glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * glyphCount);
        CTRunGetGlyphs(run, CFRangeMake(0, glyphCount), glyphs);
        CGPoint *positions = (CGPoint *)malloc(sizeof(CGPoint) * glyphCount);
        CTRunGetPositions(run, CFRangeMake(0, glyphCount), positions);
        
        icV3F_C4F_T2F_Quad *quads = (icV3F_C4F_T2F_Quad *)malloc(sizeof(icV3F_C4F_T2F) * glyphCount);
        icUShort_QuadIndices *quadIndices = (icUShort_QuadIndices *)malloc(sizeof(icUShort_QuadIndices) * glyphCount);
        
        ICGlyphCache *glyphCache = [ICGlyphCache currentGlyphCache];
        for (CFIndex j=0; j<glyphCount; j++) {
            ICTextureGlyph *textureGlyph = [glyphCache textureGlyphForGlyph:glyphs[j] font:self.font];
            
            float x1, x2, y1, y2, z;
            x1 = positions[j].x;
            y1 = positions[j].y;
            x2 = x1 + textureGlyph.size.width;
            y2 = y1 + textureGlyph.size.height;
            z = 0;
            
            quads[j].vertices[0].vect = kmVec3Make(x1, y1, z);
            quads[j].vertices[1].vect = kmVec3Make(x1, y2, z);
            quads[j].vertices[2].vect = kmVec3Make(x2, y1, z);
            quads[j].vertices[3].vect = kmVec3Make(x2, y2, z);
            
            for (ushort k=0; k<4; k++) {
                quads[j].vertices[k].texCoords = textureGlyph.texCoords[k];
                quads[j].vertices[k].color = icColor4FMake(0, 0, 0, 1);
            }
            
            GLushort indices[] = {
                j+0, j+2, j+1,
                j+3, j+2, j+1
            };
            memcpy(quadIndices[j].indices, indices, sizeof(GLushort) * 6);
        }
        
        if (_vbo)
            glDeleteBuffers(1, &_vbo);
        if (_ibo)
            glDeleteBuffers(1, &_ibo);
        
        glGenBuffers(1, &_vbo);
        glGenBuffers(1, &_ibo);
        
        glBindBuffer(GL_ARRAY_BUFFER, _vbo);
        glBufferData(GL_ARRAY_BUFFER, sizeof(icV3F_C4F_T2F) * glyphCount * 4, quads, GL_STATIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ibo);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort) * glyphCount * 6, quadIndices, GL_STATIC_DRAW);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        
        free(glyphs);
        free(positions);
        free(quads);
        free(quadIndices);
    }
    CFRelease(line);
    [attributedString release];
    
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    if (_buffersDirty)
        [self updateBuffers];
    
    /*[self applyStandardDrawSetupWithVisitor:visitor];
    
    if (![visitor isKindOfClass:[ICNodeVisitorPicking class]])
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
    IC_CHECK_GL_ERROR_DEBUG();*/
}

@end
