//
//  ImageProcessor.swift
//  ComparisonOfMetalAndOpneCV
//
//  Created by kotetu on 2018/09/01.
//  Copyright © 2018年 kotetu. All rights reserved.
//

import UIKit

protocol ImageProcessor {
    func threshold(sourceImage: UIImage, threashold: Int, maxValue: Int) -> UIImage?
    func blur(sourceImage: UIImage, width: Int, height: Int, scale: Double) -> UIImage?
    func gaussianBlur(sourceImage: UIImage, sigma: Float) -> UIImage?
    func resize(sourceImage: UIImage, scale: Double) -> UIImage?
}
