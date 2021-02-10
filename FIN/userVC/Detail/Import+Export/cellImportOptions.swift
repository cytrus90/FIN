//
//  cellImportOptions.swift
//  FIN
//
//  Created by Florian Riel on 22.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class cellImportOptions: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    
    weak var delegete: cellImportOptionsDelegate?
    
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
            self.backgroundColor = backgroundColor
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .secondarySystemBackground
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)], for: .normal)
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        self.delegete?.segmentControlChanged(selected: segment.selectedSegmentIndex, tag: self.tag)
    }
}

protocol cellImportOptionsDelegate: AnyObject {
    func segmentControlChanged(selected: Int, tag:Int)
}
