//
//  listBottomBar.swift
//  FIN
//
//  Created by Florian Riel on 09.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class splitAddBottomBar: UIView {

    @IBOutlet weak var segmentControl: UISegmentedControl!

    
    func initView() {
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)], for: .normal)
        
        segmentControl.setTitle(NSLocalizedString("bottomAddSegmentGroups", comment: "Segment Add Group Text"), forSegmentAt: 0)
        segmentControl.setTitle(NSLocalizedString("bottomAddSegmentUsers", comment: "Segment Add User Text"), forSegmentAt: 1)
        
        segmentControl.selectedSegmentIndex = selectedSegement
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("addSegmentChanged"), object: nil, userInfo: ["selectedSegment": segmentControl.selectedSegmentIndex])
//        UIImpactFeedbackGenerator().impactOccurred()
    }
}
