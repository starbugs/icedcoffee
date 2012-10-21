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

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize hostViewController = _hostViewController;
@synthesize label = _label;

- (void)dealloc
{
    [super dealloc];
}

- (void)buttonLeftMouseDown:(id)sender
{
    self.label.color = (icColor4B){255,0,255,255};
    ((ICButton *)sender).label.text = @"Mouse Down";
}

- (void)buttonLeftMouseUpInside:(id)sender
{
    self.label.color = (icColor4B){255,255,255,255};
    ((ICButton *)sender).label.text = @"Test Button";
}

- (void)setUpScene
{
    ICScene *scene = [ICScene scene];
    [scene setClearColor:(icColor4B){0,0,0,255}];
    [scene setSize:(kmVec3){self.hostViewController.view.bounds.size.width,
                            self.hostViewController.view.bounds.size.height, 0}];
    
    self.label = [ICLabel labelWithText:@"The quick brown fox jumps over the lazy dog"
                               fontName:@"Lucida Grande"
                               fontSize:16];
    [self.label setColor:(icColor4B){255,255,255,255}];
    [scene addChild:self.label];
    [self.label centerNodeOpticallyRounded:YES];
   
    ICButton *button = [[[ICButton alloc] initWithSize:CGSizeMake(160, 21)] autorelease];
    [button setPositionY:50];
    button.label.text = @"Test Button";
    [scene addChild:button];
    [button centerNodeHorizontallyRounded:YES];
    
    [button addTarget:self action:@selector(buttonLeftMouseDown:) forControlEvents:ICControlEventLeftMouseDown];
    [button addTarget:self action:@selector(buttonLeftMouseUpInside:) forControlEvents:ICControlEventLeftMouseUpInside];
    
    [self.hostViewController runWithScene:scene];
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
    
    [self setUpScene];
}

@end
