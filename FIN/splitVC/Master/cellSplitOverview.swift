//
//  overviewCell.swift
//  FIN
//
//  Created by Florian Riel on 27.09.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellSplitOverview: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var owedLabel: UILabel!
    @IBOutlet weak var owedAmount: UILabel!
    
    @IBOutlet weak var borrowedLabel: UILabel!
    @IBOutlet weak var borrowedAmount: UILabel!
    
    @IBOutlet weak var lowerStackview: UIStackView!
    
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
            self.backgroundColor = .clear
        } else {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        owedLabel.text = NSLocalizedString("owedLabel", comment: "Owed Title")
        borrowedLabel.text = NSLocalizedString("borrowedLabel", comment: "Borrowed Title")
    }
}
