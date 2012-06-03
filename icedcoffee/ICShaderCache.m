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
//  Inspired by cocos2d-iphone.org

#import "ICShaderCache.h"
#import "ICShaderProgram.h"

ICShaderCache *g_defaultShaderCache = nil;

@interface ICShaderCache (Private)
- (void)loadDefaultShaders;
@end

@implementation ICShaderCache

+ (id)defaultShaderCache
{
    if (!g_defaultShaderCache) {
        g_defaultShaderCache = [[ICShaderCache alloc] init];
    }
    return g_defaultShaderCache;
}

+ (void)purgeDefaultShaderCache
{
    [g_defaultShaderCache release];
}

- (id)init
{
    if ((self = [super init])) {
        _programs = [[NSMutableDictionary alloc] init];
        [self loadDefaultShaders];
    }
    return self;
}

- (void)dealloc
{
    [_programs release];
    [super dealloc];
}

- (void)loadDefaultShaders
{
    NSString *resourcePath = [[NSBundle bundleForClass:[self class]] resourcePath];
    
    NSString *positionTextureColorVSH = [resourcePath stringByAppendingPathComponent:@"PositionTextureColor.vsh"];
    NSString *positionTextureColorFSH = [resourcePath stringByAppendingPathComponent:@"PositionTextureColor.fsh"];
    NSString *positionTextureA8ColorVSH = [resourcePath stringByAppendingPathComponent:@"PositionTextureA8Color.vsh"];
    NSString *positionTextureA8ColorFSH = [resourcePath stringByAppendingPathComponent:@"PositionTextureA8Color.fsh"];
    NSString *pickingFSH = [resourcePath stringByAppendingPathComponent:@"Picking.fsh"];
    NSString *stencilMaskFSH = [resourcePath stringByAppendingPathComponent:@"StencilMask.fsh"];
    NSString *spriteTextureMaskFSH = [resourcePath stringByAppendingPathComponent:@"SpriteTextureMask.fsh"];

    // Standard position texture color shader
    ICShaderProgram *p = [[ICShaderProgram alloc] initWithVertexShaderFilename:positionTextureColorVSH
                                                        fragmentShaderFilename:positionTextureColorFSH];
    
	[p addAttribute:kICAttributeNamePosition index:kICVertexAttrib_Position];
	[p addAttribute:kICAttributeNameColor index:kICVertexAttrib_Color];
	[p addAttribute:kICAttributeNameTexCoord index:kICVertexAttrib_TexCoords];
    
	[p link];
	[p updateUniforms];
    
    [self setShaderProgram:p forKey:kICShader_PositionTextureColor];
    [p release];

    // Standard position texture A8 color shader (for use with masks)
    p = [[ICShaderProgram alloc] initWithVertexShaderFilename:positionTextureA8ColorVSH
                                       fragmentShaderFilename:positionTextureA8ColorFSH];
    
	[p addAttribute:kICAttributeNamePosition index:kICVertexAttrib_Position];
	[p addAttribute:kICAttributeNameColor index:kICVertexAttrib_Color];
	[p addAttribute:kICAttributeNameTexCoord index:kICVertexAttrib_TexCoords];
    
	[p link];
	[p updateUniforms];
    
    [self setShaderProgram:p forKey:kICShader_PositionTextureA8Color];
    [p release];

    // Standard picking shader
    p = [[ICShaderProgram alloc] initWithVertexShaderFilename:positionTextureColorVSH
                                       fragmentShaderFilename:pickingFSH];
    
	[p addAttribute:kICAttributeNamePosition index:kICVertexAttrib_Position];
	[p addAttribute:kICAttributeNameColor index:kICVertexAttrib_Color];
	[p addAttribute:kICAttributeNameTexCoord index:kICVertexAttrib_TexCoords];
    
	[p link];
	[p updateUniforms];
    
    [self setShaderProgram:p forKey:kICShader_Picking];
    [p release];

    // Standard stencil mask shader
    p = [[ICShaderProgram alloc] initWithVertexShaderFilename:positionTextureColorVSH
                                       fragmentShaderFilename:stencilMaskFSH];
    
	[p addAttribute:kICAttributeNamePosition index:kICVertexAttrib_Position];
	[p addAttribute:kICAttributeNameColor index:kICVertexAttrib_Color];
	[p addAttribute:kICAttributeNameTexCoord index:kICVertexAttrib_TexCoords];
    
	[p link];
	[p updateUniforms];
    
    [self setShaderProgram:p forKey:kICShader_StencilMask];
    [p release];
    
    // Sprite multi texture masking shader
    p = [[ICShaderProgram alloc] initWithVertexShaderFilename:positionTextureColorVSH
                                       fragmentShaderFilename:spriteTextureMaskFSH];
    
	[p addAttribute:kICAttributeNamePosition index:kICVertexAttrib_Position];
	[p addAttribute:kICAttributeNameColor index:kICVertexAttrib_Color];
	[p addAttribute:kICAttributeNameTexCoord index:kICVertexAttrib_TexCoords];
    
	[p link];
	[p updateUniforms];
    
    [self setShaderProgram:p forKey:kICShader_SpriteTextureMask];
    [p release];
}

- (void)setShaderProgram:(ICShaderProgram *)program forKey:(id)key
{
    [_programs setObject:program forKey:key];
}

- (ICShaderProgram *)shaderProgramForKey:(id)key
{
    return [_programs objectForKey:key];
}


@end
