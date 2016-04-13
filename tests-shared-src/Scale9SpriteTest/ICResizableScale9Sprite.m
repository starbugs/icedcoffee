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

#import "ICResizableScale9Sprite.h"
#import "icedcoffee/ICHostViewController.h"
#import "icedcoffee/Platforms/Mac/ICGLView.h"
#import "icedcoffee/ICLabel.h"

#define RESIZE_BAR_THICKNESS 10

enum {
    ResizeEdgeLeft = 1 << 0,
    ResizeEdgeTop = 1 << 1,
    ResizeEdgeRight = 1 << 2,
    ResizeEdgeBottom = 1 << 3
};

@implementation ICResizableScale9Sprite

@synthesize dropShadowSprite = _dropShadowSprite;

- (id)initWithTexture:(ICTexture2D *)texture scale9Rect:(CGRect)scale9Rect
{
    if ((self = [super initWithTexture:texture scale9Rect:scale9Rect])) {
        ICLabel *label = [ICLabel labelWithText:@"Drag and resize me" fontName:@"Lucida Grande" fontSize:12];
        [label setColor:(icColor4B){0,0,0,255}];
        [self addChild:label];
    }
    return self;
}

- (void)setSize:(kmVec3)size
{
    [super setSize:size];
    [[self.children objectAtIndex:0] centerNode];
}

- (uint)resizeEdgeWithLocalLocation:(CGPoint)localLocation
{
    uint resizeEdge = 0x0;
    if (localLocation.x < RESIZE_BAR_THICKNESS) {
        resizeEdge |= ResizeEdgeLeft;
    } 
    if (localLocation.x >= self.size.width - RESIZE_BAR_THICKNESS) {
        resizeEdge |= ResizeEdgeRight;
    } 
    if (localLocation.y < RESIZE_BAR_THICKNESS) {
        resizeEdge |= ResizeEdgeTop;
    }
    if (localLocation.y >= self.size.height - RESIZE_BAR_THICKNESS) {
        resizeEdge |= ResizeEdgeBottom;
    }
    return resizeEdge;
}

- (void)mouseExited:(ICMouseEvent *)event
{
    [[self hostViewController] setCursor:[NSCursor arrowCursor]];
}

- (void)mouseMoved:(ICMouseEvent *)event
{
    if (_isDragging)
        return;
    
    CGPoint localLocation = kmVec3ToCGPoint([event locationInNode:self]);
    NSLog(@"localLocation: %f, %f", localLocation.x, localLocation.y);
    
    uint resizeEdge = [self resizeEdgeWithLocalLocation:localLocation];

    if (resizeEdge & ResizeEdgeLeft || resizeEdge & ResizeEdgeRight)
        [[self hostViewController] setCursor:[NSCursor resizeLeftRightCursor]];
    else if (resizeEdge & ResizeEdgeTop || resizeEdge & ResizeEdgeBottom)
        [[self hostViewController] setCursor:[NSCursor resizeUpDownCursor]];        
    else
        [[self hostViewController] setCursor:[NSCursor openHandCursor]];
}

- (void)mouseDown:(ICMouseEvent *)event
{
    CGPoint location = [event locationInHostView];
    CGPoint localLocation = kmVec3ToCGPoint([event locationInNode:self]);

    _resizeEdge = [self resizeEdgeWithLocalLocation:localLocation];
    
    _dragStartLocation = location;
    _dragStartPosition = [self position];
    _dragStartsize = [self size];
    
    _isDragging = YES;
    
    if (!_resizeEdge)
        [[self hostViewController] setCursor:[NSCursor closedHandCursor]];    
}

- (void)mouseUp:(ICMouseEvent *)event
{
    _isDragging = NO;
    
    if (!_resizeEdge)
        [[self hostViewController] setCursor:[NSCursor openHandCursor]];
}

- (void)mouseDragged:(ICMouseEvent *)event
{
    CGPoint location = [event locationInHostView];
    
    CGPoint dragOffset;
    CGPoint sizeOffset;

    dragOffset.x = floorf(location.x - _dragStartLocation.x);
    dragOffset.y = floorf(location.y - _dragStartLocation.y);
    sizeOffset = dragOffset;
    
    switch (_resizeEdge) {
        case ResizeEdgeBottom | ResizeEdgeLeft:
        {
            dragOffset.y = 0;
            sizeOffset.x *= -1;
            break;
        }
        case ResizeEdgeBottom | ResizeEdgeRight:
        {
            dragOffset.x = 0;
            dragOffset.y = 0;
            break;
        }
        case ResizeEdgeTop | ResizeEdgeLeft:
        {
            sizeOffset.x *= -1;
            sizeOffset.y *= -1;
            break;
        }
        case ResizeEdgeTop | ResizeEdgeRight:
        {
            dragOffset.x = 0;
            sizeOffset.y *= -1;
            break;
        }
        case ResizeEdgeLeft:
        {
            dragOffset.y = 0;
            sizeOffset.x *= -1;
            sizeOffset.y = 0;
            break;
        }
        case ResizeEdgeTop:
        {
            dragOffset.x = 0;
            sizeOffset.x = 0;
            sizeOffset.y *= -1;
            break;
        }            
        case ResizeEdgeBottom:
        {
            dragOffset.x = 0;
            dragOffset.y = 0;
            sizeOffset.x = 0;
            break;
        }            
        case ResizeEdgeRight:
        {
            dragOffset.x = 0;
            dragOffset.y = 0;
            sizeOffset.y = 0;
            break;
        }
        default:
            sizeOffset.x = 0;
            sizeOffset.y = 0;
            break;
    }
    
    [self setPositionX:_dragStartPosition.x + dragOffset.x];
    [self setPositionY:_dragStartPosition.y + dragOffset.y];
    
    kmVec3 newsize = kmNullVec3;
    newsize.width = _dragStartsize.width + sizeOffset.x;
    newsize.height = _dragStartsize.height + sizeOffset.y;
    [self setSize:newsize];
    
    NSLog(@"%@", kmVec3Description(self.size));
    
    [_dropShadowSprite setPositionX:self.position.x - 22];
    [_dropShadowSprite setPositionY:self.position.y - 22];
    [_dropShadowSprite setSize:(kmVec3){self.size.width + 44, self.size.height + 44, 0}];
}

@end
