//
//  cellGraphSettingsTVC.swift
//  FIN
//
//  Created by Florian Riel on 26.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellGraphSettingsTVC: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    weak var delegate: cellGraphSettingsTVSDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        initView()
    }
    
    func initView() {
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)], for: .normal)
        
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.backgroundColor = .clear
        } else {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }

    @IBAction func segementControllChanged(_ sender: Any) {
        self.delegate?.selectedGraphChanged(selected: segmentControl.selectedSegmentIndex)
    }
}

protocol cellGraphSettingsTVSDelegate: AnyObject {
    func selectedGraphChanged(selected: Int)
}
