/*
 icNextPOT function is licensed under the same license that is used in ICTexture2D.m.
 */

#import "icUtils.h"
#import "kazmath/kazmath.h"
#import "kazmath/GL/matrix.h"

unsigned long icNextPOT(unsigned long x)
{
    x = x - 1;
    x = x | (x >> 1);
    x = x | (x >> 2);
    x = x | (x >> 4);
    x = x | (x >> 8);
    x = x | (x >>16);
    return x + 1;
}

// Adapted from: http://oss.sgi.com/cgi-bin/cvsweb.cgi/projects/ogl-sample/main/gfx/lib/glu/libutil/project.c?rev=1.4;content-type=text%2Fplain
void icPickMatrix(GLfloat x, GLfloat y, GLfloat deltax, GLfloat deltay, GLint viewport[4])
{
    if (deltax <= 0 || deltay <= 0) { 
        return;
    }
    
    /* Translate and scale the picked region to the entire window */
    kmMat4 matTranslate, matScale;
    kmMat4Translation(&matTranslate, (viewport[2] - 2 * (x - viewport[0])) / deltax, (viewport[3] - 2 * (y - viewport[1])) / deltay, 0);
    kmMat4Scaling(&matScale, viewport[2] / deltax, viewport[3] / deltay, 1.0);
    kmGLMultMatrix(&matTranslate);
    kmGLMultMatrix(&matScale);
}

// Translated and adapted from: http://www.opengl.org/wiki/GluProject_and_gluUnProject_code
BOOL icUnproject(kmVec3 *viewVect,
                 kmVec3 *resultVect,
                 GLint *viewport,
                 kmMat4 *matProjection,
                 kmMat4 *matModelView)
{
    kmMat4 matTransform, matInverseTransform;
    kmMat4Multiply(&matTransform, matProjection, matModelView);
    if (!kmMat4Inverse(&matInverseTransform, &matTransform))
        return NO;
    
    // Transformation of normalized coordinates in range [-1,1]
    kmVec4 inPoint;
    inPoint.x = (viewVect->x - (float)viewport[0]) / (float)viewport[2] * 2.0f - 1.0f;
    inPoint.y = (viewVect->y - (float)viewport[1]) / (float)viewport[3] * 2.0f - 1.0f;
    inPoint.z = 2.0f * viewVect->z - 1.0f;
    inPoint.w = 1.0f;
    
    kmVec4 outPoint;
    kmVec4Transform(&outPoint, &inPoint, &matInverseTransform);
    if (outPoint.w == 0.0f)
        return NO;
    outPoint.w = 1.0f / outPoint.w;
    
    resultVect->x = outPoint.x * outPoint.w;
    resultVect->y = outPoint.y * outPoint.w;
    resultVect->z = outPoint.z * outPoint.w;
    
    return YES;
}


