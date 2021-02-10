//
//  splitAddNewTVC.swift
//  FIN
//
//  Created by Florian Riel on 27.09.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

var selection = selectedSegement
var selectedDict = [Int:[Int:Any]]()

class splitAddNewTVC: UITableViewController {

    @IBOutlet var splitAddTableView: UITableView!
    
    var viewDisappear = false
    var labelText:String?
    var selectedDictText:String?
    
    var inputText = "" // Input Text from Textfield for save
    var color: Int16?
    
    var update:Int?
    var updateGroupOrPersonName:String?
    var updateCreateDate:Date?
    
    var editUser:Bool = false
    
    var postedchangeHeaderTitleNotification:Bool = false
    var postedgroupPersonAddedNotification:Bool = false
    
    var textfieldText:String?
    
    let dateFormatter = ISO8601DateFormatter()
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    let headerHeightFactor = CGFloat(0.10)
    var navTitle = NSLocalizedString("bottomAddNewGroup", comment: "Add New Group Text")
    
    var splitAddBottomBar:splitAddBottomBar = {
        let nib = UINib(nibName: "splitAddBottomBar", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! splitAddBottomBar
    }()
    var widthAnchorConstraintBottomBar: NSLayoutConstraint?
    var bottomAnchorConstraintBottomBar: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // DataCheck
        checkDoubleUser()
        
        checkIfUpdate()
        
        self.title = ""
        
        editUser = isUser(createDate: (updateCreateDate ?? Date()), namePerson: (updateGroupOrPersonName ?? ""))
        
        if selection == 1 {
            navTitle = NSLocalizedString("bottomAddNewUser", comment: "Add New User Text")
        } else if selection == 2 {
            navTitle = NSLocalizedString("bottomUpdateGroup", comment: "Edit Group Text")
            if !editUser {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteGroupPressed))
            }
        } else if selection == 3 {
            navTitle = NSLocalizedString("bottomUpdateUser", comment: "Edit User Text")
            if editUser {
                navTitle = navTitle + " [" + NSLocalizedString("youTheUser", comment: "I") + "]"
            } else {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePersonPressed))
            }
        }
        
        loadSelected()
        
        NotificationCenter.default.addObserver(self, selector: #selector(addSegmentChanged(notification:)), name: Notification.Name("addSegmentChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openDetailList), name: Notification.Name("openDetailList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectedDictChanged), name: Notification.Name("selectedDictChanged"), object: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        splitAddTableView.keyboardDismissMode = .onDrag
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        initView()
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
            splitAddTableView.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            splitAddTableView.backgroundColor = .secondarySystemBackground
        }
        initView()
    }
    
    // MARK: -initViewFunctions
    
    func initView() {
        initTableAndHeaderView()
        if selection == 0 || selection == 1 {
            initBottomBar()
        }
    }
    
    func initTableAndHeaderView() {
        splitAddTableView.sectionHeaderHeight = UITableView.automaticDimension
     
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            splitAddTableView.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
        } else {
            splitAddTableView.backgroundColor = .secondarySystemBackground
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
        headerView.scrollView = splitAddTableView
        
        splitAddTableView.backgroundView = UIView()
        splitAddTableView.backgroundView?.addSubview(headerView)
        splitAddTableView.contentInset = UIEdgeInsets(
            top: 85,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 40,
            right: 0
        )
    }
    
    func initBottomBar() {
        splitAddBottomBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(splitAddBottomBar, aboveSubview: splitAddTableView)
        splitAddBottomBar.initView()
        
        initBottomBarSize()
    }
    
    func initBottomBarSize() {
        widthAnchorConstraintBottomBar?.isActive = false
        widthAnchorConstraintBottomBar = splitAddBottomBar.widthAnchor.constraint(equalToConstant: min(view.frame.width, 400))
        widthAnchorConstraintBottomBar?.isActive = true
        
        bottomAnchorConstraintBottomBar?.isActive = false
        bottomAnchorConstraintBottomBar = splitAddBottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        bottomAnchorConstraintBottomBar?.isActive = true
        
        splitAddBottomBar.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 1.0).isActive = true
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
            return getPersonsGroupsListCell(indexPath: indexPath)
        case 2:
            return getUpdateCell(indexPath: indexPath)
        case 3:
            return getAddButtonCell(indexPath: indexPath)
        default:
            return getMainCell(indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        splitAddTableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    // MARK: -GET CELL FUNCTIONS
    func getMainCell(indexPath: IndexPath) -> cellSplitAddNewMain {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitAddNewMain", for: indexPath) as! cellSplitAddNewMain
        
        cell.nameTextField.text = textfieldText ?? ""

        cell.circleLabel.text = labelText
        if color == nil {
            color = Int16(Int.random(in: 0...35))
        }
        
        cell.circleView.backgroundColor = UIColor.randomColor(color: Int(color ?? 0), returnText: false, light: true)
        cell.circleView.layer.borderColor = UIColor.randomColor(color: Int(color ?? 0), returnText: false, light: true).cgColor
        cell.circleLabel.textColor = UIColor.randomColor(color: Int(color ?? 0), returnText: true, light: false)
        cell.delegate = self
        return cell
    }
    
    func getPersonsGroupsListCell(indexPath: IndexPath) -> cellSplitAddNewPersonsGroups {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitAddNewPersonsGroups", for: indexPath) as! cellSplitAddNewPersonsGroups
        switch selection {
        case 1:
            cell.groupPersonTitleLabel.text = NSLocalizedString("groupsTitleText", comment: "Groups Title")
            cell.label.text = selectedDictText//NSLocalizedString("addNewDefaultPersonsText", comment: "Persons Placeholder")
            break
        case 2: // Update Group
            cell.groupPersonTitleLabel.text = NSLocalizedString("personsTitleText", comment: "Groups Title")
            cell.label.text = selectedDictText
            break
        case 3: // Update Person
            cell.groupPersonTitleLabel.text = NSLocalizedString("groupsTitleText", comment: "Groups Title")
            cell.label.text = selectedDictText
            break
        default:
            cell.groupPersonTitleLabel.text = NSLocalizedString("personsTitleText", comment: "Groups Title")
            cell.label.text = selectedDictText//NSLocalizedString("addNewDefaultGroupsText", comment: "Groups Placeholder")
            break
        }
        return cell
    }
    
    func getUpdateCell(indexPath: IndexPath) -> cellSplitAddNewSelect {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitAddNewSelect", for: indexPath) as! cellSplitAddNewSelect
        switch selection {
        case 1:
            cell.updateButtom.setTitle(NSLocalizedString("addNewGroupText", comment: "Add New Group Text"), for: .normal)
            break
        case 2:
            cell.updateButtom.setTitle(NSLocalizedString("updatePersonsText", comment: "Update Persons Text"), for: .normal)
            break
        case 3:
            cell.updateButtom.setTitle(NSLocalizedString("updateGroupsText", comment: "Update Groups Text"), for: .normal)
            break
        default:
            cell.updateButtom.setTitle(NSLocalizedString("addNewPersonText", comment: "Add New Person Text"), for: .normal)
            break
        }
        return cell
    }
    
    func getAddButtonCell(indexPath: IndexPath) -> cellSplitAddNewAdd {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitAddNewAdd", for: indexPath) as! cellSplitAddNewAdd
        
        switch selection {
        case 1:
            cell.addButton.setTitle(NSLocalizedString("addAddButtonText", comment: "Add New Text"), for: .normal)
            break
        case 2,3:
            cell.addButton.setTitle(NSLocalizedString("updateAddButtonText", comment: "Update Text"), for: .normal)
            break
        default:
            cell.addButton.setTitle(NSLocalizedString("addAddButtonText", comment: "Add New Text"), for: .normal)
            break
        }
        
        cell.delegate = self
        return cell
    }
    
    // MARK: -FUNCTIONS
    func checkIfUpdate() {
        if update != nil {
            let updateCreateDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: updateCreateDate ?? Date())!
            let updateCreateDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: updateCreateDate ?? Date())!
            
            if update == 0 {
                selection = 2
                let query = NSPredicate(format: "createDate > %@ AND createDate < %@ AND nameGroup == %@", (updateCreateDateMinus as NSDate), (updateCreateDatePlus as NSDate), ((updateGroupOrPersonName ?? "") as NSString))
                color = loadQueriedAttribute(entitie: "SplitGroups", attibute: "color", query: query) as? Int16 ?? 0
            } else {
                selection = 3
                let query = NSPredicate(format: "createDate > %@ AND createDate < %@ AND namePerson == %@", (updateCreateDateMinus as NSDate), (updateCreateDatePlus as NSDate), ((updateGroupOrPersonName ?? "") as NSString))
                color = loadQueriedAttribute(entitie: "SplitPersons", attibute: "color", query: query) as? Int16 ?? 0
            }
            
            textfieldText = updateGroupOrPersonName
            inputText = updateGroupOrPersonName ?? ""
            if textfieldText?.count == 0 || textfieldText == nil {
                labelText = ""
            } else if textfieldText?.count == 1 {
                labelText = textfieldText?.prefix(1).uppercased()
            } else {
                labelText = textfieldText?.prefix(2).uppercased()
            }
        } else {
            selection = selectedSegement
            if selection == 0 || selection == 2 {
                labelText = NSLocalizedString("bottomAddSegmentGroups", comment: "Group Label Text").prefix(2).uppercased()
            } else {
                labelText = NSLocalizedString("bottomAddSegmentUsers", comment: "User Label Text").prefix(2).uppercased()
            }
        }
    }
    
    func loadSelected() {
        selectedDict.removeAll()
        let userSort = NSSortDescriptor(key: "isUser", ascending: false)
        let dateSort = NSSortDescriptor(key: "createDate", ascending: false)
        var entity: String?
        var entity2:String?
        var attribute: String?
        switch selection {
        case 1:
            entity = "SplitGroups"
            attribute = "nameGroup"
            break
        case 2:
            entity = "SplitGroups"
            entity2 = "SplitPersons"
            attribute = "namePerson"
            break
        case 3:
            entity = "SplitPersons"
            entity2 = "SplitGroups"
            attribute = "nameGroup"
            break
        default:
            entity = "SplitPersons"
            attribute = "namePerson"
            break
        }
        if selection == 2 || selection == 3 { // Update
            if selection == 2 { // Update Group
                var persons = [Int:[Int:Any]]()
                var j = 0
                
                let updateCreateDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: updateCreateDate ?? Date())!
                let updateCreateDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: updateCreateDate ?? Date())!
                
                let query = NSPredicate(format: "nameGroup == %@ AND createDate < %@ AND createDate > %@", ((updateGroupOrPersonName ?? "") as NSString), (updateCreateDatePlus as NSDate), (updateCreateDateMinus as NSDate))
                if let personsInGroup = loadQueriedAttributeSorted(entitie: entity ?? "SplitGroups", attibute: "persons", query: query, sort: [dateSort]) as? String {
                    for data in personsInGroup.components(separatedBy: "*;*") {
                        let RAM = data.components(separatedBy: "*&*")
                        if RAM.count == 2 {
                            persons[j] = [
                                0:RAM[0],
                                1:dateFormatter.date(from: RAM[1]) ?? Date()
                            ]
                        }
                        j = j + 1
                    }
                }
                var i = 0
                for data in loadBulkSorted(entitie: entity2 ?? "SplitPersons", sort: [userSort,dateSort]) {
                    var isSelected = false
                    for (_,value) in persons.enumerated() {
                        let createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: (value.value[1] as? Date ?? Date()))!
                        let createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: (value.value[1] as? Date ?? Date()))!

                        let up = (data.value(forKey: "createDate") as? Date ?? Date()).compare(createDatePersonPlus) == .orderedAscending
                        let down = (data.value(forKey: "createDate") as? Date ?? Date()).compare(createDatePersonMinus) == .orderedDescending
                        
                        if up && down && (value.value[0] as? String ?? "-" == (data.value(forKey: attribute ?? "") as? String ?? "")) {
                            isSelected = true
                            break
                        }
                    }

                    selectedDict[i] = [
                        0:(data.value(forKey: "createDate") as? Date ?? Date()),
                        1:(data.value(forKey: "namePerson") as? String ?? ""),
                        2:(data.value(forKey: "color") as? Int16 ?? 0),
                        3:isSelected
                    ]
                    i = i + 1
                }
            } else { // Update Person
                var i = 0
                
                let createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: updateCreateDate ?? Date())!
                let createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: updateCreateDate ?? Date())!
                
                for data in loadBulkSorted(entitie: "SplitGroups", sort: [dateSort]) {
                    var isSelected:Bool = false

                    let persons = (data.value(forKey: "persons") as? String ?? "-")
                    
                    if persons.contains(updateGroupOrPersonName ?? ".") {
                        for data in persons.components(separatedBy: "*;*") {
                            if data.contains(updateGroupOrPersonName ?? ".") {
                                let RAM = data.components(separatedBy: "*&*")
                                if RAM.count == 2 {
                                    let up = (dateFormatter.date(from: RAM[1]))?.compare(createDatePersonPlus) == .orderedAscending
                                    let down = (dateFormatter.date(from: RAM[1]))?.compare(createDatePersonMinus) == .orderedDescending
                                    
                                    if up && down {
                                        isSelected = true
                                    }
                                }
                            }
                        }
                    }

                    selectedDict[i] = [
                        0:(data.value(forKey: "createDate") as? Date ?? Date()),
                        1:(data.value(forKey: "nameGroup") as? String ?? ""),
                        2:(data.value(forKey: "color") as? Int16 ?? 0),
                        3:isSelected
                    ]
                    i = i + 1
                }
            }
        } else { // New
            var i = 0
            
            if selection == 0 {
                for data in loadBulkSorted(entitie: entity ?? "SplitPersons", sort: [userSort,dateSort]) {
                    
                    let user = isUser(createDate: (data.value(forKey: "createDate") as? Date ?? Date()), namePerson: (data.value(forKey: "namePerson") as? String ?? ""))
                    
                    selectedDict[i] = [
                        0:(data.value(forKey: "createDate") as? Date ?? Date()),
                        1:(data.value(forKey: "namePerson") as? String ?? ""),
                        2:(data.value(forKey: "color") as? Int16 ?? 0),
                        3:user
                    ]
                    i = i + 1
                }
            } else {
                for data in loadBulkSorted(entitie: entity ?? "SplitGroups", sort: [dateSort]) {
                    selectedDict[i] = [
                        0:(data.value(forKey: "createDate") as? Date ?? Date()),
                        1:(data.value(forKey: attribute ?? "") as? String ?? ""),
                        2:(data.value(forKey: "color") as? Int16 ?? 0),
                        3:false
                    ]
                    i = i + 1
                }
            }
        }
        selectedDictChanged()
    }
    
    func updateButtons() {
        if splitAddTableView.cellForRow(at: IndexPath(row: 1, section: 0)) != nil {
            let cellPersonsGroups = splitAddTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! cellSplitAddNewPersonsGroups
            switch selection {
            case 1:
                cellPersonsGroups.groupPersonTitleLabel.text = NSLocalizedString("groupsTitleText", comment: "Groups Title")
                cellPersonsGroups.label.text = NSLocalizedString("addNewDefaultPersonsText", comment: "Persons Placeholder")
            default:
                cellPersonsGroups.groupPersonTitleLabel.text = NSLocalizedString("personsTitleText", comment: "Groups Title")
                cellPersonsGroups.label.text = NSLocalizedString("addNewDefaultGroupsText", comment: "Groups Placeholder")
            }
        }
        if splitAddTableView.cellForRow(at: IndexPath(row: 2, section: 0)) != nil {
            let cellUpdateButton = splitAddTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! cellSplitAddNewSelect
            switch selection {
            case 1:
                cellUpdateButton.updateButtom.setTitle(NSLocalizedString("addNewGroupText", comment: "Add New Group Text"), for: .normal)
                break
            case 2:
                cellUpdateButton.updateButtom.setTitle(NSLocalizedString("updatePersonsText", comment: "Update Persons Text"), for: .normal)
                break
            case 3:
                cellUpdateButton.updateButtom.setTitle(NSLocalizedString("updateGroupsText", comment: "Update Groups Text"), for: .normal)
                break
            default:
                cellUpdateButton.updateButtom.setTitle(NSLocalizedString("addNewPersonText", comment: "Add New Person Text"), for: .normal)
                break
            }
        }
    }
    
    func createPersonsForGroup() -> String {
        let dateFormatter = ISO8601DateFormatter()
        var persons = ""
        if (selection == 0 || selection == 2) && selectedDict.count > 0 {
            for (_,value) in selectedDict.enumerated() {
                if value.value[3] as? Bool ?? false {
                    if persons.count != 0 && (value.value[1] as? String ?? "" != "") {
                        persons = persons + "*;*" + (value.value[1] as? String ?? "") + "*&*" + dateFormatter.string(from: (value.value[0] as? Date ?? Date()))
                    } else {
                        persons = (value.value[1] as? String ?? "") + "*&*" + (dateFormatter.string(from: (value.value[0] as? Date ?? Date())))
                    }
                    
                }
            }
        }
        return persons
    }
    
    func updateGroupsIfAny() {
        let dateFormatter = ISO8601DateFormatter()
        if selection == 1 && selectedDict.count > 0 {
            for i in 0...(selectedDict.count-1) {
                if selectedDict[i]?[3] as? Bool ?? false {
                    let datePlus = Calendar.current.date(byAdding: .second, value: 1, to: (selectedDict[i]?[0] as? Date ?? Date()))!
                    let dateMinus = Calendar.current.date(byAdding: .second, value: -1, to: (selectedDict[i]?[0] as? Date ?? Date()))!
                    
                    let query = NSPredicate(format: "createDate < %@ AND createDate > %@ AND nameGroup == %@", (datePlus as NSDate), (dateMinus as NSDate), ((selectedDict[i]?[1] as? String ?? "") as NSString))
                    for groups in loadBulkQueried(entitie: "SplitGroups", query: query) {
                        // PersonName & CreateDate
                        if isInputtextValid() {
                            var newPersons = groups.value(forKey: "persons") as? String ?? ""
                            if newPersons.count > 1 {
                                newPersons = newPersons + "*;*" + inputText + "*&*" + dateFormatter.string(from: Date())
                            } else {
                                newPersons = inputText + "*&*" + dateFormatter.string(from: Date())
                            }
                            saveSingleDataString(entity: "SplitGroups", attibute: "persons", newValue: newPersons, query: query)
                        }
                    }
                }
            }
        }
    }
    
    func isInputtextValid() -> Bool {
        if inputText.contains("*;*") || inputText.contains("*&*") {
            let answerError = UIAlertController(title: NSLocalizedString("Input *;* Error Title", comment: "Input *;* Error Title"), message: NSLocalizedString("Input *;* Error Text", comment: "Input *;* Error Text"), preferredStyle: .alert)
            answerError.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "forgotCodeOK"), style: .cancel, handler: nil))
            answerError.popoverPresentationController?.sourceView = self.view
            answerError.popoverPresentationController?.sourceRect = self.view.bounds
            self.present(answerError, animated: true)
        } else if inputText != "" {
            return true
        }
        return false
    }
    
    @objc func selectedDictChanged() {
        selectedDictText?.removeAll()
        if selectedDict.count > 0 {
            for i in 0...(selectedDict.count-1) {
                if (selectedDict[i]?[3] as? Bool ?? false) == true {
                    if selectedDictText?.count == 0 || selectedDictText == nil {
                        selectedDictText = (selectedDict[i]?[1] as? String ?? "")
                    } else {
                        selectedDictText = (selectedDictText ?? "") + ", " + (selectedDict[i]?[1] as? String ?? "")
                    }
                }
            }
        }
        if selectedDictText?.count == 0 || selectedDictText == nil {
            if selection == 0 || selection == 2 {
                selectedDictText = NSLocalizedString("addNewDefaultGroupsText", comment: "Groups Placeholder")
            } else {
                selectedDictText = NSLocalizedString("addNewDefaultPersonsText", comment: "Persons Placeholder")
            }
        }
        if let cell = splitAddTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSplitAddNewPersonsGroups {
            cell.label.text = selectedDictText
            cell.label.layoutIfNeeded()
        }
    }
    
    @objc func addSegmentChanged(notification: Notification) {
        if let userInfo = notification.userInfo, let selectedAddSegment = userInfo["selectedSegment"] as? Int {
            switch selectedAddSegment {
            case 1:
                navTitle = NSLocalizedString("bottomAddNewUser", comment: "Add New User Text")
                break
            default:
                navTitle = NSLocalizedString("bottomAddNewGroup", comment: "Add New Group Text")
                break
            }
            selection = selectedAddSegment
            updateButtons()
            headerView.headerLabel.text = navTitle
            loadSelected()
        }
    }
    
    @objc func cancel() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func openDetailList() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "groupsPersonsList", sender: nil)
        }
    }
    
    @objc func deleteGroupPressed() {
        let alert = UIAlertController(title: NSLocalizedString("deleteTitleGroupSplit", comment: "Delete Group Title"), message: NSLocalizedString("deleteTextGroupSplit", comment: "Delete Person Text"), preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("deleteYes", comment: "Delete Yes"), style: .destructive, handler: { action in
            self.deleteGroup()
            reloadListView = true
            reloadFinView = true
            reloadGraphView = true
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("deleteNo", comment: "Delete No"), style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        self.present(alert, animated: true)
    }
    
    func deleteGroup() {
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
        
        var nameUser:String?
        var createDateUser:Date?
        
        for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
        
        let userDateUserPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        let userDateUserMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
        
        let createGroupPlus = Calendar.current.date(byAdding: .second, value: 1, to: (updateCreateDate ?? Date()))!
        let createGroupMinus = Calendar.current.date(byAdding: .second, value: -1, to: (updateCreateDate ?? Date()))!
        
        let querySplitsUpdateTransactions = NSPredicate(format: "nameGroup == %@ AND createDateGroup < %@ AND createDateGroup > %@ AND namePerson == %@ AND createDatePerson < %@ AND createDatePerson > %@", ((updateGroupOrPersonName ?? "") as NSString), (createGroupPlus as NSDate), (createGroupMinus as NSDate), ((nameUser ?? "") as NSString), (userDateUserPlus as NSDate), (userDateUserMinus as NSDate))
        
        for split in loadBulkQueried(entitie: "Splits", query: querySplitsUpdateTransactions) {
            var amount:Double?
            let ratio = split.value(forKey: "ratio") as? Double ?? 0.00
            
            let transactionDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
            let transactionDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
            
            let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", (transactionDatePlus as NSDate), (transactionDateMinus as NSDate))
            
            for transaction in loadBulkQueried(entitie: "Transactions", query: queryTransaction) {
                amount = transaction.value(forKey: "amount") as? Double ?? 0.00
            }
            
            saveSingleDataDouble(entity: "Transactions", attibute: "amount", newValue: ((amount ?? 0.00)*ratio), query: queryTransaction)
        }
        
        let querySplitDelete = NSPredicate(format: "nameGroup == %@ AND createDateGroup < %@ AND createDateGroup > %@", ((updateGroupOrPersonName ?? "") as NSString), (createGroupPlus as NSDate), (createGroupMinus as NSDate))
        deleteData(entity: "Splits", query: querySplitDelete)
        deleteData(entity: "SplitsRegularPayments", query: querySplitDelete)
        
        let querySplitGroupsDelete = NSPredicate(format: "nameGroup == %@ AND createDate < %@ AND createDate > %@", ((updateGroupOrPersonName ?? "") as NSString), (createGroupPlus as NSDate), (createGroupMinus as NSDate))
        deleteData(entity: "SplitGroups", query: querySplitGroupsDelete)
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("groupPersonUpdated"), object: nil)
        nc.post(name: Notification.Name("groupPersonDeleted"), object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func deletePersonPressed() {
        let alert = UIAlertController(title: NSLocalizedString("deleteTitlePersonSplit", comment: "Delete Person Title"), message: NSLocalizedString("deleteTextPersonSplit", comment: "Delete Person Text"), preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("deleteYes", comment: "Delete Yes"), style: .destructive, handler: { action in
            self.deletePersonFromRegularPayment()
            self.deletePerson()
            reloadListView = true
            reloadFinView = true
            reloadGraphView = true
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("deleteNo", comment: "Delete No"), style: .cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        self.present(alert, animated: true)
    }
    
    func deletePersonFromRegularPayment() {
        let createPersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: (updateCreateDate ?? Date()))!
        let createPersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: (updateCreateDate ?? Date()))!
        
        let queryRegularSplitsUpdateTransactions = NSPredicate(format: "namePerson == %@ AND createDatePerson < %@ AND createDatePerson > %@", ((updateGroupOrPersonName ?? "") as NSString), (createPersonPlus as NSDate), (createPersonMinus as NSDate))
        
        for split in loadBulkQueried(entitie: "SplitsRegularPayments", query: queryRegularSplitsUpdateTransactions) {
            let splitDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
            let splitDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
            
            let queryNumberSplits = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", splitDatePlus as NSDate, splitDateMinus as NSDate)
            // If more than 2 Persons (so, User & the Person to be deleted) are part of a Split, then the Split of the Person to be deleted is distributed among the others and deleted. If only the User & Person to be deleted are part of a Split, it is transformed to a Transaction without a split and the splits are deleted.
            let countPeople = loadBulkQueried(entitie: "SplitsRegularPayments", query: queryNumberSplits).count
            if countPeople > 2 {
                let toBeDistributedRatio = (split.value(forKey: "ratio") as? Double ?? 0.00) / Double(countPeople-1)
                
                for splitUpdate in loadBulkQueried(entitie: "SplitsRegularPayments", query: queryNumberSplits) {
                    let splitDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "createDatePerson") as? Date ?? Date()))!
                    let splitDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "createDatePerson") as? Date ?? Date()))!
                    
                    let queryPerson = NSPredicate(format: "namePerson == %@ AND createDatePerson < %@ AND createDatePerson > %@ AND dateTimeTransaction < %@ AND dateTimeTransaction > %@", (split.value(forKey: "namePerson") as? String ?? "") as NSString, splitDatePersonPlus as NSDate, splitDatePersonMinus as NSDate, splitDatePlus as NSDate, splitDateMinus as NSDate)
                    
                    let up = (updateCreateDate ?? Date()).compare(splitDatePersonPlus) == .orderedAscending
                    let down = (updateCreateDate ?? Date()).compare(splitDatePersonMinus) == .orderedDescending
                    
                    if up && down && ((updateGroupOrPersonName ?? "") == (splitUpdate.value(forKey: "namePerson") as? String ?? "")) {
                        deleteData(entity: "SplitsRegularPayments", query: queryPerson)
                    } else {
                        saveSingleDataDouble(entity: "SplitsRegularPayments", attibute: "ratio", newValue: ((splitUpdate.value(forKey: "ratio") as? Double ?? 0.00) + toBeDistributedRatio), query: queryPerson)
                    }
                }
            } else {
                var amount:Double?
                let ratio = getUserRatio(dateTimeTransaction: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()), repeatedTransaction: true)
                var exchangeRate:Double?
                
                let transactionDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                let transactionDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                
                let queryTransaction = NSPredicate(format: "dateTimeNext < %@ AND dateTimeNext > %@", (transactionDatePlus as NSDate), (transactionDateMinus as NSDate))
                
                for transaction in loadBulkQueried(entitie: "RegularPayments", query: queryTransaction) {
                    amount = transaction.value(forKey: "amount") as? Double ?? 0.00
                    exchangeRate = transaction.value(forKey: "exchangeRate") as? Double ?? 1.00
                }
                
                saveSingleDataDouble(entity: "RegularPayments", attibute: "amount", newValue: ((amount ?? 0.00)*ratio), query: queryTransaction)
                saveSingleDataDouble(entity: "RegularPayments", attibute: "realAmount", newValue: ((amount ?? 0.00)*ratio)/(exchangeRate ?? 1.00), query: queryTransaction)
                saveSingleDataInt(entity: "RegularPayments", attibute: "isSplit", newValue: 0, query: queryTransaction)
                
                deleteData(entity: "SplitsRegularPayments", query: queryNumberSplits)
            }
        }
    }
    
    func deletePerson() {
        let createPersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: (updateCreateDate ?? Date()))!
        let createPersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: (updateCreateDate ?? Date()))!
        
        let querySplitsUpdateTransactions = NSPredicate(format: "namePerson == %@ AND createDatePerson < %@ AND createDatePerson > %@", ((updateGroupOrPersonName ?? "") as NSString), (createPersonPlus as NSDate), (createPersonMinus as NSDate))
        
        for split in loadBulkQueried(entitie: "Splits", query: querySplitsUpdateTransactions) {
            let splitDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
            let splitDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
            
            let queryNumberSplits = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@", splitDatePlus as NSDate, splitDateMinus as NSDate)
            // If more than 2 Persons (so, User & the Person to be deleted) are part of a Split, then the Split of the Person to be deleted is set to settled = 100%, but not deleted (since the other splits are still open). If only the User & Person to be deleted are part of a Split, it is transformed to a Transaction without a split and the splits are deleted.
            if loadBulkQueried(entitie: "Splits", query: queryNumberSplits).count > 2 {
                let transactionDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                let transactionDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                
                let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", (transactionDatePlus as NSDate), (transactionDateMinus as NSDate))
                
                let amountTransaction = loadQueriedAttribute(entitie: "Transactions", attibute: "amount", query: queryTransaction) as? Double ?? 0.00
                let exRateTransaction = loadQueriedAttribute(entitie: "Transactions", attibute: "exchangeRate", query: queryTransaction) as? Double ?? 1.00
                
                let querySplitSettle = NSPredicate(format: "namePerson == %@ AND createDatePerson < %@ AND createDatePerson > %@ AND dateTimeTransaction == %@", ((updateGroupOrPersonName ?? "") as NSString), (createPersonPlus as NSDate), (createPersonMinus as NSDate), (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()) as NSDate)
                saveSingleDataDouble(entity: "Splits", attibute: "settled", newValue: (amountTransaction * (split.value(forKey: "ration") as? Double ?? 0.00))/exRateTransaction, query: querySplitSettle)
            } else {
                var amount:Double?
                let ratio = getUserRatio(dateTimeTransaction: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()), repeatedTransaction: false)
                var exchangeRate:Double?
                
                let transactionDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                let transactionDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                
                let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", (transactionDatePlus as NSDate), (transactionDateMinus as NSDate))
                
                for transaction in loadBulkQueried(entitie: "Transactions", query: queryTransaction) {
                    amount = transaction.value(forKey: "amount") as? Double ?? 0.00
                    exchangeRate = transaction.value(forKey: "exchangeRate") as? Double ?? 1.00
                }
                
                saveSingleDataDouble(entity: "Transactions", attibute: "amount", newValue: ((amount ?? 0.00)*ratio), query: queryTransaction)
                saveSingleDataDouble(entity: "Transactions", attibute: "realAmount", newValue: ((amount ?? 0.00)*ratio)/(exchangeRate ?? 1.00), query: queryTransaction)
                saveSingleDataInt(entity: "Transactions", attibute: "isSplit", newValue: 0, query: queryTransaction)
                
                let queryDeleteSplit = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", transactionDatePlus as NSDate, transactionDateMinus as NSDate)
                deleteData(entity: "Splits", query: queryDeleteSplit)
            }
        }
        
        // Remove Person from Groups
        var persons = [Int:[Int:Any]]()
        
        for groups in loadBulkData(entitie: "SplitGroups", orderBy: "nameGroup") {
            persons.removeAll()
            
            var newPersons:String?
            
            var j = 0
            for data in (groups.value(forKey: "persons") as? String ?? "").components(separatedBy: "*;*") {
                newPersons?.removeAll()
                let RAM = data.components(separatedBy: "*&*")
                if RAM.count == 2 {
                    let up = (dateFormatter.date(from: RAM[1]) ?? Date()).compare(createPersonPlus) == .orderedAscending
                    let down = (dateFormatter.date(from: RAM[1]) ?? Date()).compare(createPersonMinus) == .orderedDescending
                    
                    if !(up && down && (RAM[0] == (updateGroupOrPersonName ?? ""))) {
                        persons[j] = [
                            0:RAM[0],
                            1:RAM[1]
                        ]
                        j = j + 1
                    }
                }
                if persons.count > 0 {
                    for i in 0...(persons.count-1) {
                        if i == (persons.count-1) {
                            let str = (persons[i]?[0] as? String ?? "") + "*&*" + (persons[i]?[1] as? String ?? "")
                            newPersons = (newPersons ?? "") + str
                        } else {
                            let str = (persons[i]?[0] as? String ?? "") + "*&*" + (persons[i]?[1] as? String ?? "") + "*;*"
                            newPersons = (newPersons ?? "") + str
                        }
                    }
                }
                
                let groupName = (groups.value(forKey: "nameGroup") as? String ?? "")
                let groupDate = (groups.value(forKey: "createDate") as? Date ?? Date())
                
                let groupDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: groupDate)!
                let groupDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: groupDate)!
                
                let query = NSPredicate(format: "nameGroup == %@ AND createDate < %@ AND createDate > %@", (groupName as NSString), (groupDatePlus as NSDate), (groupDateMinus as NSDate))
                saveSingleDataString(entity: "SplitGroups", attibute: "persons", newValue: (newPersons ?? ""), query: query)
            }
        }
        
        // Remove Person from SplitPersons
        let queryDeletePerson = NSPredicate(format: "namePerson == %@ AND createDate < %@ AND createDate > %@", ((updateGroupOrPersonName ?? "") as NSString), (createPersonPlus as NSDate), (createPersonMinus as NSDate))
        deleteData(entity: "SplitPersons", query: queryDeletePerson)
        
        // Dismiss View & Update others
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("groupPersonUpdated"), object: nil)
        nc.post(name: Notification.Name("groupPersonDeleted"), object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func saveRealAmount(transactionDate:Date, repeatedTransaction:Bool, removedSplit: Bool) {
        var realAmount:Double?
        
        let dateTimeTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: transactionDate)!
        let dateTimeTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: transactionDate)!
        
        if !repeatedTransaction {
            let queryTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", dateTimeTransactionPlus as NSDate, dateTimeTransactionMinus as NSDate)
            
            let amount = loadQueriedAttribute(entitie: "Transactions", attibute: "amount", query: queryTransaction) as? Double ?? 0.00
            let exchangeRate = loadQueriedAttribute(entitie: "Transactions", attibute: "exchangeRate", query: queryTransaction) as? Double ?? 1.00
            
            var isSplit = loadQueriedAttribute(entitie: "Transactions", attibute: "isSplit", query: queryTransaction) as? Int16 ?? 0
            if removedSplit {
                isSplit = 0
            }
            
            if isSplit > 0 {
                
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
                
                let datePlus = Calendar.current.date(byAdding: .second, value: 1, to: transactionDate)!
                let dateMinus = Calendar.current.date(byAdding: .second, value: -1, to: transactionDate)!

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
            saveQueriedAttribute(entity: "Transactions", attribute: "realAmount", query: queryTransaction, value: realAmount ?? 0.00)
        } else {
            let queryTransaction = NSPredicate(format: "dateTimeNext < %@ AND dateTimeNext > %@", dateTimeTransactionPlus as NSDate, dateTimeTransactionMinus as NSDate)
            
            let amount = loadQueriedAttribute(entitie: "RegularPayments", attibute: "amount", query: queryTransaction) as? Double ?? 0.00
            let exchangeRate = loadQueriedAttribute(entitie: "RegularPayments", attibute: "exchangeRate", query: queryTransaction) as? Double ?? 1.00
            let isSplit = loadQueriedAttribute(entitie: "RegularPayments", attibute: "isSplit", query: queryTransaction) as? Int16 ?? 0
            
            if isSplit > 0 {
                
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
                
                let datePlus = Calendar.current.date(byAdding: .second, value: 1, to: transactionDate)!
                let dateMinus = Calendar.current.date(byAdding: .second, value: -1, to: transactionDate)!

                let query = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePerson == %@ AND createDatePerson > %@ AND createDatePerson < %@", (dateMinus as NSDate), (datePlus as NSDate), ((nameUser ?? "") as NSString), ((userDateMinus) as NSDate), ((userDatePlus) as NSDate))
                
                var paidByUser:Bool?
                var settledUser:Double?
                
                for dataUser in loadBulkQueriedSorted(entitie: "SplitsRegularPayments", query: query, sort: [nameSort]) {
                    settledUser = (dataUser.value(forKey: "settled") as? Double ?? 0.00)
                    paidByUser = (dataUser.value(forKey: "paidByUser") as? Bool ?? true)
                }
                
                if (paidByUser ?? false) {
                    var settledByOthers:Double = 0.00
                    
                    let queryOthers = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ ", (dateMinus as NSDate), (datePlus as NSDate))
                    
                    for dataOthers in loadBulkQueriedSorted(entitie: "SplitsRegularPayments", query: queryOthers, sort: [nameSort]) {
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
            saveQueriedAttribute(entity: "RegularPayments", attribute: "realAmount", query: queryTransaction, value: realAmount ?? 0.00)
        }
    }
    
    func getUserRatio(dateTimeTransaction:Date, repeatedTransaction:Bool) -> Double {
        let transactionDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTimeTransaction)!
        let transactionDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTimeTransaction)!
        
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
        
        var nameUser:String?
        var createDateUser:Date?
        
        for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
        
        let userDateUserPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        let userDateUserMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
        
        let querySplit = NSPredicate(format: "namePerson == %@ AND createDatePerson < %@ AND createDatePerson > %@ AND dateTimeTransaction < %@ AND dateTimeTransaction > %@", (nameUser ?? "") as NSString, userDateUserPlus as NSDate, userDateUserMinus as NSDate, transactionDatePlus as NSDate, transactionDateMinus as NSDate)
        
        var entity = "Splits"
        if repeatedTransaction {
            entity = "SplitsRegularPayments"
        }
        
        return loadQueriedAttribute(entitie: entity, attibute: "ratio", query: querySplit) as? Double ?? 0.00
    }
    
    func checkDoubleUser() {
        let query = NSPredicate(format: "isUser == %@", NSNumber(value: true))
        let users = loadBulkQueried(entitie: "SplitPersons", query: query)

        if users.count > 1 {
            // Splits
            // SplitsRegularPayments
            // SplitGroups
            var trueUserName:String?
            var trueUserDate:Date?
            for user in loadBulkQueriedSorted(entitie: "SplitPersons", query: query, sort: [NSSortDescriptor(key: "createDate", ascending: true)]) {
                trueUserName = user.value(forKey: "namePerson") as? String ?? ""
                trueUserDate = user.value(forKey: "createDate") as? Date ?? Date()
                break
            }
            saveSettings(settingsChange: "userName", newValue: trueUserName ?? "User")
            for user in loadBulkQueriedSorted(entitie: "SplitPersons", query: query, sort: [NSSortDescriptor(key: "createDate", ascending: false)]) {
                // Splits
                let userWrongPlus = Calendar.current.date(byAdding: .second, value: 1, to: user.value(forKey: "createDate") as? Date ?? Date())!
                let userWrongMinus = Calendar.current.date(byAdding: .second, value: -1, to: user.value(forKey: "createDate") as? Date ?? Date())!
                
                let userWrongName = user.value(forKey: "namePerson") as? String ?? ""
                
                let up = (trueUserDate ?? Date()).compare(userWrongPlus) == .orderedAscending
                let down = (trueUserDate ?? Date()).compare(userWrongMinus) == .orderedDescending
                
                if !(up && down && userWrongName == trueUserName) {
                    let querySplits = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@", userWrongPlus as NSDate, userWrongMinus as NSDate, userWrongName as NSString)
                    
                    if saveQueriedAttributeReturn(entity: "Splits", attribute: "namePerson", query: querySplits, value: trueUserName ?? "User") && saveQueriedAttributeReturn(entity: "Splits", attribute: "createDatePerson", query: querySplits, value: trueUserDate ?? Date()) {
                        
                        let querySplitsPaid = NSPredicate(format: "createDatePersonWhoPaid < %@ AND createDatePersonWhoPaid > %@ AND namePersonWhoPaid == %@", userWrongPlus as NSDate, userWrongMinus as NSDate, userWrongName as NSString)
                        
                        _ = saveQueriedAttributeReturn(entity: "Splits", attribute: "namePersonWhoPaid", query: querySplitsPaid, value: trueUserName ?? "User")
                        _ = saveQueriedAttributeReturn(entity: "Splits", attribute: "createDatePersonWhoPaid", query: querySplitsPaid, value: trueUserDate ?? Date())
                    }
                    // SplitsRegularPayments
                    if saveQueriedAttributeReturn(entity: "SplitsRegularPayments", attribute: "namePerson", query: querySplits, value: trueUserName ?? "User") && saveQueriedAttributeReturn(entity: "SplitsRegularPayments", attribute: "createDatePerson", query: querySplits, value: trueUserDate ?? Date()) {
                        
                        let querySplitsPaid = NSPredicate(format: "createDatePersonWhoPaid < %@ AND createDatePersonWhoPaid > %@ AND namePersonWhoPaid == %@", userWrongPlus as NSDate, userWrongMinus as NSDate, userWrongName as NSString)
                        
                        _ = saveQueriedAttributeReturn(entity: "SplitsRegularPayments", attribute: "namePersonWhoPaid", query: querySplitsPaid, value: trueUserName ?? "User")
                        _ = saveQueriedAttributeReturn(entity: "SplitsRegularPayments", attribute: "createDatePersonWhoPaid", query: querySplitsPaid, value: trueUserDate ?? Date())
                    }
                    
                    // Groups
                    let dateFormatter = ISO8601DateFormatter()
                    
                    let userWrongGroupSting = userWrongName + "*&*" + dateFormatter.string(from: user.value(forKey: "createDate") as? Date ?? Date())
                    let trueUserGroupSting = (trueUserName ?? "User") + "*&*" + dateFormatter.string(from: trueUserDate ?? Date())
                    
                    for group in loadBulkSorted(entitie: "SplitGroups", sort: [NSSortDescriptor(key: "createDate", ascending: false)]) {
                        if (group.value(forKey: "persons") as? String ?? "").contains(userWrongGroupSting) {
                            var stringToReplace = (group.value(forKey: "persons") as? String ?? "")
                            stringToReplace = stringToReplace.replacingOccurrences(of: userWrongGroupSting, with: trueUserGroupSting)
                            
                            let groupWrongPlus = Calendar.current.date(byAdding: .second, value: 1, to: group.value(forKey: "createDate") as? Date ?? Date())!
                            let groupWrongMinus = Calendar.current.date(byAdding: .second, value: -1, to: group.value(forKey: "createDate") as? Date ?? Date())!
                            
                            let queryGroupSave = NSPredicate(format: "createDate < %@ AND createDate > %@ AND nameGroup == %@", groupWrongPlus as NSDate, groupWrongMinus as NSDate, (group.value(forKey: "nameGroup") as? String ?? "") as NSString)
                            
                            _ = saveQueriedAttributeReturn(entity: "SplitGroups", attribute: "persons", query: queryGroupSave, value: stringToReplace)
                        }
                    }
                    let queryWrongUser = NSPredicate(format: "createDate < %@ AND createDate > %@ AND namePerson == %@", userWrongPlus as NSDate, userWrongMinus as NSDate, userWrongName as NSString)
                    deleteData(entity: "SplitPersons", query: queryWrongUser)
                }
            }
            checkDoubleUser()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier ?? "") {
        case "groupsPersonsList":
            guard let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.topViewController as? splitAddNewSelectTVC
            else {
                fatalError()
            }
            if update != nil {
                viewController.update = true
                viewController.updateGroupOrPersonName = updateGroupOrPersonName
                viewController.updateCreateDate = updateCreateDate
            }
            
            break
        default:
            break
        }
    }
}

extension splitAddNewTVC {
    // MARK: -DATA
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
    
    func loadBulkData(entitie:String, orderBy:String) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: orderBy, ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
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
    
    func saveSplitPerson(namePerson: String, isUser: Bool = false, color: Int16) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let personSave = SplitPersons(context: managedContext)
    
        personSave.namePerson = namePerson
        personSave.isUser = isUser
        personSave.color = color
        personSave.createDate = Date()
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveSplitSplitGroup(nameGroup: String, persons: String = "", color: Int16) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let groupSave = SplitGroups(context: managedContext)
        
        groupSave.nameGroup = nameGroup
        groupSave.persons = persons
        groupSave.color = color
        groupSave.createDate = Date()
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
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
            }
        } catch {
            fatalError("Failed to fetch recordings: \(error)")
        }
    }
    
    func saveQueriedAttributeReturn(entity: String, attribute: String, query: NSPredicate ,value: Any) -> Bool {
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
    
    func saveSingleDataString(entity:String, attibute: String, newValue: String, query: NSPredicate) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                if data.value(forKey: attibute) != nil {
                    let managedObject = data
                    managedObject.setValue(newValue, forKey: attibute)
                    try managedContext.save()
                }
            }
        } catch {
            print("ERROR. \(error)")
        }
    }
    
    func saveSingleDataDouble(entity:String, attibute: String, newValue: Double, query: NSPredicate) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query

        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                if data.value(forKey: attibute) != nil {
                    let managedObject = data
                    managedObject.setValue(newValue, forKey: attibute)
                    try managedContext.save()
                }
            }
        } catch {
            print("ERROR. \(error)")
        }
    }
    
    func saveSingleDataInt(entity:String, attibute: String, newValue: Int, query: NSPredicate) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query

        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                if data.value(forKey: attibute) != nil {
                    let managedObject = data
                    managedObject.setValue(newValue, forKey: attibute)
                    try managedContext.save()
                }
            }
        } catch {
            print("ERROR. \(error)")
        }
    }
    
    func saveSettings(settingsChange: String, newValue: Any) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fetchedSettings = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            fetchedSettings[0].setValue(newValue, forKey: settingsChange)

            try managedContext.save()
        } catch {
            fatalError("Failed to fetch recordings: \(error)")
        }
    }
    
    func loadQueriedAttributeSorted(entitie:String, attibute:String, query:NSPredicate, sort:[NSSortDescriptor]) -> Any {
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
    
    func updateSplitGroup(groupName: String, groupCreateDate: Date, personsNew:String, groupNameNew:String?) {
        let createDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: groupCreateDate)!
        let createDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: groupCreateDate)!
        
        let query = NSPredicate(format: "nameGroup == %@ AND createDate > %@ AND createDate < %@", (groupName as NSString), (createDateMinus as NSDate), (createDatePlus as NSDate))
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SplitGroups")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        do {
            let fetchedData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if fetchedData.count > 1 || fetchedData.count <= 0 {
            } else {
                if groupNameNew != nil {
                    fetchedData[0].setValue(groupNameNew, forKey: "nameGroup")
                }
                fetchedData[0].setValue(personsNew, forKey: "persons")
                try managedContext.save()
            }
        } catch {
            fatalError("Failed to fetch recordings: \(error)")
        }
        
//        if (groupName != groupNameNew) && !postedchangeHeaderTitleNotification {
//            let nc = NotificationCenter.default
//            nc.post(name: Notification.Name("changeHeaderTitle"), object: nil, userInfo: ["newHeaderTitle": groupNameNew ?? "","oldName": groupName])
//            postedchangeHeaderTitleNotification = true
//        }
    }
    
    func updateSplitPerson(personName: String, personCreateDate: Date, personNameNew:String ) {
        let createDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: personCreateDate)!
        let createDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: personCreateDate)!
        
        let query = NSPredicate(format: "namePerson == %@ AND createDate > %@ AND createDate < %@", (personName as NSString), (createDateMinus as NSDate), (createDatePlus as NSDate))
        let dateSort = NSSortDescriptor(key: "createDate", ascending: true)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SplitPersons")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let fetchedData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if fetchedData.count > 1 || fetchedData.count <= 0 {
            } else {
                fetchedData[0].setValue(personNameNew, forKey: "namePerson")
                try managedContext.save()
            }
        } catch {
            fatalError("Failed to fetch recordings: \(error)")
        }

        var selectedGroups:String?
        for (_, value) in selectedDict.enumerated() {
            if (value.value[3] as? Bool ?? false) {
                let name = (value.value[1] as? String ?? "")
                let dateRAM = dateFormatter.string(from: (value.value[0] as? Date ?? Date()))
                if (selectedGroups?.count ?? 0) > 0 {
                    selectedGroups = (selectedGroups ?? "") + "*;*" + name + "*&*" + dateRAM
                } else {
                    selectedGroups = name + "*&*" + dateRAM
                }
            }
        }

        for data in loadBulkSorted(entitie: "SplitGroups", sort: [dateSort]) {
            
            let group = data.value(forKey: "nameGroup") as? String ?? ""
            let groupDate = data.value(forKey: "createDate") as? Date ?? Date()
            var persons = (data.value(forKey: "persons") as? String ?? "")
            
            if (persons.contains(personName)) && ((selectedGroups ?? "").contains(group)) {// person soll rein & ist drinnen
                persons = persons.replacingOccurrences(of: personName, with: personNameNew)
                updateSplitGroup(groupName: group, groupCreateDate: groupDate, personsNew:persons, groupNameNew: nil)
            } else if !(persons.contains(personName)) && ((selectedGroups ?? "").contains(group)) {// person soll rein & ist nicht drinnen
                if (persons.count > 0) {
                    persons = persons + "*;*" + personNameNew + "*&*" + dateFormatter.string(from: personCreateDate)
                } else {
                    persons = personNameNew + "*&*" + dateFormatter.string(from: personCreateDate)
                }
                updateSplitGroup(groupName: group, groupCreateDate: groupDate, personsNew:persons, groupNameNew: nil)
            } else if (persons.contains(personName)) && !((selectedGroups ?? "").contains(group)) {// person soll nicht rein & ist drinnen
                let removeString:String?
                
                let removeStringForArray = personName + "*&*" + dateFormatter.string(from: personCreateDate)
                if removeStringForArray == persons {
                    persons = ""
                } else {
                    let personsArray = persons.components(separatedBy: "*;*")
                    var j = 0
                    for i in 0...(personsArray.count-1) {
                        if personsArray[i] == removeStringForArray {
                            break
                        } else {
                            j = j + 1
                        }
                    }
                    if j == 0 {
                        removeString = personName + "*&*" + dateFormatter.string(from: personCreateDate) + "*;*"
                    } else if j == (personsArray.count-1) {
                        removeString = "*;*" + personName + "*&*" + dateFormatter.string(from: personCreateDate)
                    } else {
                        removeString = personName + "*&*" + dateFormatter.string(from: personCreateDate) + "*;*"
                    }
                    persons = persons.replacingOccurrences(of: removeString ?? "", with: "")
                }
                
                updateSplitGroup(groupName: group, groupCreateDate: groupDate, personsNew:persons, groupNameNew: nil)
            }
        }
    }
    
    func updatePersonSplits(namePerson: String, createDatePerson: Date, newNamePerson: String) {
        let createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDatePerson)!
        let createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDatePerson)!
        
        let query = NSPredicate(format: "namePerson == %@ AND createDatePerson < %@ AND createDatePerson > %@", (namePerson as NSString), (createDatePersonPlus as NSDate), (createDatePersonMinus as NSDate))
        saveSingleDataString(entity: "Splits", attibute: "namePerson", newValue: newNamePerson, query: query)
        
        let queryPaid = NSPredicate(format: "namePersonWhoPaid == %@ AND createDatePerson < %@ AND createDatePerson > %@", (namePerson as NSString), (createDatePersonPlus as NSDate), (createDatePersonMinus as NSDate))
        saveSingleDataString(entity: "Splits", attibute: "namePersonWhoPaid", newValue: newNamePerson, query: queryPaid)
    }
    
    func updateGroupSplits(nameGroup: String, createDateGroup: Date, newGroupName: String) {
        let createDateGroupPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateGroup)!
        let createDateGroupMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateGroup)!
        
        let query = NSPredicate(format: "nameGroup == %@ AND createDateGroup < %@ AND createDateGroup > %@", (nameGroup as NSString), (createDateGroupPlus as NSDate), (createDateGroupMinus as NSDate))
        saveSingleDataString(entity: "Splits", attibute: "nameGroup", newValue: newGroupName, query: query)
    }
    
}

extension splitAddNewTVC: cellSplitAddNewMainDelegate {
    func textFieldDidChange(newText: String) {
        if newText.count == 0 {
            labelText = ""
        } else if newText.count == 1 {
            labelText = newText.prefix(1).uppercased()
        } else {
            labelText = newText.prefix(2).uppercased()
        }
        inputText = newText
    }
}

extension splitAddNewTVC: cellSplitAddNewAddDelegate {
    func addButtonPressed() {
        if isInputtextValid() {
            switch selection {
            case 1:
                saveSplitPerson(namePerson: inputText, color: color ?? 0)
                updateGroupsIfAny()
                navTitle = NSLocalizedString("addSuccessNavlabelPerson", comment: "Person Added")
                break
            case 2:
                updateGroupSplits(nameGroup: updateGroupOrPersonName ?? "", createDateGroup: updateCreateDate ?? Date(), newGroupName: inputText)
                updateSplitGroup(groupName: updateGroupOrPersonName ?? "", groupCreateDate: updateCreateDate ?? Date(), personsNew: createPersonsForGroup(), groupNameNew: inputText)
                navTitle = NSLocalizedString("updateSuccessNavlabelGroup", comment: "Group Updated")
                break
            case 3:
                updatePersonSplits(namePerson: updateGroupOrPersonName ?? "", createDatePerson: updateCreateDate ?? Date(), newNamePerson: inputText)
                updateSplitPerson(personName: updateGroupOrPersonName ?? "", personCreateDate: updateCreateDate ?? Date(), personNameNew: inputText)
                if editUser {
                    saveSettings(settingsChange: "userName", newValue: (updateGroupOrPersonName ?? ""))
                }
                navTitle = NSLocalizedString("updateSuccessNavlabelPerson", comment: "Person Updated")
                break
            default:
                saveSplitSplitGroup(nameGroup: inputText, persons: createPersonsForGroup(), color: color ?? 0)
                navTitle = NSLocalizedString("addSuccessNavlabelGroup", comment: "Group Added")
                break
            }
            headerView.headerLabel.text = navTitle
            
            if selection == 2 || selection == 3 {
                if ((updateGroupOrPersonName ?? "") != inputText) && !postedchangeHeaderTitleNotification {
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name("changeHeaderTitle"), object: nil, userInfo: ["newHeaderTitle": inputText,"oldName": (updateGroupOrPersonName ?? "")])
                    nc.post(name: Notification.Name("groupPersonUpdated"), object: nil)
                    postedchangeHeaderTitleNotification = true
                }
            } else {
                if !postedgroupPersonAddedNotification {
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name("groupPersonAdded"), object: nil)
                    postedgroupPersonAddedNotification = true
                }
            }
//            reloadListView = true
//            reloadFinView = true
//            reloadGraphView = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
