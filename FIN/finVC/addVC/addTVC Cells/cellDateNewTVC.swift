//
//  cellDateNewTVC.swift
//  FIN
//
//  Created by Florian Riel on 01.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

var dateSelected = Date()

class cellDateNewTVC: UITableViewCell {
    
    @IBOutlet weak var cellDateOutlineView: UIView!
    
    @IBOutlet weak var plusMinusOutlineView: UIView!
    @IBOutlet weak var plusMinusCenterView: UIView!
    
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var weekendsStackView: UIStackView!
    @IBOutlet weak var weekendsLabel: UILabel!
    @IBOutlet weak var weekendsSwitch: UISwitch!
    
    let buttonBackgroundColor:UIColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.2)
    let buttonBorderColor:CGColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1).cgColor
    let buttonTextColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    let buttonSelectedBackgroundColor: UIColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    let buttonSelectedTextColor = UIColor.white
    
    var dayComponent = DateComponents()
    let calendar = Calendar.current
    
    weak var delegate: cellDateNewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
            cellDateOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.backgroundColor = .clear
        } else {
            self.backgroundColor = .clear
            cellDateOutlineView.backgroundColor = .black
            cellDateOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        
        datePicker.semanticContentAttribute = .forceRightToLeft
        datePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
        
        cellDateOutlineView.layer.borderWidth = 1
        cellDateOutlineView.layer.cornerRadius = 10
                
        plusMinusOutlineView.layer.borderWidth = 1
        plusMinusOutlineView.layer.cornerRadius = 10
        plusMinusOutlineView.layer.borderColor = buttonBorderColor
        plusMinusOutlineView.backgroundColor = buttonBackgroundColor
        plusMinusCenterView.backgroundColor = buttonBackgroundColor
        
        plusButton.tintColor = buttonTextColor
        minusButton.tintColor = buttonTextColor
        
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)], for: .normal)

//        segmentControl.setTitle(NSLocalizedString("bottomSegmentRepeatDaily", comment: "Segment Repeat Daily Text"), forSegmentAt: 0)
        segmentControl.setTitle(NSLocalizedString("bottomSegmentRepeatWeekly", comment: "Segment Repeat Weekly Text"), forSegmentAt: 0)
        segmentControl.setTitle(NSLocalizedString("bottomSegmentRepeatMonthly", comment: "Segment Repeat Monthly Text"), forSegmentAt: 1)
        segmentControl.setTitle(NSLocalizedString("bottomSegmentRepeatYearly", comment: "Segment Repeat Yearly Text"), forSegmentAt: 2)
        
        weekendsLabel.text = NSLocalizedString("skipWeekwends", comment: "Skip Weekends")
    }

    @IBAction func minusButtonPressed(_ sender: Any) {
        dayComponent.day = -1
        dateSelected = calendar.date(byAdding: dayComponent, to: dateSelected) ?? Date()
        datePicker.setDate(dateSelected, animated: true)
        self.delegate?.dateChanged(dateSelected: datePicker.date)
    }
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        dayComponent.day = 1
        dateSelected = calendar.date(byAdding: dayComponent, to: dateSelected) ?? Date()
        datePicker.setDate(dateSelected, animated: true)
        self.delegate?.dateChanged(dateSelected: datePicker.date)
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        self.delegate?.dateChanged(dateSelected: datePicker.date)
        dateSelected = datePicker.date
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        self.delegate?.repeatSegmentChanged(selected: segmentControl.selectedSegmentIndex)
    }
    
    @IBAction func skipWeekendsSwitchChanged(_ sender: Any) {
        self.delegate?.skipWeekendChanges(switchOn: weekendsSwitch.isOn)
    }
}

protocol cellDateNewDelegate: AnyObject {
    func dateChanged(dateSelected: Date)
    func repeatSegmentChanged(selected: Int)
    func skipWeekendChanges(switchOn: Bool)
}
