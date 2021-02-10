//
//  cellImportStartButton.swift
//  FIN
//
//  Created by Florian Riel on 20.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellImportStartButton: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var startButton: UIButton!
    
    let buttonBorderColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1).cgColor
    let buttonSelectedBackgroundColor: UIColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    let buttonSelectedTextColor = UIColor.white
    
    weak var delegate: cellImportStartButtonDelegate?
    
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
        
        startButton.layer.borderWidth = 1
        startButton.layer.cornerRadius = 10
        
        startButton.layer.borderColor = UIColor.clear.cgColor
        startButton.backgroundColor = buttonSelectedBackgroundColor
        startButton.tintColor = buttonSelectedTextColor
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .clear
            outlineView.layer.borderColor = UIColor.clear.cgColor
        } else {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .clear
            outlineView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.startButton.transform = self.transform.scaledBy(x: 0.9, y: 0.9)
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                self.startButton.transform = CGAffineTransform.identity
              }, completion: { _ in
                self.delegate?.startButtonPressed()
              })
            })
    }
}

protocol cellImportStartButtonDelegate: AnyObject {
    func startButtonPressed()
}
