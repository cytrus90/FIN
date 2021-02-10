//
//  cellCategorySave.swift
//  FIN
//
//  Created by Florian Riel on 03.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellCategorySave: UITableViewCell {

    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var saveSwitch: UISwitch!
    @IBOutlet weak var outlineView: UIView!
    
    weak var delegate: cellCategorySaveDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        initView()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initView()
    }

    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = UIColor.white.cgColor
        } else {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = UIColor.black.cgColor
        }
        saveLabel.text = NSLocalizedString("categorySaveSegmentTitle", comment: "Save")
    }
    
    @IBAction func switchToggled(_ sender: Any) {
        self.delegate?.saveSwitchChanged(newState: saveSwitch.isOn)
    }
}

protocol cellCategorySaveDelegate: AnyObject {
    func saveSwitchChanged(newState:Bool)
}
