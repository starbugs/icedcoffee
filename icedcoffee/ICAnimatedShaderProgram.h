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

#import "ICShaderProgram.h"

/**
 @brief Defines a generic animated shader program
 
 ICAnimatedShaderProgram is a convenience class extending the functionality of ICShaderProgram
 to allow for continuously animated shaders based on a time uniform.
 
 Shaders used with this class must provide a ``time`` uniform of type ``float``.
 ICAnimatedShaderProgram automatically updates that time uniform with the current
 host view controller's ICHostViewController::elapsedTime value when the program is used.
 */
@interface ICAnimatedShaderProgram : ICShaderProgram

/**
 @brief Refreshes the ``time`` value and updates the receiver's uniforms
 
 The ICAnimatedShaderProgram class overrides ICShaderProgram::updateUniforms to add automatic
 updates of the ``time`` uniform. ``time`` is set to the current host view controller's
 ICHostViewController::elapsedTime value before the super classes' implementation is called.
 */
- (void)updateUniforms;

@end
