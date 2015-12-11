//
//  ViewController.m
//  LaneTracking_OpenCV
//
//  Created by Jaineel Dalal on 12/9/15.
//  Copyright © 2015 Jaineel Dalal. All rights reserved.
//

//
//  ViewController.m
//  Canny_Edge
//
//  Created by Jaineel Dalal on 10/13/15.
//  Copyright © 2015 Jaineel Dalal. All rights reserved.
//

#import "ViewController.h"

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>
#import <iostream>
#endif

using namespace cv;

// Existing #import statements
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif

@interface ViewController ()
{
    // Setup the view
    UIImageView *imageView_;
    
    // For opencv video camera
    CvVideoCamera* videocamera;
}

@property (nonatomic, retain) CvVideoCamera* videocamera;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    self.videocamera = [[CvVideoCamera alloc] initWithParentView:imageView_ ];
    self.videocamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videocamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetMedium;
    self.videocamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videocamera.defaultFPS = 30;
    self.videocamera.grayscaleMode = NO;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
