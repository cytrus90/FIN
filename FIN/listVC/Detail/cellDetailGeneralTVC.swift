//
//  cellDetailGeneral.swift
//  FIN
//
//  Created by Florian Riel on 30.11.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellDetailGeneralTVC: UITableViewCell {

    @IBOutlet weak var cellOutlineView: UIView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionSubtitleLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var circleLabel: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var stackview: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellOutlineView.layer.borderWidth = 1
        cellOutlineView.layer.cornerRadius = 10
                
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
    }

    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            cellOutlineView.backgroundColor = .white
            cellOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.backgroundColor = .clear
        } else {
            self.backgroundColor = .clear
            cellOutlineView.backgroundColor = .black
            cellOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        
        circleView.layer.cornerRadius = circleView.bounds.size.width/2
        circleView.clipsToBounds = true
        
        circleView.layer.borderWidth = 1
    }

}
