//
//  ControlPanelTableViewController.swift
//  ComparisonOfMetalAndOpneCV
//
//  Created by kotetu on 2018/09/01.
//  Copyright © 2018年 kotetu. All rights reserved.
//

import UIKit

enum ImageType: Int {
    case small = 0
    case large
}

enum FrameworkType: Int {
    case metal = 0
    case openCV
}

class ControlPanelTableViewController: UITableViewController {

    private let presenter = ControlPanelPresenter()
    
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var imageSelectorSegment: UISegmentedControl!
    @IBOutlet weak var frameworkSelectorSegment: UISegmentedControl!
    @IBOutlet weak var filterSelectorSegment: UISegmentedControl!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var filteredTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.setView(view: self)
        presenter.start()
        updateSelection()

        self.tableView.tableFooterView = UIView()
    }
    
    @IBAction func tapFilterButton(_ sender: Any) {
        presenter.doFilter()
    }
    
    @IBAction func segmentSelected(_ sender: Any) {
        updateSelection()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }

}

extension ControlPanelTableViewController: ControlPanelContractView {

    func metalInitializationError() {
        showAlert("Metalの初期化に失敗しました。")
    }
    
    func filteringError() {
        showAlert("画像処理に失敗しました。")
    }
    
    func reloadImage(newImage: UIImage?) {
        displayImageView.image = newImage
    }

    func updateTime(text: String) {
        filteredTimeLabel.text = text
    }
    
    func disableInteraction() {
        filterButton.isEnabled = false
        tableView.isUserInteractionEnabled = false
    }
    
    func enableInteraction() {
        filterButton.isEnabled = true
        tableView.isUserInteractionEnabled = true
    }
    
}

private extension ControlPanelTableViewController {
    
    func updateSelection() {
        guard
            let selectedImage = ImageType(rawValue: imageSelectorSegment.selectedSegmentIndex),
            let selectedFramework = FrameworkType(rawValue: frameworkSelectorSegment.selectedSegmentIndex),
            let selectedFilter = FilterType(rawValue: filterSelectorSegment.selectedSegmentIndex) else {
                return
        }
        
        presenter.select(image: selectedImage, framework: selectedFramework, filter: selectedFilter)
    }
    
}
