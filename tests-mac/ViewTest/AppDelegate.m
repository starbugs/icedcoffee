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

@synthesize hostViewController = _hostViewController;

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void)setUpScene
{
    ICUIScene *rootScene = [ICUIScene scene];

    ICView *subSceneView = [ICView viewWithSize:icSizeMake(300, 200)];
    [rootScene.contentView addChild:subSceneView];
    [subSceneView setClipsChildren:YES];
    [subSceneView centerNodeRounded:YES];
    [subSceneView setAutoResizingMask:ICAutoResizingMaskLeftMarginFlexible | 
                                      ICAutoResizingMaskRightMarginFlexible |
                                      ICAutoResizingMaskTopMarginFlexible |
                                      ICAutoResizingMaskBottomMarginFlexible];
    
    ICUIScene *subScene = [ICUIScene scene];
    [subSceneView addChild:subScene];
    [subScene setClearsStencilBuffer:NO];
    
    NSString *textureFile = [[NSBundle mainBundle] pathForImageResource:@"Autumn_scenery"];
    ICTexture2D *texture = [self.hostViewController.textureCache loadTextureFromFile:textureFile];    
    ICSprite *sprite = [ICSprite spriteWithTexture:texture];
    [subScene addChild:sprite];    
        
    [self.hostViewController runWithScene:rootScene];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.hostViewController = [ICHostViewController platformSpecificHostViewController];
    [(ICHostViewControllerMac *)self.hostViewController setAcceptsMouseMovedEvents:YES];
    
    ICGLView *glView = [[ICGLView alloc] initWithFrame:self.window.frame
                                          shareContext:nil
                                    hostViewController:self.hostViewController];
    
    self.window.contentView = glView;
    [self.window setAcceptsMouseMovedEvents:YES];
    [self.window makeFirstResponder:self.window.contentView];
    
    [self setUpScene];
}

@end
