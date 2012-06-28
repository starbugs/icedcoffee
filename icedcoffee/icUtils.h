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

#ifdef __cplusplus
extern "C" {
#endif

    /**
     @brief Calculates the next power of two for the given value
     */
    unsigned long icNextPOT(unsigned long x);
    
    /**
     @brief Applies a pick matrix on the current matrix stack (projection)
     */
    void icPickMatrix(GLfloat x, GLfloat y, GLfloat width, GLfloat height, GLint viewport[4]);
    
    /**
     @brief Unprojects a point from view to world coordinates using the specified viewport,
     projection and model-view matrices
     
     @return Returns YES if the unprojection could be performed successfully or NO otherwise.
     */
    BOOL icUnproject(kmVec3 *viewVect,
                     kmVec3 *resultVect, 
                     GLint *viewport,
                     kmMat4 *matProjection,
                     kmMat4 *matModelView);
    
    /**
     @brief Projects a point from world to view coordinates using the specified viewport,
     projection and model-view matrices
     
     @return Returns YES if the projection could be performed successfully or NO otherwise.
     */
    BOOL icProject(kmVec3 *worldVect,
                   kmVec3 *resultVect,
                   GLint *viewport,
                   kmMat4 *matProjection,
                   kmMat4 *matModelView);
    
    kmAABB icComputeAABBFromVertices(kmVec3 *vertices, int count);
    
#ifdef __cplusplus
}
#endif
