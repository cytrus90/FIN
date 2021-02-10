//
//  cellSplitAddNewSelect.swift
//  FIN
//
//  Created by Florian Riel on 27.09.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellSplitAddNewSelect: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var updateButtom: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        updateButtom.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        updateButtom.layer.borderWidth = 1
        updateButtom.layer.cornerRadius = 10
        updateButtom.tintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1.0)
        
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            outlineView.backgroundColor = .white
            updateButtom.layer.borderColor = UIColor.white.cgColor
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.backgroundColor = backgroundColor
        } else {
            self.backgroundColor = .secondarySystemBackground
            updateButtom.layer.borderColor = UIColor.black.cgColor
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }
    
    func initView() {
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            outlineView.backgroundColor = .white
            updateButtom.layer.borderColor = UIColor.white.cgColor
            outlineView.layer.borderColor = updateButtom.layer.borderColor
            self.backgroundColor = backgroundColor
        } else {
            self.backgroundColor = .secondarySystemBackground
            updateButtom.layer.borderColor = UIColor.black.cgColor
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = updateButtom.layer.borderColor
        }
    }

    @IBAction func updateButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.updateButtom.transform = self.transform.scaledBy(x: 0.9, y: 0.9)
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                self.updateButtom.transform = CGAffineTransform.identity
              }, completion: { _ in
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name("openDetailList"), object: nil)
              })
            })        
    }
}
