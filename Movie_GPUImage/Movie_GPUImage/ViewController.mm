//
//  ViewController.m
//  Movie_GPUImage
//
//  Created by Simon Lucey on 9/24/15.
//  Copyright (c) 2015 CMU_16432. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>

@interface ViewController (){
    // Setup the view (this time using GPUImageView)
    GPUImageView *videoView_;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Setup GPUImageView (not we are not using UIImageView here).........
    videoView_ = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    // Important: add as a subview
    [self.view addSubview:videoView_];
	
	// Set the movie file to read
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"simon" withExtension:@"mov"];
    
    GPUImageMovie *movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;
	
	GPUImageSepiaFilter *customFilter = [[GPUImageSepiaFilter alloc] init];
	[movieFile addTarget:customFilter];
	[customFilter addTarget:videoView_];
	
//	// Hough
//	GPUImageHoughTransformLineDetector *lineDetector = [[GPUImageHoughTransformLineDetector alloc] init];
////	lineDetector.edgeThreshold = 0.05f; // default = 0.0
//	lineDetector.lineDetectionThreshold = 0.175f; // default = 0.12
//	
//    // Daisy chain the filters together (you can add as many filters as you like)
//    [movieFile addTarget:lineDetector];
//
//    [lineDetector setLinesDetectedBlock:^(GLfloat* lineArray, NSUInteger linesDetected, CMTime frameTime){
//        NSLog(@"Number of lines: %ld", (unsigned long)linesDetected);
//        
//        GPUImageLineGenerator *lineGenerator = [[GPUImageLineGenerator alloc] init];
////        lineGenerator.crosshairWidth = 10.0;
//        [lineGenerator setLineColorRed:1.0 green:0.0 blue:0.0];
//        [lineGenerator forceProcessingAtSize:CGSizeMake(480.0, 640.0)];
//		
//        GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
//        [blendFilter forceProcessingAtSize:CGSizeMake(480.0, 640.0)];
//		
//        [movieFile addTarget:blendFilter];
//        
//        [lineGenerator addTarget:blendFilter];
//		
//		[blendFilter addTarget:videoView_];
//        
//        [blendFilter useNextFrameForImageCapture];
//        
//        [lineGenerator renderLinesFromArray:lineArray count:linesDetected frameTime:frameTime];
//    }];
	
	// Process the movie
    [movieFile startProcessing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end