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

- (void)dealloc
{
    [super dealloc];
}

- (void)setupScene
{
    ICScene *scene = [[[ICScene alloc] initWithHostViewController:self.hostViewController] autorelease];
    
    ((ICCameraPointsToPixelsPerspective *)scene.camera).eyeOffset = (kmVec3){200,-300,0};
    ((ICCameraPointsToPixelsPerspective *)scene.camera).lookAtOffset = (kmVec3){-50,-50,0};
    
    NSString *filename = [[NSBundle mainBundle] pathForResource:@"thiswayup" ofType:@"png"];
    ICTexture2D *texture = [ICTextureLoader loadTextureFromFile:filename];
    ResponsiveSprite *rs = [ResponsiveSprite spriteWithTexture:texture];
    [scene addChild:rs];
    
    ResponsiveView *rv = [[[ResponsiveView alloc] initWithSize:CGSizeMake(128, 128)] autorelease];
    [rv setPositionX:150];
    [scene addChild:rv];
    
    ResponsiveView *nestedRV = [[[ResponsiveView alloc] initWithSize:CGSizeMake(128, 128)] autorelease];
    [nestedRV setPositionY:150];
    [scene addChild:nestedRV];
    
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

    ResponsiveView *nestedRV2 = [[[ResponsiveView alloc] initWithSize:CGSizeMake(128, 128)] autorelease];
    [nestedRV2 setPositionX:150];
    [nestedRV2 setPositionY:150];
    [scene addChild:nestedRV2];
    
    ResponsiveView *innerRV5 = [[[ResponsiveView alloc] initWithSize:CGSizeMake(108, 108)] autorelease];
    [innerRV5 setPositionX:10];
    [innerRV5 setPositionY:10];
    [nestedRV2 addChild:innerRV5];
    
    ResponsiveView *innerRV6 = [[[ResponsiveView alloc] initWithSize:CGSizeMake(88, 88)] autorelease];
    [innerRV6 setPositionX:10];
    [innerRV6 setPositionY:10];
    [innerRV5 addChild:innerRV6];
    
    [self.hostViewController runWithScene:scene];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.hostViewController = [ICHostViewController platformSpecificHostViewController];
    [self.hostViewController setFrameUpdateMode:kICFrameUpdateMode_OnDemand];
    [(ICHostViewControllerMac *)self.hostViewController setAcceptsMouseMovedEvents:YES];
    
    ICGLView *glView = [[ICGLView alloc] initWithFrame:self.window.frame
                                          shareContext:nil
                                    hostViewController:self.hostViewController];
    
    self.window.contentView = glView;
    [self.window setAcceptsMouseMovedEvents:YES];
    [self.window makeFirstResponder:self.window.contentView];

    [self setupScene];
}

@end
