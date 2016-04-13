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

#import "ICShaderValue.h"

@implementation ICShaderValue

@synthesize type = _type;

+ (id)shaderValueWithInt:(int)value
{
    return [[[[self class] alloc] initWithInt:value] autorelease];
}

+ (id)shaderValueWithFloat:(float)value
{
    return [[[[self class] alloc] initWithFloat:value] autorelease];
}

+ (id)shaderValueWithVec2:(kmVec2)value
{
    return [[[[self class] alloc] initWithVec2:value] autorelease];
}

+ (id)shaderValueWithVec3:(kmVec3)value
{
    return [[[[self class] alloc] initWithVec3:value] autorelease];
}

+ (id)shaderValueWithVec4:(kmVec4)value
{
    return [[[[self class] alloc] initWithVec4:value] autorelease];
}

+ (id)shaderValueWithMat4:(kmMat4)value
{
    return [[[[self class] alloc] initWithMat4:value] autorelease];
}

+ (id)shaderValueWithSampler2D:(int)value
{
    return [[[[self class] alloc] initWithSampler2D:value] autorelease];
}

- (id)initWithInt:(int)value
{
    if ((self = [super init])) {
        _type = ICShaderValueTypeInt;
        _value.intValue = value;
    }
    return self;
}

- (id)initWithFloat:(float)value
{
    if ((self = [super init])) {
        _type = ICShaderValueTypeFloat;
        _value.floatValue = value;
    }
    return self;
    
}

- (id)initWithVec2:(kmVec2)value
{
    if ((self = [super init])) {
        _type = ICShaderValueTypeVec2;
        _value.vec2Value = value;
    }
    return self;
    
}

- (id)initWithVec3:(kmVec3)value
{
    if ((self = [super init])) {
        _type = ICShaderValueTypeVec3;
        _value.vec3Value = value;
    }
    return self;
    
}

- (id)initWithVec4:(kmVec4)value
{
    if ((self = [super init])) {
        _type = ICShaderValueTypeVec4;
        _value.vec4Value = value;
    }
    return self;
    
}

- (id)initWithMat4:(kmMat4)value
{
    if ((self = [super init])) {
        _type = ICShaderValueTypeMat4;
        _value.mat4Value = value;
    }
    return self;
    
}

- (id)initWithSampler2D:(int)value
{
    if ((self = [super init])) {
        _type = ICShaderValueTypeSampler2D;
        _value.intValue = value;
    }
    return self;    
}

- (id)initWithShaderValue:(ICShaderValue *)value
{
    if ((self = [super init])) {
        _value = value->_value;
    }
    return self;
}

- (int)intValue
{
    return _value.intValue;
}

- (float)floatValue
{
    return _value.floatValue;    
}

- (kmVec2)vec2Value
{
    return _value.vec2Value;
}

- (kmVec3)vec3Value
{
    return _value.vec3Value;    
}

- (kmVec4)vec4Value
{
    return _value.vec4Value;
}

- (kmMat4)mat4Value
{
    return _value.mat4Value;
}


@end
