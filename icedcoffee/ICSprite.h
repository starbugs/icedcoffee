//  
//  Copyright (C) 2012 Tobias Lensing
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

#import "ICNode.h"
#import "ICTexture2D.h"
#import "icTypes.h"

/**
 @brief A colored and textured 2D sprite
 
 ICSprite defines a rectangular quad (icQuad) which may be drawn in an arbitrary 3D scene.
 You may set a color and a texture which is used to render the quad's fragments.
 The quad's size is by default set to the size of the texture (in points.) If no
 texture is set, the quad's size defaults to (w=1,h=1).
 */
@interface ICSprite : ICNode
{
@private
    ICTexture2D *_texture;
    icQuad       _quad;
    icColor4B    _color;
    icBlendFunc  _blendFunc;
}

/**
 @brief The sprite's color
 */
@property (nonatomic, assign, getter=color, setter=setColor:) icColor4B color;

/**
 @brief The sprite's texture
 */
@property (nonatomic, retain) ICTexture2D *texture;

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
 @brief Sets the size of the sprite's quad in local node space
 */
- (void)setQuadSize:(CGSize)size;

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
