//
//  cellSplitAddNewMain.swift
//  FIN
//
//  Created by Florian Riel on 27.09.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellSplitAddNewMain: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var circleLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    weak var delegate: cellSplitAddNewMainDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
        
        if nameTextField != nil {
            nameTextField.delegate = self
            nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.backgroundColor = backgroundColor
        } else {
            self.backgroundColor = .secondarySystemBackground
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
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.backgroundColor = backgroundColor
        } else {
            self.backgroundColor = .secondarySystemBackground
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        
        circleView.layer.cornerRadius = 10//circleView.bounds.size.width/2
        circleView.clipsToBounds = true
        
        circleView.layer.borderWidth = 1
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.delegate?.textFieldDidChange(newText: nameTextField.text ?? "")
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        self.delegate?.textFieldDidChange(newText: nameTextField.text ?? "")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.delegate?.textFieldDidChange(newText: nameTextField.text ?? "")
        if (nameTextField.text ?? "").count == 0 {
            circleLabel.text = ""
        } else if (nameTextField.text ?? "").count == 1 {
            circleLabel.text = nameTextField.text?.prefix(1).uppercased()
        } else {
            circleLabel.text = nameTextField.text?.prefix(2).uppercased()
        }
    }
}

protocol cellSplitAddNewMainDelegate: AnyObject {
    func textFieldDidChange(newText: String)
}
