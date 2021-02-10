//
//  categoryPickerView.swift
//  FIN
//
//  Created by Florian Riel on 21.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class categoryPickerView: UIView {

    @IBOutlet weak var categoryLabel: UILabel!
    
    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = backgroundColor
        } else {
            self.backgroundColor = .secondarySystemBackground
        }
        
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        
        self.heightAnchor.constraint(equalToConstant: (categoryLabel.intrinsicContentSize.height+14)).isActive = true
        self.widthAnchor.constraint(equalToConstant: (categoryLabel.intrinsicContentSize.width+14)).isActive = true
    }
}
