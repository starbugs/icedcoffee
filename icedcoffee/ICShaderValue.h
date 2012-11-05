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
#import "icTypes.h"

/**
 @brief Represents the value of a shader program's uniform
 
 The ICShaderValue class represents a value of an ICShaderUniform object. ICShaderUniform objects
 correspond to shader uniforms defined in GLSL shaders interfaced via ICShaderProgram objects.
 
 Shader values exhibit a certain type, defined in the source code of a given shader program.
 The ICShaderValue class must be initialized with the correct type for its target uniform.
 Shader values can be assigned to shader uniforms using ICShaderUniform::setToShaderValue:
 implemented in the ICShaderUniform class.
 */
@interface ICShaderValue : NSObject {
@protected
    ICShaderValueType _type;
    
    union ShaderValue {
        int intValue;
        float floatValue;
        kmVec2 vec2Value;
        kmVec3 vec3Value;
        kmVec4 vec4Value;
        kmMat4 mat4Value;
    } _value;
}

#pragma mark - Creating Shader Value Objects
/** @name Creating Shader Value Objects */
 
+ (id)shaderValueWithInt:(int)value;
+ (id)shaderValueWithFloat:(float)value;
+ (id)shaderValueWithVec2:(kmVec2)value;
+ (id)shaderValueWithVec3:(kmVec3)value;
+ (id)shaderValueWithVec4:(kmVec4)value;
+ (id)shaderValueWithMat4:(kmMat4)value;
+ (id)shaderValueWithSampler2D:(int)value;

- (id)initWithInt:(int)value;
- (id)initWithFloat:(float)value;
- (id)initWithVec2:(kmVec2)value;
- (id)initWithVec3:(kmVec3)value;
- (id)initWithVec4:(kmVec4)value;
- (id)initWithSampler2D:(int)value;
- (id)initWithShaderValue:(ICShaderValue *)value;
- (id)initWithMat4:(kmMat4)value;

#pragma mark - Retrieving the Value from the Object
/** @name Retrieving the Value from the Object */

- (int)intValue;
- (float)floatValue;
- (kmVec2)vec2Value;
- (kmVec3)vec3Value;
- (kmVec4)vec4Value;
- (kmMat4)mat4Value;

#pragma mark - Obtaining the Value Type
/** @name Obtaining the Value Type */

@property (nonatomic, readonly) ICShaderValueType type;

@end
