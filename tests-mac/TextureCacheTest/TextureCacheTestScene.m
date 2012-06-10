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

#import "TextureCacheTestScene.h"
#import "ImageSprite.h"
#import "AppDelegate.h"

@implementation TextureCacheTestScene

@synthesize dragStartPosition = _dragStartPosition;
@synthesize dragOffset = _dragOffset;
@synthesize textureFiles = _textureFiles;

- (id)initWithHostViewController:(ICHostViewController *)hostViewController
{
    if ((self = [super initWithHostViewController:hostViewController])) {
        NSMutableArray *files = [NSMutableArray array];
        NSString *landscapesPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"landscapes"];
        NSDirectoryEnumerator *enumerator= [[NSFileManager defaultManager] enumeratorAtPath:landscapesPath];
        NSString *filename;
        while (filename = [enumerator nextObject]) {
            if ([[filename pathExtension] isEqualToString:@"jpg"] ||
                [[filename pathExtension] isEqualToString:@"jpeg"]) {
                [files addObject:[landscapesPath stringByAppendingPathComponent:filename]];
            }
        }
        self.textureFiles = files;        
        
        ICSprite *backgroundSprite = [ICSprite sprite];
        [backgroundSprite setSize:(kmVec3){624, 624, 0}];
        [backgroundSprite setColor:(icColor4B){0,0,0,10}];
        [self addChild:backgroundSprite];
        
        uint col=0, row=0;
        
        for (NSString *textureFile in self.textureFiles) {
            ImageSprite *sprite = [ImageSprite sprite];
            [sprite setPosition:(kmVec3){32.0f + col++ * (MAX_WIDTH + 16.0f), 32.0f + row * (MAX_HEIGHT + 16.0f), 0}];
            [self addChild:sprite];
            [self.hostViewController.textureCache loadTextureFromFileAsync:textureFile
                                                                withTarget:self
                                                                withObject:sprite];
            
            if (col == NUM_COLUMNS) {
                col = 0;
                ++row;
            }
        }
    }
    return self;
}

- (void)textureDidLoad:(ICTexture2D *)texture object:(id)object
{
    ICSprite *sprite = (ICSprite *)object;
    [sprite setTexture:texture];
    
    CGSize maxSize = CGSizeMake(MAX_WIDTH, MAX_HEIGHT);
    CGSize scaledSize;
    CGSize size = [texture size];
    
    if (size.width >= size.height) {
        scaledSize.width = size.width > maxSize.width ? maxSize.width : size.width;
        scaledSize.height = size.height / size.width * scaledSize.width;
    } else {
        scaledSize.height = size.height > maxSize.height ? maxSize.height : size.height;
        scaledSize.width  = size.width / size.height * scaledSize.height;
    }
    
    [sprite setSize:(kmVec3){scaledSize.width, scaledSize.height, 0}];
    [sprite setPositionX:sprite.position.x + (maxSize.width - scaledSize.width) / 2];
    [sprite setPositionY:sprite.position.y + (maxSize.height - scaledSize.height) / 2];    
}

- (void)scrollWheel:(NSEvent *)event
{
    ICCameraPointsToPixelsPerspective *camera = (ICCameraPointsToPixelsPerspective *)self.camera;
    [camera setZoomFactor:camera.zoomFactor - event.scrollingDeltaY / 1000];
}

- (void)mouseDown:(NSEvent *)event
{
    CGPoint location = [event locationInWindow];
    _dragStartPosition = (kmVec3){location.x, location.y, 0};
    _dragOffset = (kmVec3){location.x - self.position.x, location.y - self.position.y, 0};
}

- (void)mouseDragged:(NSEvent *)event
{
    CGPoint location = [event locationInWindow];
    [self setPositionX:_dragStartPosition.x + location.x - _dragStartPosition.x - _dragOffset.x];
    [self setPositionY:_dragStartPosition.y + location.y - _dragStartPosition.y - _dragOffset.y];
}

@end
