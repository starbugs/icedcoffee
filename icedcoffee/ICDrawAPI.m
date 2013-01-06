//
//  Copyright (C) 2013 Tobias Lensing, Marcus Tillmanns
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

#import "ICDrawAPI.h"
#import "ICLine2D.h"
#import "ICNodeVisitorDrawing.h"

@implementation ICDrawAPI

+ (void)drawLine2DFrom:(kmVec3)from to:(kmVec3)to color:(icColor4B)color lineWidth:(float)lineWidth
{
    ICNodeVisitor *visitor = [[ICNodeVisitorDrawing alloc] initWithOwner:nil];
    
    ICLine2D *line = [[ICLine2D alloc] initWithOrigin:from target:to
                                            lineWidth:lineWidth antialiasStrength:0 color:color];
    [visitor visit:line];
    [line release];
    
    [visitor release];
}

+ (void)drawRect2D:(kmVec4)rect z:(float)z color:(icColor4B)color lineWidth:(float)lineWidth
{
    kmVec3 v0, v1, v2, v3;
    v0 = kmVec3Make(rect.x, rect.y, z);
    v1 = kmVec3Make(rect.x + rect.width, rect.y, z);
    v2 = kmVec3Make(rect.x + rect.width, rect.y + rect.height, z);
    v3 = kmVec3Make(rect.x, rect.y + rect.height, z);

    [[self class] drawLine2DFrom:v0 to:v1 color:color lineWidth:lineWidth];
    [[self class] drawLine2DFrom:v1 to:v2 color:color lineWidth:lineWidth];
    [[self class] drawLine2DFrom:v2 to:v3 color:color lineWidth:lineWidth];
    [[self class] drawLine2DFrom:v3 to:v0 color:color lineWidth:lineWidth];
}

@end
