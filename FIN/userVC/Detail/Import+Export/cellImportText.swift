//
//  cellImportText.swift
//  FIN
//
//  Created by Florian Riel on 20.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellImportText: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
//    @IBOutlet weak var icon1: UIImageView!
    
    @IBOutlet weak var bulletIcon1: UIImageView!
    @IBOutlet weak var bulletIcon2: UIImageView!
    @IBOutlet weak var bulletIcon3: UIImageView!
    @IBOutlet weak var bulletIcon4: UIImageView!
    @IBOutlet weak var bulletIcon5: UIImageView!
    @IBOutlet weak var bulletIcon6: UIImageView!
    @IBOutlet weak var bulletIcon7: UIImageView!
    @IBOutlet weak var bulletIcon8: UIImageView!
    @IBOutlet weak var bulletIcon9: UIImageView!
    
    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var text2: UILabel!
    @IBOutlet weak var text3: UILabel!
    @IBOutlet weak var text4: UILabel!
    @IBOutlet weak var text5: UILabel!
    
    @IBOutlet weak var bullet1: UILabel!
    @IBOutlet weak var bullet2: UILabel!
    @IBOutlet weak var bullet3: UILabel!
    @IBOutlet weak var bullet4: UILabel!
    @IBOutlet weak var bullet5: UILabel!
    @IBOutlet weak var bullet6: UILabel!
    @IBOutlet weak var bullet7: UILabel!
    @IBOutlet weak var bullet8: UILabel!
    @IBOutlet weak var bullet9: UILabel!
    
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
        
//        icon1.image = UIImage(systemName: "arrow.down.doc")?.withRenderingMode(.alwaysTemplate)
        
        bulletIcon1.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        bulletIcon2.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        bulletIcon3.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        bulletIcon4.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        bulletIcon5.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        bulletIcon6.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        bulletIcon7.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        bulletIcon8.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        bulletIcon9.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        
        text1.text = NSLocalizedString("text1", comment: "text1")
        text2.text = NSLocalizedString("text2", comment: "text2")
        text3.text = NSLocalizedString("text3", comment: "text3")
        text4.text = NSLocalizedString("text4", comment: "text4")
        text5.text = NSLocalizedString("text5", comment: "text5")
        
        bullet1.text = NSLocalizedString("bullet1", comment: "bullet1")
        bullet2.text = NSLocalizedString("bullet2", comment: "bullet2")
        bullet3.text = NSLocalizedString("bullet3", comment: "bullet3")
        bullet4.text = NSLocalizedString("bullet4", comment: "bullet4")
        bullet5.text = NSLocalizedString("bullet5", comment: "bullet5")
        bullet6.text = NSLocalizedString("bullet6", comment: "bullet6")
//        bullet7.text = NSLocalizedString("bullet7", comment: "bullet7")
//        bullet8.text = NSLocalizedString("bullet8", comment: "bullet8")
//        bullet9.text = NSLocalizedString("bullet9", comment: "bullet9")
    }
}
