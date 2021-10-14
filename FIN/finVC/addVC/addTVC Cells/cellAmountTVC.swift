//
//  cellTagAddTVC.swift
//  FIN
//
//  Created by Florian Riel on 20.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import TagListView
import SmoothPicker

class cellAmountTVC: UITableViewCell, TagListViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var tagAddListView: TagListView!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var cellAmountOutlineView: UIView!
    
    @IBOutlet weak var currencyButton: UIButton!
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var splitBillButton: UIButton!
    
    var tagListHeight: NSLayoutConstraint?
    var tagAddListHeight: NSLayoutConstraint?
    
    var currencyButtonHeight: NSLayoutConstraint?
    var currencyButtonWidth: NSLayoutConstraint?
    
    weak var delegate: cellTagAddDelegate?
    
    let buttonBackgroundColor:UIColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.2)
    let buttonBorderColor:UIColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellAmountOutlineView.layer.borderWidth = 1
        cellAmountOutlineView.layer.cornerRadius = 10
        
        initCurrencyButton()
        initSplitButton()
        
        initView()
        
        if amountTextField != nil {
            amountTextField.delegate = self
        }
        if descriptionTextField != nil {
            descriptionTextField.delegate = self
        }
        
        if amountTextField != nil {
            amountTextField.delegate = self
            amountTextField.addTarget(self, action: #selector(self.amountTextFieldDidChange(_:)), for: .editingChanged)
            if (amountTextField.text?.count ?? 0) <= 0 {
                splitBillButton.isHidden = true
            }
        }
        
        amountTextField.keyboardType = .decimalPad
        
        amountTextField.placeholder = NSLocalizedString("MissingAmountTitle", comment: "Missing Amount Title")
        descriptionTextField.placeholder = NSLocalizedString("MissingDescriptionTitle", comment: "Missing Description Title")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initView()
    }
    
    // MARK: -ACTIONS
    @IBAction func currencyButtonPressed(_ sender: Any) {
        self.delegate?.currencyButtonPressed()
    }
    
    // MARK: -INIT VIEW
    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            cellAmountOutlineView.backgroundColor = .white
            tagListView.backgroundColor = .white
            tagAddListView.backgroundColor = .white
            cellAmountOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .clear
            cellAmountOutlineView.backgroundColor = .black
            tagListView.backgroundColor = .black
            tagAddListView.backgroundColor = .black
            cellAmountOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }
    
    func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("superview is not a UITableView - getIndexPath")
            return nil
        }
        let indexPath = superView.indexPath(for: self)
        return indexPath
    }

    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagView.isSelected = !tagView.isSelected
        if sender == tagAddListView {
            self.delegate?.addTagPrompt(tagListView: tagListView, tagAddListView: tagAddListView, indexPath: getIndexPath() ?? IndexPath(row: 0, section: 0))
        }
        self.layoutIfNeeded()
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tags.removeValue(forKey: tagView.tag)
        sender.removeTagView(tagView)
        if tags.count <= 0 {
            tagListView.isHidden = true
        } else {
            tagListHeight?.isActive = false
            tagListHeight = tagListView.heightAnchor.constraint(equalToConstant: (tagListView.intrinsicContentSize.height))
            tagListHeight?.isActive = true
        }
        self.delegate?.updateCellAfterRemove(indexPath: getIndexPath() ?? IndexPath(row: 0, section: 0))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.delegate?.textFieldEdited(text: textField.text ?? "", tag: textField.tag)
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        self.delegate?.textFieldEdited(text: textField.text ?? "", tag: textField.tag)
    }
    
    // MARK: - FUNCTIONS
    func initCurrencyButton() {
        currencyButton.layer.borderWidth = 1
        currencyButton.layer.cornerRadius = 10
        currencyButton.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        
        currencyButtonWidth = currencyButton.widthAnchor.constraint(equalTo: amountTextField.heightAnchor, multiplier: 1.0)
        currencyButtonWidth?.isActive = true
        
        currencyButtonHeight = currencyButton.widthAnchor.constraint(equalTo: amountTextField.heightAnchor, multiplier: 1.0)
        currencyButtonHeight?.isActive = true
        
        let currencyCode = Locale.current.currencyCode ?? "EUR"
        currencyButton.setTitle(getSymbol(forCurrencyCode: currencyCode), for: .normal)
        currencyButton.tintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    }
    
    func initSplitButton() {
        splitBillButton.layer.borderWidth = 1
        splitBillButton.layer.cornerRadius = 7
        splitBillButton.layer.borderColor = buttonBorderColor.cgColor
        splitBillButton.backgroundColor = buttonBackgroundColor
        splitBillButton.tintColor = buttonBorderColor
        splitBillButton.setTitle(NSLocalizedString("splitButtonText", comment: "Split"), for: .normal)
    }
    // Test
    func initTags() {
        tagListView.delegate = self
        tagAddListView.delegate = self
        
        tagListView.removeAllTags()
        tagAddListView.removeAllTags()
        
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        tagListView.textFont = .systemFont(ofSize: label.font.pointSize)
        tagAddListView.textFont = .systemFont(ofSize: label.font.pointSize)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            tagListView.backgroundColor = .white
            tagAddListView.backgroundColor = .white
        } else {
            tagListView.backgroundColor = .black
            tagAddListView.backgroundColor = .black
        }
        
        tagAddListHeight?.isActive = false
        tagAddListHeight = tagAddListView.heightAnchor.constraint(equalToConstant: (label.font.pointSize+11))
        tagAddListHeight?.isActive = true
        
        let tagAdd: TagView = tagAddListView.addTag(NSLocalizedString("Add Tag", comment: "Add Tag Prompt Title"))
        tagAdd.borderColor = buttonBorderColor
        tagAdd.tagBackgroundColor = buttonBackgroundColor
        tagAdd.textColor = buttonBorderColor
        tagAdd.selectedBackgroundColor = buttonBorderColor
        tagAdd.selectedTextColor = .white
        tagAdd.enableRemoveButton = false
        
        if tags.count > 0 {
            if tagListView.isHidden {
                tagListView.isHidden = false
            }
            for tag in tags {
                let newTag = tagListView.addTag(tag.value["Title"] as? String ?? "Tag")
                newTag.borderColor = UIColor.randomColor(color: tag.value["Color"] as? Int ?? 0)
                newTag.tagBackgroundColor = UIColor.randomColor(color: tag.value["Color"] as? Int ?? 0).withAlphaComponent(0.7)
                newTag.textColor = UIColor.randomColor(color: tag.value["Color"] as? Int ?? 0)
                newTag.selectedTextColor = newTag.textColor
                newTag.tag = tag.key
            }
            tagListHeight?.isActive = false
            tagListHeight = tagListView.heightAnchor.constraint(equalToConstant: (tagListView.intrinsicContentSize.height))
            tagListHeight?.isActive = true
        } else {
            tagListView.isHidden = true
        }
    }
    
    @objc func amountTextFieldDidChange(_ textField: UITextField) {
        if (amountTextField.text?.count ?? 0) > 0 && !incomeOrSaveSelected {
            splitBillButton.isHidden = false
        } else {
            splitBillButton.isHidden = true
        }
    }
    
    @IBAction func splitButtonPressed(_ sender: Any) {
        if (amountTextField.text?.count ?? 0) > 0 {
            self.delegate?.splitButtonPressed(amountValue: amountTextField.text ?? "0.00")
        }
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

protocol cellTagAddDelegate: AnyObject {
    func addTagPrompt(tagListView: TagListView, tagAddListView: TagListView, indexPath: IndexPath)
    func updateCellAfterRemove(indexPath: IndexPath)
    func currencyButtonPressed()
    func textFieldEdited(text: String, tag: Int)
    func splitButtonPressed(amountValue:String)
}
