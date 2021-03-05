//
//  settleSplitTVC.swift
//  FIN
//
//  Created by Florian Riel on 07.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

class settleSplitTVC: UITableViewController {

    @IBOutlet var settleSplitTableView: UITableView!
    
    var rowData = [Int:[Int:Any]]()
    
    var createDateGroup:Date?
    var groupName:String?
    
    var createDatePerson:Date?
    var personName:String?
    
    var transactionCreateDate:Date?
    
    var numberFormatter = NumberFormatter()
    let dateFormatter = ISO8601DateFormatter()
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    let headerHeightFactor = CGFloat(0.10)
    var navTitle:String = ""
    
    var isWideScreen: Bool = false
    var viewDisappear = false
    
    var localCurrency:Bool = true
    
    var settleCase:Int = 0 // 0:Person Only; 1: Group Only; 2: Group & Person, but no Transaction; 3: Group && Person && Transaction, 4: No Group, but Person && Transaction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("backButton", comment: "Back"), style: .plain, target: self, action: #selector(cancel))
        NotificationCenter.default.addObserver(self, selector: #selector(currencyChanged(notification:)), name: Notification.Name("currencyChanged"), object: nil)
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        settleSplitTableView.keyboardDismissMode = .onDrag
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        numberFormatter.numberStyle = .decimal
//        numberFormatter.locale = Locale.current
        
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = Locale.current.groupingSeparator
        numberFormatter.groupingSize = 3
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        initView()
        createRowData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        viewDisappear = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        let nc = NotificationCenter.default
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            nc.post(name: Notification.Name("settleSplitDisappeared"), object: nil)
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
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.navigationController?.view.backgroundColor = backgroundGeneralColor
            view.backgroundColor = backgroundGeneralColor
            settleSplitTableView.backgroundColor = .clear
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            settleSplitTableView.backgroundColor = .clear
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSettleSplitTVC", for: indexPath) as! cellSettleSplitTVC
        
        let amoutString = (numberFormatter.string(from: NSNumber(value: abs(rowData[indexPath.row]?[0] as? Double ?? 0.00))) ?? "0.00")
        var subTitle:String?
        
        var firstName:String?
        var secondName:String?
        var firstUser:Bool = false
        
        if (rowData[indexPath.row]?[0] as? Double ?? 0.00) >= 0 {
            
            if (rowData[indexPath.row]?[1] as? String ?? "").count > 1 {
                cell.rightCircleLabel.text = (rowData[indexPath.row]?[1] as? String ?? "").prefix(2).uppercased()
            } else if (rowData[indexPath.row]?[1] as? String ?? "").count == 1 {
                cell.rightCircleLabel.text = (rowData[indexPath.row]?[1] as? String ?? "").prefix(1).uppercased()
            } else {
                cell.rightCircleLabel.text = ""
            }
            
            cell.rightCircleView.backgroundColor = UIColor.randomColor(color: Int(rowData[indexPath.row]?[2] as? Int16 ?? 0))
            cell.rightCircleLabel.textColor = UIColor.randomColor(color: Int(rowData[indexPath.row]?[2] as? Int16 ?? 0))
            cell.rightCircleView.layer.borderColor = cell.rightCircleView.backgroundColor?.cgColor
            
            if (rowData[indexPath.row]?[4] as? String ?? "").count > 1 {
                cell.leftCircleLabel.text = (rowData[indexPath.row]?[4] as? String ?? "").prefix(2).uppercased()
            } else if (rowData[indexPath.row]?[4] as? String ?? "").count == 1 {
                cell.leftCircleLabel.text = (rowData[indexPath.row]?[4] as? String ?? "").prefix(1).uppercased()
            } else {
                cell.leftCircleLabel.text = ""
            }
            
            cell.leftCircleView.backgroundColor = UIColor.randomColor(color: Int(rowData[indexPath.row]?[5] as? Int16 ?? 0))
            cell.leftCircleLabel.textColor = UIColor.randomColor(color: Int(rowData[indexPath.row]?[5] as? Int16 ?? 0))
            cell.leftCircleView.layer.borderColor = cell.leftCircleView.backgroundColor?.cgColor
            
            if isUser(createDate: (rowData[indexPath.row]?[6] as? Date ?? Date()), namePerson: (rowData[indexPath.row]?[4] as? String ?? "")) {
                firstName = NSLocalizedString("youTheUser", comment: "You")
                firstUser = true
            } else {
                firstName = (rowData[indexPath.row]?[4] as? String ?? "")
            }
            
            if isUser(createDate: (rowData[indexPath.row]?[3] as? Date ?? Date()), namePerson: (rowData[indexPath.row]?[1] as? String ?? "")) {
                let langStr = Locale.current.languageCode
                if langStr == "DE" || langStr == "de" {
                    secondName = NSLocalizedString("youTheUserDir", comment: "Dir")
                } else {
                    secondName = NSLocalizedString("youTheUser", comment: "You")
                }
            } else {
                secondName = (rowData[indexPath.row]?[1] as? String ?? "")
            }
        } else {
            if (rowData[indexPath.row]?[4] as? String ?? "").count > 1 {
                cell.rightCircleLabel.text = (rowData[indexPath.row]?[4] as? String ?? "").prefix(2).uppercased()
            } else if (rowData[indexPath.row]?[4] as? String ?? "").count == 1 {
                cell.rightCircleLabel.text = (rowData[indexPath.row]?[4] as? String ?? "").prefix(1).uppercased()
            } else {
                cell.rightCircleLabel.text = ""
            }
            
            cell.rightCircleView.backgroundColor = UIColor.randomColor(color: Int(rowData[indexPath.row]?[5] as? Int16 ?? 0))
            cell.rightCircleLabel.textColor = UIColor.randomColor(color: Int(rowData[indexPath.row]?[5] as? Int16 ?? 0))
            cell.rightCircleView.layer.borderColor = cell.rightCircleView.backgroundColor?.cgColor
            
            if (rowData[indexPath.row]?[4] as? String ?? "").count > 1 {
                cell.leftCircleLabel.text = (rowData[indexPath.row]?[1] as? String ?? "").prefix(2).uppercased()
            } else if (rowData[indexPath.row]?[1] as? String ?? "").count == 1 {
                cell.leftCircleLabel.text = (rowData[indexPath.row]?[1] as? String ?? "").prefix(1).uppercased()
            } else {
                cell.leftCircleLabel.text = ""
            }
            
            cell.leftCircleView.backgroundColor = UIColor.randomColor(color: Int(rowData[indexPath.row]?[2] as? Int16 ?? 0))
            cell.leftCircleLabel.textColor = UIColor.randomColor(color: Int(rowData[indexPath.row]?[2] as? Int16 ?? 0))
            cell.leftCircleView.layer.borderColor = cell.leftCircleView.backgroundColor?.cgColor
            
            if isUser(createDate: (rowData[indexPath.row]?[3] as? Date ?? Date()), namePerson: (rowData[indexPath.row]?[1] as? String ?? "")) {
                firstName = NSLocalizedString("youTheUser", comment: "You")
                firstUser = true
            } else {
                firstName = (rowData[indexPath.row]?[1] as? String ?? "")
            }
            
            if isUser(createDate: (rowData[indexPath.row]?[6] as? Date ?? Date()), namePerson: (rowData[indexPath.row]?[4] as? String ?? "")) {
                let langStr = Locale.current.languageCode
                if langStr == "DE" || langStr == "de" {
                    secondName = NSLocalizedString("youTheUserDir", comment: "Dir")
                } else {
                    secondName = NSLocalizedString("youTheUser", comment: "You")
                }
            } else {
                secondName = (rowData[indexPath.row]?[4] as? String ?? "")
            }
        }
        
        rowData[indexPath.row]?[9] = subTitle ?? ""
        
        if (rowData[indexPath.row]?[0] as? Double ?? 0.00) >= 0.00 && (rowData[indexPath.row]?[0] as? Double ?? 0.00) < 0.009 {
            cell.settleAmount.isHidden = true
            cell.currencyButton.isHidden = true
            cell.subTitle.isHidden = true
            cell.settleButton.isHidden = true
            cell.stackView.isHidden = true
            
            cell.centerImageView.image = UIImage(systemName: "person.fill.checkmark")?.withRenderingMode(.alwaysTemplate)
        } else {
            cell.settleAmount.isHidden = false
            cell.currencyButton.isHidden = false
            cell.subTitle.isHidden = false
            cell.settleButton.isHidden = false
            cell.stackView.isHidden = false
            
            cell.centerImageView.image = UIImage(systemName: "arrow.right")?.withRenderingMode(.alwaysTemplate)
            
            let langStr = Locale.current.languageCode
            if (langStr == "DE" || langStr == "de") && firstUser {
                subTitle = (firstName ?? "") + NSLocalizedString("personPaidFirstUser", comment: "paid") + (secondName ?? "")
            } else {
                subTitle = (firstName ?? "") + NSLocalizedString("personPaid", comment: "paid") + (secondName ?? "")
            }
            
            cell.settleAmount.text = amoutString
            cell.currencyButton.setTitle((getSymbol(forCurrencyCode: (rowData[indexPath.row]?[7] as? String ?? "EUR")) ?? "€"), for: .normal)
            
            cell.subTitle.text = subTitle ?? ""
        }
        cell.settleAmount.tag = indexPath.row
        cell.settleButton.tag = indexPath.row
        
        cell.delegate = self
        return cell
    }

    // MARK: Init View
    func initView() {
        initTableAndHeaderView()
    }
    
    func initTableAndHeaderView() {
        settleSplitTableView.sectionHeaderHeight = UITableView.automaticDimension
     
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            settleSplitTableView.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
        } else {
            settleSplitTableView.backgroundColor = .secondarySystemBackground
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
        headerView.scrollView = settleSplitTableView
        
        settleSplitTableView.backgroundView = UIView()
        settleSplitTableView.backgroundView?.addSubview(headerView)
        settleSplitTableView.contentInset = UIEdgeInsets(
            top: 85,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 40,
            right: 0
        )
    }
    
    // MARK: -FUNCTIONS
    func createRowData() {
        rowData.removeAll()

        if (transactionCreateDate == nil) && (createDateGroup != nil) && (groupName != nil) && (createDatePerson == nil) && (personName == nil) { // Settle Group
            // Get Persons of Group
            // Get Sum Owed to each Person
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("settleNavitem", comment: "Segment Group Text"), style: .done, target: self, action: #selector(settleAll))
            
            let createDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateGroup ?? Date())!
            let createDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateGroup ?? Date())!
            
            let query = NSPredicate(format: "nameGroup == %@ AND createDate > %@ AND createDate < %@", (groupName ?? ""), (createDateMinus as NSDate), (createDatePlus as NSDate))

            let personsLoad = (loadQueriedAttribute(entitie: "SplitGroups", attibute: "persons", query: query) as? String ?? "")
            let persons = personsLoad.components(separatedBy: "*;*")
            
            var i = 0
            if personsLoad.count > 0 {
                for j in 0...(persons.count-1) {

                    let personArray = persons[j].components(separatedBy: "*&*")
                    
                    let personNameFUNC = personArray[0]
                    let personCreateDateFUNC = dateFormatter.date(from: personArray[1]) ?? Date()
                    
                    for p in j...(persons.count-1) {
                        let currentPersonArray = persons[p].components(separatedBy: "*&*")
                        
                        let currentPersonName = currentPersonArray[0]
                        let currentPersonCreateDate = dateFormatter.date(from: currentPersonArray[1]) ?? Date()
                        
                        let currentCreateDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: currentPersonCreateDate)!
                        let currentCreateDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: currentPersonCreateDate)!
                        
                        let up = personCreateDateFUNC.compare(currentCreateDatePlus) == .orderedAscending
                        let down = personCreateDateFUNC.compare(currentCreateDateMinus) == .orderedDescending
                        
                        if currentPersonName.count <= 0 || (up && down && currentPersonName == personNameFUNC) { // Person same as outer-Person
                            continue
                        } else {
                            rowData[i] = getRowGroup(personName: currentPersonName, personCreateDate: currentPersonCreateDate, groupName: groupName ?? "", groupCreateDate: createDateGroup ?? Date(), outerPersonName: personNameFUNC, outerPersonCreateDate: personCreateDateFUNC)
                            i = i + 1
                        }
                    }
                }
            }

            navTitle = (groupName ?? "")
            headerView.headerLabel.text = navTitle
        } else if (transactionCreateDate == nil) && (createDateGroup != nil) && (groupName != nil) && (createDatePerson != nil) && (personName != nil) { // Settle Group+Person
            // Get Sum Owed to Person within Group
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("settleNavitem", comment: "Segment Group Text"), style: .done, target: self, action: #selector(settleAll))
            
            let createDateGroupPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateGroup ?? Date())!
            let createDateGroupMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateGroup ?? Date())!
            
            let query = NSPredicate(format: "nameGroup == %@ AND createDate > %@ AND createDate < %@", (groupName ?? ""), (createDateGroupMinus as NSDate), (createDateGroupPlus as NSDate))

            let personsLoad = (loadQueriedAttribute(entitie: "SplitGroups", attibute: "persons", query: query) as? String ?? "")
            let persons = personsLoad.components(separatedBy: "*;*")
            
            var i = 0
            if personsLoad.count > 0 {
                for j in 0...(persons.count-1) {
                    let currentPersonArray = persons[j].components(separatedBy: "*&*")
                    
                    let currentPersonName = currentPersonArray[0]
                    let currentPersonCreateDate = dateFormatter.date(from: currentPersonArray[1]) ?? Date()
                        
                    let currentCreateDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: currentPersonCreateDate)!
                    let currentCreateDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: currentPersonCreateDate)!
                        
                    let up = (createDatePerson ?? Date()).compare(currentCreateDatePlus) == .orderedAscending
                    let down = (createDatePerson ?? Date()).compare(currentCreateDateMinus) == .orderedDescending
                    
                    if currentPersonName.count <= 0 || (up && down && currentPersonName == personName) {
                        continue
                    } else {
                        rowData[i] = getRowGroup(personName: currentPersonName, personCreateDate: currentPersonCreateDate, groupName: groupName ?? "", groupCreateDate: createDateGroup ?? Date(), outerPersonName: personName ?? "", outerPersonCreateDate: createDatePerson ?? Date())
                        i = i + 1
                    }
                }
            }
            
            navTitle = (personName ?? "") + "@" + (groupName ?? "")
            headerView.headerLabel.text = navTitle
        } else if (transactionCreateDate == nil) && (createDateGroup == nil) && (groupName == nil) && (createDatePerson != nil) && (personName != nil) { // Settle Person
            // Get Sum Owed to Person
            navigationItem.rightBarButtonItem = nil

            rowData[0] = getRowPerson(personName: personName ?? "", personCreateDate: createDatePerson ?? Date())
            navTitle = personName ?? ""
            
            headerView.headerLabel.text = navTitle
        } else if transactionCreateDate != nil { // Settle Transaction
            // Get Persons who are part of Split
            // Get Sum Owed to each Person
//            navigationItem.rightBarButtonItem = nil
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("settleNavitem", comment: "Segment Group Text"), style: .done, target: self, action: #selector(settleAll))
            
            let createDateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: transactionCreateDate ?? Date())!
            let createDateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: transactionCreateDate ?? Date())!
            
            let querySplits = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
            var i = 0
            for split in loadBulkQueriedSorted(entitie: "Splits", query: querySplits, sort: [NSSortDescriptor(key: "ratio", ascending: false)]) {
                let plusCreateDatePersonWhoPaid = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()))!
                let minusCreateDatePersonWhoPaid = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()))!
                
                let up = (split.value(forKey: "createDatePerson") as? Date ?? Date()).compare(plusCreateDatePersonWhoPaid) == .orderedAscending
                let down = (split.value(forKey: "createDatePerson") as? Date ?? Date()).compare(minusCreateDatePersonWhoPaid) == .orderedDescending
                
                let isPersonWhoPaid = ((split.value(forKey: "namePerson") as? String ?? "") == (split.value(forKey: "namePersonWhoPaid") as? String ?? "")) && up && down

                if isPersonWhoPaid {
                    continue
                } else {
                    rowData[i] = getRowSettleTransaction(transactionDateTime: (transactionCreateDate ?? Date()), personName: (split.value(forKey: "namePerson") as? String ?? ""), personCreateDate: (split.value(forKey: "createDatePerson") as? Date ?? Date()))
                    i = i + 1
                }
            }
            
            let queryTransactionDescription = NSPredicate(format: "dateTime < %@ AND dateTime > %@", (createDateTransactionPlus as NSDate), (createDateTransactionMinus as NSDate))
            
            navTitle = loadQueriedAttribute(entitie: "Transactions", attibute: "descriptionNote", query: queryTransactionDescription) as? String ?? NSLocalizedString("transactionDefaultTitle", comment: "Transaction")
            headerView.headerLabel.text = navTitle
        } else {
            navigationItem.rightBarButtonItem = nil
            navTitle = NSLocalizedString("nothingSelected", comment: "Nothing Selected")
            headerView.headerLabel.text = navTitle
        }
    }
    
    // MARK: -GET AMOUNTS FUNCTIONS
    func getRowPerson(personName: String, personCreateDate: Date) -> [Int:Any] {
        let currencyCode = Locale.current.currencyCode ?? "EUR"
        var sumOwed:Double = 0.00
        
        let createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: personCreateDate)!
        let createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: personCreateDate)!
        // Get Person Color
        let queryPerson = NSPredicate(format: "createDate < %@ AND createDate > %@ AND namePerson == %@", createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString)
        let personColor = loadQueriedAttribute(entitie: "SplitPersons", attibute: "color", query: queryPerson) as? Int16 ?? 0
        
        // Get user data
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
        
        var userColor:Int16 = 0
        var userName:String?
        var createDateUser:Date?
        
        for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
            userName = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
            userColor = data.value(forKey: "color") as? Int16 ?? 0
        }
        
        let createDateUserPlus = Calendar.current.date(byAdding: .second, value: 1, to: (createDateUser ?? Date()))!
        let createDateUserMinus = Calendar.current.date(byAdding: .second, value: -1, to: (createDateUser ?? Date()))!
        
        // Get owed Amount:
        // Per Split where Person
        
        let querySplits = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString)
        
        for split in loadBulkQueried(entitie: "Splits", query: querySplits) {
            if !personOrOtherPersonPaid(dateTimeTransaction: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()), namePerson: personName, dateTimePerson: personCreateDate, nameOtherPerson: userName ?? "", dateTimeOtherPerson: createDateUser ?? Date()) {
                continue
            } else {
                // (Amount/ExchangeRate) * Ratio - Settled
                let createDateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                let createDateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                
                let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
                
                let exchangeRate = (loadQueriedAttribute(entitie: "Transactions", attibute: "exchangeRate", query: queryTransaction) as? Double ?? 1.00)
                
                let amountTransaction = ((loadQueriedAttribute(entitie: "Transactions", attibute: "amount", query: queryTransaction) as? Double ?? 0.00) / exchangeRate) // Home Currency
               
                if personPaid(dateTimeTransaction: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()), namePerson: personName, dateTimePerson: personCreateDate) {
                    let querySplitOtherPerson = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@ AND dateTimeTransaction < %@ AND dateTimeTransaction > %@", createDateUserPlus as NSDate, createDateUserMinus as NSDate, (userName ?? ";") as NSString, createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
                    
                    let ratioUser = loadQueriedAttribute(entitie: "Splits", attibute: "ratio", query: querySplitOtherPerson) as? Double ?? 0.00
                    let settledUser = (loadQueriedAttribute(entitie: "Splits", attibute: "settled", query: querySplitOtherPerson) as? Double ?? 0.00)/exchangeRate // Home Currency

                    let amountRAM = (amountTransaction*ratioUser) - settledUser
                    sumOwed = sumOwed - amountRAM
                } else {
                    let amountRAM = (amountTransaction*(split.value(forKey: "ratio") as? Double ?? 0.00))-((split.value(forKey: "settled") as? Double ?? 0.00)/exchangeRate) // Home Currency
                    sumOwed = sumOwed + amountRAM
                }
            }
        }
        
        return [
            0:sumOwed, // Amount Owed as it is now in the DB
            1:userName ?? "",
            2:userColor,
            3:createDateUser ?? Date(),
            4:personName,
            5:personColor,
            6:personCreateDate,
            7:currencyCode,
            8:sumOwed // Amount to-be-settled
        ]
    }
    
    func getRowGroup(personName: String, personCreateDate: Date, groupName: String, groupCreateDate: Date, outerPersonName: String, outerPersonCreateDate: Date) -> [Int:Any] {
        let currencyCode = Locale.current.currencyCode ?? "EUR"
        var sumOwed:Double = 0.00
        
        let createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: personCreateDate)!
        let createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: personCreateDate)!
        // Get Person Color
        let queryPerson = NSPredicate(format: "createDate < %@ AND createDate > %@ AND namePerson == %@", createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString)
        let personColor = loadQueriedAttribute(entitie: "SplitPersons", attibute: "color", query: queryPerson) as? Int16 ?? 0
        
        // Get outerPaid Data
        let createDateOuterPlus = Calendar.current.date(byAdding: .second, value: 1, to: outerPersonCreateDate)!
        let createDateOuterMinus = Calendar.current.date(byAdding: .second, value: -1, to: outerPersonCreateDate)!
        
        let queryPersonWhoPaid = NSPredicate(format: "createDate < %@ AND createDate > %@ AND namePerson == %@", createDateOuterPlus as NSDate, createDateOuterMinus as NSDate, outerPersonName as NSString)
        
        let outerPersonColor = (loadQueriedAttribute(entitie: "SplitPersons", attibute: "color", query: queryPersonWhoPaid) as? Int16 ?? 0)
        
        // Get owed Amount:
        // Per Split where Group, Person
        
        let createDateGroupPlus = Calendar.current.date(byAdding: .second, value: 1, to: groupCreateDate)!
        let createDateGroupMinus = Calendar.current.date(byAdding: .second, value: -1, to: groupCreateDate)!
        
        let querySplits = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND createDateGroup < %@ AND createDateGroup > %@ AND namePerson == %@", createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, createDateGroupPlus as NSDate, createDateGroupMinus as NSDate, personName as NSString)
        
        for split in loadBulkQueried(entitie: "Splits", query: querySplits) {
            if !personOrOtherPersonPaid(dateTimeTransaction: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()), namePerson: personName, dateTimePerson: personCreateDate, nameOtherPerson: outerPersonName, dateTimeOtherPerson: outerPersonCreateDate) {
                continue
            } else {
                // (Amount/ExchangeRate) * Ratio - Settled
                let createDateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                let createDateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                
                let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
                
                let exchangeRate = (loadQueriedAttribute(entitie: "Transactions", attibute: "exchangeRate", query: queryTransaction) as? Double ?? 1.00)
                let amountTransaction = ((loadQueriedAttribute(entitie: "Transactions", attibute: "amount", query: queryTransaction) as? Double ?? 0.00)/exchangeRate) // Home Currency
               
                if personPaid(dateTimeTransaction: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()), namePerson: personName, dateTimePerson: personCreateDate) {
                    let querySplitOtherPerson = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND createDateGroup < %@ AND createDateGroup > %@ AND namePerson == %@ AND dateTimeTransaction < %@ AND dateTimeTransaction > %@", createDateOuterPlus as NSDate, createDateOuterMinus as NSDate, createDateGroupPlus as NSDate, createDateGroupMinus as NSDate, outerPersonName as NSString, createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
                    
                    let ratioOuterPerson = loadQueriedAttribute(entitie: "Splits", attibute: "ratio", query: querySplitOtherPerson) as? Double ?? 0.00
                    let settledOuterPerson = (loadQueriedAttribute(entitie: "Splits", attibute: "settled", query: querySplitOtherPerson) as? Double ?? 0.00)/exchangeRate // Home Currency

                    let amountRAM = (amountTransaction*ratioOuterPerson) - settledOuterPerson
                    sumOwed = sumOwed - amountRAM
                } else {
                    let amountRAM = (amountTransaction*(split.value(forKey: "ratio") as? Double ?? 0.00))-((split.value(forKey: "settled") as? Double ?? 0.00)/exchangeRate) // Home Currency
                    sumOwed = sumOwed + amountRAM
                }
            }
        }
        
        return [
            0:sumOwed, // Amount Owed as it is now in the DB
            1:outerPersonName,
            2:outerPersonColor,
            3:outerPersonCreateDate,
            4:personName,
            5:personColor,
            6:personCreateDate,
            7:currencyCode,
            8:sumOwed // Amount to-be-settled
        ]
    }
    
    func getRowSettleTransaction(transactionDateTime: Date, personName: String, personCreateDate: Date) -> [Int:Any] {
        let currencyCode = Locale.current.currencyCode ?? "EUR"
        var sumOwed:Double = 0.00
        
        let createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: personCreateDate)!
        let createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: personCreateDate)!
        // Get Person Color
        let queryPerson = NSPredicate(format: "createDate < %@ AND createDate > %@ AND namePerson == %@", createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString)
        let personColor = loadQueriedAttribute(entitie: "SplitPersons", attibute: "color", query: queryPerson) as? Int16 ?? 0
        
        // Get open amount
        // for sumOwed: (TransactionAmount/ExchangeRate)*Ratio - Settled
        let createDateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: transactionDateTime)!
        let createDateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: transactionDateTime)!
        
        let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
        
        let exchangeRate = (loadQueriedAttribute(entitie: "Transactions", attibute: "exchangeRate", query: queryTransaction) as? Double ?? 0.00)
        let sumAmount = (loadQueriedAttribute(entitie: "Transactions", attibute: "amount", query: queryTransaction) as? Double ?? 0.00)/exchangeRate
        
        let querySplit = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@ AND createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate, createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString)
        
        sumOwed = (sumAmount*(loadQueriedAttribute(entitie: "Splits", attibute: "ratio", query: querySplit) as? Double ?? 0.00)) - ((loadQueriedAttribute(entitie: "Splits", attibute: "settled", query: querySplit) as? Double ?? 0.00)/exchangeRate)
        
        // Get personWhoPaid Data
        let personWhoPaidCreateDate = (loadQueriedAttribute(entitie: "Splits", attibute: "createDatePersonWhoPaid", query: querySplit) as? Date ?? Date())
        
        let createDatePersonWhoPaidPlus = Calendar.current.date(byAdding: .second, value: 1, to: personWhoPaidCreateDate)!
        let createDatePersonWhoPaidMinus = Calendar.current.date(byAdding: .second, value: -1, to: personWhoPaidCreateDate)!
        
        let personWhoPaidName = (loadQueriedAttribute(entitie: "Splits", attibute: "namePersonWhoPaid", query: querySplit) as? String ?? "")
        
        let queryPersonWhoPaid = NSPredicate(format: "createDate < %@ AND createDate > %@ AND namePerson == %@", createDatePersonWhoPaidPlus as NSDate, createDatePersonWhoPaidMinus as NSDate, personWhoPaidName as NSString)
        
        let personWhoPaidColor = (loadQueriedAttribute(entitie: "SplitPersons", attibute: "color", query: queryPersonWhoPaid) as? Int16 ?? 0)
        
        return [
            0:sumOwed, // Amount Owed as it is now in the DB
            1:personWhoPaidName,
            2:personWhoPaidColor,
            3:personWhoPaidCreateDate,
            4:personName,
            5:personColor,
            6:personCreateDate,
            7:currencyCode,
            8:sumOwed // Amount to-be-settled
        ]
    }
    
    // MARK: -SETTLE SPLITS
    func settleTransaction(row:Int, transactionDateTime: Date) {
        let amountToBeSettled = rowData[row]?[8] as? Double ?? 0.00 // Home Currency
        let personName = rowData[row]?[4] as? String ?? ""
        let personCreateDate = rowData[row]?[6] as? Date ?? Date()
        
        let createDateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: transactionDateTime)!
        let createDateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: transactionDateTime)!
        
        let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
        let exchangeRate = (loadQueriedAttribute(entitie: "Transactions", attibute: "exchangeRate", query: queryTransaction) as? Double ?? 1.00)
        let amountTransaction = (loadQueriedAttribute(entitie: "Transactions", attibute: "amount", query: queryTransaction) as? Double ?? 0.00)
        let sumAmount = amountTransaction / exchangeRate // Home Currency
        
        let createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: personCreateDate)!
        let createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: personCreateDate)!
        
        let querySplitPerson = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@ AND createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate, createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString)
        
        let settled = (loadQueriedAttribute(entitie: "Splits", attibute: "settled", query: querySplitPerson) as? Double ?? 0.00) / exchangeRate // Home Currency
        let sumOwedWithoutSettled = (sumAmount*(loadQueriedAttribute(entitie: "Splits", attibute: "ratio", query: querySplitPerson) as? Double ?? 0.00)) // Home Currency
        
        var amountSettledNew = abs(amountToBeSettled) + abs(settled)
        
        amountSettledNew = min(amountSettledNew,sumOwedWithoutSettled) // Home Currency
        amountSettledNew = amountSettledNew * exchangeRate // Transaction Currency
        
        var amountSettledPlusPersonWhoPaid = min(abs(amountToBeSettled),sumOwedWithoutSettled) // Home Currency
        amountSettledPlusPersonWhoPaid = amountSettledPlusPersonWhoPaid * exchangeRate // Transaction Currency
        
        let personWhoPaid = loadQueriedAttribute(entitie: "Splits", attibute: "namePersonWhoPaid", query: querySplitPerson) as? String ?? ""
        let personWhoPaidCreateDate = loadQueriedAttribute(entitie: "Splits", attibute: "createDatePersonWhoPaid", query: querySplitPerson) as? Date ?? Date()
        
        let createDatePersonWhoPaidPlus = Calendar.current.date(byAdding: .second, value: 1, to: personWhoPaidCreateDate)!
        let createDatePersonWhoPaidMinus = Calendar.current.date(byAdding: .second, value: -1, to: personWhoPaidCreateDate)!
        
        let querySplitPersonWhoPaid = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@ AND createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate, createDatePersonWhoPaidPlus as NSDate, createDatePersonWhoPaidMinus as NSDate, personWhoPaid as NSString)
        
        let personWhoPaidSettled = loadQueriedAttribute(entitie: "Splits", attibute: "settled", query: querySplitPersonWhoPaid) as? Double ?? 0.00 // Transaction Currency
        
        if (saveQueriedAttribute(entity: "Splits", attribute: "settled", query: querySplitPerson, value: amountSettledNew) && saveQueriedAttribute(entity: "Splits", attribute: "settled", query: querySplitPersonWhoPaid, value: (personWhoPaidSettled+amountSettledPlusPersonWhoPaid))) {
            
            if saveRealAmount(dateTime: transactionDateTime) {
                // Delete if open Split
                var openSplit:Bool = false
                
                let querySplitDelete = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
                
                for split in loadBulkQueried(entitie: "Splits", query: querySplitDelete) {
                    if ((amountTransaction*(split.value(forKey: "ratio") as? Double ?? 0.00)) - (split.value(forKey: "settled") as? Double ?? 0.00)) > 0.005 {
                        let personCreateDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "createDatePerson") as? Date ?? Date()))!
                        let personCreateDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "createDatePerson") as? Date ?? Date()))!
                        
                        let up = (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()).compare(personCreateDatePlus) == .orderedAscending
                        let down = (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()).compare(personCreateDateMinus) == .orderedDescending
                        // Person Who paid does not matter
                        if up && down && ((split.value(forKey: "namePerson") as? String ?? "") == (split.value(forKey: "namePersonWhoPaid") as? String ?? "")) {
                            continue
                        } else {
                            openSplit = true
                            break
                        }
                    }
                }
                
                if !openSplit {
                    let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
                    let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
                    
                    var userName:String = ""
                    var createDateUser:Date = Date()
                    
                    for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
                        userName = data.value(forKey: "namePerson") as? String ?? ""
                        createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
                    }
                    
                    let createDateUserPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser)!
                    let createDateUserMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser)!
                    
                    let querySplitUser = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@ AND createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate, createDateUserPlus as NSDate, createDateUserMinus as NSDate, userName as NSString)
                    
                    let ratioUser = loadQueriedAttribute(entitie: "Splits", attibute: "ratio", query: querySplitUser) as? Double ?? 0.00
                    
                    if saveQueriedAttribute(entity: "Transactions", attribute: "isSplit", query: queryTransaction, value: Int16(0)) && saveQueriedAttribute(entity: "Transactions", attribute: "amount", query: queryTransaction, value: (amountTransaction*ratioUser)) {
                        if deleteDataReturn(entity: "Splits", query: querySplitDelete) {
                            _ = saveRealAmount(dateTime: transactionDateTime)
                        }
                    }
                }
                
                let amountToBeSettled = abs(rowData[row]?[0] as? Double ?? 0.00) - abs(rowData[row]?[8] as? Double ?? 0.00)
                
                if rowData[row]?[0] as? Double ?? 0.00 < 0 {
                    rowData[row]?[0] = (-1)*amountToBeSettled
                    rowData[row]?[8] = (-1)*amountToBeSettled
                } else {
                    rowData[row]?[0] = amountToBeSettled
                    rowData[row]?[8] = amountToBeSettled
                }
                
                if abs(rowData[row]?[8] as? Double ?? 0.00) > 0.0001 {
                    if let cell = settleSplitTableView.cellForRow(at: IndexPath(row: row, section: 0)) as? cellSettleSplitTVC {
                        cell.settleAmount.text = (numberFormatter.string(from: NSNumber(value: abs(rowData[row]?[0] as? Double ?? 0.00))) ?? "0.00")
                    }
                } else {
                    settleSplitTableView.beginUpdates()
                    settleSplitTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
                    settleSplitTableView.endUpdates()
                }
                
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name("splitSettled"), object: nil)
                nc.post(name: Notification.Name("transactionUpdated"), object: nil, userInfo: ["transactionCreateDate": (transactionDateTime), "oldCreateDate":(transactionDateTime)])
                nc.post(name: Notification.Name("groupPersonAdded"), object: nil)
            }
        }
    }
    
    func settleGroup(row: Int, groupCreateDate: Date, settleAll:Bool = false) {
        var amountToBeSettled = rowData[row]?[8] as? Double ?? 0.00 // Home Currency
        
        // if zero, return and reset amount
        if (abs(amountToBeSettled) <= 0.005) && !settleAll {
            let amountOwed = (rowData[row]?[0] as? Double ?? 0.00)
            if amountOwed < 0 {
                rowData[row]?[8] = amountOwed
            } else {
                rowData[row]?[8] = amountOwed
            }
            
            if abs(rowData[row]?[8] as? Double ?? 0.00) > 0.0001 {
                if let cell = settleSplitTableView.cellForRow(at: IndexPath(row: row, section: 0)) as? cellSettleSplitTVC {
                    cell.settleAmount.text = (numberFormatter.string(from: NSNumber(value: abs(rowData[row]?[0] as? Double ?? 0.00))) ?? "0.00")
                }
            } else {
                settleSplitTableView.beginUpdates()
                settleSplitTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
                settleSplitTableView.endUpdates()
            }
            return
        }
        
        var positionPersonName = 4
        var positionPeronCreateDate = 6
        var positionOtherPersonName = 1
        var positionOtherPersonCreateDate = 3
        if (rowData[row]?[0] as? Double ?? 0.00) < 0 {
            positionPersonName = 1
            positionPeronCreateDate = 3
            positionOtherPersonName = 4
            positionOtherPersonCreateDate = 6
        }
        amountToBeSettled = abs(amountToBeSettled)
        
        let otherPersonName = rowData[row]?[positionOtherPersonName] as? String ?? ""
        let otherPersonCreateDate = rowData[row]?[positionOtherPersonCreateDate] as? Date ?? Date()
        
        let createDateOtherPersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: otherPersonCreateDate)!
        let createDateOtherPersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: otherPersonCreateDate)!
        
        let personName = rowData[row]?[positionPersonName] as? String ?? ""
        let personCreateDate = rowData[row]?[positionPeronCreateDate] as? Date ?? Date()
        
        let createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: personCreateDate)!
        let createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: personCreateDate)!
        
        let createDateGroupPlus = Calendar.current.date(byAdding: .second, value: 1, to: groupCreateDate)!
        let createDateGroupMinus = Calendar.current.date(byAdding: .second, value: -1, to: groupCreateDate)!
        
        // If sumOwed is positive, outerPerson paid
        // Get every Split which concerns this Person & Group, one for-loop for transactions, where that person has paid (adds to amountToBeSettled), a second for loop for where the person has not paid
        // Order by oldest first
        // Settle each entry until amountToBeSettled = 0 (dont forget already settled amount)
        // go through each split, if there are still open splits. If not, delete
        let querySplitPaid = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@ AND createDatePersonWhoPaid < %@ AND createDatePersonWhoPaid > %@ AND namePersonWhoPaid == %@ AND createDateGroup < %@ AND createDateGroup > %@", createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString, createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString, createDateGroupPlus as NSDate, createDateGroupMinus as NSDate)
        for split in loadBulkQueriedSorted(entitie: "Splits", query: querySplitPaid, sort: [NSSortDescriptor(key: "dateTimeTransaction", ascending: true)]) {
            let createDateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
            let createDateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
            
            let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
            
            let exchangeRate = loadQueriedAttribute(entitie: "Transactions", attibute: "exchangeRate", query: queryTransaction) as? Double ?? 1.00
            let amount = loadQueriedAttribute(entitie: "Transactions", attibute: "amount", query: queryTransaction) as? Double ?? 0.00 // Transaction Currency
            
            let amountTransaction = amount / exchangeRate // Home Currency
            // ratio other person
            let queryRatioOther = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@ AND createDateGroup < %@ AND createDateGroup > %@ AND dateTimeTransaction < %@ AND dateTimeTransaction > %@", createDateOtherPersonPlus as NSDate, createDateOtherPersonMinus as NSDate, otherPersonName as NSString, createDateGroupPlus as NSDate, createDateGroupMinus as NSDate, createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
            
            let settledOtherPerson = (loadQueriedAttribute(entitie: "Splits", attibute: "settled", query: queryRatioOther) as? Double ?? 0.00) / exchangeRate // Home Currency
            let amountTransactionOtherPerson = amountTransaction * (loadQueriedAttribute(entitie: "Splits", attibute: "ratio", query: queryRatioOther) as? Double ?? 0.00)
            
            let amountLeft = amountTransactionOtherPerson - settledOtherPerson
//            let amountSettledTransaction = min(amountLeft,amountTransactionOtherPerson)
            amountToBeSettled = amountToBeSettled + amountLeft
            
            let settledNew = amountLeft*exchangeRate // Transaction Currency
            
            // settle split
            let settledPerson = split.value(forKey: "settled") as? Double ?? 0.00
            let settlePersonNew = settledPerson + settledNew // Transaction Currency
            let settledOtherPersonNew = settledOtherPerson+settledNew // Transaction Currency
            
            let queryPerson = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@ AND createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate, createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString)
            
            if (saveQueriedAttribute(entity: "Splits", attribute: "settled", query: queryPerson, value: settlePersonNew) && saveQueriedAttribute(entity: "Splits", attribute: "settled", query: queryRatioOther, value: settledOtherPersonNew)) {
                _ = saveRealAmount(dateTime: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))
            }
        }
        let querySplitsNotPaid = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND createDateGroup < %@ AND createDateGroup > %@ AND namePerson == %@ AND createDatePersonWhoPaid < %@ AND createDatePersonWhoPaid > %@ AND namePersonWhoPaid == %@", createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, createDateGroupPlus as NSDate, createDateGroupMinus as NSDate, personName as NSString, createDateOtherPersonPlus as NSDate, createDateOtherPersonMinus as NSDate, otherPersonName as NSString)
        for split in loadBulkQueriedSorted(entitie: "Splits", query: querySplitsNotPaid, sort: [NSSortDescriptor(key: "dateTimeTransaction", ascending: true)]) {
            if abs(amountToBeSettled) <= 0.005 {
                break
            }
            // Get how much is left to be settled
            let createDateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
            let createDateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
            
            let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
            
            let exchangeRate = loadQueriedAttribute(entitie: "Transactions", attibute: "exchangeRate", query: queryTransaction) as? Double ?? 1.00
            let amount = loadQueriedAttribute(entitie: "Transactions", attibute: "amount", query: queryTransaction) as? Double ?? 0.00 // Transaction Currency
            
            let amountTransaction = amount / exchangeRate // Home Currency
            let settled = (split.value(forKey: "settled") as? Double ?? 0.00)/exchangeRate // Home Currency
            
            let amountTransactionPerson = amountTransaction * (split.value(forKey: "ratio") as? Double ?? 0.00)
            
            let amountLeft = min(abs(amountTransactionPerson - settled),amountTransactionPerson)
            
            let plusCreateDatePersonWhoPaid = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()))!
            let minusCreateDatePersonWhoPaid = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()))!
            
            let up = (split.value(forKey: "createDatePerson") as? Date ?? Date()).compare(plusCreateDatePersonWhoPaid) == .orderedAscending
            let down = (split.value(forKey: "createDatePerson") as? Date ?? Date()).compare(minusCreateDatePersonWhoPaid) == .orderedDescending
            
            var amountToSettle = 0.00
            if up && down && (split.value(forKey: "namePerson") as? String ?? ".") == (split.value(forKey: "namePersonWhoPaid") as? String ?? "") {
                continue
            } else {
                if abs(amountToBeSettled) < abs(amountLeft) {
                    amountToSettle = min(abs(amountToBeSettled),amountTransactionPerson)
                    amountToBeSettled = 0.00
                } else {
                    amountToBeSettled = amountToBeSettled - amountLeft
                    amountToSettle = amountLeft
                }
            }

            let settledNew = amountToSettle*exchangeRate // Transaction Currency
                        
            // settle splits
            let settledPerson = split.value(forKey: "settled") as? Double ?? 0.00
            let settlePersonNew = settledPerson + settledNew // Transaction Currency
            
            let queryPerson = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@ AND createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate, createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString)
            
            let queryPersonWhoPaid = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@ AND createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate, plusCreateDatePersonWhoPaid as NSDate, minusCreateDatePersonWhoPaid as NSDate, (split.value(forKey: "namePersonWhoPaid") as? String ?? "") as NSString)
            
            let settledPersonWhoPaid = loadQueriedAttribute(entitie: "Splits", attibute: "settled", query: queryPersonWhoPaid) as? Double ?? 0.00
            let settledPersonWhoPaidNew = settledPersonWhoPaid+settledNew // Transaction Currency

            if (saveQueriedAttribute(entity: "Splits", attribute: "settled", query: queryPerson, value: settlePersonNew) && saveQueriedAttribute(entity: "Splits", attribute: "settled", query: queryPersonWhoPaid, value: settledPersonWhoPaidNew)) {
                _ = saveRealAmount(dateTime: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))
            }
        }
        
        let dateSort = NSSortDescriptor(key: "dateTimeTransaction", ascending: true)
        
        let querySplits = NSPredicate(format: "createDateGroup < %@ AND createDateGroup > %@", createDateGroupPlus as NSDate, createDateGroupMinus as NSDate)
        
        let datesSplitsArray = loadDataGroupedQueriedSorted(entitie: "Splits", groupByColumn: "dateTimeTransaction", query: querySplits, sort: [dateSort]) as? [[String:Any]]
        if (datesSplitsArray?.count ?? 0) > 0 {
            for i in 0...((datesSplitsArray?.count ?? 1)-1) {
                if let createDateTransaction = datesSplitsArray?[i]["dateTimeTransaction"] as? Date {
                    let createDateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateTransaction)!
                    let createDateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateTransaction)!
                    
                    let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
                    
                    // Delete if open Split
                    var openSplit:Bool = false
                    
                    let querySplitDelete = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
                    
                    let amountTransaction = loadQueriedAttribute(entitie: "Transactions", attibute: "amount", query: queryTransaction) as? Double ?? 0.00
                    
                    for split in loadBulkQueried(entitie: "Splits", query: querySplitDelete) {
                        if abs(((amountTransaction*(split.value(forKey: "ratio") as? Double ?? 0.00)) - (split.value(forKey: "settled") as? Double ?? 0.00))) > 0.005 {
                            
                            let personCreateDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "createDatePerson") as? Date ?? Date()))!
                            let personCreateDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "createDatePerson") as? Date ?? Date()))!
                            
                            let up = (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()).compare(personCreateDatePlus) == .orderedAscending
                            let down = (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()).compare(personCreateDateMinus) == .orderedDescending
                            // Person Who paid does not matter
                            if up && down && ((split.value(forKey: "namePerson") as? String ?? "") == (split.value(forKey: "namePersonWhoPaid") as? String ?? "")) {
                                continue
                            } else {
                                openSplit = true
                                break
                            }
                        }
                    }
                    
                    if !openSplit {
                        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
                        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
            
                        var userName:String = ""
                        var createDateUser:Date = Date()
                    
                        for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
                            userName = data.value(forKey: "namePerson") as? String ?? ""
                            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
                        }
                    
                        let createDateUserPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser)!
                        let createDateUserMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser)!
                    
                        let querySplitUser = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@ AND createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate, createDateUserPlus as NSDate, createDateUserMinus as NSDate, userName as NSString)
                    
                        let ratioUser = loadQueriedAttribute(entitie: "Splits", attibute: "ratio", query: querySplitUser) as? Double ?? 0.00
                    
                        if saveQueriedAttribute(entity: "Transactions", attribute: "isSplit", query: queryTransaction, value: Int16(0)) && saveQueriedAttribute(entity: "Transactions", attribute: "amount", query: queryTransaction, value: (amountTransaction*ratioUser)) {
                            if deleteDataReturn(entity: "Splits", query: querySplitDelete) {
                                _ = saveRealAmount(dateTime: createDateTransaction)
                            }
                        }
                    }
                }
            }
        }
        
        let amountToSettled = abs(rowData[row]?[0] as? Double ?? 0.00) - abs(rowData[row]?[8] as? Double ?? 0.00)
        
        if rowData[row]?[0] as? Double ?? 0.00 < 0 {
            rowData[row]?[0] = (-1)*amountToSettled
            rowData[row]?[8] = (-1)*amountToSettled
        } else {
            rowData[row]?[0] = amountToSettled
            rowData[row]?[8] = amountToSettled
        }
        
        if abs(rowData[row]?[8] as? Double ?? 0.00) > 0.0001 {
            if let cell = settleSplitTableView.cellForRow(at: IndexPath(row: row, section: 0)) as? cellSettleSplitTVC {
                cell.settleAmount.text = (numberFormatter.string(from: NSNumber(value: abs(rowData[row]?[0] as? Double ?? 0.00))) ?? "0.00")
            }
        } else {
            settleSplitTableView.beginUpdates()
            settleSplitTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
            settleSplitTableView.endUpdates()
        }
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("splitSettled"), object: nil)
//        nc.post(name: Notification.Name("transactionUpdated"), object: nil, userInfo: ["transactionCreateDate": (transactionDateTime), "oldCreateDate":(transactionDateTime)])
        nc.post(name: Notification.Name("groupPersonAdded"), object: nil)
        
//        return [
//            0:sumOwed, // Amount Owed as it is now in the DB
//            1:outerPersonName,
//            2:outerPersonColor,
//            3:outerPersonCreateDate,
//            4:personName,
//            5:personColor,
//            6:personCreateDate,
//            7:currencyCode,
//            8:sumOwed // Amount to-be-settled
//        ]
    }
    
    func settlePerson(row:Int, settleAll:Bool = false) {
        var amountToBeSettled = rowData[row]?[8] as? Double ?? 0.00 // Home Currency
        
        // if zero, return and reset amount
        if (abs(amountToBeSettled) <= 0.005) && !settleAll {
            let amountOwed = (rowData[row]?[0] as? Double ?? 0.00)
            if amountOwed < 0 {
                rowData[row]?[8] = amountOwed
            } else {
                rowData[row]?[8] = amountOwed
            }
            
            if abs(rowData[row]?[8] as? Double ?? 0.00) > 0.0001 {
                if let cell = settleSplitTableView.cellForRow(at: IndexPath(row: row, section: 0)) as? cellSettleSplitTVC {
                    cell.settleAmount.text = (numberFormatter.string(from: NSNumber(value: abs(rowData[row]?[0] as? Double ?? 0.00))) ?? "0.00")
                }
            } else {
                settleSplitTableView.beginUpdates()
                settleSplitTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
                settleSplitTableView.endUpdates()
            }
            return
        }
        
        var positionPersonName = 4
        var positionPeronCreateDate = 6
        var positionOtherPersonName = 1
        var positionOtherPersonCreateDate = 3
        if (rowData[row]?[0] as? Double ?? 0.00) < 0 {
            positionPersonName = 1
            positionPeronCreateDate = 3
            positionOtherPersonName = 4
            positionOtherPersonCreateDate = 6
        }
        amountToBeSettled = abs(amountToBeSettled) // Home Currency
        
        let otherPersonName = rowData[row]?[positionOtherPersonName] as? String ?? ""
        let otherPersonCreateDate = rowData[row]?[positionOtherPersonCreateDate] as? Date ?? Date()
        
        let createDateOtherPersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: otherPersonCreateDate)!
        let createDateOtherPersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: otherPersonCreateDate)!
        
        let personName = rowData[row]?[positionPersonName] as? String ?? ""
        let personCreateDate = rowData[row]?[positionPeronCreateDate] as? Date ?? Date()
        
        let createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: personCreateDate)!
        let createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: personCreateDate)!
        
        // If sumOwed is positive, outerPerson paid
        // Get every Split which concerns this Person, one for-loop for transactions, where that person has paid (adds to amountToBeSettled), a second for loop for where the person has not paid
        // Order by oldest first
        // Settle each entry until amountToBeSettled = 0 (dont forget already settled amount)
        // go through each split, if there are still open splits. If not, delete
        let querySplitPaid = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@ AND createDatePersonWhoPaid < %@ AND createDatePersonWhoPaid > %@ AND namePersonWhoPaid == %@", createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString, createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString)
        for split in loadBulkQueriedSorted(entitie: "Splits", query: querySplitPaid, sort: [NSSortDescriptor(key: "dateTimeTransaction", ascending: true)]) {
            let createDateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
            let createDateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
            
            let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
            
            let exchangeRate = loadQueriedAttribute(entitie: "Transactions", attibute: "exchangeRate", query: queryTransaction) as? Double ?? 1.00
            let amount = loadQueriedAttribute(entitie: "Transactions", attibute: "amount", query: queryTransaction) as? Double ?? 0.00 // Transaction Currency
            
            let amountTransaction = amount / exchangeRate // Home Currency
            // ratio other person
            let queryRatioOther = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@ AND createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate, createDateOtherPersonPlus as NSDate, createDateOtherPersonMinus as NSDate, otherPersonName as NSString)
            let settledOtherPerson = (loadQueriedAttribute(entitie: "Splits", attibute: "settled", query: queryRatioOther) as? Double ?? 0.00) / exchangeRate // Home Currency
            let ratioOtherPerson = (loadQueriedAttribute(entitie: "Splits", attibute: "ratio", query: queryRatioOther) as? Double ?? 0.00)

            if ratioOtherPerson == 0.00 {
                continue
            }
            let amountTransactionOtherPerson = amountTransaction * ratioOtherPerson
            
            let amountLeft = amountTransactionOtherPerson - settledOtherPerson // Home Currency
            
//            let amountSettledTransaction = min((amountToBeSettled + amountLeft),amountTransactionOtherPerson)
            amountToBeSettled = amountToBeSettled + amountLeft
            let settledNew = amountLeft*exchangeRate // Transaction Currency
            
            // settle split
            let settledPerson = split.value(forKey: "settled") as? Double ?? 0.00
            let settlePersonNew = settledPerson + settledNew // Transaction Currency
            let settledOtherPersonNew = min((settledOtherPerson+settledNew),amountTransactionOtherPerson) // Transaction Currency
            
//            let queryPerson = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@ AND createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate, createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString)
            let queryPerson = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@ AND dateTimeTransaction < %@ AND dateTimeTransaction > %@", createDateOtherPersonPlus as NSDate, createDateOtherPersonMinus as NSDate, otherPersonName as NSString, createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
            
            if (saveQueriedAttribute(entity: "Splits", attribute: "settled", query: queryPerson, value: settlePersonNew) && saveQueriedAttribute(entity: "Splits", attribute: "settled", query: queryRatioOther, value: settledOtherPersonNew)) {
                _ = saveRealAmount(dateTime: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))
            }
            
        }
        let querySplitsNotPaid = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@ AND createDatePersonWhoPaid < %@ AND createDatePersonWhoPaid > %@ AND namePersonWhoPaid == %@", createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString, createDateOtherPersonPlus as NSDate, createDateOtherPersonMinus as NSDate, otherPersonName as NSString)
        for split in loadBulkQueriedSorted(entitie: "Splits", query: querySplitsNotPaid, sort: [NSSortDescriptor(key: "dateTimeTransaction", ascending: true)]) {
            if abs(amountToBeSettled) <= 0.005 {
                break
            }
            // Get how much is left to be settled
            let createDateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
            let createDateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
            
            let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
            
            let exchangeRate = loadQueriedAttribute(entitie: "Transactions", attibute: "exchangeRate", query: queryTransaction) as? Double ?? 1.00
            let amount = loadQueriedAttribute(entitie: "Transactions", attibute: "amount", query: queryTransaction) as? Double ?? 0.00 // Transaction Currency
            
            let amountTransaction = amount / exchangeRate // Home Currency
            let settled = (split.value(forKey: "settled") as? Double ?? 0.00) / exchangeRate // Home Currency
            
            let amountTransactionPerson = amountTransaction * (split.value(forKey: "ratio") as? Double ?? 0.00)
            
            let amountLeft = amountTransactionPerson - settled
            
            let plusCreateDatePersonWhoPaid = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()))!
            let minusCreateDatePersonWhoPaid = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()))!
            
            let up = (split.value(forKey: "createDatePerson") as? Date ?? Date()).compare(plusCreateDatePersonWhoPaid) == .orderedAscending
            let down = (split.value(forKey: "createDatePerson") as? Date ?? Date()).compare(minusCreateDatePersonWhoPaid) == .orderedDescending
            
            var amountToSettle = 0.00
            if up && down && (split.value(forKey: "namePerson") as? String ?? ".") == (split.value(forKey: "namePersonWhoPaid") as? String ?? "") {
                continue
            } else {
                if abs(amountToBeSettled) < abs(amountLeft) {
                    amountToSettle = amountToBeSettled
                    amountToBeSettled = 0.00
                } else {
                    amountToBeSettled = max((amountToBeSettled - amountLeft),0.00)
                    amountToSettle = max(amountLeft,0.00)
                }
            }
            let settledNew = amountToSettle*exchangeRate // Transaction Currency
                        
            // settle splits
            let settledPerson = split.value(forKey: "settled") as? Double ?? 0.00
            let settledPersonNew = settledPerson + settledNew // Transaction Currency
            
            let queryPerson = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@ AND createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate, createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString)
            
            let queryPersonWhoPaid = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@ AND createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate, plusCreateDatePersonWhoPaid as NSDate, minusCreateDatePersonWhoPaid as NSDate, (split.value(forKey: "namePersonWhoPaid") as? String ?? "") as NSString)
            
            let settledPersonWhoPaid = loadQueriedAttribute(entitie: "Splits", attibute: "settled", query: queryPersonWhoPaid) as? Double ?? 0.00
            let settledPersonWhoPaidNew = settledPersonWhoPaid+settledNew // Transaction Currency

            if (saveQueriedAttribute(entity: "Splits", attribute: "settled", query: queryPerson, value: settledPersonNew) && saveQueriedAttribute(entity: "Splits", attribute: "settled", query: queryPersonWhoPaid, value: settledPersonWhoPaidNew)) {
                _ = saveRealAmount(dateTime: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))
            }
            
        }
        let dateSort = NSSortDescriptor(key: "dateTimeTransaction", ascending: true)
        let querySplits = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDatePersonPlus as NSDate, createDatePersonMinus as NSDate, personName as NSString)
        
        let datesSplitsArray = loadDataGroupedQueriedSorted(entitie: "Splits", groupByColumn: "dateTimeTransaction", query: querySplits, sort: [dateSort]) as? [[String:Any]]
        if (datesSplitsArray?.count ?? 0) > 0 {
            for i in 0...((datesSplitsArray?.count ?? 1)-1) {
                if let createDateTransaction = datesSplitsArray?[i]["dateTimeTransaction"] as? Date {
                    let createDateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateTransaction)!
                    let createDateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateTransaction)!
                    
                    let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
                    
                    // Delete if open Split
                    var openSplit:Bool = false
                    
                    let querySplitDelete = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate)
                    
                    let amountTransaction = loadQueriedAttribute(entitie: "Transactions", attibute: "amount", query: queryTransaction) as? Double ?? 0.00
                    
                    for split in loadBulkQueried(entitie: "Splits", query: querySplitDelete) {
                        if abs(((amountTransaction*(split.value(forKey: "ratio") as? Double ?? 0.00)) - (split.value(forKey: "settled") as? Double ?? 0.00))) > 0.005 {
                            
                            let personCreateDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "createDatePerson") as? Date ?? Date()))!
                            let personCreateDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "createDatePerson") as? Date ?? Date()))!
                            
                            let up = (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()).compare(personCreateDatePlus) == .orderedAscending
                            let down = (split.value(forKey: "createDatePersonWhoPaid") as? Date ?? Date()).compare(personCreateDateMinus) == .orderedDescending
                            // Person Who paid does not matter
                            if up && down && ((split.value(forKey: "namePerson") as? String ?? "") == (split.value(forKey: "namePersonWhoPaid") as? String ?? "")) {
                                continue
                            } else {
                                openSplit = true
                                break
                            }
                        }
                    }
                    
                    if !openSplit {
                        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
                        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
            
                        var userName:String = ""
                        var createDateUser:Date = Date()
                    
                        for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
                            userName = data.value(forKey: "namePerson") as? String ?? ""
                            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
                        }
                    
                        let createDateUserPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser)!
                        let createDateUserMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser)!
                    
                        let querySplitUser = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@ AND createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", createDateTransactionPlus as NSDate, createDateTransactionMinus as NSDate, createDateUserPlus as NSDate, createDateUserMinus as NSDate, userName as NSString)
                    
                        let ratioUser = loadQueriedAttribute(entitie: "Splits", attibute: "ratio", query: querySplitUser) as? Double ?? 0.00
                    
                        if saveQueriedAttribute(entity: "Transactions", attribute: "isSplit", query: queryTransaction, value: Int16(0)) && saveQueriedAttribute(entity: "Transactions", attribute: "amount", query: queryTransaction, value: (amountTransaction*ratioUser)) {
                            if deleteDataReturn(entity: "Splits", query: querySplitDelete) {
                                _ = saveRealAmount(dateTime: createDateTransaction)
                            }
                        }
                    }
                }
            }
        }
        
        let amountToSettled = abs(rowData[row]?[0] as? Double ?? 0.00) - abs(rowData[row]?[8] as? Double ?? 0.00)
        
        if rowData[row]?[0] as? Double ?? 0.00 < 0 {
            rowData[row]?[0] = (-1)*amountToSettled
            rowData[row]?[8] = (-1)*amountToSettled
        } else {
            rowData[row]?[0] = amountToSettled
            rowData[row]?[8] = amountToSettled
        }
        
        if abs(rowData[row]?[8] as? Double ?? 0.00) > 0.0001 {
            if let cell = settleSplitTableView.cellForRow(at: IndexPath(row: row, section: 0)) as? cellSettleSplitTVC {
                cell.settleAmount.text = (numberFormatter.string(from: NSNumber(value: abs(rowData[row]?[0] as? Double ?? 0.00))) ?? "0.00")
            }
        } else {
            settleSplitTableView.beginUpdates()
            settleSplitTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
            settleSplitTableView.endUpdates()
        }
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("splitSettled"), object: nil)
//        nc.post(name: Notification.Name("transactionUpdated"), object: nil, userInfo: ["transactionCreateDate": (transactionDateTime), "oldCreateDate":(transactionDateTime)])
        nc.post(name: Notification.Name("groupPersonAdded"), object: nil)
        
//        return [
//            0:sumOwed, // Amount Owed as it is now in the DB
//            1:userName ?? "",
//            2:userColor,
//            3:createDateUser ?? Date(),
//            4:personName,
//            5:personColor,
//            6:personCreateDate,
//            7:currencyCode,
//            8:sumOwed // Amount to-be-settled
//        ]
    }
    
    @objc func cancel() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func settleAll() {
        let alert = UIAlertController(title: NSLocalizedString("allSettledTitle", comment: "All Settled Title"), message: NSLocalizedString("allSettledText", comment: "All Settled Text"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let amountFormatter = NumberFormatter()
            amountFormatter.locale = .current
            amountFormatter.numberStyle = .decimal
            amountFormatter.usesGroupingSeparator = true
            amountFormatter.groupingSeparator = Locale.current.groupingSeparator
            amountFormatter.groupingSize = 3
            amountFormatter.minimumFractionDigits = 2
            amountFormatter.maximumFractionDigits = 2
            
            for i in 0...(self.rowData.count-1) {
                if let cell = self.settleSplitTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? cellSettleSplitTVC {
                    cell.settleAmount.text = amountFormatter.string(from: NSNumber(value: self.rowData[i]?[0] as? Double ?? 0.00))
                }
                
                if (self.transactionCreateDate == nil) && (self.createDateGroup != nil) && (self.groupName != nil) && (self.createDatePerson == nil) && (self.personName == nil) { // Settle Group
                    self.settleGroup(row: i, groupCreateDate: self.createDateGroup ?? Date(), settleAll: true)
                } else if (self.transactionCreateDate == nil) && (self.createDateGroup != nil) && (self.groupName != nil) && (self.createDatePerson != nil) && (self.personName != nil) { // Settle Group+Person
                    self.settleGroup(row: i, groupCreateDate: self.createDateGroup ?? Date(), settleAll: true)
                } else if (self.transactionCreateDate == nil) && (self.createDateGroup == nil) && (self.groupName == nil) && (self.createDatePerson != nil) && (self.personName != nil) { // Settle Person
                    self.settlePerson(row: i, settleAll: true)
                } else if self.transactionCreateDate != nil { // Settle Transaction
                    self.settleTransaction(row: i, transactionDateTime: self.transactionCreateDate ?? Date())
                }
                reloadListView = true
                reloadFinView = true
                reloadGraphView = true
                
//                self.settleSplits(row: i, groupCreateDate: self.createDateGroup, nameGroup: self.groupName, personCreateDate: (self.rowData[i]?[3] as? Date ?? Date()), namePerson: (self.rowData[i]?[1] as? String ?? ""), otherPersonName: (self.rowData[i]?[4] as? String ?? ""), createDateOtherPerson: (self.rowData[i]?[6] as? Date ?? Date()), transactionDateTime: self.transactionCreateDate)
            }
        }))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        self.present(alert, animated: true)
    }
    
    func saveRealAmount(dateTime: Date) -> Bool {
        var realAmount:Double?
        
        let dateTimeTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTime)!
        let dateTimeTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTime)!
        
        let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", dateTimeTransactionPlus as NSDate, dateTimeTransactionMinus as NSDate)
        
        let amount = loadQueriedAttribute(entitie: "Transactions", attibute: "amount", query: queryTransaction) as? Double ?? 0.00
        let exchangeRate = loadQueriedAttribute(entitie: "Transactions", attibute: "exchangeRate", query: queryTransaction) as? Double ?? 1.00
        
        if isSplit(transactionDateTime: dateTime) > 0 {
            
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
            
            var paidByUser:Bool?
            var settledUser:Double?
            
            for dataUser in loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [nameSort]) {
                settledUser = (dataUser.value(forKey: "settled") as? Double ?? 0.00)
                paidByUser = (dataUser.value(forKey: "paidByUser") as? Bool ?? true)
            }
            
            if (paidByUser ?? false) {
                var settledByOthers:Double = 0.00
                
                let queryOthers = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ ", (dateMinus as NSDate), (datePlus as NSDate))
                
                for dataOthers in loadBulkQueriedSorted(entitie: "Splits", query: queryOthers, sort: [nameSort]) {
                    if !isUser(createDate: (dataOthers.value(forKey: "createDatePerson") as? Date ?? Date()), namePerson: (dataOthers.value(forKey: "namePerson") as? String ?? "")) {
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
        return saveQueriedAttribute(entity: "Transactions", attribute: "realAmount", query: queryTransaction, value: realAmount ?? 0.00)
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
    
    @objc func currencyChanged(notification: Notification) {
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
extension settleSplitTVC {
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
    
    func saveQueriedAttribute(entity: String, attribute: String, query: NSPredicate ,value: Any) -> Bool {
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
                return false
            } else {
                fetchedData[0].setValue(value, forKey: attribute)
                try managedContext.save()
                return true
            }
        } catch {
            fatalError("Failed to fetch recordings: \(error)")
        }
    }
    
    func personPaid(dateTimeTransaction: Date, namePerson: String, dateTimePerson:Date) -> Bool {
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        
        let personDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTimePerson)!
        let personDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTimePerson)!
        
        let dateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTimeTransaction)!
        let dateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTimeTransaction)!
        
        let query = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePersonWhoPaid == %@ AND createDatePersonWhoPaid > %@ AND createDatePersonWhoPaid < %@", (dateTransactionMinus as NSDate), (dateTransactionPlus as NSDate), (namePerson as NSString), (personDateMinus as NSDate), (personDatePlus as NSDate))

        if loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [nameSort]).count > 0 {
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
    
    func personOrOtherPersonPaid(dateTimeTransaction: Date, namePerson: String, dateTimePerson: Date, nameOtherPerson:String, dateTimeOtherPerson:Date) -> Bool {
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        
        let personDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTimePerson)!
        let personDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTimePerson)!
        
        let dateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTimeTransaction)!
        let dateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTimeTransaction)!
        
        let query = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePersonWhoPaid == %@ AND createDatePersonWhoPaid > %@ AND createDatePersonWhoPaid < %@", (dateTransactionMinus as NSDate), (dateTransactionPlus as NSDate), (namePerson as NSString), (personDateMinus as NSDate), (personDatePlus as NSDate))
        
        if loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [nameSort]).count > 0 {
            return true
        }
            
        let otherPersonDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTimeOtherPerson)!
        let otherPersonDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTimeOtherPerson)!
            
        let queryOtherPersonPaid = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePersonWhoPaid == %@ AND createDatePersonWhoPaid > %@ AND createDatePersonWhoPaid < %@", (dateTransactionMinus as NSDate), (dateTransactionPlus as NSDate), (nameOtherPerson as NSString), (otherPersonDateMinus as NSDate), (otherPersonDatePlus as NSDate))
            
        if loadBulkQueriedSorted(entitie: "Splits", query: queryOtherPersonPaid, sort: [nameSort]).count <= 0 {
            return false
        } else {
            return true
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
        
        return ((transactionAmount ?? 0.00)*(ratio ?? 0.00))-(settled ?? 0.00)
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
    
    func loadDataGroupedQueriedSorted(entitie:String, groupByColumn:String, query:NSPredicate, sort:[NSSortDescriptor]) -> Any {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
        let keypathExp = NSExpression(forKeyPath: groupByColumn) // can be any column
        let expression = NSExpression(forFunction: "count:", arguments: [keypathExp])
        
        let countDesc = NSExpressionDescription()
        countDesc.expression = expression
        countDesc.name = "count"
        countDesc.expressionResultType = .integer64AttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = [groupByColumn]
        fetchRequest.propertiesToFetch = [groupByColumn, countDesc]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        fetchRequest.sortDescriptors = sort
        
        do {
            let loadData = try managedContext.fetch(fetchRequest)
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return false
    }
    
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
    
    func deleteDataReturn(entity: String, query: NSPredicate) -> Bool {
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
                return true
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                return false
            }
        } catch {
            print(error)
            return false
        }
    }
}

extension settleSplitTVC: cellSettleSplitTVCDelegate {
    func amountTextFieldDidChange(newText:String, textFieldTag:Int) {
        let amountFormatter = NumberFormatter()
        amountFormatter.locale = .current
        amountFormatter.numberStyle = .decimal
        amountFormatter.usesGroupingSeparator = true
        amountFormatter.groupingSeparator = Locale.current.groupingSeparator
        amountFormatter.groupingSize = 3
        amountFormatter.minimumFractionDigits = 2
        amountFormatter.maximumFractionDigits = 2
        
        if var newSettleAmount = amountFormatter.number(from: newText) as? Double {
            if newSettleAmount < 0 {
                newSettleAmount = 0.00
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let cell = self.settleSplitTableView.cellForRow(at: IndexPath(row: textFieldTag, section: 0)) as? cellSettleSplitTVC {
                        cell.settleAmount.text = amountFormatter.string(from: NSNumber(value: newSettleAmount))
                    }
                }
            } else if newSettleAmount > abs(rowData[textFieldTag]?[0] as? Double ?? 0.00) {
                newSettleAmount = abs(rowData[textFieldTag]?[0] as? Double ?? 0.00)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let cell = self.settleSplitTableView.cellForRow(at: IndexPath(row: textFieldTag, section: 0)) as? cellSettleSplitTVC {
                        cell.settleAmount.text = amountFormatter.string(from: NSNumber(value: newSettleAmount))
                    }
                }
            }
            rowData[textFieldTag]?[8] = newSettleAmount
        }
    }
    
    func settleButtonPressed(buttonTag:Int) {
        
        let title = NSLocalizedString("settledTitle", comment: "Settled")
        
        var firstName:String?
        var firstYou = false
        var secondName:String?
        var secondYou = false
        
        if (rowData[buttonTag]?[0] as? Double ?? 0.00) >= 0 {
            if isUser(createDate: (rowData[buttonTag]?[6] as? Date ?? Date()), namePerson: (rowData[buttonTag]?[4] as? String ?? "")) {
                firstName = NSLocalizedString("youTheUser", comment: "You")
                firstYou = true
            } else {
                firstName = (rowData[buttonTag]?[4] as? String ?? "")
            }
            
            if isUser(createDate: (rowData[buttonTag]?[3] as? Date ?? Date()), namePerson: (rowData[buttonTag]?[1] as? String ?? "")) {
                secondName = NSLocalizedString("youTheUser", comment: "You")
                secondYou = true
            } else {
                secondName = (rowData[buttonTag]?[1] as? String ?? "")
            }
        } else {
            if isUser(createDate: (rowData[buttonTag]?[3] as? Date ?? Date()), namePerson: (rowData[buttonTag]?[1] as? String ?? "")) {
                firstName = NSLocalizedString("youTheUserSmall", comment: "You")
                firstYou = true
            } else {
                firstName = (rowData[buttonTag]?[1] as? String ?? "")
            }
            
            if isUser(createDate: (rowData[buttonTag]?[6] as? Date ?? Date()), namePerson: (rowData[buttonTag]?[4] as? String ?? "")) {
                secondName = NSLocalizedString("youTheUserSmall", comment: "You")
                secondYou = true
            } else {
                secondName = (rowData[buttonTag]?[4] as? String ?? "")
            }
        }
        
        var text:String = ""
        
        let langStr = Locale.current.languageCode
                
        switch langStr {
        case "de","DE":
            var amountStr0 = (numberFormatter.string(from: NSNumber(value: abs(rowData[buttonTag]?[8] as? Double ?? 0.00))) ?? "0.00")
            if amountStr0.count <= 0 { amountStr0 = numberFormatter.string(from: 0.00) ?? "0.00" }
            
            let amountString = amountStr0 + " " + (getSymbol(forCurrencyCode: (rowData[buttonTag]?[7] as? String ?? "EUR")) ?? "€")
            
            if firstYou {
                // "Hast du 100€ an Nathalie bezahlt?"
                let str0 = NSLocalizedString("settledHast", comment: "Hast") + " " + NSLocalizedString("youTheUserSmall", comment: "You") + " "
                let str1 = " " + NSLocalizedString("settledAn", comment: "an") + " "
                let str2 = " " + NSLocalizedString("settledPersonPaid", comment: "bezahlt") + "?"
                
                text = str0 + amountString + str1 + (secondName ?? "Person") + str2
            } else if secondYou {
                // "Hat Nathalie 100€ an dich bezahlt?"
                let str0 = NSLocalizedString("settledHat", comment: "Hat") + " " + (firstName ?? "") + " "
                let str1 = " " + NSLocalizedString("settledAn", comment: "an") + " "
                let str2 = " " + NSLocalizedString("settledPersonPaid", comment: "bezahlt") + "?"
                
                text = str0 + amountString + str1 + NSLocalizedString("settledDich", comment: "dich") + str2
            } else {
                // "Hat Nathalie 100€ an Sepy bezahlt?"
                let str0 = NSLocalizedString("settledHat", comment: "Hat") + " " + (firstName ?? "") + " "
                let str1 = " " + NSLocalizedString("settledAn", comment: "an") + " "
                let str2 = " " + NSLocalizedString("settledPersonPaid", comment: "bezahlt") + "?"
                
                text = str0 + amountString + str1 + (secondName ?? "Person") + str2
            }
            break
        default:
            var amountStr0 = (numberFormatter.string(from: NSNumber(value: abs(rowData[buttonTag]?[8] as? Double ?? 0.00))) ?? "0.00")
            if amountStr0.count <= 0 { amountStr0 = numberFormatter.string(from: 0.00) ?? "0.00" }
            
            let amountString = (getSymbol(forCurrencyCode: (rowData[buttonTag]?[7] as? String ?? "EUR")) ?? "€") + "" + amountStr0

            if firstYou {
                // Have you paid 100€ to Sepy?
                let str0 = NSLocalizedString("settledHast", comment: "Have") + " " + NSLocalizedString("youTheUserSmall", comment: "You") + " " + NSLocalizedString("settledPersonPaid", comment: "paid") + " "
                let str2 = " " + NSLocalizedString("settledAn", comment: "to") + " "
                
                text = str0 + amountString + str2 + (secondName ?? "Person") + "?"
            } else if secondYou {
                // "Has Nathalie paid 100€ to you?"
                let str0 = NSLocalizedString("settledHat", comment: "Has") + " " + (firstName ?? "")
                let str1 = " " + NSLocalizedString("settledPersonPaid", comment: "paid") + " "
                let str2 = " " + NSLocalizedString("settledAn", comment: "to") + " "
                
                text = str0 + str1 + amountString + str2 + NSLocalizedString("settledDich", comment: "you") + "?"
            } else {
                // Has Nathalie paid 100€ to Sepy?
                let str0 = NSLocalizedString("settledHat", comment: "Has") + " " + (firstName ?? "")
                let str1 = " " + NSLocalizedString("settledPersonPaid", comment: "paid") + " "
                let str2 = " " + NSLocalizedString("settledAn", comment: "to") + " "
                
                text = str0 + str1 + amountString + str2 + (secondName ?? "Person") + "?"
            }
            break
        }
        
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let settledAmount = abs(self.rowData[buttonTag]?[8] as? Double ?? 0.00)
            
            if (self.transactionCreateDate == nil) && (self.createDateGroup != nil) && (self.groupName != nil) && (self.createDatePerson == nil) && (self.personName == nil) { // Settle Group
                self.settleGroup(row: buttonTag, groupCreateDate: self.createDateGroup ?? Date())
            } else if (self.transactionCreateDate == nil) && (self.createDateGroup != nil) && (self.groupName != nil) && (self.createDatePerson != nil) && (self.personName != nil) { // Settle Group+Person
                self.settleGroup(row: buttonTag, groupCreateDate: self.createDateGroup ?? Date())
            } else if (self.transactionCreateDate == nil) && (self.createDateGroup == nil) && (self.groupName == nil) && (self.createDatePerson != nil) && (self.personName != nil) { // Settle Person
                self.settlePerson(row: buttonTag)
            } else if self.transactionCreateDate != nil { // Settle Transaction
                self.settleTransaction(row: buttonTag, transactionDateTime: self.transactionCreateDate ?? Date())
            }
            reloadListView = true
            reloadFinView = true
            reloadGraphView = true
            
            let nc = NotificationCenter.default
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                nc.post(name: Notification.Name("groupPersonAdded"), object: nil)
            })
            
            if let cell = self.settleSplitTableView.cellForRow(at: IndexPath(row: buttonTag, section: 0)) as? cellSettleSplitTVC {
                let numberFormatterCurrency = NumberFormatter()
                numberFormatterCurrency.numberStyle = .currency
                numberFormatterCurrency.locale = Locale.current
                
                var amountStr = (numberFormatterCurrency.string(from: NSNumber(value: settledAmount)) ?? "0.00")
                if amountStr.count <= 0 { amountStr = numberFormatterCurrency.string(from: 0.00) ?? "0.00" }
                
                let stringPrevious = cell.subTitle.text
                let stringSettled = NSLocalizedString("settledDone", comment: "Settled: ") + amountStr
                
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
                    cell.subTitle.alpha = 0.0
                }, completion: { _ in
                    cell.subTitle.text = stringSettled
                    UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
                        cell.subTitle.alpha = 1.0
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.25, delay: 1.0, options: .curveLinear, animations: {
                            cell.subTitle.alpha = 0.0
                        }, completion: { _ in
                            cell.subTitle.text = stringPrevious
                            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
                                cell.subTitle.alpha = 1.0
                            })
                        })
                    })
                })
            }
        }))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        self.present(alert, animated: true)
    }
}
