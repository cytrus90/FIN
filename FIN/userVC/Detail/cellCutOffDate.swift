//
//  cellCutOffDate.swift
//  FIN
//
//  Created by Florian Riel on 24.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellCutOffDate: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    
    weak var delegate: cellCutOffDateDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
    }

    func initView() {
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        
        
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        self.delegate?.indoButtonPressed()
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        self.delegate?.switchChanged(newState: `switch`.isOn)
    }
    
}

protocol cellCutOffDateDelegate:AnyObject {
    func indoButtonPressed()
    func switchChanged(newState:Bool)
}
