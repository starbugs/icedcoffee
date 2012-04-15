//  
//  Copyright (C) 2012 Tobias Lensing
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

@implementation AppDelegate

@synthesize window = _window;
@synthesize hostViewController = _hostViewController;
@synthesize foregroundSprite = _foregroundSprite;
@synthesize tsForegroundSprite = _tsForegroundSprite;

- (void)dealloc
{
    [super dealloc];
}

- (void)timer:(NSTimer *)timer
{
    static float posz = 0.0f;
    [_foregroundSprite setPositionZ:posz];
    [_tsForegroundSprite setPositionZ:posz];
    posz -= 0.25f;
}

- (void)setupScene
{
    ICScene *scene = [ICScene sceneWithHostViewController:self.hostViewController];
    scene.depthTestingEnabled = YES;
    
    NSString *filename = [[NSBundle mainBundle] pathForResource:@"thiswayup" ofType:@"png"];
    ICTexture2D *texture = [self.hostViewController.textureCache loadTextureFromFile:filename];
    _foregroundSprite = [ICSprite spriteWithTexture:texture];
    [_foregroundSprite setPositionX:10.0f];
    [_foregroundSprite setPositionY:10.0f];
    ICSprite *backgroundSprite = [ICSprite spriteWithTexture:texture];
    [backgroundSprite flipTextureVertically];
    [backgroundSprite setPositionZ:-100.0f];
    [scene addChild:_foregroundSprite];
    [scene addChild:backgroundSprite];
    
    ICRenderTexture *renderTexture = [ICRenderTexture renderTextureWithWidth:128
                                                                      height:128
                                                                 pixelFormat:kICTexture2DPixelFormat_RGBA8888
                                                           enableDepthBuffer:YES];
    ICScene *textureScene = [ICScene sceneWithHostViewController:self.hostViewController];
    textureScene.depthTestingEnabled = YES;
    _tsForegroundSprite = [ICSprite spriteWithTexture:texture];
    [_tsForegroundSprite setPositionX:10.0f];
    [_tsForegroundSprite setPositionY:10.0f];
    ICSprite *tsBackgroundSprite = [ICSprite spriteWithTexture:texture];
    [tsBackgroundSprite flipTextureVertically];
    [tsBackgroundSprite setPositionZ:-100.0f];
    [textureScene addChild:_tsForegroundSprite];
    [textureScene addChild:tsBackgroundSprite];
    [renderTexture setSubScene:textureScene];
    [renderTexture setPositionY:160];
    [scene addChild:renderTexture];
    
    [self.hostViewController runWithScene:scene];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.hostViewController = [ICHostViewController platformSpecificHostViewController];
    [(ICHostViewControllerMac *)self.hostViewController setAcceptsMouseMovedEvents:NO];
    
    ICGLView *glView = [[ICGLView alloc] initWithFrame:self.window.frame
                                          shareContext:nil
                                    hostViewController:self.hostViewController];
    
    self.window.contentView = glView;
    [self.window setAcceptsMouseMovedEvents:YES];
    [self.window makeFirstResponder:self.window.contentView];
    
    [self setupScene];
}

@end
