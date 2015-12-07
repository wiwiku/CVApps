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
	[(GPUImageHoughTransformLineDetector *)houghDetector setLineDetectionThreshold:0.30];
	
	GPUImageLineGenerator *lineGenerator = [[GPUImageLineGenerator alloc] init];
	[lineGenerator setLineColorRed:1.0 green:0.0 blue:0.0];
	[lineGenerator setLineWidth:5.0];
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
		// Filter lines with slope greater than threshold

        GLfloat lines[4];
		float targetm = 0.5;
		float leftmin = 100, rightmin = 100;
		bool hasLeft = false, hasRight = false;
		for (int i = 0; i < linesDetected; i++) {
			float m = lineArray[2*i], b = lineArray[2*i+1], dm;
			NSLog(@"m: %f, b: %f", lineArray[2*i], lineArray[2*i+1]);

			if (m > 0) { // Right side
				dm = fabsf(m - targetm);
				if (dm < rightmin) {
					lines[0] = m;
					lines[1] = b;
					rightmin = dm;
					hasRight = true;
				}
			} else { // Left side
				dm = fabsf(m + targetm);
				if (dm < leftmin) {
					lines[2] = m;
					lines[3] = b;
					leftmin = dm;
					hasLeft = true;
				}
			}
		}
		
		// Copy filtered lines to old array
		int nLines = 0;
		float xInter = 0;
		if (hasRight) {
			lineArray[0] = lines[0];
			lineArray[1] = lines[1];
			xInter += [self xInterceptAty:1 m:lines[0] b:lines[1]];
			nLines++;

			if (hasLeft) {
				lineArray[2] = lines[2];
				lineArray[3] = lines[3];
				xInter += [self xInterceptAty:1 m:lines[2] b:lines[3]];
				nLines++;
			}
		} else if (hasLeft) {
			lineArray[0] = lines[2];
			lineArray[1] = lines[3];
			xInter += [self xInterceptAty:1 m:lines[2] b:lines[3]];
			nLines++;
		}
		
		for (int i = 0; i < nLines; i++) {
			NSLog(@"%f %f %f %f", lines[0], lines[1], lines[2], lines[3]);
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
