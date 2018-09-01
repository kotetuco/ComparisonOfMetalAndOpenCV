//
//  ImageProcessingUseCase.swift
//  ComparisonOfMetalAndOpneCV
//
//  Created by kotetu on 2018/09/01.
//  Copyright © 2018年 kotetu. All rights reserved.
//

import UIKit

enum FilterType: Int {
    case threshold = 0
    case blur
    case gaussianBlur
    case resize
}

final class ImageProcessingUseCase {
    
    // threshold
    private static let currentThreshold = 128
    private static let maxThreshold = 255
    
    // blur
    private static let blurScale: Double = 0.75
    private static let blurKetnelWidth: Int = 1023
    private static let blurKetnelHeight: Int = 1023
    
    // gaussianBlur
    private static let sigma: Float = 128
    
    // resize
    private static let resizeScale: Double = 0.5

    static func doFilter(sourceImage: UIImage, imageProcessor: ImageProcessor, filterType: FilterType, completion:@escaping (UIImage?, TimeInterval) -> ()) {
        DispatchQueue.global().async {
            let start = Date()
            let outputImage: UIImage?
            switch filterType {
            case .threshold:
                outputImage = imageProcessor.threshold(sourceImage: sourceImage,
                                                       threashold: currentThreshold,
                                                       maxValue: maxThreshold)
            case .blur:
                outputImage = imageProcessor.blur(sourceImage: sourceImage,
                                                  width: blurKetnelWidth,
                                                  height: blurKetnelHeight,
                                                  scale: blurScale)
            case .gaussianBlur:
                outputImage = imageProcessor.gaussianBlur(sourceImage: sourceImage, sigma: sigma)
            case .resize:
                outputImage = imageProcessor.resize(sourceImage: sourceImage, scale: resizeScale)
            }
            
            let elapsed = Date().timeIntervalSince(start)
            DispatchQueue.main.async {
                completion(outputImage, elapsed)
            }
        }
    }
    
}
