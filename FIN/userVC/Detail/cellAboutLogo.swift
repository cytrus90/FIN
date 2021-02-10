//
//  cellAboutLogo.swift
//  FIN
//
//  Created by Florian Riel on 11.01.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit

class cellAboutLogo: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var title: UILabel!
    
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
            outlineView.layer.borderColor = UIColor.clear.cgColor
            outlineView.backgroundColor = UIColor.clear
            logo.image = UIImage(named: "alpakaLogoBlack")
        } else {
            self.backgroundColor = .clear
            outlineView.layer.borderColor = UIColor.clear.cgColor
            outlineView.backgroundColor =  UIColor.clear
            logo.image = UIImage(named: "alpakaLogoWhite")
        }
        
        title.text = NSLocalizedString("aboutTitleText", comment: "alpako")
    }
}
