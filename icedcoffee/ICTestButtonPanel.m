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

#import "ICTestButtonPanel.h"
#import "ICButton.h"

@implementation ICTestButtonPanel

@synthesize previousSceneButton = _previousSceneButton;
@synthesize nextSceneButton = _nextSceneButton;
@synthesize statusLabel = _statusLabel;
@synthesize hintLabel = _hintLabel;

- (id)initWithSize:(CGSize)size
{
    if ((self = [super initWithSize:size])) {
        self.autoresizingMask = ICAutoResizingMaskWidthSizable |
        ICAutoResizingMaskTopMarginFlexible;
        self.drawsBackground = YES;
        self.background.color = (icColor4B){0,0,0,180};
        
        _nextSceneButton = [[ICButton buttonWithSize:CGSizeMake(80, 21)] retain];
        _nextSceneButton.label.text = @"Next";
        _nextSceneButton.autoresizingMask = ICAutoResizingMaskLeftMarginFlexible;
        [_nextSceneButton setPositionX:self.size.width - _nextSceneButton.size.width - 25];

        _previousSceneButton = [[ICButton buttonWithSize:CGSizeMake(80, 21)] retain];
        _previousSceneButton.label.text = @"Previous";
        _previousSceneButton.autoresizingMask = ICAutoResizingMaskLeftMarginFlexible;
        [_previousSceneButton setPositionX:_nextSceneButton.position.x - _previousSceneButton.size.width - 10];
        
        [self addChild:_previousSceneButton];
        [self addChild:_nextSceneButton];
        [_previousSceneButton centerNodeVerticallyRounded:YES];
        [_nextSceneButton centerNodeVerticallyRounded:YES];
        
        _statusLabel = [[ICLabel labelWithText:@"Showing Test i/n"
                                     fontName:@"Lucida Grande"
                                     fontSize:12] retain];
        [self addChild:_statusLabel];
        [_statusLabel setPositionX:25];
        [_statusLabel setPositionY:7];
        _statusLabel.autoresizesToTextSize = NO;
        _statusLabel.clipsChildren = YES;
        
        _hintLabel = [[ICLabel labelWithText:@"Author did not provide hints"
                                    fontName:@"Lucida Grande"
                                    fontSize:12] retain];
        [self addChild:_hintLabel];
        [_hintLabel setPositionX:25];
        [_hintLabel setPositionY:25];
        _hintLabel.autoresizesToTextSize = NO;
        _hintLabel.clipsChildren = YES;
        _hintLabel.color = (icColor4B){255,255,255,255};
        _hintLabel.gamma = 0.9f;
    }
    return self;
}

- (void)dealloc
{
    [_previousSceneButton release];
    [_nextSceneButton release];
    [_statusLabel release];
    [_hintLabel release];
    [super dealloc];
}

- (void)setSize:(kmVec3)size
{
    [super setSize:size];
    [_statusLabel setWidth:self.size.width - (_previousSceneButton.size.width + _nextSceneButton.size.width + 70)];
    [_hintLabel setWidth:self.size.width - (_previousSceneButton.size.width + _nextSceneButton.size.width + 70)];
}

@end
