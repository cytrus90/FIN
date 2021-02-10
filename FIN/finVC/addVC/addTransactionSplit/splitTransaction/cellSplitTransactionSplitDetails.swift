//
//  cellSplitTransactionSplitDetails.swift
//  FIN
//
//  Created by Florian Riel on 17.10.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellSplitTransactionSplitDetails: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var topLabelLeft: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
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
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.backgroundColor = backgroundColor
        } else {
            self.backgroundColor = .secondarySystemBackground
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }

}
