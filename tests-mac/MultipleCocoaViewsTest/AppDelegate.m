//  
//  Copyright (C) 2016 Tobias Lensing, http://icedcoffee-framework.org
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

@synthesize window1 = _window1;
@synthesize window2 = _window2;
@synthesize hvc1 = _hvc1;
@synthesize hvc2 = _hvc2;

- (void)dealloc
{
    [super dealloc];
}

- (void)setupScene1
{
    ICUIScene *rootScene = [ICUIScene scene];
    rootScene.name = @"Root Scene 1";
    ICButton *button = [ICButton viewWithSize:icSizeMake(120, 21)];
    [rootScene.contentView addChild:button];
    button.label.text = @"Button 1";
    [button centerNode];
    [button setAutoResizingMask:ICAutoResizingMaskLeftMarginFlexible |
                                ICAutoResizingMaskRightMarginFlexible];
    
    [self.hvc1 runWithScene:rootScene];
}

- (void)setupScene2
{
    ICUIScene *rootScene = [ICUIScene scene];
    rootScene.name = @"Root Scene 2";
    ICButton *button = [ICButton viewWithSize:icSizeMake(120, 21)];
    [rootScene.contentView addChild:button];
    button.label.text = @"Button 2";
    [button centerNode];
    [button setAutoResizingMask:ICAutoResizingMaskLeftMarginFlexible |
                                ICAutoResizingMaskRightMarginFlexible];
    
    [self.hvc2 runWithScene:rootScene];    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.window1 = [[[NSWindow alloc] initWithContentRect:NSMakeRect(200,200,200,200)
                                               styleMask:NSTitledWindowMask | NSResizableWindowMask | NSClosableWindowMask
                                                 backing:NSBackingStoreBuffered
                                                   defer:false] autorelease];
    self.hvc1 = [ICHostViewController platformSpecificHostViewController];
    ((ICHostViewControllerMac *)self.hvc1).usesDisplayLink = NO;
    ((ICHostViewControllerMac *)self.hvc1).drawsConcurrently = NO;    
    self.hvc1.view = [[[ICGLView alloc] initWithFrame:self.window1.frame
                                         shareContext:nil
                                   hostViewController:self.hvc1] autorelease];
    [self.window1 setContentView:self.hvc1.view];
    [self.window1 makeKeyAndOrderFront:self];
    [self setupScene1];
    
    self.window2 = [[[NSWindow alloc] initWithContentRect:NSMakeRect(450, 200, 200, 200)
                                                styleMask:NSTitledWindowMask | NSResizableWindowMask | NSClosableWindowMask
                                                  backing:NSBackingStoreBuffered
                                                    defer:false] autorelease];
    self.hvc2 = [ICHostViewController platformSpecificHostViewController];
    ((ICHostViewControllerMac *)self.hvc2).usesDisplayLink = NO;
    ((ICHostViewControllerMac *)self.hvc2).drawsConcurrently = NO;
    self.hvc2.view = [[[ICGLView alloc] initWithFrame:self.window2.frame
                                         shareContext:nil
                                   hostViewController:self.hvc2] autorelease];
    [self.window2 setContentView:self.hvc2.view];
    [self.window2 makeKeyAndOrderFront:self];
    [self setupScene2];
}

@end
