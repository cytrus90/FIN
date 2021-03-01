//
//  splitTransactionTVC.swift
//  FIN
//
//  Created by Florian Riel on 17.10.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

var selectedSplitType:Int? // Equaly, % or EUR

class splitTransactionTVC: UITableViewController {

    @IBOutlet var splitTransactionTableView: UITableView!
    
    var amount:Double?
    var selectedSplit:Int?
    var selectedGroupOrPersons:String?
    
    var amountSplitPercent:Double?
    var amountSplit:Double?
    
    var paidBy:String?
    
    var buttonDisabledFlag:Bool = false
    
    var offsetContent:CGFloat = 0.00
    
    var newlyCreatedSplit = true
    
    let dateFormatter = ISO8601DateFormatter()
    var numberFormatter = NumberFormatter()
        
    var viewDisappear = false
    
    struct Person {
        var name:String
        var dateTime:Date
    }
    
    var transactionSplitRow:transactionSplitRow = {
        let nib = UINib(nibName: "transactionSplitRow", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! transactionSplitRow
    }()
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    let headerHeightFactor = CGFloat(0.10)
    var navTitle = NSLocalizedString("splitDetails", comment: "Split Details")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        if split.count != 0 {
//            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("deleteButton", comment: "Delete"), style: .done, target: self, action: #selector(deleteSplit))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSplit))
            newlyCreatedSplit = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(clearSelectedCell), name: Notification.Name("clearSelectedCell"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(whoPaidChanged), name: Notification.Name("whoPaidChanged"), object: nil)
        
        // Keyboad Scroll on Appear
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        // Keyboard dismiss
        splitTransactionTableView.keyboardDismissMode = .onDrag
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
        initSplits()
        
        offsetContent = splitTransactionTableView.contentInset.bottom
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        viewDisappear = true
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("resetSelected"), object: nil, userInfo: nil)
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
//        viewDisappear = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.navigationController?.view.backgroundColor = backgroundGeneralColor
            view.backgroundColor = backgroundGeneralColor
            splitTransactionTableView.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            splitTransactionTableView.backgroundColor = .secondarySystemBackground
        }
        
        initView()
//        createDataForRows()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 1:
            return getTransactionDetailCell(indexPath: indexPath)
        case 2:
            return getSplitTransactionGeneralCell(indexPath: indexPath)
        case 3:
            return getAddButtonCell(indexPath: indexPath)
        default:
            return getTransactionTypeCell(indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = splitTransactionTableView.cellForRow(at: indexPath)
        if indexPath.row == 2 {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "whoPaidSeque", sender: nil)
            }
            setCellSelected(indexPath: indexPath)
        }
        cell?.isSelected = false
    }

    // MARK: -CELL FUNCTIONS
    func getSplitTransactionGeneralCell(indexPath: IndexPath) -> cellSplitTransactionGeneral {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitTransactionGeneral", for: indexPath) as! cellSplitTransactionGeneral
        
        for i in 0...(split.count-1) {
            let datePlusPerson = Calendar.current.date(byAdding: .second, value: 1, to: (split[i]?[1] as? Date ?? Date()))!
            let dateMinusPerson = Calendar.current.date(byAdding: .second, value: -1, to: (split[i]?[1] as? Date ?? Date()))!
                        
            let up = (split[i]?[5] as? Date ?? Date()).compare(datePlusPerson) == .orderedAscending
            let down = (split[i]?[5] as? Date ?? Date()).compare(dateMinusPerson) == .orderedDescending
            
            if ((split[i]?[0] as? String ?? "") == (split[i]?[4] as? String ?? "")) && up && down {
                if (split[i]?[9] as? Bool ?? false) {
                    cell.mainLabel.text = (split[i]?[0] as? String ?? "") + " [" + NSLocalizedString("youTheUser", comment: "I") + "]"
                } else {
                    cell.mainLabel.text = (split[i]?[0] as? String ?? "")
                }
                
                cell.subLabel.text = NSLocalizedString("personWhoPaidSublabel", comment: "Person Who Paid Sublabel Text")
                
                let query = NSPredicate(format: "createDate < %@ AND createDate > %@ AND namePerson == %@", (datePlusPerson as NSDate), (dateMinusPerson as NSDate), ((split[i]?[0] as? String ?? "") as NSString))
                
                let colorInt = Int(loadQueriedAttribute(entitie: "SplitPersons", attibute: "color", query: query) as? Int16 ?? 0)
                
                cell.circleView.backgroundColor = UIColor.randomColor(color: colorInt, returnText: false, light: false)
                cell.circleView.layer.borderColor = UIColor.randomColor(color: colorInt, returnText: false, light: false).cgColor
                
                if (split[i]?[10] as? String ?? "").count > 0 {
                    cell.circleLabel.isHidden = true
                    cell.circleImage.isHidden = false
                    
                    var selectedIcon = (split[i]?[10] as? String ?? "").replacingOccurrences(of: "_white", with: "")
                    if (split[i]?[11] as? Bool ?? true) {
                        selectedIcon = selectedIcon + "_white"
                    }
                    
                    cell.circleImage.image = UIImage(named: selectedIcon)
                } else {
                    cell.circleLabel.isHidden = false
                    cell.circleImage.isHidden = true
                    
                    if (split[i]?[0] as? String ?? "").count == 1 {
                        cell.circleLabel.text = (split[i]?[0] as? String ?? "").prefix(1).uppercased()
                    } else if (split[i]?[0] as? String ?? "").count == 0 {
                        cell.circleLabel.text = ""
                    } else {
                        cell.circleLabel.text = (split[i]?[0] as? String ?? "").prefix(2).uppercased()
                    }
                    
                    if (split[i]?[11] as? Bool ?? true) {
                        cell.circleLabel.textColor = .white
                    } else {
                        cell.circleLabel.textColor = .black
                    }
                }
                break
            }
        }
        return cell
    }
    
    func getTransactionTypeCell(indexPath: IndexPath) -> cellSplitTransactionSplitType {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitTransactionSplitType", for: indexPath) as! cellSplitTransactionSplitType
        
        let amountString = (getSymbol(forCurrencyCode: currencyCodeSet) ?? "€") + "" + (numberFormatter.string(for: amount ?? 0.00) ?? "0.00")
        cell.topLabel.text = NSLocalizedString("topLabelTextHowSplitWasSetOne", comment: "How Split 1") + amountString + NSLocalizedString("topLabelTextHowSplitWasSetSecond", comment: "How Split 2")
        
        if editSplit {
            cell.segmentControl.selectedSegmentIndex = 2
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func getTransactionDetailCell(indexPath: IndexPath) -> cellSplitTransactionSplitDetails {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitTransactionSplitDetails", for: indexPath) as! cellSplitTransactionSplitDetails
        
        switch selectedSplitType {
        case 1:
            cell.topLabelLeft.isHidden = false
            cell.topLabel.text = NSLocalizedString("segmentSplitPercent", comment: "Segment Percent Text")
            break
        case 2:
            cell.topLabelLeft.isHidden = false
            cell.topLabel.text = getSymbol(forCurrencyCode: currencyCodeSet)
            break
        default:
            cell.topLabelLeft.isHidden = true
            cell.topLabel.text = getSymbol(forCurrencyCode: currencyCodeSet)
            break
        }
        
        for i in 0...(split.count-1) {
            
            let transactionSplitRow:transactionSplitRow = {
                let nib = UINib(nibName: "transactionSplitRow", bundle: nil)
                return nib.instantiate(withOwner: self, options: nil).first as! transactionSplitRow
            }()
            
            transactionSplitRow.initView()
            
            if split[i]?[9] as? Bool ?? false {
                transactionSplitRow.label.text = (split[i]?[0] as? String ?? "") + " [" + NSLocalizedString("youTheUser", comment: "I") + "]"
            } else {
                transactionSplitRow.label.text = split[i]?[0] as? String ?? ""
            }
            
            if selectedSplitType == 1 {
                transactionSplitRow.amountTextField.text = numberFormatter.string(from: NSNumber(value: ((split[i]?[7] as? Double ?? 0.00) * 100)))
            } else {
                let amountString = numberFormatter.string(for: ((amount ?? 0.00)*((split[i]?[7]) as? Double ?? 1.00) as NSNumber))
                transactionSplitRow.amountTextField.text = amountString
            }
            
            transactionSplitRow.tag = i
            transactionSplitRow.delegate = self
            
            cell.stackView.addArrangedSubview(transactionSplitRow)
            transactionSplitRow.leadingAnchor.constraint(equalTo: cell.stackView.leadingAnchor, constant: 5).isActive = true
            transactionSplitRow.trailingAnchor.constraint(equalTo: cell.stackView.trailingAnchor, constant: -5).isActive = true
        }
        return cell
    }
    
    func getAddButtonCell(indexPath:IndexPath) -> cellSplitTransactionSplitAddButton {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitTransactionSplitAddButton", for: indexPath) as! cellSplitTransactionSplitAddButton
        cell.delegate = self
        return cell
    }
    
    func setCellSelected(indexPath: IndexPath) {
        if let cell = splitTransactionTableView.cellForRow(at: indexPath) as? cellSplitTransactionGeneral {
            cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
            cell.outlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
        }
    }
    
    @objc func clearSelectedCell() {
        let indexPath = IndexPath(row: 2, section: 0)
        if let cell = splitTransactionTableView.cellForRow(at: indexPath) as? cellSplitTransactionGeneral {
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
    
    // MARK: -VIEW FUNCTIONS
    func initView() {
        initTableAndHeaderView()
    }
    
    func initTableAndHeaderView() {
        splitTransactionTableView.sectionHeaderHeight = UITableView.automaticDimension
     
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            splitTransactionTableView.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
        } else {
            splitTransactionTableView.backgroundColor = .secondarySystemBackground
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
        headerView.scrollView = splitTransactionTableView
        
        splitTransactionTableView.backgroundView = UIView()
        splitTransactionTableView.backgroundView?.addSubview(headerView)
        splitTransactionTableView.contentInset = UIEdgeInsets(
            top: 85,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 40,
            right: 0
        )
    }
    
    // MARK: -FUNCTIONS
    
    func initSplits() {
        if !editSplit {
            var initialCreate:Bool?
            if split.count > 0 {
                initialCreate = false
            } else {
                initialCreate = true
            }
            split.removeAll()
            
            let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
            let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
            
            var userName:String?
            var userCreateDate:Date?
            var userIcon:String?
            var userIconLight:Bool?
            
            for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
                userName = data.value(forKey: "namePerson") as? String ?? ""
                userCreateDate = data.value(forKey: "createDate") as? Date ?? Date()
                userIcon = data.value(forKey: "icon") as? String ?? ""
                userIconLight = data.value(forKey: "iconLight") as? Bool ?? true
            }
            
            var paidByUser:Bool?
            
            // 0: namePerson
            // 1: createDatePerson
            // 2: nameGroup
            // 3: createDateGroup
            // 4: namePersonWhoPaid
            // 5: createDatePersonWhoPaid
            // 6: paidByUser
            // 7: ratio
            // 8: settled
            // 9: isUser
            // 10: icon
            // 11: iconLight
            
            var i = 0
            switch selectedSplit {
            case 1: // Single Person Split
                let personName = selectedGroupOrPersons?.components(separatedBy: "*&*")[0] ?? ""
                let personCreateDate = dateFormatter.date(from: (selectedGroupOrPersons?.components(separatedBy: "*&*")[1] ?? "")) ?? Date()
                
                let userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: userCreateDate ?? Date())!
                let userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: userCreateDate ?? Date())!
                
                let up = personCreateDate.compare(userDatePlus) == .orderedAscending
                let down = personCreateDate.compare(userDateMinus) == .orderedDescending
                
                if (up && down && personName == userName) || (initialCreate ?? false) {
                    paidByUser = true
                } else {
                    paidByUser = false
                }
                
                let personDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: personCreateDate)!
                let personDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: personCreateDate)!
                
                let queryOtherPerson = NSPredicate(format: "createDate > %@ AND createDate < %@ AND namePerson == %@", personDateMinus as NSDate, personDatePlus as NSDate, personName as NSString)
                
                split[0] = [ // User
                    0:userName ?? "User",
                    1:userCreateDate ?? Date(),
                    4:userName ?? "User",
                    5:userCreateDate ?? Date(),
                    6:paidByUser ?? false,
                    7:0.5,
                    8:0.00,
                    9:true,
                    10:userIcon ?? "",
                    11:userIconLight ?? true
                ]
                
                split[1] = [ // The other person
                    0:personName,
                    1:personCreateDate,
                    4:userName ?? "User",
                    5:userCreateDate ?? Date(),
                    6:paidByUser ?? false,
                    7:0.5,
                    8:0.00,
                    9:false,
                    10:loadQueriedAttribute(entitie: "SplitPersons", attibute: "icon", query: queryOtherPerson) as? String ?? "",
                    11:loadQueriedAttribute(entitie: "SplitPersons", attibute: "iconLight", query: queryOtherPerson) as? Bool ?? true
                ]
                break
            case 2: // Multiple Persons Split
                var missing = amount
                
                let persons = (selectedGroupOrPersons ?? "").components(separatedBy: "*;*")
//                split[0] = [ // User
//                    0:userName,
//                    1:userCreateDate,
//                    4:userName,
//                    5:userCreateDate,
//                    6:paidByUser ?? false,
//                    7:(1.00 / Double(persons.count + 1)),
//                    8:0.00,
//                    9:true
//                ]
//                missing = (missing ?? 0.00) - ((split[0]?[7] as? Double ?? 0.00)*(amount ?? 0.00))
                var firstPersonName:String?
                var firstPersonCreateDate:Date?
                
                for person in persons {
                    
                    let personName = person.components(separatedBy: "*&*")[0]
                    let personCreateDate = dateFormatter.date(from: (person.components(separatedBy: "*&*")[1])) ?? Date()
                    
                    let isUserTag = isUser(createDate: personCreateDate, namePerson: personName)
                    
                    if i == 0 {
                        firstPersonName = personName
                        firstPersonCreateDate = personCreateDate
                        
                        let userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: userCreateDate ?? Date())!
                        let userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: userCreateDate ?? Date())!
                        
                        let up = (firstPersonCreateDate ?? Date()).compare(userDatePlus) == .orderedAscending
                        let down = (firstPersonCreateDate ?? Date()).compare(userDateMinus) == .orderedDescending
                        
                        if up && down && (firstPersonName == userName) {
                            paidByUser = true
                        } else {
                            paidByUser = false
                        }
                    }
                    
                    let personDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: personCreateDate)!
                    let personDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: personCreateDate)!
                    
                    let queryOtherPerson = NSPredicate(format: "createDate > %@ AND createDate < %@ AND namePerson == %@", personDateMinus as NSDate, personDatePlus as NSDate, personName as NSString)
                    
                    split[i] = [ // Persons
                        0:personName,
                        1:personCreateDate,
                        4:firstPersonName ?? personName,
                        5:firstPersonCreateDate ?? personCreateDate,
                        6:paidByUser ?? false,
                        7:(1.00 / Double(persons.count)),
                        8:0.00,
                        9:isUserTag,
                        10:loadQueriedAttribute(entitie: "SplitPersons", attibute: "icon", query: queryOtherPerson) as? String ?? "",
                        11:loadQueriedAttribute(entitie: "SplitPersons", attibute: "iconLight", query: queryOtherPerson) as? Bool ?? true
                    ]
                    missing = (missing ?? 0.00) - ((split[0]?[7] as? Double ?? 0.00)*(amount ?? 0.00))
                    
                    if i == (persons.count) && (missing ?? 0.00) > 0.00 {
                        if (missing ?? 0.00) < 0.01 {
                            missing = 0.01
                        }
                        let RAM = (split[i]?[7] as? Double ?? 0.00)
                        let amountMissing = ((RAM * (amount ?? 0.00)) + (missing ?? 0.00))
                        split[i]?[7] = (amountMissing/(amount ?? 1.00))
                    }
                    
                    i = i + 1
                }
                
                break
            default: // Group Split
                var missing = amount
                
                let groupName = selectedGroupOrPersons?.components(separatedBy: "*&*")[0] ?? ""
                let groupCreateDate = dateFormatter.date(from: (selectedGroupOrPersons?.components(separatedBy: "*&*")[1] ?? "")) ?? Date()
                
                let datePlus = Calendar.current.date(byAdding: .second, value: 1, to: (groupCreateDate))!
                let dateMinus = Calendar.current.date(byAdding: .second, value: -1, to: (groupCreateDate))!
                
                let query = NSPredicate(format: "createDate < %@ AND createDate > %@ AND nameGroup == %@", (datePlus as NSDate), (dateMinus as NSDate), ((groupName) as NSString))
                
                let persons = (loadQueriedAttribute(entitie: "SplitGroups", attibute: "persons", query: query) as? String ?? "").components(separatedBy: "*;*")

                var firstPersonName:String?
                var firstPersonCreateDate:Date?

                var personsSort = [Person]()
                
                for person in persons {
                    personsSort.append(Person(name: person.components(separatedBy: "*&*")[0], dateTime: (dateFormatter.date(from: (person.components(separatedBy: "*&*")[1])) ?? Date())))
                }
                
                if personsSort.count > 0 {
                    personsSort.sort { $0.dateTime < $1.dateTime }
                }

                for person in personsSort {
                    let personName = person.name
                    let personCreateDate = person.dateTime
                    
                    let isUserTag = isUser(createDate: personCreateDate, namePerson: personName)
                    
                    if i == 0 {
                        firstPersonName = personName
                        firstPersonCreateDate = personCreateDate
                        
                        let userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: userCreateDate ?? Date())!
                        let userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: userCreateDate ?? Date())!
                        
                        let up = (firstPersonCreateDate ?? Date()).compare(userDatePlus) == .orderedAscending
                        let down = (firstPersonCreateDate ?? Date()).compare(userDateMinus) == .orderedDescending
                        
                        if up && down && firstPersonName == userName {
                            paidByUser = true
                        } else {
                            paidByUser = false
                        }
                    }
                    
                    let personDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: personCreateDate)!
                    let personDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: personCreateDate)!
                    
                    let queryOtherPerson = NSPredicate(format: "createDate > %@ AND createDate < %@ AND namePerson == %@", personDateMinus as NSDate, personDatePlus as NSDate, personName as NSString)
                    
                    split[i] = [ // Persons
                        0:personName,
                        1:personCreateDate,
                        2:groupName,
                        3:groupCreateDate,
                        4:firstPersonName ?? personName,
                        5:firstPersonCreateDate ?? personCreateDate,
                        6:paidByUser ?? false,
                        7:(1.00 / Double(persons.count)),
                        8:0.00,
                        9:isUserTag,
                        10:loadQueriedAttribute(entitie: "SplitPersons", attibute: "icon", query: queryOtherPerson) as? String ?? "",
                        11:loadQueriedAttribute(entitie: "SplitPersons", attibute: "iconLight", query: queryOtherPerson) as? Bool ?? true
                    ]
                    missing = (missing ?? 0.00) - ((split[0]?[7] as? Double ?? 0.00)*(amount ?? 0.00))
                    
                    if i == (persons.count) && (missing ?? 0.00) > 0.00 {
                        if (missing ?? 0.00) < 0.01 {
                            missing = 0.01
                        }
                        let RAM = (split[i]?[7] as? Double ?? 0.00)
                        let amountMissing = ((RAM * (amount ?? 0.00)) + (missing ?? 0.00))
                        split[i]?[7] = (amountMissing/(amount ?? 1.00))
                    }
                    i = i + 1
                }
                break
            }
        }
        
        amountSplit = (((amount ?? 0.00)/Double(split.count)))*Double(split.count)
        amountSplitPercent = Double(truncating: (numberFormatter.number(from: numberFormatter.string(from: NSNumber(value: (Double(100.00)/Double(split.count)))) ?? "0.00")) ?? 0.00)*Double(split.count)
        if newlyCreatedSplit {
            segmentChanged(selected: selectedSplitType ?? 0)
        }
    }
    
    @objc func cancel() {
//        let nc = NotificationCenter.default
//        nc.post(name: Notification.Name("clearSelected"), object: nil, userInfo: nil)
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func deleteSplit() {
        split.removeAll()
        
        if selectedSplitRow.count != 0 {
            selectedSplitRow.removeAll()
        }
        if selectedSplitSegment != nil {
            selectedSplitSegment = nil
        }
        if selectedSplitType != nil {
            selectedSplitType = nil
        }
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("splitChanged"), object: nil, userInfo: nil)
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func whoPaidChanged() {
        if let cell = splitTransactionTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? cellSplitTransactionGeneral {
            for i in 0...(split.count-1) {
                let datePlusPerson = Calendar.current.date(byAdding: .second, value: 1, to: (split[i]?[1] as? Date ?? Date()))!
                let dateMinusPerson = Calendar.current.date(byAdding: .second, value: -1, to: (split[i]?[1] as? Date ?? Date()))!
                            
                let up = (split[i]?[5] as? Date ?? Date()).compare(datePlusPerson) == .orderedAscending
                let down = (split[i]?[5] as? Date ?? Date()).compare(dateMinusPerson) == .orderedDescending
                
                if ((split[i]?[0] as? String ?? "") == (split[i]?[4] as? String ?? "")) && up && down {

                    if (split[i]?[9] as? Bool ?? false) {
                        cell.mainLabel.text = (split[i]?[0] as? String ?? "") + " [" + NSLocalizedString("youTheUser", comment: "I") + "]"
                    } else {
                        cell.mainLabel.text = (split[i]?[0] as? String ?? "")
                    }
                    
                    cell.subLabel.text = NSLocalizedString("personWhoPaidSublabel", comment: "Person Who Paid Sublabel Text")
                    
                    let query = NSPredicate(format: "createDate < %@ AND createDate > %@ AND namePerson == %@", (datePlusPerson as NSDate), (dateMinusPerson as NSDate), ((split[i]?[0] as? String ?? "") as NSString))
                    
                    let colorInt = Int(loadQueriedAttribute(entitie: "SplitPersons", attibute: "color", query: query) as? Int16 ?? 0)
                    
                    cell.circleView.backgroundColor = UIColor.randomColor(color: colorInt, returnText: false, light: false)
                    cell.circleView.layer.borderColor = UIColor.randomColor(color: colorInt, returnText: false, light: false).cgColor
                    cell.circleLabel.textColor = UIColor.randomColor(color: colorInt, returnText: true, light: false)
                    
                    if (split[i]?[10] as? String ?? "").count > 0 {
                        cell.circleLabel.isHidden = true
                        cell.circleImage.isHidden = false
                        
                        var selectedIcon = (split[i]?[10] as? String ?? "").replacingOccurrences(of: "_white", with: "")
                        if (split[i]?[11] as? Bool ?? true) {
                            selectedIcon = selectedIcon + "_white"
                        }
                        
                        cell.circleImage.image = UIImage(named: selectedIcon)
                    } else {
                        cell.circleLabel.isHidden = false
                        cell.circleImage.isHidden = true
                        
                        if (split[i]?[0] as? String ?? "").count == 1 {
                            cell.circleLabel.text = (split[i]?[0] as? String ?? "").prefix(1).uppercased()
                        } else if (split[i]?[0] as? String ?? "").count == 0 {
                            cell.circleLabel.text = ""
                        } else {
                            cell.circleLabel.text = (split[i]?[0] as? String ?? "").prefix(2).uppercased()
                        }
                        
                        if (split[i]?[11] as? Bool ?? true) {
                            cell.circleLabel.textColor = .white
                        } else {
                            cell.circleLabel.textColor = .black
                        }
                    }
                    break
                }
            }
        }
    }
    
    func setPercent() -> String {
        var leftTopLabelText:String?
        
        if let cell = splitTransactionTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSplitTransactionSplitDetails {
            let numberPersons = Double(split.count)
            var total = 0.00
            for i in 0...(split.count-1) {
                let row = cell.stackView.arrangedSubviews[(i+1)] as? transactionSplitRow
                split[i]?[7] = (1.00 / numberPersons).roundTo(places: 4)
                total = total + (split[i]?[7] as? Double ?? 0.00)

                if (i == (split.count-1)) && (total < 1.00) {
                    let RAM = (split[i]?[7] as? Double ?? 0.00)
                    split[i]?[7] = RAM + (1.00 - total)
                }
                row?.amountTextField.text = numberFormatter.string(from: NSNumber(value: ((split[i]?[7] as? Double ?? 0.00) * 100)))
            }
        }
        
        leftTopLabelText = ""
        return leftTopLabelText ?? ""
    }
    
    func updatePercent() -> String {
        var leftTopLabelText:String?
        var total = 0.00
        if let cell = splitTransactionTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSplitTransactionSplitDetails {
            for i in 0...(split.count-1) {
                let row = cell.stackView.arrangedSubviews[(i+1)] as? transactionSplitRow

                let amountFormatter = NumberFormatter()
                amountFormatter.locale = .current
                let inputPercent = Double(truncating: amountFormatter.number(from: (row?.amountTextField.text ?? "0")) ?? 0)
                
                split[i]?[7] = (inputPercent/100.00)

                total = total + inputPercent
            }
        }
        
        var diff = ((amountSplitPercent ?? 0.00) - total).roundTo(places: 2)

        if diff < 0.00 {
            diff = (-1)*diff
            if diff < 0.01 {
                diff = 0.01
            }
            leftTopLabelText = NSLocalizedString("tooMuchText", comment: "too Much Text") + (numberFormatter.string(from: NSNumber(value: diff)) ?? "0.00") + NSLocalizedString("segmentSplitPercent", comment: "%")
            buttonDisabledFlag = true
        } else if diff == 0.00 {
            leftTopLabelText = ""
            buttonDisabledFlag = false
        } else {
            if diff < 0.01 {
                diff = 0.01
                leftTopLabelText = ""
                buttonDisabledFlag = false
            } else {
                leftTopLabelText = NSLocalizedString("missingText", comment: "Missing Text") + (numberFormatter.string(from: NSNumber(value: diff)) ?? "0.00") + NSLocalizedString("segmentSplitPercent", comment: "%")
                buttonDisabledFlag = true
            }
        }
        
        return leftTopLabelText ?? ""
    }
    
    func setAmount() -> String {
        var leftTopLabelText:String?
        
        if let cell = splitTransactionTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSplitTransactionSplitDetails {
            let numberPersons = Double(split.count)
            var total = 0.00
            for i in 0...(split.count-1) {
                let row = cell.stackView.arrangedSubviews[(i+1)] as? transactionSplitRow
                let RAM = ((amount ?? 0.00)/numberPersons)/(amount ?? 1.00)
                split[i]?[7] = round((RAM*10000))/10000
                total = total + (split[i]?[7] as? Double ?? 0.00)

                if (i == (split.count-1)) && (total < 1.00) {
                    let difference = abs((amount ?? 0.00)-(amount ?? 0.00)*total)
                    let partOfAmount = ((split[i]?[7] as? Double ?? 0.00) * (amount ?? 0.00))
                    let RAM = difference + partOfAmount
                    row?.amountTextField.text = numberFormatter.string(from: NSNumber(value: RAM))
                } else {
                    row?.amountTextField.text = numberFormatter.string(from: NSNumber(value: ((split[i]?[7] as? Double ?? 0.00) * (amount ?? 0.00))))
                }
            }
        }
        
        leftTopLabelText = ""
        return leftTopLabelText ?? ""
    }
    
    func updateAmount() -> String {
        var leftTopLabelText:String?
        var total = 0.00
        
        if let cell = splitTransactionTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSplitTransactionSplitDetails {
            for i in 0...(split.count-1) {
                let row = cell.stackView.arrangedSubviews[(i+1)] as? transactionSplitRow
                
                let inputAmount = numberFormatter.number(from: row?.amountTextField.text ?? "0.00")?.doubleValue ?? 0.00
                split[i]?[7] = (inputAmount / (amount ?? 1.00))
                
                total = total + ((split[i]?[7] as? Double ?? 0.00)*(amount ?? 0.00))
            }
        }
        
        var diff = ((amountSplit ?? 0.00) - total).roundTo(places: 2)

        if diff < 0.00 {
            diff = (-1)*diff
            if diff < 0.01 {
                diff = 0.01
            }
            leftTopLabelText = NSLocalizedString("tooMuchText", comment: "too Much Text") + (getSymbol(forCurrencyCode: currencyCodeSet) ?? "€") + (numberFormatter.string(from: NSNumber(value: diff)) ?? "0.00")
            buttonDisabledFlag = true
        } else if diff == 0.00 {
            leftTopLabelText = ""
            buttonDisabledFlag = false
        } else {
            if diff < 0.01 {
                diff = 0.00
                leftTopLabelText = ""
                buttonDisabledFlag = false
            } else {
                leftTopLabelText = NSLocalizedString("missingText", comment: "Missing Text") + (getSymbol(forCurrencyCode: currencyCodeSet) ?? "€") + (numberFormatter.string(from: NSNumber(value: diff)) ?? "0.00")
                buttonDisabledFlag = true
            }
        }
        
        return leftTopLabelText ?? ""
    }
    
    // MARK: -HELPER FUNCTIONS
    func getSymbol(forCurrencyCode code: String) -> String? {
        let locale = NSLocale(localeIdentifier: code)
        if locale.displayName(forKey: .currencySymbol, value: code) == code {
            let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: code)
        }
        return locale.displayName(forKey: .currencySymbol, value: code)
    }
    
    // MARK: Keyboard on Appear
    @objc func keyboardWillShow(notification:NSNotification) {

        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = splitTransactionTableView.contentInset
        contentInset.bottom = keyboardFrame.size.height - 100
        splitTransactionTableView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {
        splitTransactionTableView.contentInset = UIEdgeInsets(
            top: 85,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 40,
            right: 0
        )
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
extension splitTransactionTVC {
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

extension splitTransactionTVC: cellSplitTransactionSplitTypeDelegate {
    func segmentChanged(selected: Int) {
        selectedSplitType = selected
        
        if let cell = splitTransactionTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSplitTransactionSplitDetails {
            buttonDisabledFlag = false
            cell.topLabelLeft.textColor = .secondaryLabel
            switch selected {
            case 1:
                let text = setPercent()
                if text.count == 0 {
                    cell.topLabelLeft.isHidden = true
                } else {
                    cell.topLabelLeft.isHidden = false
                }
                cell.topLabelLeft.text = text
                cell.topLabel.text = NSLocalizedString("segmentSplitPercent", comment: "Segment Percent Text")
                break
            case 2:
                let text = setAmount()
                if text.count == 0 {
                    cell.topLabelLeft.isHidden = true
                } else {
                    cell.topLabelLeft.isHidden = false
                }
                cell.topLabelLeft.text = text
                cell.topLabel.text = getSymbol(forCurrencyCode: currencyCodeSet)
                break
            default:
                cell.topLabelLeft.text = setAmount()
                cell.topLabelLeft.isHidden = true
                cell.topLabel.text = getSymbol(forCurrencyCode: currencyCodeSet)
                break
            }
        }
    }
}

extension splitTransactionTVC: transactionSplitRowDelegate {
    func textFieldChanged(text: String, tag: Int) {
        if let cell = splitTransactionTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSplitTransactionSplitDetails {
            cell.topLabelLeft.textColor = .secondaryLabel
        }
        switch selectedSplitType {
        case 1:
            if let cell = splitTransactionTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSplitTransactionSplitDetails {
                let text = updatePercent()
                if text.count == 0 {
                    cell.topLabelLeft.isHidden = true
                } else {
                    cell.topLabelLeft.isHidden = false
                }
                cell.topLabelLeft.text = text
            }
            break
        case 2:
            if let cell = splitTransactionTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSplitTransactionSplitDetails {
                let text = updateAmount()
                if text.count == 0 {
                    cell.topLabelLeft.isHidden = true
                } else {
                    cell.topLabelLeft.isHidden = false
                }
                cell.topLabelLeft.text = text
            }
            break
        default:
            if selectedSplitType == 0 {
                selectedSplitType = 2
                if tableView.dequeueReusableCell(withIdentifier: "cellSplitTransactionSplitType", for: IndexPath(row: 0, section: 0)) is cellSplitTransactionSplitType {
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name("selectIndexSplitTransaction"), object: nil, userInfo: ["index": 2])
                    if let cell = splitTransactionTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSplitTransactionSplitDetails {
                        cell.topLabelLeft.isHidden = false
                    }
                }
            }
            if let cell = splitTransactionTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSplitTransactionSplitDetails {
                let text = updateAmount()
                if text.count == 0 {
                    cell.topLabelLeft.isHidden = true
                } else {
                    cell.topLabelLeft.isHidden = false
                }
                cell.topLabelLeft.text = text
            }
            break
        }
        
    }
}

extension splitTransactionTVC: cellSplitTransactionSplitAddButtonDelegate {
    func addPressed() {
        if !buttonDisabledFlag {
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("splitChanged"), object: nil, userInfo: nil)
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            if let cell = splitTransactionTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSplitTransactionSplitDetails {
                cell.topLabelLeft.textColor = .red
            }
        }
    }
}

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
