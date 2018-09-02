//
//  OpenCVFunctions.m
//  ComparisonOfMetalAndOpenCV
//
//  Created by kotetu on 2018/09/01.
//  Copyright © 2018年 kotetu. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVFunctions.h"

@implementation OpenCVFunctions

- (UIImage *)thresholdImageWith:(UIImage *)sourceImage threashold:(int)threashold maxValue:(int)maxValue {
    cv::Mat inputMat;
    cv::Mat grayScaleMat;
    cv::Mat outputMat;
    
    UIImageToMat(sourceImage, inputMat);
    
    cv::cvtColor(inputMat, grayScaleMat, cv::COLOR_BGRA2GRAY);
    cv::threshold(grayScaleMat, outputMat, threashold, maxValue, cv::THRESH_BINARY);
    
    return MatToUIImage(outputMat);
}

- (UIImage *)greyScaleImageWith:(UIImage *)sourceImage {
    cv::Mat inputMat;
    cv::Mat outputMat;
    
    UIImageToMat(sourceImage, inputMat);
    
    cv::cvtColor(inputMat, outputMat, cv::COLOR_BGRA2GRAY);
    
    return MatToUIImage(outputMat);
}

- (UIImage *)blurWith:(UIImage *)sourceImage width:(int)width height:(int)height scale:(double)scale {
    cv::Mat inputMat;
    cv::Mat resizeMat;
    cv::Mat outputMat;
    
    UIImageToMat(sourceImage, inputMat);
    
    // kernelサイズが大きくなるとい時間がかかるようになる
    cv::resize(inputMat, resizeMat, cv::Size(0, 0), scale, scale, cv::INTER_LANCZOS4);
    cv::blur(resizeMat, outputMat, cv::Size(width, height));
    
    return MatToUIImage(outputMat);
}

- (UIImage *)gaussianBlurWith:(UIImage *)sourceImage sigma:(float)sigma width:(int)width height:(int)height {
    cv::Mat inputMat;
    cv::Mat outputMat;
    
    UIImageToMat(sourceImage, inputMat);
    
    // kernelサイズが大きくなるとい時間がかかるようになる
    cv::GaussianBlur(inputMat, outputMat, cv::Size(width, height), sigma);
    
    return MatToUIImage(outputMat);
}

- (UIImage *)resizeWith:(UIImage *)sourceImage scale:(double)scale {
    cv::Mat inputMat;
    cv::Mat outputMat;
    
    UIImageToMat(sourceImage, inputMat);
    
    cv::resize(inputMat, outputMat, cv::Size(0, 0), scale, scale, cv::INTER_LANCZOS4);
    
    return MatToUIImage(outputMat);
}

@end
