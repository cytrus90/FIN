//
//  cellListEntry.swift
//  FIN
//
//  Created by Florian Riel on 09.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellListEntry: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var circleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var splitIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        splitIcon.image = UIImage(named: "tabPersonsSelected")?.withRenderingMode(.alwaysTemplate)
        
        initView()
        self.backgroundColor = .clear
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
    }

    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
//            self.backgroundColor = backgroundColor
        } else {
//            self.backgroundColor = .secondarySystemBackground
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        
        circleView.layer.cornerRadius = circleView.bounds.size.width/2
        circleView.clipsToBounds = true
        
        circleView.layer.borderWidth = 5.0
    }
}
