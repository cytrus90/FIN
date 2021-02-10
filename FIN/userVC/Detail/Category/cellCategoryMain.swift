//
//  cellCategoryMain.swift
//  FIN
//
//  Created by Florian Riel on 30.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellCategoryMain: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var categoryTitleTextField: UITextField!
    @IBOutlet weak var categoryTypeSegmentControl: UISegmentedControl!
    @IBOutlet weak var outlineView: UIView!
    
    weak var delegate: cellCategoryMainDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        if categoryTitleTextField != nil {
            categoryTitleTextField.delegate = self
        }
        
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initView()
    }

    // MARK: -FUNCTIONS
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
        
        categoryTypeSegmentControl.setTitle(NSLocalizedString("categoryExpenseSegmentTitle", comment: "Expense"), forSegmentAt: 0)
        categoryTypeSegmentControl.setTitle(NSLocalizedString("categoryIncomeSegmentTitle", comment: "Income"), forSegmentAt: 1)
        
        
    }

    @IBAction func categoryTypeSegmentChanged(_ sender: Any) {
        self.delegate?.categoryTypeSegmentChanged(selectedSegment: categoryTypeSegmentControl.selectedSegmentIndex)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.updateText(newText: textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.updateText(newText: textField.text ?? "")
        textField.resignFirstResponder()
    }
}

protocol cellCategoryMainDelegate: AnyObject {
    func categoryTypeSegmentChanged(selectedSegment: Int)
    func updateText(newText: String)
}
