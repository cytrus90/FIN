//
//  cellSplitGeneral.swift
//  FIN
//
//  Created by Florian Riel on 27.09.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellSplitTransactionGeneral: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var circleLabel: UILabel!
    @IBOutlet weak var circleImage: UIImageView!
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    
    @IBOutlet weak var arrowRight: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        initView()
    }

    func initView() {
        arrowRight.image = arrowRight.image?.withRenderingMode(.alwaysTemplate)
        
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
        
        circleView.layer.cornerRadius = 10//circleView.bounds.size.width/2
        circleView.clipsToBounds = true
        
//        circleView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        circleView.layer.borderWidth = 1
    }
}
