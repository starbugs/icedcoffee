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

#import "AppDelegate.h"
#import "ResponsiveSprite.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize hostViewController = _hostViewController;
@synthesize foregroundSprite = _foregroundSprite;
@synthesize tsForegroundSprite = _tsForegroundSprite;

- (void)dealloc
{
    [super dealloc];
}

- (void)update:(icTime)dt
{
    static float posz = 0.0f;
    static float angle = 0.0f;
    [_foregroundSprite setPositionZ:posz];
    [_foregroundSprite setRotationAngle:angle axis:(kmVec3){0,1,1}];
    [_tsForegroundSprite setPositionZ:posz];
    [_tsForegroundSprite setRotationAngle:angle axis:(kmVec3){0,1,1}];
    posz -= dt * 10;
    angle += dt;
}

- (void)setUpScene
{
    ICScene *scene = [ICScene scene];
    scene.performsDepthTesting = YES;
    
    NSString *filename = [[NSBundle mainBundle] pathForResource:@"thiswayup" ofType:@"png"];
    ICTexture2D *texture = [self.hostViewController.textureCache loadTextureFromFile:filename];
    _foregroundSprite = [ResponsiveSprite spriteWithTexture:texture];
    [_foregroundSprite setPositionX:10.0f];
    [_foregroundSprite setPositionY:10.0f];
    ICSprite *backgroundSprite = [ResponsiveSprite spriteWithTexture:texture];
    [backgroundSprite flipTextureVertically];
    [backgroundSprite setPositionZ:-100.0f];
    [scene addChild:_foregroundSprite];
    [scene addChild:backgroundSprite];
    
    ICRenderTexture *renderTexture = [ICRenderTexture renderTextureWithWidth:128
                                                                      height:128
                                                                 pixelFormat:ICPixelFormatRGBA8888
                                                           depthBufferFormat:ICDepthBufferFormat16];
    ICScene *textureScene = [ICScene scene];
    textureScene.performsDepthTesting = YES;
    _tsForegroundSprite = [ResponsiveSprite spriteWithTexture:texture];
    [_tsForegroundSprite setPositionX:10.0f];
    [_tsForegroundSprite setPositionY:10.0f];
    ICSprite *tsBackgroundSprite = [ResponsiveSprite spriteWithTexture:texture];
    [tsBackgroundSprite flipTextureVertically];
    [tsBackgroundSprite setPositionZ:-100.0f];
    [textureScene addChild:_tsForegroundSprite];
    [textureScene addChild:tsBackgroundSprite];
    [renderTexture setSubScene:textureScene];
    [renderTexture setPositionY:160];
    [scene addChild:renderTexture];
    
    [self.hostViewController.scheduler scheduleUpdateForTarget:self];
    [self.hostViewController runWithScene:scene];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.hostViewController = [ICHostViewController platformSpecificHostViewController];
    [(ICHostViewControllerMac *)self.hostViewController setAcceptsMouseMovedEvents:YES];
    [(ICHostViewControllerMac *)self.hostViewController setUpdatesMouseEnterExitEventsContinuously:YES];
    
    ICGLView *glView = [[ICGLView alloc] initWithFrame:self.window.frame
                                          shareContext:nil
                                    hostViewController:self.hostViewController];
    
    self.window.contentView = glView;
    [self.window setAcceptsMouseMovedEvents:YES];
    [self.window makeFirstResponder:self.window.contentView];
    
    [self setUpScene];
}

@end
