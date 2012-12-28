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
#import "ICFontCache.h"
#import "icFontUtils.h"


//
// ICGlyphRunMetrics
//

@interface ICGlyphRunMetrics : NSObject {
@protected
    CGFloat _ascent;
    CGFloat _descent;
    CGFloat _leading;
    CFIndex _glyphCount;
    CGGlyph *_glyphs;
    CGPoint *_positions;
    kmVec4 _boundingBox;
    float _baseline;
}

- (id)initWithCoreTextRun:(CTRunRef)run;

@property (nonatomic, readonly) CGFloat ascent;
@property (nonatomic, readonly) CGFloat descent;
@property (nonatomic, readonly) CGFloat leading;
@property (nonatomic, readonly) CFIndex glyphCount;
@property (nonatomic, readonly) CGGlyph *glyphs;
@property (nonatomic, readonly) CGPoint *positions;
@property (nonatomic, readonly) kmVec4 boundingBox;
@property (nonatomic, readonly) float baseline;

@end

@implementation ICGlyphRunMetrics

@synthesize ascent = _ascent;
@synthesize descent = _descent;
@synthesize leading = _leading;
@synthesize glyphCount = _glyphCount;
@synthesize glyphs = _glyphs;
@synthesize positions = _positions;
@synthesize boundingBox = _boundingBox;

- (id)initWithCoreTextRun:(CTRunRef)run
{
    if ((self = [super init])) {
        NSAssert(run != nil, @"A valid run must be given");
        
        // Get metrics from CoreText
        CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &_ascent, &_descent, &_leading);
        _glyphCount = CTRunGetGlyphCount(run);
        
        if (_glyphCount > 0) {
            _glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * _glyphCount);
            CTRunGetGlyphs(run, CFRangeMake(0, _glyphCount), _glyphs);
            _positions = (CGPoint *)malloc(sizeof(CGPoint) * _glyphCount);
            CTRunGetPositions(run, CFRangeMake(0, _glyphCount), _positions);
            
            CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
            CGRect *boundingRects = malloc(sizeof(CGRect) * _glyphCount);
            CTFontGetBoundingRectsForGlyphs(runFont, kCTFontDefaultOrientation, _glyphs, boundingRects, _glyphCount);
            CGSize *advances = malloc(sizeof(CGSize) * _glyphCount);
            CTFontGetAdvancesForGlyphs(runFont, kCTFontDefaultOrientation, _glyphs, advances, _glyphCount);

            float marginInPoints = ICPixelsToPoints(IC_GLYPH_RECTANGLE_MARGIN);
            _baseline = ceilf(_ascent) + marginInPoints;
            
            kmVec2 min = kmVec2Make(IC_HUGE, IC_HUGE);
            kmVec2 max = kmVec2Make(0, 0);
            CFIndex i=0;
            for (; i<_glyphCount; i++) {
                float textureGlyphHeight = boundingRects[i].size.height + marginInPoints * 2;
                
                // FIXME: determine orientation of tracking/margin compensation
                
                _positions[i].x = _positions[i].x + boundingRects[i].origin.x - marginInPoints;
                _positions[i].y = _positions[i].y - textureGlyphHeight - ceilf(boundingRects[i].origin.y) + _baseline;
                
                kmVec2 extent = kmVec2Make(advances[i].width + marginInPoints * 2,
                                           textureGlyphHeight);
                
                if (_positions[i].x < min.x)
                    min.x = _positions[i].x;
                if (_positions[i].y < min.y)
                    min.y = _positions[i].y;
                if (_positions[i].x + extent.width > max.x)
                    max.x = _positions[i].x + extent.width;
                if (_positions[i].y + extent.height > max.y)
                    max.y = _positions[i].y + extent.height;
            }
            
            _boundingBox = kmVec4Make(min.x, min.y, max.x - min.x, max.y - min.y);
            
            free(boundingRects);
            free(advances);
        }
    }
    return self;
}

- (void)dealloc
{
    if (_glyphs)
        free(_glyphs);
    if (_positions)
        free(_positions);
    
    [super dealloc];
}

@end


//
// ICTextureGlyphBuffer
//

@interface ICTextureGlyphBuffer : ICCombinedVertexIndexBuffer {
@protected
    ICGlyphTextureAtlas *_textureAtlas;
}

- (id)initWithVertexBuffer:(ICVertexBuffer *)vertexBuffer
               indexBuffer:(ICIndexBuffer *)indexBuffer
              textureAtlas:(ICGlyphTextureAtlas *)textureAtlas;

@property (nonatomic, retain) ICGlyphTextureAtlas *textureAtlas;

@end

@implementation ICTextureGlyphBuffer

@synthesize textureAtlas = _textureAtlas;

- (id)initWithVertexBuffer:(ICVertexBuffer *)vertexBuffer
               indexBuffer:(ICIndexBuffer *)indexBuffer
              textureAtlas:(ICGlyphTextureAtlas *)textureAtlas
{
    if ((self = [super initWithVertexBuffer:vertexBuffer indexBuffer:indexBuffer])) {
        self.textureAtlas = textureAtlas;
    }
    return self;
}

- (void)dealloc
{
    self.textureAtlas = nil;
    [super dealloc];
}

@end


//
// ICGlyphRun
//

// TODO: find better solution for solid color (via shader), remove color from vertices?
// TODO: retain texture glyphs or automatize re-caching in case cache was purged?

@interface ICGlyphRun ()
- (void)updateMetrics;
- (void)updateBuffers;
@property (nonatomic, retain) ICGlyphRunMetrics *metrics;
@end

@implementation ICGlyphRun

@synthesize string = _string;
@synthesize font = _font;
@synthesize tracking = _tracking;
@synthesize color = _color;
@synthesize metrics = _metrics;

+ (id)glyphRunWithString:(NSString *)string font:(ICFont *)font
{
    return [[[[self class] alloc] initWithString:string font:font] autorelease];
}

+ (id)glyphRunWithString:(NSString *)string font:(ICFont *)font color:(icColor4B)color
{
    return [[[[self class] alloc] initWithString:string font:font color:color] autorelease];
}

+ (id)glyphRunWithString:(NSString *)string attributes:(NSDictionary *)attributes
{
    return [[[[self class] alloc] initWithString:string attributes:attributes] autorelease];
}

- (id)initWithString:(NSString *)string font:(ICFont *)font
{
    return [self initWithString:string font:font color:IC_DEFAULT_GLYPH_RUN_COLOR];
}

- (id)initWithString:(NSString *)string font:(ICFont *)font color:(icColor4B)color
{
    if ((self = [super init])) {
        [self addObserver:self forKeyPath:@"color" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"string" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:nil];
        
        self.color = color;
        self.string = string;
        self.font = font;
        
        self.shaderProgram = [[ICShaderCache currentShaderCache]
                              shaderProgramForKey:kICShader_PositionTextureA8Color];
    }
    return self;
}

- (id)initWithString:(NSString *)string attributes:(NSDictionary *)attributes
{
    if (!attributes) {
        [NSException raise:NSInvalidArgumentException format:@"attributes must be non-nil"];
    }
    
    ICFont *font = [attributes objectForKey:ICFontAttributeName];
    if (!font) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"attributes dictionary must contain a font value"];
    }
    
    NSValue *colorValue = [attributes objectForKey:ICColorAttributeName];
    icColor4B color;
    if (colorValue) {
        [colorValue getValue:&color];
    } else {
        color = IC_DEFAULT_GLYPH_RUN_COLOR;
    }
    
    return [self initWithString:string font:font color:color];
}

- (id)initWithCoreTextRun:(CTRunRef)run
{
    if (!run) {
        [NSException raise:NSInvalidArgumentException format:@"run argument may not be nil"];
    }
    
    _ctRun = run;

    NSDictionary *attributes = icCreateTextAttributesWithCTAttributes(
        (NSDictionary *)CTRunGetAttributes(run)
    );
    
    self = [self initWithString:nil attributes:attributes];
    
    [attributes release];
    return self;
}

- (void)dealloc
{
    self.string = nil;
    self.font = nil;
    
    [self removeObserver:self forKeyPath:@"color"];
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
    if (object == self &&
        ([keyPath isEqualToString:@"color"] ||
         [keyPath isEqualToString:@"font"] ||
         [keyPath isEqualToString:@"string"])) {
        _dirty = YES;
    }
    
    if (_dirty) {
        [self updateMetrics];
    }
}

- (void)updateMetrics
{
    if ((self.string || _ctRun) && self.font) {
        CTLineRef line = nil;
        CTRunRef run = _ctRun;
        
        if (!run) {
            // Create a CoreText representation of the run
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        (id)self.font.fontRef, (NSString *)kCTFontAttributeName, nil];
            NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:self.string
                                                                                    attributes:attributes] autorelease];
            line = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedString);
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            CFIndex runCount = CFArrayGetCount(runs);
            NSAssert(runCount == 1, @"Shouldn't be more than 1 run");
            run = (CTRunRef)CFArrayGetValueAtIndex(runs, 0);
        }
        
        // Calculate new metrics
        self.metrics = [[[ICGlyphRunMetrics alloc] initWithCoreTextRun:run] autorelease];
        self.origin = kmVec3Make(self.metrics.boundingBox.x,
                                 self.metrics.boundingBox.y, 0);
        self.size = kmVec3Make(self.metrics.boundingBox.width,
                               self.metrics.boundingBox.height, 0);

        if (line) {
            CFRelease(line);
        }
    }
}

- (void)updateBuffers
{
    // Dispose old buffers
    [_buffers release];
    _buffers = nil;
    
    NSAssert(self.metrics != nil, @"Metrics must have been computed at this point");
    
    // We only create a new buffer if necessary (both string and font are non-nil)
    if (self.font && self.metrics) {
        // Re-create buffers
        _buffers = [[NSMutableArray alloc] initWithCapacity:1];
        
        CGGlyph *glyphs = self.metrics.glyphs;
        CFIndex glyphCount = self.metrics.glyphCount;
        CGPoint *positions = self.metrics.positions;
        
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
                
                x1 = positions[glyphIndex].x;
                y1 = positions[glyphIndex].y;
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
                    quads[j].vertices[k].color = color4FFromColor4B(self.color);
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
            
            ICTextureGlyphBuffer *glyphBuffer = [[ICTextureGlyphBuffer alloc]
                                                 initWithVertexBuffer:vertexBuffer
                                                 indexBuffer:indexBuffer
                                                 textureAtlas:[textureKey pointerValue]];
            
            // Add buffers
            [_buffers addObject:glyphBuffer];
            
            [glyphBuffer release];
            free(quads);
            free(quadIndices);
        }
    }
    
#if IC_ENABLE_DEBUG_GLYPH_RUN_METRICS
    [self removeAllChildren];
    [_dbgBaseline release];
    _dbgBaseline = [[ICLine2D lineWithOrigin:kmVec3Make(self.origin.x, [self baseline], 0)
                                      target:kmVec3Make(self.origin.x + self.size.width, [self baseline], 0)
                                   lineWidth:1.f
                           antialiasStrength:0.f
                                       color:(icColor4B){0,0,255,255}] retain];
    [self addChild:_dbgBaseline];
#endif
    
    _dirty = NO;
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    if (_dirty) {
        [self updateBuffers];
    }
    
    // _buffers may be nil if there's nothing to draw currently; in this case don't do any setup
    if (_buffers)
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
        
        glDisableVertexAttribArray(ICVertexAttribPosition);
        glDisableVertexAttribArray(ICVertexAttribColor);
        glDisableVertexAttribArray(ICVertexAttribTexCoords);        
    }
}

- (float)baseline
{
    return self.metrics.baseline;
}

- (float)ascent
{
    return (float)self.metrics.ascent;
}

@end
