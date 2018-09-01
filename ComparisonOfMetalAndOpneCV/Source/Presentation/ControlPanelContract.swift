//
//  ControlPanelContract.swift
//  ComparisonOfMetalAndOpneCV
//
//  Created by kotetu on 2018/09/01.
//  Copyright © 2018年 kotetu. All rights reserved.
//

import UIKit

protocol ControlPanelContractPresenter {
    
    func setView(view: ControlPanelContractView)
    func start()
    func select(image: ImageType, framework: FrameworkType, filter: FilterType)
    func doFilter()
    
}

protocol ControlPanelContractView {
    
    func metalInitializationError()
    func filteringError()
    func reloadImage(newImage: UIImage?)
    func updateTime(text: String)
    func disableInteraction()
    func enableInteraction()
    
}
