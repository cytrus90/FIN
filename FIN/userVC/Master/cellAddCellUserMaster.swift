//
//  cellAddCellUserMaster.swift
//  FIN
//
//  Created by Florian Riel on 03.02.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit
import GoogleMobileAds

class cellAddCellUserMaster: UITableViewCell {

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var bannerOutlineView: UIView!
    
    var bannerView: GADBannerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        outlineView.backgroundColor = .clear
        bannerOutlineView.backgroundColor = .clear
        
        if showAdds {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            addBannerViewToView(bannerView)
            bannerView.adUnitID = "ca-app-pub-6709479231347115/4061747322"
            bannerView.load(GADRequest())
        }
    }

    // MARK: Adds...
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerOutlineView.addSubview(bannerView)
        bannerView.centerYAnchor.constraint(equalTo: bannerOutlineView.centerYAnchor).isActive = true
        bannerView.centerXAnchor.constraint(equalTo: bannerOutlineView.centerXAnchor).isActive = true
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      bannerView.alpha = 0
      UIView.animate(withDuration: 1, animations: {
        bannerView.alpha = 1
      })
    }
}
