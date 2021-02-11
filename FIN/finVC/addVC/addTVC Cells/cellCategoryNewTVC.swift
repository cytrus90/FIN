//
//  cellCategoryNewTVC.swift
//  FIN
//
//  Created by Florian Riel on 22.01.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import UIKit
import CoreData

class cellCategoryNewTVC: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
//    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    var categoryData = [[Int:Any]]()
    let alphaValue:CGFloat = 0.6
    
    var selectedCell = 0
    var firstLoad:Bool = true
    
    weak var delegate: cellNewCategoryTVCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nib = UINib(nibName: "addCategoryCarouselCell", bundle: nil)
        categoryCollectionView.register(nib, forCellWithReuseIdentifier: "addCategoryCarouselCell")
        setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: 0)
        
        categoryCollectionView.layer.borderWidth = 1
        categoryCollectionView.layer.cornerRadius = 10
        categoryCollectionView.layer.borderColor = UIColor.clear.cgColor
        
        categoryCollectionView.contentMode = .center
        
        initView()
        getCategoryData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initView()
    }

    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            categoryCollectionView.backgroundColor = .white
            categoryCollectionView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .clear
            categoryCollectionView.backgroundColor = .black
            categoryCollectionView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }
    
    // MARK: -DATA
    func getCategoryData() {
        categoryData.removeAll()
        let categorySortOrder = NSSortDescriptor(key: "order", ascending: true)
        // Get Expense Categories
        let predicateExpenses:NSPredicate = NSPredicate(format: "isIncome == false && isSave == false")
        let expenses = loadBulkDataWithQuery(entitie: "Categories", query: predicateExpenses, sort: [categorySortOrder])
        if expenses.count != 0 {
            for expense in expenses {
                let ramDict = [
                    0:expense.value(forKey: "cID") as? Int16 ?? 0,
                    1:expense.value(forKey: "name") as? String ?? "",
                    2:expense.value(forKey: "color") as? Int16 ?? 0,
                    3:expense.value(forKey: "isIncome") as? Bool ?? false,
                    4:expense.value(forKey: "isSave") as? Bool ?? false
                ] as [Int:Any]
                categoryData.append(ramDict)
            }
        }
        // Get Income Categories
        let predicateIncome:NSPredicate = NSPredicate(format: "isIncome == true && isSave == false")
        let incomes = loadBulkDataWithQuery(entitie: "Categories", query: predicateIncome, sort: [categorySortOrder])
        if incomes.count != 0 {
            for income in incomes {
                let ramDict = [
                    0:income.value(forKey: "cID") as? Int16 ?? 0,
                    1:income.value(forKey: "name") as? String ?? "",
                    2:income.value(forKey: "color") as? Int16 ?? 0,
                    3:income.value(forKey: "isIncome") as? Bool ?? false,
                    4:income.value(forKey: "isSave") as? Bool ?? false
                ] as [Int:Any]
                categoryData.append(ramDict)
            }
        }
        // Get Savings Income Categories
        let predicateSaveDeposit:NSPredicate = NSPredicate(format: "isIncome == false && isSave == true")
        let savesDeposit = loadBulkDataWithQuery(entitie: "Categories", query: predicateSaveDeposit, sort: [categorySortOrder])
        if savesDeposit.count != 0 {
            for saveIncome in savesDeposit {
                let ramDict = [
                    0:saveIncome.value(forKey: "cID") as? Int16 ?? 0,
                    1:saveIncome.value(forKey: "name") as? String ?? "",
                    2:saveIncome.value(forKey: "color") as? Int16 ?? 0,
                    3:saveIncome.value(forKey: "isIncome") as? Bool ?? false,
                    4:saveIncome.value(forKey: "isSave") as? Bool ?? false
                ] as [Int:Any]
                categoryData.append(ramDict)
            }
        }
        // Get Savings Expense Categories
        let predicateSaveWithdraw:NSPredicate = NSPredicate(format: "isIncome == true && isSave == true")
        let savesWithdraw = loadBulkDataWithQuery(entitie: "Categories", query: predicateSaveWithdraw, sort: [categorySortOrder])
        if savesWithdraw.count != 0 {
            for saveExpense in savesWithdraw {
                let ramDict = [
                    0:saveExpense.value(forKey: "cID") as? Int16 ?? 0,
                    1:saveExpense.value(forKey: "name") as? String ?? "",
                    2:saveExpense.value(forKey: "color") as? Int16 ?? 0,
                    3:saveExpense.value(forKey: "isIncome") as? Bool ?? false,
                    4:saveExpense.value(forKey: "isSave") as? Bool ?? false
                ] as [Int:Any]
                categoryData.append(ramDict)
            }
        }
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        // carousel.delegate = dataSourceDelegate
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = dataSourceDelegate
        categoryCollectionView.tag = row
        categoryCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCategoryCarouselCell", for: indexPath) as! addCategoryCarouselCell
        
        cell.label.text = (categoryData[indexPath.row][1] as? String ?? "")
        
        if (categoryData[indexPath.row][0] as? Int16 ?? -1) == Int16(selectedCategory) {
            selectedCell = indexPath.row
            cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
            cell.label.textColor = UIColor.white
            if firstLoad {
                firstLoad = false
                self.delegate?.categoryPicked(category: categoryData[indexPath.row])
            }
        } else {
            cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.2)
            cell.label.textColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? addCategoryCarouselCell {
            selectedCategory = Int(categoryData[indexPath.row][0] as? Int16 ?? -1)
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = self.transform.scaledBy(x: 0.92, y: 0.92)
                }, completion: { _ in
                  UIView.animate(withDuration: 0.1, animations: {
                    self.resetCell(indexPathNew: indexPath)
                    self.setCellSelected(indexPath: indexPath)
                    cell.transform = CGAffineTransform.identity
                  }, completion: { _ in
                    self.delegate?.categoryPicked(category: self.categoryData[indexPath.row])
                  })
            })
        }
    }
    
    func setCellSelected(indexPath: IndexPath) {
        if let cell = categoryCollectionView.cellForItem(at: indexPath) as? addCategoryCarouselCell {
            cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
            cell.label.textColor = UIColor.white
            
            selectedCell = indexPath.row
        }
    }
    
    func resetCell(indexPathNew: IndexPath) {
        if indexPathNew.row != selectedCell {
            let indexPath = IndexPath(row: Int(selectedCell), section: 0)
            if let cell = categoryCollectionView.cellForItem(at: indexPath) as? addCategoryCarouselCell {
                cell.outlineView.layer.borderColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1).cgColor
                cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.2)
                cell.label.textColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
            }
        }
    }
}

// Mark: DATA
extension cellCategoryNewTVC {
    func loadBulkDataWithQuery(entitie:String, query:NSPredicate, sort:[NSSortDescriptor]) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        fetchRequest.sortDescriptors = sort
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return [NSManagedObject]()
    }
}

protocol cellNewCategoryTVCDelegate: AnyObject {
    func categoryPicked(category: [Int:Any])
}
