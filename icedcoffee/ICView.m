//  
//  Copyright (C) 2012 Tobias Lensing
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

- (id)initWithWidth:(int)w height:(int)h
{
    return [self initWithWidth:w height:h pixelFormat:kICTexture2DPixelFormat_RGBA8888];
}

- (id)initWithWidth:(int)w height:(int)h pixelFormat:(ICTexture2DPixelFormat)format
{
    if ((self = [super initWithWidth:w height:h pixelFormat:format])) {
        self.subScene = [[[ICScene alloc] initWithHostViewController:nil] autorelease];
        [self setDisplayMode:kICRenderTextureDisplayMode_Conditional];
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
