//
//  ICGPUImageTestViewController.h
//  icedcoffee-tests-ios
//
//  Created by Tobias Lensing on 10/7/12.
//  Copyright (c) 2012 Tobias Lensing. All rights reserved.
//

#import "icedcoffee/IcedCoffee.h"
#import "GPUImage.h"

@interface ICGPUImageTestViewController : ICHostViewControllerIOS {
@protected
    GPUImageVideoCamera *_camera;
    GPUImageFilter *_filter;
    GPUImageTextureOutput *_textureOutput;
    ICGPUImageTexture2D *_texture;
}

@property (nonatomic, retain) GPUImageVideoCamera *camera;

@property (nonatomic, retain) GPUImageFilter *filter;

@property (nonatomic, retain) GPUImageTextureOutput *textureOutput;

@property (nonatomic, retain) ICGPUImageTexture2D *texture;

@end
