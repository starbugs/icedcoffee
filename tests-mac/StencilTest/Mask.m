//  
//  Copyright (C) 2013 Tobias Lensing, Marcus Tillmanns
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

#import "Mask.h"
#import "icedcoffee/ICShaderProgram.h"
#import "icedcoffee/ICShaderCache.h"
#import "icedcoffee/icMacros.h"


NSString *__stencilMaskFSH = IC_SHADER_STRING
(
    #ifdef GL_ES
    precision highp float;
    #endif

    varying vec4 v_fragmentColor;
    varying vec2 v_texCoord;
    uniform sampler2D u_texture;

    void main()
    {
        vec4 tex = texture2D(u_texture, v_texCoord);
        if (tex.a < 0.9) {
            discard;
        }
        gl_FragColor = v_fragmentColor * tex;
    }
);


@implementation Mask

- (id)initWithTexture:(ICTexture2D *)texture
{
    if ((self = [super initWithTexture:texture])) {
        ICShaderCache *shaderCache = [ICShaderCache currentShaderCache];
        ICShaderFactory *shaderFactory = [shaderCache shaderFactory];
        
        NSString *positionTextureColorVSH = [shaderFactory vertexShaderStringForKey:ICShaderPositionTextureColor];
        
        ICShaderProgram *p = [ICShaderProgram shaderProgramWithName:ICShaderStencilMask
                                                 vertexShaderString:positionTextureColorVSH
                                               fragmentShaderString:__stencilMaskFSH];
        
        [p addAttribute:ICAttributeNamePosition index:ICVertexAttribPosition];
        [p addAttribute:ICAttributeNameColor index:ICVertexAttribColor];
        [p addAttribute:ICAttributeNameTexCoord index:ICVertexAttribTexCoords];
        
        [p link];
        [p updateUniforms];
        
        self.shaderProgram = p;
        [shaderCache setShaderProgram:self.shaderProgram forKey:ICShaderStencilMask];
    }
    return self;
}

- (void)drawWithVisitor:(ICNodeVisitor *)visitor
{
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
    glDepthMask(GL_FALSE);
    glEnable(GL_STENCIL_TEST);
    
    glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
    glStencilFunc(GL_ALWAYS, 1, 1);

    // Draw mask into stencil buffer
    [super drawWithVisitor:visitor];
    
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glDepthMask(GL_TRUE);
    glStencilFunc(GL_EQUAL, 1, 1);
}

- (void)childrenDidDrawWithVisitor:(ICNodeVisitor *)visitor
{
    glDisable(GL_STENCIL_TEST);
}

@end
