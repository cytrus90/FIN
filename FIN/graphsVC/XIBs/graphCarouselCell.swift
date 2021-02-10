//
//  graphCarouselCell.swift
//  FIN
//
//  Created by Florian Riel on 25.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import ScalingCarousel

class graphCarouselCell: ScalingCarouselCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var arrowLeft: UIImageView!
    @IBOutlet weak var arrowRight: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        arrowLeft.image = arrowLeft.image?.withRenderingMode(.alwaysTemplate)
        arrowRight.image = arrowRight.image?.withRenderingMode(.alwaysTemplate)
        
        self.mainView.layer.borderWidth = 1
        self.cornerRadius = 10
        
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
            self.mainView.backgroundColor = .white
            self.mainView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .clear
            self.mainView.backgroundColor = .black
            self.mainView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }
}
