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

#import "ICButton.h"
#import "ICLabel.h"
#import "ICScale9Sprite.h"
#import "ICTextureCache.h"
#import "ICRectangle.h"
#import "icMacros.h"

#ifdef __IC_PLATFORM_IOS
#define DEFAULT_BUTTON_FONT @"Helvetica"
#elif defined(__IC_PLATFORM_MAC)
#define DEFAULT_BUTTON_FONT @"Lucida Grande"
#endif


@interface ICButton (Private)
- (void)centerLabel;
@end

@interface ICButton (NotificationHandlers)
- (void)labelTextDidChange:(NSNotification *)notification;
- (void)labelFontDidChange:(NSNotification *)notification;
@end

@implementation ICButton

@synthesize label = _label;
@synthesize mixesBackgroundStates = _mixesBackgroundStates;

+ (id)buttonWithSize:(CGSize)size
{
    return [[[[self class] alloc] initWithSize:size] autorelease];
}

- (id)initWithSize:(CGSize)size
{
    if ((self = [super initWithSize:size])) {
        self.clipsChildren = YES;
        
        _mouseButtonPressed = NO;
        _mixesBackgroundStates = YES;
        
        _activeBackgrounds = [[NSMutableDictionary alloc] init];
        _backgroundsByControlState = [[NSMutableDictionary alloc] init];
        
        ICRectangle *normalBackground = [ICRectangle viewWithSize:size];
        [normalBackground setName:@"Normal Background"];
        [self setBackground:normalBackground forState:ICControlStateNormal];
        
        ICRectangle *pressedBackground = [ICRectangle viewWithSize:size];
        [pressedBackground setName:@"Pressed Background"];
        pressedBackground.gradientStartColor = (icColor4B){220,220,220,255};
        pressedBackground.gradientEndColor = (icColor4B){180,180,180,255};
        [self setBackground:pressedBackground forState:ICControlStatePressed];
        
        self.label = [ICLabel labelWithText:@"Button" fontName:DEFAULT_BUTTON_FONT fontSize:12];
        self.label.name = @"Button label (view)";
        self.label.userInteractionEnabled = NO;
        self.label.color = (icColor4B){0,0,0,255};

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(labelTextDidChange:)
                                                     name:ICLabelTextDidChange
                                                   object:self.label];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(labelFontDidChange:)
                                                     name:ICLabelFontDidChange
                                                   object:self.label];
        
        self.state = ICControlStateNormal;
        
/*        NSString *textureFile = [[NSBundle mainBundle] pathForResource:@"button_light_normal" ofType:@"png"];
        ICTexture2D *texture = [[ICTextureCache currentTextureCache] loadTextureFromFile:textureFile];
        self.background = [ICScale9Sprite spriteWithTexture:texture scale9Rect:CGRectMake(5, 5, 110, 11)];*/
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_activeBackgrounds release];
    [_backgroundsByControlState release];
    
    self.label = nil;
    
    [super dealloc];
}

- (void)cleanUpAllBackgrounds
{
    for (NSNumber *state in _activeBackgrounds) {
        ICView *activeBackground = [_activeBackgrounds objectForKey:state];
        activeBackground.isVisible = NO;
    }
    [_activeBackgrounds removeAllObjects];    
}

- (void)activateBackgroundForState:(ICControlState)state
{
    ICView *background = [self backgroundForState:state];
    if (background) {
        [_activeBackgrounds setObject:background forKey:[NSNumber numberWithUnsignedLong:state]];
        background.isVisible = YES;
    }
}

- (void)setState:(ICControlState)state
{
    [super setState:state];
    if (state & ICControlStateDisabled && [self backgroundForState:ICControlStateDisabled]) {
        [self cleanUpAllBackgrounds];
        [self activateBackgroundForState:ICControlStateDisabled];
    } else {
        [self cleanUpAllBackgrounds];
        if (state & ICControlStatePressed && [self backgroundForState:ICControlStatePressed]) {
            [self activateBackgroundForState:ICControlStatePressed];
        } else {
            [self activateBackgroundForState:ICControlStateNormal];
        }
    }
    if (state & ICControlStateSelected && [self backgroundForState:ICControlStateSelected]) {
        if (!_mixesBackgroundStates)
            [self cleanUpAllBackgrounds];
        [self activateBackgroundForState:ICControlStateSelected];
    }
    if (state & ICControlStateHighlighted && [self backgroundForState:ICControlStateHighlighted]) {
        if (!_mixesBackgroundStates)
            [self cleanUpAllBackgrounds];
        [self activateBackgroundForState:ICControlStateHighlighted];        
    }
    if (!_mixesBackgroundStates && state & (ICControlStateSelected | ICControlStateHighlighted) &&
        [self backgroundForState:ICControlStateSelected | ICControlStateHighlighted]) {
        [self activateBackgroundForState:ICControlStateSelected | ICControlStateHighlighted];
    }
}

- (void)setBackground:(ICView *)background forState:(ICControlState)state
{
    ICView *existingBackground = [self backgroundForState:state];
    if (existingBackground) {
        [self removeBackgroundForState:state];
        existingBackground = nil;
    }
    [_backgroundsByControlState setObject:background forKey:[NSNumber numberWithUnsignedLong:state]];
    [self addChild:background];
    background.isVisible = NO;
}

- (void)removeBackgroundForState:(ICControlState)state
{
    ICView *background = [[self backgroundForState:state] retain];
    [_backgroundsByControlState removeObjectForKey:[NSNumber numberWithUnsignedLong:state]];
    [self removeChild:background];
    [background release];
}

- (ICView *)backgroundForState:(ICControlState)state
{
    return [_backgroundsByControlState objectForKey:[NSNumber numberWithUnsignedLong:state]];
}

#ifdef __IC_PLATFORM_MAC

- (void)mouseDown:(ICMouseEvent *)event
{
    self.state |= ICControlStatePressed;
    _mouseButtonPressed = YES;
}

- (void)mouseUp:(ICMouseEvent *)event
{
    self.state &= ~ICControlStatePressed;
    _mouseButtonPressed = NO;
}

- (void)mouseEntered:(ICMouseEvent *)event
{
    if (_mouseButtonPressed) {
        self.state |= ICControlStatePressed;
    }
}

- (void)mouseExited:(ICMouseEvent *)event
{
    if (_mouseButtonPressed) {
        self.state &= ~ICControlStatePressed;
    }
}

#elif defined(__IC_PLATFORM_IOS)

- (void)touchesBegan:(NSSet *)touches withTouchEvent:(ICTouchEvent *)event
{
    self.state |= ICControlStatePressed;
}

- (void)touchesEnded:(NSSet *)touches withTouchEvent:(ICTouchEvent *)event
{
    self.state &= ~ICControlStatePressed;
}

#endif

- (void)layoutChildren
{
    [self centerLabel];
    for (NSNumber *state in _backgroundsByControlState) {
        [(ICView *)[_backgroundsByControlState objectForKey:state] setSize:self.size];
    }
}

- (void)setLabel:(ICLabel *)label
{
    if (_label)
        [self removeChild:_label];
    [_label release];
    _label = [label retain];
    if (_label)
        [self addChild:_label];    
}

@end

@implementation ICButton (Private)

- (void)centerLabel
{
    [self.label centerNodeOpticallyRounded:YES];
}

@end

@implementation ICButton (NotificationHandlers)

- (void)labelTextDidChange:(NSNotification *)notification
{
    [self setNeedsLayout];
}

- (void)labelFontDidChange:(NSNotification *)notification
{
    [self setNeedsLayout];
}

@end
