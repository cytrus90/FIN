//
//  userDetailTableVCell.swift
//  FIN
//
//  Created by Florian Riel on 12.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellDetailGeneral: UITableViewCell {

    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var cellOutlineView: UIView!
    @IBOutlet weak var cellImageLabel: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellMainStackView: UIStackView!
    @IBOutlet weak var cellLabelArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellOutlineView.layer.borderWidth = 1
        cellOutlineView.layer.cornerRadius = 10
        cellLabelArrow.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        cellMainStackView.heightAnchor.constraint(equalToConstant: (cellLabel.font.pointSize)+3).isActive = true
        
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
    }

    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            cellOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .clear
            cellOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }
}
