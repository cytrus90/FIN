//
//  cellPurchase.swift
//  FIN
//
//  Created by Florian Riel on 11.01.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit

class cellPurchase: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
    weak var delegate: cellPurchaseDelegate?
    
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
        
        outlineView.layer.borderColor = UIColor.clear.cgColor
        outlineView.backgroundColor = .clear
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = backgroundGeneralColor
//            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
//            outlineView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            
            purchaseButton.backgroundColor = .white
            purchaseButton.layer.borderColor = UIColor.white.cgColor
            
            restoreButton.backgroundColor = .white
            restoreButton.layer.borderColor = UIColor.white.cgColor
        } else {
            self.backgroundColor = .secondarySystemBackground
//            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
//            outlineView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
            
            purchaseButton.backgroundColor = .black
            purchaseButton.layer.borderColor = UIColor.black.cgColor
            
            restoreButton.backgroundColor = .black
            restoreButton.layer.borderColor = UIColor.black.cgColor
        }
        
        purchaseButton.setTitle(NSLocalizedString("purchaseButtonTitle", comment: "purchase"), for: .normal)
        restoreButton.setTitle(NSLocalizedString("restoreTitle", comment: "resore"), for: .normal)
        
        purchaseButton.layer.borderWidth = 1
        purchaseButton.layer.cornerRadius = 10
        purchaseButton.tintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1.0)
        
        restoreButton.layer.borderWidth = 1
        restoreButton.layer.cornerRadius = 10
        restoreButton.tintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1.0)
    }
    
    @IBAction func purchaseButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.purchaseButton.transform = self.purchaseButton.transform.scaledBy(x: 0.9, y: 0.9)
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                self.purchaseButton.transform = CGAffineTransform.identity
              }, completion: { _ in
                self.delegate?.purchaseButtonPressed()
              })
            })
    }
    
    @IBAction func restoreButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.restoreButton.transform = self.restoreButton.transform.scaledBy(x: 0.9, y: 0.9)
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                self.restoreButton.transform = CGAffineTransform.identity
              }, completion: { _ in
                self.delegate?.restoreButtonPressed()
              })
            })
    }
}

protocol cellPurchaseDelegate: AnyObject {
    func purchaseButtonPressed()
    func restoreButtonPressed()
}
