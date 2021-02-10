//
//  cellSaveDeposit.swift
//  FIN
//
//  Created by Florian Riel on 06.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellSaveDeposit: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var liquidLabel: UILabel!
    @IBOutlet weak var liquidInfoButton: UIButton!
    @IBOutlet weak var liquidSwitch: UISwitch!
    
    weak var delegate: cellSaveDepositDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        segmentControl.setTitle(NSLocalizedString("segmentDepositText", comment: "Segment Deposit Text"), forSegmentAt: 0)
        segmentControl.setTitle(NSLocalizedString("segmentWithdrawText", comment: "Segment Withdraw Text"), forSegmentAt: 1)
        
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)], for: .normal)
        
        liquidLabel.text = NSLocalizedString("liquidLabelText", comment: "Liquid Label Text")
        
        initUI()
    }

    func initUI() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .clear
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = backgroundColor
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .secondarySystemBackground
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }
    
    @IBAction func saveSegmentChanged(_ sender: Any) {
        UIImpactFeedbackGenerator().impactOccurred()
        self.delegate?.saveChanged(selected: segmentControl.selectedSegmentIndex)
    }
    
    @IBAction func liquidInfoButtonPressed(_ sender: Any) {
        self.delegate?.liquidInfoButtonPressed()
    }
    
    @IBAction func liquidSwitchChanged(_ sender: Any) {
        self.delegate?.liquidSwitchChanged(newState: liquidSwitch.isOn)
    }
}

protocol cellSaveDepositDelegate: AnyObject {
    func saveChanged(selected: Int)
    func liquidInfoButtonPressed()
    func liquidSwitchChanged(newState:Bool)
}
