//
//  cellCategoriesOverview.swift
//  FIN
//
//  Created by Florian Riel on 05.01.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit
import CoreData

class cellCategoriesOverview: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var Delegate:cellCategoriesOverviewDelegate?
    
    var indexRow = 2
    
    var categoryData = [[Int:Any]]()
    
    var numberFormatter = NumberFormatter()
    var numberFormatterPercent = NumberFormatter()
    
    let alphaValue:CGFloat = 0.8
    
    var selectedCategoryTimeRange = 0
    
    struct categoryEntry {
        var name:String
        var color:Int16
        var sum:Double
        var budget:Double?
        var isSave:Bool
        var isIncome:Bool
        var order:Int16
        var icon:String
        var light:Bool
    }
    
    var activeBudget = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("updateFinVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("dataImported"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("transactionDeleted"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("transactionUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("transactionAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(categoyTimeRangeChanged(notification:)), name: Notification.Name("finVCCategoyTimeRangeChanged"), object: nil)
        
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        
        numberFormatterPercent.numberStyle = .decimal
        numberFormatterPercent.usesGroupingSeparator = true
        numberFormatterPercent.groupingSeparator = Locale.current.groupingSeparator
        numberFormatterPercent.groupingSize = 3
        numberFormatterPercent.minimumFractionDigits = 2
        numberFormatterPercent.maximumFractionDigits = 2
        
        activeBudget = dataHandler.loadIfBudget()
        
        let nib = UINib(nibName: "categoryCarouselCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "categoryCarouselCell")
        setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: 0)
        
        getCategoryData()
        collectionView.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        refreshView()
    }
    
    @objc func refreshView() {
        activeBudget = dataHandler.loadIfBudget()
        categoryData.removeAll()
        getCategoryData()
        collectionView.reloadData()
    }
    
    func getCategoryData() {
        // Get sum grouped-by catID - isSave = false
        // for each entry, get category color & name and add to array
        var fromDateTime = Date().startOfMonth
        var toDateTime = Date().endOfMonth
        
        var categoryStructData = [categoryEntry]()
        
        var queryCategoryGroup = NSPredicate(format: "dateTime >= %@ AND dateTime <= %@ AND dateTime != nil", fromDateTime as NSDate, toDateTime as NSDate)
        
        if (selectedCategoryTimeRange == 1 && !activeBudget) || (selectedCategoryTimeRange == 2 && activeBudget) {
            fromDateTime = Date().startOfYear
            toDateTime = Date().endOfYear
            queryCategoryGroup = NSPredicate(format: "dateTime >= %@ AND dateTime <= %@ AND dateTime != nil", fromDateTime as NSDate, toDateTime as NSDate)
        } else if (selectedCategoryTimeRange == 2 && !activeBudget) || (selectedCategoryTimeRange == 3 && activeBudget) {
            queryCategoryGroup = NSPredicate(format: "categoryID != nil", fromDateTime as NSDate, toDateTime as NSDate)
        }
        
        if selectedCategoryTimeRange == 0 && activeBudget {
            let queryCategoryBudget = NSPredicate(format: "budget != nil AND budget > %f", 0.00)
            for category in dataHandler.loadBulkQueriedSorted(entitie: "Categories", query: queryCategoryBudget, sort: [NSSortDescriptor(key: "cID", ascending: true)]) {
                var sum = 0.00
                let budget = (category.value(forKey: "budget") as? Double ?? 0.00)
                let isIncome = category.value(forKey: "isIncome") as? Bool ?? false
                let isSave = category.value(forKey: "isSave") as? Bool ?? false
                
                let icon = category.value(forKey: "icon") as? String ?? ""
                let light = category.value(forKey: "iconLight") as? Bool ?? true
                
                let querySum = NSPredicate(format: "dateTime >= %@ AND dateTime <= %@ AND dateTime != nil AND categoryID == %i AND isLiquid == true", fromDateTime as NSDate, toDateTime as NSDate, category.value(forKey: "cID") as? Int16 ?? -2)
                let groupedSUM = dataHandler.loadDataGroupedSUM(entitie: "Transactions", groupByColumn: "categoryID", query: querySum) as? [[String:Any]]
                if (groupedSUM?.count ?? 0) > 0 {
                    for i in 0...(groupedSUM?.count ?? 1)-1 {
                        sum = (groupedSUM?[i]["sum"] as? Double ?? 0.00)
//                        if isIncome || isSave {
//                            sum = (groupedSUM?[i]["sum"] as? Double ?? 0.00) - budget
//                        } else {
//                            sum = budget - (groupedSUM?[i]["sum"] as? Double ?? 0.00)
//                        }
                    }
                }
                
                categoryStructData.append(categoryEntry(
                                            name: (category.value(forKey: "name") as? String ?? ""),
                                            color: (category.value(forKey: "color") as? Int16 ?? 0),
                                            sum: sum,
                                            budget: budget,
                                            isSave: isSave,
                                            isIncome: isIncome,
                                            order: (category.value(forKey: "order") as? Int16 ?? 0),
                                            icon: icon,
                                            light: light
                                          ))
            }
        } else {
            let groupedData = dataHandler.loadDataGroupedSUM(entitie: "Transactions", groupByColumn: "categoryID", query: queryCategoryGroup) as? [[String:Any]]
            if (groupedData?.count ?? 0) > 0 {
                for i in 0...(groupedData?.count ?? 1)-1 {
                    let queryCategory = NSPredicate(format: "cID == %i", (groupedData?[i]["categoryID"] as? Int16 ?? 0))
                    categoryStructData.append(categoryEntry(
                                                name: ((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? "")),// + " (" + monthStr.prefix(1).uppercased() + ")"),
                                                color: (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0),
                            sum: (groupedData?[i]["sum"] as? Double ?? 0.00),
                                                isSave: (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isSave", query: queryCategory) as? Bool ?? false),
                                                isIncome: (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false),
                                                order: (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "order", query: queryCategory) as? Int16 ?? 0),
                                                icon: ((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "icon", query: queryCategory) as? String ?? "")),
                                                light: (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "iconLight", query: queryCategory) as? Bool ?? false)))
                }
            }
        }
        
        if categoryStructData.count > 0 { categoryStructData.sort { $0.order < $1.order } }
        
        categoryData.removeAll()
        for category in categoryStructData {
            let ramDict = [
                0:category.name,
                1:category.color,
                2:category.sum,
                3:category.isSave,
                4:category.isIncome,
                5:category.budget ?? 0.00,
                6:true, // Show percent
                7:category.icon,
                8:category.light
            ] as [Int:Any]
            categoryData.append(ramDict)
        }
    }
    
    @objc func categoyTimeRangeChanged(notification: Notification) {
        if let userInfo = notification.userInfo, let selectedNew = userInfo["selectedLabel"] as? Int {
            if let selectedCell = userInfo["selectedCell"] as? Int {
                if selectedCell == 3 {
                    activeBudget = dataHandler.loadIfBudget()
                    
                    selectedCategoryTimeRange = selectedNew
                    getCategoryData()

                    collectionView.reloadSections(IndexSet(integer: 0))
                    
                    //collectionView.performBatchUpdates({
                        //collectionView.reloadData()
                        // collectionView.reloadSections(IndexSet(integer: 0))
                    //}, completion: nil)
                    // collectionView.layoutIfNeeded()
                }
            }
        }
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        // carousel.delegate = dataSourceDelegate
        collectionView.delegate = self
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCarouselCell", for: indexPath) as! categoryCarouselCell
        cell.amountLabel.isHidden = false
        cell.subLabel.text = (categoryData[indexPath.row][0] as? String ?? "")
        cell.outlineView.backgroundColor = UIColor.randomColor(color: Int(categoryData[indexPath.row][1] as? Int16 ?? 0)).withAlphaComponent(alphaValue)
        cell.outlineView.layer.borderColor = UIColor.randomColor(color: Int(categoryData[indexPath.row][1] as? Int16 ?? 0)).withAlphaComponent(alphaValue).cgColor
        cell.outlineView.layer.borderWidth = 1.0
        if selectedCategoryTimeRange == 0 && activeBudget {
            if categoryData[indexPath.row][6] as? Bool ?? false {
                let amount = ((categoryData[indexPath.row][2] as? Double ?? 0.00) / (categoryData[indexPath.row][5] as? Double ?? 0.00)) * 100
                cell.amountLabel.text = (numberFormatterPercent.string(from: NSNumber(value: amount)) ?? "") + " %"
            } else {
                cell.amountLabel.text = (numberFormatter.string(from: NSNumber(value: categoryData[indexPath.row][2] as? Double ?? 0.00)) ?? "") + " / " + (numberFormatter.string(from: NSNumber(value: categoryData[indexPath.row][5] as? Double ?? 0.00)) ?? "")
            }
            if (!(categoryData[indexPath.row][3] as? Bool ?? false) && !(categoryData[indexPath.row][4] as? Bool ?? false)) && ((categoryData[indexPath.row][2] as? Double ?? 0.00) > (categoryData[indexPath.row][5] as? Double ?? 0.00)) {
                cell.amountLabel.font = UIFont.preferredFont(forTextStyle: .body).bold()
                cell.outlineView.layer.borderWidth = 2.0
            } else if ((categoryData[indexPath.row][3] as? Bool ?? false) || (categoryData[indexPath.row][4] as? Bool ?? false)) && (categoryData[indexPath.row][2] as? Double ?? 0.00) < (categoryData[indexPath.row][5] as? Double ?? 0.00) {
                cell.amountLabel.font = UIFont.preferredFont(forTextStyle: .body).bold()
                cell.outlineView.layer.borderWidth = 2.0
            } else {
                cell.amountLabel.font = UIFont.preferredFont(forTextStyle: .body)
            }
        } else {
            cell.amountLabel.text = numberFormatter.string(from: NSNumber(value: categoryData[indexPath.row][2] as? Double ?? 0.00))
            cell.amountLabel.font = UIFont.preferredFont(forTextStyle: .body)
        }
        
        if (categoryData[indexPath.row][8] as? Bool ?? true) {
            cell.amountLabel.textColor = .white
            cell.subLabel.textColor = .white
        } else {
            cell.amountLabel.textColor = .black
            cell.subLabel.textColor = .black
        }

        if (categoryData[indexPath.row][7] as? String ?? "").count > 0 {
            var selectedIcon = (categoryData[indexPath.row][7] as? String ?? "").replacingOccurrences(of: "_white", with: "")
            if (categoryData[indexPath.row][8] as? Bool ?? true) {
                selectedIcon = selectedIcon + "_white"
            }
            cell.icon.image = UIImage(named: selectedIcon)
        } else {
            if (categoryData[indexPath.row][3] as? Bool ?? false) { // isSave
                if !(categoryData[indexPath.row][8] as? Bool ?? true) {
                    cell.icon.image = UIImage(named: "safeBlack")
                } else {
                    cell.icon.image = UIImage(named: "safeWhite")
                }
            } else if (categoryData[indexPath.row][4] as? Bool ?? false) { // isIncome
                if !(categoryData[indexPath.row][8] as? Bool ?? true) {
                    cell.icon.image = UIImage(named: "iconPlusBlack")
                } else {
                    cell.icon.image = UIImage(named: "iconPlusWhite")
                }
            } else { // isExpense
                if !(categoryData[indexPath.row][8] as? Bool ?? true) {
                    cell.icon.image = UIImage(named: "iconMinusBlack")
                } else {
                    cell.icon.image = UIImage(named: "iconMinusWhite")
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? categoryCarouselCell {
            if selectedCategoryTimeRange == 0 && activeBudget {
                self.categoryData[indexPath.row][6] = !(self.categoryData[indexPath.row][6] as? Bool ?? false)
                
                var reload = [IndexPath]()
                for i in 0...categoryData.count-1 {
                    reload.append(IndexPath(row: i, section: 0))
                }
                
                UIView.animate(withDuration: 0.1, animations: {
                    cell.transform = self.transform.scaledBy(x: 0.92, y: 0.92)
                    }, completion: { _ in
                      // Step 2
                      UIView.animate(withDuration: 0.1, animations: {
                        cell.transform = CGAffineTransform.identity
                      }, completion: { _ in
                        cell.amountLabel.isHidden = true
                        //self.collectionView.performBatchUpdates({
                        // self.collectionView.reloadData()
                        // self.collectionView.reloadSections(IndexSet(integer: 0))
                        UIView.animate(withDuration: 0.01, delay: 0.0, options: .curveLinear, animations: {
                            self.collectionView.alpha = 0.99
                            self.collectionView.performBatchUpdates({
                                self.collectionView.reloadItems(at: reload)
                            }, completion: {_ in
                                UIView.animate(withDuration: 0.01, delay: 0.0, options: .curveLinear, animations: {
                                    self.collectionView.alpha = 1.0
                                }, completion: {_ in
                                    self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                                })
//                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
//
//                                })
                            })
                        })
                        
                        
                            // self.collectionView.reloadItems(at: [indexPath])
                            // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                            //    self.collectionView.reloadItems(at: [indexPath])
                            // })
                            // self.collectionView.reloadData()
                            // if self.categoryData[indexPath.row][6] as? Bool ?? false {
                            //    let amount = ((self.categoryData[indexPath.row][2] as? Double ?? 0.00) / (self.categoryData[indexPath.row][5] as? Double ?? 0.00)) * 100
                            //    cell.amountLabel.text = (self.numberFormatterPercent.string(from: NSNumber(value: amount)) ?? "") + " %"
                            // } else {
                            //    cell.amountLabel.text = (self.numberFormatter.string(from: NSNumber(value: self.categoryData[indexPath.row][2] as? Double ?? 0.00)) ?? "") + " / " + (self.numberFormatter.string(from: NSNumber(value: self.categoryData[indexPath.row][5] as? Double ?? 0.00)) ?? "")
                            // }
                        // cell.amountLabel.isHidden = false
                        // self.collectionView.layoutIfNeeded()
                        //})
                      })
                    })
            } else {
                UIView.animate(withDuration: 0.1, animations: {
                    cell.transform = self.transform.scaledBy(x: 0.92, y: 0.92)
                    }, completion: { _ in
                      // Step 2
                      UIView.animate(withDuration: 0.1, animations: {
                        cell.transform = CGAffineTransform.identity
                      }, completion: { _ in
                        self.Delegate?.switchToListPressed()
                      })
                    })
            }
        }
    }
    
    @objc func switchToList() {
        self.Delegate?.switchToListPressed()
    }
}

protocol cellCategoriesOverviewDelegate: AnyObject {
    func switchToListPressed()
}

extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }

    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }

    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}
