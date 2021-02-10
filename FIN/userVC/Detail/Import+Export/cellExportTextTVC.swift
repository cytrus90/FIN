//
//  cellExportTextTVC.swift
//  FIN
//
//  Created by Florian Riel on 24.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellExportTextTVC: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var textE1: UILabel!
    
    @IBOutlet weak var bulletIconE1: UIImageView!
    @IBOutlet weak var bulletE1: UILabel!
    
    @IBOutlet weak var bulletIconE2: UIImageView!
    @IBOutlet weak var bulletE2: UILabel!
    
    @IBOutlet weak var bulletIconE3: UIImageView!
    @IBOutlet weak var bulletE3: UILabel!
    
    @IBOutlet weak var bulletIconE4: UIImageView!
    @IBOutlet weak var bulletE4: UILabel!
    
    @IBOutlet weak var bulletIconE5: UIImageView!
    @IBOutlet weak var bulletE5: UILabel!
    
    @IBOutlet weak var bulletIconE6: UIImageView!
    @IBOutlet weak var bulletE6: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
    }

    func initView() {
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = backgroundColor
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .secondarySystemBackground
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        textE1.text = NSLocalizedString("textE1", comment: "Export Text")
        
        bulletIconE1.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        bulletIconE2.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        bulletIconE3.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        bulletIconE4.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        bulletIconE5.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        bulletIconE6.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        
        bulletE1.text = NSLocalizedString("bullet2", comment: "Date")
        bulletE2.text = NSLocalizedString("bullet1", comment: "Amount")
        bulletE3.text = NSLocalizedString("bullet4", comment: "Description")
        bulletE4.text = NSLocalizedString("bullet3", comment: "Category")
        bulletE5.text = NSLocalizedString("bullet5", comment: "Currency Code")
        bulletE6.text = NSLocalizedString("bullet6", comment: "Exchange Rate")
    }
}
