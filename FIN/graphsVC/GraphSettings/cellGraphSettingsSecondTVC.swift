//
//  cellGraphSettingsSecondTVC.swift
//  FIN
//
//  Created by Florian Riel on 08.03.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit

class cellGraphSettingsSecondTVC: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var secondSwitch: UISwitch!
    
    weak var delegate:cellGraphSettingsSecondTVCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
    }

    func initView() {
        secondLabel.text = NSLocalizedString("showSecondGraphLabel", comment: "Show Second")
        
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
    
    @IBAction func secondSwitchSwitched(_ sender: Any) {
        self.delegate?.secondSwitchChanged(newState: secondSwitch.isOn)
    }
}

protocol cellGraphSettingsSecondTVCDelegate: AnyObject {
    func secondSwitchChanged(newState:Bool)
}
