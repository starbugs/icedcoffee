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

#import "ICGlyphRun.h"
#import "icTypes.h"
#import "ICGlyphCache.h"
#import "ICTextureGlyph.h"
#import "ICNodeVisitorPicking.h"
#import "Platforms/icGL.h"
#import "ICCombinedVertexIndexBuffer.h"
#import "ICGlyphTextureAtlas.h"
#import "icGLState.h"
#import "ICShaderCache.h"

@interface ICTextureGlyphBuffer : ICCombinedVertexIndexBuffer {
@protected
    ICGlyphTextureAtlas *_textureAtlas;
}

@property (nonatomic, retain) ICGlyphTextureAtlas *textureAtlas;

@end

@implementation ICTextureGlyphBuffer

@synthesize textureAtlas = _textureAtlas;

- (void)dealloc
{
    self.textureAtlas = nil;
    [super dealloc];
}

@end



@interface ICGlyphRun ()
- (void)updateBuffers;
@end

@implementation ICGlyphRun

@synthesize string = _string;
@synthesize font = _font;
@synthesize tracking = _tracking;

+ (id)glyphRunWithString:(NSString *)string font:(ICFont *)font
{
    return [[[[self class] alloc] initWithString:string font:font] autorelease];
}

- (id)initWithString:(NSString *)string font:(ICFont *)font
{
    if ((self = [super init])) {
        [self addObserver:self forKeyPath:@"string" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:nil];
        
        self.string = string;
        self.font = font;
        
        self.shaderProgram = [[ICShaderCache currentShaderCache]
                              shaderProgramForKey:kICShader_PositionTextureA8Color];
    }
    return self;
}

- (void)dealloc
{
    self.string = nil;
    self.font = nil;
    
    [self removeObserver:self forKeyPath:@"string"];
    [self removeObserver:self forKeyPath:@"font"];

    [_buffers release];
    
    [super dealloc];
}

- (id)precache
{
    NSAssert(self.font != nil && self.string != nil, @"Both text and font properties must be set");
    
    [[ICGlyphCache currentGlyphCache] cacheGlyphsWithString:self.string forFont:self.font];
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (([keyPath isEqualToString:@"string"] && self.font != nil) ||
        ([keyPath isEqualToString:@"font"] && self.string != nil)) {
        _buffersDirty = YES;
    }
}

- (void)updateBuffers
{
    // Dispose old and re-create new buffers
    [_buffers release];
    _buffers = [[NSMutableArray alloc] initWithCapacity:1];

    // Create a CoreText representation of the run
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (id)self.font.fontRef, (NSString *)kCTFontAttributeName, nil];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.string
                                                                           attributes:attributes];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runs);
    NSAssert(runCount == 1, @"Shouldn't be more than 1 run");
    
    for (CFIndex i=0; i<runCount; i++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runs, i);
        
        CGFloat ascent, descent, leading;
        CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
        
        CFIndex glyphCount = CTRunGetGlyphCount(run);
        
        CGGlyph *glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * glyphCount);
        CTRunGetGlyphs(run, CFRangeMake(0, glyphCount), glyphs);
        CGPoint *positions = (CGPoint *)malloc(sizeof(CGPoint) * glyphCount);
        CTRunGetPositions(run, CFRangeMake(0, glyphCount), positions);
        
        // Get texture glyphs separated by texture. The idea here is to create distinct VBOs and
        // index buffers for all relevant glyphs that are cached on the same texture so as to
        // limit the number of texture state changes.
        ICGlyphCache *glyphCache = [ICGlyphCache currentGlyphCache];
        NSDictionary *glyphsByTexture = [glyphCache textureGlyphsSeparatedByTextureForGlyphs:glyphs
                                                                                       count:glyphCount
                                                                                        font:self.font];
        
        // Iterate over each returned array of glyphs by distinct texture
        for (NSValue *textureKey in glyphsByTexture) {
            // Get glyph entries and glyph count
            NSArray *glyphEntries = [glyphsByTexture objectForKey:textureKey];
            NSInteger textureGlyphCount = [glyphEntries count];
            
            // Allocate memory for upload to VBO
            icV3F_C4F_T2F_Quad *quads = (icV3F_C4F_T2F_Quad *)malloc(sizeof(icV3F_C4F_T2F_Quad) * textureGlyphCount);
            icUShort_QuadIndices *quadIndices = (icUShort_QuadIndices *)malloc(sizeof(icUShort_QuadIndices) * textureGlyphCount);
            
            // Iterate over all relevant glyph entries for this texture
            CFIndex j = 0;
            for (NSArray *glyphEntry in glyphEntries) {
                // Get the glyph's index in the run
                NSInteger glyphIndex = [[glyphEntry objectAtIndex:0] integerValue];
                // .. and the texture glyph itself
                ICTextureGlyph *textureGlyph = [glyphEntry objectAtIndex:1];
                
                // Calculate and assign vertex positions
                float x1, x2, y1, y2, z;
                float positionX = positions[glyphIndex].x;
                float positionY = positions[glyphIndex].y;
                
                // TODO: determine orientation of tracking/margin compensation
                x1 = positionX + textureGlyph.boundingRect.origin.x + glyphIndex * self.tracking - IC_GLYPH_RECTANGLE_MARGIN;
                y1 = positionY - textureGlyph.size.height - ceilf(textureGlyph.boundingRect.origin.y) + ceilf(ascent) + IC_GLYPH_RECTANGLE_MARGIN;
                x2 = x1 + textureGlyph.size.width;
                y2 = y1 + textureGlyph.size.height;
                z = 0;
                
                quads[j].vertices[0].vect = kmVec3Make(x1, y1, z);
                quads[j].vertices[1].vect = kmVec3Make(x1, y2, z);
                quads[j].vertices[2].vect = kmVec3Make(x2, y1, z);
                quads[j].vertices[3].vect = kmVec3Make(x2, y2, z);
                
                // Assign texture coordinates and color
                for (ushort k=0; k<4; k++) {
                    quads[j].vertices[k].texCoords = textureGlyph.texCoords[k];
                    quads[j].vertices[k].color = icColor4FMake(0, 0, 0, 1);
                }
                
                // Calculate and assign indices
                GLushort offset = (GLushort)j * 4;
                GLushort indices[] = {
                    offset+0, offset+1, offset+2,
                    offset+3, offset+2, offset+1
                };
                memcpy(quadIndices[j].indices, indices, sizeof(GLushort) * 6);
                j++;
            }
    
            // Create buffers for all relevant glyphs of this texture
            ICVertexBuffer *vertexBuffer = [ICVertexBuffer vertexBufferWithVertices:quads
                                                                              count:(GLuint)textureGlyphCount * 4
                                                                             stride:sizeof(icV3F_C4F_T2F)
                                                                              usage:GL_STATIC_DRAW];
            ICIndexBuffer *indexBuffer = [ICIndexBuffer indexBufferWithIndices:quadIndices
                                                                         count:(GLuint)textureGlyphCount * 6
                                                                        stride:sizeof(GLushort)
                                                                         usage:GL_STATIC_DRAW];
            ICTextureGlyphBuffer *glyphBuffer =
                [ICTextureGlyphBuffer combinedVertexIndexBufferWithVertexBuffer:vertexBuffer
                                                                    indexBuffer:indexBuffer];
            glyphBuffer.textureAtlas = [textureKey pointerValue];
            
            // Add buffers
            [_buffers addObject:glyphBuffer];
    
            free(quads);
            free(quadIndices);
        }

        free(glyphs);
        free(positions);
    }
    
    CFRelease(line);
    [attributedString release];
    
    _buffersDirty = NO;
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    if (_buffersDirty) {
        [self updateBuffers];
    }
    
    [self applyStandardDrawSetupWithVisitor:visitor];
    
    // Draw each texture glyph buffer required to display the run
    for (ICTextureGlyphBuffer *buffer in _buffers) {
        if (![visitor isKindOfClass:[ICNodeVisitorPicking class]])
            glBindTexture(GL_TEXTURE_2D, buffer.textureAtlas.name);
        
        if ([visitor isKindOfClass:[ICNodeVisitorPicking class]]) {
            icGLDisable(GL_BLEND);
        } else {
            icGLBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            icGLEnable(IC_GL_BLEND);
        }
        
        // FIXME: needs to go into icGLState
        glEnableVertexAttribArray(ICVertexAttribPosition);
        glEnableVertexAttribArray(ICVertexAttribColor);
        glEnableVertexAttribArray(ICVertexAttribTexCoords);
        IC_CHECK_GL_ERROR_DEBUG();
        
        [buffer.vertexBuffer bind];
        [buffer.indexBuffer bind];
        
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
        
        glDrawElements(GL_TRIANGLES, buffer.indexBuffer.count, GL_UNSIGNED_SHORT, NULL);
        IC_CHECK_GL_ERROR_DEBUG();
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        
        glBindTexture(GL_TEXTURE_2D, 0);
        IC_CHECK_GL_ERROR_DEBUG();
    }
}

@end
