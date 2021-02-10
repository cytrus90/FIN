//
//  categoryCarouselCell.swift
//  FIN
//
//  Created by Florian Riel on 05.01.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit
import ScalingCarousel

class categoryCarouselCell: ScalingCarouselCell {
    
    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }
    
    func initView() {
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
    }
}
