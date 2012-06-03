//  
//  Copyright (C) 2012 Tobias Lensing, http://icedcoffee-framework.org
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

#ifdef __IC_PLATFORM_IOS
#import <CoreGraphics/CoreGraphics.h>
#elif __IC_PLATFORM_MAC
#import <QuartzCore/QuartzCore.h>
#endif

#import "ICNodeVisitorDrawing.h"
#import "icTypes.h"

#define IC_PICK_COLOR_RESOLUTION 255.0f

@class ICRenderTexture;

@interface ICNodeVisitorPicking : ICNodeVisitorDrawing {
@private
    uint32_t _nodeIndex;
    ICRenderTexture *_renderTexture;
    NSMutableArray *_resultNodeStack;
    NSMutableArray *_appendNodesToStack;
    CGPoint _pickPoint;
}

@property (nonatomic, readonly) NSArray *resultNodeStack;

@property (nonatomic, readonly) CGPoint pickPoint;

- (void)beginWithPickPoint:(CGPoint)point;

- (void)end;

- (void)visit:(ICNode *)node;

- (void)visitSingleNode:(ICNode *)node;

- (icColor4B)pickColor;

// Used for merging picking results inside ICRenderTexture objects
- (void)appendNodesToResultStack:(NSArray *)nodes;

@end
