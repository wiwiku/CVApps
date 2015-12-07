#import "SimpleVideoFilterViewController.h"
#import <GPUImage/GPUImage.h>

@interface SimpleVideoFilterViewController (){
    GPUImageView *videoView_;
	GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
}
@end

@implementation SimpleVideoFilterViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//    }
//    return self;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	/* === Camera and frame setup === */
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];

    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
	videoCamera.runBenchmark = YES;

	GPUImageView *filterView = (GPUImageView *)self.view;

	/* === Filter declarations === */
	GPUImageHoughTransformLineDetector *houghDetector = [[GPUImageHoughTransformLineDetector alloc] init];
	[(GPUImageHoughTransformLineDetector *)houghDetector setLineDetectionThreshold:0.50]; // 0.30 was good for direct camera feed

	GPUImageLineGenerator *lineGenerator = [[GPUImageLineGenerator alloc] init];
	[lineGenerator setLineColorRed:1.0 green:0.0 blue:0.0];
	[lineGenerator forceProcessingAtSize:CGSizeMake(480.0, 640.0)];

	GPUImageCrosshairGenerator *crosshairGenerator = [[GPUImageCrosshairGenerator alloc] init];
    crosshairGenerator.crosshairWidth = 15.0;
    [crosshairGenerator forceProcessingAtSize:CGSizeMake(480.0, 640.0)];

	GPUImageAlphaBlendFilter *blendFilter1 = [[GPUImageAlphaBlendFilter alloc] init];
	[blendFilter1 forceProcessingAtSize:CGSizeMake(480.0, 640.0)];
	
	GPUImageAlphaBlendFilter *blendFilter2 = [[GPUImageAlphaBlendFilter alloc] init];
	[blendFilter2 forceProcessingAtSize:CGSizeMake(480.0, 640.0)];
	
	GPUImageLuminanceThresholdFilter *thresholdFilter = [[GPUImageLuminanceThresholdFilter alloc] init];
	
	/* === Filter cascade === */
    // Daisy chain the filters together (you can add as many filters as you like)
	[videoCamera addTarget:thresholdFilter];

    [thresholdFilter addTarget:houghDetector];

	[thresholdFilter addTarget:blendFilter1];
	[lineGenerator addTarget:blendFilter1];

	[blendFilter1 addTarget:blendFilter2];
	[crosshairGenerator addTarget:blendFilter2];

	[blendFilter2 addTarget:filterView];

	// Callback function for line detection
    [houghDetector setLinesDetectedBlock:^(GLfloat* lineArray, NSUInteger linesDetected, CMTime frameTime){
		// Filter lines with slope greater than threshold
		float thres = 1; // diagonal
		int nFiltered = [self filterLines:lineArray withLength:(int) linesDetected withThres:thres];

		// Find left and right lines
		GLfloat lines[4];
		float centerx = 0.5;
		float leftmin = 10000, rightmin = 10000;
		bool hasLeft = false, hasRight = false;
		for (int i = 0; i < nFiltered; i++) {
			float m = lineArray[2*i], b = lineArray[2*i+1];
			float x = [self xInterceptAty:1 m:m b:b];
			float d = x - centerx;
			if (d >= 0) { // Right side
//				NSLog(@"m: %f, b: %f, x: %f, rightd: %f", lineArray[2*i], lineArray[2*i+1], x, d);
				if (d < rightmin) {
					lines[0] = m;
					lines[1] = b;
					rightmin = d;
					hasRight = true;
				}
			} else { // Left side
//				NSLog(@"m: %f, b: %f, x: %f, leftd: %f", lineArray[2*i], lineArray[2*i+1], x, -d);
				if (-d < leftmin) {
					lines[2] = m;
					lines[3] = b;
					leftmin = -d;
					hasLeft = true;
				}
			}
		}

		// Copy filtered lines to old array
		int nLines = 0;
		if (hasRight) {
			lineArray[0] = lines[0];
			lineArray[1] = lines[1];
			nLines++;

			if (hasLeft) {
				lineArray[2] = lines[2];
				lineArray[3] = lines[3];
				nLines++;
			}
		} else if (hasLeft) {
			lineArray[0] = lines[2];
			lineArray[1] = lines[3];
			nLines++;
		}

//		for (int i = 0; i < nFiltered; i++) {
//			NSLog(@"%@, %@, %f %f %f %f", (hasLeft)?@"TRUE":@"FALSE", (hasRight)?@"TRUE":@"FALSE", lines[0], lines[1], lines[2], lines[3]);
//		}

//		NSLog(@"Number of lines: %ld; Number of filtered: %d", (unsigned long) linesDetected, nFiltered);
		NSLog(@"Number of lines: %ld; Number of filtered: %d, Number of new lines: %d", (unsigned long) linesDetected, nFiltered, nLines);

		[lineGenerator renderLinesFromArray:lineArray count:nLines frameTime:frameTime];

		GLfloat center[] = {0.5, 1.0};
		[crosshairGenerator renderCrosshairsFromArray:center count:1 frameTime:frameTime];
    }];
	
	// Start camera
    [videoCamera startCameraCapture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (int)filterLines:(GLfloat*) arr withLength:(int)len withThres:(float)thres {
	GLfloat tmp[len * 2];
	int n = 0;

	// Filter out horizontal and perfectly vertical lines and store results in tmp
	for (int i = 0; i < len; i++) {
		GLfloat m = arr[2*i];
		if (fabsf(m) > thres && fabsf(m) < 1000) {
			tmp[2*n] = arr[2*i];
			tmp[2*n+1] = arr[2*i+1];
			n++;
		}
	}

	// Copy tmp back to array
	for (int i = 0; i < n; i++) {
		arr[2*i] = tmp[2*i];
		arr[2*i+1] = tmp[2*i+1];
	}
	
	return n;
}

- (float)xInterceptAty:(float)y m:(float)m b:(float)b {
	return (y - b) / m / 2 + 0.5;
}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    // Map UIDeviceOrientation to UIInterfaceOrientation.
//    UIInterfaceOrientation orient = UIInterfaceOrientationPortrait;
//    switch ([[UIDevice currentDevice] orientation])
//    {
//        case UIDeviceOrientationLandscapeLeft:
//            orient = UIInterfaceOrientationLandscapeLeft;
//            break;
//
//        case UIDeviceOrientationLandscapeRight:
//            orient = UIInterfaceOrientationLandscapeRight;
//            break;
//
//        case UIDeviceOrientationPortrait:
//            orient = UIInterfaceOrientationPortrait;
//            break;
//
//        case UIDeviceOrientationPortraitUpsideDown:
//            orient = UIInterfaceOrientationPortraitUpsideDown;
//            break;
//
//        case UIDeviceOrientationFaceUp:
//        case UIDeviceOrientationFaceDown:
//        case UIDeviceOrientationUnknown:
//            // When in doubt, stay the same.
//            orient = fromInterfaceOrientation;
//            break;
//    }
//    videoCamera.outputImageOrientation = orient;
//
//}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return YES; // Support all orientations.
//}

//- (IBAction)updateSliderValue:(id)sender
//{
//    [(GPUImageSepiaFilter *)filter setIntensity:[(UISlider *)sender value]];
//}

@end
