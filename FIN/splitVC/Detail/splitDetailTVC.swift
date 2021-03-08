//
//  splitDetailTVC.swift
//  FIN
//
//  Created by Florian Riel on 05.10.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

class splitDetailTVC: UITableViewController {

    @IBOutlet var detailSplitViewTable: UITableView!
    
    var rowData = [Int:[Int:Any]]()
    
    var numberFormatter = NumberFormatter()
    let dateFormatter = ISO8601DateFormatter()
    
    var sumOwed:Double?
    var sumBorrowed:Double?
    
    var isWideScreen: Bool = false
    var viewDisappear = false
    
    var isTopVC:Bool = false
    
    var personOrGroupName:String?
    var createDate:Date?
    
    var selectedRowIndex:Int?
    var selectedSegement:Int?
    var selectedCreateDate:Date?
    var selectedGroupName:String?
    var selectedGroupCreateDate:Date?
    
    var selectedRowPerson:String?
    
    var user:Bool?
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    let headerHeightFactor = CGFloat(0.10)
    var navTitle:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("settleNavitem", comment: "Segment Group Text"), style: .done, target: self, action: #selector(settleSplits))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "editIcon")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(edit))
        
        NotificationCenter.default.addObserver(self, selector: #selector(groupPersonAdded), name: Notification.Name("groupPersonAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(groupPersonDeleted), name: Notification.Name("groupPersonDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeHeaderTitle(notification:)), name: Notification.Name("changeHeaderTitle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(detailListDisappeared), name: Notification.Name("detailListDisappeared"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(groupPersonAdded), name: Notification.Name("groupPersonUpdated"), object: nil)
        
        numberFormatter.numberStyle = .decimal
//        numberFormatter.locale = Locale.current
        
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = Locale.current.groupingSeparator
        numberFormatter.groupingSize = 3
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        if isUser(createDate: (createDate ?? Date()), namePerson: (personOrGroupName ?? "")) {
            navTitle = (personOrGroupName ?? "") + " [" + (NSLocalizedString("youTheUser", comment: "I")) + "]"
        } else {
            navTitle = (personOrGroupName ?? "")
        }
        
        if navTitle?.count ?? 0 <= 0 {
            navTitle = " "
        }

        createDataForRows()
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        initFirstSelected()
        if selectedRowPerson != nil {
            selectedRowPerson = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        viewDisappear = true
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.navigationController?.view.backgroundColor = backgroundGeneralColor
            view.backgroundColor = backgroundGeneralColor
            detailSplitViewTable.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            detailSplitViewTable.backgroundColor = .secondarySystemBackground
        }
        
        initView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (rowData.count+1)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if rowData.count != 0 {
            if indexPath.row == 0 {
                return getOverviewCell(indexPath: indexPath)
            } else {
                return getGeneralCell(indexPath: indexPath)
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath) as! subtitleCellTVC
            cell.subtitleLabel.text = NSLocalizedString("noDataText", comment: "No Entries")
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedSegement == 0 && indexPath.row != 0 {
            initRows(indexPathSelected: indexPath)
            UISelectionFeedbackGenerator().selectionChanged()
            
            selectedRowIndex = indexPath.row
            selectedRowPerson = rowData[indexPath.row]?[1] as? String ?? ""
            selectedCreateDate = rowData[indexPath.row]?[5] as? Date ?? Date()
            selectedGroupName = personOrGroupName ?? ""
            selectedGroupCreateDate = createDate ?? Date()
//            if UIDevice().model.contains("iPad") {
//                DispatchQueue.main.async {
//                    self.performSegue(withIdentifier: "selfShowPersons", sender: nil)
//                }
//            } else {
            let splitDetailStoryBoard: UIStoryboard = UIStoryboard(name: "splitTSB", bundle: nil)
            let splitDetailVC = splitDetailStoryBoard.instantiateViewController(withIdentifier: "splitDetailTVC") as! splitDetailTVC
                
            splitDetailVC.personOrGroupName = selectedRowPerson ?? "User"
            splitDetailVC.createDate = selectedCreateDate ?? Date()
            splitDetailVC.selectedSegement = 1
            
            if (selectedGroupName?.count ?? 0) > 0 {
                splitDetailVC.selectedGroupName = selectedGroupName ?? ""
                splitDetailVC.selectedGroupCreateDate = selectedGroupCreateDate ?? Date()
            }
            
            splitDetailVC.modalPresentationStyle = .fullScreen
            selectedRowIndex = nil
            self.navigationController?.pushViewController(splitDetailVC, animated: true)
//            }
        } else if indexPath.row == 0 {
            initRows(indexPathSelected: indexPath)
            
            let settleSplitStoryBoard: UIStoryboard = UIStoryboard(name: "settleSplit", bundle: nil)
            let settleSplitVC = settleSplitStoryBoard.instantiateViewController(withIdentifier: "settleSplitTVC") as! settleSplitTVC
            
            if selectedSegement == 0 { // Group
                settleSplitVC.groupName = personOrGroupName ?? ""
                settleSplitVC.createDateGroup = createDate ?? Date()
            } else { // Person
                settleSplitVC.personName = personOrGroupName ?? ""
                settleSplitVC.createDatePerson = createDate ?? Date()
                if selectedGroupName != nil && selectedGroupCreateDate != nil {
                    settleSplitVC.createDateGroup = selectedGroupCreateDate ?? Date()
                    settleSplitVC.groupName = selectedGroupName ?? ""
                }
            }
            
            let navigationVC = UINavigationController(rootViewController: settleSplitVC)
            self.present(navigationVC, animated: true, completion: nil)
        } else {
            initRows(indexPathSelected: indexPath)
            isTopVC = true
            
            let listStoryBoard: UIStoryboard = UIStoryboard(name: "listTSB", bundle: nil)
            let transactionVC = listStoryBoard.instantiateViewController(withIdentifier: "TransactionDetail") as! listDetailTVC
            
            transactionVC.superSplit = true
            transactionVC.dateOfSelectedRow = rowData[indexPath.row]?[7] as? Date ?? Date()
            
            let navigationVC = UINavigationController(rootViewController: transactionVC)
            self.present(navigationVC, animated: true, completion: nil)
        }
    }
    
    // MARK: -CELL FUNCTIONS
    func getOverviewCell(indexPath: IndexPath) -> cellSplitOverview {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitOverview", for: indexPath) as! cellSplitOverview
        
        cell.borrowedAmount.isHidden = true
        cell.borrowedLabel.text = NSLocalizedString("tabToSettle", comment: "Tab to Settle")
        cell.borrowedLabel.textColor = .link
        
        if (user ?? false) && (selectedSegement ?? 0) == 1 {
            if (sumOwed ?? 0.00) <= 0 {
                cell.owedLabel.text = NSLocalizedString("personBorrowedLabel", comment: "Person Borrowed Text")
            } else {
                cell.owedLabel.text = NSLocalizedString("personOwedLabel", comment: "Person Get Text")
            }
        } else {
            if (sumOwed ?? 0.00) <= 0 {
                cell.owedLabel.text = NSLocalizedString("borrowedLabel", comment: "You Borrowed Text")
            } else {
                cell.owedLabel.text = NSLocalizedString("owedLabel", comment: "You Get Text")
            }
        }
        
        cell.owedAmount.text = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: abs(sumOwed ?? 0.00))) ?? "0.00")
        
        return cell
    }
    
    func getGeneralCell(indexPath: IndexPath) -> cellSplitGeneral {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitGeneral", for: indexPath) as! cellSplitGeneral
        
        if selectedSegement == 0 {
            if isUser(createDate: (rowData[indexPath.row]?[5] as? Date ?? Date()), namePerson: (rowData[indexPath.row]?[1] as? String ?? "")) {
                cell.mainLabel.text = (rowData[indexPath.row]?[1] as? String ?? "") + " [" + (NSLocalizedString("youTheUser", comment: "I")) + "]"
            } else {
                cell.mainLabel.text = rowData[indexPath.row]?[1] as? String ?? ""
            }
        } else if selectedSegement == 1 {
            if isUser(createDate: (createDate ?? Date()), namePerson: (rowData[indexPath.row]?[1] as? String ?? "")) {
                cell.mainLabel.text = (rowData[indexPath.row]?[1] as? String ?? "") + " [" + (NSLocalizedString("youTheUser", comment: "I")) + "]"
            } else {
                cell.mainLabel.text = rowData[indexPath.row]?[1] as? String ?? ""
            }
        }
        
        cell.amountLabel.text = rowData[indexPath.row]?[0] as? String ?? ""
        
        if (rowData[indexPath.row]?[2] as? Bool ?? false) {
            if (rowData[indexPath.row]?[6] as? Bool ?? false) {
                cell.subLabel.text = NSLocalizedString("youAreOwedLabel", comment: "You are Owed text")
            } else {
                cell.subLabel.text = NSLocalizedString("personOwedLabel", comment: "Person is Owed text")
            }
        } else {
            if (rowData[indexPath.row]?[6] as? Bool ?? false) {
                cell.subLabel.text = NSLocalizedString("youBorrowedLabel", comment: "You have to pay text")
            } else {
                cell.subLabel.text = NSLocalizedString("personBorrowedLabel", comment: "Person has to pay text")
            }
        }
        
        if (rowData[indexPath.row]?[9] as? String ?? "").count > 0 {
            cell.circleLabel.isHidden = true
            cell.circleImage.isHidden = false
            
            var selectedIcon = (rowData[indexPath.row]?[9] as? String ?? "").replacingOccurrences(of: "_white", with: "")
            if (rowData[indexPath.row]?[10] as? Bool ?? true) {
                selectedIcon = selectedIcon + "_white"
            }
            
            cell.circleImage.image = UIImage(named: selectedIcon)
        } else {
            cell.circleLabel.isHidden = false
            cell.circleImage.isHidden = true
            
            if (rowData[indexPath.row]?[3] as? String ?? "").count > 1 {
                cell.circleLabel.text = (rowData[indexPath.row]?[3] as? String ?? "").prefix(2).uppercased()
            } else if (rowData[indexPath.row]?[3] as? String ?? "").count == 1 {
                cell.circleLabel.text = (rowData[indexPath.row]?[3] as? String ?? "").prefix(1).uppercased()
            } else {
                cell.circleLabel.text = ""
            }
            if (rowData[indexPath.row]?[10] as? Bool ?? true) {
                cell.circleLabel.textColor = .white
            } else {
                cell.circleLabel.textColor = .black
            }
        }
        
        cell.circleView.backgroundColor = UIColor.randomColor(color: Int(rowData[indexPath.row]?[4] as? Int16 ?? 0))
        cell.circleView.layer.borderColor = cell.circleView.backgroundColor?.cgColor
        
        if (rowData[indexPath.row]?[8] as? Int ?? 0) == 1 {
            cell.icon.isHidden = false
            cell.icon.image = UIImage(named: "tabPersonSelected")?.withRenderingMode(.alwaysTemplate)
        } else if (rowData[indexPath.row]?[8] as? Int ?? 0) == 2 {
            cell.icon.isHidden = false
            cell.icon.image = UIImage(named: "tabPersonsSelected")?.withRenderingMode(.alwaysTemplate)
        } else {
            cell.icon.isHidden = true
        }
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.outlineView.addInteraction(interaction)
        cell.outlineView.tag = indexPath.row
        
        return cell
    }
    
    func initRows(indexPathSelected: IndexPath = IndexPath(row: 0, section: 0), clearRows: Bool = false) {
        for i in 0...rowData.count {
            let indexPathRAM: IndexPath = IndexPath(row: i, section: 0)
            if let cell = detailSplitViewTable.cellForRow(at: indexPathRAM) as? cellSplitGeneral {
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
            if let cell = detailSplitViewTable.cellForRow(at: indexPathSelected) as? cellSplitGeneral {
                cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                cell.outlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
            }
        }
    }
    
    func initFirstSelected() {
//        if selectedRowIndex == nil && UIDevice().model.contains("iPad") {
//            selectedRowIndex = 1
//            initRows(indexPathSelected: IndexPath(row: selectedRowIndex ?? 0, section: 0))
//        } else
        if selectedRowIndex != nil && UIDevice().model.contains("iPad") {
            initRows(indexPathSelected: IndexPath(row: selectedRowIndex ?? 0, section: 0), clearRows: false)
        } else {
            initRows(clearRows: true)
        }
    }

    // MARK: -initViewFunctions

    func initView() {
        initTableAndHeaderView()
    }
    
    func initTableAndHeaderView() {
        detailSplitViewTable.sectionHeaderHeight = UITableView.automaticDimension
     
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            detailSplitViewTable.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
        } else {
            detailSplitViewTable.backgroundColor = .secondarySystemBackground
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
        headerView.scrollView = detailSplitViewTable
        
        detailSplitViewTable.backgroundView = UIView()
        detailSplitViewTable.backgroundView?.addSubview(headerView)
        detailSplitViewTable.contentInset = UIEdgeInsets(
            top: 85,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 40,
            right: 0
        )
    }
    
    // MARK: -FUNCTIONS
    
    func createDataForRows() {
        var i = 1
        rowData.removeAll()
        
        switch selectedSegement {
        case 1: // A person has been selected
            var groupSelected = false
            
            user = isUser(createDate: (createDate ?? Date()), namePerson: (personOrGroupName ?? ""))
            
            let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
            let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
        
            var userName:String = ""
            var createDateUser:Date = Date()
            
            for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
                userName = data.value(forKey: "namePerson") as? String ?? ""
                createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
            }
            
            let createDateUserPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser)!
            let createDateUserMinus =  Calendar.current.date(byAdding: .second, value: -1, to: createDateUser)!
            
            let dateSort = NSSortDescriptor(key: "dateTimeTransaction", ascending: false)
            
            let createDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDate ?? Date())!
            let createDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDate ?? Date())!
            
            var query = NSPredicate(format: "createDatePerson > %@ AND createDatePerson < %@ AND namePerson == %@", (createDateMinus as NSDate), (createDatePlus as NSDate), (personOrGroupName ?? ""))
            
            if (selectedGroupName?.count ?? 0) > 0 {
                let selectedGroupCreateDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: selectedGroupCreateDate ?? Date())!
                let selectedGroupCreateDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: selectedGroupCreateDate ?? Date())!
                
                query = NSPredicate(format: "createDatePerson > %@ AND createDatePerson < %@ AND namePerson == %@ AND createDateGroup > %@ AND createDateGroup < %@ AND nameGroup == %@", (createDateMinus as NSDate), (createDatePlus as NSDate), (personOrGroupName ?? ""), (selectedGroupCreateDateMinus as NSDate), (selectedGroupCreateDatePlus as NSDate), (selectedGroupName ?? ""))
                
                groupSelected = true
            }
            
            let splitData = loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [dateSort])
            
            for split in splitData {
                let paidByUserOrPerson = personOrUserPaid(dateTimeTransaction: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()), namePerson: (personOrGroupName ?? ""), dateTimeUser: (createDate ?? Date()))

                if !paidByUserOrPerson && !groupSelected {
                    continue
                }
                
                let settled = split.value(forKey: "settled") as? Double ?? 0.00
                var ratio = split.value(forKey: "ratio") as? Double ?? 0.00
                
                let dateTimeTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                let dateTimeTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                 
                let query = NSPredicate(format: "dateTime < %@ AND dateTime > %@", (dateTimeTransactionPlus as NSDate), (dateTimeTransactionMinus as NSDate))
                let dateSort = NSSortDescriptor(key: "dateTime", ascending: false)
                
                var amountSUM = 0.00
                
                for transaction in loadBulkQueriedSorted(entitie: "Transactions", query: query, sort: [dateSort]) {
                    let amount = transaction.value(forKey: "amount") as? Double ?? 0.00
                    let exchangeRate = transaction.value(forKey: "exchangeRate") as? Double ?? 1.00
                    
                    let plusCreateDatePersonWhoPaid = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()))!
                    let minusCreateDatePersonWhoPaid = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()))!
                    
                    let up = (split.value(forKey: "createDatePerson") as? Date ?? Date()).compare(plusCreateDatePersonWhoPaid) == .orderedAscending
                    let down = (split.value(forKey: "createDatePerson") as? Date ?? Date()).compare(minusCreateDatePersonWhoPaid) == .orderedDescending
                    
                    var ratioUser = ratio
                    var settledUser = 0.00
                    let isPersonWhoPaid = ((split.value(forKey: "namePerson") as? String ?? "") == (split.value(forKey: "namePersonWhoPaid") as? String ?? "")) && up && down
                    
                    if isPersonWhoPaid {
                        let queryUser = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@ AND dateTimeTransaction < %@ AND dateTimeTransaction > %@", createDateUserPlus as NSDate, createDateUserMinus as NSDate, userName as NSString, dateTimeTransactionPlus as NSDate, dateTimeTransactionMinus as NSDate)
                        
                        ratioUser = loadQueriedAttribute(entitie: "Splits", attibute: "ratio", query: queryUser) as? Double ?? 0.00
                        settledUser = loadQueriedAttribute(entitie: "Splits", attibute: "settled", query: queryUser) as? Double ?? 0.00
                        ratio = 1-ratio
                    }
                    
                    let cID = transaction.value(forKey: "categoryID") as? Int16 ?? 0
                    let queryCategory = NSPredicate(format: "cID == %i", cID)
                    let categoryName = loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory)
                    let categoryColor = loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0
                    let icon = loadQueriedAttribute(entitie: "Categories", attibute: "icon", query: queryCategory) as? String ?? ""
                    let iconLight = loadQueriedAttribute(entitie: "Categories", attibute: "iconLight", query: queryCategory) as? Bool ?? true

                    var amountString = ""
                    let amountPerson = amount*ratio
                
                    if isPersonWhoPaid {
                        amountSUM = amountSUM + ((amountPerson - settled)/exchangeRate) // Home Currency
                        amountString = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: abs(amountSUM))) ?? "")
                        sumOwed = (sumOwed ?? 0.00) - (((amount*ratioUser) - settledUser)/exchangeRate)
                    } else {
                        amountSUM = amountSUM - ((amountPerson - settled)/exchangeRate)
                        amountString = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: abs(amountSUM))) ?? "")
                        // Only if user paid, it is included in the overview
                        let up = (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()).compare(plusCreateDatePersonWhoPaid) == .orderedAscending
                        let down = (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()).compare(minusCreateDatePersonWhoPaid) == .orderedDescending
                        
                        if up && down && ((split.value(forKey: "namePersonWhoPaid") as? String ?? "") == userName) {
                            sumOwed = (sumOwed ?? 0.00) + (((amount*ratioUser) - settled)/exchangeRate)
                        }
                    }
                    
                    rowData[i] = [
                        0:amountString,
                        1:(transaction.value(forKey: "descriptionNote") as? String ?? ""),
                        2:isPersonWhoPaid,
                        3:categoryName,
                        4:categoryColor,
                        6:(user ?? true),
                        7:(split.value(forKey: "dateTimeTransaction") as? Date ?? Date()),
                        8:isSplit(transactionDateTime: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date())),
                        9:icon,
                        10:iconLight,
                        13:false
                    ]
                    i = i + 1
                }
            }
            break
        default: // A group has been selected
            let createDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDate ?? Date())!
            let createDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDate ?? Date())!
            
            let query = NSPredicate(format: "nameGroup == %@ AND createDate > %@ AND createDate < %@", (personOrGroupName ?? ""), (createDateMinus as NSDate), (createDatePlus as NSDate))

            let personsLoad = (loadQueriedAttribute(entitie: "SplitGroups", attibute: "persons", query: query) as? String ?? "")
            let persons = personsLoad.components(separatedBy: "*;*")
            if persons.count > 0 {
                
                for person in persons {
                    let personArray = person.components(separatedBy: "*&*")
                    let personName = personArray[0]
                    if personName.count <= 0 {
                        continue
                    }
                    
                    let personCreateDate = dateFormatter.date(from: personArray[1]) ?? Date()
                    
                    let personCreateDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: personCreateDate)!
                    let personCreateDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: personCreateDate)!
                    
                    let queryPerson = NSPredicate(format: "createDate < %@ AND createDate > %@ AND namePerson == %@", (personCreateDatePlus as NSDate), (personCreateDateMinus as NSDate) , (personName as NSString))
                    
                    let querySplits = NSPredicate(format: "createDatePerson > %@ AND createDatePerson < %@ AND namePerson == %@ AND nameGroup == %@ AND createDateGroup > %@ AND createDateGroup < %@", (personCreateDateMinus as NSDate), (personCreateDatePlus as NSDate), (personName as NSString), (personOrGroupName ?? "") as NSString, (createDateMinus as NSDate), (createDatePlus as NSDate))
                    
                    var amountSUM:Double?
                    
                    let dateSort = NSSortDescriptor(key: "dateTimeTransaction", ascending: false)
                    let personColor = loadQueriedAttribute(entitie: "SplitPersons", attibute: "color", query: queryPerson) as? Int16 ?? 0
                    let icon = loadQueriedAttribute(entitie: "SplitPersons", attibute: "icon", query: queryPerson) as? String ?? ""
                    let iconLight = loadQueriedAttribute(entitie: "SplitPersons", attibute: "iconLight", query: queryPerson) as? Bool ?? true

                    for split in loadBulkQueriedSorted(entitie: "Splits", query: querySplits, sort: [dateSort]) {
                        let dateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                        let dateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                        
                        let query = NSPredicate(format: "dateTime > %@ AND dateTime < %@", dateTransactionMinus as NSDate, dateTransactionPlus as NSDate)
                        let dateSort = NSSortDescriptor(key: "dateTime", ascending: false)
                        
                        for transaction in loadBulkQueriedSorted(entitie: "Transactions", query: query, sort: [dateSort]) {
                            let amount = transaction.value(forKey: "amount") as? Double ?? 0.00 // Transaction Currency
                            let exchangeRate = transaction.value(forKey: "exchangeRate") as? Double ?? 1.00
                            
                            let settled = (split.value(forKey: "settled") as? Double ?? 0.00)/exchangeRate // Home Currency
                            let ratio = split.value(forKey: "ratio") as? Double ?? 0.00
                            let amountPerson = (amount/exchangeRate)*ratio // Home Currency
                            
                            let plusCreateDatePersonWhoPaid = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()))!
                            let minusCreateDatePersonWhoPaid = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()))!
                            
                            let up = (split.value(forKey: "createDatePerson") as? Date ?? Date()).compare(plusCreateDatePersonWhoPaid) == .orderedAscending
                            let down = (split.value(forKey: "createDatePerson") as? Date ?? Date()).compare(minusCreateDatePersonWhoPaid) == .orderedDescending
                            
                            let isPersonWhoPaid = ((split.value(forKey: "namePerson") as? String ?? "") == (split.value(forKey: "namePersonWhoPaid") as? String ?? "")) && up && down
                            
                            let upPerson = (split.value(forKey: "createDatePerson") as? Date ?? Date()).compare(personCreateDatePlus) == .orderedAscending
                            let downPerson = (split.value(forKey: "createDatePerson") as? Date ?? Date()).compare(personCreateDateMinus) == .orderedDescending
                            
                            let isPerson = upPerson && downPerson && (personName == (split.value(forKey: "namePerson") as? String ?? ""))
                            if isUser(createDate: (split.value(forKey: "createDatePerson") as? Date ?? Date()), namePerson: (split.value(forKey: "namePerson") as? String ?? "")) {
                                if isPersonWhoPaid {
                                    sumOwed = (sumOwed ?? 0.00) + (amount/exchangeRate) - settled - amountPerson
                                } else {
                                    sumOwed = (sumOwed ?? 0.00) - amountPerson + settled
                                }
                            } else {
                                if isPersonWhoPaid && isPerson {
                                    amountSUM = (amountSUM ?? 0.00) + (amount/exchangeRate) - settled - amountPerson
                                } else if !isPersonWhoPaid && isPerson {
                                    amountSUM = (amountSUM ?? 0.00) - amountPerson + settled
                                }
                            }
                            
                        }
                    }
                    
                    let amountString:String?
                    var owed:Bool?
                    
                    user = isUser(createDate: personCreateDate, namePerson: personName)
                    
                    if amountSUM ?? 0.00 <= 0 {
                        owed = false
                        amountString = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: (abs(amountSUM ?? 0.00)))) ?? "")
                    } else {
                        owed = true
                        amountString = (getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(from: NSNumber(value: amountSUM ?? 0.00)) ?? "")
                    }
                    
                    if !(user ?? false) {
                        rowData[i] = [
                            0:amountString ?? "0.00",
                            1:personName,
                            2:owed ?? false,
                            3:personName,
                            4:personColor,
                            5:personCreateDate,
                            6:(user ?? false),
                            8:1,
                            9:icon,
                            10:iconLight,
                            13:false
                        ]
                        i = i + 1
                    }
                }
            }
            break
        }
        detailSplitViewTable.reloadData()
    }
    
    func getUserAmount(dateTimeTransaction: Date) -> Double {
        var ratio:Double?
        var settled:Double?
        var transactionAmount:Double?
        
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
        
        var nameUser:String?
        var createDateUser:Date?
        
        for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
        
        let userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        let userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
        
        let dateTimeTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTimeTransaction)!
        let dateTimeTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTimeTransaction)!
        
        let dateSortSplit = NSSortDescriptor(key: "dateTimeTransaction", ascending: false)
        let querySplit = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@ AND namePerson == %@ AND createDatePerson < %@ AND createDatePerson > %@", (dateTimeTransactionPlus as NSDate), (dateTimeTransactionMinus as NSDate), ((nameUser ?? "User") as NSString), (userDatePlus as NSDate), (userDateMinus as NSDate))
        
        for split in loadBulkQueriedSorted(entitie: "Splits", query: querySplit, sort: [dateSortSplit]) {
            ratio = split.value(forKey: "ratio") as? Double ?? 0.00
            settled = (split.value(forKey: "settled") as? Double ?? 1.00)
        }
        
        let dateSortTransaction = NSSortDescriptor(key: "dateTime", ascending: false)
        let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", dateTimeTransactionPlus as NSDate, dateTimeTransactionMinus as NSDate)
        
        for transaction in loadBulkQueriedSorted(entitie: "Transactions", query: queryTransaction, sort: [dateSortTransaction]) {
            transactionAmount = (transaction.value(forKey: "amount") as? Double ?? 0.00)/(transaction.value(forKey: "exchangeRate") as? Double ?? 1.00)
        }
        
        return (transactionAmount ?? 0.00)*(ratio ?? 0.00)-(settled ?? 0.00)
    }
    
    func isSplit(transactionDateTime: Date) -> Int {
        let query = NSPredicate(format: "dateTimeTransaction == %@", transactionDateTime as NSDate)
        var isSplit = 0
        
        for split in loadBulkQueried(entitie: "Splits", query: query) {
            if (split.value(forKey: "nameGroup") as? String ?? "").count > 0 {
                isSplit = 2
            } else {
                isSplit = 1
            }
            break
        }
        return isSplit
    }
    
    @objc func settleSplits() {
        
    }
    
    @objc func edit() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "editGroupOrPerson", sender: nil)
        }
    }
    
    @objc func changeHeaderTitle(notification: Notification) {
        if let userInfo = notification.userInfo, let newHeaderTitle = userInfo["newHeaderTitle"] as? String, let oldName = userInfo["oldName"] as? String {
            if oldName == navTitle {
                navTitle = newHeaderTitle
                headerView.headerLabel.text = navTitle
                if selectedRowPerson != nil {
                    selectedRowPerson = newHeaderTitle
                } else {
                    personOrGroupName = newHeaderTitle
                }
                createDataForRows()
            }
        }
    }
    
    @objc func groupPersonAdded() {
        sumOwed = 0.00
        createDataForRows()
//        if let userInfo = notification.userInfo {
//            personOrGroupName = userInfo["personOrGroupName"] as? String ?? ""
//            createDate = userInfo["createDate"] as? Date ?? Date()
//        }
    }
    
    @objc func groupPersonDeleted() {
        initRows(clearRows: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if UIDevice().model.contains("iPad") {
                self.navigationController?.navigationController?.popToRootViewController(animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func detailListDisappeared() {
        if isTopVC {
            isTopVC = false
            initRows(clearRows: false)
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier ?? "") {
        case "selfShowPersons":
            guard let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.topViewController as? splitDetailTVC
            else {
                fatalError()
            }
            viewController.personOrGroupName = selectedRowPerson ?? "User"
            viewController.createDate = selectedCreateDate ?? Date()
            viewController.selectedSegement = 1
            
            if (selectedGroupName?.count ?? 0) > 0 {
                viewController.selectedGroupName = selectedGroupName ?? ""
                viewController.selectedGroupCreateDate = selectedGroupCreateDate ?? Date()
            }
            
            viewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            viewController.navigationItem.leftItemsSupplementBackButton = true
            
            break
        case "editGroupOrPerson":
            guard let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.topViewController as? splitAddNewTVC
            else {
                fatalError()
            }
            viewController.update = selectedSegement ?? 0
            viewController.updateGroupOrPersonName = personOrGroupName
            viewController.updateCreateDate = createDate
            
        default:
            break
        }
    }
}

// Context Menu
extension splitDetailTVC: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        if UIDevice().model.contains("iPad") {
            if selectedSegement == 0 { // Group has been selected
                return UIContextMenuConfiguration(
                    identifier: IndexPath(row: (interaction.view?.tag ?? -1), section: 0) as NSIndexPath,
                    previewProvider: nil,
                      actionProvider: { _ in
                        let children: [UIMenuElement] = [self.makeEditPersonAction(row: (interaction.view?.tag ?? -1))]
                        return UIMenu(title: "", children: children)
                      })
            } else { // Person has been selected
                return UIContextMenuConfiguration(
                    identifier: IndexPath(row: (interaction.view?.tag ?? -1), section: 0) as NSIndexPath,
                    previewProvider: nil,
                      actionProvider: { _ in
                        let children: [UIMenuElement] = [self.makeEditTransactionAction(row: (interaction.view?.tag ?? -1)),self.makeDeleteAction(rowString: String(interaction.view?.tag ?? -1))]
                        return UIMenu(title: "", children: children)
                      })
            }
        } else {
            if selectedSegement == 0 { // Group has been selected
                return UIContextMenuConfiguration(
                    identifier: IndexPath(row: (interaction.view?.tag ?? -1), section: 0) as NSIndexPath,
                    previewProvider: { self.makeSplitPersonDetailPreview(row: (interaction.view?.tag ?? -1)) },
                      actionProvider: { _ in
                        let children: [UIMenuElement] = []
                        return UIMenu(title: "", children: children)
                      })
            } else { // Person has been selected
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
        if selectedSegement == 0 {
            animator.addCompletion {
                self.show(self.makeSplitPersonDetailPreview(row: (interaction.view?.tag ?? -1)), sender: self)
            }
        } else {
            animator.addCompletion {
                self.show(self.makeDetailPreview(row: (interaction.view?.tag ?? -1)), sender: self)
            }
        }
    }
    
    func makeDeleteAction(rowString: String) -> UIAction {
      return UIAction(
        title: NSLocalizedString("deleteButton", comment: "Delete"),
        image: UIImage(systemName: "trash"),
        identifier: UIAction.Identifier(rowString),
        attributes: .destructive,
        handler: deleteTransaction)
    }
    
    func deleteTransaction(from action: UIAction) {
        let identifier = String(action.identifier.rawValue)
        
        let numFormater = NumberFormatter()
        numFormater.numberStyle = .none
        
        let row = Int(truncating: numFormater.number(from: identifier) ?? -1)

        if row != -1 {
            let transactionDate = (rowData[(row)]?[7] as? Date ?? Date())
            
            let dateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: transactionDate)!
            let dateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: transactionDate)!

            let queryDelete = NSPredicate(format: "dateTime < %@ AND dateTime > %@", dateTransactionPlus as NSDate, dateTransactionMinus as NSDate)
            deleteDataQueried(entity: "Transactions", query: queryDelete)

            let querySplits = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", dateTransactionPlus as NSDate, dateTransactionMinus as NSDate)
            deleteDataQueried(entity: "Splits", query: querySplits)
            
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("transactionDeleted"), object: nil)
            nc.post(name: Notification.Name("groupPersonAdded"), object: nil)
        }
    }
    
    func makeEditPersonAction(row: Int) -> UIAction {
        return UIAction(
            title: NSLocalizedString("editRegularPaymentTitle", comment: "Edit"),
            image: UIImage(systemName: "pencil"),
            identifier: UIAction.Identifier(String(row)+"_edit"),
            handler: openEditPerson)
    }
    
    func openEditPerson(from action: UIAction) {
        let identifier = String(action.identifier.rawValue).replacingOccurrences(of: "_edit", with: "")
        let numFormater = NumberFormatter()
        numFormater.numberStyle = .none
        
        let finStoryBoard: UIStoryboard = UIStoryboard(name: "splitTSB", bundle: nil)
        let addSplitVC = finStoryBoard.instantiateViewController(withIdentifier: "splitAddNewTVC") as! splitAddNewTVC
        
        let row = Int(truncating: numFormater.number(from: identifier) ?? -1)
        
        if row != -1 {
            addSplitVC.updateGroupOrPersonName = rowData[(row)]?[1] as? String ?? ""
            addSplitVC.updateCreateDate = (rowData[(row)]?[5] as? Date ?? Date())
        }
        
        addSplitVC.update = 1
        
        let navigationVC = UINavigationController(rootViewController: addSplitVC)
        
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func makeEditTransactionAction(row: Int) -> UIAction {
        return UIAction(
            title: NSLocalizedString("editRegularPaymentTitle", comment: "Edit"),
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
            if let latestTransactionDate = (rowData[(row)]?[7] as? Date) {
                addVC.updateCreateDate = latestTransactionDate
            }
        }
        
        let navigationVC = UINavigationController(rootViewController: addVC)
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func makeSplitPersonDetailPreview(row: Int) -> UIViewController {
        let finStoryBoard: UIStoryboard = UIStoryboard(name: "splitTSB", bundle: nil)
        let addSplitVC = finStoryBoard.instantiateViewController(withIdentifier: "splitAddNewTVC") as! splitAddNewTVC
        
        addSplitVC.update = 1
        addSplitVC.updateGroupOrPersonName = rowData[(row)]?[1] as? String ?? ""
        addSplitVC.updateCreateDate = (rowData[(row)]?[5] as? Date ?? Date())

        let navigationVC = UINavigationController(rootViewController: addSplitVC)
        return navigationVC
    }
    
    func makeDetailPreview(row: Int) -> UIViewController {
        let finStoryBoard: UIStoryboard = UIStoryboard(name: "finTSB", bundle: nil)
        let addVC = finStoryBoard.instantiateViewController(withIdentifier: "addTVC") as! addTVC
        
        if let latestTransactionDate = (rowData[(row)]?[7] as? Date) {
            addVC.updateCreateDate = latestTransactionDate
        }
        
        let navigationVC = UINavigationController(rootViewController: addVC)
        return navigationVC
    }
}

// MARK: -DATA
extension splitDetailTVC {
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
    
    func loadBulkSorted(entitie:String, sort:[NSSortDescriptor]) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = sort
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
    
    func loadData(entitie:String, attibute:String) -> Any {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
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
    
    func deleteDataQueried(entity: String, query: NSPredicate) {
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
    
    func isUser(createDate:Date, namePerson:String) -> Bool {
        let plusCreateDate = Calendar.current.date(byAdding: .second, value: 1, to: createDate)!
        let minusCreateDate = Calendar.current.date(byAdding: .second, value: -1, to: createDate)!
        
        let query = NSPredicate(format: "createDate < %@ AND createDate > %@ AND namePerson == %@", (plusCreateDate as NSDate), (minusCreateDate as NSDate) , (namePerson as NSString))
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SplitPersons")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                if data.value(forKey: "isUser") != nil {
                    return data.value(forKey: "isUser") as? Bool ?? false
                }
            }
        } catch {
            print("Could not fetch. \(error)")
        }
        
        return false
    }
    
    func userPartOfSplit(dateTime: Date) -> Bool {
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
        
        var nameUser:String?
        var createDateUser:Date?
        
        for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
        
        let userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        let userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
        
        let datePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTime)!
        let dateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTime)!
        
        let query = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePerson == %@ AND createDatePerson > %@ AND createDatePerson < %@", (dateMinus as NSDate), (datePlus as NSDate), ((nameUser ?? "") as NSString), ((userDateMinus) as NSDate), ((userDatePlus) as NSDate))
        if loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [nameSort]).count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func getRatioUser(dateTimeTransaction: Date) -> Double {
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
            
        var nameUser:String?
        var createDateUser:Date?
            
        for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
            
        let userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        let userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
        
        let dateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTimeTransaction)!
        let dateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTimeTransaction)!
        
        let query = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePerson == %@ AND createDatePerson > %@ AND createDatePerson < %@", (dateTransactionMinus as NSDate), (dateTransactionPlus as NSDate), ((nameUser ?? "") as NSString), (userDateMinus as NSDate), (userDatePlus as NSDate))
        
        for split in loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [nameSort]) {
            return (split.value(forKey: "ratio") as? Double ?? 0.00)
        }
        return 0.00
    }
    
    func personOrUserPaid(dateTimeTransaction: Date, namePerson: String, dateTimeUser: Date) -> Bool {
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        
        let personDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTimeUser)!
        let personDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTimeUser)!
        
        let dateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTimeTransaction)!
        let dateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTimeTransaction)!
        
        let query = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePersonWhoPaid == %@ AND createDatePersonWhoPaid > %@ AND createDatePersonWhoPaid < %@", (dateTransactionMinus as NSDate), (dateTransactionPlus as NSDate), (namePerson as NSString), (personDateMinus as NSDate), (personDatePlus as NSDate))
        
        if loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [nameSort]).count > 0 {
            return true
        }
        
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
            
        var nameUser:String?
        var createDateUser:Date?
            
        for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
            
        let userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        let userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
            
        let queryUserPaid = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePersonWhoPaid == %@ AND createDatePersonWhoPaid > %@ AND createDatePersonWhoPaid < %@", (dateTransactionMinus as NSDate), (dateTransactionPlus as NSDate), ((nameUser ?? "") as NSString), (userDateMinus as NSDate), (userDatePlus as NSDate))
            
        if loadBulkQueriedSorted(entitie: "Splits", query: queryUserPaid, sort: [nameSort]).count <= 0 {
            return false
        } else {
            return true
        }
    }
}
