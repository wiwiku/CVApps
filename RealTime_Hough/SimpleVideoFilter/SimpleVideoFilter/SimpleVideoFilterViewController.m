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
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];

    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
	videoCamera.runBenchmark = YES;

	GPUImageView *filterView = (GPUImageView *)self.view;

	// Hough Lines
	GPUImageHoughTransformLineDetector *lineDetector = [[GPUImageHoughTransformLineDetector alloc] init];
//	lineDetector.edgeThreshold = 0.05f; // default = 0.0
	lineDetector.lineDetectionThreshold = 0.175f; // default = 0.12
	
    // Daisy chain the filters together (you can add as many filters as you like)
    [videoCamera addTarget:lineDetector];
	[videoCamera addTarget:filterView];

    [
     lineDetector setLinesDetectedBlock:^(GLfloat* lineArray, NSUInteger linesDetected, CMTime frameTime)
     {
        NSLog(@"Number of lines: %ld", (unsigned long)linesDetected);
    
        GPUImageLineGenerator *lineGenerator = [[GPUImageLineGenerator alloc] init];
        [lineGenerator setLineColorRed:1.0 green:0.0 blue:0.0];
        [lineGenerator forceProcessingAtSize:CGSizeMake(640.0, 480.0)];
        [lineGenerator renderLinesFromArray:lineArray count:linesDetected frameTime:frameTime];
     }
    ];

    [videoCamera startCameraCapture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
