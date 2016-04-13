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

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize hostViewController = _hostViewController;

- (void)dealloc
{
    [super dealloc];
}

- (void)setUpScene
{
    ICScene *scene = [ICScene scene];
    [scene setSize:kmVec3Make(self.hostViewController.view.bounds.size.width,
                              self.hostViewController.view.bounds.size.height, 0)];    
    [scene setClearColor:(icColor4B){128,128,128,255}];
    
    NSString *gradientWhite = [[NSBundle mainBundle] pathForImageResource:@"gradient-white-transparent"];
    ICTexture2D *gradientWhiteTex = [self.hostViewController.textureCache loadTextureFromFile:gradientWhite];
    ICSprite *gradientSprite = [ICSprite spriteWithTexture:gradientWhiteTex];
    [scene addChild:gradientSprite];
    
    NSString *npot = [[NSBundle mainBundle] pathForImageResource:@"iced-coffee-npot"];
    ICTexture2D *npotTex = [self.hostViewController.textureCache loadTextureFromFile:npot];
    ICSprite *npotSprite = [ICSprite spriteWithTexture:npotTex];
    [scene addChild:npotSprite];
    [npotSprite centerNodeRounded:YES];
    
    [self.hostViewController runWithScene:scene];
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.hostViewController = [ICHostViewController platformSpecificHostViewController];
    [self.hostViewController setFrameUpdateMode:ICFrameUpdateModeOnDemand];
    [(ICHostViewControllerMac *)self.hostViewController setAcceptsMouseMovedEvents:NO];
    
    ICGLView *glView = [[ICGLView alloc] initWithFrame:self.window.frame
                                          shareContext:nil
                                    hostViewController:self.hostViewController];
    
    self.window.contentView = glView;
    [self.window setAcceptsMouseMovedEvents:YES];
    [self.window makeFirstResponder:self.window.contentView];
    
    [self setUpScene];
}

@end
