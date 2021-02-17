//
//  cellSubtitleStack.swift
//  FIN
//
//  Created by Florian Riel on 16.02.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit

class cellSubtitleStack: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    
    var selectedLabel = 0
    let selectedView = UIView()
    
//    var height:NSLayoutConstraint?
//    var width:NSLayoutConstraint?
    var centerX:NSLayoutConstraint?
    var centerY:NSLayoutConstraint?
    var trailingConstraint:NSLayoutConstraint?
    var leadingConstraint:NSLayoutConstraint?
    
    @IBOutlet weak var stackViewTrailingConstraint: NSLayoutConstraint!
    
    let nc = NotificationCenter.default
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
//        initSelectedCell(selectedIndex: selectedLabel)
    }

    func setLargeStackTrailingConstraint() {
        stackViewTrailingConstraint.constant = 15
    }
    
    func initCells() {
        let leftSwipe = UISwipeGestureRecognizer()
        leftSwipe.direction = .left
        leftSwipe.addTarget(self, action: #selector(handleLeftSwipe))
        leftSwipe.delegate = self
        stackView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer()
        rightSwipe.direction = .right
        rightSwipe.addTarget(self, action: #selector(handleRightSwipe))
        rightSwipe.delegate = self
        stackView.addGestureRecognizer(rightSwipe)
        
        stackView.isUserInteractionEnabled = true
        
        for view in stackView.arrangedSubviews {
            let tab = UITapGestureRecognizer()
            tab.addTarget(self, action: #selector(handleTab(sender:)))
            tab.delegate = self
            view.addGestureRecognizer(tab)
            view.isUserInteractionEnabled = true
        }
    }
    
    func initSelectedCell(selectedIndex: Int = 0) {
        var maxWidth:CGFloat = 0//(stackView.frame.width / CGFloat(stackView.arrangedSubviews.count)) - CGFloat(10*(stackView.arrangedSubviews.count-1))
        for view in stackView.arrangedSubviews {
            if view.frame.width > maxWidth {
                maxWidth = view.frame.width
            }
        }
        if let view = stackView.arrangedSubviews[selectedIndex] as? UILabel {
            selectedView.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(selectedView)
                
            selectedView.heightAnchor.constraint(equalToConstant: max((view.frame.height+10),30)).isActive = true
//            selectedView.widthAnchor.constraint(equalToConstant: maxWidth).isActive = true
                
//            centerX?.isActive = false
//            centerX = selectedView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0)
//            centerX?.isActive = true
            
            centerY?.isActive = false
            centerY = selectedView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
            centerY?.isActive = true
            
            trailingConstraint?.isActive = false
            trailingConstraint = selectedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
            trailingConstraint?.isActive = true
            
            leadingConstraint?.isActive = false
            leadingConstraint = selectedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
            leadingConstraint?.isActive = true
            
            selectedView.backgroundColor = .systemBackground
            selectedView.layer.borderWidth = 1
            selectedView.layer.cornerRadius = 10
            selectedView.layer.borderColor = UIColor.systemBackground.cgColor
            
            selectedLabel = selectedIndex
            
            stackView.arrangedSubviews[selectedLabel].alpha = 1.0
            
            self.contentView.sendSubviewToBack(selectedView)
        }
    }
    
    @objc func handleTab(sender:UITapGestureRecognizer) {
        let selectedTag = sender.view?.tag
        if selectedTag != selectedLabel {
            if let label = stackView.arrangedSubviews[selectedTag ?? 0] as? UILabel {
                nc.post(name: Notification.Name("finVCCategoyTimeRangeChanged"), object: nil, userInfo: ["selectedLabel": selectedTag ?? 0, "selectedCell": self.tag])
                
//                centerX?.isActive = false
//                centerX = selectedView.centerXAnchor.constraint(equalTo: label.centerXAnchor, constant: 0)
//                centerX?.isActive = true
                
                centerY?.isActive = false
                centerY = selectedView.centerYAnchor.constraint(equalTo: label.centerYAnchor, constant: 0)
                centerY?.isActive = true
                
                trailingConstraint?.isActive = false
                trailingConstraint = selectedView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 0)
                trailingConstraint?.isActive = true
                
                leadingConstraint?.isActive = false
                leadingConstraint = selectedView.leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: 0)
                leadingConstraint?.isActive = true
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.stackView.arrangedSubviews[self.selectedLabel].alpha = 0.3
                    self.stackView.arrangedSubviews[selectedTag ?? 0].alpha = 1.0
                    self.layoutIfNeeded()
                }, completion: {_ in 
                    self.selectedLabel = selectedTag ?? 0
                })
            }
        }
    }
    
    @objc func handleLeftSwipe() {
        if selectedLabel > 0 {
            let selectedNew = selectedLabel - 1
            if let label = stackView.arrangedSubviews[selectedNew] as? UILabel {
                nc.post(name: Notification.Name("finVCCategoyTimeRangeChanged"), object: nil, userInfo: ["selectedLabel": selectedNew, "selectedCell": self.tag])
                
//                centerX?.isActive = false
//                centerX = selectedView.centerXAnchor.constraint(equalTo: label.centerXAnchor, constant: 0)
//                centerX?.isActive = true
//
                centerY?.isActive = false
                centerY = selectedView.centerYAnchor.constraint(equalTo: label.centerYAnchor, constant: 0)
                centerY?.isActive = true
                
                trailingConstraint?.isActive = false
                trailingConstraint = selectedView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 0)
                trailingConstraint?.isActive = true
                
                leadingConstraint?.isActive = false
                leadingConstraint = selectedView.leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: 0)
                leadingConstraint?.isActive = true
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.stackView.arrangedSubviews[self.selectedLabel].alpha = 0.3
                    self.stackView.arrangedSubviews[selectedNew ].alpha = 1.0
                    self.layoutIfNeeded()
                }, completion: {_ in
                    self.selectedLabel = selectedNew
                })
            }
        }
    }
    
    @objc func handleRightSwipe() {
        if selectedLabel < 2 {
            let selectedNew = selectedLabel + 1
            if let label = stackView.arrangedSubviews[selectedNew] as? UILabel {
                nc.post(name: Notification.Name("finVCCategoyTimeRangeChanged"), object: nil, userInfo: ["selectedLabel": selectedNew, "selectedCell": self.tag])
                
//                centerX?.isActive = false
//                centerX = selectedView.centerXAnchor.constraint(equalTo: label.centerXAnchor, constant: 0)
//                centerX?.isActive = true
                
                centerY?.isActive = false
                centerY = selectedView.centerYAnchor.constraint(equalTo: label.centerYAnchor, constant: 0)
                centerY?.isActive = true
                
                trailingConstraint?.isActive = false
                trailingConstraint = selectedView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 0)
                trailingConstraint?.isActive = true
                
                leadingConstraint?.isActive = false
                leadingConstraint = selectedView.leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: 0)
                leadingConstraint?.isActive = true
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.stackView.arrangedSubviews[self.selectedLabel].alpha = 0.3
                    self.stackView.arrangedSubviews[selectedNew ].alpha = 1.0
                    self.layoutIfNeeded()
                }, completion: {_ in
                    self.selectedLabel = selectedNew
                })
            }
        }
    }
}
