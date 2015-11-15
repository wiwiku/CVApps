//
//  ViewController.m
//  GPUImage_OpenGL_ES_first_prototype
//
//  Created by Jaineel Dalal on 11/15/15.
//  Copyright © 2015 Jaineel Dalal. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>

@interface ViewController ()
{
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
    UIImage *inputImage = [UIImage imageNamed:@"prince_book.jpg"];
    
    // Initialize filters
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
    
    // Grayscale
    GPUImageGrayscaleFilter *stillImageFilter = [[GPUImageGrayscaleFilter alloc] init];
    
    // Gaussian Blur
    GPUImageGaussianBlurFilter* blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    blurFilter.blurRadiusInPixels = 3.5;
    blurFilter.blurPasses = 1;
    
    // Resizing the image
    GPUImageTransformFilter *transformFilter = [[GPUImageTransformFilter alloc] init];
    CGAffineTransform resizeTransform = CGAffineTransformMakeScale(.2, .2);
    transformFilter.affineTransform = resizeTransform;
    GPUImageTransformFilter *resizeBackImageFilter = [[GPUImageTransformFilter alloc] init];
    CGAffineTransform resizeBackTransform = CGAffineTransformMakeScale(5, 5);
    resizeBackImageFilter.affineTransform = resizeBackTransform;
    
    // Canny edge detection
    GPUImageCannyEdgeDetectionFilter* cannyFilter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
    cannyFilter.upperThreshold = .1;
    
    // Daisy chain the filters together (you can add as many filters as you like)
    [stillImageSource addTarget:stillImageFilter];
    [stillImageFilter addTarget:blurFilter];
    [blurFilter addTarget:transformFilter];
    [transformFilter addTarget:resizeBackImageFilter];
    [resizeBackImageFilter addTarget:cannyFilter];
    [cannyFilter addTarget:imageView_];
    
    // Process the image
    [stillImageSource processImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
