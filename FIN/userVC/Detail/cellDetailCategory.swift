//
//  cellDetailCategory.swift
//  FIN
//
//  Created by Florian Riel on 28.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellDetailCategory: UITableViewCell {

    @IBOutlet weak var cellOutlineView: UIView!
    @IBOutlet weak var cellTopIcon: UIImageView!
    @IBOutlet weak var cellBottomIcon: UIImageView!
    
    @IBOutlet weak var cellTopLabel: UILabel!
    @IBOutlet weak var cellBottomLabel: UILabel!
    
    @IBOutlet weak var cellRightArrow: UIImageView!
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var circleLabel: UILabel!
    @IBOutlet weak var circleImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellOutlineView.layer.borderWidth = 1
        cellOutlineView.layer.cornerRadius = 10
        
        cellRightArrow.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)

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
        } else {
            cellOutlineView.backgroundColor = .black
            cellOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        circleView.layer.cornerRadius = 10//circleView.bounds.size.width/2
        circleView.clipsToBounds = true
        circleView.layer.borderWidth = 1
    }
}
