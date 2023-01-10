//
//  cellTopOverview.swift
//  FIN
//
//  Created by Florian Riel on 05.01.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit
import Charts
import TagListView

class cellTopOverview: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    
    @IBOutlet weak var pieChart: PieChartView!
    
    @IBOutlet weak var secondSubLabel: UILabel!
    
    @IBOutlet weak var latestTransactionStackView: UIStackView!
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var circleLabel: UILabel!
    @IBOutlet weak var circleImage: UIImageView!
    
    @IBOutlet weak var transactionDescriptionLabel: UILabel!
    @IBOutlet weak var transactionSubLabel: UILabel!
    @IBOutlet weak var transactionIcon: UIImageView!
    
    @IBOutlet weak var transactionAmount: UILabel!
    
    @IBOutlet weak var transactionArrowIcon: UIImageView!
    
    @IBOutlet weak var tagListView: TagListView!
    var tagListHeight: NSLayoutConstraint?
    
    var tagsCellView = [Int:[String:Any]]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initTags()
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initTags()
        initView()
    }

    func initView() {
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
//            self.backgroundColor = backgroundColor
        } else {
//            self.backgroundColor = .secondarySystemBackground
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        
        circleView.layer.cornerRadius = 10//circleView.bounds.size.width/2
        circleView.clipsToBounds = true
        
        circleView.layer.borderWidth = 1
    }
    
    func initTags() {
        tagListView.removeAllTags()
        
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        tagListView.textFont = .systemFont(ofSize: label.font.pointSize)
        tagListView.enableRemoveButton = false
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            tagListView.backgroundColor = .clear
        } else {
            tagListView.backgroundColor = .clear
        }
                
        if self.tagsCellView.count > 0 {
            if tagListView.isHidden {
                tagListView.isHidden = false
            }
            for (_,value) in self.tagsCellView.enumerated() {
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
    
    func removeTags() {
        tagListView.removeAllTags()
        tagListView.isHidden = true
    }
}
