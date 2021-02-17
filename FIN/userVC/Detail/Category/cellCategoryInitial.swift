//
//  cellCategoryInitial.swift
//  FIN
//
//  Created by Florian Riel on 14.02.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit

class cellCategoryInitial: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var infoButton: UIButton!
    
    weak var delegate: cellCategoryInitialDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        if textField != nil {
            textField.keyboardType = .decimalPad
            textField.delegate = self
        }
        
        initView()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initView()
    }
    
    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = UIColor.white.cgColor
        } else {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = UIColor.black.cgColor
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.delegate?.textFieldEdited(text: textField.text ?? "", textFieldTag: textField.tag)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        self.delegate?.textFieldEdited(text: textField.text ?? "", textFieldTag: textField.tag)
    }
    
    @IBAction func infoPressed(_ sender: Any) {
        self.delegate?.infoButtonPressed(textFieldTag: textField.tag)
    }
}

protocol cellCategoryInitialDelegate: AnyObject {
    func infoButtonPressed(textFieldTag:Int)
    func textFieldEdited(text: String, textFieldTag:Int)
}
