//
//  splitTransactionSelectTVC.swift
//  FIN
//
//  Created by Florian Riel on 08.10.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

class splitTransactionSelectTVC: UITableViewController {

    @IBOutlet var splitSelectTableview: UITableView!
    
    var rowData = [Int:[Int:Any]]()
    var rowDataUser = [Int:[Int:Any]]()
    
    var viewDisappear = false
    var isWideScreen: Bool = false
    var selectedRowIndex: Int?
    
    var selectedSplit:Int?
    var amount:Double?
    var selectedGroupOrPersons:String?
    
    var backupSelectedSplitSegment:Int?
    var backupSelectedGroupOrPersons:String?
    var backupSelectedSplitRow = [Int:Bool]()
    
    let dateFormatter = ISO8601DateFormatter()
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    let headerHeightFactor = CGFloat(0.10)
    var navTitle = NSLocalizedString("selectGroupSplitTransactionTitle", comment: "Group Split Transaction Title")
    
    var splitBottomBar:splitBottomBar = {
        let nib = UINib(nibName: "splitBottomBar", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! splitBottomBar
    }()
    var widthAnchorConstraintBottomBar: NSLayoutConstraint?
    var bottomAnchorConstraintBottomBar: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        if selectedSplitSegment == 0 || selectedSplitSegment == 1 {
            selectedSplit = selectedSplitSegment
            if selectedSplit == 1 {
                navTitle = NSLocalizedString("selectPersonSplitTransactionTitle", comment: "Person Split Transaction Title")
//                navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("selectMultiple", comment: "Multiple"), style: .done, target: self, action: #selector(selectMultiplePresses))
            }
        } else if selectedSplitSegment == 2 {
            selectedSplit = 2
//            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("splitMultipleNavItem", comment: "Split Multiple NavItem"), style: .done, target: self, action: #selector(splitMultiple))
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("backToSingle", comment: "Cancel"), style: .plain, target: self, action: #selector(cancelMultiple))
            
            navTitle = NSLocalizedString("selectPersonSplitTransactionTitle", comment: "Person Split Transaction Title")
        } else {
            selectedSplit = 0
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(clearSelected), name: Notification.Name("clearSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetSelected), name: Notification.Name("resetSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(splitChanged), name: Notification.Name("splitChanged"), object: nil)
        
        initView()
        if selectedSplitSegment == 2 {
            selectMultiple()
        }
        
        if editSplit {
            backupSelectedSplitSegment = selectedSplitSegment
            backupSelectedGroupOrPersons = selectedGroupOrPersons
            backupSelectedSplitRow = selectedSplitRow
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
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
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.navigationController?.view.backgroundColor = backgroundGeneralColor
            view.backgroundColor = backgroundGeneralColor
            splitSelectTableview.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            splitSelectTableview.backgroundColor = .secondarySystemBackground
        }
        
        initView()
        if selectedSplitSegment == 2 {
            selectMultiple()
        }
    }
    
    // MARK: -initViewFunctions
    func initView() {
        initTableAndHeaderView()
        initBottomBar()
        createDataForRows()
    }
    
    func initTableAndHeaderView() {
        splitSelectTableview.sectionHeaderHeight = UITableView.automaticDimension
     
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            splitSelectTableview.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
        } else {
            splitSelectTableview.backgroundColor = .secondarySystemBackground
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
        headerView.scrollView = splitSelectTableview
        
        splitSelectTableview.backgroundView = UIView()
        splitSelectTableview.backgroundView?.addSubview(headerView)
        splitSelectTableview.contentInset = UIEdgeInsets(
            top: 85,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 40,
            right: 0
        )
    }
    
    func initBottomBar() {
        splitBottomBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(splitBottomBar, aboveSubview: splitSelectTableview)
        splitBottomBar.initView()
        
        if selectedSplitSegment == nil {
            splitBottomBar.segmentControl.selectedSegmentIndex = 0
        } else {
            splitBottomBar.segmentControl.selectedSegmentIndex = selectedSplitSegment ?? 0
        }
        
        initBottomBarSize()
        
        splitBottomBar.delegete = self
        
        if selectedSplitSegment == 2 {
            hideBottomBar()
        }
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
        
        if selectedSplit == 2 {
            splitBottomBar.segmentControl.selectedSegmentIndex = 1
        } else {
            splitBottomBar.segmentControl.selectedSegmentIndex = selectedSplit ?? 0
        }
        
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
        return rowData.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitTransactionGeneral", for: indexPath) as! cellSplitTransactionGeneral

        if dataHandler.isUser(createDate: (rowData[indexPath.row]?[3] as? Date ?? Date()), namePerson: (rowData[indexPath.row]?[0] as? String ?? "")) {
            cell.mainLabel.text = (rowData[indexPath.row]?[0] as? String ?? "") + " [" + NSLocalizedString("youTheUser", comment: "I") + "]"
        } else {
            cell.mainLabel.text = rowData[indexPath.row]?[0] as? String ?? ""
        }

        if selectedSplit == 0 {
            cell.subLabel.text = (rowData[indexPath.row]?[2] as? String ?? "") + " " + NSLocalizedString("bottomSegmentUsers", comment: "persons")
            cell.subLabel.isHidden = false
        } else {
            cell.subLabel.isHidden = true
        }
        
        if (rowData[indexPath.row]?[4] as? String ?? "").count > 0 {
            cell.circleLabel.isHidden = true
            cell.circleImage.isHidden = false
            
            var selectedIcon = (rowData[indexPath.row]?[4] as? String ?? "").replacingOccurrences(of: "_white", with: "")
            if (rowData[indexPath.row]?[5] as? Bool ?? true) {
                selectedIcon = selectedIcon + "_white"
            }
            
            cell.circleImage.image = UIImage(named: selectedIcon)
        } else {
            cell.circleLabel.isHidden = false
            cell.circleImage.isHidden = true
            
            if (rowData[indexPath.row]?[0] as? String ?? "").count > 1 {
                cell.circleLabel.text = (rowData[indexPath.row]?[0] as? String ?? "").prefix(2).uppercased()
            } else if (rowData[indexPath.row]?[0] as? String ?? "").count == 1 {
                cell.circleLabel.text = (rowData[indexPath.row]?[0] as? String ?? "").prefix(1).uppercased()
            } else {
                cell.circleLabel.text = ""
            }
            
            if (rowData[indexPath.row]?[5] as? Bool ?? true) {
                cell.circleLabel.textColor = .white
            } else {
                cell.circleLabel.textColor = .black
            }
        }
        
        cell.circleView.backgroundColor = UIColor.randomColor(color: Int(rowData[indexPath.row]?[1] as? Int16 ?? 0))
        cell.circleView.layer.borderColor = cell.circleView.backgroundColor?.cgColor
        
        if selectedSplitSegment != nil && selectedSplitRow.count != 0 {
            if selectedSplitSegment == selectedSplit && (selectedSplitRow[indexPath.row] ?? false) {
                cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                cell.outlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                
                let nameAndDate = (rowData[indexPath.row]?[0] as? String ?? "") + "*&*" + (dateFormatter.string(from: (rowData[indexPath.row]?[3] as? Date ?? Date())))

                if (selectedGroupOrPersons?.count ?? 0) <= 0 {
                    selectedGroupOrPersons = nameAndDate
                } else {
                    selectedGroupOrPersons = (selectedGroupOrPersons ?? "") + "*;*" + nameAndDate
                }
                
            } else {
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
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        editSplit = false
        if let cell = splitSelectTableview.cellForRow(at: indexPath) as? cellSplitTransactionGeneral {
            cell.isSelected = false
        }
        if selectedSplit != 2 {
            if split.count != 0 && selectedSplitRow[indexPath.row] == nil {
                split.removeAll()
                selectedSplitRow.removeAll()

                if selectedSplitRow.count != 0 {
                    selectedSplitRow.removeAll()
                }
                if selectedSplitSegment != nil {
                    selectedSplitSegment = nil
                }
                if selectedSplitType != nil {
                    selectedSplitType = nil
                }
                clearRows()
            }
            selectedSplitSegment = selectedSplit
            selectedSplitRow[indexPath.row] = true
//            clearRows()
            singleSelectRow(indexPath: indexPath)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "splitOpenDetail", sender: nil)
            }
        } else {
            selectedSplitSegment = selectedSplit
            multiSelectRows(indexPathSelected: indexPath)
        }
    }

    func updateCellIconAlpha() {
        let heightTableView = splitSelectTableview.visibleSize.height
        let heightTableViewP = 0.01 * heightTableView
        
        for cell in splitSelectTableview.visibleCells {
            if let cellConverted = cell as? cellSplitTransactionGeneral {
                let yTopPosition = splitSelectTableview.convert(cellConverted.frame, to: nil).maxY
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
    
    // MARK: -TABLE DATA & FUNCTIONS
    func createDataForRows() {
        rowData.removeAll()
        
        if selectedSplit == 0 { // Groups
            let dateSort = NSSortDescriptor(key: "createDate", ascending: false)
            var i = 0
            for data in dataHandler.loadBulkSorted(entitie: "SplitGroups", sort: [dateSort]) {
                let personsLoad = (data.value(forKey: "persons") as? String ?? "")
                let numPersons:Int?
                
                if personsLoad.count > 0 {
                    numPersons = personsLoad.components(separatedBy: "*;*").count
                } else {
                    numPersons = 0
                }

                rowData[i] = [
                    0:data.value(forKey: "nameGroup") as? String ?? "",
                    1:data.value(forKey: "color") as? Int16 ?? 0,
                    2:String(numPersons ?? 0),
                    3:data.value(forKey: "createDate") as? Date ?? Date(),
                    4:data.value(forKey: "icon") as? String ?? "",
                    5:data.value(forKey: "iconLight") as? Bool ?? true
                ]
                i = i + 1
            }
        } else { // Persons
            let dateSort = NSSortDescriptor(key: "createDate", ascending: false)
            let userSort = NSSortDescriptor(key: "isUser", ascending: false)
            
            var i = 0
            for data in dataHandler.loadBulkSorted(entitie: "SplitPersons", sort: [userSort,dateSort]) {
                var namePerson:String?
                        
                if (data.value(forKey: "isUser") as? Bool ?? false) {
                    namePerson = (data.value(forKey: "namePerson") as? String ?? "")// + " [" + NSLocalizedString("youTheUser", comment: "I") + "]"
                    rowDataUser[0] = [
                        0:namePerson ?? "",
                        1:data.value(forKey: "color") as? Int16 ?? 0,
                        3:data.value(forKey: "createDate") as? Date ?? Date(),
                        4:data.value(forKey: "icon") as? String ?? "",
                        5:data.value(forKey: "iconLight") as? Bool ?? true
                    ]
                    if (selectedSplit == 2) && editSplit {
                        rowData[i] = [
                            0:namePerson ?? "",
                            1:data.value(forKey: "color") as? Int16 ?? 0,
                            3:data.value(forKey: "createDate") as? Date ?? Date(),
                            4:data.value(forKey: "icon") as? String ?? "",
                            5:data.value(forKey: "iconLight") as? Bool ?? true
                        ]
                        i = i + 1
                    }
                } else {
                    namePerson = data.value(forKey: "namePerson") as? String ?? ""
                    rowData[i] = [
                        0:namePerson ?? "",
                        1:data.value(forKey: "color") as? Int16 ?? 0,
                        3:data.value(forKey: "createDate") as? Date ?? Date(),
                        4:data.value(forKey: "icon") as? String ?? "",
                        5:data.value(forKey: "iconLight") as? Bool ?? true
                    ]
                    i = i + 1
                }
            }
        }
    }
    
    func multiSelectRows(indexPathSelected: IndexPath = IndexPath(row: 0, section: 0)) {
        if let cell = splitSelectTableview.cellForRow(at: indexPathSelected) as? cellSplitTransactionGeneral {
            var nameAndDate = (rowData[indexPathSelected.row]?[0] as? String ?? "") + "*&*" + (dateFormatter.string(from: (rowData[indexPathSelected.row]?[3] as? Date ?? Date())))
            
            if (selectedGroupOrPersons ?? "").contains(nameAndDate) { // de-Select Row
                selectedSplitRow.removeValue(forKey: indexPathSelected.row)
                
                let userInterfaceStyle = traitCollection.userInterfaceStyle
                if userInterfaceStyle == .light {
                    cell.outlineView.backgroundColor = .white
                    cell.outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                } else {
                    cell.outlineView.backgroundColor = .black
                    cell.outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
                }
                    
                var i = 0
                for data in (selectedGroupOrPersons ?? "").components(separatedBy: "*;*") {
                    if data == nameAndDate {
                        break
                    } else {
                        i = i + 1
                    }
                }
                
                if i == 0 && (selectedGroupOrPersons ?? "").components(separatedBy: "*;*").count > 1 {
                    nameAndDate = nameAndDate + "*;*"
                } else if (i == ((selectedGroupOrPersons ?? "").components(separatedBy: "*;*").count - 1 )) && (selectedGroupOrPersons ?? "").components(separatedBy: "*;*").count != 1 {
                    nameAndDate = "*;*" + nameAndDate
                } else if i != 0 && (i != (selectedGroupOrPersons ?? "").components(separatedBy: "*;*").count - 1 ) {
                    nameAndDate = nameAndDate + "*;*"
                }
                
                selectedGroupOrPersons = (selectedGroupOrPersons ?? "").replacingOccurrences(of: nameAndDate, with: "")
                
                cell.arrowRight?.image = UIImage(named: "circle")?.withRenderingMode(.alwaysTemplate)
            } else { // Select Row
                selectedSplitRow[indexPathSelected.row] = true
                
                cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                cell.outlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                
                if (selectedGroupOrPersons?.count ?? 0) <= 0 {
                    selectedGroupOrPersons = nameAndDate
                } else {
                    selectedGroupOrPersons = (selectedGroupOrPersons ?? "") + "*;*" + nameAndDate
                }
                
                cell.arrowRight?.image = UIImage(named: "circleChecked")?.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    func singleSelectRow(indexPath: IndexPath) {
        if let cell = splitSelectTableview.cellForRow(at: indexPath) as? cellSplitTransactionGeneral {
            cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
            cell.outlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
            selectedGroupOrPersons = (rowData[indexPath.row]?[0] as? String ?? "") + "*&*" + (dateFormatter.string(from: (rowData[indexPath.row]?[3] as? Date ?? Date())))
        }
    }
    
    func clearRows() {
        for i in 0...rowData.count {
            let indexPathRAM: IndexPath = IndexPath(row: i, section: 0)
            if let cell = splitSelectTableview.cellForRow(at: indexPathRAM) as? cellSplitTransactionGeneral {
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
    }

    // MARK: -FUNCTIONS
    @objc func selectMultiplePresses() {
//        editSplit = false
        selectMultiple()
    }
    
    func selectMultiple(preInitBottom:Bool = false) {
        if !editSplit {
            let rowDataRAM = rowData
            
            rowData.removeAll()
            rowData[0] = rowDataUser[0]
            
            for i in 1...(rowDataRAM.count) {
                rowData[i] = rowDataRAM[(i-1)]
            }
            
            splitSelectTableview.beginUpdates()
            splitSelectTableview.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            splitSelectTableview.endUpdates()
        }
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("splitMultipleNavItem", comment: "Split Multiple NavItem"), style: .done, target: self, action: #selector(splitMultiple))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("backToSingle", comment: "Cancel"), style: .plain, target: self, action: #selector(cancelMultiple))
        
        selectedSplit = 2
        
        if !editSplit {
            selectedSplitRow.removeAll()
            selectedGroupOrPersons?.removeAll()
            clearRows()
        }
        
        for i in 0...(rowData.count-1) {
            if let cell = splitSelectTableview.cellForRow(at: IndexPath(row: i, section: 0)) as? cellSplitTransactionGeneral {
                if (selectedSplitRow[i] ?? false) {
                    cell.arrowRight?.image = UIImage(named: "circleChecked")?.withRenderingMode(.alwaysTemplate)
                } else {
                    cell.arrowRight?.image = UIImage(named: "circle")?.withRenderingMode(.alwaysTemplate)
                }
            }
        }
        
        if !preInitBottom {
            hideBottomBar()
        }
        
        navTitle = NSLocalizedString("multipleSplitTitle", comment: "Multiple Persons Split Title")
        headerView.headerLabel.text = navTitle
    }
    
    @objc func cancelMultiple() {
        let rowDataRAM = rowData
        
        for i in 1...(rowDataRAM.count) {
            rowData[(i-1)] = rowDataRAM[i]
        }
        
        splitSelectTableview.beginUpdates()
        splitSelectTableview.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        splitSelectTableview.endUpdates()
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("selectMultiple", comment: "Multiple"), style: .done, target: self, action: #selector(selectMultiplePresses))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        showBottomBar()
        
        selectedSplit = 1
        
        for i in 0...(rowData.count-1) {
            if let cell = splitSelectTableview.cellForRow(at: IndexPath(row: i, section: 0)) as? cellSplitTransactionGeneral {
                cell.arrowRight?.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
            }
        }
        clearRows()
        selectedSplitRow.removeAll()
        
        navTitle = NSLocalizedString("selectPersonSplitTransactionTitle", comment: "Person Split Transaction Title")
        headerView.headerLabel.text = navTitle
    }
    
    @objc func splitMultiple() {
        if selectedGroupOrPersons?.count != 0 {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "splitOpenDetail", sender: nil)
            }
        }
    }
    
    @objc func cancel() {
        if backupSelectedSplitSegment != nil || backupSelectedGroupOrPersons != nil || backupSelectedSplitRow.count != 0 {
            selectedSplitSegment = backupSelectedSplitSegment
            selectedGroupOrPersons = backupSelectedGroupOrPersons
            selectedSplitRow = backupSelectedSplitRow
        }
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func clearSelected() {
        selectedGroupOrPersons = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.clearRows()
        }
    }
    
    @objc func resetSelected() {
//        splitSelectTableview.reloadData()
    }
    
    @objc func splitChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier ?? "") {
        case "splitOpenDetail":
            if let viewController = segue.destination as? splitTransactionTVC {
                viewController.amount = amount ?? 0.00
                viewController.selectedSplit = selectedSplit
                viewController.selectedGroupOrPersons = selectedGroupOrPersons
            }
            break
        default:
            break
        }
    }
}

extension splitTransactionSelectTVC: splitBottomBarDelegate {
    func segmentControlChanged(selected: Int) {
        editSplit = false
        selectedGroupOrPersons = ""
        clearRows()
        selectedSplitRow.removeAll()
        selectedSplit = selected
        if selected == 0  {
            navTitle = NSLocalizedString("selectGroupSplitTransactionTitle", comment: "Group Split Transaction Title")
            createDataForRows()
            splitSelectTableview.reloadData()
            navigationItem.rightBarButtonItem = nil
        } else {
            navTitle = NSLocalizedString("selectPersonSplitTransactionTitle", comment: "Person Split Transaction Title")
            createDataForRows()
            splitSelectTableview.reloadData()
//            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("selectMultiple", comment: "Multiple"), style: .done, target: self, action: #selector(selectMultiplePresses))
        }
        headerView.headerLabel.text = navTitle
    }
}
