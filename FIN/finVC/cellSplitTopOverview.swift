//
//  cellSplitOverview.swift
//  FIN
//
//  Created by Florian Riel on 05.01.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit

class cellSplitTopOverview: UITableViewCell {

    @IBOutlet weak var rightOutlineView: UIView!
    @IBOutlet weak var rightAmountLabel: UILabel!
    @IBOutlet weak var rightIcon: UIImageView!
    @IBOutlet weak var rightSubLabel: UILabel!
    
    @IBOutlet weak var leftOutlineView: UIView!
    @IBOutlet weak var leftAmountLabel: UILabel!
    @IBOutlet weak var leftIcon: UIImageView!
    @IBOutlet weak var leftSubLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initView()
    }
    
    func initView() {
        rightOutlineView.layer.borderWidth = 1
        rightOutlineView.layer.cornerRadius = 10
        
        leftOutlineView.layer.borderWidth = 1
        leftOutlineView.layer.cornerRadius = 10
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            rightOutlineView.backgroundColor = .white
            rightOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            leftOutlineView.backgroundColor = .white
            leftOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
//            self.backgroundColor = backgroundColor
        } else {
//            self.backgroundColor = .secondarySystemBackground
            rightOutlineView.backgroundColor = .black
            rightOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
            leftOutlineView.backgroundColor = .black
            leftOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }
}
