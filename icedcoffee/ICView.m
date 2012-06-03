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

#import "ICView.h"
#import "ICScene.h"

@implementation ICView

+ (id)viewWithWidth:(int)w
             height:(int)h
{
    return [[[[self class] alloc] initWithWidth:w height:h] autorelease];
}

+ (id)viewWithWidth:(int)w
             height:(int)h 
        depthBuffer:(BOOL)depthBuffer
{
    return [[[[self class] alloc] initWithWidth:w height:h depthBuffer:depthBuffer] autorelease];    
}

+ (id)viewWithWidth:(int)w
             height:(int)h
        pixelFormat:(ICPixelFormat)pixelFormat
{
    return [[[[self class] alloc] initWithWidth:w height:h pixelFormat:pixelFormat] autorelease];
}

+ (id)viewWithWidth:(int)w
             height:(int)h
        pixelFormat:(ICPixelFormat)pixelFormat
  depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
{
    return [[[[self class] alloc] initWithWidth:w
                                         height:h
                                    pixelFormat:pixelFormat
                              depthBufferFormat:depthBufferFormat] autorelease];    
}


- (id)initWithWidth:(int)w
             height:(int)h
{
    return [super initWithWidth:w height:h];
}

- (id)initWithWidth:(int)w
             height:(int)h
        depthBuffer:(BOOL)depthBuffer
{
    return [super initWithWidth:w height:h depthBuffer:depthBuffer];
}

- (id)initWithWidth:(int)w
             height:(int)h
        pixelFormat:(ICPixelFormat)format
{
    return [super initWithWidth:w height:h pixelFormat:format];
}

- (id)initWithWidth:(int)w
             height:(int)h
        pixelFormat:(ICPixelFormat)format
  depthBufferFormat:(ICDepthBufferFormat)depthBufferFormat
{
    if ((self = [super initWithWidth:w height:h pixelFormat:format depthBufferFormat:depthBufferFormat])) {
        self.subScene = [[[ICScene alloc] initWithHostViewController:nil] autorelease];
        [self.subScene setClearColor:(icColor4B){0,0,0,0}];
        [self setFrameUpdateMode:kICFrameUpdateMode_OnDemand];
    }
    return self;    
}

- (void)dealloc
{
    [super dealloc];
}

- (void)addSubView:(ICView *)subView
{
    [self.subScene addChild:subView];
}

- (void)removeSubView:(ICView *)subView
{
    [self.subScene removeChild:subView];
}

- (NSArray *)subViews
{
    NSMutableArray *subViews = [NSMutableArray arrayWithCapacity:[self.subScene.children count]];
    for (ICNode *child in self.subScene.children) {
        if ([child isKindOfClass:[ICView class]]) {
            [subViews addObject:child];
        }
    }
    return subViews;
}


@end
