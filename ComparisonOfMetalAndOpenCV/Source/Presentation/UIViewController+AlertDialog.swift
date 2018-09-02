//
//  UIViewController+AlertDialog.swift
//  ComparisonOfMetalAndOpenCV
//
//  Created by kotetu on 2018/09/01.
//  Copyright © 2018年 kotetu. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(_ description: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title:"エラー",
                                          message: description,
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
