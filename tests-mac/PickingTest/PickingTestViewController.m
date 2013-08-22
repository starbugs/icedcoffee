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

#import "PickingTestViewController.h"

#import "ResponsiveSprite.h"
#import "ResponsiveView.h"

enum {
    // Control UI tags
    CombinedTestButtonPanelTag = 1,
    
    // Scene tags
    SimpleTestTag = 2,
    SpriteOverlapTag = 3,
    CombinedTestTag = 4,
};

@interface PickingTestViewController (Private)
- (void)setViewsWantRenderTextureBacking:(BOOL)flag;
- (void)backingSwitchButtonClicked:(id)sender;
- (void)animateButtonClicked:(id)sender;
@end

@implementation PickingTestViewController

@synthesize camAngle = _camAngle;
@synthesize animateCamera = _animateCamera;

- (id)init
{
    if ((self = [super init])) {
        self.animateCamera = NO;        
    }
    return self;
}

- (void)setUpSimpleTestScene
{
    ICUIScene *scene = [ICUIScene scene];
    scene.name = @"Picking Test (Single Sprite)";
    scene.tag = SimpleTestTag;

    NSString *filename = [[NSBundle mainBundle] pathForResource:@"thiswayup" ofType:@"png"];
    ICTexture2D *texture = [[ICTextureCache currentTextureCache] loadTextureFromFile:filename];
    
    ResponsiveSprite *rs = [ResponsiveSprite spriteWithTexture:texture];
    [scene.contentView addChild:rs];
    
    [self addTestScene:scene withHint:@"Sprite flips its texture vertically when clicked"];
}

- (void)setUpSpriteOverlapTestScene
{
    ICUIScene *scene = [ICUIScene scene];
    scene.name = @"Picking Test (Sprite Overlap)";
    scene.tag = SpriteOverlapTag;
    
    NSString *filename = [[NSBundle mainBundle] pathForResource:@"thiswayup" ofType:@"png"];
    ICTexture2D *texture = [[ICTextureCache currentTextureCache] loadTextureFromFile:filename];
    
    ResponsiveSprite *rs = [ResponsiveSprite spriteWithTexture:texture];
    [scene.contentView addChild:rs];    

    ResponsiveSprite *overlapRS = [ResponsiveSprite spriteWithTexture:texture];
    [overlapRS setName:@"Overlapping Sprite"];
    [overlapRS setPositionX:64.0f];
    [overlapRS setPositionY:64.0f];
    [scene.contentView addChild:overlapRS];
    
    [self addTestScene:scene withHint:@"Sprites flip their textures vertically when clicked"];
}

- (void)setUpCombinedTestScene
{
    ICUIScene *combinedScene = [ICUIScene scene];
    combinedScene.name = @"Picking Test (Combined)";
    combinedScene.tag = CombinedTestTag;
    
    NSString *filename = [[NSBundle mainBundle] pathForResource:@"thiswayup" ofType:@"png"];
    ICTexture2D *texture = [[ICTextureCache currentTextureCache] loadTextureFromFile:filename];
    
    ResponsiveSprite *rs = [ResponsiveSprite spriteWithTexture:texture];
    [rs setName:@"Simple Sprite"];
    [combinedScene.contentView addChild:rs];
    
    ResponsiveSprite *overlapRS = [ResponsiveSprite spriteWithTexture:texture];
    [overlapRS setName:@"Overlapping Sprite"];
    [overlapRS setPositionX:10.0f];
    [overlapRS setPositionY:10.0f];
    [combinedScene.contentView addChild:overlapRS];
    
    ResponsiveView *rv = [[[ResponsiveView alloc] initWithSize:icSizeMake(128, 128)] autorelease];
    [rv setName:@"Simple View"];
    [rv setPositionX:150];
    [combinedScene.contentView addChild:rv];
    
    ResponsiveView *nestedRV = [[[ResponsiveView alloc] initWithSize:icSizeMake(128, 128)] autorelease];
    [nestedRV setName:@"Superview of nested views (left-bottom)"];
    [nestedRV setPositionY:150];
    [combinedScene.contentView addChild:nestedRV];
    
    ResponsiveView *innerRV = [[[ResponsiveView alloc] initWithSize:icSizeMake(48, 48)] autorelease];
    [innerRV setName:@"Inner view (left top)"];
    [innerRV setPositionX:10];
    [innerRV setPositionY:10];
    [nestedRV addChild:innerRV];
    
    ResponsiveView *innerRV2 = [[[ResponsiveView alloc] initWithSize:icSizeMake(48, 48)] autorelease];
    [innerRV2 setName:@"Inner view (right top)"];
    [innerRV2 setPositionX:70];
    [innerRV2 setPositionY:10];
    [nestedRV addChild:innerRV2];
    
    ResponsiveView *innerRV3 = [[[ResponsiveView alloc] initWithSize:icSizeMake(48, 48)] autorelease];
    [innerRV3 setName:@"Inner view (left bottom)"];
    [innerRV3 setPositionX:10];
    [innerRV3 setPositionY:70];
    [nestedRV addChild:innerRV3];
    
    ResponsiveView *innerRV4 = [[[ResponsiveView alloc] initWithSize:icSizeMake(48, 48)] autorelease];
    [innerRV4 setName:@"Inner view (right bottom)"];
    [innerRV4 setPositionX:70];
    [innerRV4 setPositionY:70];
    [nestedRV addChild:innerRV4];
    
    ResponsiveView *innerInnerRV = [[[ResponsiveView alloc] initWithSize:icSizeMake(12, 12)] autorelease];
    [innerInnerRV setName:@"Little guy"];
    [innerInnerRV setPositionX:4];
    [innerInnerRV setPositionY:4];
    [innerRV4 addChild:innerInnerRV];
    
    ResponsiveView *nestedRV2 = [[[ResponsiveView alloc] initWithSize:icSizeMake(128, 128)] autorelease];
    [nestedRV2 setName:@"Superview of nested views (bottom right)"];
    [nestedRV2 setPositionX:150];
    [nestedRV2 setPositionY:150];
    [combinedScene.contentView addChild:nestedRV2];
    
    ResponsiveView *innerRV5 = [[[ResponsiveView alloc] initWithSize:icSizeMake(108, 108)] autorelease];
    [innerRV5 setName:@"Inner view centered 1"];
    [innerRV5 setPositionX:10];
    [innerRV5 setPositionY:10];
    [nestedRV2 addChild:innerRV5];
    
    ResponsiveView *innerRV6 = [[[ResponsiveView alloc] initWithSize:icSizeMake(88, 88)] autorelease];
    [innerRV6 setName:@"Inner view centered 2"];
    [innerRV6 setPositionX:10];
    [innerRV6 setPositionY:10];
    [innerRV5 addChild:innerRV6];
    
    [self addTestScene:combinedScene withHint:@"Sprites/views flip their texture vertically when clicked"];
}

- (void)setUpTestScenes
{
    [self setUpSimpleTestScene];
    [self setUpSpriteOverlapTestScene];
    [self setUpCombinedTestScene];
    
    [[self scheduler] scheduleUpdateForTarget:self];    
}

- (void)setUpScene
{
    [super setUpScene];
    
    // Set up the test's scene
    [self setUpTestScenes];
    
    // Set up user interface controls for the test
    ICView *buttonPanel = [ICView viewWithSize:icSizeMake(310, 21)];
    buttonPanel.isVisible = NO;
    buttonPanel.tag = CombinedTestButtonPanelTag;
    [self.testHostScene.contentView addChild:buttonPanel];
    [buttonPanel setPositionY:20];
    [buttonPanel centerNodeHorizontallyRounded:YES];
    buttonPanel.autoresizingMask = ICAutoResizingMaskLeftMarginFlexible |
                                   ICAutoResizingMaskRightMarginFlexible |
                                   ICAutoResizingMaskBottomMarginFlexible;
    
    ICButton *backingSwitchButton = [ICButton viewWithSize:icSizeMake(180, 21)];
    [buttonPanel addChild:backingSwitchButton];
    ICButton *animateButton = [ICButton viewWithSize:icSizeMake(120, 21)];
    [buttonPanel addChild:animateButton];
    
    backingSwitchButton.label.text = @"Without Render Textures";
    [backingSwitchButton addTarget:self action:@selector(backingSwitchButtonClicked:)
                  forControlEvents:ICControlEventLeftMouseUpInside];
    
    [animateButton setPositionX:190];
    animateButton.label.text = @"Animated";
    [animateButton addTarget:self action:@selector(animateButtonClicked:)
            forControlEvents:ICControlEventLeftMouseUpInside];
}

- (void)setCurrentTestScene:(ICScene *)currentTestScene
{
    [super setCurrentTestScene:currentTestScene];
    if (_currentTestScene.tag == CombinedTestTag) {
        _animateCamera = YES;
        [[_testHostScene.contentView childForTag:CombinedTestButtonPanelTag] setIsVisible:YES];
    } else {
        [[_testHostScene.contentView childForTag:CombinedTestButtonPanelTag] setIsVisible:NO];        
        _animateCamera = NO;
    }
}

- (void)update:(icTime)dt
{
    if (_animateCamera) {
        kmVec3 eyeOffset = kmVec3Make(cos(_camAngle)*200, sin(_camAngle)*-300, 0);
        ((ICUICamera *)self.currentTestScene.camera).eyeOffset = eyeOffset;
        ((ICUICamera *)self.currentTestScene.camera).lookAtOffset = (kmVec3){-50,-50,0};
        _camAngle += 0.1f * dt;
    } else {
        ((ICUICamera *)self.currentTestScene.camera).eyeOffset = kmNullVec3;
        ((ICUICamera *)self.currentTestScene.camera).lookAtOffset = kmNullVec3;
    }
}

- (void)setViewsWantRenderTextureBacking:(BOOL)flag
{
    NSArray *views = [self.currentTestScene descendantsOfType:[ICView class]];
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

@end
