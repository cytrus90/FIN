//
//  cellAboutText.swift
//  FIN
//
//  Created by Florian Riel on 11.01.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit

class cellAboutText: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var aboutText: UILabel!
    @IBOutlet weak var feedbackButton: UIButton!
    
    weak var delegate: cellAboutTextDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
    }

    func initView() {
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            outlineView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .clear
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
            outlineView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        
        aboutText.text = NSLocalizedString("aboutTextText", comment: "About Text")
        feedbackButton.setTitle(NSLocalizedString("feedbackTitle", comment: "Feedback"), for: .normal)
    }
    
    @IBAction func feedbackButtonPressed(_ sender: Any) {
        self.delegate?.sendFeedbackPressed()
    }
}

protocol cellAboutTextDelegate: AnyObject {
    func sendFeedbackPressed()
}

