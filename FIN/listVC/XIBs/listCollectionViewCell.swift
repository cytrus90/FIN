//
//  listCollectionViewCell.swift
//  FIN
//
//  Created by Florian Riel on 12.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import ScalingCarousel

class listCollectionViewCell: ScalingCarouselCell {

    @IBOutlet weak var arrowRight: UIImageView!
    @IBOutlet weak var arrowLeft: UIImageView!
    
    @IBOutlet weak var expensesStackView: UIStackView!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var expensesAmount: UILabel!
    
    @IBOutlet weak var earningsStackView: UIStackView!
    @IBOutlet weak var earningsLabel: UILabel!
    @IBOutlet weak var earningsAmount: UILabel!
    
    @IBOutlet weak var savedStackView: UIStackView!
    @IBOutlet weak var savedLabel: UILabel!
    @IBOutlet weak var savedAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        expensesLabel.text = NSLocalizedString("topPickerExpensesLabel", comment: "Expenses Label")
        earningsLabel.text = NSLocalizedString("topPickerEarningsLabel", comment: "Earnings Label")
        savedLabel.text = NSLocalizedString("topPickerSavingsLabel", comment: "Savings Label")
        
        arrowLeft.image = arrowLeft.image?.withRenderingMode(.alwaysTemplate)
        arrowRight.image = arrowRight.image?.withRenderingMode(.alwaysTemplate)
    }
}
