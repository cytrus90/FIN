//
//  splitAddNewSelectTVC.swift
//  FIN
//
//  Created by Florian Riel on 28.09.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

class splitAddNewSelectTVC: UITableViewController {

    @IBOutlet var splitAddNewTableView: UITableView!
    
    var tableData = [Int:[Int:Any]]()
    
    var update:Bool?
    var updateGroupOrPersonName:String?
    var updateCreateDate:Date?
    
    var viewDisappear = false
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    let headerHeightFactor = CGFloat(0.10)
    var navTitle = NSLocalizedString("bottomSegmentGroups", comment: "Segment Group Text")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
                
        self.title = ""

        // Has to be the opposite than in prev view
        if selection == 0 || selectedSegement == 2 {
            navTitle = NSLocalizedString("splitSelectTitleUser", comment: "Select Title User")
        } else if selection == 1 || selection == 3 {
            navTitle = NSLocalizedString("splitSelectTitleGroup", comment: "Select Title Group")
        }
        
        initView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        viewDisappear = true
        if selectedDict.count > 0 {
            selectedDict.removeAll()
            selectedDict = tableData
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("selectedDictChanged"), object: nil)
        }
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
            splitAddNewTableView.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            splitAddNewTableView.backgroundColor = .secondarySystemBackground
        }
        
        initView()
    }

    func initView() {
        initTableAndHeaderView()
    }
    
    func initTableAndHeaderView() {
        splitAddNewTableView.sectionHeaderHeight = UITableView.automaticDimension
     
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            splitAddNewTableView.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
        } else {
            splitAddNewTableView.backgroundColor = .secondarySystemBackground
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
        headerView.scrollView = splitAddNewTableView
        
        splitAddNewTableView.backgroundView = UIView()
        splitAddNewTableView.backgroundView?.addSubview(headerView)
        splitAddNewTableView.contentInset = UIEdgeInsets(
            top: 85,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 40,
            right: 0
        )
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCell(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = splitAddNewTableView.cellForRow(at: indexPath) as? cellSplitAddSelectPersonsGroup {
            if !isUser(createDate: (tableData[indexPath.row]?[0] as? Date ?? Date()), namePerson: (tableData[indexPath.row]?[1] as? String ?? "")) {
                if selectedDict.count > 0 {
                    if (tableData[indexPath.row]?[3] as? Bool ?? false) == false {
                        setCellSelected(indexPath: indexPath)
                    } else {
                        resetCellSelected(indexPath: indexPath)
                    }
                }
            }
            cell.isSelected = false
        }
    }

    // MARK: -CELLS
    
    func getCell(indexPath: IndexPath) -> cellSplitAddSelectPersonsGroup {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitAddSelectPersonsGroup", for: indexPath) as! cellSplitAddSelectPersonsGroup
        
        if isUser(createDate: (tableData[indexPath.row]?[0] as? Date ?? Date()), namePerson: (tableData[indexPath.row]?[1] as? String ?? "")) {
            cell.label.text = (tableData[indexPath.row]?[1] as? String ?? "") + " [" + NSLocalizedString("youTheUser", comment: "I") + "]"
        } else {
            cell.label.text = (tableData[indexPath.row]?[1] as? String ?? "")
        }
        
        if (tableData[indexPath.row]?[1] as? String ?? "").count > 1 {
            cell.circleLabel.text = (tableData[indexPath.row]?[1] as? String ?? "").prefix(2).uppercased()
        } else if (tableData[indexPath.row]?[1] as? String ?? "").count == 1 {
            cell.circleLabel.text = (tableData[indexPath.row]?[1] as? String ?? "").prefix(1).uppercased()
        } else {
            if selection == 1 || selection == 3 {
                cell.circleLabel.text = NSLocalizedString("bottomAddSegmentGroups", comment: "Group Label Text").prefix(2).uppercased()
            } else {
                cell.circleLabel.text = NSLocalizedString("bottomAddSegmentUsers", comment: "User Label Text").prefix(2).uppercased()
            }
        }
        
        cell.circleView.backgroundColor = UIColor.randomColor(color: Int((tableData[indexPath.row]?[2] as? Int16 ?? 0)), returnText: false, light: false)
        cell.circleView.layer.borderColor = UIColor.randomColor(color: Int((tableData[indexPath.row]?[2] as? Int16 ?? 0)), returnText: false, light: false).cgColor
        cell.circleLabel.textColor = UIColor.randomColor(color: Int((tableData[indexPath.row]?[2] as? Int16 ?? 0)), returnText: true, light: false)
        
        if (tableData[indexPath.row]?[3] as? Bool ?? false) == true {
            cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
            cell.outlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
        } else {
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            if userInterfaceStyle == .light {
                cell.outlineView.backgroundColor = .white
                cell.outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                cell.backgroundColor = backgroundGeneralColor
            } else {
                cell.backgroundColor = .secondarySystemBackground
                cell.outlineView.backgroundColor = .black
                cell.outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
            }
        }
        
        return cell
    }
    
    func setCellSelected(indexPath: IndexPath) {
        if let cell = splitAddNewTableView.cellForRow(at: indexPath) as? cellSplitAddSelectPersonsGroup {
            if (update ?? false) && (updateGroupOrPersonName?.count ?? 0 > 0) {
                let createDatePersonPlus:Date?
                let createDatePersonMinus:Date?
                
                let createDateGroupPlus:Date?
                let createDateGroupMinus:Date?
                
                let personName:String?
                let groupName:String?
                
                if selection == 2 { // Group is being edited -> User in Cell
                    createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: tableData[indexPath.row]?[0] as? Date ?? Date())!
                    createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: tableData[indexPath.row]?[0] as? Date ?? Date())!
                    
                    createDateGroupPlus = Calendar.current.date(byAdding: .second, value: 1, to: updateCreateDate ?? Date())!
                    createDateGroupMinus = Calendar.current.date(byAdding: .second, value: -1, to: updateCreateDate ?? Date())!
                    
                    personName = tableData[indexPath.row]?[1] as? String ?? ""
                    groupName = updateGroupOrPersonName
                } else { // Person is being edited -> Group in Cell
                    createDateGroupPlus = Calendar.current.date(byAdding: .second, value: 1, to: tableData[indexPath.row]?[0] as? Date ?? Date())!
                    createDateGroupMinus = Calendar.current.date(byAdding: .second, value: -1, to: tableData[indexPath.row]?[0] as? Date ?? Date())!
                    
                    createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: updateCreateDate ?? Date())!
                    createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: updateCreateDate ?? Date())!
                    
                    groupName = tableData[indexPath.row]?[1] as? String ?? ""
                    personName = updateGroupOrPersonName
                }
                
                let dateSort = NSSortDescriptor(key: "createDatePerson", ascending: true)
                let query = NSPredicate(format: "createDatePerson > %@ AND createDatePerson < %@ AND namePerson == %@ AND nameGroup == %@ AND createDateGroup > %@ AND createDateGroup < %@ AND settled < 0.9999", ((createDatePersonMinus ?? Date()) as NSDate), ((createDatePersonPlus ?? Date()) as NSDate), (personName ?? "") as NSString, ((groupName ?? "") as NSString), ((createDateGroupMinus ?? Date()) as NSDate), ((createDateGroupPlus ?? Date())as NSDate))
                
                if loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [dateSort]).count > 0 {
                    let answerError = UIAlertController(title: NSLocalizedString("openSplitsOfPersonInGroupTitle", comment: "Open Splits of Person in Group Title"), message: NSLocalizedString("openSplitsOfPersonInGroupText", comment: "Open Splits of Person in Group Text"), preferredStyle: .alert)
                    answerError.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "forgotCodeOK"), style: .cancel, handler: nil))
                    answerError.popoverPresentationController?.sourceView = self.view
                    answerError.popoverPresentationController?.sourceRect = self.view.bounds
                    self.present(answerError, animated: true)
                } else {
                    tableData[indexPath.row]?[3] = true
                    cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                    cell.outlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                }
            } else {
                tableData[indexPath.row]?[3] = true
                cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                cell.outlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
            }
        }
    }
    
    func resetCellSelected(indexPath: IndexPath) {
        if let cell = splitAddNewTableView.cellForRow(at: indexPath) as? cellSplitAddSelectPersonsGroup {
            tableData[indexPath.row]?[3] = false
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            if userInterfaceStyle == .light {
                cell.outlineView.backgroundColor = .white
                cell.outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                cell.backgroundColor = backgroundGeneralColor
            } else {
                cell.backgroundColor = .secondarySystemBackground
                cell.outlineView.backgroundColor = .black
                cell.outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
            }
        }
    }
    
    // MARK: -FUNCTIONS
    
    func createData() {
        tableData.removeAll()
        if selectedDict.count > 0 {
            tableData = selectedDict
        } else {
            let labelText: String?
            if selection == 1 || selection == 3 {
                labelText = NSLocalizedString("noGroups", comment: "No Groups Label Text")
            } else {
                labelText = NSLocalizedString("noUsers", comment: "No User Label Text")
            }
            tableData[0] = [
                0:Date(),
                1:labelText ?? "",
                2:Int16(0),
                3:false
            ]
        }
    }
    
    @objc func done() {
        if selectedDict.count > 0 {
            selectedDict.removeAll()
            selectedDict = tableData
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("selectedDictChanged"), object: nil)
        }
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
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

extension splitAddNewSelectTVC {
    // MARK: -DATA
    
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
}
