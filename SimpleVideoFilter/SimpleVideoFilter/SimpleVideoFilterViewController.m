#import "SimpleVideoFilterViewController.h"
#import <GPUImage/GPUImage.h>

@interface SimpleVideoFilterViewController (){
    GPUImageView *videoView_;
	GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
}
@end

@implementation SimpleVideoFilterViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	/* === Camera and frame setup === */
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
//    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
//	  videoCamera.runBenchmark = YES;
	
	/* === Use movie file === */
	// Set the movie file to read
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"simon" withExtension:@"mov"];
    
    GPUImageMovie *movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;

	/* === Output view (screen) === */
	GPUImageView *filterView = (GPUImageView *)self.view;

	/* === Filter declarations === */
	GPUImageHoughTransformLineDetector *houghDetector = [[GPUImageHoughTransformLineDetector alloc] init];
	[(GPUImageHoughTransformLineDetector *)houghDetector setLineDetectionThreshold:0.30]; // 0.30 was good for direct camera feed

	GPUImageLineGenerator *lineGenerator = [[GPUImageLineGenerator alloc] init];
	[lineGenerator setLineColorRed:1.0 green:0.0 blue:0.0];
	[lineGenerator forceProcessingAtSize:CGSizeMake(480.0, 640.0)];
	[lineGenerator setLineWidth:10.0];

	GPUImageCrosshairGenerator *crosshairGenerator = [[GPUImageCrosshairGenerator alloc] init];
    crosshairGenerator.crosshairWidth = 15.0;
    [crosshairGenerator forceProcessingAtSize:CGSizeMake(480.0, 640.0)];

	GPUImageAlphaBlendFilter *blendFilter1 = [[GPUImageAlphaBlendFilter alloc] init];
	[blendFilter1 forceProcessingAtSize:CGSizeMake(480.0, 640.0)];
	
	GPUImageAlphaBlendFilter *blendFilter2 = [[GPUImageAlphaBlendFilter alloc] init];
	[blendFilter2 forceProcessingAtSize:CGSizeMake(480.0, 640.0)];
	
//	GPUImageLuminanceThresholdFilter *thresholdFilter = [[GPUImageLuminanceThresholdFilter alloc] init];
	
	/* === Filter cascade === */
    // Daisy chain the filters together (you can add as many filters as you like)
//	[videoCamera addTarget:thresholdFilter];

    [movieFile addTarget:houghDetector];

	[movieFile addTarget:blendFilter1];
	[lineGenerator addTarget:blendFilter1];

	[blendFilter1 addTarget:blendFilter2];
	[crosshairGenerator addTarget:blendFilter2];

	[blendFilter2 addTarget:filterView];
	
	// Callback function for line detection
    [houghDetector setLinesDetectedBlock:^(GLfloat* lineArray, NSUInteger linesDetected, CMTime frameTime){
		// Find lines within slope bound
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

		// Compute average lines and store in old array
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

		// Debug prints
		NSLog(@"Number of lines: %ld; Number of new lines: %d", (unsigned long) linesDetected, nLines);
		for (int i = 0; i < nLines; i++) {
			NSLog(@"%f %f %f %f", lineArray[0], lineArray[1], lineArray[2], lineArray[3]);
		}

		// Render lines
		[lineGenerator renderLinesFromArray:lineArray count:nLines frameTime:frameTime];

		// Generate crosses
		if (nLines == 0) xInter = 0.5;
		else xInter /= nLines;
		int nPoints = 20;
		GLfloat center[nPoints * 2];
		for (int i = 0; i < nPoints; i++) {
			center[2*i] = xInter;
			center[2*i+1] = 1.0 - 0.8 / nPoints * i;
		}
		
		// Render crosses
		[crosshairGenerator renderCrosshairsFromArray:center count:nPoints frameTime:frameTime];
    }];

	// Start camera
    [videoCamera startCameraCapture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

/* Calculates x-intercept of a line y=mx+b at a given y. */
- (float)xInterceptAty:(float)y m:(float)m b:(float)b {
	if (m >= 100000) return b / 2 + 0.5;
	else return (y - b) / m / 2 + 0.5;
}

@end
