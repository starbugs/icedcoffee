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

@implementation AppDelegate

@synthesize window = _window;
@synthesize hostViewController = _hostViewController;

- (void)dealloc
{
    [super dealloc];
}

- (void)setupScene
{
    ICScene *scene = [ICScene scene];
    
    NSString *textureFile = [[NSBundle mainBundle] pathForImageResource:@"Autumn_scenery"];
    ICTexture2D *texture = [self.hostViewController.textureCache loadTextureFromFile:textureFile];

    ICSprite *scrollableSprite = [ICSprite spriteWithTexture:texture];
    [scrollableSprite setName:@"sprite1"];
    ICScrollView *scrollView = [ICScrollView viewWithSize:CGSizeMake(300, 400)];
    [scrollView setName:@"scrollView1"];
    [scrollableSprite setPosition:(kmVec3){-200,-200,0}];
    [scrollView addChild:scrollableSprite];
    [scene addChild:scrollView];

    ICSprite *scrollableSprite2 = [ICSprite spriteWithTexture:texture];    
    [scrollableSprite2 setName:@"sprite2"];
    ICScrollView *scrollView2 = [ICScrollView viewWithSize:CGSizeMake(300, 400)];
    [scrollView2 setName:@"scrollView2"];
    [scrollView2 addChild:scrollableSprite2];
    [scrollView2 setPositionX:350];
    [scene addChild:scrollView2];
    
    [self.hostViewController runWithScene:scene];
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
    
    [self setupScene];
}

@end
