//
//  headerView.swift
//  FIN
//
//  Created by Florian Riel on 09.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class headerView: UIView {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet private(set) var headerLabel: UILabel!

    @IBOutlet weak var scrollView: UIScrollView?
    private var cachedMinimumSize: CGSize?
    
    var maxHeight:CGFloat = 100.0
    var maxLabelPointSize:CGFloat = 25.0
    var minLabelPointSize:CGFloat = 15.0
    
    private var minimumHeight: CGFloat {
        get {
            guard let scrollView = scrollView else { return 0 }
            if let cachedSize = cachedMinimumSize {
                if cachedSize.width == scrollView.frame.width {
                    return cachedSize.height
                }
            }
         
            // Ask Auto Layout what the minimum height of the header should be.
            let minimumSize = systemLayoutSizeFitting(CGSize(width: scrollView.frame.width, height: 0),
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
        let targetHeight = referenceHeight - offset - referenceOffset
        var targetOffset = referenceOffset
        if targetHeight < minimumSize {
            targetOffset += targetHeight - minimumSize
        }
        
        // Update the header's height and vertical position.
        var headerFrame = frame;
        headerFrame.size.height = max(minimumSize, targetHeight)
        headerFrame.origin.y = targetOffset
        
        // Calculate dynamic text size
        let fontSize = max(maxLabelPointSize, (((headerFrame.size.height-minimumSize)/maxHeight)*(maxLabelPointSize-minLabelPointSize))+minLabelPointSize)
        headerLabel.font = headerLabel.font.withSize(max(fontSize, minLabelPointSize))
        
        frame = headerFrame
    }
}
