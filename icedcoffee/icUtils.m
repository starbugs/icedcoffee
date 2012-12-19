/*
 icNextPOT function is licensed under the same license that is used in ICTexture2D.m.
 */

#import "icUtils.h"
#import "icMacros.h"
#import "Platforms/icGL.h"
#import "kazmath/kazmath.h"
#import "kazmath/GL/matrix.h"

#import <mach/mach.h>
#import <mach/mach_time.h>

#import "ICControl.h"

#ifdef __IC_PLATFORM_MAC
#import "Platforms/Mac/ICGLView.h"
#elif defined(__IC_PLATFORM_IOS)
#import "Platforms/iOS/ICGLView.h"
#endif

ICOpenGLContext *icCreateAuxGLContextForView(ICGLView *view, BOOL share)
{
#ifdef __IC_PLATFORM_MAC
    NSOpenGLPixelFormat *pixelFormat = [view pixelFormat];
    NSOpenGLContext *nativeShareContext = share ? [view openGLContext] : nil;
    NSOpenGLContext *nativeContext = [[NSOpenGLContext alloc] initWithFormat:pixelFormat
                                                                shareContext:nativeShareContext];
    ICOpenGLContext *viewContext = share ? [[ICOpenGLContextManager defaultOpenGLContextManager]
                                            openGLContextForNativeOpenGLContext:[view openGLContext]]
                                         : nil;
#elif defined(__IC_PLATFORM_IOS)
    EAGLSharegroup *sharegroup = share ? [[view context] sharegroup] : nil;
    EAGLContext *nativeContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2
                                                       sharegroup:sharegroup];
    ICOpenGLContext *viewContext = share ? [[ICOpenGLContextManager defaultOpenGLContextManager]
                                            openGLContextForNativeOpenGLContext:[view context]]
                                         : nil;
#endif
    return [[ICOpenGLContext openGLContextWithNativeOpenGLContext:nativeContext
                                                     shareContext:viewContext] registerContext];
}

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
    float translateX = (viewport[2] - 2 * (x - viewport[0])) / deltax - 1;
    float translateY = (viewport[3] - 2 * (y - viewport[1])) / deltay - 1;
    kmMat4Translation(&matTranslate, translateX, translateY, 0);
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

// Translated and adapted from: http://www.opengl.org/wiki/GluProject_and_gluUnProject_code
BOOL icProject(kmVec3 *worldVect,
               kmVec3 *resultVect,
               GLint *viewport,
               kmMat4 *matProjection,
               kmMat4 *matModelView)
{
    float objx = worldVect->x, objy = worldVect->y, objz = worldVect->z;
    float *modelview = matModelView->mat;
    float *projection = matProjection->mat;
    
    //Transformation vectors
    float fTempo[8];
    //Modelview transform
    fTempo[0]=modelview[0]*objx+modelview[4]*objy+modelview[8]*objz+modelview[12];  //w is always 1
    fTempo[1]=modelview[1]*objx+modelview[5]*objy+modelview[9]*objz+modelview[13];
    fTempo[2]=modelview[2]*objx+modelview[6]*objy+modelview[10]*objz+modelview[14];
    fTempo[3]=modelview[3]*objx+modelview[7]*objy+modelview[11]*objz+modelview[15];
    //Projection transform, the final row of projection matrix is always [0 0 -1 0]
    //so we optimize for that.
    fTempo[4]=projection[0]*fTempo[0]+projection[4]*fTempo[1]+projection[8]*fTempo[2]+projection[12]*fTempo[3];
    fTempo[5]=projection[1]*fTempo[0]+projection[5]*fTempo[1]+projection[9]*fTempo[2]+projection[13]*fTempo[3];
    fTempo[6]=projection[2]*fTempo[0]+projection[6]*fTempo[1]+projection[10]*fTempo[2]+projection[14]*fTempo[3];
    fTempo[7]=-fTempo[2];
    //The result normalizes between -1 and 1
    if(fTempo[7]==0.0)	//The w value
        return 0;
    fTempo[7]=1.0/fTempo[7];
    //Perspective division
    fTempo[4]*=fTempo[7];
    fTempo[5]*=fTempo[7];
    fTempo[6]*=fTempo[7];
    //Window coordinates
    //Map x, y to range 0-1
    resultVect->x=(fTempo[4]*0.5+0.5)*viewport[2]+viewport[0];
    resultVect->y=(fTempo[5]*0.5+0.5)*viewport[3]+viewport[1];
    //This is only correct when glDepthRange(0.0, 1.0)
    resultVect->z=(1.0+fTempo[6])*0.5;	//Between 0 and 1
    return 1;
}

kmAABB icComputeAABBFromVertices(kmVec3 *vertices, int count)
{
    int i, j;
    kmVec3 aabbMin = (kmVec3){IC_HUGE, IC_HUGE, IC_HUGE};
    kmVec3 aabbMax = (kmVec3){-IC_HUGE, -IC_HUGE, -IC_HUGE};
    float *minComps = (float*)&aabbMin;
    float *maxComps = (float*)&aabbMax;
    
    // min components
    for(i=0; i<3; i++) {
        for(j=0; j<count; j++) {
            kmVec3 *v = &vertices[j];
            float comp = *(((float*)v)+i);
            if(comp < *(minComps+i))
                ((float*)&aabbMin)[i] = comp;
        }
    }
    // max components
    for(i=0; i<3; i++) {
        for(j=0; j<count; j++) {
            kmVec3 *v = &vertices[j];
            float comp = *(((float*)v)+i);
            if(comp > *(maxComps+i))
                ((float*)&aabbMax)[i] = comp;
        }
    }
    
    return (kmAABB){ aabbMin, aabbMax };   
}

// Taken from http://stackoverflow.com/questions/2405832/uievent-has-timestamp-how-can-i-generate-an-equivalent-value-on-my-own
NSTimeInterval icTimestamp()
{
    // get the timebase info -- different on phone and OSX
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    
    // get the time
    uint64_t absTime = mach_absolute_time();
    
    // apply the timebase info
    absTime *= info.numer;
    absTime /= info.denom;
    
    // convert nanoseconds into seconds and return
    return (NSTimeInterval) ((double) absTime / 1000000000.0);    
}

ICControl *ICControlForNode(ICNode *node)
{
    if ([node isKindOfClass:[ICControl class]]) {
        // The node itself is a control
        return (ICControl *)node;
    } else {
        ICControl *ancestorControl = (ICControl *)[node firstAncestorOfType:[ICControl class]];
        if (ancestorControl) {
            // The node has an ancestor which is a control
            return ancestorControl;
        }
    }
    return nil; // no control found for given node
}
