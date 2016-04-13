//
//  ICGPUImageTestViewController.m
//  icedcoffee-tests-ios
//
//  Created by Tobias Lensing on 10/7/12.
//  Copyright (C) 2016 Tobias Lensing. All rights reserved.
//

#import "ICGPUImageTestViewController.h"

@interface ICGPUImageTestViewController ()

@end

@implementation ICGPUImageTestViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.camera = nil;
    self.filter = nil;
    self.textureOutput = nil;
    self.texture = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpScene
{
    self.camera = [[[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480
                                                       cameraPosition:AVCaptureDevicePositionBack] autorelease];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorFrontFacingCamera = NO;
    self.camera.horizontallyMirrorRearFacingCamera = NO;
    
    self.filter = [[GPUImageSepiaFilter alloc] init];
    [self.camera addTarget:self.filter];
    
    self.textureOutput = [[GPUImageTextureOutput alloc] init];
    self.texture = [[ICGPUImageTexture2D alloc] initWithOpenGLName:0 size:CGSizeMake(480, 640)];
    self.textureOutput.delegate = self.texture;
    [self.filter addTarget:self.textureOutput];
    
    [self.camera startCameraCapture];
    
    [self.openGLContext makeCurrentContext];
    
    ICUIScene *scene = [ICUIScene scene];
    ICSprite *sprite = [ICSprite spriteWithTexture:self.texture];
    [scene.contentView addChild:sprite];
    
    [self runWithScene:scene];
}

@end
