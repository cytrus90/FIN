//
//  cellDetailGeneral.swift
//  FIN
//
//  Created by Florian Riel on 30.11.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import TagListView

class cellDetailGeneralTVC: UITableViewCell {

    @IBOutlet weak var cellOutlineView: UIView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionSubtitleLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var circleLabel: UILabel!
    @IBOutlet weak var circleImage: UIImageView!
    
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var stackview: UIStackView!
    
    var tagListHeight: NSLayoutConstraint?
    
    var tagsCellView = [Int:[String:Any]]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellOutlineView.layer.borderWidth = 1
        cellOutlineView.layer.cornerRadius = 10
                
        initTags()
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initTags()
        initView()
    }

    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            cellOutlineView.backgroundColor = .white
            cellOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.backgroundColor = .clear
        } else {
            self.backgroundColor = .clear
            cellOutlineView.backgroundColor = .black
            cellOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
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
            // for (_,value) in self.tagsCellView.enumerated() {
            for key in Array(self.tagsCellView.keys.sorted()) {
                let newTag = tagListView.addTag(self.tagsCellView[key]?["Title"] as? String ?? "Tag")
                newTag.borderColor = UIColor.randomColor(color: self.tagsCellView[key]?["Color"] as? Int ?? 0)
                newTag.tagBackgroundColor = UIColor.randomColor(color: self.tagsCellView[key]?["Color"] as? Int ?? 0).withAlphaComponent(0.5)
                if userInterfaceStyle == .light {
                    newTag.textColor = UIColor.randomColor(color: self.tagsCellView[key]?["Color"] as? Int ?? 0).darker() ?? UIColor.black
                } else {
                    newTag.textColor = UIColor.randomColor(color: self.tagsCellView[key]?["Color"] as? Int ?? 0).lighter() ?? UIColor.white
                }
                newTag.tag = key
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
