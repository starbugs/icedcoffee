/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/**
 @file icTypes.h
 @brief IcedCoffee types
 */

#pragma once

#import "Platforms/icGL.h"
#import "kazmath/kazmath.h"
#import "kazmath/vec4.h"

// IcedCoffee extensions to kazmath

#define kmNullVec2 (kmVec2){0,0}
#define kmNullVec3 (kmVec3){0,0,0}
#define kmVec2Make(x,y) (kmVec2){x,y}
#define kmVec3Make(x,y,z) (kmVec3){x,y,z}
#define kmVec3ToCGPoint(v) (CGPointMake(v.x,v.y))
#define kmVec4Make(x,y,z,w) (kmVec4){x,y,z,w}
#define kmVec3Description(v) \
    ([NSString stringWithFormat:@"[ %f, %f, %f ]", v.x, v.y, v.z])
#define kmMat4Description(m) \
    ([NSString stringWithFormat:@"[ %f, %f, %f, %f,\n  %f, %f, %f, %f\n  %f, %f, %f, %f\n  %f, %f, %f, %f ]", \
     (m).mat[0], (m).mat[4], (m).mat[8], (m).mat[12], \
     (m).mat[1], (m).mat[5], (m).mat[9], (m).mat[13], \
     (m).mat[2], (m).mat[6], (m).mat[10], (m).mat[14], \
     (m).mat[3], (m).mat[7], (m).mat[11], (m).mat[15]])
#define kmVec4FromColor(c) ((kmVec4){(float)c.r/255.0f,(float)c.g/255.0f,(float)c.b/255.0f,(float)c.a/255.0f})
#define colorFromKmVec4(v) ((icColor4B){((GLubyte)(v.x*255.0f)),((GLubyte)(v.y*255.0f)),((GLubyte)(v.z*255.0f)),((GLubyte)(v.w*255.0f))})

/** @name Frame Updates */

typedef enum _ICFrameUpdateMode {
    kICFrameUpdateMode_Synchronized = 0,
    kICFrameUpdateMode_OnDemand = 1
} ICFrameUpdateMode;

typedef enum _ICShaderValueType {
    ICShaderValueType_Invalid,
    ICShaderValueType_Int,
    ICShaderValueType_Float,
    ICShaderValueType_Vec2,
    ICShaderValueType_Vec3,
    ICShaderValueType_Vec4,
    ICShaderValueType_Mat4,
    ICShaderValueType_Sampler2D
} ICShaderValueType;

/** @name Color Types */

/**
 @brief Defines an RGBA color composed of four bytes
 */
typedef struct _icColor4B {
    GLubyte r;
    GLubyte g;
    GLubyte b;
    GLubyte a;
} icColor4B;

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

/**
 @brief A 3D quad defined by four vertices
 */
typedef struct _icV3F_C4B_T2FQuad {
	icV3F_C4B_T2F tl;
	icV3F_C4B_T2F tr;
	icV3F_C4B_T2F bl;
	icV3F_C4B_T2F br;
} icV3F_C4B_T2FQuad;

/**
 @brief Short for icV3F_C4B_T2FQuad
 */
typedef icV3F_C4B_T2FQuad icQuad;


/**
 @struct icBlendFunc
 @brief Blend function used for textures
 */
typedef struct _icBlendFunc
{
	//! source blend function
	GLenum src;
	//! destination blend function
	GLenum dst;
} icBlendFunc;


/** @typedef ICPixelFormat
 Supported texture pixel formats
 */
typedef enum {
	kICPixelFormat_Automatic = 0,
	//! 32-bit texture: RGBA8888
	kICPixelFormat_RGBA8888,
	//! 16-bit texture without Alpha channel
	kICPixelFormat_RGB565,
	//! 8-bit textures used as masks
	kICPixelFormat_A8,
	//! 16-bit textures: RGBA4444
	kICPixelFormat_RGBA4444,
	//! 16-bit textures: RGB5A1
	kICPixelFormat_RGB5A1,	
    
	//! Default texture format: RGBA8888
	kICPixelFormat_Default = kICPixelFormat_RGBA8888,
} ICPixelFormat;


/** @typedef ICDepthBufferFormat
 Supported depth buffer formats
 */
typedef enum {
    kICDepthBufferFormat_None = 0,
	kICDepthBufferFormat_16 = 1,
    kICDepthBufferFormat_24 = 2,
    
	//! Default texture format: RGBA8888
	kICDepthBufferFormat_Default = kICDepthBufferFormat_24
} ICDepthBufferFormat;


/** @typedef ICStencilBufferFormat
 */
typedef enum {
    kICStencilBufferFormat_None = 0,
	kICStencilBufferFormat_8 = 1,
    
	//! Default texture format: RGBA8888
	kICStencilBufferFormat_Default = kICStencilBufferFormat_8
} ICStencilBufferFormat;


/**
 @enum icResolutionType
 @brief Texture resolution type
 */
typedef enum _icResolutionType {
	//! Unknonw resolution type
	kICResolutionUnknown,
	//! iPhone resolution type
	kICResolutioniPhone,
	//! RetinaDisplay resolution type
	kICResolutionRetinaDisplay,
	//! iPad resolution type
	kICResolutioniPad,
} icResolutionType;


enum {
    ICAutoResizingMaskNotSizable           = 0x00,
    ICAutoResizingMaskLeftMarginFlexible   = 0x01,
    ICAutoResizingMaskWidthSizable         = 0x02,
    ICAutoResizingMaskRightMarginFlexible  = 0x04,
    ICAutoResizingMaskTopMarginFlexible    = 0x08,
    ICAutoResizingMaskHeightSizable        = 0x10,
    ICAutoResizingMaskBottomMarginFlexible = 0x20
};

typedef double icTime;
