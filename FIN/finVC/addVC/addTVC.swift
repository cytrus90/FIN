//
//  addTVC.swift
//  FIN
//
//  Created by Florian Riel on 20.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData
import TagListView
import SmoothPicker
import Vision
import Photos

var tags = [Int:[String:Any]]()
var selectedCategory: Int = 1 // Category ID
var currencyCodeSet:String = "EUR"
var currencyExchangeRate:Double?

var split = [Int:[Int:Any]]()
var editSplit = false

var selectedSplitRow = [Int:Bool]()
var selectedSplitSegment:Int?

class addTVC: UITableViewController, UIPopoverPresentationControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet var addTable: UITableView!
    
    var updateCreateDate:Date?
    var updateUUID:UUID?
    var oldCategoryID:Int16?
    
    var receiptTransaction:Bool?
    let fileManager = FileManager.default
    var receiptImage:UIImage?
    var imagePickerController : UIImagePickerController!
    
    var transactionDateTime:Date?
    var superRegularPayment:Bool = false
    var newRegularPayment:Bool = false
    
    var transactionData = [Int:Any]()
    var sumIncome:Double = 0.00
    var sumExpenses:Double = 0.00
    
    var amount:Double?
    
    var addCellRow = 4
    // #### if addCellRow == 5 -> isSave == true in transaction. transactionDate[7] = withdraw or not. If withdraw, amount = negative ####
    
    // Balance View
    let balanceViewXOffsetFactor:CGFloat = 0.05
    let balanceViewYOffsetFactor:CGFloat = 0.02
    
    var isLeft = true
    var isCenter = false
    var isOnEdge = false
    var centerXAnchorConstraint: NSLayoutConstraint?
    var widthAnchorConstraint: NSLayoutConstraint?
    
    var balanceView:balanceView = {
        let nib = UINib(nibName: "balanceView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! balanceView
    }()
    
    // Header View
    let headerHeightFactor = CGFloat(0.10)
    var viewDisappear = false
    var isWideScreen: Bool = false
    var navTitle = NSLocalizedString("Add Transaction Title", comment: "Add Transaction Title")
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    
    // PickerView
    var datePickerView:datePickerView = {
        let nib = UINib(nibName: "datePickerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! datePickerView
    }()
    
    var datePickerViewYAnchor: NSLayoutConstraint?
    
    var shortDate = DateFormatter()
    var numberFormatter = NumberFormatter()
    var tabOutside: UIGestureRecognizer?
    let longDate = DateFormatter()
    
    var dayComponent = DateComponents()
    let calendar = Calendar.current
    
    let manager = LocalNotificationManager()
    
    var repeatTransaction:Bool = false
    var repeatFrequency:Int = 1 // 0: Weekly, 1: Monthly, 2: Yearly
    var skipWeekends:Bool = true
    
    var oldTags:String = ""
    
    var ac:UIAlertController?
    let tagsStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 10, height: 44))
    
    override func loadView() {
        super.loadView()
        
        tags.removeAll()
        
        longDate.dateFormat = "ddMMyyyyHHmmss"
        
        repeatTransaction = superRegularPayment
        
        numberFormatter.numberStyle = .decimal
//        numberFormatter.locale = Locale.current
        
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = Locale.current.groupingSeparator
        numberFormatter.groupingSize = 3
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2

        currencyCodeSet = Locale.current.currencyCode ?? "EUR"
        initTransactionData()
        
        setTitle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // DataCheck
        checkDoubleUser()
        
        tabOutside = UIGestureRecognizer(target: self, action: #selector(self.dismissDatePickerViewTab(_:)))
        initView()
        
//        addTable.reloadData()
        // Keyboard dismiss
        addTable.keyboardDismissMode = .onDrag
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        shortDate.dateStyle = .medium
        
        NotificationCenter.default.addObserver(self, selector: #selector(currencyChanged), name: Notification.Name("currencyChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(splitChanged), name: Notification.Name("splitChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(collectionViedDidScroll), name: Notification.Name("collectionViedDidScroll"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(imageUpdated), name: Notification.Name("imageSaved"), object: nil)
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(transactionCancelled))
        addNavButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.addTable.contentInset = UIEdgeInsets(
                top: self.view.frame.height * self.headerHeightFactor + 20,
                left: 0,
                bottom: 0,
                right: 0
            )
        })
        showSplitButton()
        
        if let cell = addTable.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellDateNewTVC {
            dayComponent.day = 0
            let ramDate = calendar.date(byAdding: dayComponent, to: transactionData[5] as? Date ?? (updateCreateDate ?? Date())) ?? Date()
            cell.datePicker.setDate(ramDate, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initCategories()
        if reloadAddView {
            reloadAddView = false
            if addTable.cellForRow(at: IndexPath(row: 2, section: 0)) != nil {
                let cell = addTable.cellForRow(at: IndexPath(row: 2, section: 0)) as! cellCategoryNewTVC
                cell.getCategoryData()
            }
        }
        if repeatTransaction {
            checkNotificationAuthorization()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if selectedSplitRow.count != 0 {
            selectedSplitRow.removeAll()
        }
        if selectedSplitSegment != nil {
            selectedSplitSegment = nil
        }
        if selectedSplitType != nil {
            selectedSplitType = nil
        }
        if split.count != 0 {
            split.removeAll()
        }
        if repeatTransaction {
            repeatTransaction = false
        }
        tags.removeAll()
        selectedCategory = 1
        currencyExchangeRate = 1.00
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        headerView.updatePosition()
        if !viewDisappear {
            if UIDevice().model.contains("iPhone") && UIDevice.current.orientation.isLandscape {
                if headerView.frame.origin.y <= 0 {
                    super.navigationController?.navigationBar.topItem?.title = navTitle
                } else {
                    super.navigationController?.navigationBar.topItem?.title = ""
                }
            } else {
                if headerView.frame.origin.y <= (headerView.headerLabel.frame.height) {
                    super.navigationController?.navigationBar.topItem?.title = navTitle
                } else {
                    super.navigationController?.navigationBar.topItem?.title = ""
                }
            }
        }
        viewDisappear = false
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        headerView.updatePosition()
        dismissDatePickerView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
        headerView.updatePosition()
    }
    
    @objc func transactionCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        dismissDatePickerView()
    }
    
    @objc func currencyChanged() {
        initView()
        transactionData[1] = currencyCodeSet
        transactionData[2] = currencyExchangeRate
        addTable.reloadData()
        self.view.layoutIfNeeded()
    }
    
    @objc func cancel() {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if addCellRow == 5 {
            return 6
        } else {
            return 5
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 1:
            return getDateCell(indexPath: indexPath)
        case 2:
            return getCategoryCell(indexPath: indexPath)
        case 3:
            if addCellRow == 5 {
                return getDepositCell(indexPath: indexPath)
            } else {
                if receiptTransaction ?? false {
                    return getShowReceiptCell(indexPath: indexPath)
                } else {
                    return getAddReceiptCell(indexPath: indexPath)
                }
            }
        case 4:
            if addCellRow == 5 {
                if receiptTransaction ?? false {
                    return getShowReceiptCell(indexPath: indexPath)
                } else {
                    return getAddReceiptCell(indexPath: indexPath)
                }
            } else {
                return getAddCell(indexPath: indexPath)
            }
        case 5:
            return getAddCell(indexPath: indexPath)
        default:
            return getAmountCell(indexPath: indexPath)
        }
    }
    
    // MARK: -FUNCTIONS
    // MARK: CELLS
    func getDepositCell(indexPath: IndexPath) -> cellSaveDeposit {
        let cell = tableView.dequeueReusableCell(withIdentifier: "saveDepositCell", for: indexPath) as! cellSaveDeposit
        
        if (transactionData[8] as? Bool ?? true) {
            cell.segmentControl.selectedSegmentIndex = 1
        } else {
            cell.segmentControl.selectedSegmentIndex = 0
        }
        
        if (transactionData[9] as? Bool ?? false) { // isLiquid
            cell.segmentControl.setTitle(NSLocalizedString("segmentDepositText", comment: "Deposit"), forSegmentAt: 0)
            cell.segmentControl.setTitle(NSLocalizedString("segmentWithdrawText", comment: "Withdraw"), forSegmentAt: 1)
            cell.liquidSwitch.isOn = true
        } else {
            cell.segmentControl.setTitle(NSLocalizedString("segmentIncreaseText", comment: "Increase"), forSegmentAt: 0)
            cell.segmentControl.setTitle(NSLocalizedString("segmentDecreaseText", comment: "Decrease"), forSegmentAt: 1)
            cell.liquidSwitch.isOn = false
        }
        
        cell.delegate = self
        return cell
    }
    
    func getAddCell(indexPath: IndexPath) -> cellAddTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as! cellAddTVC
        
        var isSave:Bool = false
        var isIncome:Bool = false
        let isWithdraw = transactionData[8] as? Bool ?? true
        
        let queryCategory = NSPredicate(format: "cID == %@", (transactionData[4] as? Int16 ?? 0) as NSNumber)
        for category in dataHandler.loadBulkQueried(entitie: "Categories", query: queryCategory) {
            isSave = category.value(forKey: "isSave") as? Bool ?? false
            isIncome = category.value(forKey: "isIncome") as? Bool ?? false
        }
        
        if !isIncome && !isSave {
            // Expense
            if updateCreateDate != nil {
                cell.addButton.setTitle(NSLocalizedString("updateButtonExpenseText", comment: "Add to Expenses"), for: .normal)
            } else {
                cell.addButton.setTitle(NSLocalizedString("addButtonExpenseText", comment: "Add to Expenses"), for: .normal)
            }
        } else if isIncome && !isSave {
            // Income
            if updateCreateDate != nil {
                cell.addButton.setTitle(NSLocalizedString("updateButtonIncomeText", comment: "Update Income"), for: .normal)
            } else {
                cell.addButton.setTitle(NSLocalizedString("addButtonIncomeText", comment: "Add to Income"), for: .normal)
            }
        } else if !isWithdraw && isSave {
            // Deposit?
            if (transactionData[9] as? Bool ?? false) { // isLiquid
                cell.addButton.setTitle(NSLocalizedString("addButtonSaveAddText", comment: "Deposit to Savings"), for: .normal)
            } else {
                cell.addButton.setTitle(NSLocalizedString("addButtonSaveIncreaseText", comment: "Increase Savings"), for: .normal)
            }
        } else if isWithdraw && isSave {
            // Withdraw?
            if (transactionData[9] as? Bool ?? false) { // isLiquid
                cell.addButton.setTitle(NSLocalizedString("addButtonSaveWithdrawText", comment: "Withdraw from Savings"), for: .normal)
            } else {
                cell.addButton.setTitle(NSLocalizedString("addButtonSaveDecreaseText", comment: "Decrease Savings"), for: .normal)
            }
        } else {
            // else
            if updateCreateDate != nil {
                cell.addButton.setTitle(NSLocalizedString("updateButtonText", comment: "Add"), for: .normal)
            } else {
                cell.addButton.setTitle(NSLocalizedString("addButtonText", comment: "Add"), for: .normal)
            }
        }
        
        cell.delegate = self
        return cell
    }
    
    func getDateCell(indexPath: IndexPath) -> cellDateNewTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dateCellNew", for: indexPath) as! cellDateNewTVC
        
        if repeatTransaction {
            cell.segmentControl.isHidden = false
            cell.segmentControl.selectedSegmentIndex = repeatFrequency
            
            cell.weekendsStackView.isHidden = false
            cell.weekendsSwitch.isOn = skipWeekends
        } else {
            cell.segmentControl.isHidden = true
            cell.weekendsStackView.isHidden = true
        }
        
        cell.delegate = self
        return cell
    }
    
    func getAmountCell(indexPath: IndexPath) -> cellAmountTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "amountCell", for: indexPath) as! cellAmountTVC
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            cell.backgroundColor = backgroundGeneralColor
        } else {
            cell.backgroundColor = .secondarySystemBackground
        }

        if (split.count != 0) {
            editSplit = true
        } else {
            editSplit = false
        }
        
        cell.currencyButton.setTitle(getSymbol(forCurrencyCode: (transactionData[1] as? String ?? "EUR")), for: .normal)
        cell.amountTextField.text = transactionData[0] as? String ?? ""
        cell.descriptionTextField.text = transactionData[3] as? String ?? ""
        cell.initTags()
        cell.amountTextField.tag = 0
        cell.descriptionTextField.tag = 1
        cell.delegate = self
        showSplitButton()
        return cell
    }
    
    func getCategoryCell(indexPath: IndexPath) -> cellCategoryNewTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategoryNewTVC", for: indexPath) as! cellCategoryNewTVC
        cell.delegate = self
        
        return cell
    }
    
    func getAddReceiptCell(indexPath: IndexPath) -> cellAddReceiptTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAddReceiptTVC", for: indexPath) as! cellAddReceiptTVC
//        cell.delegate = self
        
        return cell
    }
    
    func getShowReceiptCell(indexPath: IndexPath) -> cellShowReceiptTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellShowReceiptTVC", for: indexPath) as! cellShowReceiptTVC
//        cell.delegate = self
        
        if receiptImage != nil {
            cell.requestTextFromImage(image: receiptImage!)
            cell.receiptImageView.isHidden = false
            cell.activityIndicator.stopAnimating()
        } else {
            cell.activityIndicator.startAnimating()
            cell.receiptImageView.isHidden = true
        }
        
        return cell
    }
    
    // MARK: -INIT VIEW
    func setTitle() {
        if (newRegularPayment || repeatTransaction) && updateCreateDate == nil {
            navTitle = NSLocalizedString("addRegularPaymentTitle", comment: "Add Regular Title")
        } else if superRegularPayment || (repeatTransaction && updateCreateDate != nil) {
            navTitle = NSLocalizedString("editRegularPaymentTitle", comment: "Edit Regular Title")
        } else if updateCreateDate != nil {
            navTitle = NSLocalizedString("Update Transaction Title", comment: "Edit Transaction Title")
        } else {
            navTitle = NSLocalizedString("Add Transaction Title", comment: "Add Transaction Title")
        }
    }
    
    func addNavButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItems?.removeAll()
        
        if updateCreateDate != nil && !superRegularPayment { // Edit Transaction
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTransaction))
        } else if updateCreateDate != nil && superRegularPayment { // Edit Regular Payment
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTransaction))
        } else if updateCreateDate == nil && !superRegularPayment { // New Transaction from finTVC
            if repeatTransaction {
//                let repeatedTransactionButton = UIBarButtonItem(image: UIImage(named: "repeatCalenderFilled")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(toggleRepeatTransaction))
//                let removeButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTransaction))
//                navigationItem.rightBarButtonItems = [removeButton,repeatedTransactionButton]
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "repeatCalenderFilled")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(toggleRepeatTransaction))
            } else {
//                let repeatedTransactionButton = UIBarButtonItem(image: UIImage(named: "repeatCalender")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(toggleRepeatTransaction))
//                let removeButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTransaction))
//                navigationItem.rightBarButtonItems = [removeButton,repeatedTransactionButton]
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "repeatCalender")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(toggleRepeatTransaction))
            }
        }
    }
    
    func initView(traitCollectionDidChange: Bool = false) {
        addTable.sectionHeaderHeight = UITableView.automaticDimension
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            view.backgroundColor = backgroundGeneralColor
            addTable.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
            datePickerView.backgroundColor = .white
        } else {
            view.backgroundColor = .secondarySystemBackground
            addTable.backgroundColor = .secondarySystemBackground
            headerView.backgroundColor = .secondarySystemBackground
            datePickerView.backgroundColor = .black
        }
            
        headerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerView.headerLabel.text = navTitle
        
        headerView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.frame.width,
            height: 85//view.frame.height * headerHeightFactor
        )
        
        headerView.maxHeight = view.frame.height * headerHeightFactor
        headerView.maxLabelPointSize = headerView.headerLabel.font.pointSize
        headerView.minLabelPointSize = 20.0
        headerView.scrollView = addTable
                
        addTable.backgroundView = UIView()
        addTable.backgroundView?.addSubview(headerView)
        addTable.contentInset = UIEdgeInsets(
            top: 85,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 0,
            right: 0
        )
        initDatepicker()
        // initBalanceView(left: isLeft, traitCollectionDidChange: traitCollectionDidChange)
    }
    
    func initTransactionData() {
        if updateCreateDate != nil {
            var amount:Double?
            var currencyCode:String?
            var exchangeRate:Double?
            var descriptionNote:String?
            var categoryID:Int16?
            var tagString:String?
            var isSave:Bool?
            var isWithdraw:Bool?
            var isLiquid:Bool?
            var uuid:UUID?
            
            let dateTimePlus = Calendar.current.date(byAdding: .second, value: 1, to: updateCreateDate ?? Date())!
            let dateTimeMinus = Calendar.current.date(byAdding: .second, value: -1, to: updateCreateDate ?? Date())!
            
            var query = NSPredicate(format: "dateTime < %@ AND dateTime > %@", dateTimePlus as NSDate, dateTimeMinus as NSDate)
            
            var entityTransaction = "Transactions"
            if superRegularPayment {
                entityTransaction = "RegularPayments"
                query = NSPredicate(format: "dateTimeNext < %@ AND dateTimeNext > %@", dateTimePlus as NSDate, dateTimeMinus as NSDate)
            }
            
            for transaction in dataHandler.loadBulkQueried(entitie: entityTransaction, query: query) {
                amount = abs(transaction.value(forKey: "amount") as? Double ?? 0.00)
                if (transaction.value(forKey: "amount") as? Double ?? 0.00) < 0 {
                    isWithdraw = true
                } else {
                    isWithdraw = false
                }
                currencyCode = transaction.value(forKey: "currencyCode") as? String ?? "EUR"
                exchangeRate = transaction.value(forKey: "exchangeRate") as? Double ?? 1.00
                descriptionNote = transaction.value(forKey: "descriptionNote") as? String ?? ""
                categoryID = transaction.value(forKey: "categoryID") as? Int16 ?? 0
                tagString = transaction.value(forKey: "tags") as? String ?? ""
                isSave = transaction.value(forKey: "isSave") as? Bool ?? false
                isLiquid = transaction.value(forKey: "isLiquid") as? Bool ?? false
                uuid = transaction.value(forKey: "uuid") as? UUID ?? UUID()
                
                if superRegularPayment {
                    skipWeekends = transaction.value(forKey: "skipWeekends") as? Bool ?? true
                    repeatFrequency = Int(transaction.value(forKey: "frequency") as? Int16 ?? 1)
                }
            }
            
            selectedCategory = Int(categoryID ?? 1)
            createTags(tagsString: (tagString ?? ""))
            dateSelected = updateCreateDate ?? Date()
             
            transactionData[0] = numberFormatter.string(from: NSNumber(value: amount ?? 0.00)) // Amount
            transactionData[1] = currencyCode ?? "EUR" // Currency Symbol
            transactionData[2] = exchangeRate ?? 1.00 // Exchange Rate
            transactionData[3] = descriptionNote ?? "" // Description Note
            transactionData[4] = categoryID ?? 0 // Category
            transactionData[5] = updateCreateDate // DateTime
            transactionData[6] = tagString ?? "" // Tags
            transactionData[7] = isSave ?? false // isSave
            transactionData[8] = isWithdraw ?? false // Withdraw from Savings
            transactionData[9] = isLiquid ?? true // Only relevant for Savings, if FALSE: it is NOT included in the calculation of liquidity
            transactionData[10] = uuid ?? nil // UUID of to be updated Transaction
            
            oldTags = tagString ?? ""
            createSplits(dateTimePlus: dateTimePlus, dateTimeMinus: dateTimeMinus)
            
            currencyExchangeRate = exchangeRate ?? 1.00
            
            oldCategoryID = categoryID ?? -1
            
            receiptTransaction = checkIfReceiptImage(transactionUUID: uuid ?? UUID())
        } else {
            selectedCategory = Int(dataHandler.loadFirstCategory())
            transactionData[0] = "" // Amount
            transactionData[1] = currencyCodeSet // Currency Symbol
            transactionData[2] = currencyExchangeRate // Exchange Rate
            transactionData[3] = "" // Description Note
            transactionData[4] = Int16(selectedCategory) // Category
            transactionData[5] = Date() // DateTime
            transactionData[6] = "" // Tags
            transactionData[7] = false // isSave
            transactionData[8] = false // Withdraw from Savings
            transactionData[9] = true // Only relevant for Savings, if FALSE: it is NOT included in the calculation of liquidity
            
            dateSelected = Date()
        }
    }
    
    func createSplits(dateTimePlus: Date, dateTimeMinus: Date) {
        // 0: namePerson
        // 1: createDatePerson
        // 2: nameGroup
        // 3: createDateGroup
        // 4: namePersonWhoPaid
        // 5: createDatePersonWhoPaid
        // 6: paidByUser
        // 7: ratio
        // 8: settled
        
        split.removeAll()
        
        var first = true
        
        let query = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", dateTimePlus as NSDate, dateTimeMinus as NSDate)
        
        var entitySplit = "Splits"
        if superRegularPayment {
            entitySplit = "SplitsRegularPayments"
        }
        
        for splits in dataHandler.loadBulkQueried(entitie: entitySplit, query: query) {
            
            let namePerson = splits.value(forKey: "namePerson") as? String ?? ""
            let createDatePerson = splits.value(forKey: "createDatePerson") as? Date ?? Date()
            let nameGroup = splits.value(forKey: "nameGroup") as? String ?? ""
            let createDateGroup = splits.value(forKey: "createDateGroup") as? Date ?? Date()
            let namePersonWhoPaid = splits.value(forKey: "namePersonWhoPaid") as? String ?? ""
            let createDatePersonWhoPaid = splits.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()
            let paidByUser = splits.value(forKey: "paidByUser") as? Bool ?? false
            let ratio = splits.value(forKey: "ratio") as? Double ?? 0.00
            let settled = splits.value(forKey: "settled") as? Double ?? 0.00
            let uuid = splits.value(forKey: "uuid") as? UUID ?? UUID()
            
            if first {
                if nameGroup.count > 0 {
                    selectedSplitSegment = 0
                } else {
                    selectedSplitSegment = 1
                }
                first = false
            }
            
            split[split.count] = [
                0:namePerson,
                1:createDatePerson,
                2:nameGroup,
                3:createDateGroup,
                4:namePersonWhoPaid,
                5:createDatePersonWhoPaid,
                6:paidByUser,
                7:ratio,
                8:settled,
                9:uuid
            ]
        }
        if split.count > 0 {
            editSplit = true
            
            if selectedSplitSegment == 0 { // Groups
                var i = 0
                
                let createDateGroupPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split[0]?[3] as? Date ?? Date()))!
                let createDateGroupMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split[0]?[3] as? Date ?? Date()))!
                
                let dateSort = NSSortDescriptor(key: "createDate", ascending: false)
                for data in dataHandler.loadBulkSorted(entitie: "SplitGroups", sort: [dateSort]) {
                    let up = createDateGroupMinus.compare((data.value(forKey: "createDate") as? Date ?? Date())) == .orderedAscending
                    let down = createDateGroupPlus.compare((data.value(forKey: "createDate") as? Date ?? Date())) == .orderedDescending
                    
                    if up && down && (split[0]?[2] as? String ?? "") == (data.value(forKey: "nameGroup") as? String ?? ".") {
                        selectedSplitRow[i] = true
                    } else {
                        selectedSplitRow[i] = false
                    }
                    i = i + 1
                }
            } else { // Persons
                let dateSort = NSSortDescriptor(key: "createDate", ascending: false)
                let userSort = NSSortDescriptor(key: "isUser", ascending: false)
                
                var i = 0
                
                for data in dataHandler.loadBulkSorted(entitie: "SplitPersons", sort: [userSort,dateSort]) {
                    if (data.value(forKey: "isUser") as? Bool ?? false) {
                        continue
                    }
                    let createdatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: (data.value(forKey: "namePerson") as? Date ?? Date()))!
                    let createdatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: (data.value(forKey: "namePerson") as? Date ?? Date()))!
                    
                    var set = false
                    for (_,value) in split.enumerated() {
                        let up = createdatePersonMinus.compare(value.value[2] as? Date ?? Date()) == .orderedAscending
                        let down = createdatePersonPlus.compare(value.value[2] as? Date ?? Date()) == .orderedDescending
                        
                        if up && down && (value.value[0] as? String ?? "") == (data.value(forKey: "namePerson") as? String ?? ".") {
                            set = true
                            break
                        }
                    }
                    selectedSplitRow[i] = set
                    i = i + 1
                }
            }
        }
    }
    
    func createTags(tagsString:String) {
        tags.removeAll()
        
        for tag in tagsString.components(separatedBy: "*;*") {
            if tag.count <= 0 {
                continue
            } else {
                let tagName = tag
                var tagColor:Int?
                
                let queryTag = NSPredicate(format: "tagName == %@", (tag as NSString))
                
                for tagData in dataHandler.loadBulkQueried(entitie: "Tags", query: queryTag) {
                    tagColor = Int(tagData.value(forKey: "tagColor") as? Int16 ?? 0)
                }
                
                tags[tags.count] = [
                    "Title":tagName,
                    "Color":tagColor ?? 0
                ]
            }
        }
    }
    
    func saveNewTag(newTags: String) {
        var tagsArray = [String]()
        var tagColor:Int16 = 0
        
        let dateSortHighestFirst = NSSortDescriptor(key: "lastUsed", ascending: false)
        for data in dataHandler.loadBulkSorted(entitie: "Tags", sort: [dateSortHighestFirst]) {
            tagsArray.append(data.value(forKey: "tagName") as? String ?? "")
        }
        var newTagsArray = newTags.components(separatedBy: "*;*")
        if newTagsArray.count > 0 {
            newTagsArray.remove(at: 0)
        }

        for newTag in newTagsArray {
            if tagsArray.contains(newTag) && !oldTags.contains(newTag) {
                if tagsArray[tagsArray.firstIndex(of: newTag) ?? 0] == newTag {
                    if newTag != "" {
                        let query = NSPredicate(format: "tagName == %@", NSString(string: newTag))
                        let numberTags = dataHandler.loadQueriedAttribute(entitie: "Tags", attibute: "countEntries", query: query) as? Int16 ?? 0
                        dataHandler.saveQueriedAttributeMultiple(entity: "Tags", attribute: "lastUsed", query: query, value: Date())
                        dataHandler.saveQueriedAttributeMultiple(entity: "Tags", attribute: "countEntries", query: query, value: (numberTags + 1))
                    }
                }
            } else if !tagsArray.contains(newTag) && !oldTags.contains(newTag) {
                for activeTags in tags {
                    if activeTags.value["Title"] as? String ?? "" == newTag {
                        tagColor = Int16(activeTags.value["Color"] as? Int ?? 0)
                        break
                    }
                }
                dataHandler.saveTag(tagName: newTag, tagColor: tagColor)
            }
        }

        let oldTagsArray = oldTags.components(separatedBy: "*;*")
        for oldTag in oldTagsArray {
            if !newTags.contains(oldTag) {
                let query = NSPredicate(format: "tagName == %@", NSString(string: oldTag))
                var numberTags = dataHandler.loadQueriedAttribute(entitie: "Tags", attibute: "countEntries", query: query) as? Int16 ?? 0
                numberTags = numberTags - 1
                if numberTags <= 0 {
                    dataHandler.deleteData(entity: "Tags", query: query)
                } else {
                    dataHandler.saveQueriedAttributeMultiple(entity: "Tags", attribute: "countEntries", query: query, value: numberTags)
                }
            }
        }
    }
    
    func getTagColor(tagName: String) -> Int {
        let dateSortHighestFirst = NSSortDescriptor(key: "lastUsed", ascending: false)
        for data in dataHandler.loadBulkSorted(entitie: "Tags", sort: [dateSortHighestFirst]) {
            if tagName == (data.value(forKey: "tagName") as? String ?? "") {
                return Int(data.value(forKey: "tagColor") as? Int16 ?? 0)
            }
        }
        return Int.random(in: 0...35)
    }
    
    @objc func toggleRepeatTransaction() {
        repeatTransaction = !repeatTransaction
        if repeatTransaction {
            addTable.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            checkNotificationAuthorization()
        } else {
            addTable.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        }
        addNavButtons()
        setTitle()
        headerView.headerLabel.text = navTitle
    }
    
    func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                        print("Notifications Granted")
                    }
                default:
                    break // Do nothing
                }
            }
    }
    
    // MARK: IMAGE FUNCTIONS
    func checkIfReceiptImage(transactionUUID: UUID) -> Bool {
        let imageName = transactionUUID.uuidString + ".png"
        
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        
        if fileManager.fileExists(atPath: imagePath) {
            return true
        } else {
            return false
        }
    }
    
    func getReceiptImage(transactionUUID: UUID) -> UIImage {
        let imageName = transactionUUID.uuidString + ".png"
        
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        
        if fileManager.fileExists(atPath: imagePath) {
            return UIImage(contentsOfFile: imagePath) ?? UIImage(systemName: "xmark.octagon")!
        } else {
            return UIImage(systemName: "xmark.octagon")!
        }
    }
    
    func saveReceiptImage(transactionUUID: UUID, image: UIImage) {
        let imageName = transactionUUID.uuidString + ".png"
            
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)

        //get the PNG data for this image
        let data = (image).pngData()

        //store it in the document directory
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
    }
    
    func setReceiptImage(transactionUUID: UUID) {
        addTable.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
        addTable.layoutIfNeeded()
    }
    
    @objc func imageUpdated() {
        setReceiptImage(transactionUUID: transactionData[10] as? UUID ?? UUID())
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
    
    func saveRealAmount(dateTime: Date, futureRepeatTransaction: Bool, nextDateTime:Date?) -> Bool {
        var realAmount:Double?
        
        let dateTimeTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTime)!
        let dateTimeTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTime)!
        
        if !futureRepeatTransaction {
            let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", dateTimeTransactionPlus as NSDate, dateTimeTransactionMinus as NSDate)
            
            let amount = dataHandler.loadQueriedAttribute(entitie: "Transactions", attibute: "amount", query: queryTransaction) as? Double ?? 0.00
            let exchangeRate = dataHandler.loadQueriedAttribute(entitie: "Transactions", attibute: "exchangeRate", query: queryTransaction) as? Double ?? 1.00
            let isSplit = dataHandler.loadQueriedAttribute(entitie: "Transactions", attibute: "isSplit", query: queryTransaction) as? Int16 ?? 0
            
            if isSplit > 0 {
                let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
                let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
                
                var nameUser:String?
                var createDateUser:Date?
                
                for data in dataHandler.loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
                    nameUser = data.value(forKey: "namePerson") as? String ?? ""
                    createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
                }
                
                let userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
                let userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
                
                let datePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTime)!
                let dateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTime)!

                let query = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePerson == %@ AND createDatePerson > %@ AND createDatePerson < %@", (dateMinus as NSDate), (datePlus as NSDate), ((nameUser ?? "") as NSString), ((userDateMinus) as NSDate), ((userDatePlus) as NSDate))
                
                var paidByUser:Bool?
                var settledUser:Double?
                
                for dataUser in dataHandler.loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [nameSort]) {
                    settledUser = (dataUser.value(forKey: "settled") as? Double ?? 0.00)
                    paidByUser = (dataUser.value(forKey: "paidByUser") as? Bool ?? true)
                }
                
                if (paidByUser ?? false) {
                    var settledByOthers:Double = 0.00
                    
                    let queryOthers = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ ", (dateMinus as NSDate), (datePlus as NSDate))
                    
                    for dataOthers in dataHandler.loadBulkQueriedSorted(entitie: "Splits", query: queryOthers, sort: [nameSort]) {
                        if !dataHandler.isUser(createDate: (dataOthers.value(forKey: "createDatePerson") as? Date ?? Date()), namePerson: (dataOthers.value(forKey: "namePerson") as? String ?? "")) {
                            let settledOther = (dataOthers.value(forKey: "settled") as? Double ?? 0.00)
                            settledByOthers = settledByOthers + settledOther
                        }
                    }
                    realAmount = (amount-settledByOthers)/exchangeRate
                } else {
                    realAmount = (settledUser ?? 0.00)/exchangeRate
                }
            } else {
                realAmount = amount/exchangeRate
            }
            
            if repeatTransaction {
                let dateTimeNextTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: nextDateTime ?? Date())!
                let dateTimeNextTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: nextDateTime ?? Date())!
                
                let queryRepeatTransaction = NSPredicate(format: "dateTimeNext < %@ AND dateTimeNext > %@", dateTimeNextTransactionPlus as NSDate, dateTimeNextTransactionMinus as NSDate)
                dataHandler.saveQueriedAttributeMultiple(entity: "RegularPayments", attribute: "realAmount", query: queryRepeatTransaction, value: realAmount ?? 0.00)
            }
            
            dataHandler.saveQueriedAttributeMultiple(entity: "Transactions", attribute: "realAmount", query: queryTransaction, value: realAmount ?? 0.00)
            return true
        } else {
            let queryTransaction = NSPredicate(format: "dateTimeNext < %@ AND dateTimeNext > %@", dateTimeTransactionPlus as NSDate, dateTimeTransactionMinus as NSDate)
            
            let amount = dataHandler.loadQueriedAttribute(entitie: "RegularPayments", attibute: "amount", query: queryTransaction) as? Double ?? 0.00
            let exchangeRate = dataHandler.loadQueriedAttribute(entitie: "RegularPayments", attibute: "exchangeRate", query: queryTransaction) as? Double ?? 1.00
            let isSplit = dataHandler.loadQueriedAttribute(entitie: "RegularPayments", attibute: "isSplit", query: queryTransaction) as? Int16 ?? 0
            
            if isSplit > 0 {
                
                let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
                let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
                
                var nameUser:String?
                var createDateUser:Date?
                
                for data in dataHandler.loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
                    nameUser = data.value(forKey: "namePerson") as? String ?? ""
                    createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
                }
                
                let userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
                let userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
                
                let datePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTime)!
                let dateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTime)!

                let query = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePerson == %@ AND createDatePerson > %@ AND createDatePerson < %@", (dateMinus as NSDate), (datePlus as NSDate), ((nameUser ?? "") as NSString), ((userDateMinus) as NSDate), ((userDatePlus) as NSDate))
                
                var paidByUser:Bool?
                var settledUser:Double?
                
                for dataUser in dataHandler.loadBulkQueriedSorted(entitie: "SplitsRegularPayments", query: query, sort: [nameSort]) {
                    settledUser = (dataUser.value(forKey: "settled") as? Double ?? 0.00)
                    paidByUser = (dataUser.value(forKey: "paidByUser") as? Bool ?? true)
                }
                
                if (paidByUser ?? false) {
                    var settledByOthers:Double = 0.00
                    
                    let queryOthers = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ ", (dateMinus as NSDate), (datePlus as NSDate))
                    
                    for dataOthers in dataHandler.loadBulkQueriedSorted(entitie: "SplitsRegularPayments", query: queryOthers, sort: [nameSort]) {
                        if !dataHandler.isUser(createDate: (dataOthers.value(forKey: "createDatePerson") as? Date ?? Date()), namePerson: (dataOthers.value(forKey: "namePerson") as? String ?? "")) {
                            let settledOther = (dataOthers.value(forKey: "settled") as? Double ?? 0.00)
                            settledByOthers = settledByOthers + settledOther
                        }
                    }
                    realAmount = (amount-settledByOthers)/exchangeRate
                } else {
                    realAmount = (settledUser ?? 0.00)/exchangeRate
                }
            } else {
                realAmount = amount/exchangeRate
            }
            dataHandler.saveQueriedAttributeMultiple(entity: "RegularPayments", attribute: "realAmount", query: queryTransaction, value: realAmount ?? 0.00)
            return true
        }
    }
    
    @objc func collectionViedDidScroll() {
        self.view.endEditing(true)
    }
    
    // MARK: - Balance View
    func initBalanceView(left: Bool, traitCollectionDidChange: Bool = false, updatePosition: Bool = false) {
        if traitCollectionDidChange {
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            if userInterfaceStyle == .light {
                balanceView.backgroundColor = .white
                balanceView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                balanceView.rightView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                balanceView.leftView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            } else {
                balanceView.backgroundColor = .black
                balanceView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
                balanceView.rightView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
                balanceView.leftView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            }
            updateBalanceViewPosition(left: left)
        } else {
            balanceView.initView()

            setBalanceViewLabels()
            
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            if userInterfaceStyle == .light {
                balanceView.backgroundColor = .white
                balanceView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            } else {
                balanceView.backgroundColor = .black
                balanceView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            }
            balanceView.translatesAutoresizingMaskIntoConstraints = false
            
            let tab = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            tab.cancelsTouchesInView = false
            balanceView.addGestureRecognizer(tab)
            
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleLeftSwipe(_:)))
            leftSwipe.direction = .left
            leftSwipe.cancelsTouchesInView = false
            balanceView.addGestureRecognizer(leftSwipe)
            
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleRightSwipe(_:)))
            rightSwipe.direction = .right
            rightSwipe.cancelsTouchesInView = false
            balanceView.addGestureRecognizer(rightSwipe)
            
            balanceView.isUserInteractionEnabled = true
            
            self.view.insertSubview(balanceView, aboveSubview: addTable)
            updateBalanceViewPosition(left: left)
        }
    }
    
    func setBalanceViewLabels() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
//        numberFormatter.locale = Locale.current
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSize = 3
        
        let income = numberFormatter.string(for: sumIncome) ?? ""
        let expenses = numberFormatter.string(for: sumExpenses) ?? ""
        let balance = numberFormatter.string(for: (sumIncome - sumExpenses)) ?? ""
        let currencySymbol = getSymbol(forCurrencyCode: "EUR") ?? "€"
        
        if isCenter {
            balanceView.leftLabel.text = expenses + " " + currencySymbol
            balanceView.rightLabel.text = income + " " + currencySymbol
        } else {
            if isLeft {
                balanceView.rightLabel.text = balance + " " + currencySymbol
                balanceView.leftLabel.text = ""
            } else {
                balanceView.leftLabel.text = balance + " " + currencySymbol
                balanceView.rightLabel.text = ""
            }
        }
        balanceView.leftLabel.sizeToFit()
        balanceView.rightLabel.sizeToFit()
        
        widthAnchorConstraint?.isActive = false
        if max(balanceView.rightLabel.frame.width*3,balanceView.leftLabel.frame.width*3)+20 < view.frame.width {
            widthAnchorConstraint = balanceView.widthAnchor.constraint(equalToConstant: max(balanceView.rightLabel.frame.width*3,balanceView.leftLabel.frame.width*3)+20)
        } else {
            widthAnchorConstraint = balanceView.widthAnchor.constraint(equalToConstant: (view.frame.width-10))
        }
        widthAnchorConstraint?.isActive = true
    }
    
    func getSumIncome() -> Double {
        // Get Categories which are incomes
        let incomesCategoriesPredicate = NSPredicate(format: "isIncome == %@ AND isSave == %@", NSNumber(value: true), NSNumber(value: false))
        var incomesCategories = [Int16]()
        for data in dataHandler.loadBulkQueried(entitie: "Categories", query: incomesCategoriesPredicate) {
            incomesCategories.append(data.value(forKey: "cID") as? Int16 ?? 0)
        }
        // Get transactions with those categories
        var sumIncomes = 0.00
        if incomesCategories.count > 0 {
            for data in incomesCategories {
                let incomePredicate = NSPredicate(format: "categoryID == \(data)", NSNumber(value: false))
                for incomes in dataHandler.loadBulkQueried(entitie: "Transactions", query: incomePredicate) {
                    sumIncomes = sumIncomes + ((incomes.value(forKey: "amount") as? Double ?? 0.00) / (incomes.value(forKey: "exchangeRate") as? Double ?? 1.00))
                }
            }
        }
        return sumIncomes
    }
    
    func getSumExpenses() -> Double {
        // Get Categories which are expenses
        let expensesCategoriesPredicate = NSPredicate(format: "isIncome == %@ AND isSave == %@", NSNumber(value: false), NSNumber(value: false))
        var expensesCategories = [Int16]()
        for data in dataHandler.loadBulkQueried(entitie: "Categories", query: expensesCategoriesPredicate) {
            expensesCategories.append(data.value(forKey: "cID") as? Int16 ?? 0)
        }

        // Get transactions with those categories
        var sumExpenses = 0.00
        if expensesCategories.count > 0 {
            for data in expensesCategories {
                let expensePredicate = NSPredicate(format: "categoryID == \(data)", NSNumber(value: false))
                for expenses in dataHandler.loadBulkQueried(entitie: "Transactions", query: expensePredicate) {
                    sumExpenses = sumExpenses + ((expenses.value(forKey: "amount") as? Double ?? 0.00) / (expenses.value(forKey: "exchangeRate") as? Double ?? 1.00))
                }
            }
        }
        return sumExpenses
    }
    
    func updateBalanceViewPosition(left: Bool) {
        self.balanceView.centerHelperView.isHidden = true
        centerXAnchorConstraint?.isActive = false
        if left {
            if isOnEdge {
                centerXAnchorConstraint = balanceView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
                centerXAnchorConstraint?.isActive = true
                balanceView.leftLabel.isHidden = true
                balanceView.leftIcon.isHidden = true
                balanceView.rightLabel.isHidden = true
                balanceView.rightIcon.isHidden = true
            } else {
                centerXAnchorConstraint = balanceView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant:0)
                centerXAnchorConstraint?.isActive = true
                balanceView.leftLabel.isHidden = true
                balanceView.leftIcon.isHidden = true
                balanceView.rightLabel.isHidden = false
                balanceView.rightIcon.isHidden = false
            }
        } else {
            if isOnEdge {
                centerXAnchorConstraint = balanceView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
                centerXAnchorConstraint?.isActive = true
                balanceView.leftLabel.isHidden = true
                balanceView.leftIcon.isHidden = true
                balanceView.rightLabel.isHidden = true
                balanceView.rightIcon.isHidden = true
            } else {
                centerXAnchorConstraint = balanceView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant:0)
                centerXAnchorConstraint?.isActive = true
                balanceView.rightLabel.isHidden = true
                balanceView.rightIcon.isHidden = true
                balanceView.leftLabel.isHidden = false
                balanceView.leftIcon.isHidden = false
            }
        }
        balanceView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        balanceView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(view.frame.height * balanceViewYOffsetFactor)).isActive = true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        isOnEdge = false
        if isCenter && isLeft {
            animateBalanceView(toLeft: false)
        } else if isCenter && !isLeft {
            animateBalanceView(toLeft: true)
        } else if !isCenter {
            animateBalanceView()
        }
    }
    
    @objc func handleLeftSwipe(_ sender: UISwipeGestureRecognizer) {
        if isOnEdge { isOnEdge = false }
        if isCenter {
            isLeft = true
            dataHandler.saveSettings(settingsChange: "isLeft", newValue: isLeft)
            animateBalanceView(toLeft: false)
        } else if !isCenter && !isLeft {
            animateBalanceView(toLeft: false)
        } else if !isCenter && isLeft && !isOnEdge {
            isOnEdge = true
            dataHandler.saveSettings(settingsChange: "isOnEdge", newValue: isOnEdge)
            animateBalanceView(toLeft: isLeft, toEdge: isOnEdge)
        }
    }
    
    @objc func handleRightSwipe(_ sender: UISwipeGestureRecognizer) {
        if isOnEdge { isOnEdge = false }
        if isCenter {
            isLeft = false
            dataHandler.saveSettings(settingsChange: "isLeft", newValue: isLeft)
            animateBalanceView(toLeft: true)
        } else if !isCenter && isLeft {
            animateBalanceView(toLeft: true)
        } else if !isCenter && !isLeft && !isOnEdge {
            isOnEdge = true
            dataHandler.saveSettings(settingsChange: "isOnEdge", newValue: isOnEdge)
            animateBalanceView(toLeft: isLeft, toEdge: isOnEdge)
        }
    }
    
    func animateBalanceView(toLeft: Bool = false, toEdge: Bool = false) {
        let durationAnimation = 0.3
        centerXAnchorConstraint?.isActive = false
        if !toLeft && isCenter {
            isCenter = false
            setBalanceViewLabels()
            centerXAnchorConstraint = balanceView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant:0)
            centerXAnchorConstraint?.isActive = true
            animateToBorder(durationAnimation: durationAnimation, toLeft: toLeft)
        } else if toLeft && isCenter {
            isCenter = false
            setBalanceViewLabels()
            centerXAnchorConstraint = balanceView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant:0)
            centerXAnchorConstraint?.isActive = true
            animateToBorder(durationAnimation: durationAnimation, toLeft: toLeft)
        } else if !isCenter && !toEdge {
            isCenter = true
            setBalanceViewLabels()
            centerXAnchorConstraint = balanceView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            centerXAnchorConstraint?.isActive = true
            animateToCenter(durationAnimation: durationAnimation)
        } else if toLeft && toEdge {
            setBalanceViewLabels()
            centerXAnchorConstraint = balanceView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
            centerXAnchorConstraint?.isActive = true
            animateToBorder(durationAnimation: durationAnimation, toLeft: toLeft)
        } else if !toLeft && toEdge {
            setBalanceViewLabels()
            centerXAnchorConstraint = balanceView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
            centerXAnchorConstraint?.isActive = true
            animateToBorder(durationAnimation: durationAnimation, toLeft: toLeft)
        }
    }
    
    func animateToCenter(durationAnimation: Double) {
        UIView.animate(withDuration: durationAnimation, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        })
        UIView.animate(withDuration: (durationAnimation / 2), delay: 0.0, animations: {
            self.balanceView.rightLabel.isHidden = true
            self.balanceView.rightIcon.isHidden = true
            self.balanceView.leftLabel.isHidden = true
            self.balanceView.leftIcon.isHidden = true
            self.balanceView.rightIcon.alpha = 1.0
            self.balanceView.rightLabel.alpha = 1.0
            self.balanceView.leftIcon.alpha = 1.0
            self.balanceView.leftLabel.alpha = 1.0
        })
        UIView.animate(withDuration: (durationAnimation / 2), delay: durationAnimation, animations: {
            self.balanceView.rightLabel.isHidden = false
            self.balanceView.rightIcon.isHidden = false
            self.balanceView.rightIcon.image = UIImage(systemName: "arrow.down")
            self.balanceView.leftLabel.isHidden = false
            self.balanceView.leftIcon.isHidden = false
            self.balanceView.leftIcon.image = UIImage(systemName: "arrow.up")
            self.balanceView.centerHelperView.isHidden = false
        })
    }
    
    func animateToBorder(durationAnimation: Double, toLeft: Bool) {
        UIView.animate(withDuration: durationAnimation, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            if toLeft {
                self.balanceView.rightIcon.alpha = 0.0
                self.balanceView.rightLabel.alpha = 0.0
            } else {
                self.balanceView.leftIcon.alpha = 0.0
                self.balanceView.leftLabel.alpha = 0.0
            }
        })
        UIView.animate(withDuration: durationAnimation, delay: durationAnimation/2, animations: {
            self.balanceView.rightIcon.image = UIImage(systemName: "arrow.up.arrow.down")
            self.balanceView.leftIcon.image = UIImage(systemName: "arrow.up.arrow.down")
        })
        UIView.animate(withDuration: durationAnimation, delay: durationAnimation, animations: {
            self.balanceView.centerHelperView.isHidden = true
            if toLeft {
                if self.isOnEdge {
                    self.balanceView.leftIcon.isHidden = true
                    self.balanceView.leftLabel.isHidden = true
                } else {
                    self.balanceView.leftIcon.isHidden = false
                    self.balanceView.leftLabel.isHidden = false
                }
                self.balanceView.rightIcon.isHidden = true
            } else {
                if self.isOnEdge {
                    self.balanceView.rightIcon.isHidden = true
                    self.balanceView.rightLabel.isHidden = true
                } else {
                    self.balanceView.rightIcon.isHidden = false
                    self.balanceView.rightLabel.isHidden = false
                }
                self.balanceView.leftIcon.isHidden = true
            }
        })
    }
    
    // MARK: DATEPICKERVIEW
    func initDatepicker() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            datePickerView.backgroundColor = .white
            datePickerView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            
        } else {
            datePickerView.backgroundColor = .black
            datePickerView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            
        }
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        datePickerView.isHidden = true
        datePickerView.initView()
        datePickerView.delegate = self
        self.view.insertSubview(datePickerView, aboveSubview: addTable)
        
        let widthDatePicker = min(400, view.frame.width)
        datePickerView.widthAnchor.constraint(equalToConstant: widthDatePicker).isActive = true
        datePickerView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        datePickerView.centerXAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.centerXAnchor, multiplier: 1.0).isActive = true
        
        datePickerViewYAnchor?.isActive = false
        datePickerViewYAnchor = datePickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10)
        datePickerViewYAnchor?.isActive = true
        view.layoutIfNeeded()
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleDownSwipe(_:)))
        downSwipe.direction = .down
        datePickerView.addGestureRecognizer(downSwipe)
        
        let tab = UITapGestureRecognizer(target: self, action: #selector(self.handleDownSwipe(_:)))
        tab.numberOfTapsRequired = 1
        datePickerView.smallTopView.addGestureRecognizer(tab)
        datePickerView.smallTopView.addGestureRecognizer(downSwipe)
        
        addTable.addGestureRecognizer(tabOutside!)
    }
    
    func showDatePickerView() {
        tabOutside?.isEnabled = true
        addTable.isScrollEnabled = false
        datePickerViewYAnchor?.isActive = false
        datePickerViewYAnchor = datePickerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: (self.tabBarController?.tabBar.frame.height ?? 0)+30)
        datePickerViewYAnchor?.isActive = true
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionFlipFromBottom, animations: {
            self.datePickerView.isHidden = false
            self.view.layoutIfNeeded()
            self.tabBarController?.tabBar.alpha = 0.0
            self.balanceView.alpha = 0.0
        }, completion: nil )
    }
    
    @objc func dismissDatePickerViewTab(_ sender: UITapGestureRecognizer? = nil) {
        dismissDatePickerView()
    }
    
    @objc func dismissDatePickerView() {
        datePickerViewYAnchor?.isActive = false
        datePickerViewYAnchor = datePickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        datePickerViewYAnchor?.isActive = true

        UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionFlipFromBottom, animations: {
            self.view.layoutIfNeeded()
            self.tabBarController?.tabBar.alpha = 1.0
        }, completion: { finished in
            UIView.animate(withDuration: 0.2, animations: {
                self.balanceView.alpha = 1.0
            })
            self.datePickerView.isHidden = true
            self.addTable.isScrollEnabled = true
        })
        tabOutside?.isEnabled = false
    }
    
    @objc func handleDownSwipe(_ sender: UISwipeGestureRecognizer) {
        dismissDatePickerView()
    }
    
    @objc func splitChanged() {
        if split.count != 0 {
            if let cell = addTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellAmountTVC {
                cell.splitBillButton.isHidden = false
                cell.splitBillButton.setTitle(NSLocalizedString("splitButtonEditText", comment: "Edit Split"), for: .normal)
            }
            editSplit = true
        } else {
            if let cell = addTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellAmountTVC {
                cell.splitBillButton.isHidden = false
                cell.splitBillButton.setTitle(NSLocalizedString("splitButtonText", comment: "Split"), for: .normal)
            }
            editSplit = false
        }
    }
    
    func deleteSplit() {
        split.removeAll()
        if let cell = addTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellAmountTVC {
            cell.splitBillButton.isHidden = true
            cell.splitBillButton.setTitle(NSLocalizedString("splitButtonText", comment: "Split"), for: .normal)
        }
        editSplit = false
    }
    
    func showSplitButton() {
        if let cell = addTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellAmountTVC {
            var isSave:Bool = false
            var isIncome:Bool = false
            
            let queryCategory = NSPredicate(format: "cID == %@", (transactionData[4] as? Int16 ?? 0) as NSNumber)
            for category in dataHandler.loadBulkQueried(entitie: "Categories", query: queryCategory) {
                isSave = category.value(forKey: "isSave") as? Bool ?? false
                isIncome = category.value(forKey: "isIncome") as? Bool ?? false
                break
            }
            
            if !isSave && !isIncome && ((transactionData[0] as? String ?? "").count > 0) {
                cell.splitBillButton.isHidden = false
                if editSplit {
                    cell.splitBillButton.setTitle(NSLocalizedString("splitButtonEditText", comment: "Edit Split"), for: .normal)
                } else {
                    cell.splitBillButton.setTitle(NSLocalizedString("splitButtonText", comment: "Split"), for: .normal)
                }
            } else {
                cell.splitBillButton.isHidden = true
            }
        }
        
    }
    
    @objc func deleteTransaction() {
        
        var alertTitle = NSLocalizedString("deleteTitleTransaction", comment: "Delete Transaction Title")
        if superRegularPayment {
            alertTitle = NSLocalizedString("deleteRepeatedTitleTransaction", comment: "Delete Transaction Title")
        }
        
        var alert = UIAlertController(title: alertTitle, message: NSLocalizedString("deleteTextTransaction", comment: "Delete Transaction Text"), preferredStyle: .actionSheet)
        if !UIDevice().model.contains("iPhone") {
            alert = UIAlertController(title: alertTitle, message: NSLocalizedString("deleteTextTransaction", comment: "Delete Transaction Text"), preferredStyle: .alert)
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("deleteYes", comment: "Delete Yes"), style: .destructive, handler: { action in
            let dateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: self.updateCreateDate ?? Date())!
            let dateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: self.updateCreateDate ?? Date())!
            
            if !self.superRegularPayment {
                var deleteTransactionQuery = NSPredicate(format: "dateTime < %@ AND dateTime > %@", dateTransactionPlus as NSDate, dateTransactionMinus as NSDate)
                if ((self.transactionData[10] as? UUID) != nil) {
                    let uuid = (self.transactionData[10] as? UUID ?? UUID()).uuidString
                    deleteTransactionQuery = NSPredicate(format: "uuid == %@", uuid)
                }
                
                if dataHandler.loadQueriedAttribute(entitie: "Transactions", attibute: "isSplit", query: deleteTransactionQuery) as? Int16 ?? 0 != 0 {
                    reloadSplitView = true
                }
                dataHandler.deleteData(entity: "Transactions", query: deleteTransactionQuery)
                
                let deleteSplitsQuery = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", dateTransactionPlus as NSDate, dateTransactionMinus as NSDate)
                dataHandler.deleteData(entity: "Splits", query: deleteSplitsQuery)
                
                let queryDecreaseCategoryCounter = NSPredicate(format: "cID == %@", (self.transactionData[4] as? Int16 ?? 0) as NSNumber)
                var categoryCounter = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "countEntries", query: queryDecreaseCategoryCounter) as? Int64 ?? 1
                categoryCounter = categoryCounter - 1
                dataHandler.saveQueriedAttributeMultiple(entity: "Categories", attribute: "countEntries", query: queryDecreaseCategoryCounter, value: categoryCounter)
            } else {
                let deleteTransactionQuery = NSPredicate(format: "dateTimeNext < %@ AND dateTimeNext > %@", dateTransactionPlus as NSDate, dateTransactionMinus as NSDate)
                dataHandler.deleteData(entity: "RegularPayments", query: deleteTransactionQuery)
                
                let deleteSplitsQuery = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", dateTransactionPlus as NSDate, dateTransactionMinus as NSDate)
                dataHandler.deleteData(entity: "SplitsRegularPayments", query: deleteSplitsQuery)
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.longDate.string(from: (self.updateCreateDate ?? Date()))])
            }
            
            var oldTagsArray = self.oldTags.components(separatedBy: "*;*")
            if oldTagsArray.count > 0 {
                oldTagsArray.remove(at: 0)
            }
            
            for oldTag in oldTagsArray {
                let query = NSPredicate(format: "tagName == %@", NSString(string: oldTag))
                var numberTags = dataHandler.loadQueriedAttribute(entitie: "Tags", attibute: "countEntries", query: query) as? Int16 ?? 0
                numberTags = numberTags - 1
                if numberTags <= 0 {
                    dataHandler.deleteData(entity: "Tags", query: query)
                } else {
                    dataHandler.saveQueriedAttributeMultiple(entity: "Tags", attribute: "countEntries", query: query, value: numberTags)
                }
            }
            
            self.transactionData.removeAll()
            split.removeAll()
            selectedSplitRow.removeAll()
            selectedSplitSegment = nil
            tags.removeAll()
            
//            reloadListView = true
            reloadFinView = true
            reloadGraphView = true
            
            let nc = NotificationCenter.default
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
//                nc.post(name: Notification.Name("groupPersonAdded"), object: nil)
//                nc.post(name: Notification.Name("transactionAdded"), object: nil)
//                nc.post(name: Notification.Name("transactionUpdated"), object: nil)
                nc.post(name: Notification.Name("transactionDeleted"), object: nil)
            })
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("deleteNo", comment: "Delete No"), style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        
        self.present(alert, animated: true)
    }
    
    func saveTransaction(amount: Double) {
        var saveAmount = amount
        
        var seconds = 0.05
        if (transactionData[3] as? String ?? "") == "" {
            let queryCategoryName = NSPredicate(format: "cID == %@", (transactionData[4] as? Int16 ?? 0) as NSNumber)
            let categoryName = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategoryName) as? String ?? ""
            
            if let cell = addTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellAmountTVC {
                cell.descriptionTextField.text = categoryName
            }
            transactionData[3] = categoryName
            seconds = 0.1
        }
        
        if (transactionData[8] as? Bool ?? false) && (transactionData[7] as? Bool ?? false) {
            saveAmount = (-1)*abs(saveAmount)
        }
        var isSave = false
        if addCellRow == 5 {
            isSave = true
        }
        
        if updateCreateDate != nil {
            let dateTimePlus = Calendar.current.date(byAdding: .second, value: 1, to: updateCreateDate ?? Date())!
            let dateTimeMinus = Calendar.current.date(byAdding: .second, value: -1, to: updateCreateDate ?? Date())!
            
            let queryDeleteTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", dateTimePlus as NSDate, dateTimeMinus as NSDate)
            dataHandler.deleteData(entity: "Transactions", query: queryDeleteTransaction)
            
            let queryDeleteSplits = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", dateTimePlus as NSDate, dateTimeMinus as NSDate)
            dataHandler.deleteData(entity: "Splits", query: queryDeleteSplits)
            
            if superRegularPayment {
                let queryDeleteRepeatedTransaction = NSPredicate(format: "dateTimeNext < %@ AND dateTimeNext > %@", dateTimePlus as NSDate, dateTimeMinus as NSDate)
                dataHandler.deleteData(entity: "RegularPayments", query: queryDeleteRepeatedTransaction)
                
                let queryDeleteRepeatedSplits = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", dateTimePlus as NSDate, dateTimeMinus as NSDate)
                dataHandler.deleteData(entity: "SplitsRegularPayments", query: queryDeleteRepeatedSplits)
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [longDate.string(from: (updateCreateDate ?? Date()))])
            }
        }
        
        var doubleTransaction = true
        
        repeat {
            let dateTimeTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (transactionData[5] as? Date ?? Date()))!
            let dateTimeTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (transactionData[5] as? Date ?? Date()))!
            
            let querySaveTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", dateTimeTransactionPlus as NSDate, dateTimeTransactionMinus as NSDate)
            
            if dataHandler.loadBulkQueried(entitie: "Transactions", query: querySaveTransaction).count > 0 {
                doubleTransaction = true
                transactionData[5] = dateTimeTransactionPlus
            } else {
                doubleTransaction = false
            }
        } while doubleTransaction
        
        if repeatTransaction && (transactionData[5] as? Date ?? Date()) > Date() {
            afterTransactionSave(seconds: seconds, isSave: isSave, futureRepeatTransaction: true, amount: saveAmount)
        } else {
            beforeTransactionSave(saveAmount: saveAmount, isSave: isSave, seconds: seconds)
        }
    }
    
    func beforeTransactionSave(saveAmount: Double, isSave: Bool, seconds: Double) {
        let saveTransactionReturn = dataHandler.saveTransaction(amount: saveAmount, category: transactionData[4] as? Int16 ?? 0, currencyCode: transactionData[1] as? String ?? "EUR", dateTime: transactionData[5] as? Date ?? Date(), descriptionNote: transactionData[3] as? String ?? "", exchangeRate: currencyExchangeRate ?? 1.0, tags: transactionData[6] as? String ?? "", isSave: isSave, isLiquid: transactionData[9] as? Bool ?? true)
        if saveTransactionReturn.0 {
            transactionDateTime = saveTransactionReturn.1
            afterTransactionSave(seconds: seconds, isSave: isSave, futureRepeatTransaction: false, amount: saveAmount)
        }
    }
    
    func afterTransactionSave(seconds: Double, isSave: Bool, futureRepeatTransaction: Bool, amount: Double) {
        var nextDateTime:Date?
        saveNewTag(newTags: transactionData[6] as? String ?? "")
        
        if repeatTransaction {
            if !futureRepeatTransaction {
                switch repeatFrequency {
                case 0: // Weekly
                    nextDateTime = Calendar.current.date(byAdding: .day, value: 7, to: (transactionData[5] as? Date ?? Date()))!
                    break
                case 1: // Monthly
                    nextDateTime = Calendar.current.date(byAdding: .month, value: 1, to: (transactionData[5] as? Date ?? Date()))!
                    break
                case 2: // Yearly
                    nextDateTime = Calendar.current.date(byAdding: .year, value: 1, to: (transactionData[5] as? Date ?? Date()))!
                    break
                default: // Daily
                    nextDateTime = Calendar.current.date(byAdding: .day, value: 1, to: (transactionData[5] as? Date ?? Date()))!
                    break
                }
            } else {
                nextDateTime = (transactionData[5] as? Date ?? Date())
            }
            
            let nextDateTimeOriginal = nextDateTime
            if skipWeekends {
                if Calendar.current.dateComponents([.weekday], from: nextDateTime ?? Date()).weekday == 1 {
                    nextDateTime = Calendar.current.date(byAdding: .day, value: 1, to: nextDateTime ?? Date())!
                } else if Calendar.current.dateComponents([.weekday], from: nextDateTime ?? Date()).weekday == 7 {
                    nextDateTime = Calendar.current.date(byAdding: .day, value: 2, to: nextDateTime ?? Date())!
                }
            }
            
            var doubleTransaction = true
            
            repeat {
                let dateTimeTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: nextDateTime ?? (transactionData[5] as? Date ?? Date()))!
                let dateTimeTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: nextDateTime ?? (transactionData[5] as? Date ?? Date()))!
                
                let querySaveTransaction = NSPredicate(format: "dateTimeNext < %@ AND dateTimeNext > %@", dateTimeTransactionPlus as NSDate, dateTimeTransactionMinus as NSDate)
                
                if dataHandler.loadBulkQueried(entitie: "RegularPayments", query: querySaveTransaction).count > 0 {
                    doubleTransaction = true
                    nextDateTime = dateTimeTransactionPlus
                } else {
                    doubleTransaction = false
                }
            } while doubleTransaction
            
            saveRepeatedTransaction(dateTimeNext: nextDateTime ?? (transactionData[5] as? Date ?? Date()), isSave: isSave, amount: amount, repeatFrequency: repeatFrequency, dateTimeNextOriginal: nextDateTimeOriginal ?? Date())
            if futureRepeatTransaction {
                transactionDateTime = nextDateTime ?? (transactionData[5] as? Date ?? Date())
            }
            
            let comps = Calendar.current.dateComponents([.year, .month, .day , .hour, .minute, .second], from: nextDateTime ?? Date())
            let notificationMsg = NSLocalizedString("regularPaymentsTitle", comment: "Regular Payment") + ": " + (transactionData[3] as? String ?? "") + " " + NSLocalizedString("hasBeenAdded", comment: "has been added")
            
            manager.notifications = [LocalNotificationManager.Notification(id: longDate.string(from: nextDateTime ?? Date()), title: notificationMsg, datetime: comps)]
            manager.schedule()
            
            if !futureRepeatTransaction {
                let triggerNow = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                
                let categoryIdentifire = "Added Notification Type"
                let msgContent      = UNMutableNotificationContent()
                msgContent.title = NSLocalizedString("transactionAddedNotificationTitle", comment: "Added")
                msgContent.body = notificationMsg
                msgContent.sound = .default
                msgContent.categoryIdentifier = categoryIdentifire
                
                let requestNow = UNNotificationRequest(identifier: "now", content: msgContent, trigger: triggerNow)
                
                UNUserNotificationCenter.current().add(requestNow) { (error) in
                        if let error = error {
                            print("Error \(error.localizedDescription)")
                        }
                    }
                
                let category = UNNotificationCategory(identifier: categoryIdentifire, actions: [], intentIdentifiers: [], options: [])
                UNUserNotificationCenter.current().setNotificationCategories([category])
            }
        }
        
        if dataHandler.incrementCategoryCount(id: transactionData[4] as? Int16 ?? 0, oldID: oldCategoryID ?? -1, futureRepeatTransaction: futureRepeatTransaction) && saveRealAmount(dateTime: transactionDateTime ?? Date(), futureRepeatTransaction: futureRepeatTransaction, nextDateTime: nextDateTime) {
            let nc = NotificationCenter.default
            if self.updateCreateDate != nil {
                nc.post(name: Notification.Name("transactionUpdated"), object: nil, userInfo: ["transactionCreateDate": (self.transactionData[5] as? Date ?? Date()), "oldCreateDate":(updateCreateDate ?? Date())])
                nc.post(name: Notification.Name("updateFinVC"), object: nil)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    nc.post(name: Notification.Name("transactionAdded"), object: nil)
                })
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: {
                self.dismissDatePickerView()
                reloadCategoryView = true
                self.initTransactionData()
                self.addTable.reloadData()
            })

            tags.removeAll()
            if (addTable.cellForRow(at: IndexPath(row: 3, section: 0)) != nil && !isSave) || (addTable.cellForRow(at: IndexPath(row: 4, section: 0)) != nil && isSave) {
                var cell:cellAddTVC?
                if isSave {
                    cell = addTable.cellForRow(at: IndexPath(row: 4, section: 0)) as? cellAddTVC
                } else {
                    cell = addTable.cellForRow(at: IndexPath(row: 3, section: 0)) as? cellAddTVC
                }
                let ramText = cell?.addButton.title(for: .normal)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    cell?.addButton.setTitle(ramText, for: .normal)
                })
                cell?.addButton.setTitle(NSLocalizedString("addButtonAddedText", comment: "Add"), for: .normal)
            }
            
            if split.count > 0 {
                reloadSplitView = true
                nc.post(name: Notification.Name("groupPersonAdded"), object: nil)
            }
            
            split.removeAll()
            deleteSplit()
//            reloadListView = true
//            reloadFinView = true
            reloadGraphView = true
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    func saveRepeatedTransaction(dateTimeNext: Date, isSave: Bool, amount: Double, repeatFrequency: Int, dateTimeNextOriginal: Date) {
        dataHandler.saveRepeatTransaction(amount: amount, category: transactionData[4] as? Int16 ?? 0, currencyCode: transactionData[1] as? String ?? "EUR", dateTimeNext: dateTimeNext, descriptionNote: transactionData[3] as? String ?? "", exchangeRate: currencyExchangeRate ?? 1.0, tags: transactionData[6] as? String ?? "", isSave: isSave, isLiquid: transactionData[9] as? Bool ?? true, repeatFrequency: repeatFrequency, skipWeekends: skipWeekends, dateTimeNextOriginal: dateTimeNextOriginal)
    }
    
    func initCategories() {
        if (dataHandler.loadBulkData(entitie: "Categories", orderBy: "cID")).count <= 0 {
            
            let categoryTitle = NSLocalizedString("createCategoriesTitle", comment: "Delete Transaction Title")
            let categoryPrompt = UIAlertController(title: categoryTitle, message: NSLocalizedString("createCategoriesText", comment: "Create Categories Text"), preferredStyle: .alert)

            categoryPrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteYes", comment: "Delete Yes"), style: .default, handler: { action in
            
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
                self.cancel()
            }))
            categoryPrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteNo", comment: "Delete No"), style: .cancel, handler: { action in
                self.cancel()
            }))
            
            categoryPrompt.popoverPresentationController?.sourceView = self.view
            categoryPrompt.popoverPresentationController?.sourceRect = self.view.bounds
            
            self.present(categoryPrompt, animated: true)
        }
    }
    
    func checkDoubleUser() {
        let query = NSPredicate(format: "isUser == %@", NSNumber(value: true))
        let users = dataHandler.loadBulkQueried(entitie: "SplitPersons", query: query)

        if users.count > 1 {
            // Splits
            // SplitsRegularPayments
            // SplitGroups
            var trueUserName:String = NSLocalizedString("userTitle", comment: "User")
            var trueUserDate:Date?
            
            let entries = dataHandler.loadBulkQueriedSorted(entitie: "SplitPersons", query: query, sort: [NSSortDescriptor(key: "createDate", ascending: true)])
            
            var i = 1
            for user in entries {
                if (user.value(forKey: "namePerson") as? String ?? "") != NSLocalizedString("userTitle", comment: "User") || i == (entries.count) {
                    trueUserName = user.value(forKey: "namePerson") as? String ?? ""
                    trueUserDate = user.value(forKey: "createDate") as? Date ?? Date()
                    break
                } else {
                    trueUserDate = user.value(forKey: "createDate") as? Date ?? Date()
                }
                i = i + 1
            }
            dataHandler.saveSettings(settingsChange: "userName", newValue: trueUserName )
            for user in dataHandler.loadBulkQueriedSorted(entitie: "SplitPersons", query: query, sort: [NSSortDescriptor(key: "createDate", ascending: false)]) {
                // Splits
                let userWrongPlus = Calendar.current.date(byAdding: .second, value: 1, to: user.value(forKey: "createDate") as? Date ?? Date())!
                let userWrongMinus = Calendar.current.date(byAdding: .second, value: -1, to: user.value(forKey: "createDate") as? Date ?? Date())!
                
                let userWrongName = user.value(forKey: "namePerson") as? String ?? ""
                
                let up = (trueUserDate ?? Date()).compare(userWrongPlus) == .orderedAscending
                let down = (trueUserDate ?? Date()).compare(userWrongMinus) == .orderedDescending
                
                if !(up && down && userWrongName == trueUserName) {
                    let querySplits = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", userWrongPlus as NSDate, userWrongMinus as NSDate, userWrongName as NSString)
                    
                    dataHandler.saveQueriedAttributeMultiple(entity: "Splits", attribute: "namePerson", query: querySplits, value: trueUserName )
                    dataHandler.saveQueriedAttributeMultiple(entity: "Splits", attribute: "createDatePerson", query: querySplits, value: trueUserDate ?? Date())
                        
                    let querySplitsPaid = NSPredicate(format: "createDatePersonWhoPaid < %@ AND createDatePersonWhoPaid > %@ AND namePersonWhoPaid == %@", userWrongPlus as NSDate, userWrongMinus as NSDate, userWrongName as NSString)
                        
                    dataHandler.saveQueriedAttributeMultiple(entity: "Splits", attribute: "namePersonWhoPaid", query: querySplitsPaid, value: trueUserName )
                    dataHandler.saveQueriedAttributeMultiple(entity: "Splits", attribute: "createDatePersonWhoPaid", query: querySplitsPaid, value: trueUserDate ?? Date())
                    
                    // SplitsRegularPayments
                    dataHandler.saveQueriedAttributeMultiple(entity: "SplitsRegularPayments", attribute: "namePerson", query: querySplits, value: trueUserName )
                    dataHandler.saveQueriedAttributeMultiple(entity: "SplitsRegularPayments", attribute: "createDatePerson", query: querySplits, value: trueUserDate ?? Date())
                        
                    let querySplitsPaidSecond = NSPredicate(format: "createDatePersonWhoPaid < %@ AND createDatePersonWhoPaid > %@ AND namePersonWhoPaid == %@", userWrongPlus as NSDate, userWrongMinus as NSDate, userWrongName as NSString)
                        
                    dataHandler.saveQueriedAttributeMultiple(entity: "SplitsRegularPayments", attribute: "namePersonWhoPaid", query: querySplitsPaidSecond, value: trueUserName )
                    dataHandler.saveQueriedAttributeMultiple(entity: "SplitsRegularPayments", attribute: "createDatePersonWhoPaid", query: querySplitsPaidSecond, value: trueUserDate ?? Date())
                    
                    // Groups
                    let dateFormatter = ISO8601DateFormatter()
                    
                    let userWrongGroupSting = userWrongName + "*&*" + dateFormatter.string(from: user.value(forKey: "createDate") as? Date ?? Date())
                    let trueUserGroupSting = (trueUserName ) + "*&*" + dateFormatter.string(from: trueUserDate ?? Date())
                    
                    for group in dataHandler.loadBulkSorted(entitie: "SplitGroups", sort: [NSSortDescriptor(key: "createDate", ascending: false)]) {
                        if (group.value(forKey: "persons") as? String ?? "").contains(userWrongGroupSting) {
                            var stringToReplace = (group.value(forKey: "persons") as? String ?? "")
                            stringToReplace = stringToReplace.replacingOccurrences(of: userWrongGroupSting, with: trueUserGroupSting)
                            
                            let groupWrongPlus = Calendar.current.date(byAdding: .second, value: 1, to: group.value(forKey: "createDate") as? Date ?? Date())!
                            let groupWrongMinus = Calendar.current.date(byAdding: .second, value: -1, to: group.value(forKey: "createDate") as? Date ?? Date())!
                            
                            let queryGroupSave = NSPredicate(format: "createDate < %@ AND createDate > %@ AND nameGroup == %@", groupWrongPlus as NSDate, groupWrongMinus as NSDate, (group.value(forKey: "nameGroup") as? String ?? "") as NSString)
                            
                            dataHandler.saveQueriedAttributeMultiple(entity: "SplitGroups", attribute: "persons", query: queryGroupSave, value: stringToReplace)
                        }
                    }
                    let queryWrongUser = NSPredicate(format: "createDate < %@ AND createDate > %@ AND namePerson == %@", userWrongPlus as NSDate, userWrongMinus as NSDate, userWrongName as NSString)
                    dataHandler.deleteData(entity: "SplitPersons", query: queryWrongUser)
                }
            }
            checkDoubleUser()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        receiptImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        imagePickerController.dismiss(animated: true, completion: {
            self.receiptTransaction = true
            self.imageUpdated()
        })
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier ?? "") {
        case "splitSeque":
            guard let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.topViewController as? splitTransactionSelectTVC
            else {
                fatalError()
            }
            viewController.amount = amount ?? 0.00
            break
        case "selectCurrencySeque":
            guard let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.topViewController as? currencyPickerVC
            else {
                fatalError()
            }
            viewController.lastCurrencyCode = transactionData[1] as? String ?? "EUR"
            break
        default:
            break
        }
    }
}

extension addTVC: datePickerViewDelegate {
    func updateCellAfterRemove(selectedDate: Date) {
//        if addTable.cellForRow(at: IndexPath(row: 1, section: 0)) != nil {
//            let cell = addTable.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellDateTVC
//            cell?.dateButton.setTitle(shortDate.string(from: selectedDate), for: .normal)
//        }
        transactionData[5] = selectedDate
    }
}

extension addTVC: cellDateDelegate {
    func showPopOverDatePicker(button: UIButton, cell: cellDateTVC) {
        if datePickerView.isHidden {
            showDatePickerView()
        } else {
            dismissDatePickerView()
        }
    }
    func dateChangedButton(dateSelected: Date) {
        transactionData[5] = dateSelected
    }
}

extension addTVC: cellDateNewDelegate {
    func dateChanged(dateSelected: Date) {
        transactionData[5] = dateSelected
    }
    
    func repeatSegmentChanged(selected: Int) {
        repeatFrequency = selected
    }
    
    func skipWeekendChanges(switchOn: Bool) {
        skipWeekends = switchOn
    }
}

extension addTVC: cellTagAddDelegate {
    func cameraButtonPressed() {
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func currencyButtonPressed() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "selectCurrencySeque", sender: nil)
        }
    }
    
    func addTagPrompt(tagListView: TagListView, tagAddListView: TagListView, indexPath: IndexPath) {
        ac = UIAlertController(title: NSLocalizedString("Add Tag", comment: "Add Tag Prompt Title"), message: NSLocalizedString("Add Tag Text", comment: "Add Tag Prompt Text"), preferredStyle: .alert)
        ac?.addTextField()
        
        let submitAction = UIAlertAction(title: NSLocalizedString("addTagButton", comment: "Add Tag"), style: .default) { [unowned ac] _ in
            let answer = ac?.textFields![0]
            if answer?.text?.contains("*;*") ?? false {
                let answerError = UIAlertController(title: NSLocalizedString("Tag *;* Error Title", comment: "Tag *;* Error Title"), message: NSLocalizedString("Tag *;* Error Text", comment: "Tag *;* Error Text"), preferredStyle: .alert)
                answerError.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "forgotCodeOK"), style: .cancel, handler: nil))
                                
                answerError.popoverPresentationController?.sourceView = self.view
                answerError.popoverPresentationController?.sourceRect = self.view.bounds
                
                self.present(answerError, animated: true)
                self.addTable.reloadRows(at: [indexPath], with: .none)
            } else if answer?.text != "" {
                var alreadyInTagList: Bool = false
                for activeTags in tags {
                    if activeTags.value["Title"] as? String ?? "" == answer?.text {
                        alreadyInTagList = true
                        break
                    }
                }
                if alreadyInTagList {
                    let answerError = UIAlertController(title: NSLocalizedString("Tag Already In List Title", comment: "Tag Already In List Title"), message: NSLocalizedString("Tag Already In List Text", comment: "Tag Already In List Text"), preferredStyle: .alert)
                    answerError.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "forgotCodeOK"), style: .cancel, handler: nil))
                    answerError.popoverPresentationController?.sourceView = self.view
                    answerError.popoverPresentationController?.sourceRect = self.view.bounds
                    self.present(answerError, animated: true)
                    self.addTable.reloadRows(at: [indexPath], with: .none)
                } else {
                    var newTagPosition = 0
                    let colorInt = self.getTagColor(tagName: answer?.text ?? "New Tag")
                    
                    for i in 0...999 {
                        if tags[i] == nil {
                            newTagPosition = i
                            break
                        }
                    }
                    
                    tags[newTagPosition] = [
                        "Title":answer?.text ?? "New Tag",
                        "Color":colorInt
                    ]
                    self.addTable.reloadRows(at: [indexPath], with: .none)
                    self.transactionData[6] = String(self.transactionData[6] as? String ?? "") + "*;*" + String(answer?.text ?? "New Tag")
                    self.showSplitButton()
                }
            } else {
                self.addTable.reloadRows(at: [indexPath], with: .none)
                self.showSplitButton()
            }
        }
        
        tagsStackView.removeFullyAllArrangedSubviews()
        tagsStackView.axis = .horizontal
        tagsStackView.alignment = .center
        tagsStackView.distribution = .fillEqually
        tagsStackView.backgroundColor = .systemBackground
        var i = 0
        for tag in dataHandler.loadBulkSorted(entitie: "Tags", sort: [NSSortDescriptor(key: "lastUsed", ascending: false)]) {
            let tabButton = UIButton(type: .system)
            tabButton.addTarget(self, action: #selector(selectTag(_:)), for: .touchUpInside)
            tabButton.setTitle((tag.value(forKey: "tagName") as? String), for: .normal)
            tabButton.setTitleColor(.label, for: .normal)
//            tabButton.titleLabel?.adjustsFontSizeToFitWidth = true
            
            tagsStackView.addArrangedSubview(tabButton)
            i = i + 1
            if i >= 3 {
                break
            }
        }
        ac?.addAction(UIAlertAction(title: NSLocalizedString("cancelImport", comment: "Cancel"), style: .cancel, handler: { _ in
            self.addTable.reloadRows(at: [indexPath], with: .none)
        }))
        ac?.addAction(submitAction)
        ac?.textFields?[0].inputAccessoryView = tagsStackView
        ac?.textFields?[0].addTarget(self, action: #selector(self.tagTextFieldDidChange(_:)), for: .editingChanged)
        ac?.popoverPresentationController?.sourceView = self.view
        ac?.popoverPresentationController?.sourceRect = self.view.bounds
        if ac != nil {
            present(ac!, animated: true)
        }
    }
    
    @objc func selectTag(_ sender:UIButton!) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = sender.transform.scaledBy(x: 0.9, y: 0.9)
            }, completion: { _ in
              UIView.animate(withDuration: 0.1, animations: {
                sender.transform = CGAffineTransform.identity
              }, completion: { _ in
                self.ac?.textFields?[0].text = sender.titleLabel?.text
                if self.ac?.textFields?[0] != nil {
                    self.tagTextFieldDidChange((self.ac?.textFields?[0])!)
                }
              })
            })
    }
    
    @objc func tagTextFieldDidChange(_ sender:UITextField) {
        tagsStackView.removeFullyAllArrangedSubviews()
        if (sender.text?.count ?? 0) > 0 {
            let query = NSPredicate(format: "tagName == %@ OR tagName CONTAINS[c] %@", (sender.text ?? "-") as NSString, (sender.text ?? "-") as NSString)
            var i = 0
            for tag in dataHandler.loadBulkQueriedSorted(entitie: "Tags", query: query, sort: [NSSortDescriptor(key: "tagName", ascending: true)]) {
                let tabButton = UIButton(type: .system)
                tabButton.addTarget(self, action: #selector(selectTag(_:)), for: .touchUpInside)
                tabButton.setTitle((tag.value(forKey: "tagName") as? String), for: .normal)
                tabButton.setTitleColor(.label, for: .normal)
                
                tagsStackView.addArrangedSubview(tabButton)
                i = i + 1
                if i >= 3 {
                    break
                }
            }
        } else {
            var i = 0
            for tag in dataHandler.loadBulkSorted(entitie: "Tags", sort: [NSSortDescriptor(key: "lastUsed", ascending: false)]) {
                let tabButton = UIButton(type: .system)
                tabButton.addTarget(self, action: #selector(selectTag(_:)), for: .touchUpInside)
                tabButton.setTitle((tag.value(forKey: "tagName") as? String), for: .normal)
                tabButton.setTitleColor(.label, for: .normal)
                
                tagsStackView.addArrangedSubview(tabButton)
                i = i + 1
                if i >= 3 {
                    break
                }
            }
        }
    }
    
    func updateCellAfterRemove(indexPath: IndexPath) {
        self.addTable.reloadRows(at: [indexPath], with: .none)
        transactionData[6] = ""
        if tags.count > 0 {
            for (_,value) in tags.enumerated() {
                transactionData[6] = (transactionData[6] as? String ?? "") + "*;*" + (value.value["Title"] as? String ?? "")
            }
        }
        showSplitButton()
    }
    
    func textFieldEdited(text: String, tag: Int) {
        if tag == 0 {
            transactionData[0] = text
            if let cell = addTable.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellAmountTVC {
                let amountFormatter = NumberFormatter()
                amountFormatter.locale = .current
                let thSep:String = Locale.current.groupingSeparator ?? ","
                cell.amountTextField.text = numberFormatter.string(from: NSNumber(value: (amountFormatter.number(from: (transactionData[0] as? String ?? "0").replacingOccurrences(of: thSep, with: "")) as? Double) ?? 0.00))
            }
            showSplitButton()
        } else {
            transactionData[3] = text
        }
    }
    
    func splitButtonPressed(amountValue:String) {
        amount = numberFormatter.number(from: amountValue) as? Double ?? 0.00
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "splitSeque", sender: nil)
        }
    }
}

extension addTVC: cellNewCategoryTVCDelegate {
    func categoryPicked(category: [Int:Any]) {
        if let cell = addTable.cellForRow(at: IndexPath(row: addCellRow, section: 0)) as? cellAddTVC {
            if category[3] as? Bool ?? false { // isIncome
                deleteSplit()
                if (category[4] as? Bool ?? false) { // isSave
                    transactionData[7] = true // isSave
                    if (transactionData[8] as? Bool ?? false) { // is Withdraw
                        if transactionData[9] as? Bool ?? false { // isLiquid
                            cell.addButton.setTitle(NSLocalizedString("addButtonSaveWithdrawText", comment: "Withdraw from Savings"), for: .normal)
                        } else {
                            cell.addButton.setTitle(NSLocalizedString("addButtonSaveDecreaseText", comment: "Decrease Savings"), for: .normal)
                        }
                    } else { // is Deposit
                        if transactionData[9] as? Bool ?? false { // isLiquid
                            cell.addButton.setTitle(NSLocalizedString("addButtonSaveAddText", comment: "Deposit to Savings"), for: .normal)
                        } else {
                            cell.addButton.setTitle(NSLocalizedString("addButtonSaveIncreaseText", comment: "Increase Savings"), for: .normal)
                        }
                    }
                    if addCellRow == 4 {
                        addCellRow = 5
                        addTable.insertRows(at: [IndexPath(row: (addCellRow-2), section: 0)], with: .automatic)
                    }
                    
                    if let cellSave = addTable.cellForRow(at: IndexPath(row: (addCellRow-2), section: 0)) as? cellSaveDeposit {
                        if (transactionData[8] as? Bool ?? false) {
                            cellSave.segmentControl.selectedSegmentIndex = 1
                        } else {
                            cellSave.segmentControl.selectedSegmentIndex = 0
                        }
                        if (transactionData[9] as? Bool ?? false) { // isLiquid
                            cellSave.segmentControl.setTitle(NSLocalizedString("segmentDepositText", comment: "Deposit"), forSegmentAt: 0)
                            cellSave.segmentControl.setTitle(NSLocalizedString("segmentWithdrawText", comment: "Withdraw"), forSegmentAt: 1)
                        } else {
                            cellSave.segmentControl.setTitle(NSLocalizedString("segmentIncreaseText", comment: "Increase"), forSegmentAt: 0)
                            cellSave.segmentControl.setTitle(NSLocalizedString("segmentDecreaseText", comment: "Decrease"), forSegmentAt: 1)
                        }
                    }
                } else {
                    transactionData[7] = false // isSave NOT
                    if updateCreateDate != nil {
                        cell.addButton.setTitle(NSLocalizedString("updateButtonIncomeText", comment: "Update Income"), for: .normal)
                    } else {
                        cell.addButton.setTitle(NSLocalizedString("addButtonIncomeText", comment: "Add to Income"), for: .normal)
                    }
                    if addCellRow == 5 {
                        addCellRow = 4
                        addTable.deleteRows(at: [IndexPath(row: (addCellRow-1), section: 0)], with: .fade)
                    }
                }
            } else {
                if (category[4] as? Bool ?? false) { // isSave
                    transactionData[7] = true // isSave
                    deleteSplit()
                    if (transactionData[8] as? Bool ?? false) { // is Withdraw
                        if (transactionData[9] as? Bool ?? false) { // isLiquid
                            cell.addButton.setTitle(NSLocalizedString("addButtonSaveWithdrawText", comment: "Withdraw from Savings"), for: .normal)
                        } else {
                            cell.addButton.setTitle(NSLocalizedString("addButtonSaveDecreaseText", comment: "Decrease Savings"), for: .normal)
                        }
                    } else {
                        if transactionData[9] as? Bool ?? false { // isLiquid
                            cell.addButton.setTitle(NSLocalizedString("addButtonSaveAddText", comment: "Deposit to Savings"), for: .normal)
                        } else {
                            cell.addButton.setTitle(NSLocalizedString("addButtonSaveIncreaseText", comment: "Increase Savings"), for: .normal)
                        }
                    }
                    if addCellRow == 4 {
                        addCellRow = 5
                        addTable.insertRows(at: [IndexPath(row: (addCellRow-2), section: 0)], with: .automatic)
                    }
                    
                    if let cellSave = addTable.cellForRow(at: IndexPath(row: (addCellRow-2), section: 0)) as? cellSaveDeposit {
                        if (transactionData[8] as? Bool ?? false) {
                            cellSave.segmentControl.selectedSegmentIndex = 1
                        } else {
                            cellSave.segmentControl.selectedSegmentIndex = 0
                        }
                        if (transactionData[9] as? Bool ?? false) { // isLiquid
                            cellSave.segmentControl.setTitle(NSLocalizedString("segmentDepositText", comment: "Deposit"), forSegmentAt: 0)
                            cellSave.segmentControl.setTitle(NSLocalizedString("segmentWithdrawText", comment: "Withdraw"), forSegmentAt: 1)
                        } else {
                            cellSave.segmentControl.setTitle(NSLocalizedString("segmentIncreaseText", comment: "Increase"), forSegmentAt: 0)
                            cellSave.segmentControl.setTitle(NSLocalizedString("segmentDecreaseText", comment: "Decrease"), forSegmentAt: 1)
                        }
                    }
                } else {
                    transactionData[7] = false // isSave NOT
                    if updateCreateDate != nil {
                        cell.addButton.setTitle(NSLocalizedString("updateButtonExpenseText", comment: "Add to Expenses"), for: .normal)
                    } else {
                        cell.addButton.setTitle(NSLocalizedString("addButtonExpenseText", comment: "Add to Expenses"), for: .normal)
                    }
                    if addCellRow == 5 {
                        addCellRow = 4
                        addTable.deleteRows(at: [IndexPath(row: (addCellRow-1), section: 0)], with: .fade)
                    }
                }
            }
        }
        transactionData[4] = category[0] as? Int16 ?? -1
        showSplitButton()
    }
}

extension addTVC: cellSaveDepositDelegate {
    func saveChanged(selected: Int) {
        if selected == 0 {
            transactionData[8] = false // Deposit
            if let cell = addTable.cellForRow(at: IndexPath(row: addCellRow, section: 0)) as? cellAddTVC {
                if (transactionData[9] as? Bool ?? false) {
                    cell.addButton.setTitle(NSLocalizedString("addButtonSaveAddText", comment: "Deposit to Savings"), for: .normal)
                } else {
                    cell.addButton.setTitle(NSLocalizedString("addButtonSaveIncreaseText", comment: "Increase Savings"), for: .normal)
                }
            }
        } else {
            transactionData[8] = true // Withdraw
            if let cell = addTable.cellForRow(at: IndexPath(row: addCellRow, section: 0)) as? cellAddTVC {
                if (transactionData[9] as? Bool ?? false) {
                    cell.addButton.setTitle(NSLocalizedString("addButtonSaveWithdrawText", comment: "Withdraw from Savings"), for: .normal)
                } else {
                    cell.addButton.setTitle(NSLocalizedString("addButtonSaveDecreaseText", comment: "Decrease Savings"), for: .normal)
                }
            }
        }
    }
    
    func liquidInfoButtonPressed() {
        let infoAlert = UIAlertController(title: NSLocalizedString("liquidInfoTitle", comment: "Liquid Info Title"), message: NSLocalizedString("liquidInfoText", comment: "Liquid Info Text"), preferredStyle: .alert)
        infoAlert.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "forgotCodeOK"), style: .cancel, handler: nil))
        infoAlert.popoverPresentationController?.sourceView = self.view
        infoAlert.popoverPresentationController?.sourceRect = self.view.bounds
        
        self.present(infoAlert, animated: true)
    }
    
    func liquidSwitchChanged(newState:Bool) {
        transactionData[9] = newState
        if let cellSave = addTable.cellForRow(at: IndexPath(row: (addCellRow-1), section: 0)) as? cellSaveDeposit {
            if let cellAdd = addTable.cellForRow(at: IndexPath(row: addCellRow, section: 0)) as? cellAddTVC {
                if (transactionData[7] as? Bool ?? false) && !(transactionData[9] as? Bool ?? false) && (transactionData[8] as? Bool ?? true) { // if isSave, isLiquid, isWithdraw
                    // Set Segment to Increase/Decrease. Selected Segment: 1
                    cellSave.segmentControl.setTitle(NSLocalizedString("segmentIncreaseText", comment: "Increase"), forSegmentAt: 0)
                    cellSave.segmentControl.setTitle(NSLocalizedString("segmentDecreaseText", comment: "Decrease"), forSegmentAt: 1)
                    cellSave.segmentControl.selectedSegmentIndex = 1
                    cellAdd.addButton.setTitle(NSLocalizedString("addButtonSaveDecreaseText", comment: "Decrease Savings"), for: .normal)
                } else if (transactionData[7] as? Bool ?? false) && !(transactionData[9] as? Bool ?? false) && !(transactionData[8] as? Bool ?? true) { // if isSave, isLiquid, !isWithdraw
                    // Set Segment to Increase/Decrease. Selected Segment: 0
                    cellSave.segmentControl.setTitle(NSLocalizedString("segmentIncreaseText", comment: "Increase"), forSegmentAt: 0)
                    cellSave.segmentControl.setTitle(NSLocalizedString("segmentDecreaseText", comment: "Decrease"), forSegmentAt: 1)
                    cellSave.segmentControl.selectedSegmentIndex = 0
                    cellAdd.addButton.setTitle(NSLocalizedString("addButtonSaveIncreaseText", comment: "Increase Savings"), for: .normal)
                } else if (transactionData[7] as? Bool ?? false) && (transactionData[9] as? Bool ?? false) && (transactionData[8] as? Bool ?? true) { // if isSave, !isLiquid, isWithdraw
                    // Set Segment to Deposit/Witdraw. Selected Segment: 1
                    cellSave.segmentControl.setTitle(NSLocalizedString("segmentDepositText", comment: "Deposit"), forSegmentAt: 0)
                    cellSave.segmentControl.setTitle(NSLocalizedString("segmentWithdrawText", comment: "Withdraw"), forSegmentAt: 1)
                    cellSave.segmentControl.selectedSegmentIndex = 1
                    cellAdd.addButton.setTitle(NSLocalizedString("addButtonSaveWithdrawText", comment: "Withdraw from Savings"), for: .normal)
                } else if (transactionData[7] as? Bool ?? false) && (transactionData[9] as? Bool ?? false) && !(transactionData[8] as? Bool ?? true) { // if isSave, !isLiquid, !isWithdraw
                    // Set Segment to Deposit/Witdraw. Selected Segment: 0
                    cellSave.segmentControl.setTitle(NSLocalizedString("segmentDepositText", comment: "Deposit"), forSegmentAt: 0)
                    cellSave.segmentControl.setTitle(NSLocalizedString("segmentWithdrawText", comment: "Withdraw"), forSegmentAt: 1)
                    cellSave.segmentControl.selectedSegmentIndex = 0
                    cellAdd.addButton.setTitle(NSLocalizedString("addButtonSaveAddText", comment: "Withdraw from Savings"), for: .normal)
                }
            }
        }
    }
}

extension addTVC: cellAddPressedDelegate {
    func addPressed() {
        let amountFormatter = NumberFormatter()
        amountFormatter.locale = .current
        
        let thSep:String = Locale.current.groupingSeparator ?? ","
        
        if let saveAmount = amountFormatter.number(from: (transactionData[0] as? String ?? "0").replacingOccurrences(of: thSep, with: "")) as? Double {
            saveTransaction(amount: saveAmount)
        } else {
            let answerError = UIAlertController(title: NSLocalizedString("MissingAmountTitle", comment: "Missing Amount Title"), message: NSLocalizedString("MissingAmountText", comment: "Missing Amount Text"), preferredStyle: .alert)
            answerError.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "forgotCodeOK"), style: .cancel, handler: nil))
            answerError.popoverPresentationController?.sourceView = self.view
            answerError.popoverPresentationController?.sourceRect = self.view.bounds
            self.present(answerError, animated: true)
        }
    }
}

extension UIColor {
    static func randomColor(color: Int = 0) -> UIColor {
        let colors = [
            UIColor(red: 255/255, green:0/255, blue: 0/255, alpha: 1.0),
            UIColor(red: 255/255, green:99/255, blue: 71/255, alpha: 1.0),
            UIColor(red: 255/255, green:127/255, blue: 80/255, alpha: 1.0),
            UIColor(red: 205/255, green:92/255, blue: 92/255, alpha: 1.0),
            UIColor(red: 233/255, green:150/255, blue: 122/255, alpha: 1.0),
            UIColor(red: 250/255, green:128/255, blue: 114/255, alpha: 1.0),
            UIColor(red: 255/255, green:160/255, blue: 122/255, alpha: 1.0),
            UIColor(red: 255/255, green:165/255, blue: 0/255, alpha: 1.0),
            UIColor(red: 218/255, green:165/255, blue: 32/255, alpha: 1.0),
            UIColor(red: 238/255, green:232/255, blue: 170/255, alpha: 1.0),
            UIColor(red: 240/255, green:230/255, blue: 140/255, alpha: 1.0),
            UIColor(red: 128/255, green:128/255, blue: 0/255, alpha: 1.0),
            UIColor(red: 255/255, green:255/255, blue: 0/255, alpha: 1.0),
            UIColor(red: 154/255, green:205/255, blue: 50/255, alpha: 1.0),
            UIColor(red: 85/255, green:107/255, blue: 47/255, alpha: 1.0),
            UIColor(red: 107/255, green: 142/255, blue: 35/255, alpha: 1.0),
            UIColor(red: 124/255, green: 252/255, blue: 0/255, alpha: 1.0),
            UIColor(red: 173/255, green: 255/255, blue: 47/255, alpha: 1.0),
            UIColor(red: 0/255, green: 100/255, blue: 0/255, alpha: 1.0),
            UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1.0),
            UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1.0),
            UIColor(red: 144/255, green: 238/255, blue: 144/255, alpha: 1.0),
            UIColor(red: 152/255, green: 251/255, blue: 152/255, alpha: 1.0),
            UIColor(red: 143/255, green: 188/255, blue: 143/255, alpha: 1.0),
            UIColor(red: 0/255, green: 255/255, blue: 127/255, alpha: 1.0),
            UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1.0),
            UIColor(red: 102/255, green: 205/255, blue: 170/255, alpha: 1.0),
            UIColor(red: 60/255, green: 179/255, blue: 113/255, alpha: 1.0),
            UIColor(red: 32/255, green: 178/255, blue: 170/255, alpha: 1.0),
            UIColor(red: 47/255, green: 79/255, blue: 79/255, alpha: 1.0),
            UIColor(red: 0/255, green: 128/255, blue: 128/255, alpha: 1.0),
            UIColor(red: 224/255, green: 255/255, blue: 255/255, alpha: 1.0),
            UIColor(red: 0/255, green: 206/255, blue: 209/255, alpha: 1.0),
            UIColor(red: 72/255, green: 209/255, blue: 204/255, alpha: 1.0),
            UIColor(red: 127/255, green: 255/255, blue: 212/255, alpha: 1.0),
            UIColor(red: 176/255, green: 224/255, blue: 230/255, alpha: 1.0),
            UIColor(red: 95/255, green: 158/255, blue: 160/255, alpha: 1.0),
            UIColor(red: 70/255, green: 130/255, blue: 180/255, alpha: 1.0),
            UIColor(red: 100/255, green: 149/255, blue: 237/255, alpha: 1.0),
            UIColor(red: 0/255, green: 191/255, blue: 255/255, alpha: 1.0),
            UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 1.0),
            UIColor(red: 25/255, green: 25/255, blue: 112/255, alpha: 1.0),
            UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha: 1.0),
            UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1.0),
            UIColor(red: 65/255, green: 105/255, blue: 225/255, alpha: 1.0),
            UIColor(red: 138/255, green: 43/255, blue: 226/255, alpha: 1.0),
            UIColor(red: 75/255, green: 0/255, blue: 130/255, alpha: 1.0),
            UIColor(red: 72/255, green: 61/255, blue: 139/255, alpha: 1.0),
            UIColor(red: 106/255, green: 90/255, blue: 205/255, alpha: 1.0),
            UIColor(red: 139/255, green: 0/255, blue: 139/255, alpha: 1.0),
            UIColor(red: 128/255, green: 0/255, blue: 128/255, alpha: 1.0),
            UIColor(red: 216/255, green: 191/255, blue: 216/255, alpha: 1.0),
            UIColor(red: 238/255, green: 130/255, blue: 238/255, alpha: 1.0),
            UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1.0),
            UIColor(red: 218/255, green: 112/255, blue: 214/255, alpha: 1.0),
            UIColor(red: 199/255, green: 21/255, blue: 133/255, alpha: 1.0),
            UIColor(red: 219/255, green: 112/255, blue: 147/255, alpha: 1.0),
            UIColor(red: 255/255, green: 20/255, blue: 147/255, alpha: 1.0),
            UIColor(red: 255/255, green: 105/255, blue: 180/255, alpha: 1.0),
            UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1.0),
            UIColor(red: 160/255, green: 82/255, blue: 45/255, alpha: 1.0),
            UIColor(red: 210/255, green: 105/255, blue: 30/255, alpha: 1.0),
            UIColor(red: 205/255, green: 133/255, blue: 63/255, alpha: 1.0),
            UIColor(red: 210/255, green: 180/255, blue: 140/255, alpha: 1.0),
            UIColor(red: 255/255, green: 228/255, blue: 181/255, alpha: 1.0),
            UIColor(red: 255/255, green: 218/255, blue: 185/255, alpha: 1.0),
            UIColor(red: 255/255, green: 240/255, blue: 245/255, alpha: 1.0),
            UIColor(red: 119/255, green: 136/255, blue: 153/255, alpha: 1.0),
            UIColor(red: 176/255, green: 196/255, blue: 222/255, alpha: 1.0),
            UIColor(red: 230/255, green: 230/255, blue: 250/255, alpha: 1.0),
            UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0),
            UIColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 1.0),
            UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0),
            UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0),
            UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
            ]
        return colors[color]
    }
}

extension UIStackView {

    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }

    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeFully(view: view)
        }
    }

}

//class GradientView: UIView {
//    override open class var layerClass: AnyClass {
//       return CAGradientLayer.classForCoder()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        let gradientLayer = layer as! CAGradientLayer
//        gradientLayer.colors = [self.backgroundColor?.cgColor, self.backgroundColor?.cgColor]
//    }
//}
