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

@property (nonatomic, readonly) ICShaderValueType type;

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

- (int)intValue;
- (float)floatValue;
- (kmVec2)vec2Value;
- (kmVec3)vec3Value;
- (kmVec4)vec4Value;
- (kmMat4)mat4Value;

@end
