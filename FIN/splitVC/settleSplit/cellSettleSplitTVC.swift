//
//  cellSettleSplitTVC.swift
//  FIN
//
//  Created by Florian Riel on 07.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellSettleSplitTVC: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var leftCircleView: UIView!
    @IBOutlet weak var leftCircleLabel: UILabel!
    
    @IBOutlet weak var centerImageView: UIImageView!
    
    @IBOutlet weak var rightCircleView: UIView!
    @IBOutlet weak var rightCircleLabel: UILabel!
    
    @IBOutlet weak var subTitle: UILabel!
    
    @IBOutlet weak var settleAmount: UITextField!
    @IBOutlet weak var currencyButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var settleButton: UIButton!
    
    weak var delegate: cellSettleSplitTVCDelegate?
    
    var currencyButtonHeight: NSLayoutConstraint?
    var currencyButtonWidth: NSLayoutConstraint?
    
    let buttonBackgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.2)
    let buttonBorderColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1).cgColor
    let buttonTextColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    let buttonSelectedBackgroundColor: UIColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    let buttonSelectedTextColor = UIColor.white
    
    override func awakeFromNib() {
        super.awakeFromNib()
        settleButton.setTitle(NSLocalizedString("settle", comment: "Settle"), for: .normal)
        initUI()
        initCurrencyButton()
        
        settleAmount.keyboardType = .decimalPad
        
        if settleAmount != nil {
            settleAmount.delegate = self
            settleAmount.addTarget(self, action: #selector(self.amountTextFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initUI()
    }

    func initUI() {
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        settleButton.layer.borderWidth = 1
        settleButton.layer.cornerRadius = 7
        settleButton.layer.borderColor = buttonBorderColor
        settleButton.backgroundColor = buttonSelectedBackgroundColor
        settleButton.tintColor = buttonSelectedTextColor
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            currencyButton.tintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
            currencyButton.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        } else {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
            currencyButton.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.6)
            currencyButton.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 0.6)
        }
        
        leftCircleView.layer.cornerRadius = leftCircleView.bounds.size.width/2
        leftCircleView.clipsToBounds = true
        
        leftCircleView.layer.borderWidth = 1
        
        rightCircleView.layer.cornerRadius = leftCircleView.bounds.size.width/2
        rightCircleView.clipsToBounds = true
        
        rightCircleView.layer.borderWidth = 1
    }
    
    func initCurrencyButton() {
        currencyButton.layer.borderWidth = 1
        currencyButton.layer.cornerRadius = 10
        
        currencyButtonWidth = currencyButton.widthAnchor.constraint(equalTo: settleAmount.heightAnchor, multiplier: 1.0)
        currencyButtonWidth?.isActive = true
        
        currencyButtonHeight = currencyButton.widthAnchor.constraint(equalTo: settleAmount.heightAnchor, multiplier: 1.0)
        currencyButtonHeight?.isActive = true
        
        let currencyCode = Locale.current.currencyCode ?? "EUR"
        currencyButton.setTitle(getSymbol(forCurrencyCode: currencyCode), for: .normal)
    }
    
    @IBAction func currencyButtonPressed(_ sender: Any) {
    }
    
    @IBAction func settleButtonPressed(_ sender: Any) {
        self.delegate?.settleButtonPressed(buttonTag: settleButton.tag)
    }
    
    @objc func amountTextFieldDidChange(_ textField: UITextField) {
        self.delegate?.amountTextFieldDidChange(newText: (textField.text ?? ""), textFieldTag: textField.tag)
    }
    
    // MARK: HELPER FUNCTIONS
    func getSymbol(forCurrencyCode code: String) -> String? {
        let locale = NSLocale(localeIdentifier: code)
        if locale.displayName(forKey: .currencySymbol, value: code) == code {
            let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: code)
        }
        return locale.displayName(forKey: .currencySymbol, value: code)
    }
}

protocol cellSettleSplitTVCDelegate: AnyObject {
    func amountTextFieldDidChange(newText:String, textFieldTag:Int)
    func settleButtonPressed(buttonTag:Int)
}
