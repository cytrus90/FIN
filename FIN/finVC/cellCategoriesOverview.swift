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
    
    let alphaValue:CGFloat = 0.6
    
    struct categoryEntry {
        var name:String
        var color:Int16
        var sum:Double
        var isSave:Bool
        var isIncome:Bool
        var order:Int16
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("updateFinVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("dataImported"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("transactionDeleted"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("transactionUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("transactionAdded"), object: nil)
        
        
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        
        let nib = UINib(nibName: "categoryCarouselCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "categoryCarouselCell")
        setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: 0)
        
        getCategoryData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        refreshView()
    }
    
    @objc func refreshView() {
        categoryData.removeAll()
        getCategoryData()
        collectionView.reloadData()
    }
    
    func getCategoryData() {
        // Get sum grouped-by catID - isSave = false
        // for each entry, get category color & name and add to array
        let fromDateTime = Date().startOfMonth
        let toDateTime = Date().endOfMonth
        
        var categoryStructData = [categoryEntry]()
        
        let monthInt = Calendar.current.component(.month, from: Date())
        let monthStr = Calendar.current.monthSymbols[monthInt-1]
        
        let queryCategoryGroup = NSPredicate(format: "isSave == %@ AND dateTime >= %@ AND dateTime <= %@ AND dateTime != nil", NSNumber(value: false), fromDateTime as NSDate, toDateTime as NSDate)
        let groupedData = loadDataGroupedSUM(entitie: "Transactions", groupByColumn: "categoryID", query: queryCategoryGroup) as? [[String:Any]]
        if (groupedData?.count ?? 0) > 0 {
            print("flkdsjflaksd")
            print(groupedData)
            for i in 0...(groupedData?.count ?? 0)-1 {
                let queryCategory = NSPredicate(format: "cID == %i", (groupedData?[i]["categoryID"] as? Int16 ?? 0))
                categoryStructData.append(categoryEntry(
                        name: ((loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? "") + " (" + monthStr.prefix(1).uppercased() + ")"),
                        color: (loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0),
                        sum: (groupedData?[i]["sum"] as? Double ?? 0.00),
                        isSave: (loadQueriedAttribute(entitie: "Categories", attibute: "isSave", query: queryCategory) as? Bool ?? false),
                        isIncome: (loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false),
                        order: (loadQueriedAttribute(entitie: "Categories", attibute: "order", query: queryCategory) as? Int16 ?? 0)))
            }
        }
        // Get sum grouped-by catID - isSave = true
        // for each entry, get category color & name and add to array
        let querySavingsGroup = NSPredicate(format: "isSave == %@", NSNumber(value: true))
        let groupedSavingsData = loadDataGroupedSUM(entitie: "Transactions", groupByColumn: "categoryID", query: querySavingsGroup) as? [[String:Any]]
        if (groupedSavingsData?.count ?? 0) > 0 {
            for i in 0...(groupedSavingsData?.count ?? 0)-1 {
                let queryCategory = NSPredicate(format: "cID == %i", (groupedSavingsData?[i]["categoryID"] as? Int16 ?? 0))
                categoryStructData.append(categoryEntry(
                        name: ((loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? "") + " (" + monthStr.prefix(1).uppercased() + ")"),
                        color: (loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0),
                        sum: (groupedData?[i]["sum"] as? Double ?? 0.00),
                        isSave: (loadQueriedAttribute(entitie: "Categories", attibute: "isSave", query: queryCategory) as? Bool ?? false),
                        isIncome: (loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false),
                        order: (loadQueriedAttribute(entitie: "Categories", attibute: "order", query: queryCategory) as? Int16 ?? 0)))
            }
        }
        
        if categoryStructData.count > 0 { categoryStructData.sort { $0.order < $1.order } }
        
        print("flkadjflasdk")
        print(categoryStructData)
        
        for category in categoryStructData {
            let ramDict = [
                0:category.name,
                1:category.color,
                2:category.sum,
                3:category.isSave,
                4:category.isIncome
            ] as [Int:Any]
            categoryData.append(ramDict)
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
        return categoryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCarouselCell", for: indexPath) as! categoryCarouselCell
        
        cell.subLabel.text = (categoryData[indexPath.row][0] as? String ?? "")
        cell.outlineView.backgroundColor = UIColor.randomColor(color: Int(categoryData[indexPath.row][1] as? Int16 ?? 0), returnText: false, light: false).withAlphaComponent(alphaValue)
        cell.outlineView.layer.borderColor = UIColor.randomColor(color: Int(categoryData[indexPath.row][1] as? Int16 ?? 0), returnText: false, light: false).withAlphaComponent(alphaValue).cgColor
        cell.amountLabel.text = numberFormatter.string(from: NSNumber(value: categoryData[indexPath.row][2] as? Double ?? 0.00))
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            cell.amountLabel.textColor = UIColor.randomColor(color: Int(categoryData[indexPath.row][1] as? Int16 ?? 0), returnText: true, light: false)
            cell.subLabel.textColor = UIColor.randomColor(color: Int(categoryData[indexPath.row][1] as? Int16 ?? 0), returnText: true, light: false)
        } else {
            cell.amountLabel.textColor = .white
            cell.subLabel.textColor = .white
        }
        
        var iconBlack:Bool = true
        if UIColor.randomColor(color: Int(categoryData[indexPath.row][1] as? Int16 ?? 0), returnText: true, light: false) == .white || userInterfaceStyle == .dark {
            iconBlack = false
        }
        
        if (categoryData[indexPath.row][3] as? Bool ?? false) { // isSave
            if iconBlack {
                cell.icon.image = UIImage(named: "safeBlack")
            } else {
                cell.icon.image = UIImage(named: "safeWhite")
            }
        } else if (categoryData[indexPath.row][4] as? Bool ?? false) { // isIncome
            if iconBlack {
                cell.icon.image = UIImage(named: "iconPlusBlack")
            } else {
                cell.icon.image = UIImage(named: "iconPlusWhite")
            }
        } else { // isExpense
            if iconBlack {
                cell.icon.image = UIImage(named: "iconMinusBlack")
            } else {
                cell.icon.image = UIImage(named: "iconMinusWhite")
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? categoryCarouselCell {
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
    
    @objc func switchToList() {
        self.Delegate?.switchToListPressed()
    }
}

protocol cellCategoriesOverviewDelegate: AnyObject {
    func switchToListPressed()
}

// MARK: -DATA
extension cellCategoriesOverview {
    func loadDataGroupedSUM(entitie:String, groupByColumn:String, query:NSPredicate) -> Any {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
        let keypathExp1 = NSExpression(forKeyPath: "realAmount") // can be any column
        let expression1 = NSExpression(forFunction: "sum:", arguments: [keypathExp1])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression1
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        
        let keypathExp2 = NSExpression(forKeyPath: groupByColumn) // can be any column
        let expression2 = NSExpression(forFunction: "count:", arguments: [keypathExp2])
        
        let countDesc = NSExpressionDescription()
        countDesc.expression = expression2
        countDesc.name = "count"
        countDesc.expressionResultType = .integer64AttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = [groupByColumn]
        fetchRequest.propertiesToFetch = [groupByColumn, countDesc ,sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let loadData = try managedContext.fetch(fetchRequest)
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return false
    }
    
    func loadQueriedAttribute(entitie:String, attibute:String, query:NSPredicate) -> Any {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                if data.value(forKey: attibute) != nil {
                    return data.value(forKey: attibute) ?? false
                }
            }
        } catch {
            print("Could not fetch. \(error)")
        }
        return false
    }
}
