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
#import "ResponsiveSprite.h"
#import "ResponsiveView.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize hostViewController = _hostViewController;

- (void)dealloc
{
    [_hostViewController release];
    [_window release];
    [super dealloc];
}

- (void)buttonPressed
{
    //int brk = 1;
}

- (void)setUpScene
{
    ICScene *scene = [ICScene scene];
    [scene setSize:CGSizeTokmVec3(self.hostViewController.view.bounds.size)];
    
    NSString *filename = [[NSBundle mainBundle] pathForResource:@"thiswayup" ofType:@"png"];
    ICTexture2D *texture = [[ICTextureCache currentTextureCache] loadTextureFromFile:filename];
    ResponsiveSprite *rs = [ResponsiveSprite spriteWithTexture:texture];
    [scene addChild:rs];
    
    ResponsiveView *rv = [ResponsiveView viewWithSize:CGSizeMake(128, 128)];
    [rv setPositionY:150];
    [scene addChild:rv];
    
    ICButton *button = [ICButton buttonWithSize:CGSizeMake(150, 32)];
    button.label.fontSize = 14.f;
    button.label.text = @"Test Button";
    [button setPositionY:300];
    [scene addChild:button];
    [button centerNodeHorizontally];
    [button addTarget:self action:@selector(buttonPressed) forControlEvents:ICControlEventTouchDragExit];
    
    [self.hostViewController runWithScene:scene];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.hostViewController = [ICHostViewController platformSpecificHostViewController];
    
    ICGLView *glView = [ICGLView viewWithFrame:[self.window bounds]
                                   pixelFormat:kEAGLColorFormatRGB565
                                   depthFormat:0 /* GL_DEPTH_COMPONENT24_OES */
                            preserveBackbuffer:NO
                                    sharegroup:nil
                                 multiSampling:NO
                               numberOfSamples:0];

    [glView setMultipleTouchEnabled:YES];
    [glView setHostViewController:self.hostViewController];
    [self.hostViewController enableRetinaDisplaySupport:YES];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.rootViewController = self.hostViewController;
    [self.window makeKeyAndVisible];
    
    [self setUpScene];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
