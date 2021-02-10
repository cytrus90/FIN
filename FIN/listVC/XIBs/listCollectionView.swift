//
//  listCollectionView.swift
//  FIN
//
//  Created by Florian Riel on 12.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import ScalingCarousel

class listCollectionView: UIView, UICollectionViewDelegate {

    @IBOutlet weak var carousel: ScalingCarouselView!
    @IBOutlet weak var headerLabel: UILabel!
    
    func initView() {
        let nib = UINib(nibName: "listCollectionViewCell", bundle: nil)
        carousel.register(nib, forCellWithReuseIdentifier: "listCollectionViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(collectionViewScrollTo(notification:)), name: Notification.Name("collectionViewScrollTo"), object: nil)
    }
    
    @IBOutlet weak var scrollView: UIScrollView?
    private var cachedMinimumSize: CGSize?
        
    var maxHeight:CGFloat = 150.0
    var maxLabelPointSize:CGFloat = 35.0
    var minLabelPointSize:CGFloat = 25.0
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.backgroundColor = .clear
//        let userInterfaceStyle = traitCollection.userInterfaceStyle
//        if userInterfaceStyle == .light {
//            self.backgroundColor = backgroundGeneralColor
//        } else {
//            self.backgroundColor = .secondarySystemBackground
//        }
    }
    
    private var minimumHeight: CGFloat {
        get {
            guard let scrollView = scrollView else { return 0 }
            if let cachedSize = cachedMinimumSize {
                if cachedSize.width == scrollView.frame.width {
                    return cachedSize.height
                }
            }
            // Ask Auto Layout what the minimum height of the header should be.
            let minimumSize = systemLayoutSizeFitting(CGSize(width: scrollView.frame.width, height: 10),
                                                      withHorizontalFittingPriority: .required,
                                                      verticalFittingPriority: .defaultLow)
            cachedMinimumSize = minimumSize
            return minimumSize.height
        }
    }
    
    func updatePosition() {
        guard let scrollView = scrollView else { return }
        // Calculate the minimum size the header's constraints will fit
        let minimumSize = minimumHeight
        // Calculate the baseline header height and vertical position
        let referenceOffset = scrollView.safeAreaInsets.top
        let referenceHeight = scrollView.contentInset.top - referenceOffset
        
        // Calculate the new frame size and position
        let offset = referenceHeight + scrollView.contentOffset.y
        var targetHeight = referenceHeight - offset - referenceOffset
        if targetHeight > maxHeight {
            targetHeight = maxHeight
        }
        var targetOffset = referenceOffset
        if targetHeight < minimumSize {
            //targetOffset = targetHeight
            targetOffset += targetHeight - minimumSize
        }
        
        // Update the header's height and vertical position.
        var headerFrame = frame;
        headerFrame.size.height = max(minimumSize, targetHeight)
        headerFrame.origin.y = targetOffset
        
        // Calculate dynamic text size
        let fontSize = min(maxLabelPointSize, (((headerFrame.size.height-minimumSize)/maxHeight)*(maxLabelPointSize-minLabelPointSize))+minLabelPointSize)
        headerLabel.font = headerLabel.font.withSize(max(fontSize, minLabelPointSize))

        frame = headerFrame
    }
    
    func viewTransition() {
        carousel.deviceRotated()
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        // carousel.delegate = dataSourceDelegate
        carousel.delegate = self
        carousel.dataSource = dataSourceDelegate
        carousel.tag = row
        carousel.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        carousel.didScroll()
        guard let currentCenterIndex = carousel.currentCenterCellIndex?.row else { return }
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("collectionViewChanged"), object: nil, userInfo: ["currentCenterIndex": currentCenterIndex])
    }
    
    @objc func collectionViewScrollTo(notification: Notification) {
        if let userInfo = notification.userInfo, let scrollToIndex = userInfo["toIndex"] as? Int {
            carousel.scrollToItem(at: IndexPath(row: scrollToIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
}
