//
//  listFilterTVC.swift
//  FIN
//
//  Created by Florian Riel on 29.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

var fileredCategories = [Int:[Int:Any]]()
var filteredTags = [Int:[Int:Any]]()

// Filter Variables
var fromDateMax: Date?
var toDateMax: Date?

class listFilterTVC: UITableViewController {

    @IBOutlet var listFilterTable: UITableView!
    
    var fromGraphsView:Bool = false
    
    var filterData = [Int:[Int:Any]]()
    var selectedSegment:Int = 0
    
    var listFilterBottomBar:listFilterBottomBar = {
        let nib = UINib(nibName: "listFilterBottomBar", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! listFilterBottomBar
    }()
    var widthAnchorConstraintFilterBottomBar: NSLayoutConstraint?
    var bottomAnchorConstraintFilterBottomBar: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.navigationController?.navigationBar.topItem?.title = NSLocalizedString("filterTitle", comment: "Filter Title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(applyFilter))
        
        initView()
        createData()
        listFilterTable.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
        listFilterTable.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (filterData[0]?[1] as? Bool ?? true) {
            return 1
        } else {
            return filterData.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: // ALL
            let cell = tableView.dequeueReusableCell(withIdentifier: "listFilterCell", for: indexPath) as! listFilterCell
            cell.label.text = filterData[indexPath.row]?[0] as? String ?? ""
            cell.subLabel.text = filterData[indexPath.row]?[2] as? String ?? ""
            cell.switch.isOn = filterData[indexPath.row]?[1] as? Bool ?? true
            cell.tag = indexPath.row
            cell.delegete = self
            return cell
        default: // Data
            let cell = tableView.dequeueReusableCell(withIdentifier: "listFilterCell", for: indexPath) as! listFilterCell
            cell.label.text = filterData[indexPath.row]?[0] as? String ?? ""
            if selectedSegment == 0 {
                cell.subLabel.text = filterData[indexPath.row]?[2] as? String ?? ""
                cell.subLabel.isHidden = false
            } else {
                cell.subLabel.isHidden = true
            }
            cell.switch.isOn = filterData[indexPath.row]?[1] as? Bool ?? true
            cell.tag = indexPath.row
            cell.delegete = self
            return cell
        }
    }

    func initView() {
        initFilterButtomView()
        
        listFilterTable.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 45,
            right: 0
        )
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.navigationController?.view.backgroundColor = backgroundGeneralColor
            view.backgroundColor = backgroundGeneralColor
            listFilterTable.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            listFilterTable.backgroundColor = .secondarySystemBackground
        }
    }
    
    func initFilterButtomView() {
        listFilterBottomBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(listFilterBottomBar, aboveSubview: listFilterTable)
        listFilterBottomBar.initView()
        
        initFilterBottomBarSize()
        
        listFilterBottomBar.delegete = self
    }
    
    func initFilterBottomBarSize() {
        widthAnchorConstraintFilterBottomBar?.isActive = false
        widthAnchorConstraintFilterBottomBar = listFilterBottomBar.widthAnchor.constraint(equalToConstant: min(view.frame.width, 400))
        widthAnchorConstraintFilterBottomBar?.isActive = true
        
        bottomAnchorConstraintFilterBottomBar?.isActive = false
        bottomAnchorConstraintFilterBottomBar = listFilterBottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        bottomAnchorConstraintFilterBottomBar?.isActive = true
        
        listFilterBottomBar.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 1.0).isActive = true
    }
    
    // MARK: -FUNCTIONS
    @objc func applyFilter() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let nc = NotificationCenter.default
            if !self.fromGraphsView {
                nc.post(name: Notification.Name("filterChanged"), object: nil)
            } else {
                nc.post(name: Notification.Name("filterChangedForGraph"), object: nil)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func createData() {
        filterData.removeAll()
        var i = 1
        switch selectedSegment {
        case 1: // Tags
            initFilteredTags()
            filterData[0] = [
                0:NSLocalizedString("filteredAll", comment: "All Filtered"),
                1:!filteredTagsZero,
                2:NSLocalizedString("filteredAllSubTag", comment: "All Filtered Subtext")
            ]
            if filteredTags.count > 0 {
                for j in 1...(filteredTags.count) {
                    filterData[i] = [
                        0:filteredTags[j]?[0] as? String ?? "",
                        1:filteredTags[j]?[1] as? Bool ?? true
                    ]
                    i = i + 1
                }
            }
            break
        default: // Categories
            initFileredCategories()
            filterData[0] = [
                0:NSLocalizedString("filteredAll", comment: "All Filtered"),
                1:!filteredCategoriesZero,
                2:NSLocalizedString("filteredAllSubCategory", comment: "All Filtered Subtext")
            ]
            if fileredCategories.count > 0 {
                for j in 1...(fileredCategories.count) {
                    var subText:String?
                    if (fileredCategories[j]?[4] as? Bool ?? false) {
                        subText = NSLocalizedString("filteredIsSave", comment: "Save")
                    } else {
                        if (fileredCategories[j]?[3] as? Bool ?? false) {
                            subText = NSLocalizedString("filteredIsIncome", comment: "Income")
                        } else {
                            subText = NSLocalizedString("filteredIsExpense", comment: "Expense")
                        }
                    }
                    filterData[i] = [
                        0:fileredCategories[j]?[1] as? String ?? "",
                        1:fileredCategories[j]?[2] as? Bool ?? true,
                        2:subText ?? "",
                        3:fileredCategories[j]?[0] as? Int16 ?? -1
                    ]
                    i = i + 1
                }
            }
            break
        }
    }
    
    func initFileredCategories() {
        fileredCategories.removeAll()
        var i = 1
        let categorySortID = NSSortDescriptor(key: "cID", ascending: true)

        // Get Expenses
        let expensesCategoriesPredicate = NSPredicate(format: "isIncome == %@ AND isSave == %@", NSNumber(value: false), NSNumber(value: false))
        for data in loadBulkQueriedSorted(entitie: "Categories", query: expensesCategoriesPredicate, sort: [categorySortID]) {
            fileredCategories[i] = [
                0:data.value(forKey: "cID") as? Int16 ?? 0,
                1:data.value(forKey: "name") as? String ?? "",
                2:data.value(forKey: "selectedForFilter") as? Bool ?? true,
                3:data.value(forKey: "isIncome") as? Bool ?? false,
                4:data.value(forKey: "isSave") as? Bool ?? false
            ]
            i = i + 1
        }
        
        // Get Incomes
        let incomesCategoriesPredicate = NSPredicate(format: "isIncome == %@ AND isSave == %@", NSNumber(value: true), NSNumber(value: false))
        for data in loadBulkQueriedSorted(entitie: "Categories", query: incomesCategoriesPredicate, sort: [categorySortID]) {
            fileredCategories[i] = [
                0:data.value(forKey: "cID") as? Int16 ?? 0,
                1:data.value(forKey: "name") as? String ?? "",
                2:data.value(forKey: "selectedForFilter") as? Bool ?? true,
                3:data.value(forKey: "isIncome") as? Bool ?? true,
                4:data.value(forKey: "isSave") as? Bool ?? false
            ]
            i = i + 1
        }
        
        // Get Save
        let savingsCategoriesPredicate = NSPredicate(format: "isSave == %@", NSNumber(value: true))
        for data in loadBulkQueriedSorted(entitie: "Categories", query: savingsCategoriesPredicate, sort: [categorySortID]) {
            fileredCategories[i] = [
                0:data.value(forKey: "cID") as? Int16 ?? 0,
                1:data.value(forKey: "name") as? String ?? "",
                2:data.value(forKey: "selectedForFilter") as? Bool ?? true,
                3:data.value(forKey: "isIncome") as? Bool ?? false,
                4:data.value(forKey: "isSave") as? Bool ?? true
            ]
            i = i + 1
        }
    }
    
    func initFilteredTags() {
        filteredTags.removeAll()
        var i = 1
        let tagSortDate = NSSortDescriptor(key: "lastUsed", ascending: false)
        for data in loadBulkSorted(entitie: "Tags", sort: [tagSortDate]) {
            filteredTags[i] = [
                0:data.value(forKey: "tagName") as? String ?? "",
                1:data.value(forKey: "selectedForFilter") as? Bool ?? true
            ]
            i = i + 1
        }
    }
}

// MARK: -DATA
extension listFilterTVC {
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
}

extension listFilterTVC: listFilterBottomBarDelegate {
    func segmentControlChanged(selected: Int) {
        selectedSegment = selected
        createData()
        listFilterTable.reloadData()
    }
}

extension listFilterTVC: listFilterCellDelegate {
    func switchChanged(cellTag: Int, newState: Bool) {
        filterData[cellTag]?[1] = newState
        if cellTag == 0 {
            if selectedSegment == 0 {
                saveSettings(settingsChange: "filteredCategoriesZero", newValue: !newState)
                filteredCategoriesZero = !newState
            } else {
                saveSettings(settingsChange: "filteredTagsZero", newValue: !newState)
                filteredTagsZero = !newState
            }
            
            listFilterTable.beginUpdates()
            if newState {
                if filterData.count > 0 {
                    for i in 0...(filterData.count-1) {
                        if i == 0 {
                            continue
                        } else {
                            filterData[i]?[1] = true
                            if listFilterTable.cellForRow(at: IndexPath(row: i, section: 0)) != nil {
                                let cell = listFilterTable.cellForRow(at: IndexPath(row: i, section: 0)) as! listFilterCell
                                cell.switch.setOn((filterData[i]?[1] as? Bool ?? true), animated: true)
                            }
                            listFilterTable.deleteRows(at: [IndexPath(row: i, section: 0)], with: .fade)
                            if selectedSegment == 0 {
                                let savingsCategoriesPredicate = NSPredicate(format: "cID == %@", NSNumber(value: fileredCategories[i]?[0] as? Int16 ?? 0))
                                _ = saveQueriedAttribute(entity: "Categories", attribute: "selectedForFilter", query: savingsCategoriesPredicate, value: filterData[i]?[1] as? Bool ?? true)
                            } else {
                                let savingsCategoriesPredicate = NSPredicate(format: "tagName == %@", filteredTags[i]?[0] as? String ?? "")
                                _ = saveQueriedAttribute(entity: "Tags", attribute: "selectedForFilter", query: savingsCategoriesPredicate, value: filterData[i]?[1] as? Bool ?? true)
                            }
                        }
                    }
                }
            } else {
                if filterData.count > 0 {
                    var indexPathsInsert = [IndexPath]()
                    for i in 0...(filterData.count-1) {
                        if i == 0 {
                            continue
                        } else {
                            filterData[i]?[1] = false
                            indexPathsInsert.append(IndexPath(row: i, section: 0))
                            if selectedSegment == 0 {
                                let savingsCategoriesPredicate = NSPredicate(format: "cID == %@", NSNumber(value: fileredCategories[i]?[0] as? Int16 ?? 0))
                                _ = saveQueriedAttribute(entity: "Categories", attribute: "selectedForFilter", query: savingsCategoriesPredicate, value: filterData[i]?[1] as? Bool ?? false)
                            } else {
                                let savingsCategoriesPredicate = NSPredicate(format: "tagName == %@", filteredTags[i]?[0] as? String ?? "")
                                _ = saveQueriedAttribute(entity: "Tags", attribute: "selectedForFilter", query: savingsCategoriesPredicate, value: filterData[i]?[1] as? Bool ?? false)
                            }
                        }
                    }
                    listFilterTable.insertRows(at: indexPathsInsert, with: .fade)
                }
            }
            listFilterTable.endUpdates()
        } else {
            if selectedSegment == 0 {
                let savingsCategoriesPredicate = NSPredicate(format: "cID == %@", NSNumber(value: fileredCategories[cellTag]?[0] as? Int16 ?? 0))
                _ = saveQueriedAttribute(entity: "Categories", attribute: "selectedForFilter", query: savingsCategoriesPredicate, value: newState)
            } else {
                let savingsCategoriesPredicate = NSPredicate(format: "tagName == %@", filterData[cellTag]?[0] as? String ?? "")
                _ = saveQueriedAttribute(entity: "Tags", attribute: "selectedForFilter", query: savingsCategoriesPredicate, value: newState)
            }
            if !newState {
                filterData[0]?[1] = false
                if listFilterTable.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
                    let cell = listFilterTable.cellForRow(at: IndexPath(row: 0, section: 0)) as! listFilterCell
                    cell.switch.setOn((filterData[0]?[1] as? Bool ?? true), animated: true)
                }
            }
        }
    }
}
