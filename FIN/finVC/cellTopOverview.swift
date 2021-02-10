//
//  cellTopOverview.swift
//  FIN
//
//  Created by Florian Riel on 05.01.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit
import Charts

class cellTopOverview: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    
    @IBOutlet weak var pieChart: PieChartView!
    
    @IBOutlet weak var secondSubLabel: UILabel!
    
    @IBOutlet weak var latestTransactionStackView: UIStackView!
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var circleLabel: UILabel!
    
    @IBOutlet weak var transactionDescriptionLabel: UILabel!
    @IBOutlet weak var transactionSubLabel: UILabel!
    @IBOutlet weak var transactionIcon: UIImageView!
    
    @IBOutlet weak var transactionAmount: UILabel!
    
    @IBOutlet weak var transactionArrowIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initView()
    }

    func initView() {
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
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
