//
//  cellAddTVC.swift
//  FIN
//
//  Created by Florian Riel on 21.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellAddTVC: UITableViewCell {

    @IBOutlet weak var cellAddOutlineView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    weak var delegate: cellAddPressedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellAddOutlineView.layer.borderWidth = 1
        cellAddOutlineView.layer.cornerRadius = 10
        
//        addButton.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        addButton.layer.borderWidth = 1
        addButton.layer.cornerRadius = 10
//        addButton.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.2)
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
            addButton.layer.borderColor = UIColor.white.cgColor
            addButton.backgroundColor = .white
            cellAddOutlineView.backgroundColor = .white
            cellAddOutlineView.layer.borderColor = addButton.layer.borderColor
        } else {
            self.backgroundColor = .clear
            addButton.layer.borderColor = UIColor.black.cgColor
            addButton.backgroundColor = .black
            cellAddOutlineView.backgroundColor = .black
            cellAddOutlineView.layer.borderColor = addButton.layer.borderColor
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

protocol cellAddPressedDelegate: AnyObject {
    func addPressed()
}
