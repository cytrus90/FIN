//
//  cellCategoryAdd.swift
//  FIN
//
//  Created by Florian Riel on 30.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellCategoryAdd: UITableViewCell {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cellOutlineView: UIView!
    
    weak var delegate: cellCategoryAddDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellOutlineView.layer.borderWidth = 1
        cellOutlineView.layer.cornerRadius = 10
        
//        addButton.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        addButton.layer.borderWidth = 1
        addButton.layer.cornerRadius = 10
        addButton.tintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1.0)
        
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
            addButton.backgroundColor = .white
            cellOutlineView.backgroundColor = .white
            addButton.layer.borderColor = UIColor.white.cgColor
            cellOutlineView.layer.borderColor = addButton.layer.borderColor
        } else {
            self.backgroundColor = .clear
            addButton.backgroundColor = .black
            addButton.layer.borderColor = UIColor.black.cgColor
            cellOutlineView.backgroundColor = .black
            cellOutlineView.layer.borderColor = addButton.layer.borderColor
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.addButton.transform = self.transform.scaledBy(x: 0.9, y: 0.9)
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                self.addButton.transform = CGAffineTransform.identity
                self.delegate?.addButtonPressed()
              })
            })
    }
    
}

protocol cellCategoryAddDelegate: AnyObject {
    func addButtonPressed()
}
