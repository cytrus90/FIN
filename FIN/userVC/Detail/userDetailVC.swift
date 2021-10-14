//
//  userDetailVC.swift
//  FIN
//
//  Created by Florian Riel on 12.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import MessageUI
import StoreKit

// MARK: CATEGORY VARIABLES
var selectedCategoryDetail:Int16 = -1

class userDetailVC: UITableViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet var userDetailTable: UITableView!
    
    let dateFormatter = ISO8601DateFormatter()
    
    let activityIndicator = UIActivityIndicatorView()
    
    let headerHeightFactor = CGFloat(0.05)
    
    var selectedRow: String?
    var selectedRowForCells: Int?
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    
    // Bottom Bar for re-Ordering of Categories
    var categoryBottomBar:categoryBottomBar = {
        let nib = UINib(nibName: "categoriesBottomBar", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! categoryBottomBar
    }()
    var widthAnchorConstraintBottomBar: NSLayoutConstraint?
    var bottomAnchorConstraintBottomBar: NSLayoutConstraint?
    
    var selectedSegmentOrderCategories = 0
    
    var removeIDs = [Int]()
    
    var numberOfSections: Int = 1
    
    // MARK: CATEGORY VARIABLES
    
    // MARK: EXPORT/IMPORT VARIABLES
    let exportIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    let importIndexPath: IndexPath = IndexPath(row: 1, section: 0)
    
    // MARK: SETTINGS VARIABLES
    var userDetailCells = [Int:Any]()
    var codeIsSet: Bool = false
    let setCodeCellIndexPath: IndexPath = IndexPath(row: 1, section: 0)
    
    var userDetailCellsTmp = [Int:Any]()
    
    var numberFormatter = NumberFormatter()
    var mediumDate = DateFormatter()
    
    // In-App
    var productsArray: Array<SKProduct> = []
    
    var selectedProductIndex: Int!
    var transactionInProgress = false
    var canPerformPurchase = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Keyboard dismiss
        userDetailTable.keyboardDismissMode = .onDrag
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(categoryChanged), name: Notification.Name("categoryChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(detailListDisappeared), name: Notification.Name("detailListDisappeared"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userIconColorChanges(notification:)), name: Notification.Name("userIconColorChanges"), object: nil)
        
        if selectedRowForCells == 0 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRegularPaymentTabbed))
            NotificationCenter.default.addObserver(self, selector: #selector(transactionUpdated(notification:)), name: Notification.Name("transactionUpdated"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(transactionDeleted), name: Notification.Name("transactionDeleted"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(transactionDeleted), name: Notification.Name("transactionAdded"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(transactionDeleted), name: Notification.Name("splitSettled"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(transactionDeleted), name: Notification.Name("updateFinVC"), object: nil)
        }
        
        if showAdds {
            if selectedRowForCells == 1 {
                checkForCategoryNameDuplicates()
                checkForCategoryDuplicates()
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailed), name: Notification.Name("purchaseFailed"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(purchaseDone), name: Notification.Name("purchaseDone"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(purchaseRestored), name: Notification.Name("purchaseRestored"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(restoreNotFound), name: Notification.Name("restoreNotFound"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(purchaseFinished), name: Notification.Name("purchaseFinished"), object: nil)
            
            PKIAPHandler.shared.setProductIds(ids: ["removeads.alpako.fin"])
            PKIAPHandler.shared.fetchAvailableProducts { [weak self](products) in
               guard let sSelf = self else {return}
               sSelf.productsArray = products
               //sSelf.tableView.reloadData() //reload you table or collection view
            }
            canPerformPurchase = PKIAPHandler.shared.canMakePurchases()
        }
        
        numberFormatter.numberStyle = .decimal
//        numberFormatter.locale = .current
        
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = Locale.current.groupingSeparator
        numberFormatter.groupingSize = 3
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        mediumDate.dateStyle = .medium
        
        initCells(selectedRowForCells: selectedRowForCells ?? 0)
        initView(table: userDetailTable)
        userDetailTable.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        if reloadCategoryView {
            reloadCategoryView = false
            categoryChanged()
        }
        if selectedRowForCells == 3 {
            initCells(selectedRowForCells: selectedRowForCells ?? 0)
            userDetailTable.reloadData()
        }
        initRows(clearRows: true)
        
        if (dataHandler.loadBulkData(entitie: "Categories", orderBy: "cID")).count <= 0 && selectedRowForCells == 1 {
            initCategories()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            userDetailTable.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
        } else {
            userDetailTable.backgroundColor = .secondarySystemBackground
            headerView.backgroundColor = .secondarySystemBackground
        }
        userDetailTable.reloadData()
    }
    
    
    @objc func categoryChanged() {
        self.title = ""
        initCells(selectedRowForCells: selectedRowForCells ?? 0)
        initView(table: userDetailTable)
        userDetailTable.reloadData()
        self.view.layoutIfNeeded()
    }
    
    @objc func detailListDisappeared() {
        initRows(clearRows: true)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDetailCells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath) as! subtitleCellTVC
        cell.subtitleLabel.text = ""
        
        switch selectedRowForCells {
        case 0: // Repeated Payments
            if (((userDetailCells[indexPath.row]) as? [Int:Any])?[9] as? Bool ?? false) {
                return getSubtitleCell(indexPath: indexPath)
            } else {
                return getRegularPaymentCell(indexPath: indexPath)
            }
        case 1: // Categories
            if (((userDetailCells[indexPath.row]) as? [Int:Any])?[9] as? Bool ?? false) {
                return getSubtitleCategoryCell(indexPath: indexPath)
            } else {
                return getCategoryCells(indexPath: indexPath)
            }
        case 2: // Export / Import
            return getExportImportCells(indexPath: indexPath)
        case 3: // Settings
            switch indexPath.row {
            case 0:
                return getSettingsTextCell(indexPath: indexPath)
            case 1:
//                if loginEnabled {
                    return getSettingsGeneralCell(indexPath: indexPath)
//                } else {
//                    return getCutOffCell(indexPath: indexPath)
//                }
            default:
                return getCutOffCell(indexPath: indexPath)
            }
        case 4: // About
            if indexPath.row == 0 {
                return getAboutTitleCell(indexPath: indexPath)
            } else {
                return getAboutTextCell(indexPath: indexPath)
            }
        default:
            break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedRowForCells == 0 { // Regular Payments
            initRows(indexPathSelected: indexPath)
            
            let listStoryBoard: UIStoryboard = UIStoryboard(name: "listTSB", bundle: nil)
            let transactionVC = listStoryBoard.instantiateViewController(withIdentifier: "TransactionDetail") as! listDetailTVC
            
            transactionVC.superRegularPayment = true
            transactionVC.dateOfSelectedRow = ((userDetailCells[indexPath.row] as? [Int:Any])?[4] as? Date ?? Date())
            
            let navigationVC = UINavigationController(rootViewController: transactionVC)
            self.present(navigationVC, animated: true, completion: nil)
        } else if indexPath == exportIndexPath && selectedRowForCells == 2 { // Export
            if showAdds {
                let purchaseText = NSLocalizedString("purchaseText", comment: "Unlock Features Text")
                let purchaseTitle = NSLocalizedString("purchaseTitle", comment: "Unlock Features Title")
                let purchasePrompt = UIAlertController(title: purchaseTitle, message: purchaseText, preferredStyle: .alert)

                purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteYes", comment: "Delete Yes"), style: .cancel, handler: { action in
                    self.purchaseButtonPressed()
                }))
                purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteNo", comment: "Delete No"), style: .default, handler: nil))
                
                purchasePrompt.popoverPresentationController?.sourceView = self.view
                purchasePrompt.popoverPresentationController?.sourceRect = self.view.bounds
                
                self.present(purchasePrompt, animated: true)
            } else {
                initRows(indexPathSelected: indexPath)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "exportSeque", sender: nil)
                }
            }
        } else if indexPath == importIndexPath && selectedRowForCells == 2 { // Import
            if showAdds {
                let purchaseText = NSLocalizedString("purchaseText", comment: "Unlock Features Text")
                let purchaseTitle = NSLocalizedString("purchaseTitle", comment: "Unlock Features Title")
                let purchasePrompt = UIAlertController(title: purchaseTitle, message: purchaseText, preferredStyle: .alert)

                purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteYes", comment: "Delete Yes"), style: .cancel, handler: { action in
                    self.purchaseButtonPressed()
                }))
                purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteNo", comment: "Delete No"), style: .default, handler: nil))
                
                purchasePrompt.popoverPresentationController?.sourceView = self.view
                purchasePrompt.popoverPresentationController?.sourceRect = self.view.bounds
                
                self.present(purchasePrompt, animated: true)
            } else {
                initRows(indexPathSelected: indexPath)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "importSeque", sender: nil)
                }
            }
        } else if indexPath == setCodeCellIndexPath && selectedRowForCells == 3 && loginEnabled { // Settings
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "setCodeSeque", sender: nil)
            }
        } else if selectedRowForCells == 1 { // Category
            if userDetailTable.cellForRow(at: indexPath) as? cellDetailCategory != nil {
//                if !showAdds {
//                    let purchaseText = NSLocalizedString("purchaseText", comment: "Unlock Features Text")
//                    let purchaseTitle = NSLocalizedString("purchaseTitle", comment: "Unlock Features Title")
//                    let purchasePrompt = UIAlertController(title: purchaseTitle, message: purchaseText, preferredStyle: .alert)
//
//                    purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteYes", comment: "Delete Yes"), style: .cancel, handler: { action in
//                        self.purchaseButtonPressed()
//                    }))
//                    purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteNo", comment: "Delete No"), style: .default, handler: nil))
//
//                    purchasePrompt.popoverPresentationController?.sourceView = self.view
//                    purchasePrompt.popoverPresentationController?.sourceRect = self.view.bounds
//
//                    self.present(purchasePrompt, animated: true)
//                } else {
                    initRows(indexPathSelected: indexPath)
                    selectedCategoryDetail = (userDetailCells[indexPath.row] as? [Int:Any])?[0] as? Int16 ?? -1
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toCategoryTCVSeque", sender: nil)
//                    }
                }
            }
        }
    }
    
    // Reodering of Categories
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update Order within Group -> j
        // Also update position within Table -> exchange i
        let des_i = (userDetailCells[destinationIndexPath.row] as? [Int:Any])?[7] as? Int
        
        var newOld = [Int:Int]() // [Int_new:Int_old] -> Position within the main table
        
        if sourceIndexPath.row < destinationIndexPath.row { // #1
            for k in sourceIndexPath.row...destinationIndexPath.row {
                if k == sourceIndexPath.row {
                    var dictRam = userDetailCells[k] as? [Int:Any]
                    newOld[destinationIndexPath.row] = dictRam?[7] as? Int ?? 0
                    dictRam?[6] = destinationIndexPath.row
                    dictRam?[7] = des_i
                    userDetailCells[k] = dictRam
                } else {
                    var dictRam = userDetailCells[k] as? [Int:Any]
                    dictRam?[6] = k - 1
                    let i_RAM = ((dictRam?[7] as? Int ?? 1) - 1)
                    newOld[k - 1] = (userDetailCells[k] as? [Int:Any])?[7] as? Int ?? 0
                    dictRam?[7] = i_RAM
                    userDetailCells[k] = dictRam
                }
            }
        } else { // #2
            for k in destinationIndexPath.row...sourceIndexPath.row {
                if k == sourceIndexPath.row {
                    var dictRam = userDetailCells[k] as? [Int:Any]
                    newOld[destinationIndexPath.row] = dictRam?[7] as? Int ?? 0
                    dictRam?[6] = destinationIndexPath.row
                    dictRam?[7] = des_i
                    userDetailCells[k] = dictRam
                } else {
                    var dictRam = userDetailCells[k] as? [Int:Any]
                    dictRam?[6] = k + 1
                    let i_RAM = ((dictRam?[7] as? Int ?? 1) + 1)
                    newOld[k + 1] = (userDetailCells[k] as? [Int:Any])?[7] as? Int ?? 0
                    dictRam?[7] = i_RAM
                    userDetailCells[k] = dictRam
                }
            }
        }

        var userDetailCellsTmp2 = userDetailCells
        userDetailCells.removeAll()
        for (_,value) in userDetailCellsTmp2.enumerated() {
            userDetailCells[((value.value as? [Int:Any])?[6] as? Int ?? 0)] = value.value
        }
        
        for (_,value) in newOld.enumerated() {
            userDetailCellsTmp[value.value] = userDetailCells[value.key]
        }
        
        userDetailCellsTmp2.removeAll()
        userDetailCellsTmp2 = userDetailCellsTmp
        for (_,value) in userDetailCellsTmp2.enumerated() {
            userDetailCellsTmp[((value.value as? [Int:Any])?[7] as? Int ?? 0)] = value.value
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if (userDetailCells[indexPath.row] as? [Int:Any])?[9] as? Bool ?? false {
            return false
        } else {
            return true
        }
    }
    
    // MARK: -CELL FUNCTIONS
    func initCells(selectedRowForCells: Int) {
        switch selectedRowForCells {
        case 0: // Regular Payments
            numberOfSections = 1
            userDetailCells.removeAll()
            
            let dateTimeNextSort = NSSortDescriptor(key: "dateTimeNext", ascending: true)
            let frequencySort = NSSortDescriptor(key: "frequency", ascending: true)
            
            var i = 0
            var prevFreq:Int16 = -1
            
            for repeatingTransaction in dataHandler.loadBulkSorted(entitie: "RegularPayments", sort: [dateTimeNextSort,frequencySort]) {
                let categoryQuery = NSPredicate(format: "cID == %i", (repeatingTransaction.value(forKey: "categoryID") as? Int16 ?? 0))
                let categoryName = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: categoryQuery) as? String ?? ""
                let categoryColor = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "color", query: categoryQuery) as? Int16 ?? 0
                let categoryIsSave = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isSave", query: categoryQuery) as? Bool ?? false
                let categoryIcon = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "icon", query: categoryQuery) as? String ?? ""
                let categoryIconLight = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "iconLight", query: categoryQuery) as? Bool ?? false
                
                let datePlus = Calendar.current.date(byAdding: .second, value: 1, to: repeatingTransaction.value(forKey: "dateTimeNext") as? Date ?? Date())!
                let dateMinus = Calendar.current.date(byAdding: .second, value: -1, to: repeatingTransaction.value(forKey: "dateTimeNext") as? Date ?? Date())!
                
                let splitQuery = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", datePlus as NSDate, dateMinus as NSDate)
                let splitSort = NSSortDescriptor(key: "dateTimeTransaction", ascending: true)
                var isSplit:Int16 = 0
                for split in dataHandler.loadBulkQueriedSorted(entitie: "SplitsRegularPayments", query: splitQuery, sort: [splitSort]) {
                    
                    if (split.value(forKey: "nameGroup") as? String ?? "").count > 0 {
                        isSplit = 2
                    } else {
                        isSplit = 1
                    }
                    break
                }
                
                if prevFreq != (repeatingTransaction.value(forKey: "frequency") as? Int16 ?? 0) {
                    let ramDict = [
                        3:(repeatingTransaction.value(forKey: "frequency") as? Int16 ?? 0),
                        9:true
                    ] as [Int : Any]
                    userDetailCells[i] = ramDict
                    i = i + 1
                    prevFreq = (repeatingTransaction.value(forKey: "frequency") as? Int16 ?? 0)
                }
                
                let dictRAM = [
                    0:(repeatingTransaction.value(forKey: "realAmount") as? Double) ?? 0.00,
                    1:getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€",
                    2:(repeatingTransaction.value(forKey: "descriptionNote") as? String) ?? "",
                    3:(repeatingTransaction.value(forKey: "frequency") as? Int16 ?? 0),
                    4:(repeatingTransaction.value(forKey: "dateTimeNext") as? Date ?? Date()) as Any,
                    5:isSplit,
                    6:categoryName,
                    7:categoryColor,
                    8:categoryIsSave,
                    9:false,
                    10:categoryIcon,
                    11:categoryIconLight
                ] as [Int : Any]
                userDetailCells[i] = dictRAM
                i = i + 1
            }
            
            if userDetailCells.count <= 0 {
                let ramDict = [
                    3:Int16(4),
                    9:true
                ] as [Int : Any]
                userDetailCells[0] = ramDict
            }
            break
        case 1: // Categories
//            saveCategoryWithID(name: "BAD", isIncome: false, isSave: false)
            numberOfSections = 1
            userDetailCells.removeAll()
            
            var countData = dataHandler.loadDataGrouped(entitie: "Transactions", groupByColumn: "categoryID") as? [[String:Any]]

            var j:Int = 0 // order within Group (expenses, income, savings)
            var i = 0 // order within Table
            
            let ramDict0 = [
                3:0,
                7:i,
                9:true
            ] as [Int : Any]
            userDetailCells[i] = ramDict0
            i = i + 1
            // Get Expenses
            let predicateExpenses:NSPredicate = NSPredicate(format: "isIncome == false && isSave == false")
            let expenses = dataHandler.loadBulkDataWithQuery(entitie: "Categories", query: predicateExpenses)
            if expenses.count > 0 {
                for expense in expenses {
                    var numberExpensesInCategory:Int64 = 0
                    if (countData?.count ?? 0) > 0 {
                        for j in 0...((countData?.count ?? 1)-1) {
                            if (countData?[j]["categoryID"] as? Int16 ?? 0) == expense.value(forKey: "cID") as? Int16 ?? 0 {
                                numberExpensesInCategory = (countData?[j]["count"] as? Int64 ?? 0)
                                let querySaveCatNumber = NSPredicate(format: "cID == %i", (expense.value(forKey: "cID") as? Int16 ?? 0))
                                dataHandler.saveSingleDataInt64(entity: "Categories", attibute: "countEntries", newValue: Int64(numberExpensesInCategory), query: querySaveCatNumber)
                                countData?.remove(at: j)
                                break
                            }
                        }
                    }
                    
                    let dictRAM = [
                        0:expense.value(forKey: "cID") as? Int16 ?? 0,
                        1:expense.value(forKey: "name") as? String ?? "",
                        2:Int64(numberExpensesInCategory),
                        3:expense.value(forKey: "color") as? Int16 ?? 0,
                        4:expense.value(forKey: "isIncome") as? Bool ?? false,
                        5:expense.value(forKey: "isSave") as? Bool ?? false,
                        6:j,
                        7:i,
                        8:expense.value(forKey: "icon") as? String ?? "",
                        10:expense.value(forKey: "iconLight") as? Bool ?? true
                    ] as [Int : Any]
                    userDetailCells[i] = dictRAM
                    i = i + 1
                    j = j + 1
                }
            }
            // Get Income
            j = 0
            let ramDict2 = [
                3:1,
                7:i,
                9:true
            ] as [Int : Any]
            userDetailCells[i] = ramDict2
            i = i + 1
            
            let predicateIncome:NSPredicate = NSPredicate(format: "isIncome == true && isSave == false")
            let incomes = dataHandler.loadBulkDataWithQuery(entitie: "Categories", query: predicateIncome)
            if incomes.count > 0 {
                for income in incomes {
                    var numberIncomeInCategory:Int64 = 0
                    if (countData?.count ?? 0) > 0 {
                        for j in 0...((countData?.count ?? 1)-1) {
                            if (countData?[j]["categoryID"] as? Int16 ?? 0) == income.value(forKey: "cID") as? Int16 ?? 0 {
                                numberIncomeInCategory = (countData?[j]["count"] as? Int64 ?? 0)
                                let querySaveCatNumber = NSPredicate(format: "cID == %i", (income.value(forKey: "cID") as? Int16 ?? 0))
                                dataHandler.saveSingleDataInt64(entity: "Categories", attibute: "countEntries", newValue: Int64(numberIncomeInCategory), query: querySaveCatNumber)
                                countData?.remove(at: j)
                                break
                            }
                        }
                    }
                    let dictRAM = [
                        0:income.value(forKey: "cID") as? Int16 ?? 0,
                        1:income.value(forKey: "name") as? String ?? "",
                        2:Int64(numberIncomeInCategory),
                        3:income.value(forKey: "color") as? Int16 ?? 0,
                        4:income.value(forKey: "isIncome") as? Bool ?? true,
                        5:income.value(forKey: "isSave") as? Bool ?? false,
                        6:j,
                        7:i,
                        8:income.value(forKey: "icon") as? String ?? "",
                        10:income.value(forKey: "iconLight") as? Bool ?? true
                    ] as [Int : Any]
                    userDetailCells[i] = dictRAM
                    i = i + 1
                    j = j + 1
                }
            }
            
            let ramDict3 = [
                3:2,
                7:i,
                9:true
            ] as [Int : Any]
            userDetailCells[i] = ramDict3
            i = i + 1
            j = 0
            // Get Save Deposit
            let predicateSaveDeposit:NSPredicate = NSPredicate(format: "isIncome == false && isSave == true")
            let savesDeposit = dataHandler.loadBulkDataWithQuery(entitie: "Categories", query: predicateSaveDeposit)
            if savesDeposit.count > 0 {
                for save in savesDeposit {
                    var numberSavingsInCategory:Int64 = 0
                    if (countData?.count ?? 0) > 0 {
                        for j in 0...((countData?.count ?? 1)-1) {
                            if (countData?[j]["categoryID"] as? Int16 ?? 0) == save.value(forKey: "cID") as? Int16 ?? 0 {
                                numberSavingsInCategory = (countData?[j]["count"] as? Int64 ?? 0)
                                let querySaveCatNumber = NSPredicate(format: "cID == %i", (save.value(forKey: "cID") as? Int16 ?? 0))
                                dataHandler.saveSingleDataInt64(entity: "Categories", attibute: "countEntries", newValue: Int64(numberSavingsInCategory), query: querySaveCatNumber)
                                countData?.remove(at: j)
                                break
                            }
                        }
                    }
                    let dictRAM = [
                        0:save.value(forKey: "cID") as? Int16 ?? 0,
                        1:save.value(forKey: "name") as? String ?? "",
                        2:Int64(numberSavingsInCategory),
                        3:save.value(forKey: "color") as? Int16 ?? 0,
                        4:save.value(forKey: "isIncome") as? Bool ?? false,
                        5:save.value(forKey: "isSave") as? Bool ?? true,
                        6:j,
                        7:i,
                        8:save.value(forKey: "icon") as? String ?? "",
                        10:save.value(forKey: "iconLight") as? Bool ?? true
                    ] as [Int : Any]
                    userDetailCells[i] = dictRAM
                    i = i + 1
                    j = j + 1
                }
            }
            // Get Save Withdraw
            let predicateSaveWithdraw:NSPredicate = NSPredicate(format: "isIncome == true && isSave == true")
            let savesWithdraw = dataHandler.loadBulkDataWithQuery(entitie: "Categories", query: predicateSaveWithdraw)
            if savesWithdraw.count != 0 {
                for save in savesWithdraw {
                    var numberSavingsInCategory:Int64 = 0
                    if (countData?.count ?? 0) > 0 {
                        for j in 0...((countData?.count ?? 1)-1) {
                            if (countData?[j]["categoryID"] as? Int16 ?? 0) == save.value(forKey: "cID") as? Int16 ?? 0 {
                                numberSavingsInCategory = (countData?[j]["count"] as? Int64 ?? 0)
                                let querySaveCatNumber = NSPredicate(format: "cID == %i", (save.value(forKey: "cID") as? Int16 ?? 0))
                                dataHandler.saveSingleDataInt64(entity: "Categories", attibute: "countEntries", newValue: Int64(numberSavingsInCategory), query: querySaveCatNumber)
                                countData?.remove(at: j)
                                break
                            }
                        }
                    }
                    let dictRAM = [
                        0:save.value(forKey: "cID") as? Int16 ?? 0,
                        1:save.value(forKey: "name") as? String ?? "",
                        2:numberSavingsInCategory,
                        3:save.value(forKey: "color") as? Int16 ?? 0,
                        4:save.value(forKey: "isIncome") as? Bool ?? false,
                        5:save.value(forKey: "isSave") as? Bool ?? true,
                        6:j,
                        7:i,
                        8:save.value(forKey: "icon") as? String ?? "",
                        10:save.value(forKey: "iconLight") as? Bool ?? true
                    ] as [Int : Any]
                    userDetailCells[i] = dictRAM
                    i = i + 1
                    j = j + 1
                }
            }
            
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategoryTabbed))
            let orderButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(reorderCategories))
            
            navigationItem.rightBarButtonItems = [addButton,orderButton]
            break
        case 2: // Export / Import
            numberOfSections = 1
            userDetailCells.removeAll()
            
            userDetailCells[0] = NSLocalizedString("Export", comment: "Export Title")
            userDetailCells[1] = NSLocalizedString("Import", comment: "Import Title")
            break
        case 3: // Settings
            numberOfSections = 1
            userDetailCells.removeAll()
            // Get Data
            checkSettingsDuplicates()
            
            let userName = dataHandler.loadData(entitie: "Settings", attibute: "userName") as? String ?? NSLocalizedString("userTitle", comment: "User VC Title")
            let recoveryMail = dataHandler.loadData(entitie: "Settings", attibute: "recoveryMail") as? String ?? ""
            let loginEnabled = dataHandler.loadData(entitie: "Settings", attibute: "loginEnabled") as? Bool ?? false
            if (dataHandler.loadData(entitie: "Settings", attibute: "userCode") as? String ?? "").count <= 0 || (dataHandler.loadData(entitie: "Settings", attibute: "userCode") as? String ?? "").count <= 0 {
                codeIsSet = false
            } else {
                codeIsSet = true
            }
            
            let queryUserPerson = NSPredicate(format: "isUser == true")
            let iconUser = dataHandler.loadQueriedAttribute(entitie: "SplitPersons", attibute: "icon", query: queryUserPerson) as? String ?? ""
            let iconLightUser = dataHandler.loadQueriedAttribute(entitie: "SplitPersons", attibute: "iconLight", query: queryUserPerson) as? Bool ?? true
            let userColor = dataHandler.loadQueriedAttribute(entitie: "SplitPersons", attibute: "color", query: queryUserPerson) as? Int16 ?? 10
            
            // Create Dictionary
            let dictRAM = [
                0:userName,
                1:recoveryMail,
                2:loginEnabled,
                3:iconUser,
                4:iconLightUser,
                5:userColor
                ] as [Int : Any]
            
            userDetailCells[0] = dictRAM
            if codeIsSet && loginEnabled {
                userDetailCells[1] = codeIsSet
//                userDetailCells[2] = [
//                    0:(loadData(entitie: "Settings", attibute: "cutOffDate") as? Bool ?? false)
//                ] as [Int : Any]
            } else {
//                userDetailCells[1] = [
//                    0:(loadData(entitie: "Settings", attibute: "cutOffDate") as? Bool ?? false)
//                ] as [Int : Any]
            }
            break
        case 4: // About
            numberOfSections = 1
            userDetailCells.removeAll()
            
            let dictRAM1 = [
                0:"Title"
                ] as [Int : Any]
            userDetailCells[0] = dictRAM1
            
            let dictRAM2 = [
                0:"Text"
                ] as [Int : Any]
            userDetailCells[1] = dictRAM2
            
            break
        default:
            break
        }
    }
    
    func initRows(indexPathSelected: IndexPath = IndexPath(row: 0, section: 0), clearRows: Bool = false) {
        if selectedRowForCells == 0 || selectedRowForCells == 1 {
            for (row, _) in userDetailCells {
                let indexPathRAM: IndexPath = IndexPath(row: row, section: 0)
                if let cell = userDetailTable.cellForRow(at: indexPathRAM) as? cellDetailGeneralTVC {
                    let userInterfaceStyle = traitCollection.userInterfaceStyle
                    if userInterfaceStyle == .light {
                        cell.cellOutlineView.backgroundColor = .white
                        cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                    } else {
                        cell.cellOutlineView.backgroundColor = .black
                        cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
                    }
                } else if let cell = userDetailTable.cellForRow(at: indexPathRAM) as? cellDetailCategory {
                    let userInterfaceStyle = traitCollection.userInterfaceStyle
                    if userInterfaceStyle == .light {
                        cell.cellOutlineView.backgroundColor = .white
                        cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                    } else {
                        cell.cellOutlineView.backgroundColor = .black
                        cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
                    }
                }
            }
            if !clearRows {
                if let cell = userDetailTable.cellForRow(at: indexPathSelected) as? cellDetailGeneralTVC {
                    cell.cellOutlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                    cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                } else if let cell = userDetailTable.cellForRow(at: indexPathSelected) as? cellDetailCategory {
                    cell.cellOutlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                    cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                }
            }
        } else if selectedRowForCells == 2 || selectedRowForCells == 3 {
            for (row, _) in userDetailCells {
                let indexPathRAM: IndexPath = IndexPath(row: row, section: 0)
                if let cell = userDetailTable.cellForRow(at: indexPathRAM) as? cellDetailGeneral {
                    let userInterfaceStyle = traitCollection.userInterfaceStyle
                    if userInterfaceStyle == .light {
                        cell.cellOutlineView.backgroundColor = .white
                        cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                    } else {
                        cell.cellOutlineView.backgroundColor = .black
                        cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
                    }
                }
            }
            if !clearRows {
                if let cell = userDetailTable.cellForRow(at: indexPathSelected) as? cellDetailGeneral {
                    cell.cellOutlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                    cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                }
            }
        }
    }
    
    // MARK: -CELLS
    func getRegularPaymentCell(indexPath: IndexPath) -> cellDetailGeneralTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetailGeneralTVC", for: indexPath) as! cellDetailGeneralTVC
        
        cell.circleView.backgroundColor = UIColor.randomColor(color: Int(((userDetailCells[indexPath.row]) as? [Int:Any])?[7] as? Int16 ?? 0))
        cell.circleView.layer.borderColor = UIColor.randomColor(color: Int(((userDetailCells[indexPath.row]) as? [Int:Any])?[7] as? Int16 ?? 0)).cgColor
        
        if ((userDetailCells[indexPath.row] as? [Int:Any])?[10] as? String ?? "").count > 0 {
            cell.circleImage.isHidden = false
            cell.circleLabel.isHidden = true
            
            var selectedIcon = ((userDetailCells[indexPath.row] as? [Int:Any])?[10] as? String ?? "").replacingOccurrences(of: "_white", with: "")
            if ((userDetailCells[indexPath.row] as? [Int:Any])?[11] as? Bool ?? true) {
                selectedIcon = selectedIcon + "_white"
            }
            
            cell.circleImage.image = UIImage(named: selectedIcon)
        } else {
            cell.circleImage.isHidden = true
            cell.circleLabel.isHidden = false
            
            if ((userDetailCells[indexPath.row] as? [Int:Any])?[6] as? String ?? "").count == 1 {
                cell.circleLabel.text = ((userDetailCells[indexPath.row] as? [Int:Any])?[6] as? String ?? "").prefix(1).uppercased()
            } else {
                cell.circleLabel.text = ((userDetailCells[indexPath.row] as? [Int:Any])?[6] as? String ?? "").prefix(2).uppercased()
            }
            
            if ((userDetailCells[indexPath.row] as? [Int:Any])?[11] as? Bool ?? true) {
                cell.circleLabel.textColor = .white
            } else {
                cell.circleLabel.textColor = .black
            }
        }
        
        cell.amountLabel.text = ((userDetailCells[indexPath.row] as? [Int:Any])?[1] as? String ?? "") + " " + (numberFormatter.string(from: NSNumber(value: (userDetailCells[indexPath.row] as? [Int:Any])?[0] as? Double ?? 0.00)) ?? "0.00")
        
        cell.descriptionLabel.text = ((userDetailCells[indexPath.row] as? [Int:Any])?[2] as? String ?? "")
        
        cell.descriptionSubtitleLabel.text = (getDayForDate(dayDate: ((userDetailCells[indexPath.row] as? [Int:Any])?[4] as? Date ?? Date())))

        // NSLocalizedString("nextText", comment: "Next") + 
        
        if ((userDetailCells[indexPath.row] as? [Int:Any])?[8] as? Bool ?? false) { // isSave
            cell.icon.isHidden = false
            cell.icon.image = UIImage(named: "safe")?.withRenderingMode(.alwaysTemplate)
        } else if (((userDetailCells[indexPath.row]) as? [Int:Any])?[5] as? Int16 ?? 0) == 1 {
            cell.icon.isHidden = false
            cell.icon.image = UIImage(named: "tabPersonSelected")?.withRenderingMode(.alwaysTemplate)
        } else if (((userDetailCells[indexPath.row]) as? [Int:Any])?[5] as? Int16 ?? 0) == 2 {
            cell.icon.isHidden = false
            cell.icon.image = UIImage(named: "tabPersonsSelected")?.withRenderingMode(.alwaysTemplate)
        } else {
            cell.icon.isHidden = true
        }
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.cellOutlineView.addInteraction(interaction)
        cell.cellOutlineView.tag = indexPath.row
        
        return cell
    }
    
    func getSubtitleCell(indexPath: IndexPath) -> subtitleCellTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath) as! subtitleCellTVC
        
        var str:String?
        switch ((userDetailCells[indexPath.row] as? [Int:Any])?[3] as? Int16 ?? 0) {
        case 0: // Weekly
            str = NSLocalizedString("bottomSegmentRepeatWeekly", comment: "weekly")
            break
        case 1: // Monthly
            str = NSLocalizedString("bottomSegmentRepeatMonthly", comment: "monthly")
            break
        case 2: // Yearly
            str = NSLocalizedString("bottomSegmentRepeatYearly", comment: "yearly")
            break
        case 4:
            str = NSLocalizedString("noRegularPayment", comment: "No Payments")
        default: // Daily
            str = NSLocalizedString("bottomSegmentRepeatDaily", comment: "daily")
            break
        }
        
        cell.subtitleLabel.text = str
        
        return cell
    }
    
    func getCategoryCells(indexPath: IndexPath) -> cellDetailCategory {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetailCategory", for: indexPath) as! cellDetailCategory
        var light = false
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            light = true
        } else {
            light = false
        }
        
        let dict = userDetailCells[indexPath.row] as? [Int:Any]

        cell.cellTopLabel.text = dict?[1] as? String ?? ""
        cell.cellBottomLabel.text = "#Entries: " + String((dict?[2]) as? Int64 ?? 0)
        
        if dict?[4] as? Bool ?? false && !(dict?[5] as? Bool ?? false) {
            if light {
                cell.cellTopIcon.image = UIImage(named: "iconPlusBlack")?.withRenderingMode(.alwaysTemplate)
            } else {
                cell.cellTopIcon.image = UIImage(named: "iconPlusWhite")?.withRenderingMode(.alwaysTemplate)
            }
//            cell.cellTopIcon.image = UIImage(systemName: "arrow.down")
        } else {
            if light {
                cell.cellTopIcon.image = UIImage(named: "iconMinusBlack")?.withRenderingMode(.alwaysTemplate)
            } else {
                cell.cellTopIcon.image = UIImage(named: "iconMinusWhite")?.withRenderingMode(.alwaysTemplate)
            }
//            cell.cellTopIcon.image = UIImage(systemName: "arrow.up")
        }
        
        if dict?[5] as? Bool ?? false {
            cell.cellBottomIcon.isHidden = true
            if light {
                cell.cellTopIcon.image = UIImage(named: "safeBlack")?.withRenderingMode(.alwaysTemplate)
            } else {
                cell.cellTopIcon.image = UIImage(named: "safeWhite")?.withRenderingMode(.alwaysTemplate)
            }
        } else {
            cell.cellBottomIcon.isHidden = true
        }
        // cell.cellOutlineView.layer.borderColor = UIColor.randomColor(color: Int(dict?[3] as? Int16 ?? 0), returnText: false, light: light).cgColor
         
        cell.circleView.backgroundColor = UIColor.randomColor(color: Int(dict?[3] as? Int16 ?? 0))
        cell.circleView.layer.borderColor = UIColor.randomColor(color: Int(dict?[3] as? Int16 ?? 0)).cgColor
        
        if (dict?[8] as? String ?? "").count > 0 {
            cell.circleLabel.isHidden = true
            cell.circleImage.isHidden = false
            
            var selectedIconString = (dict?[8] as? String ?? "").replacingOccurrences(of: "_white", with: "")
            if (dict?[10] as? Bool ?? true) {
                selectedIconString = selectedIconString + "_white"
            }
            
            cell.circleImage.image = UIImage(named: selectedIconString)
        } else {
            cell.circleImage.isHidden = true
            cell.circleLabel.isHidden = false
            
            if (dict?[1] as? String)?.count == 1 {
                cell.circleLabel.text = (dict?[1] as? String)?.prefix(1).uppercased()
            } else {
                cell.circleLabel.text = (dict?[1] as? String)?.prefix(2).uppercased()
            }
            if (dict?[10] as? Bool ?? true) {
                cell.circleLabel.textColor = .white
            } else {
                cell.circleLabel.textColor = .black
            }
        }
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.cellOutlineView.addInteraction(interaction)
        
        return cell
    }
    
    func getSubtitleCategoryCell(indexPath: IndexPath) -> subtitleCellTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath) as! subtitleCellTVC
        
        var str:String?
        switch ((userDetailCells[indexPath.row] as? [Int:Any])?[3] as? Int ?? 0) {
        case 0:
            str = NSLocalizedString("subtitleExpensesLabel", comment: "Expenses")
            break
        case 1:
            str = NSLocalizedString("subtitleEarningsLabel", comment: "Income")
            break
        case 2:
            str = NSLocalizedString("subtitleSavingsLabel", comment: "Savings")
            break
        default:
            str = ""
            break
        }
        
        cell.subtitleLabel.text = str
        
        return cell
    }
    
    func getExportImportCells(indexPath: IndexPath) -> cellDetailGeneral {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetailGeneral", for: indexPath) as! cellDetailGeneral
        
        cell.cellLabel.text = userDetailCells[indexPath.row] as? String ?? ""
        
        switch indexPath.row {
        case 1:
            cell.cellImageLabel.image = UIImage(systemName: "arrow.down.doc")?.withRenderingMode(.alwaysTemplate)
            break
        default:
            cell.cellImageLabel.image = UIImage(systemName: "arrow.up.doc")?.withRenderingMode(.alwaysTemplate)
            break
        }
        return cell
    }
    
    func getSettingsGeneralCell(indexPath: IndexPath) -> cellDetailGeneral {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellDetailGeneral", for: indexPath) as! cellDetailGeneral
        
        if userDetailCells[1] as? Bool ?? false {
            cell.cellLabel.text = NSLocalizedString("cellCodeSetText", comment: "Code already Set")
        } else {
            cell.cellLabel.text = NSLocalizedString("cellCodeNotSetText", comment: "Code Not Set")
        }
        cell.cellImageLabel.image = UIImage(named: "key")?.withRenderingMode(.alwaysTemplate)
        return cell
    }
    
    func getSettingsTextCell(indexPath: IndexPath) -> cellUserSettings {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSettingsText", for: indexPath) as! cellUserSettings
        let dict = userDetailCells[0] as! [Int:Any]
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            cell.backgroundColor = backgroundGeneralColor
            cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            cell.backgroundColor = .secondarySystemBackground
            cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
        
        cell.cellUsernameText.tag = 0
        cell.cellRecoveryText.tag = 1
        
        cell.cellUsernameText.text = dict[0] as? String ?? NSLocalizedString("userTitle", comment: "User VC Title")
        cell.cellRecoveryText.text = dict[1] as? String ?? ""
        if dict[2] as? Bool ?? false {
            cell.cellLoginSwitch.isOn = true
        }
        
        cell.cellRecoveryText.placeholder = NSLocalizedString("recoveryEmailPlaceholder", comment: "Placeholder")
        
        cell.circleView.backgroundColor = UIColor.randomColor(color: Int(dict[5] as? Int16 ?? 10))
        cell.circleView.layer.borderColor = UIColor.randomColor(color: Int(dict[5] as? Int16 ?? 10)).cgColor
        
        if (dict[3] as? String ?? "").count > 0 {
            cell.circleLabel.isHidden = true
            cell.cellUsernameIcon.isHidden = false
            
            var selectedIcon = (dict[3] as? String ?? "").replacingOccurrences(of: "_white", with: "")
            if (dict[4] as? Bool ?? true) {
                selectedIcon = selectedIcon + "_white"
            }
            
            cell.cellUsernameIcon.image = UIImage(named: selectedIcon)
        } else {
            cell.circleLabel.isHidden = false
            cell.cellUsernameIcon.isHidden = true
            
            if (dict[0] as? String ?? "").count <= 0 {
                cell.circleLabel.text = (NSLocalizedString("userTitle", comment: "User")).prefix(2).uppercased()
            } else if (dict[0] as? String ?? "").count == 1 {
                cell.circleLabel.text = (dict[0] as? String ?? "").prefix(1).uppercased()
            } else {
                cell.circleLabel.text = (dict[0] as? String ?? "").prefix(2).uppercased()
            }
            
            if (dict[4] as? Bool ?? true) {
                cell.circleLabel.textColor = .white
            } else {
                cell.circleLabel.textColor = .black
            }
        }
        
        let tabRecongnizer = UITapGestureRecognizer(target: self, action: #selector(openIconPicker))
        cell.circleView.addGestureRecognizer(tabRecongnizer)
        
        cell.delegate = self
        
        return cell
    }
    
    func getCutOffCell(indexPath: IndexPath) -> cellCutOffDate {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCutoffDate", for: indexPath) as! cellCutOffDate
        cell.delegate = self
        return cell
    }
    
    func getAboutTitleCell(indexPath: IndexPath) -> cellAboutLogo {
        self.title = "v" + (Bundle.main.releaseVersionNumber ?? "1.0.0")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAboutLogo", for: indexPath) as! cellAboutLogo
        return cell
    }
    
    func getAboutTextCell(indexPath: IndexPath) -> cellAboutText {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAboutText", for: indexPath) as! cellAboutText
        cell.delegate = self
        return cell
    }
    
    // MARK: -FUNCTIONS
    func initView(table: UITableView) {
        super.navigationController?.navigationBar.topItem?.title = selectedRow
        
        table.sectionHeaderHeight = UITableView.automaticDimension
                
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            userDetailTable.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
        } else {
            userDetailTable.backgroundColor = .secondarySystemBackground
            headerView.backgroundColor = .secondarySystemBackground
        }
        
        var headerHeight = view.frame.height * headerHeightFactor
        if selectedRowForCells == 1 {
            headerHeight = 20
        }
        
        headerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerView.headerLabel.text = " "
            
        headerView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.frame.width,
            height: headerHeight
        )
        headerView.maxHeight = headerHeight
        headerView.maxLabelPointSize = headerView.headerLabel.font.pointSize
        headerView.minLabelPointSize = 20.0
        headerView.scrollView = table
            
        var heightFloat = view.frame.height * headerHeightFactor + 20
        var bottomInset:CGFloat = 0.0
        if selectedRowForCells == 4 {
            heightFloat = 0.0
        } else if selectedRowForCells == 1 {
            heightFloat = 20.0
            bottomInset = 50.0
        }
            
        table.backgroundView = UIView()
        table.backgroundView?.addSubview(headerView)
        table.contentInset = UIEdgeInsets(
            top: heightFloat,
            left: 0,
            bottom: bottomInset,
            right: 0
        )
        
        activityIndicator.style = .medium
        activityIndicator.hidesWhenStopped = true
        table.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerYAnchor.constraint(equalTo: table.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: table.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        
        if selectedRowForCells == 1 {
            categoryBottomBar.isHidden = true
            initBottomBar()
            hideBottomBar()
        }
        
        loadViewIfNeeded()
    }
    
    func initBottomBar() {
        categoryBottomBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(categoryBottomBar, aboveSubview: userDetailTable)
        categoryBottomBar.initView()
        
        initBottomBarSize()
        
        categoryBottomBar.delegete = self
    }
    
    func initBottomBarSize() {
        widthAnchorConstraintBottomBar?.isActive = false
        widthAnchorConstraintBottomBar = categoryBottomBar.widthAnchor.constraint(equalToConstant: min(view.frame.width, 400))
        widthAnchorConstraintBottomBar?.isActive = true
        
        bottomAnchorConstraintBottomBar?.isActive = false
        bottomAnchorConstraintBottomBar = categoryBottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        bottomAnchorConstraintBottomBar?.isActive = true
        
        categoryBottomBar.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 1.0).isActive = true
    }
    
    func hideBottomBar() {
        bottomAnchorConstraintBottomBar?.isActive = false
        bottomAnchorConstraintBottomBar = categoryBottomBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        bottomAnchorConstraintBottomBar?.isActive = true
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        } , completion: { finished in
            self.categoryBottomBar.isHidden = true
        })
    }
    
    func showBottomBar() {
        bottomAnchorConstraintBottomBar?.isActive = false
        bottomAnchorConstraintBottomBar = categoryBottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        bottomAnchorConstraintBottomBar?.isActive = true
        self.categoryBottomBar.isHidden = false
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        } , completion: { finished in
            
        })
    }
    
    func sendEmail() {
      if MFMailComposeViewController.canSendMail() {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["support@alpako.info"])
        mail.setSubject("Feedback - FIN")
        mail.setMessageBody("Thank you for your Feedback.", isHTML: true)

        present(mail, animated: true)
      }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
      controller.dismiss(animated: true)
    }
    
    func initCategories() {
        for i in 0...4 {
            switch i {
            case 1:
                dataHandler.saveCategory(name: NSLocalizedString("categorySport", comment: "Sport"), color: 53, isIncome: false, isSave: false, icon: "cycling")
                break
            case 2:
                dataHandler.saveCategory(name: NSLocalizedString("categoryOther", comment: "Other"), color: 37, isIncome: false, isSave: false, icon: "")
                break
            case 3:
                dataHandler.saveCategory(name: NSLocalizedString("categorySalary", comment: "Salary"), color: 19, isIncome: true, isSave: false, icon: "papermoney")
                break
            case 4:
                dataHandler.saveCategory(name: NSLocalizedString("categorySavingsAccount", comment: "Savings Account"), color: 0, isIncome: false, isSave: true, icon: "safe")
                break
            default:
                dataHandler.saveCategory(name: NSLocalizedString("categoryHousehold", comment: "Household"), color: 60, isIncome: false, isSave: false, icon: "prefabhouse")
                break
            }
        }
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("categoryChanged"), object: nil)
    }
    
    @objc func openIconPicker() {
        if let cell = userDetailTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellUserSettings {
            UIView.animate(withDuration: 0.1, animations: {
                cell.circleView.transform = cell.circleView.transform.scaledBy(x: 0.96, y: 0.96)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.1, animations: {
                    cell.circleView.transform = CGAffineTransform.identity
                }, completion: { _ in
                    let userStoryBoard: UIStoryboard = UIStoryboard(name: "userTSB", bundle: nil)
                    let iconTVC = userStoryBoard.instantiateViewController(withIdentifier: "iconPickerTVC") as! iconPickerTVC
                    
                    iconTVC.selectedColor = (self.userDetailCells[0] as? [Int:Any])?[5] as? Int16 ?? 0
                    iconTVC.selectedIcon = (self.userDetailCells[0] as? [Int:Any])?[3] as? String ?? ""
                    if ((self.userDetailCells[0] as? [Int:Any])?[0] as? String ?? "").count > 0 {
                        iconTVC.selectedLabelText = (self.userDetailCells[0] as? [Int:Any])?[0] as? String ?? ""
                    } else {
                        iconTVC.selectedLabelText = NSLocalizedString("previewIcon", comment: "Preview")
                    }
                    iconTVC.light = (self.userDetailCells[0] as? [Int:Any])?[4] as? Bool ?? true
                    iconTVC.selectedType = 3
                    
                    let navigationVC = UINavigationController(rootViewController: iconTVC)
                    self.present(navigationVC, animated: true, completion: nil)
                })
            })
        }
    }
    
    @objc func addRegularPaymentTabbed() {
        let finStoryBoard: UIStoryboard = UIStoryboard(name: "finTSB", bundle: nil)
        let addVC = finStoryBoard.instantiateViewController(withIdentifier: "addTVC") as! addTVC
                
        addVC.superRegularPayment = true
        addVC.newRegularPayment = true
        
        let navigationVC = UINavigationController(rootViewController: addVC)
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    @objc func addCategoryTabbed() {
        if showAdds {
            let purchaseText = NSLocalizedString("purchaseText", comment: "Unlock Features Text")
            let purchaseTitle = NSLocalizedString("purchaseTitle", comment: "Unlock Features Title")
            let purchasePrompt = UIAlertController(title: purchaseTitle, message: purchaseText, preferredStyle: .alert)

            purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteYes", comment: "Delete Yes"), style: .cancel, handler: { action in
                self.purchaseButtonPressed()
            }))
            purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteNo", comment: "Delete No"), style: .default, handler: nil))
                
            purchasePrompt.popoverPresentationController?.sourceView = self.view
            purchasePrompt.popoverPresentationController?.sourceRect = self.view.bounds
                
            self.present(purchasePrompt, animated: true)
        } else {
            selectedCategoryDetail = -1
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toCategoryTCVSeque", sender: nil)
            }
        }
    }
    
    @objc func categoryReorderDone() {
        var cellsShown = [Int]()
        for (_,value) in userDetailCells.enumerated() {
            cellsShown.append((value.value  as? [Int:Any])?[7] as? Int ?? 0)
        }
        
        var addIDs = [IndexPath]()
        for (_,value) in userDetailCellsTmp.enumerated() {
            if find(value: value.key, in: cellsShown) == nil {
                addIDs.append(IndexPath(row: value.key, section: 0))
            }
        }

        userDetailCells.removeAll()
        userDetailCells = userDetailCellsTmp
        userDetailTable.setEditing(false, animated: true)
        userDetailTable.showsVerticalScrollIndicator = true
        navigationItem.hidesBackButton = false
        
        userDetailTable.beginUpdates()
        userDetailTable.insertRows(at: addIDs, with: .automatic)
        userDetailTable.endUpdates()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategoryTabbed))
        let orderButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(reorderCategories))
        
        navigationItem.rightBarButtonItems = [addButton,orderButton]
        hideBottomBar()
        
        var j:Int16 = 1
        for i in 0...userDetailCells.count-1 {
            if !((userDetailCells[i] as? [Int:Any])?[9] as? Bool ?? false) {
                let querySaveOrder = NSPredicate(format: "cID == %i", Int((userDetailCells[i] as? [Int:Any])?[0] as? Int16 ?? -1) as NSInteger)
                dataHandler.saveSingleData(entity: "Categories", attibute: "order", newValue: j, query: querySaveOrder)
                j = j + 1
            }
        }
    }
    
    @objc func reorderCategories() {
//        if showAdds {
//            let purchaseText = NSLocalizedString("purchaseText", comment: "Unlock Features Text")
//            let purchaseTitle = NSLocalizedString("purchaseTitle", comment: "Unlock Features Title")
//            let purchasePrompt = UIAlertController(title: purchaseTitle, message: purchaseText, preferredStyle: .alert)
//
//            purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteYes", comment: "Delete Yes"), style: .cancel, handler: { action in
//                self.purchaseButtonPressed()
//            }))
//            purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteNo", comment: "Delete No"), style: .default, handler: nil))
//
//            purchasePrompt.popoverPresentationController?.sourceView = self.view
//            purchasePrompt.popoverPresentationController?.sourceRect = self.view.bounds
//
//            self.present(purchasePrompt, animated: true)
//        } else {
            removeIDs.removeAll()
            userDetailCellsTmp.removeAll()
            userDetailCellsTmp = userDetailCells
            
            userDetailTable.isEditing = true

            changeCategoriesForOrder(selectedType: selectedSegmentOrderCategories, reloadTable: false)
            showBottomBar()
            
            userDetailTable.showsVerticalScrollIndicator = false
            navigationItem.hidesBackButton = true
            
            navigationItem.rightBarButtonItems?.removeAll()
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(categoryReorderDone))
//        }
    }
    
    func changeCategoriesForOrder(selectedType:Int, reloadTable:Bool) {
        userDetailCells.removeAll()
        userDetailCells = userDetailCellsTmp
        
        removeIDs.removeAll()
        for (_,value) in userDetailCells.enumerated() {
            switch selectedType {
            case 1: // Income
                if !(((value.value  as? [Int:Any])?[4] as? Bool ?? false) && !((value.value  as? [Int:Any])?[5] as? Bool ?? true)) {
                    removeIDs.append(value.key)
                }
                break
            case 2: // Savings
                if !((value.value  as? [Int:Any])?[5] as? Bool ?? false) {
                    removeIDs.append(value.key)
                }
                break
            default: // Expenses
                if !(!((value.value  as? [Int:Any])?[4] as? Bool ?? true) && !((value.value  as? [Int:Any])?[5] as? Bool ?? true)) {
                    removeIDs.append(value.key)
                }
                break
            }
        }
        
        var indexPathsToBeDeleted = [IndexPath]()
        for index in removeIDs {
            indexPathsToBeDeleted.append(IndexPath(row: index, section: 0))
            userDetailCells.removeValue(forKey: index)
        }

        var userDetailCellsTmp2 = [Int:Any]()
        for (_,value) in userDetailCells.enumerated() {
            userDetailCellsTmp2[Int((value.value  as? [Int:Any])?[6] as? Int ?? 0)] = value.value
        }
        
        userDetailCells.removeAll()
        userDetailCells = userDetailCellsTmp2

        if reloadTable {
            userDetailTable.reloadData()
        } else {
            userDetailTable.beginUpdates()
            userDetailTable.deleteRows(at: indexPathsToBeDeleted, with: .automatic)
            userDetailTable.endUpdates()
        }
    }
    
    @objc func transactionUpdated(notification: Notification) {
        if let userInfo = notification.userInfo, let transactionCreateDate = userInfo["transactionCreateDate"] as? Date {
            if let oldCreateDate = userInfo["oldCreateDate"] as? Date {
                if oldCreateDate != transactionCreateDate {
                    initCells(selectedRowForCells: selectedRowForCells ?? 0)
                    initView(table: userDetailTable)
                    userDetailTable.reloadData()
//                    initRows(clearRows: true)
                }
            }
        }
    }
    
    @objc func transactionDeleted() {
        initCells(selectedRowForCells: selectedRowForCells ?? 0)
        initView(table: userDetailTable)
        userDetailTable.reloadData()
    }
    
    @objc func userIconColorChanges(notification: Notification) {
        if let userInfo = notification.userInfo {
            if (userInfo["selectedType"] as? Int ?? -1) == 3 {
                var ramDict = (userDetailCells[0] as? [Int:Any])
                
                let colorNew = userInfo["selectedColor"] as? Int16 ?? (userDetailCells[0] as? [Int:Any])?[5] as? Int16 ?? 0
                let iconNew = userInfo["selectedIcon"] as? String ?? (userDetailCells[0] as? [Int:Any])?[3] as? String ?? ""
                let iconLightNew = userInfo["selectedLight"] as? Bool ?? (userDetailCells[0] as? [Int:Any])?[4] as? Bool ?? true
                
                ramDict?[5] = colorNew
                ramDict?[3] = iconNew
                ramDict?[4] = iconLightNew
                
                userDetailCells[0] = ramDict
                
                let queryUser = NSPredicate(format: "isUser == true")
                
                dataHandler.saveSingleData(entity: "SplitPersons", attibute: "icon", newValue: iconNew, query: queryUser)
                dataHandler.saveSingleData(entity: "SplitPersons", attibute: "iconLight", newValue: iconLightNew, query: queryUser)
                dataHandler.saveSingleData(entity: "SplitPersons", attibute: "color", newValue: colorNew, query: queryUser)
                
                userDetailTable.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        }
    }
    
    func checkSettingsDuplicates() {
        let countSettings = dataHandler.loadBulk(entitie: "Settings").count
        var firstDate = Date()
        var showAddsRAM:Bool = true
        var trueUserName = NSLocalizedString("userTitle", comment: "User")
        let loginEnabledSafe = false
        var firstLaunch = true
        var filteredTagsZero = false
        var filteredCategoriesZero = false
        var recoveryMail = ""
        var lastCurrencyCodeSafe = Locale.current.currencyCode ?? "EUR"
        var userColorSafe = Int16(0)
        var userCodeSafe = ""
        
        if countSettings > 1 {
            trueUserName = dataHandler.loadSettingsOldest(entitie: "Settings", attibute: "userName") as? String ?? NSLocalizedString("userTitle", comment: "User")
            firstDate = dataHandler.loadSettingsOldest(entitie: "Settings", attibute: "firstLaunchDate") as? Date ?? Date()
            showAddsRAM = dataHandler.loadSettingsOldest(entitie: "Settings", attibute: "showAdds") as? Bool ?? true
//            loginEnabledSafe = loadSettingsOldest(entitie: "Settings", attibute: "loginEnabled") as? Bool ?? false
            firstLaunch = dataHandler.loadSettingsOldest(entitie: "Settings", attibute: "firstLaunch") as? Bool ?? false
            filteredTagsZero = dataHandler.loadSettingsOldest(entitie: "Settings", attibute: "filteredTagsZero") as? Bool ?? false
            filteredCategoriesZero = dataHandler.loadSettingsOldest(entitie: "Settings", attibute: "filteredCategoriesZero") as? Bool ?? false
            recoveryMail = dataHandler.loadSettingsOldest(entitie: "Settings", attibute: "recoveryMail") as? String ?? ""
            lastCurrencyCodeSafe = dataHandler.loadSettingsOldest(entitie: "Settings", attibute: "lastCurrencyCode") as? String ?? ""
            userColorSafe = dataHandler.loadSettingsOldest(entitie: "Settings", attibute: "userColor") as? Int16 ?? 0
            userCodeSafe = dataHandler.loadSettingsOldest(entitie: "Settings", attibute: "userCode") as? String ?? ""
            
            dataHandler.deleteData(entity: "Settings")
        }
        
        let countSettings2 = dataHandler.loadBulk(entitie: "Settings").count
        if countSettings2 <= 0 {
            let managedContext = dataHandler.persistentContainer.viewContext
            managedContext.automaticallyMergesChangesFromParent = true
            managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
            let settingsSave = Settings(context: managedContext)
            
            settingsSave.userCode = ""
            settingsSave.showAdds = true
            settingsSave.firstLaunchDate = Date()
                
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
        if countSettings > 1 {
            dataHandler.saveSettings(settingsChange: "firstLaunch", newValue: false)
            dataHandler.saveSettings(settingsChange: "firstLaunchDate", newValue: firstDate)
            dataHandler.saveSettings(settingsChange: "showAdds", newValue: showAddsRAM)
            dataHandler.saveSettings(settingsChange: "userName", newValue: trueUserName)
            dataHandler.saveSettings(settingsChange: "loginEnabled", newValue: loginEnabledSafe)
            dataHandler.saveSettings(settingsChange: "firstLaunch", newValue: firstLaunch)
            dataHandler.saveSettings(settingsChange: "filteredTagsZero", newValue: filteredTagsZero)
            dataHandler.saveSettings(settingsChange: "filteredCategoriesZero", newValue: filteredCategoriesZero)
            dataHandler.saveSettings(settingsChange: "recoveryMail", newValue: recoveryMail)
            dataHandler.saveSettings(settingsChange: "lastCurrencyCode", newValue: lastCurrencyCodeSafe)
            dataHandler.saveSettings(settingsChange: "userColor", newValue: userColorSafe)
            dataHandler.saveSettings(settingsChange: "userCode", newValue: userCodeSafe)
        }
    }
    
    func checkForCategoryNameDuplicates() {
        var duplicateIDs = [Int16]()
        let categoriesCountArray = dataHandler.loadDataGrouped(entitie: "Categories", groupByColumn: "name") as? [[String:Any]]
        if (categoriesCountArray?.count ?? 0) > 0 {
            for i in 0...((categoriesCountArray?.count ?? 1)-1) {
                if categoriesCountArray?[i]["count"] as? Int64 ?? 0 > 1 {
                    let queryCategory = NSPredicate(format: "name == %@", (categoriesCountArray?[i]["name"] as? String ?? "") as NSString)
                    for category in dataHandler.loadBulkQueriedSorted(entitie: "Categories", query: queryCategory, sort: [NSSortDescriptor(key: "createDate", ascending: true)]) {
                        let queryTransactions = NSPredicate(format: "categoryID == %i", (category.value(forKey: "cID") as? Int16 ?? -1))
                        if dataHandler.loadBulkQueriedLimited(entitie: "Transactions", query: queryTransactions).count <= 0 {
                            duplicateIDs.append((category.value(forKey: "cID") as? Int16 ?? -1))
                            break
                        }
                    }
                }
            }
        }
        
        if duplicateIDs.count > 0 {
            for duplicate in duplicateIDs {
                let queryDelete = NSPredicate(format: "cID == %i", duplicate)
                dataHandler.deleteDataQueried(entity: "Categories", query: queryDelete)
            }
            checkForCategoryNameDuplicates()
        }
    }
    
    func checkForCategoryDuplicates() {
        var duplicateIDs = [Int16]()
        
        let categoriesCountArray = dataHandler.loadDataGrouped(entitie: "Categories", groupByColumn: "cID") as? [[String:Any]]
        if (categoriesCountArray?.count ?? 0) > 0 {
            for i in 0...((categoriesCountArray?.count ?? 1)-1) {
                if categoriesCountArray?[i]["count"] as? Int64 ?? 0 > 1 {
                    duplicateIDs.append(categoriesCountArray?[i]["cID"] as? Int16 ?? 0)
                }
            }
        }
        
        if duplicateIDs.count > 0 {
            for duplicate in duplicateIDs {
                let nextID = dataHandler.loadNextCategoryID()
                let query = NSPredicate(format: "cID == %i", duplicate)
                dataHandler.saveSingleDataInt16(entity: "Categories", attibute: "cID", newValue: nextID, query: query, sort: [NSSortDescriptor(key: "createDate", ascending: false)])
            }
            checkForCategoryDuplicates()
        }
    }
    
    // MARK: HELPER FUNCTIONS
    func getSymbol(forCurrencyCode code: String) -> String? {
        let locale = NSLocale(localeIdentifier: code)
        if locale.displayName(forKey: .currencySymbol, value: code) == code {
            let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: code)
        }
        return locale.displayName(forKey: .currencySymbol, value: code)
    }
    
    func getDayForDate(dayDate: Date) -> String {
        let calendar = Calendar.current
        
        let dayDateDateOnly = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: dayDate)
        let nowDateOnly = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: Date())
        
        let differenceInDays = Calendar.current.dateComponents([.day], from: dayDateDateOnly, to: nowDateOnly).day!
        
        if differenceInDays == 0 {
            return NSLocalizedString("today", comment: "Today")
        } else if differenceInDays == 1 {
            return NSLocalizedString("yesterday", comment: "Yesterday")
        } else if differenceInDays < 7 && differenceInDays > 0 {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: dayDate)
        } else if differenceInDays == -1 {
            return NSLocalizedString("tomorrowText", comment: "Tomorrow")
        } else if differenceInDays == -2 {
            return NSLocalizedString("dayAfterTomorrowText", comment: "Day after Tomorrow")
        } else {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: dayDate).capitalized.prefix(3) + ", " + mediumDate.string(from: dayDate)
        }
    }
    
    func find(value searchValue: Int, in array: [Int]) -> Int? {
        for (index, value) in array.enumerated() {
            if value == searchValue {
                return index
            }
        }
        return nil
    }

    func updateSplitsNewUser(newUserName: String) {
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
        
        var nameUser:String?
        var createDateUser:Date?
        
        for data in dataHandler.loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
        
        dataHandler.saveSingleDataString(entity: "SplitPersons", attibute: "namePerson", newValue: newUserName, query: queryUser)
        
        let userDateUserPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        let userDateUserMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
        
        let querySplitsPersons = NSPredicate(format: "namePerson == %@ AND createDatePerson < %@ AND createDatePerson > %@", ((nameUser ?? "") as NSString), (userDateUserPlus as NSDate), (userDateUserMinus as NSDate))
        dataHandler.saveSingleDataString(entity: "Splits", attibute: "namePerson", newValue: newUserName, query: querySplitsPersons)
        
        let querySplitsPersonsPaid = NSPredicate(format: "namePersonWhoPaid == %@ AND createDatePersonWhoPaid < %@ AND createDatePersonWhoPaid > %@", ((nameUser ?? "") as NSString), (userDateUserPlus as NSDate), (userDateUserMinus as NSDate))
        dataHandler.saveSingleDataString(entity: "Splits", attibute: "namePersonWhoPaid", newValue: newUserName, query: querySplitsPersonsPaid)
        
        var persons = [Int:[Int:Any]]()
        
        for groups in dataHandler.loadBulkData(entitie: "SplitGroups", orderBy: "nameGroup") {
            persons.removeAll()
            
            var newPersons:String?
            
            var j = 0
            for data in (groups.value(forKey: "persons") as? String ?? "").components(separatedBy: "*;*") {
                newPersons?.removeAll()
                var RAM = data.components(separatedBy: "*&*")
                if RAM.count == 2 {
                    let up = (dateFormatter.date(from: RAM[1]) ?? Date()).compare(userDateUserPlus) == .orderedAscending
                    let down = (dateFormatter.date(from: RAM[1]) ?? Date()).compare(userDateUserMinus) == .orderedDescending
                    
                    if up && down && (RAM[0] == (nameUser ?? "")) {
                        RAM[0] = newUserName
                    }

                    persons[j] = [
                        0:RAM[0],
                        1:RAM[1]
                    ]
                    j = j + 1
                }
                
                for i in 0...(persons.count-1) {
                    if i == (persons.count-1) {
                        let str = (persons[i]?[0] as? String ?? "") + "*&*" + (persons[i]?[1] as? String ?? "")
                        newPersons = (newPersons ?? "") + str
                    } else {
                        let str = (persons[i]?[0] as? String ?? "") + "*&*" + (persons[i]?[1] as? String ?? "") + "*;*"
                        newPersons = (newPersons ?? "") + str
                    }
                }
                
                let groupName = (groups.value(forKey: "nameGroup") as? String ?? "")
                let groupDate = (groups.value(forKey: "createDate") as? Date ?? Date())
                
                let groupDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: groupDate)!
                let groupDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: groupDate)!
                
                let query = NSPredicate(format: "nameGroup == %@ AND createDate < %@ AND createDate > %@", (groupName as NSString), (groupDatePlus as NSDate), (groupDateMinus as NSDate))
                dataHandler.saveSingleDataString(entity: "SplitGroups", attibute: "persons", newValue: (newPersons ?? ""), query: query)
            }
        }
    }
    
    // MARK: -TextViewDelegate
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier ?? "") {
        case "setCodeSeque":
            guard let codeVC = segue.destination as? setPasscode else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            codeVC.codePreviouslySet = codeIsSet
            break
        default:
            break
        }
    }
}

// Context Menu
extension userDetailVC: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if UIDevice().model.contains("iPad") {
            if selectedRowForCells == 1 { // Categories
                return UIContextMenuConfiguration(
                    identifier: IndexPath(row: (interaction.view?.tag ?? -1), section: 0) as NSIndexPath,
                    previewProvider: nil,
                      actionProvider: { _ in
                        let children: [UIMenuElement] = [self.makeCategoryAction()]
                        return UIMenu(title: "", children: children)
                      })
            } else {
                return UIContextMenuConfiguration(
                    identifier: IndexPath(row: (interaction.view?.tag ?? -1), section: 0) as NSIndexPath,
                    previewProvider: nil,
                      actionProvider: { _ in
                        let children: [UIMenuElement] = [self.makeEditTransactionAction(row: (interaction.view?.tag ?? -1)), self.makeDeleteAction(rowString: String(interaction.view?.tag ?? -1))]
                        return UIMenu(title: "", children: children)
                      })
            }
        } else {
            if selectedRowForCells == 1 { // Categories
                return UIContextMenuConfiguration(
                    identifier: IndexPath(row: (interaction.view?.tag ?? -1), section: 0) as NSIndexPath,
                    previewProvider: nil,
                      actionProvider: { _ in
                        let children: [UIMenuElement] = [self.makeCategoryAction()]
                        return UIMenu(title: "", children: children)
                      })
            } else {
                return UIContextMenuConfiguration(
                    identifier: IndexPath(row: (interaction.view?.tag ?? -1), section: 0) as NSIndexPath,
                    previewProvider: { self.makeDetailPreview(row: (interaction.view?.tag ?? -1)) },
                      actionProvider: { _ in
                        let children: [UIMenuElement] = [self.makeDeleteAction(rowString: String(interaction.view?.tag ?? -1))]
                        return UIMenu(title: "", children: children)
                      })
            }
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        if selectedRowForCells == 0 {
            animator.addCompletion {
                self.show(self.makeDetailPreview(row: (interaction.view?.tag ?? -1)), sender: self)
            }
        }
    }
    
    func makeDetailPreview(row: Int) -> UIViewController {
        let finStoryBoard: UIStoryboard = UIStoryboard(name: "finTSB", bundle: nil)
        let addVC = finStoryBoard.instantiateViewController(withIdentifier: "addTVC") as! addTVC
        
        if let latestTransactionDate = ((userDetailCells[(row)] as? [Int:Any])?[4] as? Date) {
            addVC.updateCreateDate = latestTransactionDate
            addVC.superRegularPayment = true
            addVC.newRegularPayment = true
        }
        let navigationVC = UINavigationController(rootViewController: addVC)
        return navigationVC
    }
    
    func makeDeleteAction(rowString: String) -> UIAction {
      return UIAction(
        title: NSLocalizedString("deleteButton", comment: "Delete"),
        image: UIImage(systemName: "trash"),
        identifier: UIAction.Identifier(rowString),
        attributes: .destructive,
        handler: deleteTransaction)
    }
    
    func makeCategoryAction() -> UIAction {
      return UIAction(
        title: NSLocalizedString("reorderCategoryQuickAction", comment: "Change order"),
        image: UIImage(systemName: "arrow.up.arrow.down"),
        handler: triggerReorder)
    }
    
    func makeEditTransactionAction(row: Int) -> UIAction {
        return UIAction(
            title: NSLocalizedString("editSomethingLabel", comment: "Edit"),
            image: UIImage(systemName: "pencil"),
            identifier: UIAction.Identifier(String(row)+"_edit"),
            handler: openEditTransaction)
    }
    
    func openEditTransaction(from action: UIAction) {
        let identifier = String(action.identifier.rawValue).replacingOccurrences(of: "_edit", with: "")
        let numFormater = NumberFormatter()
        numFormater.numberStyle = .none
        
        let finStoryBoard: UIStoryboard = UIStoryboard(name: "finTSB", bundle: nil)
        let addVC = finStoryBoard.instantiateViewController(withIdentifier: "addTVC") as! addTVC
        
        let row = Int(truncating: numFormater.number(from: identifier) ?? -1)
        
        if row != -1 {
            if let latestTransactionDate = ((userDetailCells[(row)] as? [Int:Any])?[4] as? Date) {
                addVC.updateCreateDate = latestTransactionDate
                addVC.superRegularPayment = true
                addVC.newRegularPayment = true
            }
        }
        
        let navigationVC = UINavigationController(rootViewController: addVC)
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func triggerReorder(from action: UIAction) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.reorderCategories()
        }
    }
    
    func deleteTransaction(from action: UIAction) {
        let identifier = String(action.identifier.rawValue)
        
        let numFormater = NumberFormatter()
        numFormater.numberStyle = .none
        
        let row = Int(truncating: numFormater.number(from: identifier) ?? -1)

        if row != -1 {
            let transactionDate = ((userDetailCells[(row)] as? [Int:Any])?[4] as? Date ?? Date())
            
            let dateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: transactionDate)!
            let dateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: transactionDate)!

            let queryDelete = NSPredicate(format: "dateTimeNext < %@ AND dateTimeNext > %@", dateTransactionPlus as NSDate, dateTransactionMinus as NSDate)
            dataHandler.deleteDataQueried(entity: "RegularPayments", query: queryDelete)

            let queryDeleteSplitsRegularPayments = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", dateTransactionPlus as NSDate, dateTransactionMinus as NSDate)
            dataHandler.deleteDataQueried(entity: "SplitsRegularPayments", query: queryDeleteSplitsRegularPayments)
            
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("transactionDeleted"), object: nil)
        }
    }
}

extension userDetailVC: categoryBottomBarDelegate {
    func segmentControlChanged(selected: Int) {
        changeCategoriesForOrder(selectedType: selected, reloadTable: true)
        selectedSegmentOrderCategories = selected
    }
}

extension userDetailVC {
    // MARK: -In-App Purchase
    func purchaseButtonPressed() {
        if canPerformPurchase {
            activityIndicator.startAnimating()
            selectedProductIndex = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                if self.productsArray.count > 0 {
                    PKIAPHandler.shared.purchase(product: self.productsArray[0]) { (alert, product, transaction) in
                        if let _ = transaction, let _ = product {
                         //use transaction details and purchased product as you want
                       }
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: NSLocalizedString("errorProductRequestTitle", comment: "Error"), message: NSLocalizedString("notAuthorisedText", comment: "Not authorised text"), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("noNameOk", comment: "Ok"), style: UIAlertAction.Style.default, handler: nil))
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = self.view.bounds
            present(alert, animated: true, completion: { self.activityIndicator.stopAnimating() })
        }
    }
    
    @objc func purchaseFailed() {
        activityIndicator.stopAnimating()
    }
    
    @objc func purchaseFinished() {
        activityIndicator.stopAnimating()
    }
    
    @objc func purchaseDone() {
        transactionInProgress = false
        showAdds = false
        dataHandler.saveSettings(settingsChange: "showAdds", newValue: false)
        activityIndicator.stopAnimating()
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("updateFinVC"), object: nil) // reload finVC
        nc.post(name: Notification.Name("dataImported"), object: nil) // reload listMasterVC
        nc.post(name: Notification.Name("filterChangedForGraph"), object: nil) // reload graphsVC
        userDetailTable.reloadData()
    }
    
    @objc func purchaseRestored() {
        showAdds = false
        dataHandler.saveSettings(settingsChange: "showAdds", newValue: false)
        activityIndicator.stopAnimating()
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("updateFinVC"), object: nil) // reload finVC
        nc.post(name: Notification.Name("dataImported"), object: nil) // reload listMasterVC
        nc.post(name: Notification.Name("filterChangedForGraph"), object: nil) // reload graphsVC
        userDetailTable.reloadData()
        
        let alert = UIAlertController(title: NSLocalizedString("foundTitle", comment: "Success"), message: NSLocalizedString("purchaseRestoredText", comment: "Purchase Restored"), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("noNameOk", comment: "Ok"), style: UIAlertAction.Style.default, handler: nil))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        present(alert, animated: true, completion: nil)
    }
    
    @objc func restoreNotFound() {
        let alert = UIAlertController(title: NSLocalizedString("notFoundTitle", comment: "Not found"), message: NSLocalizedString("notFoundText", comment: "Not found text"), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("noNameOk", comment: "Ok"), style: UIAlertAction.Style.default, handler: nil))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        present(alert, animated: true, completion: nil)
        activityIndicator.stopAnimating()
    }
}

extension userDetailVC: userSelectionDelegate {
    func userRowSelected() {
    }
}

extension userDetailVC: cellUserSettingsDelegate {
    // Settings Switch
    func loginToggle(newState: Bool) {
        if showAdds {
            let purchaseText = NSLocalizedString("purchaseText", comment: "Unlock Features Text")
            let purchaseTitle = NSLocalizedString("purchaseTitle", comment: "Unlock Features Title")
            let purchasePrompt = UIAlertController(title: purchaseTitle, message: purchaseText, preferredStyle: .alert)

            purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteYes", comment: "Delete Yes"), style: .cancel, handler: { action in
                self.purchaseButtonPressed()
            }))
            purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteNo", comment: "Delete No"), style: .default, handler: nil))
            
            purchasePrompt.popoverPresentationController?.sourceView = self.view
            purchasePrompt.popoverPresentationController?.sourceRect = self.view.bounds
            
            self.present(purchasePrompt, animated: true)
            
            if let cell = userDetailTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellUserSettings {
                cell.cellLoginSwitch.isOn = false
            }
        } else {
            if (dataHandler.loadData(entitie: "Settings", attibute: "userCode") as? String ?? "").count <= 0 || (dataHandler.loadData(entitie: "Settings", attibute: "userCode") as? String ?? "").count <= 0 {
                codeIsSet = false
            } else {
                codeIsSet = true
            }
            
            if newState && codeIsSet {
                loginSuccessfull = false
                loginEnabled = true
            } else {
                loginSuccessfull = true
                loginEnabled = false
            }
            
            dataHandler.saveSettings(settingsChange: "loginEnabled", newValue: loginEnabled)
            
            var dict = userDetailCells[0] as? [Int:Any]
            userDetailCells.removeAll()
            
            dict?[2] = newState
            userDetailCells[0] = dict
            
            if newState {
                userDetailCells[1] = codeIsSet
    //            userDetailCells[2] = [
    //                0:(loadData(entitie: "Settings", attibute: "cutOffDate") as? Date ?? Date())
    //            ] as [Int : Any]
            } else {
    //            userDetailCells[1] = [
    //                0:(loadData(entitie: "Settings", attibute: "cutOffDate") as? Date ?? Date())
    //            ] as [Int : Any]
            }

            if newState {
                if (userDetailTable.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellDetailGeneral) == nil {
                    userDetailTable.insertRows(at: [setCodeCellIndexPath], with: .automatic)
                }
            } else {
                if (userDetailTable.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellDetailGeneral) != nil {
                    userDetailTable.deleteRows(at: [setCodeCellIndexPath], with: .automatic)
                }
            }
            
            if newState && !codeIsSet {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "setCodeSeque", sender: nil)
                }
            }
        }
    }
    
    // Settings - Set Username or Recovery Mail
    func updateText(newText: String, textFieldTag: Int) {
        if showAdds {
            let purchaseText = NSLocalizedString("purchaseText", comment: "Unlock Features Text")
            let purchaseTitle = NSLocalizedString("purchaseTitle", comment: "Unlock Features Title")
            let purchasePrompt = UIAlertController(title: purchaseTitle, message: purchaseText, preferredStyle: .alert)

            purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteYes", comment: "Delete Yes"), style: .cancel, handler: { action in
                self.purchaseButtonPressed()
            }))
            purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteNo", comment: "Delete No"), style: .default, handler: nil))
            
            purchasePrompt.popoverPresentationController?.sourceView = self.view
            purchasePrompt.popoverPresentationController?.sourceRect = self.view.bounds
            
            self.present(purchasePrompt, animated: true)
            
            if textFieldTag == 0 { // Username
                if let cell = userDetailTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellUserSettings {
                    cell.cellUsernameText.text = NSLocalizedString("userText", comment: "User")
                }
            } else if textFieldTag == 1 { // RecoveryMail
                if let cell = userDetailTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellUserSettings {
                    cell.cellRecoveryText.text = ""
                }
            }
        } else {
            switch textFieldTag {
            case 1:
                dataHandler.saveSettings(settingsChange: "recoveryMail", newValue: newText)
                if newText.count <= 0 {
                    loginEnabled = false
                    dataHandler.saveSettings(settingsChange: "loginEnabled", newValue: false)
                    if let cell = userDetailTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellUserSettings {
                        cell.cellLoginSwitch.isOn = false
                        loginToggle(newState: false)
                    }
                }
                break
            default:
                if newText.count > 0 {
                    dataHandler.saveSettings(settingsChange: "userName", newValue: newText)
                    updateSplitsNewUser(newUserName: newText)
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name("updateUserHeader"), object: nil)
                    
                    var ramDict = (userDetailCells[0] as? [Int:Any])
                    ramDict?[0] = newText
                    
                    userDetailCells[0] = ramDict
                    
                    if let cell = userDetailTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellUserSettings {
                        let dict = userDetailCells[0] as! [Int:Any]

                        if (dict[3] as? String ?? "").count <= 0 {
                            cell.circleLabel.isHidden = false
                            cell.cellUsernameIcon.isHidden = true
                            
                            if (dict[0] as? String ?? "").count <= 0 {
                                cell.circleLabel.text = (NSLocalizedString("userTitle", comment: "User")).prefix(2).uppercased()
                            } else if (dict[0] as? String ?? "").count == 1 {
                                cell.circleLabel.text = (dict[0] as? String ?? "").prefix(1).uppercased()
                            } else {
                                cell.circleLabel.text = (dict[0] as? String ?? "").prefix(2).uppercased()
                            }
                            
                            if (dict[4] as? Bool ?? true) {
                                cell.circleLabel.textColor = .white
                            } else {
                                cell.circleLabel.textColor = .black
                            }
                        }
                    }
                }
                break
            }
        }
    }
}

extension userDetailVC: cellCutOffDateDelegate {
    func indoButtonPressed() {
        let text = NSLocalizedString("cutOffInfoText", comment: "Cutoff Info Text")
        let answerSuccess = UIAlertController(title: NSLocalizedString("cutOffTitle", comment: "Cotoff Title"), message: text, preferredStyle: .alert)
        answerSuccess.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "forgotCodeOK"), style: .cancel, handler: nil))
        answerSuccess.popoverPresentationController?.sourceView = self.view
        answerSuccess.popoverPresentationController?.sourceRect = self.view.bounds
        self.present(answerSuccess, animated: true)
    }
    
    func switchChanged(newState:Bool) {
        dataHandler.saveSettings(settingsChange: "cutOffDate", newValue: newState)
    }
}

extension userDetailVC: cellAboutTextDelegate {
    func sendFeedbackPressed() {
        sendEmail()
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionNumberPretty: String {
        return "v\(releaseVersionNumber ?? "1.0.0")"
    }
}
