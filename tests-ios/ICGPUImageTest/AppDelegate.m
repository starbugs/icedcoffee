//
//  AppDelegate.m
//  ICGPUImageTest
//
//  Created by Tobias Lensing on 10/7/12.
//  Copyright (C) 2013 Tobias Lensing. All rights reserved.
//

#import "AppDelegate.h"
#import "ICGPUImageTestViewController.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    
    GPUImageOpenGLESContext *gpuImageContext = [GPUImageOpenGLESContext sharedImageProcessingOpenGLESContext];
    EAGLSharegroup *sharegroup = gpuImageContext.context.sharegroup;
    
    ICGPUImageTestViewController *viewController = [[[ICGPUImageTestViewController alloc] init] autorelease];
    viewController.frameUpdateMode = ICFrameUpdateModeSynchronized;
    
    ICGLView *view = [[[ICGLView alloc] initWithFrame:self.window.bounds
                                          pixelFormat:kEAGLColorFormatRGBA8
                                          depthFormat:GL_DEPTH24_STENCIL8_OES
                                   preserveBackbuffer:NO
                                           sharegroup:sharegroup
                                        multiSampling:NO
                                      numberOfSamples:0] autorelease];
    
    [viewController enableRetinaDisplaySupport:YES];
    [view setHostViewController:viewController];
    
    self.window.rootViewController = viewController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
