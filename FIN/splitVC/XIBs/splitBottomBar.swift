//
//  listBottomBar.swift
//  FIN
//
//  Created by Florian Riel on 09.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class splitBottomBar: UIView {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    weak var delegete: splitBottomBarDelegate?
    
    func initView() {
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)], for: .normal)
        
        segmentControl.setTitle(NSLocalizedString("bottomSegmentGroups", comment: "Segment Group Text"), forSegmentAt: 0)
        segmentControl.setTitle(NSLocalizedString("bottomSegmentUsers", comment: "Segment User Text"), forSegmentAt: 1)
        
        if selectedSplitSegment != nil {
            segmentControl.selectedSegmentIndex = selectedSplitSegment ?? 0
        } else {
            segmentControl.selectedSegmentIndex = selectedSegement
        }
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        self.delegete?.segmentControlChanged(selected: segmentControl.selectedSegmentIndex)
//        UIImpactFeedbackGenerator().impactOccurred()
    }
}

protocol splitBottomBarDelegate: AnyObject {
    func segmentControlChanged(selected: Int)
}
