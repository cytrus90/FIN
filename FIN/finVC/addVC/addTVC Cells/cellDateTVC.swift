//
//  cellDateTVC.swift
//  FIN
//
//  Created by Florian Riel on 21.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellDateTVC: UITableViewCell {
    
    @IBOutlet weak var cellDateOutlineView: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var plusMinusOutlineView: UIView!
    @IBOutlet weak var plusMinusCenterView: UIView!
    
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var dateButton: UIButton!
    
    let shortDate = DateFormatter()
    var dayComponent = DateComponents()
    let calendar = Calendar.current
    
    weak var delegate: cellDateDelegate?
    
    let buttonBackgroundColor:UIColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.2)
    let buttonBorderColor:CGColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1).cgColor
    let buttonTextColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    let buttonSelectedBackgroundColor: UIColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    let buttonSelectedTextColor = UIColor.white
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shortDate.dateStyle = .medium
        initUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initUI()
    }
    
    // MARK: -ACTION
    @IBAction func dateButtonPressed(_ sender: Any) {
        self.delegate?.showPopOverDatePicker(button: (sender as! UIButton), cell: self)
    }
    
    @IBAction func minusButtonPressed(_ sender: Any) {
        dayComponent.day = -1
        dateSelected = calendar.date(byAdding: dayComponent, to: dateSelected) ?? Date()
        dateButton.setTitle(shortDate.string(from: dateSelected), for: .normal)
        self.delegate?.dateChangedButton(dateSelected: dateSelected)
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "dateChanged")))
    }

    @IBAction func plusButtonPressed(_ sender: Any) {
        dayComponent.day = 1
        dateSelected = calendar.date(byAdding: dayComponent, to: dateSelected) ?? Date()
        dateButton.setTitle(shortDate.string(from: dateSelected), for: .normal)
        self.delegate?.dateChangedButton(dateSelected: dateSelected)
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "dateChanged")))
    }
    
    // MARK: -FUNCTIONS
    func initUI() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            cellDateOutlineView.backgroundColor = .white
            cellDateOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.backgroundColor = .clear
        } else {
            self.backgroundColor = .clear
            cellDateOutlineView.backgroundColor = .black
            cellDateOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        
        cellDateOutlineView.layer.borderWidth = 1
        cellDateOutlineView.layer.cornerRadius = 10
        
        dateButton.layer.borderWidth = 1
        dateButton.layer.cornerRadius = 10
        dateButton.layer.borderColor = buttonBorderColor
        dateButton.setTitle(shortDate.string(from: dateSelected), for: .normal)
        setTodayButton()
        
        plusMinusOutlineView.layer.borderWidth = 1
        plusMinusOutlineView.layer.cornerRadius = 10
        plusMinusOutlineView.layer.borderColor = buttonBorderColor
        plusMinusOutlineView.backgroundColor = buttonBackgroundColor
        plusMinusCenterView.backgroundColor = buttonBackgroundColor
        
        plusButton.tintColor = buttonTextColor
        minusButton.tintColor = buttonTextColor
    }
    
    func resetButtons() {
        dateButton.tintColor = buttonTextColor
        dateButton.backgroundColor = buttonBackgroundColor
    }
    
    func setTodayButton() {
        dateButton.backgroundColor = buttonSelectedBackgroundColor
        dateButton.tintColor = buttonSelectedTextColor
    }
    
    func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("superview is not a UITableView - getIndexPath")
            return nil
        }
        let indexPath = superView.indexPath(for: self)
        return indexPath
    }
}

protocol cellDateDelegate: AnyObject {
    func showPopOverDatePicker(button: UIButton, cell: cellDateTVC)
    func dateChangedButton(dateSelected: Date)
}
