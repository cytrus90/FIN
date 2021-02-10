//
//  listFilterCell.swift
//  FIN
//
//  Created by Florian Riel on 29.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class listFilterCell: UITableViewCell {

    @IBOutlet weak var contentOutline: UIView!
    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    
    @IBOutlet weak var `switch`: UISwitch!
    
    weak var delegete: listFilterCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        initCell()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initCell()
    }
    
    func initCell() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = backgroundColor
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .secondarySystemBackground
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }

    @IBAction func switchChanged(_ sender: Any) {
        self.delegete?.switchChanged(cellTag: self.tag, newState: `switch`.isOn)
    }
}

protocol listFilterCellDelegate:AnyObject {
    func switchChanged(cellTag: Int, newState: Bool)
}
