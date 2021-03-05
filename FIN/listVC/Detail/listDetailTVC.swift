//
//  listDetailTVC.swift
//  FIN
//
//  Created by Florian Riel on 07.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

var tagsDetailView = [Int:[String:Any]]()

class listDetailTVC: UITableViewController {

    @IBOutlet var tableviewListDetail: UITableView!
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    let headerHeightFactor = CGFloat(0.10)
    var navTitle = NSLocalizedString("viewTitleListDetail", comment: "Transaction Detail Title")
    
    var isWideScreen: Bool = false
    var viewDisappear = false
    
    var numberFormatter = NumberFormatter()
    var mediumDate = DateFormatter()
    
    var dateOfSelectedRow:Date?
    var superSplit:Bool = false
    var superRegularPayment:Bool = false

    var rowData = [Int:Any]()
    
    var selectedRowIndex: Int?
    
    var transactionPartOfGroupSplit:Bool = false
    var transactionPartOfSplit:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""
        
        if superSplit || superRegularPayment {
//            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("backButton", comment: "Back"), style: .plain, target: self, action: #selector(cancel))
        }
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePressed))
        
        NotificationCenter.default.addObserver(self, selector: #selector(transactionUpdated(notification:)), name: Notification.Name("transactionUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionDeleted), name: Notification.Name("transactionDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(settleSplitDisappeared), name: Notification.Name("settleSplitDisappeared"), object: nil)
        
        numberFormatter.numberStyle = .decimal
//        numberFormatter.locale = Locale.current
        
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = Locale.current.groupingSeparator
        numberFormatter.groupingSize = 3
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        mediumDate.dateStyle = .medium
        if dateOfSelectedRow != nil {
            createData(completion: {(success) -> Void in
                setNavButtons()
            })
        }
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        initRows(clearRows: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        viewDisappear = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        let nc = NotificationCenter.default
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            nc.post(name: Notification.Name("detailListDisappeared"), object: nil)
        })
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
        initRows(clearRows: true)
//        (self.splitViewController as! splitVC).initFirstSelected()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.navigationController?.view.backgroundColor = backgroundGeneralColor
            view.backgroundColor = backgroundGeneralColor
            tableviewListDetail.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            tableviewListDetail.backgroundColor = .secondarySystemBackground
        }
        initView()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0: // Amount Cell
            return getAmountCell(indexPath: indexPath)
        case 1: // Category Cell
            return getSplitCell(indexPath: indexPath)
        case 2: // Date Cell
            return getDateCell(indexPath: indexPath)
        case 3:
            return getSubtitleCell(indexPath: indexPath)
        case 4:
            return getSplitCell(indexPath: indexPath)
        case 5:
            if transactionPartOfGroupSplit {
                return getSubtitleCell(indexPath: indexPath)
            } else {
                return getSplitCell(indexPath: indexPath)
            }
        default: // Split Person Cell
            return getSplitCell(indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 || (indexPath.row > 5 && transactionPartOfGroupSplit)  || (indexPath.row >= 5 && !transactionPartOfGroupSplit) {
            let settleSplitStoryBoard: UIStoryboard = UIStoryboard(name: "settleSplit", bundle: nil)
            let settleSplitVC = settleSplitStoryBoard.instantiateViewController(withIdentifier: "settleSplitTVC") as! settleSplitTVC
            
            settleSplitVC.transactionCreateDate = dateOfSelectedRow ?? Date()
            
            if indexPath.row == 4 && transactionPartOfGroupSplit { // Group has been selected
                initRows(indexPathSelected: indexPath)
                selectedRowIndex = indexPath.row
                
                settleSplitVC.groupName = ((rowData[indexPath.row] as? [Int:Any])?[1]) as? String ?? ""
                settleSplitVC.createDateGroup = ((rowData[indexPath.row] as? [Int:Any])?[8]) as? Date ?? Date()
            } else if indexPath.row == 4 && !transactionPartOfGroupSplit { // Person has been selected
                initRows(indexPathSelected: indexPath)
                selectedRowIndex = indexPath.row
                
                settleSplitVC.personName = ((rowData[indexPath.row] as? [Int:Any])?[1]) as? String ?? ""
                settleSplitVC.createDatePerson = ((rowData[indexPath.row] as? [Int:Any])?[8]) as? Date ?? Date()
            } else if indexPath.row == 5 && !transactionPartOfGroupSplit { // Person has been selected
                initRows(indexPathSelected: indexPath)
                selectedRowIndex = indexPath.row
                
                settleSplitVC.personName = ((rowData[indexPath.row] as? [Int:Any])?[1]) as? String ?? ""
                settleSplitVC.createDatePerson = ((rowData[indexPath.row] as? [Int:Any])?[8]) as? Date ?? Date()
            } else if indexPath.row > 5 && !transactionPartOfGroupSplit { // Person has been selected, no Group
                initRows(indexPathSelected: indexPath)
                selectedRowIndex = indexPath.row
                
                settleSplitVC.personName = ((rowData[indexPath.row] as? [Int:Any])?[1]) as? String ?? ""
                settleSplitVC.createDatePerson = ((rowData[indexPath.row] as? [Int:Any])?[8]) as? Date ?? Date()
            } else if indexPath.row > 5 && transactionPartOfGroupSplit { // Person has been selected && Group
                initRows(indexPathSelected: indexPath)
                selectedRowIndex = indexPath.row
                
                settleSplitVC.personName = ((rowData[indexPath.row] as? [Int:Any])?[1]) as? String ?? ""
                settleSplitVC.createDatePerson = ((rowData[indexPath.row] as? [Int:Any])?[8]) as? Date ?? Date()
                
                let cell = tableviewListDetail.cellForRow(at: IndexPath(row: 4, section: 0))
                if cell != nil {
                    settleSplitVC.groupName = ((rowData[4] as? [Int:Any])?[1]) as? String ?? ""
                    settleSplitVC.createDateGroup = ((rowData[4] as? [Int:Any])?[8]) as? Date ?? Date()
                }
            }
            
            let navigationVC = UINavigationController(rootViewController: settleSplitVC)
            self.present(navigationVC, animated: true, completion: nil)
        }
        tableviewListDetail.cellForRow(at: indexPath)?.isSelected = false
    }

    // MARK: Cell Functions
    func getAmountCell(indexPath: IndexPath) -> cellAmountDetailTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "amountDetailCell", for: indexPath) as! cellAmountDetailTVC
        cell.amountCell.text = numberFormatter.string(from: NSNumber(value: ((rowData[0] as? [Int:Any])?[0] as? Double ?? 0.00)))
        cell.currencyButton.setTitle(getSymbol(forCurrencyCode: ((rowData[0] as? [Int:Any])?[1] as? String ?? "EUR")), for: .normal)
        cell.descriptionLabel.text = (rowData[0] as? [Int:Any])?[2] as? String ?? ""
        
        let amountTab = UITapGestureRecognizer(target: self, action: #selector(amountCellPressed))
        cell.addGestureRecognizer(amountTab)
        
        cell.Delegate = self
        return cell
    }
    
    func getDateCell(indexPath: IndexPath) -> dateDetailCellTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dateDetailCell", for: indexPath) as! dateDetailCellTVC
        cell.dateButton.setTitle(getDayForDate(dayDate: (rowData[2] as? Date ?? Date())), for: .normal)
        cell.Delegate = self
        return cell
    }
    
    func getSubtitleCell(indexPath: IndexPath) -> subtitleCellTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath) as! subtitleCellTVC
        if indexPath.row != 3 { // Person
            cell.subtitleLabel.text = NSLocalizedString("personDetailSubLabel", comment: "Person")
        } else if indexPath.row == 3 && transactionPartOfGroupSplit { // Group
            cell.subtitleLabel.text = NSLocalizedString("groupDetailSubLabel", comment: "Group")
        } else { // Person
            cell.subtitleLabel.text = NSLocalizedString("personDetailSubLabel", comment: "Person")
        }
        return cell
    }
    
    func getSplitCell(indexPath: IndexPath) -> cellDetailGeneralTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellGeneral", for: indexPath) as! cellDetailGeneralTVC
        if indexPath.row == 1 { // Category
            cell.descriptionLabel.text = ((rowData[1] as? [Int:Any])?[0] as? String ?? "")
            
            cell.circleView.backgroundColor = UIColor.randomColor(color: Int(((rowData[1]) as? [Int:Any])?[1] as? Int16 ?? 0))
            cell.circleView.layer.borderColor = UIColor.randomColor(color: Int(((rowData[1]) as? [Int:Any])?[1] as? Int16 ?? 0)).cgColor
            
            if ((rowData[1] as? [Int:Any])?[9] as? String ?? "").count > 0 {
                cell.circleImage.isHidden = false
                cell.circleLabel.isHidden = true
                
                var selectedIcon = ((rowData[1] as? [Int:Any])?[9] as? String ?? "").replacingOccurrences(of: "_white", with: "")
                if ((rowData[1] as? [Int:Any])?[10] as? Bool ?? true) {
                    selectedIcon = selectedIcon + "_white"
                }
                
                cell.circleImage.image = UIImage(named: selectedIcon)
            } else {
                cell.circleLabel.isHidden = false
                cell.circleImage.isHidden = true
                
                if ((rowData[1] as? [Int:Any])?[0] as? String ?? "").count == 1 {
                    cell.circleLabel.text = ((rowData[1] as? [Int:Any])?[0] as? String ?? "").prefix(1).uppercased()
                } else {
                    cell.circleLabel.text = ((rowData[1] as? [Int:Any])?[0] as? String ?? "").prefix(2).uppercased()
                }
                
                if ((rowData[1] as? [Int:Any])?[10] as? Bool ?? true) {
                    cell.circleLabel.textColor = .white
                } else {
                    cell.circleLabel.textColor = .black
                }
            }
            
            if ((rowData[1] as? [Int:Any])?[3] as? Bool ?? false) { // Is Income
                cell.icon.image = UIImage(named: "iconPlusBlack")?.withRenderingMode(.alwaysTemplate)
                cell.descriptionSubtitleLabel.text = NSLocalizedString("detailTransactionEarningsLabel", comment: "Earning")
            } else if ((rowData[1] as? [Int:Any])?[2] as? Bool ?? false) { // Is Save
                cell.icon.image = UIImage(named: "safe")?.withRenderingMode(.alwaysTemplate)
                if ((rowData[0] as? [Int:Any])?[0] as? Double ?? 0.00) < 0 {
                    if ((rowData[1] as? [Int:Any])?[4] as? Bool ?? true) { // isLiquid
                        cell.descriptionSubtitleLabel.text = NSLocalizedString("detailTransactionSaveWithdrawText", comment: "Savings Withdrew")
                    } else {
                        cell.descriptionSubtitleLabel.text = NSLocalizedString("detailTransactionDecreasedAddText", comment: "Savings Decreased")
                    }
                } else {
                    if ((rowData[1] as? [Int:Any])?[4] as? Bool ?? true) { // isLiquid
                        cell.descriptionSubtitleLabel.text = NSLocalizedString("detailTransactionSaveAddText", comment: "Savings Added")
                    } else {
                        cell.descriptionSubtitleLabel.text = NSLocalizedString("detailTransactionIncreasedAddText", comment: "Savings Increased")
                    }
                }
            } else { // Expense
                cell.icon.image = UIImage(named: "iconMinusBlack")?.withRenderingMode(.alwaysTemplate)
                cell.descriptionSubtitleLabel.text = NSLocalizedString("detailTransactionExpensesLabel", comment: "Expense")
            }
            
            let categoryTab = UITapGestureRecognizer(target: self, action: #selector(categoryCellPressed))
            cell.addGestureRecognizer(categoryTab)
            
            cell.amountLabel.isHidden = true
        } else {
            if ((rowData[indexPath.row] as? [Int:Any])?[0] as? Bool ?? false) { // is Group
                cell.descriptionLabel.text = ((rowData[indexPath.row] as? [Int:Any])?[1] as? String ?? "")
                
                cell.circleView.backgroundColor = UIColor.randomColor(color: Int(((rowData[indexPath.row]) as? [Int:Any])?[2] as? Int16 ?? 0))
                cell.circleView.layer.borderColor = UIColor.randomColor(color: Int(((rowData[indexPath.row]) as? [Int:Any])?[2] as? Int16 ?? 0)).cgColor
                
                if ((rowData[indexPath.row] as? [Int:Any])?[9] as? String ?? "").count > 0 {
                    cell.circleImage.isHidden = false
                    cell.circleLabel.isHidden = true
                    
                    var selectedIcon = ((rowData[indexPath.row] as? [Int:Any])?[9] as? String ?? "").replacingOccurrences(of: "_white", with: "")
                    if ((rowData[indexPath.row] as? [Int:Any])?[10] as? Bool ?? true) {
                        selectedIcon = selectedIcon + "_white"
                    }
                    
                    cell.circleImage.image = UIImage(named: selectedIcon)
                } else {
                    cell.circleLabel.isHidden = false
                    cell.circleImage.isHidden = true
                    
                    if ((rowData[indexPath.row] as? [Int:Any])?[0] as? String ?? "").count == 1 {
                        cell.circleLabel.text = ((rowData[indexPath.row] as? [Int:Any])?[1] as? String ?? "").prefix(1).uppercased()
                    } else {
                        cell.circleLabel.text = ((rowData[indexPath.row] as? [Int:Any])?[1] as? String ?? "").prefix(2).uppercased()
                    }
                    
                    if ((rowData[indexPath.row] as? [Int:Any])?[10] as? Bool ?? true) {
                        cell.circleLabel.textColor = .white
                    } else {
                        cell.circleLabel.textColor = .black
                    }
                }
                
                cell.amountLabel.isHidden = true
                cell.descriptionSubtitleLabel.isHidden = true
                cell.stackview.spacing = 0
                cell.icon.isHidden = true
            } else { // is Person
                if ((rowData[indexPath.row] as? [Int:Any])?[3] as? Bool ?? false) { // Is User
                    cell.descriptionLabel.text = ((rowData[indexPath.row] as? [Int:Any])?[1] as? String ?? "") + " [" + (NSLocalizedString("youTheUser", comment: "I")) + "]"
                } else {
                    cell.descriptionLabel.text = ((rowData[indexPath.row] as? [Int:Any])?[1] as? String ?? "")
                }
                
                if ((rowData[indexPath.row] as? [Int:Any])?[9] as? String ?? "").count > 0 {
                    cell.circleImage.isHidden = false
                    cell.circleLabel.isHidden = true
                    
                    var selectedIcon = ((rowData[indexPath.row] as? [Int:Any])?[9] as? String ?? "").replacingOccurrences(of: "_white", with: "")
                    if ((rowData[indexPath.row] as? [Int:Any])?[10] as? Bool ?? true) {
                        selectedIcon = selectedIcon + "_white"
                    }
                    
                    cell.circleImage.image = UIImage(named: selectedIcon)
                } else {
                    cell.circleLabel.isHidden = false
                    cell.circleImage.isHidden = true
                    
                    if ((rowData[indexPath.row] as? [Int:Any])?[0] as? String ?? "").count == 1 {
                        cell.circleLabel.text = ((rowData[indexPath.row] as? [Int:Any])?[1] as? String ?? "").prefix(1).uppercased()
                    } else {
                        cell.circleLabel.text = ((rowData[indexPath.row] as? [Int:Any])?[1] as? String ?? "").prefix(2).uppercased()
                    }
                    
                    if ((rowData[indexPath.row] as? [Int:Any])?[10] as? Bool ?? true) {
                        cell.circleLabel.textColor = .white
                    } else {
                        cell.circleLabel.textColor = .black
                    }
                }
                
                cell.circleView.backgroundColor = UIColor.randomColor(color: Int(((rowData[indexPath.row]) as? [Int:Any])?[2] as? Int16 ?? 0))
                cell.circleView.layer.borderColor = UIColor.randomColor(color: Int(((rowData[indexPath.row]) as? [Int:Any])?[2] as? Int16 ?? 0)).cgColor
                
                cell.amountLabel.text = (getSymbol(forCurrencyCode: ((rowData[indexPath.row] as? [Int:Any])?[7] as? String ?? "EUR")) ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: ((rowData[indexPath.row] as? [Int:Any])?[5] as? Double ?? 0.00))) ?? "")
                
                let foreignCurrency = ((rowData[indexPath.row] as? [Int:Any])?[7] as? String ?? "EUR") == (Locale.current.currencyCode ?? "EUR")
                
                if ((rowData[indexPath.row] as? [Int:Any])?[3] as? Bool ?? false) && ((rowData[indexPath.row] as? [Int:Any])?[4] as? Bool ?? false) { // is user && is person who paid
                    let str1 = NSLocalizedString("youAreOwedLabel", comment: "You get")
                    if foreignCurrency {
                        let str2_1 = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: ((rowData[indexPath.row] as? [Int:Any])?[5] as? Double ?? 0.00))) ?? "")
                        let str2 = " [ " + str2_1 + " ]"
                        cell.descriptionSubtitleLabel.text = str1 + str2
                    }
                    cell.descriptionSubtitleLabel.text = str1
                } else if ((rowData[indexPath.row] as? [Int:Any])?[3] as? Bool ?? false) && !((rowData[indexPath.row] as? [Int:Any])?[4] as? Bool ?? false) { // isUser but not person who paid
                    let str1 = NSLocalizedString("youBorrowedLabel", comment: "You Borrowed")
                    if foreignCurrency {
                        let str2_1 = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: ((rowData[indexPath.row] as? [Int:Any])?[5] as? Double ?? 0.00))) ?? "")
                        let str2 = " [ " + str2_1 + " ]"
                        cell.descriptionSubtitleLabel.text = str1 + str2
                    }
                    cell.descriptionSubtitleLabel.text = str1
                } else if !((rowData[indexPath.row] as? [Int:Any])?[3] as? Bool ?? false) && ((rowData[indexPath.row] as? [Int:Any])?[4] as? Bool ?? false) { // isNOTUser && Person who paid
                    let str1 = NSLocalizedString("personOwedLabel", comment: "Person gets")
                    if foreignCurrency {
                        let str2_1 = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: ((rowData[indexPath.row] as? [Int:Any])?[5] as? Double ?? 0.00))) ?? "")
                        let str2 = " [ " + str2_1 + " ]"
                        cell.descriptionSubtitleLabel.text = str1 + str2
                    }
                    cell.descriptionSubtitleLabel.text = str1
                } else { // isNOTUser && not Person who paid
                    let str1 = NSLocalizedString("personBorrowedLabel", comment: "Person borrowed")
                    if foreignCurrency {
                        let str2_1 = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: ((rowData[indexPath.row] as? [Int:Any])?[5] as? Double ?? 0.00))) ?? "")
                        let str2 = " [ " + str2_1 + " ]"
                        cell.descriptionSubtitleLabel.text = str1 + str2
                    }
                    cell.descriptionSubtitleLabel.text = str1
                }
                cell.icon.isHidden = true
            }
        }
        return cell
    }
    
    func initRows(indexPathSelected: IndexPath = IndexPath(row: 0, section: 0), clearRows: Bool = false) {
        for (row, _) in rowData {
            let indexPathRAM: IndexPath = IndexPath(row: row, section: 0)
            if let cell = tableviewListDetail.cellForRow(at: indexPathRAM) as? cellDetailGeneralTVC {
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
            if let cell = tableviewListDetail.cellForRow(at: indexPathSelected) as? cellDetailGeneralTVC {
                cell.cellOutlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
            }
        }
    }
    
    // MARK: -VIEW
    func initView() {
        initTableAndHeaderView()
    }
    
    func initTableAndHeaderView() {
        tableviewListDetail.sectionHeaderHeight = UITableView.automaticDimension
     
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            tableviewListDetail.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
        } else {
            tableviewListDetail.backgroundColor = .secondarySystemBackground
            headerView.backgroundColor = .secondarySystemBackground
        }
        
        headerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerView.headerLabel.text = navTitle
        
        headerView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.frame.width,
            height: 78//view.frame.height * headerHeightFactor
        )
        
        headerView.maxHeight = view.frame.height * headerHeightFactor
        headerView.maxLabelPointSize = headerView.headerLabel.font.pointSize
        headerView.minLabelPointSize = 20.0
        headerView.scrollView = tableviewListDetail
        
        tableviewListDetail.backgroundView = UIView()
        tableviewListDetail.backgroundView?.addSubview(headerView)
        tableviewListDetail.contentInset = UIEdgeInsets(
            top: 78,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 40,
            right: 0
        )
    }
    
    func setNavButtons() {
//        navigationItem.rightBarButtonItems?.removeAll()
//        if !transactionPartOfSplit {
////            let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTransaction))
//            let editButton = UIBarButtonItem(image: UIImage(named: "editIcon")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(editTransaction))
//            let repeatedTransactionButton = UIBarButtonItem(image: UIImage(named: "repeatClock")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(repeatTransaction))
//            navigationItem.rightBarButtonItems = [editButton,repeatedTransactionButton]
//        } else {
//            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTransaction))
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "editIcon")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(editTransaction))
//        }
    }
    
    // MARK: -FUNCTIONS
    func createData(completion: (Bool) -> ()) {
        rowData.removeAll()
//        transactionPartOfSplit = false
        
        var amount:Double?
        var currencyCode:String?
        var exchangeRate:Double?
        var description:String?
        var transactionTags:String?
        var categoryID:Int16?
        var isSave:Bool?
        var isLiquid:Bool?
        
        var isIncome:Bool?
        var categoryName:String?
        var categoryColor:Int16?
        var icon:String?
        var iconLight:Bool?
        
        // Get Data from Transaction
        let createDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateOfSelectedRow ?? Date())!
        let createDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateOfSelectedRow ?? Date())!
        
        var queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", createDatePlus as NSDate, createDateMinus as NSDate)
        var entityTransaction = "Transactions"
        
        if superRegularPayment {
            entityTransaction = "RegularPayments"
            queryTransaction = NSPredicate(format: "dateTimeNext < %@ AND dateTimeNext > %@", createDatePlus as NSDate, createDateMinus as NSDate)
        }
        
        for transaction in loadBulkQueried(entitie: entityTransaction, query: queryTransaction) {
            amount = transaction.value(forKey: "amount") as? Double ?? 0.00
            currencyCode = transaction.value(forKey: "currencyCode") as? String ?? "EUR"
            exchangeRate = transaction.value(forKey: "exchangeRate") as? Double ?? 1.00
            description = transaction.value(forKey: "descriptionNote") as? String ?? "-"
            transactionTags = transaction.value(forKey: "tags") as? String ?? ""
            categoryID = transaction.value(forKey: "categoryID") as? Int16 ?? 0
            isSave = transaction.value(forKey: "isSave") as? Bool ?? false
            isLiquid = transaction.value(forKey: "isLiquid") as? Bool ?? true
        }
        
        createTags(tagsString: (transactionTags ?? ""))

        // Get Data from Category
        let queryCategory = NSPredicate(format: "cID == %@", ((categoryID ?? 0) as Int16) as NSNumber)
        
        for category in loadBulkQueried(entitie: "Categories", query: queryCategory) {
            categoryName = category.value(forKey: "name") as? String ?? "-"
            categoryColor = category.value(forKey: "color") as? Int16 ?? 0
            isIncome = category.value(forKey: "isIncome") as? Bool ?? false
            icon = category.value(forKey: "icon") as? String ?? ""
            iconLight = category.value(forKey: "iconLight") as? Bool ?? true
        }
        
        let ramDictAmount = [ // Amount Cell
            0:amount ?? 0.00,
            1:currencyCode ?? "EUR",
            2:description ?? "Description"
        ] as [Int : Any]
        rowData[0] = ramDictAmount
        
        let ramDictCategory = [
            0:categoryName ?? "Category",
            1:categoryColor ?? 0,
            2:isSave ?? false,
            3:isIncome ?? false,
            4:isLiquid ?? true,
            9:icon ?? "",
            10:iconLight ?? true
        ] as [Int : Any]
        rowData[1] = ramDictCategory
        
        rowData[2] = dateOfSelectedRow ?? Date()
        
        // Get Splits if any
        let querySplits = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", createDatePlus as NSDate, createDateMinus as NSDate)
        let dateSort = NSSortDescriptor(key: "createDatePerson", ascending: true)
        
        var entitySplit = "Splits"
        
        if superRegularPayment {
            entitySplit = "SplitsRegularPayments"
        }
        var first = true
        for split in loadBulkQueriedSorted(entitie: entitySplit, query: querySplits, sort: [dateSort]) {
//            transactionPartOfSplit = true
            // Get Group if any
            if first && !((split.value(forKey: "nameGroup") as? String ?? "").count <= 0) {
                var groupName:String?
                var groupColor:Int16?
                var groupIcon:String?
                var groupIconLight:Bool?
                
                let createDateGroupPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "createDateGroup") as? Date ?? Date()))!
                let createDateGroupMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "createDateGroup") as? Date ?? Date()))!
                let queryGroup = NSPredicate(format: "createDate < %@ AND createDate > %@ AND nameGroup == %@", createDateGroupPlus as NSDate, createDateGroupMinus as NSDate, (split.value(forKey: "nameGroup") as? String ?? "") as NSString)
                for group in loadBulkQueried(entitie: "SplitGroups", query: queryGroup) {
                    groupName = group.value(forKey: "nameGroup") as? String ?? ""
                    groupColor = group.value(forKey: "color") as? Int16 ?? 0
                    groupIcon = group.value(forKey: "icon") as? String ?? ""
                    groupIconLight = group.value(forKey: "iconLight") as? Bool ?? true
                }
                let ramDict = [
                    0:true, // Is Group
                    1:groupName ?? "",
                    2:groupColor ?? 0,
                    8:split.value(forKey: "createDateGroup") as Any,
                    9:groupIcon ?? "",
                    10:groupIconLight ?? true,
                ] as [Int : Any]
                rowData[rowData.count] = "Group"
                rowData[rowData.count] = ramDict
                transactionPartOfGroupSplit = true
            }
            
            if first {
                rowData[rowData.count] = "Person"
                first = false
            }
            
            // Get Person if any
            var personName:String?
            var personColor:Int16?
            var isUser:Bool?
            
            var personIcon:String?
            var personIconLight:Bool?
            
            var amountPerson:Double?
            var amountPersonHomeCurrency:Double?
            var isPersonWhoPaid:Bool?
            
            let createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "createDatePerson") as? Date ?? Date()))!
            let createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "createDatePerson") as? Date ?? Date()))!
            let queryPerson = NSPredicate(format: "createDate < %@ AND createDate > %@ AND namePerson == %@", createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, (split.value(forKey: "namePerson") as? String ?? "") as NSString)
            
            for person in loadBulkQueried(entitie: "SplitPersons", query: queryPerson) {
                personName = person.value(forKey: "namePerson") as? String ?? "Person"
                personColor = person.value(forKey: "color") as? Int16 ?? 0
                isUser = person.value(forKey: "isUser") as? Bool ?? false
                personIcon = person.value(forKey: "icon") as? String ?? ""
                personIconLight = person.value(forKey: "iconLight") as? Bool ?? true
            }
            
            let up = createDatePersonMinus.compare((split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date())) == .orderedAscending
            let down = createDatePersonPlus.compare((split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date())) == .orderedDescending
            
            if up && down && (split.value(forKey: "namePersonWhoPaid") as? String ?? "") == (personName ?? "-") {
                isPersonWhoPaid = true
            } else {
                isPersonWhoPaid = false
            }
            
            let ratio = split.value(forKey: "ratio") as? Double ?? 0.00
            let settled = (split.value(forKey: "settled") as? Double ?? 0.00)
            
            if (isPersonWhoPaid ?? false) {
                let amoutFUNC = (amount ?? 0.00)*(1-ratio)
                amountPerson = amoutFUNC-settled
                // Ok
            } else {
                let amoutFUNC = (amount ?? 0.00)*ratio
                amountPerson = amoutFUNC-settled
                // Ok
            }
            amountPersonHomeCurrency = (amountPerson ?? 0.00)/(exchangeRate ?? 1.00)
            
            let ramDict = [
                0:false, // Is Person
                1:personName ?? "",
                2:personColor ?? 0,
                3:isUser ?? false,
                4:isPersonWhoPaid ?? false,
                5:amountPerson ?? 0.00,
                6:amountPersonHomeCurrency ?? 0.00,
                7:currencyCode ?? "EUR",
                8:split.value(forKey: "createDatePerson") as Any,
                9:personIcon ?? "",
                10:personIconLight ?? true
            ] as [Int : Any]
            rowData[rowData.count] = ramDict
        }
        completion(true)
    }
    
    func createTags(tagsString:String) {
        tagsDetailView.removeAll()

        for tag in tagsString.components(separatedBy: "*;*") {
            if tag.count <= 0 {
                continue
            } else {
                let tagName = tag
                var tagColor:Int?
                
                let queryTag = NSPredicate(format: "tagName == %@", (tag as NSString))
                
                for tagData in loadBulkQueried(entitie: "Tags", query: queryTag) {
                    tagColor = Int(tagData.value(forKey: "tagColor") as? Int16 ?? 0)
                }
                
                tagsDetailView[tagsDetailView.count] = [
                    "Title":tagName,
                    "Color":tagColor ?? 0
                ]
            }
        }
    }
    
    @objc func amountCellPressed() {
        if let cell = tableviewListDetail.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellAmountDetailTVC {
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = cell.transform.scaledBy(x: 0.98, y: 0.98)
                }, completion: { _ in
                  UIView.animate(withDuration: 0.1, animations: {
                    cell.transform = CGAffineTransform.identity
                  }, completion: { _ in
                    self.editTransaction()
                  })
                })
        }
    }
    
    @objc func categoryCellPressed() {
        if let cell = tableviewListDetail.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellDetailGeneralTVC {
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = cell.transform.scaledBy(x: 0.98, y: 0.98)
                }, completion: { _ in
                  UIView.animate(withDuration: 0.1, animations: {
                    cell.transform = CGAffineTransform.identity
                  }, completion: { _ in
                    self.editTransaction()
                  })
                })
        }
    }
    
    @objc func editTransaction() {
        let finStoryBoard: UIStoryboard = UIStoryboard(name: "finTSB", bundle: nil)
        let addVC = finStoryBoard.instantiateViewController(withIdentifier: "addTVC") as! addTVC
        
        addVC.updateCreateDate = dateOfSelectedRow ?? Date()
        
        if superRegularPayment {
            addVC.superRegularPayment = true
        }
        
        let navigationVC = UINavigationController(rootViewController: addVC)
        self.present(navigationVC, animated: true, completion: nil)
    }

//    @objc func repeatTransaction() {
//
//    }
    
    @objc func cancel() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func transactionDeleted() {
        if superRegularPayment || superSplit {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if UIDevice().model.contains("iPad") {
                    self.navigationController?.navigationController?.popToRootViewController(animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @objc func transactionUpdated(notification: Notification) {
        if let userInfo = notification.userInfo, let newCreateDate = userInfo["transactionCreateDate"] as? Date {
            dateOfSelectedRow = newCreateDate
            createData(completion: {(success) -> Void in
                setNavButtons()
            })
            tableviewListDetail.reloadData()
            if let cell = tableviewListDetail.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellAmountDetailTVC {
                cell.initTags()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                if let cellDate = self.tableviewListDetail.cellForRow(at: IndexPath(row: 2, section: 0)) as? dateDetailCellTVC {
                    cellDate.dateButton.setTitle(self.getDayForDate(dayDate: (self.rowData[2] as? Date ?? Date())), for: .normal)
                }
            })
            tableviewListDetail.beginUpdates()
            tableviewListDetail.needsUpdateConstraints()
            tableviewListDetail.endUpdates()
        }
    }
    
    @objc func settleSplitDisappeared() {
        initRows(clearRows: false)
    }
    
    // MARK: -Helper Functions
    func getDayForDate(dayDate: Date) -> String {
        let calendar = Calendar.current
        
        let dayDateDateOnly = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: dayDate)
        let nowDateOnly = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: Date())
        
        let differenceInDays = Calendar.current.dateComponents([.day], from: dayDateDateOnly, to: nowDateOnly).day!
        
        if differenceInDays == 0 {
            return NSLocalizedString("today", comment: "Today")
        } else if differenceInDays == 1 {
            return NSLocalizedString("yesterday", comment: "Yesterday")
        } else if differenceInDays <= 7 && differenceInDays > 0 {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: dayDate)
        } else if differenceInDays == -1 {
            return NSLocalizedString("tomorrowText", comment: "Tomorrow")
        } else if differenceInDays == -2 {
            return NSLocalizedString("dayAfterTomorrowText", comment: "Day after Tomorrow")
        } else {
            return mediumDate.string(from: dayDate)
        }
    }
    
    func getSymbol(forCurrencyCode code: String) -> String? {
        let locale = NSLocale(localeIdentifier: code)
        if locale.displayName(forKey: .currencySymbol, value: code) == code {
            let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: code)
        }
        return locale.displayName(forKey: .currencySymbol, value: code)
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

// MARK: -DATA
extension listDetailTVC {
    func loadBulkQueried(entitie:String, query:NSPredicate) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if loadData.count > 0 {
                return loadData
            }
        } catch {
            print("Could not fetch. \(error)")
        }
        return [NSManagedObject]()
    }
    
    func loadBulkQueriedSorted(entitie:String, query:NSPredicate, sort:[NSSortDescriptor]) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = sort
        fetchRequest.predicate = query
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if loadData.count > 0 {
                return loadData
            }
        } catch {
            print("Could not fetch. \(error)")
        }
        return [NSManagedObject]()
    }
}

extension listDetailTVC: cellAmountDetailTVCDelegate {
    func currencyButtonPressed() {
        editTransaction()
    }
}

extension listDetailTVC: dateDetailCellDelegate {
    func dateButtonPressed() {
        editTransaction()
    }
}
