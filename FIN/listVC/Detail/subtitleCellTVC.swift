//
//  subtitleCellTVC.swift
//  FIN
//
//  Created by Florian Riel on 30.11.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class subtitleCellTVC: UITableViewCell {

    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initCell()
    }

    func initCell() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            subtitleLabel.textColor = .secondaryLabel
        } else {
            subtitleLabel.textColor = .secondaryLabel
        }
    }
}
