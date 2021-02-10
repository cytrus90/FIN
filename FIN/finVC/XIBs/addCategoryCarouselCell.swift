//
//  addCategoryCarouselCell.swift
//  FIN
//
//  Created by Florian Riel on 22.01.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit
import ScalingCarousel

class addCategoryCarouselCell: ScalingCarouselCell {

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    func initView() {
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        outlineView.layer.borderColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1).cgColor
        outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.2)
        label.textColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    }
}
