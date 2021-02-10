//
//  searchBar.swift
//  FIN
//
//  Created by Florian Riel on 07.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit

class searchBar: UIView, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    weak var delegate: searchBarDelegate?
    
    func initView() {
       
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 1
        
//        searchBar.backgroundImage = UIImage()
        initTraitChange()
        if searchBar != nil {
            searchBar.delegate = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(searchBarDissappeared), name: Notification.Name("searchBarDissappeared"), object: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initTraitChange()
    }

    func initTraitChange() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.layer.borderColor = UIColor.white.cgColor
        } else {
            self.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.delegate?.cancelButtonPressed()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.delegate?.seachBarTextChanged(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.delegate?.toggleScrolling(disabled: false)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.delegate?.toggleScrolling(disabled: true)
        return true
    }
    
    @objc func searchBarDissappeared() {
        searchBar.resignFirstResponder()
    }
}

protocol searchBarDelegate: AnyObject {
    func cancelButtonPressed()
    func seachBarTextChanged(searchText: String)
    func toggleScrolling(disabled: Bool)
}
