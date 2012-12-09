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

#import "Platforms/icGL.h"
#import "kazmath/vec4.h"
#import "icTypes.h"
#import "icMacros.h"

@class ICNode;
@class ICControl;
@class ICGLView;

#ifdef __cplusplus
extern "C" {
#endif

    /**
     @defgroup utility-functions Utility Functions
     @{
     */
    
    ICOpenGLContext *icCreateAuxGLContextForView(ICGLView *view, BOOL share);
    
    /**
     @brief Calculates the next power of two for the given value
     */
    unsigned long icNextPOT(unsigned long x);
    
    /**
     @brief Applies a pick matrix on the current matrix stack
     
     @param x The x origin of the rectangle to be picked
     @param y The y origin of the rectangle to be picked
     @param width The width of the rectangle to be picked
     @param height The height of the rectangle to be picked
     @param viewport The OpenGL viewport from which the specified rectangle is picked
     
     This method computes a pick matrix for the specified rectangle with regard to the given
     viewport and multiplies that matrix with the current OpenGL matrix. You should set the
     current matrix mode to ``KM_GL_PROJECTION`` using ``kmGLMatrixMode()``.
     */
    void icPickMatrix(GLfloat x, GLfloat y, GLfloat width, GLfloat height, GLint viewport[4]);
    
    /**
     @brief Unprojects the given point from view to world coordinates using the specified viewport,
     projection and model-view matrices
     
     @param viewVect A pointer to a ``kmVec3`` defining the vector to unproject, in view (window)
     coordinates
     @param resultVect A pointer to a ``kmVec3`` receiving the resulting unprojected point
     @param viewport A pointer to a ``GLint`` array with four elements defining the OpenGL viewport
     to use for computing the unprojected point
     @param matProjection The projection matrix to be used to compute the unprojection
     @param matModelView The model view matrix to be used to compute unprojection
     
     @return Returns ``YES`` if the unprojection could be performed successfully or ``NO``
     otherwise. If the unprojection succeeded, ``resultVect`` contains the unprojected point
     in world coordinates upon return.
     */
    BOOL icUnproject(kmVec3 *viewVect,
                     kmVec3 *resultVect, 
                     GLint *viewport,
                     kmMat4 *matProjection,
                     kmMat4 *matModelView);
    
    /**
     @brief Projects the given point from world to view coordinates using the specified viewport,
     projection and model-view matrices

     @param worldVect A pointer to a ``kmVec3`` defining the vector to project, in world coordinates
     @param resultVect A pointer to a ``kmVec3`` receiving the resulting projected point
     @param viewport A pointer to a ``GLint`` array with four elements defining the OpenGL viewport
     to use for computing the projected point
     @param matProjection The projection matrix to be used to compute the projection
     @param matModelView The model view matrix to be used to compute projection

     @return Returns ``YES`` if the projection could be performed successfully or ``NO`` otherwise.
     If the projection succeeded, ``resultVect`` contains the projected point in view (window)
     coordinates upon return.
     */
    BOOL icProject(kmVec3 *worldVect,
                   kmVec3 *resultVect,
                   GLint *viewport,
                   kmMat4 *matProjection,
                   kmMat4 *matModelView);
    
    /**
     @brief Computes an axis-aligned bounding box for the given vertices
     
     @param vertices An array of ``kmVec3`` vectors defining the vertices' positions
     @param count An ``int`` defining the number of vertices in the given array
     
     @return Returns a ``kmAABB`` defining the axis-aligned bounding box containing the vertices.
     */
    kmAABB icComputeAABBFromVertices(kmVec3 *vertices, int count);
    
    /**
     @brief Returns a timestamp for the current point in time for use with ``NSEvent``/``UIEvent``
     */
    NSTimeInterval icTimestamp();
    
    /**
     @brief Returns the control for a given node
     
     If the given node itself is kind of ICControl, simply returns that node. Otherwise,
     this method retrieves the first ancestor of ``node`` that is kind of ICControl.
     */
    ICControl *ICControlForNode(ICNode *node);
    
    /** @} */
    
#ifdef __cplusplus
}
#endif
