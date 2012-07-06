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

#pragma once

// General Configuration

// GL state cache (incomplete)
#ifndef IC_ENABLE_GL_STATE_CACHE
#define IC_ENABLE_GL_STATE_CACHE 1
#endif


// Logging and Debugging

// Output debug log messages to console for hit test results
#ifndef IC_ENABLE_DEBUG_HITTEST
#define IC_ENABLE_DEBUG_HITTEST 0
#endif

// Output debug log messages to console when picking is being performed
#ifndef IC_ENABLE_DEBUG_PICKING
#define IC_ENABLE_DEBUG_PICKING 0
#endif

#ifndef IC_ENABLE_DEBUG_TOUCH_DISPATCHER
#define IC_ENABLE_DEBUG_TOUCH_DISPATCHER 0
#endif
