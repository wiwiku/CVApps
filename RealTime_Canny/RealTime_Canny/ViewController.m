//
//  ViewController.m
//  RealTime_Canny
//
//  Created by Jaineel Dalal on 11/19/15.
//  Copyright © 2015 Jaineel Dalal. All rights reserved.
//

#import "ViewController.h"

#import <GPUImage/GPUImage.h>

@interface ViewController ()
{
    // Setup the view for a video (this time using GPUImageView)
    GPUImageView *videoView_;
    // Using the Camera to get a Real-Time video 
    GPUImageVideoCamera *videoCamera;
    //GPUImageOutput<GPUImageInput> *filter;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Initialize the Back Camera in Portrait Mode with a preset of 640x480
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition: AVCaptureDevicePositionBack];
    
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    // to show runtime in milliseconds for the camera
    videoCamera.runBenchmark = YES;
    
    // Initialize the Video View
    videoView_ = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 640, 480)];
    // Important: add as a subview
    [self.view addSubview:videoView_];
    
    // Initialize all the required filters over here before Daisychaining them
    // Grayscale
    GPUImageGrayscaleFilter *videoGrayFilter = [[GPUImageGrayscaleFilter alloc] init];
    //[videoGrayFilter forceProcessingAtSize:CGSizeMake(640.0, 480.0)];
    [videoGrayFilter forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(640, 480)];
    
    // Daisy chain all the filters together
    [videoCamera addTarget:videoGrayFilter];
    [videoGrayFilter addTarget:videoView_];
    
    // Starting to capture
    [videoCamera startCameraCapture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
