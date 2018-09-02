//
//  OpenCVDataStore.swift
//  ComparisonOfMetalAndOpenCV
//
//  Created by kotetu on 2018/09/01.
//  Copyright © 2018年 kotetu. All rights reserved.
//

import UIKit

final class OpenCVDataStore: ImageProcessor {
    
    private let openCV = OpenCVFunctions()
    
    func threshold(sourceImage: UIImage, threashold: Int, maxValue: Int) -> UIImage? {
        return openCV.thresholdImage(with: sourceImage, threashold: Int32(threashold), maxValue: Int32(maxValue))
    }
    
    func greyScaleImage(_ sourceImage: UIImage) -> UIImage {
        return openCV.greyScaleImage(with: sourceImage)
    }
    
    func blur(sourceImage: UIImage, width: Int, height: Int, scale: Double) -> UIImage? {
        return openCV.blur(with: sourceImage, width: Int32(width), height: Int32(height), scale: scale)
    }
    
    func gaussianBlur(sourceImage: UIImage, sigma: Float) -> UIImage? {
        // なるべくMPSに近いぼかしになるように調整する
        let width = 511
        let height = 511
        return openCV.gaussianBlur(with: sourceImage, sigma: sigma, width: Int32(width), height: Int32(height))
    }
    
    func resize(sourceImage: UIImage, scale: Double) -> UIImage? {
        return openCV.resize(with: sourceImage, scale: scale)
    }
    
}
