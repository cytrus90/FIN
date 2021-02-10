//
//  cellSplitTransactionSplitType.swift
//  FIN
//
//  Created by Florian Riel on 17.10.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellSplitTransactionSplitType: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    weak var delegate: cellSplitTransactionSplitTypeDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectIndexSplitTransaction(notification:)), name: Notification.Name("selectIndexSplitTransaction"), object: nil)
        
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
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.backgroundColor = backgroundColor
        } else {
            self.backgroundColor = .secondarySystemBackground
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)], for: .normal)
            
        segmentControl.setTitle(NSLocalizedString("segmentSplitEqualy", comment: "Segment Equaly Text"), forSegmentAt: 0)
        segmentControl.setTitle(NSLocalizedString("segmentSplitPercent", comment: "Segment Percent Text"), forSegmentAt: 1)
        segmentControl.setTitle(currencyCodeSet, forSegmentAt: 2)
        
        if selectedSplitType != nil {
            segmentControl.selectedSegmentIndex = selectedSplitType ?? 0
        } else {
            segmentControl.selectedSegmentIndex = 0
        }
    }
    
    @objc func selectIndexSplitTransaction(notification: Notification) {
        if let userInfo = notification.userInfo, let index = userInfo["index"] as? Int {
            self.segmentControl.selectedSegmentIndex = index
        }
    }
    
    // MARK: -HELPER FUNCTIONS
    func getSymbol(forCurrencyCode code: String) -> String? {
        let locale = NSLocale(localeIdentifier: code)
        if locale.displayName(forKey: .currencySymbol, value: code) == code {
            let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: code)
        }
        return locale.displayName(forKey: .currencySymbol, value: code)
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        self.delegate?.segmentChanged(selected: segmentControl.selectedSegmentIndex)
        UIImpactFeedbackGenerator().impactOccurred()
    }
}

protocol cellSplitTransactionSplitTypeDelegate: AnyObject {
    func segmentChanged(selected: Int)
}
