//
//  transactionSplitRow.swift
//  FIN
//
//  Created by Florian Riel on 17.10.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class transactionSplitRow: UIView, UITextFieldDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    
    weak var delegate: transactionSplitRowDelegate?
    
    func initView() {
        if amountTextField != nil {
            amountTextField.delegate = self
            amountTextField.addTarget(self, action: #selector(self.amountTextFieldDidChange(_:)), for: .editingChanged)
        }
        
        amountTextField.keyboardType = .decimalPad
    }
    
    @objc func amountTextFieldDidChange(_ textField: UITextField) {
        self.delegate?.textFieldChanged(text: amountTextField.text ?? "", tag: self.tag)
    }
}

protocol transactionSplitRowDelegate: AnyObject {
    func textFieldChanged(text: String, tag: Int)
}
