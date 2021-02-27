//
//  cellUserSettings.swift
//  FIN
//
//  Created by Florian Riel on 14.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellUserSettings: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var cellOutlineView: UIView!
    
    @IBOutlet weak var cellMainStackView: UIStackView!
    // Username
    @IBOutlet weak var cellUsernameStackview: UIStackView!
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var cellUsernameIcon: UIImageView!
    @IBOutlet weak var circleLabel: UILabel!
    
    @IBOutlet weak var cellUsernameText: UITextField!
    // Recovery Mail
    @IBOutlet weak var cellRecoveryIcon: UIImageView!
    @IBOutlet weak var cellRecoveryText: UITextField!
    // Switch
    @IBOutlet weak var cellLoginIcon: UIImageView!
    @IBOutlet weak var cellLoginLabel: UILabel!
    @IBOutlet weak var cellLoginSwitch: UISwitch!
    
    weak var delegate: cellUserSettingsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellOutlineView.layer.borderWidth = 1
        cellOutlineView.layer.cornerRadius = 10
        cellUsernameIcon.image = UIImage(named: "tabPersonSelected")?.withRenderingMode(.alwaysTemplate)
//        cellMainStackView.heightAnchor.constraint(equalToConstant: ((cellLoginLabel.font?.pointSize ?? 20)*3)+60).isActive = true
        
        if cellRecoveryText != nil {
            cellRecoveryText.delegate = self
        }
        if cellUsernameText != nil {
            cellUsernameText.delegate = self
            cellUsernameText.addTarget(self, action: #selector(self.usernameTextFieldDidChange(_:)), for: .editingChanged)
        }
        cellUsernameText.keyboardType = .namePhonePad
        cellRecoveryText.keyboardType = .emailAddress
        
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
    }
    
    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
//            cell.backgroundColor = backgroundGeneralColor
            cellOutlineView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            cellOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
//            cell.backgroundColor = .secondarySystemBackground
            cellOutlineView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 6.6)
            cellOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        
        circleView.layer.cornerRadius = 10//circleView.bounds.size.width/2
        circleView.clipsToBounds = true
        
        circleView.layer.borderWidth = 1
    }

    @IBAction func toggleSwitch(_ sender: Any) {
        if cellLoginSwitch != nil {
            if self.cellLoginSwitch.isOn {
                if cellRecoveryText != nil {
                    if wildcard(cellRecoveryText.text ?? "", pattern: "*@*.*") {
                        self.delegate?.loginToggle(newState: self.cellLoginSwitch.isOn)
                        self.delegate?.updateText(newText: cellRecoveryText.text ?? "", textFieldTag: 1)
                    } else {
                        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0 ,animations: {
                            self.cellRecoveryText.alpha = 0.1
                            self.cellRecoveryIcon.alpha = 0.1
                        })
                        UIView.animateKeyframes(withDuration: 0.3, delay: 0.6 ,animations: {
                            self.cellRecoveryText.alpha = 1.0
                            self.cellRecoveryIcon.alpha = 1.0
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            self.cellLoginSwitch.isOn = false
                        })
                    }
                } else {
                    self.cellLoginSwitch.isOn = false
                }
            } else {
                self.delegate?.loginToggle(newState: self.cellLoginSwitch.isOn)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.delegate?.updateText(newText: textField.text ?? "", textFieldTag: textField.tag)
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.updateText(newText: textField.text ?? "", textFieldTag: textField.tag)
        textField.resignFirstResponder()
    }
    
    @objc func usernameTextFieldDidChange(_ textField: UITextField) {
//        self.delegate?.updateText(newText: textField.text ?? "", textFieldTag: textField.tag)
    }
    
    // MARK: -FUNCTIONS
    func wildcard(_ string: String, pattern: String) -> Bool {
        let pred = NSPredicate(format: "self LIKE %@", pattern)
        return !NSArray(object: string).filtered(using: pred).isEmpty
    }
}

protocol cellUserSettingsDelegate: AnyObject {
    func loginToggle(newState: Bool)
    func updateText(newText: String, textFieldTag: Int)
}
