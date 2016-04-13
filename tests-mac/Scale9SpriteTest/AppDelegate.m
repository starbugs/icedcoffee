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
#import "ICResizableScale9Sprite.h"

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
    
    NSString *dropShadowFile = [[NSBundle mainBundle] pathForImageResource:@"dropshadow_rounded_5px.png"];
    ICTexture2D *dropShadowTexture = [[ICTextureCache currentTextureCache] loadTextureFromFile:dropShadowFile];
    ICScale9Sprite *dropShadowSprite = [ICScale9Sprite spriteWithTexture:dropShadowTexture scale9Rect:CGRectMake(22, 22, 34, 30)];
    [dropShadowSprite setSize:(kmVec3){444,344,0}];
    [scene addChild:dropShadowSprite];
    [dropShadowSprite centerNode];
    
    NSString *textureFile = [[NSBundle mainBundle] pathForImageResource:@"button_light_normal.png"];
    ICTexture2D *texture = [[ICTextureCache currentTextureCache] loadTextureFromFile:textureFile];
    ICResizableScale9Sprite *resizableSprite = [ICResizableScale9Sprite spriteWithTexture:texture scale9Rect:CGRectMake(5, 5, 110, 11)];
    [resizableSprite setSize:(kmVec3){400,300,0}];
    [scene addChild:resizableSprite];
    [resizableSprite centerNode];
    resizableSprite.dropShadowSprite = dropShadowSprite;
        
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
    
    [self setUpScene];
}

@end
