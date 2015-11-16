//
//  ViewController.m
//  Intro_GPUImage
//
//  Created by Simon Lucey on 9/23/15.
//  Copyright (c) 2015 CMU_16432. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>

@interface ViewController () {
    // Setup the view (this time using GPUImageView)
    GPUImageView *imageView_;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Do any additional setup after loading the view, typically from a nib.
    
    // Setup GPUImageView (not we are not using UIImageView here).........
    imageView_ = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    
    // Important: add as a subview
    [self.view addSubview:imageView_];
    
    // Read in the image (of the famous Lena)
    UIImage *inputImage = [UIImage imageNamed:@"road.jpg"];
    
    // Initialize filters
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
	
	// Hough
	GPUImageHoughTransformLineDetector *lineDetector = [[GPUImageHoughTransformLineDetector alloc] init];
//	lineDetector.edgeThreshold = 0.05f; // default = 0.0
	lineDetector.lineDetectionThreshold = 0.175f; // default = 0.12
	
    // Daisy chain the filters together (you can add as many filters as you like)
    [stillImageSource addTarget:lineDetector];

    [lineDetector setLinesDetectedBlock:^(GLfloat* lineArray, NSUInteger linesDetected, CMTime frameTime){
        NSLog(@"Number of lines: %ld", (unsigned long)linesDetected);
        
        GPUImageLineGenerator *lineGenerator = [[GPUImageLineGenerator alloc] init];
//        lineGenerator.crosshairWidth = 10.0;
        [lineGenerator setLineColorRed:1.0 green:0.0 blue:0.0];
        [lineGenerator forceProcessingAtSize:[stillImageSource outputImageSize]];
        
        GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
        [blendFilter forceProcessingAtSize:[stillImageSource outputImageSize]];
        
        [stillImageSource addTarget:blendFilter];
        
        [lineGenerator addTarget:blendFilter];
		
		[blendFilter addTarget:imageView_];
        
        [blendFilter useNextFrameForImageCapture];
        
        [lineGenerator renderLinesFromArray:lineArray count:linesDetected frameTime:frameTime];
    }];
    
    // Process the image
    [stillImageSource processImage];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
