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
#import "icTypes.h"

@class ICTexture2D;

/**
 @brief A sprite capable of scaling texture regions based on a so-called scale-9 rect
 
 This class implements a sprite consisting of 9 quads (18 polygons) that are defined by
 the sprite's contentSize (see ICNode::contentSize) and a scale-9 rectangle
 (see ICScale9Sprite::scale9Rect). Just as with the ICSprite class, the content size property
 defines the extends of the sprite in world coordinates (points). While the naive implementation
 of the ICSprite class simply scales or repeats its texture so that it fits the sprite's quad
 surface, ICScale9Sprite applies special scaling rules based on the specified scale-9 rectangle.
 
 The scale-9 rectangle defines an inner region of a given texture in texture coordinate space.
 The coordinates of that rectangle are defined in points. The ICScale9Sprite class uses these
 coordinates to calculate a grid like multi-quad structure which is then used to scale only
 certain parts of the texture on screen. More precisely, the corners emerging from calculating
 the intersections of the original texture rectangle and the scale-9 rectangle are not scaled
 when changing the sprite's content size while all other regions are scaled to match the final
 content size. This is essentially useful when you need to scale textures containing rounded
 corners or similar regions that must be excluded from scaling to preserve correct visual
 appearance.
 */
@interface ICScale9Sprite : ICSprite {
@protected
    CGRect _scale9Rect;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;    
}

@property (nonatomic, assign, setter=setScale9Rect:) CGRect scale9Rect;

+ (id)spriteWithTexture:(ICTexture2D *)texture scale9Rect:(CGRect)scale9Rect;

- (id)init;

- (id)initWithTexture:(ICTexture2D *)texture scale9Rect:(CGRect)scale9Rect;

@end
