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
    
    // Read in the image
    UIImage *inputImage = [UIImage imageNamed:@"lanecrop.jpg"];
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
	
	// Initialize filters
	GPUImageHoughTransformLineDetector *houghDetector = [[GPUImageHoughTransformLineDetector alloc] init];
	[(GPUImageHoughTransformLineDetector *)houghDetector setLineDetectionThreshold:0.30];
	
	GPUImageLineGenerator *lineGenerator = [[GPUImageLineGenerator alloc] init];
	[lineGenerator setLineColorRed:1.0 green:0.0 blue:0.0];
	[lineGenerator forceProcessingAtSize:[stillImageSource outputImageSize]];
	
	GPUImageCrosshairGenerator *crosshairGenerator = [[GPUImageCrosshairGenerator alloc] init];
    crosshairGenerator.crosshairWidth = 15.0;
    [crosshairGenerator forceProcessingAtSize:[stillImageSource outputImageSize]];
        
	GPUImageAlphaBlendFilter *blendFilter1 = [[GPUImageAlphaBlendFilter alloc] init];
	[blendFilter1 forceProcessingAtSize:[stillImageSource outputImageSize]];
	
	GPUImageAlphaBlendFilter *blendFilter2 = [[GPUImageAlphaBlendFilter alloc] init];
	[blendFilter2 forceProcessingAtSize:[stillImageSource outputImageSize]];
	
    // Daisy chain the filters together (you can add as many filters as you like)
    [stillImageSource addTarget:houghDetector];
	[stillImageSource addTarget:blendFilter1];
	[lineGenerator addTarget:blendFilter1];

	[blendFilter1 addTarget:blendFilter2];
	[crosshairGenerator addTarget:blendFilter2];
	[blendFilter2 addTarget:imageView_];

    [houghDetector setLinesDetectedBlock:^(GLfloat* lineArray, NSUInteger linesDetected, CMTime frameTime){
        NSLog(@"Number of lines: %ld", (unsigned long) linesDetected);
        //[blendFilter1 useNextFrameForImageCapture];
		
		// Filter lines with slope greater than threshold
		int nLines = 2;
		GLfloat lines[(unsigned long) nLines * 2];
		float thres = 1; // 45 degree
		float leftmin = 100, rightmin = 100;
		float centerx = 0.5, centery = 1.0;

		for (int i = 0; i < (unsigned long) linesDetected; i++) {
			float m = lineArray[2*i], b = lineArray[2*i+1], d;
			if (m > thres) { // Right side
				d = [self distWithm:m b:b x:centerx y:centery];
				if (d < rightmin) {
					lines[0] = m;
					lines[1] = b;
					rightmin = d;
				}
			} else if(-m > thres) { // Left side
				d = [self distWithm:m b:b x:centerx y:centery];
				if (d < leftmin) {
					lines[2] = m;
					lines[3] = b;
					leftmin = d;
				}
			}
		}
		
		// Copy filtered lines to old array
		for (int i = 0; i < nLines; i++) {
			lineArray[2*i] = lines[2*i];
			lineArray[2*i+1] = lines[2*i+1];
			NSLog(@"%f %f", lineArray[2*i], lineArray[2*i+1]);
		}

		[lineGenerator renderLinesFromArray:lineArray count:nLines frameTime:frameTime];
		
		float r = [self xInterceptAty:1 m:lines[0] b:lines[1]];
		float l = [self xInterceptAty:1 m:lines[2] b:lines[3]];
		float mid = (l + r) / 2;
		NSLog(@"%f %f %f", r, l, mid);
		int nPoints = 20;
		GLfloat center[nPoints * 2];
		for (int i = 0; i < nPoints; i++) {
			center[2*i] = mid;
			center[2*i+1] = 1.0 - 0.8 / nPoints * i;
		}
		[crosshairGenerator renderCrosshairsFromArray:center count:nPoints frameTime:frameTime];
    }];
    
    // Process the image
    [stillImageSource processImage];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (float)distWithm:(float)m b:(float)b x:(float)x y:(float)y {
	return fabsf(m * x - y + b) / sqrt(m * m + 1);
}

- (float)xInterceptAty:(float)y m:(float)m b:(float)b {
	if (m >= 100000) {
		return b;
	} else {
		return (y - b) / m / 2 + 0.5;
	}
}
@end
