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
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];

    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
	videoCamera.runBenchmark = YES;

//    filter = [[GPUImageSepiaFilter alloc] init];
	GPUImageView *filterView = (GPUImageView *)self.view;

	// Hough
	GPUImageHoughTransformLineDetector *lineDetector = [[GPUImageHoughTransformLineDetector alloc] init];
//	lineDetector.edgeThreshold = 0.05f; // default = 0.0
	lineDetector.lineDetectionThreshold = 0.175f; // default = 0.12
	
    // Daisy chain the filters together (you can add as many filters as you like)
    [videoCamera addTarget:lineDetector];
	[videoCamera addTarget:filterView];

    [lineDetector setLinesDetectedBlock:^(GLfloat* lineArray, NSUInteger linesDetected, CMTime frameTime){
        NSLog(@"Number of lines: %ld", (unsigned long)linesDetected);
        
        GPUImageLineGenerator *lineGenerator = [[GPUImageLineGenerator alloc] init];
//        lineGenerator.crosshairWidth = 10.0;
        [lineGenerator setLineColorRed:1.0 green:0.0 blue:0.0];
        [lineGenerator forceProcessingAtSize:CGSizeMake(640.0, 480.0)];
        
//        GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
//        [blendFilter forceProcessingAtSize:CGSizeMake(640.0, 480.0)];
//        
//        [videoCamera addTarget:blendFilter];
//        
//        [lineGenerator addTarget:blendFilter];
//		
//		[blendFilter addTarget:filterView];
//        
//        [blendFilter useNextFrameForImageCapture];
		
        [lineGenerator renderLinesFromArray:lineArray count:linesDetected frameTime:frameTime];
    }];

//    [videoCamera addTarget:filter];
//    [filter addTarget:filterView];
	
    [videoCamera startCameraCapture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
