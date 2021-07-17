//
//  cellCategoriesOverview.swift
//  FIN
//
//  Created by Florian Riel on 05.01.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit
import CoreData

class cellSavingsOverview: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var indexRow = 2
    
    var savingsData = [[Int:Any]]()
    
    var numberFormatter = NumberFormatter()
    
    let alphaValue:CGFloat = 0.6
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        
        let nib = UINib(nibName: "categoryCarouselCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "categoryCarouselCell")
        setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: 0)
        
        
        getSavingsData()
    }
    
    @objc func refreshView() {
        getSavingsData()
        collectionView.reloadData()
    }
    
    func getSavingsData() {
        // Get sum grouped-by catID - isSave = true
        // for each entry, get category color & name and add to array
        let queryCategoryGroup = NSPredicate(format: "isSave == %@", NSNumber(value: true))
        let groupedData = dataHandler.loadDataGroupedSUM(entitie: "Transactions", groupByColumn: "categoryID", query: queryCategoryGroup) as? [[String:Any]]
        if (groupedData?.count ?? 0) > 0 {
            for i in 0...(groupedData?.count ?? 0)-1 {
                let queryCategory = NSPredicate(format: "cID == %i", (groupedData?[i]["categoryID"] as? Int16 ?? 0))
                let ramDict = [
                    0:dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? "",
                    1:dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? "",
                    2:(groupedData?[i]["sum"] as? Double ?? 0.00)
                ] as [Int:Any]
                savingsData.append(ramDict)
            }
        }
        collectionView.reloadData()
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        // carousel.delegate = dataSourceDelegate
        collectionView.delegate = self
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savingsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCarouselCell", for: indexPath) as! categoryCarouselCell
        
        cell.subLabel.text = (savingsData[indexPath.row][0] as? String ?? "")
        cell.outlineView.backgroundColor = UIColor.randomColor(color: Int(savingsData[indexPath.row][1] as? Int16 ?? 0)).withAlphaComponent(alphaValue)
        cell.outlineView.layer.borderColor = UIColor.randomColor(color: Int(savingsData[indexPath.row][1] as? Int16 ?? 0)).withAlphaComponent(alphaValue).cgColor
        cell.subLabel.textColor = UIColor.randomColor(color: Int(savingsData[indexPath.row][1] as? Int16 ?? 0))
        cell.amountLabel.textColor = UIColor.randomColor(color: Int(savingsData[indexPath.row][1] as? Int16 ?? 0))
        cell.amountLabel.text = numberFormatter.string(from: NSNumber(value: savingsData[indexPath.row][2] as? Double ?? 0.00))
        
        return cell
    }
}
