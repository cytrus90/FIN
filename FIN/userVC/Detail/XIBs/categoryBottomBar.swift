//
//  categoryBottomBar.swift
//  FIN
//
//  Created by Florian Riel on 11.02.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit

class categoryBottomBar: UIView {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    weak var delegete: categoryBottomBarDelegate?
   
    func initView() {
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)], for: .normal)
        
        segmentControl.setTitle(NSLocalizedString("categorySegmentExpense", comment: "Expenses"), forSegmentAt: 0)
        segmentControl.setTitle(NSLocalizedString("categorySegmentIncome", comment: "Expenses"), forSegmentAt: 1)
        segmentControl.setTitle(NSLocalizedString("categorySegmentSave", comment: "Expenses"), forSegmentAt: 2)
        
        segmentControl.selectedSegmentIndex = 0
    }

    @IBAction func segmentControlChanged(_ sender: Any) {
        self.delegete?.segmentControlChanged(selected: segmentControl.selectedSegmentIndex)
    }
}

protocol categoryBottomBarDelegate: AnyObject {
    func segmentControlChanged(selected: Int)
}
