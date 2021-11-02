//
//  cellAddReceiptTVC.swift
//  FIN
//
//  Created by Florian Riel on 01.11.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit

class cellAddReceiptTVC: UITableViewCell {

    @IBOutlet weak var cellAddOutlineView: UIView!
    @IBOutlet weak var addReceiptButton: UIButton!
    
    weak var delegate: cellAddReceiptPressedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellAddOutlineView.layer.borderWidth = 1
        cellAddOutlineView.layer.cornerRadius = 10
        
        addReceiptButton.layer.borderWidth = 1
        addReceiptButton.layer.cornerRadius = 10
        addReceiptButton.tintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1.0)
        
        addReceiptButton.setTitle(NSLocalizedString("addReceiptButtonText", comment: "Add receipt"), for: .normal)
        
        initUI()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initUI()
    }
    
    func initUI() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            addReceiptButton.layer.borderColor = UIColor.white.cgColor
            addReceiptButton.backgroundColor = .white
            cellAddOutlineView.backgroundColor = .white
            cellAddOutlineView.layer.borderColor = addReceiptButton.layer.borderColor
        } else {
            self.backgroundColor = .clear
            addReceiptButton.layer.borderColor = UIColor.black.cgColor
            addReceiptButton.backgroundColor = .black
            cellAddOutlineView.backgroundColor = .black
            cellAddOutlineView.layer.borderColor = addReceiptButton.layer.borderColor
        }
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.addReceiptButton.transform = self.transform.scaledBy(x: 0.9, y: 0.9)
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                self.addReceiptButton.transform = CGAffineTransform.identity
              }, completion: { _ in
                self.delegate?.addReceiptPressed()
              })
            })
    }
    
}

protocol cellAddReceiptPressedDelegate: AnyObject {
    func addReceiptPressed()
}
