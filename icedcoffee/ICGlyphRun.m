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
#import "ICShaderProgram.h"
#import "ICShaderValue.h"
#import "ICFontCache.h"
#import "icFontUtils.h"


// FIXME: property changes do not rebuild run


#define ICAttributeNameGamma @"a_gamma"


#define SHIFT_STRENGTH 1.0

NSString *__glyphVSH = IC_SHADER_STRING
(
    attribute vec4 a_position;
    attribute vec2 a_texCoord;
    attribute vec4 a_color;
    attribute float a_gamma;

    uniform mat4 u_MVPMatrix;

    #ifdef GL_ES
    varying lowp vec4 v_fragmentColor;
    varying highp vec2 v_texCoord;
    varying mediump float v_gamma;
    #else
    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;
    varying float v_gamma;
    #endif

    void main()
    {
        gl_Position = u_MVPMatrix * a_position;
        v_fragmentColor = a_color;
        v_texCoord = a_texCoord;
        v_gamma = a_gamma;
    }
);

NSString *__glyphRGBAFSH = IC_SHADER_STRING
(
    #ifdef GL_ES
    precision highp float;
    #endif

    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;
    varying float v_gamma;
    uniform sampler2D u_texture;

    void main()
    {
        vec4 c = texture2D(u_texture, v_texCoord);
        vec3 gc = pow(vec3(c.r,c.g,c.b), vec3(1.0/v_gamma));
        gl_FragColor = vec4(v_fragmentColor.rgb, (gc.r+gc.g+gc.b)/3.0 * v_fragmentColor.a);
    }
);

NSString *__glyphAFSH = IC_SHADER_STRING
(
    #ifdef GL_ES
    precision lowp float;
    #endif

    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;
    varying float v_gamma;
    uniform sampler2D u_texture;

    void main()
    {
        float glyphAlpha = pow(texture2D(u_texture, v_texCoord).a, 1.0/v_gamma);
        gl_FragColor = vec4(v_fragmentColor.rgb,
                            v_fragmentColor.a * glyphAlpha);
    }
);


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
    float *_offsets;
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
@property (nonatomic, readonly) float *offsets;
@property (nonatomic, readonly) kmVec4 boundingBox;

@end

@implementation ICGlyphRunMetrics

@synthesize ascent = _ascent;
@synthesize descent = _descent;
@synthesize leading = _leading;
@synthesize glyphCount = _glyphCount;
@synthesize glyphs = _glyphs;
@synthesize positions = _positions;
@synthesize offsets = _offsets;
@synthesize boundingBox = _boundingBox;

- (id)initWithCoreTextRun:(CTRunRef)run
{
    if ((self = [super init])) {
        NSAssert(run != nil, @"A valid run must be given");
        
        // Get metrics from CoreText
        CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &_ascent, &_descent, &_leading);
        _glyphCount = CTRunGetGlyphCount(run);
        
        _ascent = ICFontPixelsToPoints(_ascent);
        _descent = ICFontPixelsToPoints(_descent);
        _leading = ICFontPixelsToPoints(_leading);
        
        if (_glyphCount > 0) {
            _glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * _glyphCount);
            CTRunGetGlyphs(run, CFRangeMake(0, _glyphCount), _glyphs);
            
            _positions = (CGPoint *)malloc(sizeof(CGPoint) * _glyphCount);
            CTRunGetPositions(run, CFRangeMake(0, _glyphCount), _positions);
            
            _offsets = (float *)malloc(sizeof(float) * _glyphCount);
            
            //CGAffineTransform textMatrix = CTRunGetTextMatrix(run);
            
            CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
            CGRect *boundingRects = malloc(sizeof(CGRect) * _glyphCount);
            CTFontGetBoundingRectsForGlyphs(runFont, kCTFontDefaultOrientation, _glyphs, boundingRects, _glyphCount);

            float marginInPoints = ICFontPixelsToPoints(IC_GLYPH_RECTANGLE_MARGIN);
            
            kmVec2 min = kmVec2Make(IC_HUGE, IC_HUGE);
            kmVec2 max = kmVec2Make(0, 0);
            CFIndex i=0;
            for (; i<_glyphCount; i++) {
                size_t tgHeight = (size_t)ceilf(boundingRects[i].size.height);
                if (ICFontContentScaleFactor() == 2.)
                    tgHeight += tgHeight % 2;
                float textureGlyphHeight = ICFontPixelsToPoints((float)tgHeight) + marginInPoints;
                
                // FIXME: determine orientation of tracking/margin compensation
                
                _positions[i].x = ICFontPixelsToPoints(_positions[i].x) + ICFontPixelsToPoints(boundingRects[i].origin.x) - marginInPoints;
                _positions[i].y = ICFontPixelsToPoints(_positions[i].y) - textureGlyphHeight - ICFontPixelsToPoints(ceilf(boundingRects[i].origin.y)) + roundf(_ascent);
                
#if IC_USE_EXTRA_SUBPIXEL_GLYPHS
                //float orig = _positions[i].x;
                CGPoint pixelPosition = CGPointMake(ICPointsToPixels(_positions[i].x),
                                                    ICPointsToPixels(_positions[i].y));
                float pixelOffset = 0;
                pixelOffset = pixelPosition.x - floorf(pixelPosition.x);
                if (pixelOffset > 0.8f) {
                    // Move glyphs with subpixel offset > 0.8 one pixel right
                    pixelPosition.x = ceilf(pixelPosition.x);
                    pixelOffset = 0;
                } else if (pixelOffset >= 0.5f) {
                    // Use 0.66 offset rasterization for subpixel offsets > 0.33
                    pixelPosition.x = floorf(pixelPosition.x);
                    pixelOffset = 0.66f;
                } else if (pixelOffset >= 0.2f) {
                    // Use 0.33 offset rasterization for subpixel offsets > 0.33
                    pixelPosition.x = floorf(pixelPosition.x);
                    pixelOffset = 0.33f;
                } else {
                    pixelPosition.x = floorf(pixelPosition.x);
                    pixelOffset = 0.f;
                }
                _positions[i].x = ICPixelsToPoints(pixelPosition.x);
                _offsets[i] = ICPixelsToPoints(pixelOffset);
                //NSLog(@"pos: %f orig: %f offset: %f", _positions[i].x, orig, _offsets[i]);
#elif IC_ROUND_GLYPH_X_POSITIONS
                _positions[i].x = ICPixelsToPoints(roundf(ICPointsToPixels(_positions[i].x)));
                _offsets[i] = 0.f;
#endif
                
                float advance = ICFontPixelsToPoints(boundingRects[i].size.width);
                
                if (_positions[i].x + marginInPoints < min.x)
                    min.x = _positions[i].x + marginInPoints;
                if (_positions[i].x + advance + marginInPoints > max.x)
                    max.x = _positions[i].x + advance + marginInPoints;
                if (_positions[i].y + marginInPoints < min.y)
                    min.y = _positions[i].y + marginInPoints;
                if (_positions[i].y + textureGlyphHeight + marginInPoints > max.y)
                    max.y = _positions[i].y + textureGlyphHeight + marginInPoints;
            }
            
            _boundingBox = kmVec4Make(min.x, min.y, max.x - min.x, max.y - min.y);
            
            free(boundingRects);
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
    if (_offsets)
        free(_offsets);
    
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
@synthesize gamma = _gamma;
@synthesize superscript = _superscript;
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
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSValue valueWithBytes:&color objCType:@encode(icColor4B)], ICForegroundColorAttributeName,
        font, ICFontAttributeName,
        nil
    ];
    self = [self initWithString:string attributes:attributes];
    [attributes release];
    return self;
}

- (id)initWithString:(NSString *)string attributes:(NSDictionary *)attributes
{
    if ((self = [super init])) {
        if (!attributes) {
            [NSException raise:NSInvalidArgumentException format:@"attributes must be non-nil"];
        }
        
        ICFont *font = [attributes objectForKey:ICFontAttributeName];
        if (!font) {
            [NSException raise:NSInternalInconsistencyException
                        format:@"attributes dictionary must contain a font value"];
        }
        
        NSValue *colorValue = [attributes objectForKey:ICForegroundColorAttributeName];
        icColor4B color;
        if (colorValue) {
            [colorValue getValue:&color];
        } else {
            color = IC_DEFAULT_GLYPH_RUN_COLOR;
        }
        
        NSNumber *gammaAttr = [attributes objectForKey:ICGammaAttributeName];
        float gamma = gammaAttr ? [gammaAttr floatValue] : IC_DEFAULT_GLYPH_RUN_GAMMA;
        
        NSNumber *trackingAttr = [attributes objectForKey:ICTrackingAttributeName];
        float tracking = trackingAttr ? [trackingAttr floatValue] : 0;
        
        NSNumber *superscriptAttr = [attributes objectForKey:ICSuperscriptAttributeName];
        NSInteger superscript = superscriptAttr ? [superscriptAttr integerValue] : 0;
        
        self.color = color;
        self.gamma = gamma;
        self.superscript = superscript;
        self.tracking = tracking;
        self.string = string;
        self.font = font;
        
        // Set up shader
        ICShaderCache *shaderCache = [ICShaderCache currentShaderCache];
        ICShaderProgram *p = [shaderCache shaderProgramForKey:ICShaderGlyph];
        
        if (!p) {
            NSString *glyphFSH = IC_GLYPH_CACHE_TEXTURE_DEPTH == 4 ? __glyphRGBAFSH : __glyphAFSH;
            p = [ICShaderProgram shaderProgramWithName:ICShaderGlyph
                                    vertexShaderString:__glyphVSH
                                  fragmentShaderString:glyphFSH];
            [p addAttribute:ICAttributeNamePosition index:ICVertexAttribPosition];
            [p addAttribute:ICAttributeNameColor index:ICVertexAttribColor];
            [p addAttribute:ICAttributeNameTexCoord index:ICVertexAttribTexCoords];
            [p addAttribute:ICAttributeNameGamma index:ICVertexAttribTexCoords+1];
            
            [p link];
            [p updateUniforms];
            
            [shaderCache setShaderProgram:p forKey:ICShaderGlyph];
        }
        
        self.shaderProgram = p;        
    }
    
    return self;
}

- (id)initWithCoreTextRun:(CTRunRef)run extendedAttributes:(NSDictionary *)extendedAttributes
{
    if (!run) {
        [NSException raise:NSInvalidArgumentException format:@"run argument may not be nil"];
    }
    
    _ctRun = run;
    CFRetain(_ctRun);

    NSDictionary *ctRunAttributes = (NSDictionary *)CTRunGetAttributes(run);
    NSDictionary *runAttributes = icCreateTextAttributesWithCTAttributes(ctRunAttributes);
    
    // Merge runAttributes with extendedAttributes
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:
                                       [runAttributes count] + [extendedAttributes count]];
    for (id key in runAttributes) {
        [attributes setObject:[runAttributes objectForKey:key] forKey:key];
    }
    for (id key in extendedAttributes) {
        [attributes setObject:[extendedAttributes objectForKey:key] forKey:key];
    }
    
    self = [self initWithString:nil attributes:attributes];
    
    [attributes release];
    [runAttributes release];
    return self;
}

- (void)dealloc
{
    self.string = nil;
    self.font = nil;
    self.metrics = nil;
    
    [_buffers release];
    
    if (_ctRun)
        CFRelease(_ctRun);
    
    [super dealloc];
}

- (id)precache
{
    NSAssert(self.font != nil && self.string != nil, @"Both text and font properties must be set");
    
    [[ICGlyphCache currentGlyphCache] cacheGlyphsWithString:self.string forFont:self.font];
    return self;
}

- (void)setString:(NSString *)string
{
    [_string release];
    _string = [string copy];
    _dirty = YES;
    [self updateMetrics];
}

- (void)setFont:(ICFont *)font
{
    [_font release];
    _font = [font retain];
    _dirty = YES;
    [self updateMetrics];
}

- (void)setColor:(icColor4B)color
{
    _color = color;
    _dirty = YES;
}

- (void)setGamma:(float)gamma
{
    _gamma = gamma;
    _dirty = YES;
}

- (void)setTracking:(float)tracking
{
    _tracking = tracking;
    _dirty = YES;
    [self updateMetrics];
}

- (void)setSuperscript:(NSInteger)superscript
{
    _superscript = superscript;
    _dirty = YES;
    [self updateMetrics];
}

- (void)updateMetrics
{
    if ((self.string || _ctRun) && self.font) {
        CTLineRef line = nil;
        CTRunRef run = _ctRun;
        
        if (!run) {
            // Create a CoreText representation of the run
            NSNumber *trackingAttr = [NSNumber numberWithFloat:self.tracking];
            NSNumber *superscriptAttr = [NSNumber numberWithInteger:self.superscript];
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        (id)self.font.fontRef, (NSString *)kCTFontAttributeName,
                                        (id)trackingAttr, (NSString *)kCTKernAttributeName,
                                        (id)superscriptAttr, (NSString *)kCTSuperscriptAttributeName,
                                        nil];
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
        
        // Redraw the glyph run
        [self setNeedsDisplay];
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
        float *offsets = self.metrics.offsets;
        
        // Get texture glyphs separated by texture. The idea here is to create distinct VBOs and
        // index buffers for all relevant glyphs that are cached on the same texture so as to
        // limit the number of texture state changes.
        ICGlyphCache *glyphCache = [ICGlyphCache currentGlyphCache];
        NSDictionary *glyphsByTexture = [glyphCache textureGlyphsSeparatedByTextureForGlyphs:glyphs
                                                                                     offsets:offsets
                                                                                       count:glyphCount
                                                                                        font:self.font];
        
        // Iterate over each returned array of glyphs by distinct texture
        for (NSValue *textureKey in glyphsByTexture) {
            // Get glyph entries and glyph count
            NSArray *glyphEntries = [glyphsByTexture objectForKey:textureKey];
            NSInteger textureGlyphCount = [glyphEntries count];
            
            // Allocate memory for upload to VBO
            icV3F_C4F_T2F_G1F_Quad *quads = (icV3F_C4F_T2F_G1F_Quad *)malloc(sizeof(icV3F_C4F_T2F_G1F_Quad) * textureGlyphCount);
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
                
                // Assign texture coordinates, color, shift and gamma
                for (ushort k=0; k<4; k++) {
                    quads[j].vertices[k].texCoords = textureGlyph.texCoords[k];
                    quads[j].vertices[k].color = color4FFromColor4B(self.color);
                    quads[j].vertices[k].gamma = self.gamma;
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
                                                                             stride:sizeof(icV3F_C4F_T2F_G1F)
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
    _dbgBaseline = [[ICLine2D lineWithOrigin:kmVec3Make(self.origin.x, [self ascent], 0)
                                      target:kmVec3Make(self.origin.x + self.size.width, [self ascent], 0)
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
    
    // Draw each texture glyph buffer required to display the run
    for (ICTextureGlyphBuffer *buffer in _buffers) {
        [self applyStandardDrawSetupWithVisitor:visitor];

        if (![visitor isKindOfClass:[ICNodeVisitorPicking class]]) {
            glBindTexture(GL_TEXTURE_2D, buffer.textureAtlas.name);
        }
        
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
        glEnableVertexAttribArray(ICVertexAttribTexCoords+1);
        IC_CHECK_GL_ERROR_DEBUG();
        
        [buffer.vertexBuffer bind];
        [buffer.indexBuffer bind];
        
#define kVertexSize sizeof(icV3F_C4F_T2F_G1F)
        
        // vertex
        NSInteger diff = offsetof(icV3F_C4F_T2F_G1F, vect);
        glVertexAttribPointer(ICVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, kVertexSize, (void*)(diff));
        
        // color
        diff = offsetof(icV3F_C4F_T2F_G1F, color);
        glVertexAttribPointer(ICVertexAttribColor, 4, GL_FLOAT, GL_FALSE, kVertexSize, (void*)(diff));
        
        // texCoords
        diff = offsetof(icV3F_C4F_T2F_G1F, texCoords);
        glVertexAttribPointer(ICVertexAttribTexCoords, 2, GL_FLOAT, GL_FALSE, kVertexSize, (void*)(diff));

        // gamma
        diff = offsetof(icV3F_C4F_T2F_G1F, gamma);
        glVertexAttribPointer(ICVertexAttribTexCoords+1, 1, GL_FLOAT, GL_FALSE, kVertexSize, (void*)(diff));
        
        glDrawElements(GL_TRIANGLES, buffer.indexBuffer.count, GL_UNSIGNED_SHORT, NULL);
        IC_CHECK_GL_ERROR_DEBUG();
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        
        glBindTexture(GL_TEXTURE_2D, 0);
        IC_CHECK_GL_ERROR_DEBUG();
        
        glDisableVertexAttribArray(ICVertexAttribPosition);
        glDisableVertexAttribArray(ICVertexAttribColor);
        glDisableVertexAttribArray(ICVertexAttribTexCoords);
        glDisableVertexAttribArray(ICVertexAttribTexCoords+1);
    }
    
    //[self debugDrawBoundingBox];
}

- (float)ascent
{
    return (float)self.metrics.ascent;
}

- (float)descent
{
    return (float)self.metrics.descent;
}

- (float)leading
{
    return (float)self.metrics.leading;
}

@end
