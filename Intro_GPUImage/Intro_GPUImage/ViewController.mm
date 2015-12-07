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
    UIImage *inputImage = [UIImage imageNamed:@"solid.jpg"];
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
	
	// Initialize filters
	GPUImageHoughTransformLineDetector *houghDetector = [[GPUImageHoughTransformLineDetector alloc] init];
	[(GPUImageHoughTransformLineDetector *)houghDetector setLineDetectionThreshold:0.20];
	
	GPUImageLineGenerator *lineGenerator = [[GPUImageLineGenerator alloc] init];
	[lineGenerator setLineColorRed:1.0 green:0.0 blue:0.0];
	[lineGenerator setLineWidth:10.0];
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
		// Find left and right lanes
		float lowm = 0.5, highm = 0.65;
		float leftcount = 0, leftm = 0, leftb = 0, rightcount = 0, rightm = 0, rightb = 0;
		bool hasLeft = false, hasRight = false;
		for (int i = 0; i < linesDetected; i++) {
			float m = lineArray[2*i], b = lineArray[2*i+1];

			if (m > lowm && m < highm) { // Right side
				NSLog(@"m: %f, b: %f", lineArray[2*i], lineArray[2*i+1]);
				rightcount++;
				rightm += m;
				rightb += b;
				hasRight = true;

			} else if (-m > lowm && -m < highm) { // Left side
				NSLog(@"m: %f, b: %f", lineArray[2*i], lineArray[2*i+1]);
				leftcount++;
				leftm += m;
				leftb += b;
				hasLeft = true;

			}
		}
		
		// Copy filtered lines to old array
		int nLines = 0;
		float xInter = 0;
		if (hasRight) {
			lineArray[0] = rightm / rightcount;
			lineArray[1] = rightb / rightcount;
			xInter += [self xInterceptAty:1 m:lineArray[0] b:lineArray[1]];
			nLines++;

			if (hasLeft) {
				lineArray[2] = leftm / leftcount;
				lineArray[3] = leftb / leftcount;
				xInter += [self xInterceptAty:1 m:lineArray[2] b:lineArray[3]];
				nLines++;
			}
		} else if (hasLeft) {
			lineArray[0] = leftm / leftcount;
			lineArray[1] = leftb / leftcount;
			xInter += [self xInterceptAty:1 m:lineArray[2] b:lineArray[3]];
			nLines++;
		}

		NSLog(@"Number of lines: %ld; Number of new lines: %d", (unsigned long) linesDetected, nLines);

		for (int i = 0; i < nLines; i++) {
			NSLog(@"%f %f %f %f", lineArray[0], lineArray[1], lineArray[2], lineArray[3]);
		}

		[lineGenerator renderLinesFromArray:lineArray count:nLines frameTime:frameTime];
		
		if (nLines == 0) xInter = 0.5;
		else xInter /= nLines;
		int nPoints = 20;
		GLfloat center[nPoints * 2];
		for (int i = 0; i < nPoints; i++) {
			center[2*i] = xInter;
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

//- (float)distWithm:(float)m b:(float)b x:(float)x y:(float)y {
//	return fabsf(m * x - y + b) / sqrt(m * m + 1);
//}

- (float)xInterceptAty:(float)y m:(float)m b:(float)b {
	if (m >= 100000) return b / 2 + 0.5;
	else return (y - b) / m / 2 + 0.5;
}
@end
