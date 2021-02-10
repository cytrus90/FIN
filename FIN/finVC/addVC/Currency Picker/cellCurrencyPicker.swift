//
//  currencyPickerTVC.swift
//  FIN
//
//  Created by Florian Riel on 27.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellCurrencyPicker: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rightLabel.textColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
