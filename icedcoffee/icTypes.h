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
//  Some structs and typedefs adapted from cocos2d-iphone.org (see LICENSE_cocos2d.txt).

/**
 @file icTypes.h
 @brief IcedCoffee types
 */

#pragma once

#import "Platforms/icGL.h"
#import "kazmath/kazmath.h"
#import "kazmath/vec4.h"


/**
 @defgroup conversion-macros Conversion Macros
 @{
 */

#define kmNullVec2 ((kmVec2){0,0})
#define kmNullVec3 ((kmVec3){0,0,0})
#define kmVec2Make(x,y) ((kmVec2){x,y})
#define kmVec3Make(x,y,z) ((kmVec3){x,y,z})
#define kmVec3ToCGPoint(v) (CGPointMake(v.x,v.y))
#define kmVec3ToCGSize(v) (CGSizeMake(v.x,v.y))
#define CGSizeTokmVec3(s) (kmVec3Make(s.width,s.height,0.0f))
#define kmVec4Make(x,y,z,w) ((kmVec4){x,y,z,w})
#define kmVec3Round(v) ((kmVec3){roundf(v.x),roundf(v.y),roundf(v.z)})
#define kmVec3Description(v) \
    ([NSString stringWithFormat:@"[ %f, %f, %f ]", v.x, v.y, v.z])
#define kmMat4Description(m) \
    ([NSString stringWithFormat:@"[ %f, %f, %f, %f,\n  %f, %f, %f, %f\n  %f, %f, %f, %f\n  %f, %f, %f, %f ]", \
     (m).mat[0], (m).mat[4], (m).mat[8], (m).mat[12], \
     (m).mat[1], (m).mat[5], (m).mat[9], (m).mat[13], \
     (m).mat[2], (m).mat[6], (m).mat[10], (m).mat[14], \
     (m).mat[3], (m).mat[7], (m).mat[11], (m).mat[15]])
#define kmVec4FromColor4B(c) ((kmVec4){(float)c.r/255.0f,(float)c.g/255.0f,(float)c.b/255.0f,(float)c.a/255.0f})
#define kmVec4FromColor4F(c) ((kmVec4){c.r,c.g,c.b,c.a})
#define icColor4FMake(r,g,b,a) ((icColor4F){r,g,b,a})
#define color4BFromKmVec4(v) ((icColor4B){((GLubyte)(v.x*255.0f)),((GLubyte)(v.y*255.0f)),((GLubyte)(v.z*255.0f)),((GLubyte)(v.w*255.0f))})
#define color4FFromColor4B(c) ((icColor4F){(float)c.r/255.0f,(float)c.g/255.0f,(float)c.b/255.0f,(float)c.a/255.0f})

/** @} */


/**
 @defgroup general-types General Types
 @{
 */

/** @name Misc. */

typedef enum _ICShaderValueType {
    ICShaderValueTypeInvalid,
    ICShaderValueTypeInt,
    ICShaderValueTypeFloat,
    ICShaderValueTypeVec2,
    ICShaderValueTypeVec3,
    ICShaderValueTypeVec4,
    ICShaderValueTypeMat4,
    ICShaderValueTypeSampler2D
} ICShaderValueType;

typedef enum _ICFrameUpdateMode {
    ICFrameUpdateModeSynchronized = 0,
    ICFrameUpdateModeOnDemand = 1
} ICFrameUpdateMode;


/** @name Pixel, Depth and Stencil Formats */

/** @typedef ICPixelFormat
 Supported texture pixel formats
 */
typedef enum {
	ICPixelFormatAutomatic = 0,
	//! 32-bit texture: RGBA8888
	ICPixelFormatRGBA8888,
	//! 16-bit texture without Alpha channel
	ICPixelFormatRGB565,
	//! 8-bit textures used as masks
	ICPixelFormatA8,
	//! 16-bit textures: RGBA4444
	ICPixelFormatRGBA4444,
	//! 16-bit textures: RGB5A1
	ICPixelFormatRGB5A1,	
    
	//! Default texture format: RGBA8888
	ICPixelFormatDefault = ICPixelFormatRGBA8888,
} ICPixelFormat;


/** @typedef ICDepthBufferFormat
 Supported depth buffer formats
 */
typedef enum {
    ICDepthBufferFormatNone = 0,
	ICDepthBufferFormat16 = 1,
    ICDepthBufferFormat24 = 2,
    
	//! Default texture format: RGBA8888
	ICDepthBufferFormatDefault = ICDepthBufferFormat24
} ICDepthBufferFormat;


/** @typedef ICStencilBufferFormat
 */
typedef enum {
    ICStencilBufferFormatNone = 0,
	ICStencilBufferFormat8 = 1,
    
	//! Default texture format: RGBA8888
	ICStencilBufferFormatDefault = ICStencilBufferFormat8
} ICStencilBufferFormat;


/** @name Resolution Types */

/**
 @enum ICResolutionType
 @brief Texture resolution type
 */
typedef enum _ICResolutionType {
	//! Unknonw resolution type
	ICResolutionTypeUnknown,
	//! Standard definition resolution type
	ICResolutionTypeStandard,
	//! RetinaDisplay resolution type
	ICResolutionTypeRetinaDisplay,
} ICResolutionType;


/** @name Hit Test Result Types */

enum {
    ICHitTestUnsupported = 0,
    ICHitTestHit = 1,
    ICHitTestFailed = 2
};

typedef uint ICHitTestResult;

typedef double icTime;

/** @name Color Types */

/**
 @brief Defines an RGBA color composed of four bytes
 */
typedef struct _icColor4B {
    GLubyte r, g, b, a;
} icColor4B;

/**
 @brief Defines an RGBA color composed of four floats
 */
typedef struct _icColor4F {
    float r, g, b, a;
} icColor4F;

/** @name Texture Coordinate Types */

typedef struct _icTex2F {
    GLfloat u;
    GLfloat v;
} icTex2F;

/** @name Vertex Types */

typedef struct _icV3F_C4B_T2F {
    kmVec3 vect;                // 12 bytes
	icColor4B color;			// 4 bytes
    kmVec2 texCoords;           // 8 bytes
} icV3F_C4B_T2F;

typedef struct _icV3F_C4F {
    kmVec3 vect;                // 12 bytes
	icColor4F color;			// 16 bytes
} icV3F_C4F;

typedef struct _icV3F_C4F_T2F {
    kmVec3 vect;                // 12 bytes
	icColor4F color;			// 16 bytes
    kmVec2 texCoords;           // 8 bytes
} icV3F_C4F_T2F;


typedef struct _icRay3 {
    kmVec3 origin;
    kmVec3 direction;
} icRay3;

/**
 @brief Blend function used for textures
 */
typedef struct _icBlendFunc
{
	//! source blend function
	GLenum src;
	//! destination blend function
	GLenum dst;
} icBlendFunc;

/** @} */
