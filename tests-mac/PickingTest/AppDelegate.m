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

#import "AppDelegate.h"
#import "ResponsiveSprite.h"
#import "ResponsiveView.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize hostViewController = _hostViewController;
@synthesize testScene = _testScene;
@synthesize camAngle = _camAngle;
@synthesize animateCamera = _animateCamera;

- (id)init
{
    if ((self = [super init])) {
        self.animateCamera = YES;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)update:(icTime)dt
{
    if (_animateCamera) {
        kmVec3 eyeOffset = kmVec3Make(cos(_camAngle)*200, sin(_camAngle)*-300, 0);
        ((ICUICamera *)self.testScene.camera).eyeOffset = eyeOffset;
        ((ICUICamera *)self.testScene.camera).lookAtOffset = (kmVec3){-50,-50,0};
        _camAngle += 0.1f * dt;
    } else {
        ((ICUICamera *)self.testScene.camera).eyeOffset = kmNullVec3;
        ((ICUICamera *)self.testScene.camera).lookAtOffset = kmNullVec3;
    }
}

- (void)setViewsWantRenderTextureBacking:(BOOL)flag
{
    NSArray *views = [self.testScene descendantsOfType:[ICView class]];
    for (ICView *view in views) {
        [view setWantsRenderTextureBacking:flag];
    }
    
    //[self.testScene debugLogBranch];
}

- (void)backingSwitchButtonClicked:(id)sender
{
    ICButton *button = (ICButton *)sender;
    if ([button.label.text isEqualToString:@"Without Render Textures"]) {
        button.label.text = @"With Render Textures";
        [self setViewsWantRenderTextureBacking:YES];
    } else {
        button.label.text = @"Without Render Textures";
        [self setViewsWantRenderTextureBacking:NO];
    }
}

- (void)animateButtonClicked:(id)sender
{
    ICButton *button = (ICButton *)sender;
    if ([button.label.text isEqualToString:@"Animated"]) {
        button.label.text = @"Not animated";
        self.animateCamera = NO;
    } else {
        button.label.text = @"Animated";
        self.animateCamera = YES;
    }    
}

- (void)setupScene
{
    self.testScene = [ICUIScene scene];

    NSString *filename = [[NSBundle mainBundle] pathForResource:@"thiswayup" ofType:@"png"];
    ICTexture2D *texture = [[ICTextureCache currentTextureCache] loadTextureFromFile:filename];
    ResponsiveSprite *rs = [ResponsiveSprite spriteWithTexture:texture];
    [self.testScene.contentView addChild:rs];
    
    ResponsiveView *rv = [[[ResponsiveView alloc] initWithSize:CGSizeMake(128, 128)] autorelease];
    [rv setPositionX:150];
    [self.testScene.contentView addChild:rv];
    
    ResponsiveView *nestedRV = [[[ResponsiveView alloc] initWithSize:CGSizeMake(128, 128)] autorelease];
    [nestedRV setPositionY:150];
    [self.testScene.contentView addChild:nestedRV];
    
    ResponsiveView *innerRV = [[[ResponsiveView alloc] initWithSize:CGSizeMake(48, 48)] autorelease];
    [innerRV setPositionX:10];
    [innerRV setPositionY:10];
    [nestedRV addChild:innerRV];
    
    ResponsiveView *innerRV2 = [[[ResponsiveView alloc] initWithSize:CGSizeMake(48, 48)] autorelease];
    [innerRV2 setPositionX:70];
    [innerRV2 setPositionY:10];
    [nestedRV addChild:innerRV2];

    ResponsiveView *innerRV3 = [[[ResponsiveView alloc] initWithSize:CGSizeMake(48, 48)] autorelease];
    [innerRV3 setPositionX:10];
    [innerRV3 setPositionY:70];
    [nestedRV addChild:innerRV3];

    ResponsiveView *innerRV4 = [[[ResponsiveView alloc] initWithSize:CGSizeMake(48, 48)] autorelease];
    [innerRV4 setPositionX:70];
    [innerRV4 setPositionY:70];
    [nestedRV addChild:innerRV4];

    ResponsiveView *innerInnerRV = [[[ResponsiveView alloc] initWithSize:CGSizeMake(12, 12)] autorelease];
    [innerInnerRV setPositionX:4];
    [innerInnerRV setPositionY:4];
    [innerRV4 addChild:innerInnerRV];
    
    ResponsiveView *nestedRV2 = [[[ResponsiveView alloc] initWithSize:CGSizeMake(128, 128)] autorelease];
    [nestedRV2 setPositionX:150];
    [nestedRV2 setPositionY:150];
    [self.testScene.contentView addChild:nestedRV2];
    
    ResponsiveView *innerRV5 = [[[ResponsiveView alloc] initWithSize:CGSizeMake(108, 108)] autorelease];
    [innerRV5 setPositionX:10];
    [innerRV5 setPositionY:10];
    [nestedRV2 addChild:innerRV5];
    
    ResponsiveView *innerRV6 = [[[ResponsiveView alloc] initWithSize:CGSizeMake(88, 88)] autorelease];
    [innerRV6 setPositionX:10];
    [innerRV6 setPositionY:10];
    [innerRV5 addChild:innerRV6];
    

    ICUIScene *testHostScene = [ICUIScene scene];
    [testHostScene.contentView addChild:self.testScene];
    
    ICView *buttonPanel = [ICView viewWithSize:CGSizeMake(310, 21)];
    [testHostScene.contentView addChild:buttonPanel];
    [buttonPanel setPositionY:20];
    [buttonPanel centerNodeHorizontally];
    buttonPanel.autoresizingMask = ICAutoResizingMaskLeftMarginFlexible |
                                   ICAutoResizingMaskRightMarginFlexible |
                                   ICAutoResizingMaskBottomMarginFlexible;
    
    ICButton *backingSwitchButton = [ICButton viewWithSize:CGSizeMake(180, 21)];
    [buttonPanel addChild:backingSwitchButton];
    ICButton *animateButton = [ICButton viewWithSize:CGSizeMake(120, 21)];
    [buttonPanel addChild:animateButton];

    backingSwitchButton.label.text = @"Without Render Textures";
    [backingSwitchButton addTarget:self action:@selector(backingSwitchButtonClicked:)
                  forControlEvents:ICControlEventLeftMouseUpInside];

    [animateButton setPositionX:190];
    animateButton.label.text = @"Animated";
    [animateButton addTarget:self action:@selector(animateButtonClicked:)
            forControlEvents:ICControlEventLeftMouseUpInside];
    
    [self.hostViewController runWithScene:testHostScene];
    
    [[self.hostViewController scheduler] scheduleUpdateForTarget:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.hostViewController = [ICHostViewController platformSpecificHostViewController];
    [self.hostViewController setFrameUpdateMode:kICFrameUpdateMode_Synchronized];
    [(ICHostViewControllerMac *)self.hostViewController setAcceptsMouseMovedEvents:NO];
    
    ICGLView *glView = [[ICGLView alloc] initWithFrame:self.window.frame
                                          shareContext:nil
                                    hostViewController:self.hostViewController];
    
    self.window.contentView = glView;
    [self.window setAcceptsMouseMovedEvents:NO];
    [self.window makeFirstResponder:self.window.contentView];
    [self.window makeKeyAndOrderFront:self];

    [self setupScene];
}

@end
