//
//  listBottomBar.swift
//  FIN
//
//  Created by Florian Riel on 09.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class listFilterBottomBar: UIView {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    weak var delegete: listFilterBottomBarDelegate?
    
    func initView() {
        
        
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)], for: .normal)
        
        segmentControl.setTitle(NSLocalizedString("filterCategorySegmentControll", comment: "filterCategorySegmentControll Text"), forSegmentAt: 0)
        segmentControl.setTitle(NSLocalizedString("filterTagSegmentControll", comment: "filterCategorySegmentControll"), forSegmentAt: 1)
        
        segmentControl.selectedSegmentIndex = 0
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        self.delegete?.segmentControlChanged(selected: segmentControl.selectedSegmentIndex)
//        UIImpactFeedbackGenerator().impactOccurred()
    }
}

protocol listFilterBottomBarDelegate: AnyObject {
    func segmentControlChanged(selected: Int)
}
