//
//  ControlPanelPresenter.swift
//  ComparisonOfMetalAndOpneCV
//
//  Created by kotetu on 2018/09/01.
//  Copyright © 2018年 kotetu. All rights reserved.
//

import UIKit

final class ControlPanelPresenter {

    private var view: ControlPanelContractView!
    
    private var metalShaderDataStore: MetalShaderDataStore!
    private let openCVDataStore = OpenCVDataStore()
    
    private var selectImage: UIImage!
    private var selectImageProcessor: ImageProcessor!
    private var selectFilter: FilterType!

}

extension ControlPanelPresenter: ControlPanelContractPresenter {

    func setView(view: ControlPanelContractView) {
        self.view = view
    }
    
    func start() {
        guard let metalDataStore = MetalShaderDataStore() else {
            view.disableInteraction()
            view.metalInitializationError()
            return
        }
        metalShaderDataStore = metalDataStore
    }
    
    func select(image: ImageType, framework: FrameworkType, filter: FilterType) {
        self.selectImage = sourceImage(with: image)
        self.selectImageProcessor = self.imageProcessor(with: framework)
        self.selectFilter = filter
        
        view.updateTime(text: "-")
        view.reloadImage(newImage: self.selectImage)
    }
    
    func doFilter() {
        view.disableInteraction()
        ImageProcessingUseCase.doFilter(sourceImage: selectImage,
                                        imageProcessor: selectImageProcessor,
                                        filterType: selectFilter)
        { (outputImage, elapsed) in
            guard let outputImage = outputImage else {
                self.view.updateTime(text: "-")
                self.view.filteringError()
                return
            }
            self.view.updateTime(text: "\(elapsed)")
            self.view.reloadImage(newImage: outputImage)
            self.view.enableInteraction()
        }
    }

}

private extension ControlPanelPresenter {
    
    func sourceImage(with selectedImage: ImageType) -> UIImage {
        switch selectedImage {
        case .large:
            return UIImage(named: "large.jpg")!
        case .small:
            return UIImage(named: "small.jpg")!
        }
    }
    
    func imageProcessor(with selectedFramework: FrameworkType) -> ImageProcessor {
        switch selectedFramework {
        case .metal:
            return metalShaderDataStore
        case .openCV:
            return openCVDataStore
        }
    }

}
