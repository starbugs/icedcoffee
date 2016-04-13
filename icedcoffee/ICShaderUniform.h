//  
//  Copyright (C) 2016 Tobias Lensing, Marcus Tillmanns
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
#import "icTypes.h"
#import "ICShaderValue.h"

/** @brief Represents a Shader Uniform
 
 The ICShaderUniform class provides an interface to a uniform used by a shader program
 implemented in an ICShaderProgram object. You do not need to create ICShaderUniform objects
 manually usually. The uniform itself is defined in the shader program's GLSL source code.
 ICShaderProgram enumerates all uniforms implemented by a given shader program and automatically
 creates ICShaderUniform objects for them. The ICShaderUniform class is then used to set uniforms
 to a certain value represented by the ICShaderValue class.
 */
@interface ICShaderUniform : ICShaderValue {
@protected
    GLint _location;
}

#pragma mark - Creating a Shader Uniform Representation
/** @name Creating a Shader Uniform Representation */

+ (id)shaderUniformWithType:(ICShaderValueType)type location:(GLint)location;

- (id)initWithType:(ICShaderValueType)type location:(GLint)location;

#pragma mark - Setting the Uniform's Value
/** @name Setting the Uniform's Value */

- (BOOL)setToShaderValue:(ICShaderValue *)value;

#pragma mark - Obtaining the Uniform's Location
/** @name Obtaining the Uniform's Location */

@property (nonatomic, assign) GLint location;

@end
