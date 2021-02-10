//
//  listBottomBar.swift
//  FIN
//
//  Created by Florian Riel on 09.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class listBottomBar: UIView {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    weak var delegete: listBottomBarDelegate?
    
    func initView() {
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)], for: .normal)
        
        segmentControl.setTitle(NSLocalizedString("bottomSegmentWeekly", comment: "Segment Weekly Text"), forSegmentAt: 0)
        segmentControl.setTitle(NSLocalizedString("bottomSegmentMonthly", comment: "Segment Monthly Text"), forSegmentAt: 1)
        segmentControl.insertSegment(withTitle: NSLocalizedString("bottomSegmentYearly", comment: "Segment Yearly Text"), at: 2, animated: false)
        segmentControl.insertSegment(withTitle: NSLocalizedString("bottomSegmentAll", comment: "Segment All Text"), at: 3, animated: false)
        
        segmentControl.selectedSegmentIndex = 1
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        self.delegete?.segmentControlChanged(selected: segmentControl.selectedSegmentIndex)
        UIImpactFeedbackGenerator().impactOccurred()
    }
}

protocol listBottomBarDelegate: AnyObject {
    func segmentControlChanged(selected: Int)
}
