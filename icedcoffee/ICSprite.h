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

#import <Foundation/Foundation.h>

#import "ICPlanarNode.h"
#import "ICTexture2D.h"
#import "icTypes.h"

/**
 @brief A colored and textured 2D sprite
 
 ICSprite defines a rectangular quad (icQuad) which may be drawn in an arbitrary 3D scene.
 The quad consists of two polygons and is rendered as a static triangle strip.
 You may set a color and a texture which is used to render the quad's fragments.
 The quad's size is by default set to the size of the texture (in points.) If no
 texture is set, the quad's size defaults to (w=1,h=1).
 */
@interface ICSprite : ICPlanarNode
{
@protected
    ICTexture2D *_texture;
    ICTexture2D *_maskTexture;
    icColor4B    _color;
    icBlendFunc  _blendFunc;
    GLuint       _vertexBuffer;
    kmVec2       _texCoords[4];
}

/**
 @brief The sprite's color
 */
@property (nonatomic, assign, getter=color, setter=setColor:) icColor4B color;

/**
 @brief The sprite's texture
 */
@property (nonatomic, retain, setter=setTexture:) ICTexture2D *texture;

/**
 @brief The sprite's mask texture
 */
@property (nonatomic, retain, setter=setMaskTexture:) ICTexture2D *maskTexture;

/**
 @brief The sprite's blending function
 */
@property (nonatomic, assign) icBlendFunc blendFunc;

/**
 @brief A convenience method returning an autoreleased ICSprite instance
 */
+ (id)sprite;

/**
 @brief A convenience method returning an autoreleased ICSprite instance with the given texture
 */
+ (id)spriteWithTexture:(ICTexture2D *)texture;

/**
 @brief Initializes a default sprite
 */
- (id)init;

/**
 @brief Initializes a sprite with the specified texture
 */
- (id)initWithTexture:(ICTexture2D *)texture;

/**
 @brief Draws the sprite
 */
- (void)drawWithVisitor:(ICNodeVisitor *)visitor;

/**
 @brief Flips the sprite's texture horizontally
 */
- (void)flipTextureHorizontally;

/**
 @brief Flips the sprite's texture vertically
 */
- (void)flipTextureVertically;

/**
 @brief Rotates the sprite's texture by 90 degrees in the clock-wise direction
 */
- (void)rotateTextureCW;

/**
 @brief Rotates the sprite's texture by 90 degrees in the counter clock-wise direction
 */
- (void)rotateTextureCCW;

@end
