//
//  splitMasterTVC.swift
//  FIN
//
//  Created by Florian Riel on 27.09.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

var selectedSegement: Int = 0

class splitMasterTVC: UITableViewController {
    
    @IBOutlet var splitTableView: UITableView!

    var rowData = [Int:[Int:Any]]()
    var sumOwed = 0.00 // Amount Owed-by-User (paidByUser = false)
    var sumBorrowed = 0.00 // Amount borrowed-from-user (paidByUser = true)
    
    var numberFormatter = NumberFormatter()
    
    var isWideScreen: Bool = false
    var viewDisappear = false
    
    var selectedRowIndex: Int?
    var selectedRowPersonOrGroup: String?
    var createDate:Date?
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    let headerHeightFactor = CGFloat(0.10)
    var navTitle = NSLocalizedString("bottomSegmentGroups", comment: "Segment Group Text")
    
    var splitBottomBar:splitBottomBar = {
        let nib = UINib(nibName: "splitBottomBar", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! splitBottomBar
    }()
    var widthAnchorConstraintBottomBar: NSLayoutConstraint?
    var bottomAnchorConstraintBottomBar: NSLayoutConstraint?
    
    var initialLoad:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNew))
        
//        NotificationCenter.default.addObserver(self, selector: #selector(transactionAdded), name: Notification.Name("transactionAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionAdded), name: Notification.Name("groupPersonAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionAdded), name: Notification.Name("groupPersonUpdated"), object: nil)
        
        numberFormatter.numberStyle = .decimal
//        numberFormatter.locale = Locale.current
        
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = Locale.current.groupingSeparator
        numberFormatter.groupingSize = 3
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        createDataForRows()
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        initFirstSelected()
        dataHandler.initUserSplitPerson()
        
        if reloadSplitView && !initialLoad {
            reloadSplitView = false
            transactionAdded()
        }
        initialLoad = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        viewDisappear = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        headerView.updatePosition()
//        updateCellIconAlpha()
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
//        (self.splitViewController as! splitVC).initFirstSelected()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        headerView.updatePosition()
//        (self.splitViewController as! splitVC).initFirstSelected()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.navigationController?.view.backgroundColor = backgroundGeneralColor
            view.backgroundColor = backgroundGeneralColor
            splitTableView.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            splitTableView.backgroundColor = .secondarySystemBackground
        }
        initView()
        initFirstSelected()
    }
    
    // MARK: -initViewFunctions
    func initView() {
        initTableAndHeaderView()
        initBottomBar()
    }
    
    func initTableAndHeaderView() {
        splitTableView.sectionHeaderHeight = UITableView.automaticDimension
     
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            splitTableView.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
        } else {
            splitTableView.backgroundColor = .secondarySystemBackground
            headerView.backgroundColor = .secondarySystemBackground
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
        headerView.scrollView = splitTableView
        
        splitTableView.backgroundView = UIView()
        splitTableView.backgroundView?.addSubview(headerView)
        splitTableView.contentInset = UIEdgeInsets(
            top: 85,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 40,
            right: 0
        )
    }
    
    func initBottomBar() {
        splitBottomBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(splitBottomBar, aboveSubview: splitTableView)
        splitBottomBar.initView()
        
        initBottomBarSize()
        
        splitBottomBar.delegete = self
    }
    
    func initBottomBarSize() {
        widthAnchorConstraintBottomBar?.isActive = false
        widthAnchorConstraintBottomBar = splitBottomBar.widthAnchor.constraint(equalToConstant: min(view.frame.width, 400))
        widthAnchorConstraintBottomBar?.isActive = true
        
        bottomAnchorConstraintBottomBar?.isActive = false
        bottomAnchorConstraintBottomBar = splitBottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        bottomAnchorConstraintBottomBar?.isActive = true
        
        splitBottomBar.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 1.0).isActive = true
    }
    
    func hideBottomBar() {
        bottomAnchorConstraintBottomBar?.isActive = false
        bottomAnchorConstraintBottomBar = splitBottomBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        bottomAnchorConstraintBottomBar?.isActive = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        } , completion: { finished in
            self.splitBottomBar.isHidden = true
        })
    }
    
    func showBottomBar() {
        bottomAnchorConstraintBottomBar?.isActive = false
        bottomAnchorConstraintBottomBar = splitBottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        bottomAnchorConstraintBottomBar?.isActive = true
        self.splitBottomBar.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        } , completion: { finished in
            
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (rowData.count+1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitOverview", for: indexPath) as! cellSplitOverview
            
            cell.borrowedAmount.text = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: sumBorrowed)) ?? "0.00")
            cell.owedAmount.text = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: sumOwed)) ?? "0.00")
            
            return cell
        default:
            return getGeneralCell(indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            initRows(indexPathSelected: indexPath)
            UISelectionFeedbackGenerator().selectionChanged()
            selectedRowIndex = indexPath.row
            
            if (splitTableView.cellForRow(at: indexPath) as? cellSplitGeneral) != nil {
                selectedRowPersonOrGroup = rowData[(indexPath.row-1)]?[0] as? String ?? ""
                createDate = rowData[(indexPath.row-1)]?[4] as? Date ?? Date()
            }
            if UIDevice().model.contains("iPad") {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "splitDetailSelected", sender: nil)
                }
            } else {
                let splitDetailStoryBoard: UIStoryboard = UIStoryboard(name: "splitTSB", bundle: nil)
                let splitDetailVC = splitDetailStoryBoard.instantiateViewController(withIdentifier: "splitDetailTVC") as! splitDetailTVC
                
                splitDetailVC.personOrGroupName = selectedRowPersonOrGroup ?? ""
                splitDetailVC.createDate = createDate ?? Date()
                splitDetailVC.selectedSegement = selectedSegement
                
                splitDetailVC.modalPresentationStyle = .fullScreen
                selectedRowIndex = nil
                self.navigationController?.pushViewController(splitDetailVC, animated: true)
            }
        }
    }

    func getGeneralCell(indexPath: IndexPath) -> cellSplitGeneral {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitGeneral", for: indexPath) as! cellSplitGeneral
        
        cell.circleView.backgroundColor =  UIColor.randomColor(color: Int(rowData[(indexPath.row-1)]?[1] as? Int16 ?? 0))
        cell.circleView.layer.borderColor = cell.circleView.backgroundColor?.cgColor
        
        if (rowData[(indexPath.row-1)]?[6] as? String ?? "").count > 0 {
            cell.circleImage.isHidden = false
            cell.circleLabel.isHidden = true
            
            var selectedIcon = (rowData[(indexPath.row-1)]?[6] as? String ?? "").replacingOccurrences(of: "_white", with: "")
            if (rowData[(indexPath.row-1)]?[7] as? Bool ?? true) {
                selectedIcon = selectedIcon + "_white"
            }
            
            cell.circleImage.image = UIImage(named: selectedIcon)
        } else {
            cell.circleImage.isHidden = true
            cell.circleLabel.isHidden = false
            
            if (rowData[(indexPath.row-1)]?[6] as? String ?? "").count == 1 {
                cell.circleLabel.text = (rowData[(indexPath.row-1)]?[0] as? String ?? "").prefix(1).uppercased()
            } else {
                cell.circleLabel.text = (rowData[(indexPath.row-1)]?[0] as? String ?? "").prefix(2).uppercased()
            }
            if (rowData[(indexPath.row-1)]?[7] as? Bool ?? true) {
                cell.circleLabel.textColor = .white
            } else {
                cell.circleLabel.textColor = .black
            }
        }
        
        if dataHandler.isUser(createDate: (rowData[(indexPath.row-1)]?[4] as? Date ?? Date()), namePerson: (rowData[(indexPath.row-1)]?[0] as? String ?? "")) {
            cell.mainLabel.text = (rowData[(indexPath.row-1)]?[0] as? String ?? "") + " [" + (NSLocalizedString("youTheUser", comment: "I")) + "]"
        } else {
            cell.mainLabel.text = rowData[(indexPath.row-1)]?[0] as? String ?? ""
        }
        
        cell.subLabel.text = rowData[(indexPath.row-1)]?[2] as? String ?? ""
        
        if (rowData[(indexPath.row-1)]?[5] as? Int ?? 2) == 0 { // Group
            cell.icon.isHidden = false
            cell.icon.image = UIImage(named: "tabPersonsSelected")?.withRenderingMode(.alwaysTemplate)
        } else if (rowData[(indexPath.row-1)]?[5] as? Int ?? 2) == 1 {
            cell.icon.isHidden = false
            cell.icon.image = UIImage(named: "tabPersonSelected")?.withRenderingMode(.alwaysTemplate)
        } else {
            cell.icon.isHidden = true
        }
        
        cell.amountLabel.text = rowData[(indexPath.row-1)]?[3] as? String ?? ""
        
        if selectedRowIndex != indexPath.row {
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            if userInterfaceStyle == .light {
                cell.outlineView.backgroundColor = .white
                cell.outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            } else {
                cell.outlineView.backgroundColor = .black
                cell.outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
            }
        } else {
            cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
            cell.outlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
        }
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.outlineView.addInteraction(interaction)
        cell.outlineView.tag = (indexPath.row-1)
        
        return cell
    }
    
    func initRows(indexPathSelected: IndexPath = IndexPath(row: 0, section: 0), clearRows: Bool = false) {
        for i in 0...rowData.count {
            let indexPathRAM: IndexPath = IndexPath(row: i, section: 0)
            if let cell = splitTableView.cellForRow(at: indexPathRAM) as? cellSplitGeneral {
                let userInterfaceStyle = traitCollection.userInterfaceStyle
                if userInterfaceStyle == .light {
                    cell.outlineView.backgroundColor = .white
                    cell.outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                } else {
                    cell.outlineView.backgroundColor = .black
                    cell.outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
                }
            }
        }
        if !clearRows {
            if let cell = splitTableView.cellForRow(at: indexPathSelected) as? cellSplitGeneral {
                cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                cell.outlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
            }
        }
    }
    
    func initFirstSelected() {
        if selectedRowIndex == nil && UIDevice().model.contains("iPad") {
            selectedRowIndex = 1
            initRows(indexPathSelected: IndexPath(row: selectedRowIndex ?? 0, section: 0))
            if (splitTableView.cellForRow(at: IndexPath(row: selectedRowIndex ?? 0, section: 0)) as? cellSplitGeneral) != nil {
                selectedRowPersonOrGroup = rowData[(IndexPath(row: selectedRowIndex ?? 0, section: 0).row-1)]?[0] as? String ?? ""
                createDate = rowData[(IndexPath(row: selectedRowIndex ?? 0, section: 0).row-1)]?[4] as? Date ?? Date()
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "splitDetailSelected", sender: nil)
            }
        } else if selectedRowIndex != nil && UIDevice().model.contains("iPad") {
            initRows(indexPathSelected: IndexPath(row: selectedRowIndex ?? 0, section: 0), clearRows: false)
        } else {
            initRows(clearRows: true)
        }
    }
    
    func updateCellIconAlpha() {
        let heightTableView = splitTableView.visibleSize.height
        let heightTableViewP = 0.2 * heightTableView
        
        for cell in splitTableView.visibleCells {
            if let cellConverted = cell as? cellSplitGeneral {
                let yTopPosition = splitTableView.convert(cellConverted.frame, to: nil).maxY
    //            let yBottomPosition = listTable.convert(cellConverted.frame, to: nil).minY

                if yTopPosition > (heightTableView - heightTableViewP) {
                    let alp = ((heightTableView - yTopPosition) / heightTableViewP)
                    cellConverted.outlineView.alpha = alp
                    
    //            } else if yBottomPosition < heightTableViewP {
    //                let alp = ((heightTableView - yBottomPosition) / heightTableViewP)
    //                cellConverted.outlineView.alpha = alp
                } else {
                    cellConverted.outlineView.alpha = 1.0
                }
            }
        }
    }

    // MARK: -FUNCTIONS    
    func createDataForRows() {
        sumOwed = 0.00
        sumBorrowed = 0.00
        rowData.removeAll()
        
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
        
        var nameUser:String?
        var createDateUser:Date?
        
        for data in dataHandler.loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
        
        let userDateUserPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        let userDateUserMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
        
        if selectedSegement == 0 { // Groups
            let dateSort = NSSortDescriptor(key: "createDate", ascending: false)
            
            let groupData = dataHandler.loadBulkSorted(entitie: "SplitGroups", sort: [dateSort])
            
            var i = 0
            for data in groupData { // Get Groups
                var sum = 0.00
                let createDateGroup = (data.value(forKey: "createDate") as? Date ?? Date())
                
                let createDateGroupPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateGroup)!
                let createDateGroupMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateGroup)!
                
                let query = NSPredicate(format: "nameGroup == %@ AND createDateGroup < %@ AND createDateGroup > %@", (data.value(forKey: "nameGroup") as! NSString), (createDateGroupPlus as NSDate), (createDateGroupMinus as NSDate))
                let dateSort = NSSortDescriptor(key: "dateTimeTransaction", ascending: false)
                
                var userIsPartOfSplit:Bool?
                
                for split in dataHandler.loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [dateSort]) {
                    if userPartOfSplit(dateTime: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date())) {
                        userIsPartOfSplit = true
                    } else {
                        userIsPartOfSplit = false
                    }

                    let createTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                    let createTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                        
                    let query = NSPredicate(format: "dateTime < %@ AND dateTime > %@", (createTransactionPlus as NSDate), (createTransactionMinus as NSDate))
                    let dateSort = NSSortDescriptor(key: "dateTime", ascending: false)
                    
                    for transaction in dataHandler.loadBulkQueriedSorted(entitie: "Transactions", query: query, sort: [dateSort]) {
                        let exchangeRate = (transaction.value(forKey: "exchangeRate") as? Double ?? 1.00)
                        
                        let settled = (split.value(forKey: "settled") as? Double ?? 0.00)/exchangeRate
                        let sumTransaction = (transaction.value(forKey: "amount") as? Double ?? 0.00)/exchangeRate
                        let ratio = (split.value(forKey: "ratio") as? Double ?? 0.00)
                        
                        if userIsPartOfSplit ?? false {
                            if (split.value(forKey: "paidByUser") as? Bool ?? true) && !dataHandler.isUser(createDate: split.value(forKey: "createDatePerson") as? Date ?? Date(), namePerson: split.value(forKey: "namePerson") as? String ?? "") {
                                sum = sum + (sumTransaction*ratio) - settled
                            } else if !(split.value(forKey: "paidByUser") as? Bool ?? true) && dataHandler.isUser(createDate: split.value(forKey: "createDatePerson") as? Date ?? Date(), namePerson: split.value(forKey: "namePerson") as? String ?? "") {
                                sum = sum - (sumTransaction*ratio) + settled
                            }
                        }
                    }
                }
                
                var sumString:String?
                var groupSumString:String?
                
                if sum == 0.00 {
                    if dataHandler.loadBulkQueriedSortedCount(entitie: "Splits", query: query, sort: [dateSort]).count > 0 {
                        sumString = NSLocalizedString("notInvolvedSplit", comment: "User not Involved, but open")
                        groupSumString = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: 0.00)) ?? "0.00")
                    } else {
                        sumString = NSLocalizedString("allSettledSplit", comment: "All Settled")
                        groupSumString = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: 0.00)) ?? "0.00")
                    }
                } else if sum <= 0 {
                    sumBorrowed = sumBorrowed + abs(sum)
                    groupSumString = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: abs(sum))) ?? "0.00")
                    sumString = NSLocalizedString("youBorrowedLabel", comment: "Borrowed Sublabel")// + " " + amount
                } else {
                    sumOwed = sumOwed + sum
                    groupSumString = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: sum)) ?? "0.00")
                    sumString = NSLocalizedString("youAreOwedLabel", comment: "Owed Sublabel")// + " " + amount
                }
                
                rowData[i] = [
                    0:data.value(forKey: "nameGroup") as? String ?? "",
                    1:data.value(forKey: "color") as? Int16 ?? 0,
                    2:sumString ?? "",
                    3:groupSumString ?? "",
                    4:createDateGroup,
                    5:0,
                    6:data.value(forKey: "icon") as? String ?? "",
                    7:data.value(forKey: "iconLight") as? Bool ?? true,
                    13:false
                ]
                i = i + 1
                
                
            }
        } else { // Persons
            let dateSort = NSSortDescriptor(key: "createDate", ascending: false)
            var i = 0
            let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: false))
            
            let personData = dataHandler.loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [dateSort])
            
            for data in personData {
                var sum = 0.00

                let createDatePerson = (data.value(forKey: "createDate") as? Date ?? Date())
                
                let createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDatePerson)!
                let createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDatePerson)!
                
                let query = NSPredicate(format: "namePerson == %@ AND createDatePerson < %@ AND createDatePerson > %@", (data.value(forKey: "namePerson") as! NSString), (createDatePersonPlus as NSDate), (createDatePersonMinus as NSDate))
                let dateSort = NSSortDescriptor(key: "dateTimeTransaction", ascending: false)
                
                var userIsPartOfSplit:Bool?
                
                for split in dataHandler.loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [dateSort]) {
                    if userPartOfSplit(dateTime: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date())) {
                        userIsPartOfSplit = true
                    } else {
                        continue
                    }
                    
                    if !personOrUserPaid(dateTimeTransaction: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()), namePerson: (data.value(forKey: "namePerson") as? String ?? ""), dateTimeUser: createDatePerson) {
                        continue
                    }
                    
                    let createTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                    let createTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                    
                    let query = NSPredicate(format: "dateTime < %@ AND dateTime > %@", (createTransactionPlus as NSDate), (createTransactionMinus as NSDate))
                    let dateSort = NSSortDescriptor(key: "dateTime", ascending: false)
                    
                    for transaction in dataHandler.loadBulkQueriedSorted(entitie: "Transactions", query: query, sort: [dateSort]) {
                        let exchangeRate = (transaction.value(forKey: "exchangeRate") as? Double ?? 1.00)
                        
                        let settled = (split.value(forKey: "settled") as? Double ?? 0.00)/exchangeRate
                        let sumTransaction = (transaction.value(forKey: "amount") as? Double ?? 0.00)/exchangeRate
                        
                        if userIsPartOfSplit ?? false {
                            if (split.value(forKey: "paidByUser") as? Bool ?? true) {
                                let ratio = (split.value(forKey: "ratio") as? Double ?? 0.00)
                                sum = sum - (sumTransaction*ratio) + settled
                            } else {
                                let queryUserRatio = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@ AND dateTimeTransaction < %@ AND dateTimeTransaction > %@", (userDateUserPlus as NSDate), (userDateUserMinus as NSDate), (nameUser ?? "") as NSString, (createTransactionPlus as NSDate), (createTransactionMinus as NSDate))
                                let ratio = dataHandler.loadQueriedAttribute(entitie: "Splits", attibute: "ratio", query: queryUserRatio) as? Double ?? (1-(split.value(forKey: "ratio") as? Double ?? 0.00))
                                let settledUser = (dataHandler.loadQueriedAttribute(entitie: "Splits", attibute: "settled", query: queryUserRatio) as? Double ?? (1-(split.value(forKey: "ratio") as? Double ?? 0.00)))/exchangeRate
                                sum = sum + sumTransaction*ratio - settledUser
                            }
                        }
                    }
                }
                
                var sumString:String?
                var personSumString:String?
                
                if sum == 0.00 {
                    sumString = NSLocalizedString("allSettledSplit", comment: "All Settled Split")
                    personSumString = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: 0.00)) ?? "0.00")
                } else if sum < 0 {
                    sum = abs(sum)
                    sumOwed = sumOwed + sum
                    personSumString = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: sum)) ?? "0.00")
                    sumString = NSLocalizedString("youAreOwedLabel", comment: "Owed Sublabel")// + " " + amount
                } else {
                    sumBorrowed = sumBorrowed + sum
                    personSumString = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: sum)) ?? "0.00")
                    sumString = NSLocalizedString("youBorrowedLabel", comment: "Borrowed Sublabel")// + " " + amount
                }
                
                rowData[i] = [
                    0:(data.value(forKey: "namePerson") as? String ?? ""),
                    1:data.value(forKey: "color") as? Int16 ?? 0,
                    2:sumString ?? "",
                    3:personSumString ?? "",
                    4:createDatePerson,
                    5:1,
                    6:data.value(forKey: "icon") as? String ?? "",
                    7:data.value(forKey: "iconLight") as? Bool ?? true,
                    13:false
                ]
                i = i + 1
            }
        }
    }
    
    @objc func addNew() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "addNewPersonGroup", sender: nil)
        }
    }
    
    @objc func transactionAdded() {
        initRows(clearRows: true)
        createDataForRows()
//        getOverviewAmounts()
        splitTableView.reloadData()
    }
    
    @objc func groupPersonAdded() {
        createDataForRows()
        splitTableView.reloadData()
    }
    
    // MARK: HELPER FUNCIONS
    func getSymbol(forCurrencyCode code: String) -> String? {
        let locale = NSLocale(localeIdentifier: code)
        if locale.displayName(forKey: .currencySymbol, value: code) == code {
            let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: code)
        }
        return locale.displayName(forKey: .currencySymbol, value: code)
    }
    
    func userPartOfSplit(dateTime: Date) -> Bool {
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
        if dataHandler.loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [nameSort]).count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func personOrUserPaid(dateTimeTransaction: Date, namePerson: String, dateTimeUser: Date) -> Bool {
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        
        let personDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTimeUser)!
        let personDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTimeUser)!
        
        let dateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTimeTransaction)!
        let dateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTimeTransaction)!
        
        let query = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePersonWhoPaid == %@ AND createDatePersonWhoPaid > %@ AND createDatePersonWhoPaid < %@", (dateTransactionMinus as NSDate), (dateTransactionPlus as NSDate), (namePerson as NSString), (personDateMinus as NSDate), (personDatePlus as NSDate))
        
        if dataHandler.loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [nameSort]).count > 0 {
            return true
        }
        
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
            
        var nameUser:String?
        var createDateUser:Date?
        
        for data in dataHandler.loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
            
        let userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        let userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
            
        let queryUserPaid = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePersonWhoPaid == %@ AND createDatePersonWhoPaid > %@ AND createDatePersonWhoPaid < %@", (dateTransactionMinus as NSDate), (dateTransactionPlus as NSDate), ((nameUser ?? "") as NSString), (userDateMinus as NSDate), (userDatePlus as NSDate))
            
        if dataHandler.loadBulkQueriedSorted(entitie: "Splits", query: queryUserPaid, sort: [nameSort]).count <= 0 {
            return false
        } else {
            return true
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier ?? "") {
        case "splitDetailSelected":
            guard let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.topViewController as? splitDetailTVC
            else {
                fatalError()
            }
            viewController.personOrGroupName = selectedRowPersonOrGroup ?? ""
            viewController.createDate = createDate ?? Date()
            viewController.selectedSegement = selectedSegement
            break
        default:
            break
        }
    }
}

// Context Menu
extension splitMasterTVC: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if UIDevice().model.contains("iPad") {
            return UIContextMenuConfiguration(
                identifier: IndexPath(row: (interaction.view?.tag ?? -1), section: 0) as NSIndexPath,
                previewProvider: nil,
                  actionProvider: { _ in
                    let children: [UIMenuElement] = [self.makeEditAction(row: (interaction.view?.tag ?? -1))]
                    return UIMenu(title: "", children: children)
                  })
        } else {
            return UIContextMenuConfiguration(
                identifier: IndexPath(row: (interaction.view?.tag ?? -1), section: 0) as NSIndexPath,
                previewProvider: { self.makeDetailPreview(row: (interaction.view?.tag ?? -1)) },
                  actionProvider: { _ in
                    let children: [UIMenuElement] = []//[self.makeDeleteAction(rowString: String(interaction.view?.tag ?? -1))]
                    return UIMenu(title: "", children: children)
                  })
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            self.show(self.makeDetailPreview(row: (interaction.view?.tag ?? -1)), sender: self)
        }
    }
    
    func makeDetailPreview(row: Int) -> UIViewController {
        let finStoryBoard: UIStoryboard = UIStoryboard(name: "splitTSB", bundle: nil)
        let addSplitVC = finStoryBoard.instantiateViewController(withIdentifier: "splitAddNewTVC") as! splitAddNewTVC
        
        addSplitVC.update = selectedSegement
        addSplitVC.updateGroupOrPersonName = rowData[(row)]?[0] as? String ?? ""
        addSplitVC.updateCreateDate = (rowData[(row)]?[4] as? Date ?? Date())

        let navigationVC = UINavigationController(rootViewController: addSplitVC)
        return navigationVC
    }
    
    func makeEditAction(row: Int) -> UIAction {
        return UIAction(
            title: NSLocalizedString("editSomethingLabel", comment: "Edit"),
            image: UIImage(systemName: "pencil"),
            identifier: UIAction.Identifier(String(row)+"_edit"),
            handler: openEdit)
    }
    
    func openEdit(from action: UIAction) {
        let identifier = String(action.identifier.rawValue).replacingOccurrences(of: "_edit", with: "")
        let numFormater = NumberFormatter()
        numFormater.numberStyle = .none
        
        let finStoryBoard: UIStoryboard = UIStoryboard(name: "splitTSB", bundle: nil)
        let addSplitVC = finStoryBoard.instantiateViewController(withIdentifier: "splitAddNewTVC") as! splitAddNewTVC
        
        let row = Int(truncating: numFormater.number(from: identifier) ?? -1)
        
        if row != -1 {
            addSplitVC.updateGroupOrPersonName = rowData[(row)]?[0] as? String ?? ""
            addSplitVC.updateCreateDate = (rowData[(row)]?[4] as? Date ?? Date())
        }
        
        addSplitVC.update = selectedSegement
        
        let navigationVC = UINavigationController(rootViewController: addSplitVC)
        
        self.present(navigationVC, animated: true, completion: nil)
    }
}

extension splitMasterTVC: splitBottomBarDelegate {
    func segmentControlChanged(selected: Int) {
        selectedSegement = selected
        if selected == 0  {
            navTitle = NSLocalizedString("bottomSegmentGroups", comment: "Segment Group Text")
            createDataForRows()
            splitTableView.reloadData()
        } else {
            navTitle = NSLocalizedString("bottomSegmentUsers", comment: "Segment User Text")
            createDataForRows()
            splitTableView.reloadData()
        }
        headerView.headerLabel.text = navTitle
        if (splitTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSplitGeneral) != nil {
            selectedRowPersonOrGroup = (rowData[(IndexPath(row: 1, section: 0)).row]?[0] as? String ?? "")
        } else {
            selectedRowPersonOrGroup = ""
        }
        selectedRowIndex = nil
        initFirstSelected()
    }
}
