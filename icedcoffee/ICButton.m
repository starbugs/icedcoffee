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

#import "ICButton.h"
#import "ICLabel.h"
#import "ICScale9Sprite.h"
#import "ICTextureLoader.h"

@interface ICButton (Private)
- (void)centerLabel;
@end

@interface ICButton (NotificationHandlers)
- (void)labelTextDidChange:(NSNotification *)notification;
- (void)labelFontDidChange:(NSNotification *)notification;
@end

@implementation ICButton

@synthesize label = _label;
@synthesize background = _background;

- (id)initWithSize:(CGSize)size
{
    if ((self = [super initWithSize:size])) {
        self.label = [ICLabel labelWithText:@"Button" fontName:@"Lucida Grande" fontSize:12];
        self.label.color = (icColor4B){0,0,0,255};

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(labelTextDidChange:)
                                                     name:ICLabelTextDidChange
                                                   object:self.label];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(labelFontDidChange:)
                                                     name:ICLabelFontDidChange
                                                   object:self.label];
        
        NSString *textureFile = [[NSBundle mainBundle] pathForResource:@"button_light_normal" ofType:@"png"];
        ICTexture2D *texture = [ICTextureLoader loadTextureFromFile:textureFile];
        self.background = [ICScale9Sprite spriteWithTexture:texture scale9Rect:CGRectMake(5, 5, 110, 11)];
        [self.background setSize:self.size];
        
        [self addChild:self.background];
        [self addChild:self.label];
        
        [self centerLabel];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.label = nil;
    self.background = nil;
    
    [super dealloc];
}

@end

@implementation ICButton (Private)

- (void)centerLabel
{
    [self.label centerNode];
    [self.label setPositionY:self.label.position.y + 1];    
}

@end

@implementation ICButton (NotificationHandlers)

- (void)labelTextDidChange:(NSNotification *)notification
{
    [self centerLabel];
    [self setNeedsDisplay];
}

- (void)labelFontDidChange:(NSNotification *)notification
{
    [self centerLabel];
    [self setNeedsDisplay];
}

@end
