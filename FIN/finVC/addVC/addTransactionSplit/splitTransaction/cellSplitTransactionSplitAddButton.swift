//
//  cellSplitTransactionSplitAddButton.swift
//  FIN
//
//  Created by Florian Riel on 18.10.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellSplitTransactionSplitAddButton: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    weak var delegate: cellSplitTransactionSplitAddButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
//        addButton.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.2)
        addButton.tintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1.0)
        
        initView()
        
        addButton.setTitle(NSLocalizedString("saveText", comment: "Save"), for: .normal)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initView()
    }
    
    func initView() {
        addButton.layer.borderWidth = 1
        addButton.layer.cornerRadius = 10
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = backgroundColor
            addButton.layer.borderColor = UIColor.white.cgColor
            addButton.backgroundColor = .white
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = addButton.layer.borderColor
        } else {
            self.backgroundColor = .secondarySystemBackground
            addButton.layer.borderColor = UIColor.black.cgColor
            addButton.backgroundColor = .black
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
                self.delegate?.addPressed()
              })
            })
    }
}

protocol cellSplitTransactionSplitAddButtonDelegate: AnyObject {
    func addPressed()
}
