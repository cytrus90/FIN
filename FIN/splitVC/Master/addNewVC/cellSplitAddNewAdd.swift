//
//  splitAddNewAdd.swift
//  FIN
//
//  Created by Florian Riel on 27.09.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellSplitAddNewAdd: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    weak var delegate: cellSplitAddNewAddDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addButton.setTitle(NSLocalizedString("addButtonText", comment: "Add"), for: .normal)
        
//        addButton.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        addButton.layer.borderWidth = 1
        addButton.layer.cornerRadius = 10
        addButton.tintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1.0)
        
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            addButton.layer.borderColor = UIColor.white.cgColor
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.backgroundColor = backgroundColor
        } else {
            self.backgroundColor = .secondarySystemBackground
            addButton.layer.borderColor = UIColor.black.cgColor
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }


    func initView() {
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            addButton.layer.borderColor = UIColor.white.cgColor
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = addButton.layer.borderColor
            self.backgroundColor = backgroundColor
        } else {
            self.backgroundColor = .secondarySystemBackground
            addButton.layer.borderColor = UIColor.black.cgColor
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = addButton.layer.borderColor
        }
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.addButton.transform = self.transform.scaledBy(x: 0.9, y: 0.9)
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                self.addButton.transform = CGAffineTransform.identity
              }, completion: { _ in
                self.delegate?.addButtonPressed()
              })
            })
    }
}

protocol cellSplitAddNewAddDelegate: AnyObject {
    func addButtonPressed()
}
