//
//  cellAmountDetailTVC.swift
//  FIN
//
//  Created by Florian Riel on 30.11.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import TagListView

class cellAmountDetailTVC: UITableViewCell {
    
    @IBOutlet weak var cellAmountOutlineView: UIView!
    
    @IBOutlet weak var amountCell: UILabel!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var descriptionIcon: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var tagListView: TagListView!
    
    var tagListHeight: NSLayoutConstraint?
    
    var currencyButtonHeight: NSLayoutConstraint?
    var currencyButtonWidth: NSLayoutConstraint?
    
    let buttonBackgroundColor:UIColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.2)
    let buttonBorderColor:UIColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    
    weak var Delegate:cellAmountDetailTVCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initCell()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initTags()
        initView()
    }
    
    func initCell() {
        initCurrencyButton()
        initTags()
        
        cellAmountOutlineView.layer.borderWidth = 1
        cellAmountOutlineView.layer.cornerRadius = 10
        
        initView()
    }
    
    func initView(){
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            cellAmountOutlineView.backgroundColor = .white
            tagListView.backgroundColor = .white
            cellAmountOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .clear
            cellAmountOutlineView.backgroundColor = .black
            tagListView.backgroundColor = .black
            cellAmountOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }
    
    func initCurrencyButton() {
        currencyButton.layer.borderWidth = 1
        currencyButton.layer.cornerRadius = 10
        currencyButton.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        
        currencyButtonWidth = currencyButton.widthAnchor.constraint(equalTo: amountCell.heightAnchor, multiplier: 1.0)
        currencyButtonWidth?.isActive = true
        
        currencyButtonHeight = currencyButton.widthAnchor.constraint(equalTo: amountCell.heightAnchor, multiplier: 1.0)
        currencyButtonHeight?.isActive = true
        
        let currencyCode = Locale.current.currencyCode ?? "EUR"
        currencyButton.setTitle(getSymbol(forCurrencyCode: currencyCode), for: .normal)
        currencyButton.tintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    }
    
    func initTags() {
        tagListView.removeAllTags()
        
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        tagListView.textFont = .systemFont(ofSize: label.font.pointSize)
        tagListView.enableRemoveButton = false
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            tagListView.backgroundColor = .white
        } else {
            tagListView.backgroundColor = .black
        }
                
        if tagsDetailView.count > 0 {
            if tagListView.isHidden {
                tagListView.isHidden = false
            }
            for (_,value) in tagsDetailView.enumerated() {
                let newTag = tagListView.addTag(value.value["Title"] as? String ?? "Tag")
                newTag.borderColor = UIColor.randomColor(color: value.value["Color"] as? Int ?? 0)
                newTag.tagBackgroundColor = UIColor.randomColor(color: value.value["Color"] as? Int ?? 0).withAlphaComponent(0.5)
                if userInterfaceStyle == .light {
                    newTag.textColor = UIColor.randomColor(color: value.value["Color"] as? Int ?? 0).darker() ?? UIColor.black
                } else {
                    newTag.textColor = UIColor.randomColor(color: value.value["Color"] as? Int ?? 0).lighter() ?? UIColor.white
                }
                newTag.tag = value.key
            }
            tagListHeight?.isActive = false
            tagListHeight = tagListView.heightAnchor.constraint(equalToConstant: (tagListView.intrinsicContentSize.height))
            tagListHeight?.isActive = true
        } else {
            tagListView.isHidden = true
        }
    }
    
    @IBAction func currencyButton(_ sender: Any) {
        self.Delegate?.currencyButtonPressed()
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

protocol cellAmountDetailTVCDelegate: AnyObject {
    func currencyButtonPressed()
}
