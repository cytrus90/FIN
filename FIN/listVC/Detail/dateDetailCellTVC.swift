//
//  dateDetailCellTVC.swift
//  FIN
//
//  Created by Florian Riel on 30.11.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class dateDetailCellTVC: UITableViewCell {

    @IBOutlet weak var cellDateOutlineView: UIView!
    
    @IBOutlet weak var dateButton: UIButton!
    
    let shortDate = DateFormatter()
    var dayComponent = DateComponents()
    let calendar = Calendar.current
    
    let buttonBackgroundColor:UIColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.2)
    let buttonBorderColor:CGColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1).cgColor
    let buttonTextColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    let buttonSelectedBackgroundColor: UIColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    let buttonSelectedTextColor = UIColor.white
    
    weak var Delegate:dateDetailCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shortDate.dateStyle = .medium
        initUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initUI()
    }

    func initUI() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            cellDateOutlineView.backgroundColor = .white
            dateButton.layer.borderColor = UIColor.white.cgColor
            cellDateOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.backgroundColor = .clear
        } else {
            self.backgroundColor = .clear
            cellDateOutlineView.backgroundColor = .black
            dateButton.layer.borderColor = UIColor.black.cgColor
            cellDateOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        
        cellDateOutlineView.layer.borderWidth = 1
        cellDateOutlineView.layer.cornerRadius = 10
        
        dateButton.layer.borderWidth = 1
        dateButton.layer.cornerRadius = 10
//        dateButton.layer.borderColor = buttonBorderColor
        dateButton.setTitle(shortDate.string(from: dateSelected), for: .normal)
//        dateButton.backgroundColor = buttonSelectedBackgroundColor
//        dateButton.tintColor = buttonSelectedTextColor
//        dateButton.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        
        dateButton.tintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    }
    
    @IBAction func dateButton(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.dateButton.transform = self.transform.scaledBy(x: 0.9, y: 0.9)
            }, completion: { _ in
              // Step 2
              UIView.animate(withDuration: 0.1, animations: {
                self.dateButton.transform = CGAffineTransform.identity
                self.Delegate?.dateButtonPressed()
              })
            })
    }
}

protocol dateDetailCellDelegate: AnyObject {
    func dateButtonPressed()
}
