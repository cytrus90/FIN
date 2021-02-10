//
//  datePickerView.swift
//  FIN
//
//  Created by Florian Riel on 23.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class datePickerView: UIView {
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var smallTopView: UIView!
    
    weak var delegate: datePickerViewDelegate?
    
    func initView() {
        NotificationCenter.default.addObserver(self, selector: #selector(dateChanged), name: Notification.Name("dateChanged"), object: nil)
        
        lineView.backgroundColor = backgroundGeneralColor
        
        smallTopView.backgroundColor = .secondarySystemBackground
        smallTopView.layer.borderWidth = 1
        smallTopView.layer.cornerRadius = 2
        smallTopView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        
        initTraitChange()
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.setDate(dateSelected, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initTraitChange()
    }
    
    func initTraitChange() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .white
            self.layer.borderColor = UIColor.white.cgColor
        } else {
            self.backgroundColor = .black
            self.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        self.delegate?.updateCellAfterRemove(selectedDate: sender.date)
        dateSelected = sender.date
    }
    
    @objc func dateChanged() {
        if datePicker != nil {
            datePicker.setDate(dateSelected, animated: true)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

protocol datePickerViewDelegate: AnyObject {
    func updateCellAfterRemove(selectedDate: Date)
}
