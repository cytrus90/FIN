//
//  cellGraphSettingsDetailsTVC.swift
//  FIN
//
//  Created by Florian Riel on 26.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellGraphSettingsDetailsTVC: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var segmentControl1: UISegmentedControl!
    
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var segmentControl2: UISegmentedControl!
    
    @IBOutlet weak var segmentControl3: UISegmentedControl!
    
    weak var delegate: cellGraphSettingsDetailsTVCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        initView()
    }

    func initView() {
        segmentControl1.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        segmentControl1.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)], for: .normal)
        
        segmentControl2.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        segmentControl2.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)], for: .normal)
        
        segmentControl3.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        segmentControl3.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)], for: .normal)
        
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

    @IBAction func segment1Changed(_ sender: Any) {
        self.delegate?.graphOption1Changed(selected: segmentControl1.selectedSegmentIndex)
    }
    
    @IBAction func segment2Changed(_ sender: Any) {
        self.delegate?.graphOption2Changed(selected: segmentControl2.selectedSegmentIndex)
    }
    
    @IBAction func segment3Changed(_ sender: Any) {
        self.delegate?.graphOption3Changed(selected: segmentControl3.selectedSegmentIndex)
    }
}

protocol cellGraphSettingsDetailsTVCDelegate: AnyObject {
    func graphOption1Changed(selected: Int)
    func graphOption2Changed(selected: Int)
    func graphOption3Changed(selected: Int)
}
