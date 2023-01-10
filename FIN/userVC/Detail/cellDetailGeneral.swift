//
//  userDetailTableVCell.swift
//  FIN
//
//  Created by Florian Riel on 12.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import TagListView

class cellDetailGeneral: UITableViewCell {

    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var cellOutlineView: UIView!
    @IBOutlet weak var cellImageLabel: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellMainStackView: UIStackView!
    @IBOutlet weak var cellLabelArrow: UIImageView!
    
    @IBOutlet weak var tagListView: TagListView!
    var tagListHeight: NSLayoutConstraint?
    
    var tagsCellView = [Int:[String:Any]]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellOutlineView.layer.borderWidth = 1
        cellOutlineView.layer.cornerRadius = 10
        cellLabelArrow.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        cellMainStackView.heightAnchor.constraint(equalToConstant: (cellLabel.font.pointSize)+3).isActive = true
        
        initTags()
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
    }

    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            cellOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .clear
            cellOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
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
