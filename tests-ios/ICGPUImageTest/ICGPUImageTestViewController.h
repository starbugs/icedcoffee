//
//  ICGPUImageTestViewController.h
//  icedcoffee-tests-ios
//
//  Created by Tobias Lensing on 10/7/12.
//  Copyright (C) 2016 Tobias Lensing. All rights reserved.
//

#import "icedcoffee/icedcoffee.h"
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
