//
//  categoryTVC.swift
//  FIN
//
//  Created by Florian Riel on 30.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

class categoryTVC: UITableViewController {

    @IBOutlet var categoryTable: UITableView!
        
    var categoryData = [Int:Any]()
    
    let amountFormatter = NumberFormatter()
    let numberFormatter = NumberFormatter()
    
    struct CategoryEntry {
        var cID:Int16
        var name:String
        var dateTime:Date
        var order:Int16
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("CategoryTitle", comment: "CategoryTitle")
        
        // Keyboard dismiss
        categoryTable.keyboardDismissMode = .onDrag
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissViewController))
        
        amountFormatter.locale = .current
        amountFormatter.numberStyle = .currency
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = Locale.current.groupingSeparator
        numberFormatter.groupingSize = 3
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        initView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initView()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategorySave", for: indexPath) as! cellCategorySave
            if categoryData[2] as? Bool ?? false {
                cell.saveSwitch.isOn = true
            } else {
                cell.saveSwitch.isOn = false
            }
            cell.saveLabel.text = NSLocalizedString("categorySaveSegmentTitle", comment: "isSaveLabel")
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategoryInitial", for: indexPath) as! cellCategoryInitial
            cell.textField.text = amountFormatter.string(from: NSNumber(value: categoryData[6] as? Double ?? 0.00))
            cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategoryColor", for: indexPath) as! cellCategoryColor
            cell.colorPickerView.preselectedIndex = Int(categoryData[3] as? Int16 ?? 0)
            cell.delegate = self
            return cell
        case 4: // Add Button
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategoryAdd", for: indexPath) as! cellCategoryAdd
            if selectedCategoryDetail == -1 {
                cell.addButton.setTitle(NSLocalizedString("categoryButtonAdd", comment: "Add Button Add"), for: .normal)
            } else {
                cell.addButton.setTitle(NSLocalizedString("categoryButtonUpdate", comment: "Add Button Update"), for: .normal)
            }
            cell.delegate = self
            return cell
        default: // Main
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategoryMain", for: indexPath) as! cellCategoryMain
            cell.categoryTitleTextField.placeholder = NSLocalizedString("categoryTitlePlaceholder", comment: "Category Title Placeholder")
            cell.categoryTitleTextField.text = categoryData[0] as? String ?? ""
            if categoryData[1] as? Bool ?? false {
                cell.categoryTypeSegmentControl.selectedSegmentIndex = 1
            } else {
                cell.categoryTypeSegmentControl.selectedSegmentIndex = 0
            }
            if categoryData[2] as? Bool ?? true {
                cell.categoryTypeSegmentControl.isHidden = true
            } else {
                cell.categoryTypeSegmentControl.isHidden = false
            }
            cell.delegate = self
            return cell
        }
    }
    
    // MARK: -FUNCTIONS
    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            categoryTable.backgroundColor = backgroundGeneralColor
        } else {
            categoryTable.backgroundColor = .secondarySystemBackground
        }
        if selectedCategoryDetail == -1 {
            categoryData[0] = "" // Title
            categoryData[1] = false // Income
            categoryData[2] = false // Save
            categoryData[3] = Int16(0) // Color
            categoryData[4] = Date() // createDate
            categoryData[5] = Int16(-1)
            categoryData[6] = 0.00
        } else {
            let categoryPredicate:NSPredicate = NSPredicate(format: "cID == \(selectedCategoryDetail)")
            let categoryLoaded = loadBulkDataWithQuery(entitie: "Categories", query: categoryPredicate)
            categoryData[0] = categoryLoaded[0].value(forKey: "name") as? String ?? ""
            categoryData[1] = categoryLoaded[0].value(forKey: "isIncome") as? Bool ?? false
            categoryData[2] = categoryLoaded[0].value(forKey: "isSave") as? Bool ?? false
            categoryData[3] = categoryLoaded[0].value(forKey: "color") as? Int16 ?? 0
            categoryData[4] = categoryLoaded[0].value(forKey: "createDate") as? Date ?? Date()
            categoryData[5] = categoryLoaded[0].value(forKey: "cID") as? Int16 ?? 0
            
            let queryInitialTransaction = NSPredicate(format: "dateTime == nil AND categoryID == \(selectedCategoryDetail)")
            categoryData[6] = loadQueriedAttribute(entitie: "Transactions", attibute: "realAmount", query: queryInitialTransaction) as? Double ?? 0.00
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteCategoryButton))
        }
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func deleteCategoryButton() {
        if selectedCategoryDetail != -1 {
            let alert = UIAlertController(title: NSLocalizedString("deleteTitle", comment: "Delete Title"), message: NSLocalizedString("deleteText", comment: "Delete Text"), preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: NSLocalizedString("deleteYes", comment: "Delete Yes"), style: .destructive, handler: { action in
                let createDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: (self.categoryData[4]) as? Date ?? Date())!
                let createDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: (self.categoryData[4]) as? Date ?? Date())!
                
                var query = NSPredicate(format: "cID == %i AND createDate < %@ AND createDate > %@", (self.categoryData[5] as? Int16 ?? -1), createDatePlus as NSDate, createDateMinus as NSDate)
                if self.loadBulkDataWithQuery(entitie: "Categories", query: query).count <= 0 {
                    query = NSPredicate(format: "cID == %i", (self.categoryData[5] as? Int16 ?? -1))
                }
                self.deleteData(entity: "Categories", query: query)
                
                let queryDeleteTransactions = NSPredicate(format: "categoryID == %i", (self.categoryData[5] as? Int16 ?? -1))
                self.deleteData(entity: "Transactions", query: queryDeleteTransactions)
                
                for regularPayment in self.loadBulkDataWithQuery(entitie: "RegularPayments", query: queryDeleteTransactions) {
                    
                    let createDateRegularPlus = Calendar.current.date(byAdding: .second, value: 1, to: (regularPayment.value(forKey: "dateTimeNext") as? Date ?? Date()))!
                    let createDateRegularMinus = Calendar.current.date(byAdding: .second, value: -1, to: (regularPayment.value(forKey: "dateTimeNext") as? Date ?? Date()))!
                    let queryDeleteSplitsRegularPayments = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", createDateRegularPlus as NSDate, createDateRegularMinus as NSDate)
                    
                    self.deleteData(entity: "SplitsRegularPayments", query: queryDeleteSplitsRegularPayments)
                }
                self.deleteData(entity: "RegularPayments", query: queryDeleteTransactions)
                
                self.updateCategoryOrder()
                
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "categoryChanged")))
                NotificationCenter.default.post(name: Notification.Name("updateFinVC"), object: nil)
                self.dismiss(animated: true, completion: nil)
                reloadAddView = true
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("deleteNo", comment: "Delete No"), style: .cancel, handler: nil))
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = self.view.bounds
            self.present(alert, animated: true)
        }
    }
    
    func updateCategoryOrder() {
        // get & order all categories
        // order each one
        // update enties
        // save to categories
        var expenses = [CategoryEntry]()
        var income = [CategoryEntry]()
        var savings = [CategoryEntry]()
        
        for category in loadBulkDataSorted(entitie: "Categories", sort: [NSSortDescriptor(key: "cID", ascending: true)]) {
            if (category.value(forKey: "isSave") as? Bool ?? false) { // isSave
                savings.append(CategoryEntry(
                                cID: category.value(forKey: "cID") as? Int16 ?? -1,
                                name: category.value(forKey: "name") as? String ?? "",
                                dateTime: category.value(forKey: "createDate") as? Date ?? Date(),
                                order: category.value(forKey: "order") as? Int16 ?? category.value(forKey: "cID") as? Int16 ?? -1))
            } else if (category.value(forKey: "isIncome") as? Bool ?? false) { // isIncome
                income.append(CategoryEntry(
                                cID: category.value(forKey: "cID") as? Int16 ?? -1,
                                name: category.value(forKey: "name") as? String ?? "",
                                dateTime: category.value(forKey: "createDate") as? Date ?? Date(),
                                order: category.value(forKey: "order") as? Int16 ?? category.value(forKey: "cID") as? Int16 ?? -1))
            } else { // isExpense
                expenses.append(CategoryEntry(
                                    cID: category.value(forKey: "cID") as? Int16 ?? -1,
                                    name: category.value(forKey: "name") as? String ?? "",
                                    dateTime: category.value(forKey: "createDate") as? Date ?? Date(),
                                    order: category.value(forKey: "order") as? Int16 ?? category.value(forKey: "cID") as? Int16 ?? -1))
            }
        }
        
        var expensesSorted = expenses.sorted(by: { $0.order < $1.order })
        var incomeSorted = income.sorted(by: { $0.order < $1.order })
        var savingsSorted = savings.sorted(by: { $0.order < $1.order })
        
        var j:Int16 = 0
        for i in 0...expensesSorted.count-1 {
            expensesSorted[i].order = j
            j = j + 1
            
            let querySave = NSPredicate(format: "cID == %i", expensesSorted[i].cID)
            saveQueriedAttribute(entity: "Categories", attribute: "order", query: querySave, value: expensesSorted[i].order)
        }
        for i in 0...incomeSorted.count-1 {
            incomeSorted[i].order = j
            j = j + 1
            
            let querySave = NSPredicate(format: "cID == %i", incomeSorted[i].cID)
            saveQueriedAttribute(entity: "Categories", attribute: "order", query: querySave, value: incomeSorted[i].order)
        }
        for i in 0...savingsSorted.count-1 {
            savingsSorted[i].order = j
            j = j + 1
            
            let querySave = NSPredicate(format: "cID == %i", savingsSorted[i].cID)
            saveQueriedAttribute(entity: "Categories", attribute: "order", query: querySave, value: savingsSorted[i].order)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension categoryTVC {
    // MARK: -DATA
    // MARK: SAVE
    func saveNewCategory() -> Bool {
        if categoryData[0] as? String ?? "" != "" {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedContext = appDelegate!.persistentContainer.viewContext
            managedContext.automaticallyMergesChangesFromParent = true
            managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
            let categorySave = Categories(context: managedContext)
            
            let nextID = loadNextCategoryID()
            categorySave.cID = nextID
            categorySave.name = categoryData[0] as? String ?? ""
            categorySave.isIncome = categoryData[1] as? Bool ?? false
            categorySave.isSave = categoryData[2] as? Bool ?? false
            categorySave.color = categoryData[3] as? Int16 ?? 0
            categorySave.countEntries = 0
            categorySave.createDate = Date()
            categorySave.order = nextID
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            saveInitialTransaction(amount: (categoryData[6] as? Double ?? 0.00), isSave: (categoryData[2] as? Bool ?? false), categoryID: nextID)
            
            return true
        } else {
            let alert = UIAlertController(title: NSLocalizedString("noNameTitle", comment: "No Name Title"), message: NSLocalizedString("noNameText", comment: "No Name Text"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("noNameOk", comment: "No Name Ok"), style: .default, handler: nil))
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = self.view.bounds
            self.present(alert, animated: true)
        }
        return false
    }
    
    func updateCategory() -> Bool {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Categories")
        fetchRequest.predicate = NSPredicate(format: "cID == \(selectedCategoryDetail)")
        
        let queryTransactions = NSPredicate(format: "categoryID == \(selectedCategoryDetail)")
        
        do {
            let fetchedData = try managedContext.fetch(fetchRequest)
            for data in fetchedData {
                data.setValue(categoryData[0] as? String ?? "", forKey: "name")
                data.setValue(categoryData[1] as? Bool ?? false, forKey: "isIncome")
                data.setValue(categoryData[2] as? Bool ?? false, forKey: "isSave")
                data.setValue(categoryData[3] as? Int16 ?? 0, forKey: "color")
                
                saveQueriedAttributeMultiple(entity: "Transactions", attribute: "isSave", query: queryTransactions, value: (categoryData[2] as? Bool ?? false))
                
                updateInitialTransaction(amount: (categoryData[6] as? Double ?? 0.00), isSave: (categoryData[2] as? Bool ?? false), categoryID: selectedCategoryDetail)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
        do {
            try managedContext.save()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
    }
    
    func saveInitialTransaction(amount: Double, isSave: Bool, categoryID: Int16) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let transactionSave = Transactions(context: managedContext)
        
        transactionSave.amount = amount
        transactionSave.realAmount = amount
        transactionSave.categoryID = categoryID
        transactionSave.currencyCode = Locale.current.currencyCode ?? "EUR"
        transactionSave.dateTime = nil
        transactionSave.descriptionNote = "Initial"
        transactionSave.exchangeRate = 1.0
        transactionSave.tags = ""
        transactionSave.isSave = isSave
        transactionSave.isSplit = 0
        transactionSave.isLiquid = !isSave
                
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return
        }
    }
    
    func updateInitialTransaction(amount: Double, isSave: Bool, categoryID: Int16) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Transactions")
        fetchRequest.predicate = NSPredicate(format: "categoryID == \(selectedCategoryDetail) AND dateTime == nil")
        
        do {
            let fetchedData = try managedContext.fetch(fetchRequest)
            if fetchedData.count > 0 {
                for transactionSave in fetchedData {
                    transactionSave.setValue(amount, forKey: "amount")
                    transactionSave.setValue(amount, forKey: "realAmount")
                    transactionSave.setValue(categoryID, forKey: "categoryID")
                    transactionSave.setValue((Locale.current.currencyCode ?? "EUR"), forKey: "currencyCode")
                    transactionSave.setValue(nil, forKey: "dateTime")
                    transactionSave.setValue("Initial", forKey: "descriptionNote")
                    transactionSave.setValue(1.0, forKey: "exchangeRate")
                    transactionSave.setValue("", forKey: "tags")
                    transactionSave.setValue(isSave, forKey: "isSave")
                    transactionSave.setValue(0, forKey: "isSplit")
                    transactionSave.setValue(!isSave, forKey: "isLiquid")
                }
            } else {
                saveInitialTransaction(amount: amount, isSave: isSave, categoryID: selectedCategoryDetail)
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return
        }
    }
    
    // MARK: LOAD
    func loadBulkDataWithQuery(entitie:String, query:NSPredicate) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return [NSManagedObject]()
    }
    
    func loadBulkDataSorted(entitie:String, sort:[NSSortDescriptor]) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = sort
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return [NSManagedObject]()
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
    
    func loadNextCategoryID() -> Int16 {
        var i:Int16 = 0
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
        fetchRequest.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Categories.cID), ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let loadCategories = try managedContext.fetch(fetchRequest) as! [Categories]
            for data in loadCategories {
                if data.cID == i {
                    i = i + 1
                } else {
                    break
                }
            }
        } catch {
            print("Could not fetch. \(error)")
        }
        return i
    }
    
    func saveQueriedAttribute(entity: String, attribute: String, query: NSPredicate ,value: Any) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        do {
            let fetchedData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if fetchedData.count > 1 || fetchedData.count <= 0 {
                return
            } else {
                fetchedData[0].setValue(value, forKey: attribute)
                try managedContext.save()
                return
            }
        } catch {
            fatalError("Failed to fetch recordings: \(error)")
        }
    }
    
    func saveQueriedAttributeMultiple(entity: String, attribute: String, query: NSPredicate ,value: Any) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.newBackgroundContext()
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        do {
            let fetchedData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if fetchedData.count <= 0 {
                return
            } else {
                for data in fetchedData {
                    data.setValue(value, forKey: attribute)
                }
                try managedContext.save()
            }
        } catch {
            fatalError("Failed to fetch recordings: \(error)")
        }
    }
    
    // MARK: DELETE
    func deleteData(entity: String, query: NSPredicate) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = query
        do {
            let delete = try managedContext.fetch(fetchRequest)
            for data in delete {
                managedContext.delete(data as! NSManagedObject)
            }
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } catch {
            print(error)
        }
    }
}

extension categoryTVC: cellCategoryInitialDelegate {
    func infoButtonPressed() {
        let infoText = NSLocalizedString("categoryInitialInfoText", comment: "Info Text")
        let infoTitle = NSLocalizedString("categoryInitialInfoTitle", comment: "Info")
        let infoPrompt = UIAlertController(title: infoTitle, message: infoText, preferredStyle: .alert)

        infoPrompt.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "Ok"), style: .default, handler: nil))
        
        infoPrompt.popoverPresentationController?.sourceView = self.view
        infoPrompt.popoverPresentationController?.sourceRect = self.view.bounds
        
        self.present(infoPrompt, animated: true)
    }
    
    func textFieldEdited(text: String) {
        let thSep:String = Locale.current.groupingSeparator ?? ","
        let currencySymbol = Locale.current.currencySymbol ?? "€"
        
        categoryData[6] = numberFormatter.number(from: (text).replacingOccurrences(of: thSep, with: "").replacingOccurrences(of: currencySymbol, with: ""))
        if let cell = categoryTable.cellForRow(at: IndexPath(row: 2, section: 0)) as? cellCategoryInitial {
            cell.textField.text = amountFormatter.string(from: NSNumber(value: categoryData[6] as? Double ?? 0.00))
        }
    }
}

extension categoryTVC: cellCategoryMainDelegate {
    func categoryTypeSegmentChanged(selectedSegment: Int) {
        if selectedSegment == 0 {
            categoryData[1] = false
        } else {
            categoryData[1] = true
        }
    }
    
    func updateText(newText: String) {
        categoryData[0] = newText
    }
}

extension categoryTVC: cellCategorySaveDelegate {
    func saveSwitchChanged(newState:Bool) {
        categoryData[1] = false
        categoryData[2] = newState
        if newState {
            if categoryTable.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
                categoryTable.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }
        } else {
            if categoryTable.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
                categoryTable.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }
        }
    }
}

extension categoryTVC: cellCategoryColorDelegate {
    func colorChanged(newColor: Int16) {
        categoryData[3] = newColor
    }
}

extension categoryTVC: cellCategoryAddDelegate {
    func addButtonPressed() {
        if let cell = categoryTable.cellForRow(at: IndexPath(row: 2, section: 0)) as? cellCategoryInitial {
            let thSep:String = Locale.current.groupingSeparator ?? ","
            categoryData[6] = amountFormatter.number(from: (cell.textField.text)?.replacingOccurrences(of: thSep, with: "") ?? "0.00")
        }
        
        reloadAddView = true
        if selectedCategoryDetail == -1 {
            if saveNewCategory() {
                updateCategoryOrder()
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "categoryChanged")))
                NotificationCenter.default.post(name: Notification.Name("updateFinVC"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            if updateCategory() {
                updateCategoryOrder()
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "categoryChanged")))
                NotificationCenter.default.post(name: Notification.Name("updateFinVC"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
        reloadListView = true
        reloadFinView = true
        reloadGraphView = true
    }
}
