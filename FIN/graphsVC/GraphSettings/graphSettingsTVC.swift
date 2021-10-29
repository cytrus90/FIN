//
//  graphSettingsTVC.swift
//  FIN
//
//  Created by Florian Riel on 26.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

class graphSettingsTVC: UITableViewController {

    @IBOutlet var graphSettingsTableView: UITableView!
    
    var rowData = [Int:[Int:Any]]()
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    let headerHeightFactor = CGFloat(0.10)
    var navTitle = NSLocalizedString("graphSettingsTitle", comment: "Graph Settings Title")
    
    var isWideScreen: Bool = false
    var viewDisappear = false
    
    var activeGraphID:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(applyFilter))
        
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        initData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
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
//        (self.splitViewController as! splitVC).initFirstSelected()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if activeGraphID == 0 {
            if let cell = graphSettingsTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellGraphSettingsDetailsTVC {
                if UIDevice().model.contains("iPhone") && UIDevice.current.orientation.isPortrait {
                    cell.segmentControl1.setTitle(NSLocalizedString("lineChartOption1_2", comment: "Savings"), forSegmentAt: 1)
                } else {
                    cell.segmentControl1.setTitle(NSLocalizedString("lineChartOption1_2", comment: "Savings"), forSegmentAt: 1)
                }
            }
        }
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.navigationController?.view.backgroundColor = backgroundGeneralColor
            view.backgroundColor = backgroundGeneralColor
            graphSettingsTableView.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            graphSettingsTableView.backgroundColor = .secondarySystemBackground
        }
        initView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UIDevice().model.contains("iPad") {
            return 3
        } else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellGraphSettingsTVC", for: indexPath) as! cellGraphSettingsTVC
            
            cell.label.text = NSLocalizedString("graphSettingsCellTitle", comment: "Cell Title")
            
            cell.segmentControl.setTitle(NSLocalizedString("lineChartTitle", comment: "Line Cahrt"), forSegmentAt: 0)
            cell.segmentControl.setTitle(NSLocalizedString("pieChartTitle", comment: "Pie Chart"), forSegmentAt: 1)
            cell.segmentControl.setTitle(NSLocalizedString("barChartTitle", comment: "Bar Chart"), forSegmentAt: 2)
            cell.segmentControl.selectedSegmentIndex = activeGraphID
            
            cell.delegate = self
            
            return cell
        } else if indexPath.row == 1 && !UIDevice().model.contains("iPad") {
            return getSettingsCells(indexPath: indexPath)
        } else if indexPath.row == 1 && UIDevice().model.contains("iPad") {
            return getSecondSwitchCell(indexPath: indexPath)
        } else {
            return getSettingsCells(indexPath: indexPath)
        }
    }

    
    // MARK: -INIT VIEW
    func initView() {
        initTableAndHeaderView()
    }

    func initTableAndHeaderView() {
        graphSettingsTableView.sectionHeaderHeight = UITableView.automaticDimension
     
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            graphSettingsTableView.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
        } else {
            graphSettingsTableView.backgroundColor = .secondarySystemBackground
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
        headerView.scrollView = graphSettingsTableView
        
        graphSettingsTableView.backgroundView = UIView()
        graphSettingsTableView.backgroundView?.addSubview(headerView)
        graphSettingsTableView.contentInset = UIEdgeInsets(
            top: 85,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 40,
            right: 0
        )
    }
    
    // MARK: -CELLs
    func getSettingsCells(indexPath: IndexPath) -> cellGraphSettingsDetailsTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellGraphSettingsDetailsTVC", for: indexPath) as! cellGraphSettingsDetailsTVC
        
        if (rowData[activeGraphID]?[4] as? Bool ?? false) && !UIDevice().model.contains("iPhone") {
            cell.segmentControl3.isHidden = false
        } else {
            cell.segmentControl3.isHidden = true
        }
        
        if activeGraphID == 0 {
            cell.label1.text = NSLocalizedString("option1LineChartTitle", comment: "Line Chart Options")
            
            cell.segmentControl1.setTitle(NSLocalizedString("lineChartOption1_0", comment: "Balance"), forSegmentAt: 0)
            cell.segmentControl1.setTitle(NSLocalizedString("lineChartOption1_2", comment: "Savings"), forSegmentAt: 1)
            
            if cell.segmentControl1.numberOfSegments >= 3 {
                cell.segmentControl1.removeSegment(at: 2, animated: false)
            }
            
            cell.segmentControl1.selectedSegmentIndex = Int(rowData[activeGraphID]?[2] as? Int16 ?? 0)
            
            cell.segmentControl3.setTitle(NSLocalizedString("lineChartOption1_0", comment: "Balance"), forSegmentAt: 0)
            cell.segmentControl3.setTitle(NSLocalizedString("lineChartOption1_2", comment: "Savings"), forSegmentAt: 1)
            
            if cell.segmentControl3.numberOfSegments >= 3 {
                cell.segmentControl3.removeSegment(at: 2, animated: false)
            }
            
            cell.segmentControl3.selectedSegmentIndex = Int(rowData[activeGraphID]?[5] as? Int16 ?? 0)
            
            if cell.segmentControl2.numberOfSegments < 3 {
                cell.segmentControl2.insertSegment(withTitle: NSLocalizedString("bottomSegmentAll", comment: "All"), at: 2, animated: false)
            }
            
            cell.segmentControl2.selectedSegmentIndex = Int(rowData[activeGraphID]?[3] as? Int16 ?? 0)
        } else if activeGraphID == 1 {
            cell.label1.text = NSLocalizedString("option1PieChartTitle", comment: "Bar Chart Options")
            
            cell.segmentControl1.setTitle(NSLocalizedString("pieChartOption1_0", comment: "Category"), forSegmentAt: 0)
            cell.segmentControl1.setTitle(NSLocalizedString("pieChartOption1_1", comment: "Tags"), forSegmentAt: 1)
            if cell.segmentControl1.numberOfSegments < 3 {
                cell.segmentControl1.insertSegment(withTitle: NSLocalizedString("lineChartOption1_2", comment: "Savings"), at: 2, animated: false)
            }
            cell.segmentControl1.selectedSegmentIndex = Int(rowData[activeGraphID]?[2] as? Int16 ?? 0)

            cell.segmentControl3.setTitle(NSLocalizedString("pieChartOption1_0", comment: "Category"), forSegmentAt: 0)
            cell.segmentControl3.setTitle(NSLocalizedString("pieChartOption1_1", comment: "Tags"), forSegmentAt: 1)
            if cell.segmentControl3.numberOfSegments < 3 {
                cell.segmentControl3.insertSegment(withTitle: NSLocalizedString("lineChartOption1_2", comment: "Savings"), at: 2, animated: false)
            }

            cell.segmentControl3.selectedSegmentIndex = Int(rowData[activeGraphID]?[5] as? Int16 ?? 0)
            
            if cell.segmentControl2.numberOfSegments < 3 {
                cell.segmentControl2.insertSegment(withTitle: NSLocalizedString("bottomSegmentAll", comment: "All"), at: 2, animated: false)
            }
            
            cell.segmentControl2.selectedSegmentIndex = Int(rowData[activeGraphID]?[3] as? Int16 ?? 0)
        } else if activeGraphID == 2 {
            cell.label1.text = NSLocalizedString("option1BarChartTitle", comment: "Line Chart Options")
            
            cell.segmentControl1.setTitle(NSLocalizedString("barChartOption1_0", comment: "Balance"), forSegmentAt: 0)
            cell.segmentControl1.setTitle(NSLocalizedString("barChartOption1_1", comment: "Savings"), forSegmentAt: 1)
            
            if cell.segmentControl1.numberOfSegments >= 3 {
                cell.segmentControl1.removeSegment(at: 2, animated: false)
            }
            
            cell.segmentControl1.selectedSegmentIndex = Int(rowData[activeGraphID]?[2] as? Int16 ?? 0)
            
            cell.segmentControl3.setTitle(NSLocalizedString("barChartOption1_0", comment: "Balance"), forSegmentAt: 0)
            cell.segmentControl3.setTitle(NSLocalizedString("barChartOption1_1", comment: "Savings"), forSegmentAt: 1)
            
            if cell.segmentControl3.numberOfSegments >= 3 {
                cell.segmentControl3.removeSegment(at: 2, animated: false)
            }
            
            cell.segmentControl3.selectedSegmentIndex = Int(rowData[activeGraphID]?[5] as? Int16 ?? 0)
            
            if cell.segmentControl2.numberOfSegments >= 3 {
                cell.segmentControl2.removeSegment(at: 2, animated: false)
                if (rowData[activeGraphID]?[3] as? Int16 ?? 0) >= 2 {
                    graphOption2Changed(selected: 1)
                    cell.segmentControl2.selectedSegmentIndex = 1
                } else {
                    cell.segmentControl2.selectedSegmentIndex = Int(rowData[activeGraphID]?[3] as? Int16 ?? 0)
                }
            }
        }
        
        cell.label2.text = NSLocalizedString("option2ChartTitle", comment: "Options2")
        cell.segmentControl2.setTitle(NSLocalizedString("bottomSegmentMonthly", comment: "Monthly"), forSegmentAt: 0)
        cell.segmentControl2.setTitle(NSLocalizedString("bottomSegmentYearly", comment: "Yearly"), forSegmentAt: 1)
        
        cell.delegate = self
        
        return cell
    }
    
    func getSecondSwitchCell(indexPath: IndexPath) -> cellGraphSettingsSecondTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellGraphSettingsSecondTVC", for: indexPath) as! cellGraphSettingsSecondTVC
        cell.secondSwitch.isOn = (rowData[activeGraphID]?[4] as? Bool ?? false)
        cell.delegate = self
        return cell
    }
    
    // MARK: -FUNCTIONS
    func initData() {
        
        let graphSort = NSSortDescriptor(key: "graphID", ascending: true)
        // DataCheck
        if dataHandler.loadBulkSorted(entitie: "GraphSettings", sort: [graphSort]).count <= 0 || dataHandler.loadBulkSorted(entitie: "GraphSettings", sort: [graphSort]).count > 3 {
            dataHandler.saveNewGraphs()
        }
        
        for graph in dataHandler.loadBulkSorted(entitie: "GraphSettings", sort: [graphSort]) {
            let graphActive = (graph.value(forKey: "graphActive") as? Bool ?? false)
            let graphName = (graph.value(forKey: "graphName") as? Int16 ?? 0)
            let graphOption1 = (graph.value(forKey: "graphOption1") as? Int16 ?? 0)
            let graphOption2 = (graph.value(forKey: "graphOption2") as? Int16 ?? 0)
            var showSecondGraph = false
            let graphOption3 = (graph.value(forKey: "graphOption3") as? Int16 ?? 0)
            
            if !UIDevice().model.contains("iPhone") {
                let showSecondGraphLocal = UserDefaults.standard.bool(forKey: "showSecondGraph")
                if showSecondGraphLocal {
                    showSecondGraph = true
                } else {
                    showSecondGraph = false
                }
            }
            
            rowData[Int(graph.value(forKey: "graphID") as? Int16 ?? 0)] = [
                0:graphActive,
                1:graphName,
                2:graphOption1,
                3:graphOption2,
                4:showSecondGraph,
                5:graphOption3
            ]
            if (graph.value(forKey: "graphActive") as? Bool ?? false)! {
                activeGraphID = Int(graph.value(forKey: "graphID") as? Int16 ?? 0)
            }
        }
    }
    
    @objc func applyFilter() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("filterChangedForGraph"), object: nil)
        }
        self.dismiss(animated: true, completion: nil)
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

extension graphSettingsTVC: cellGraphSettingsTVSDelegate {
    func selectedGraphChanged(selected: Int) {
        let graphSort = NSSortDescriptor(key: "graphID", ascending: true)
        var someGraphIsActive = false
        
        for graph in dataHandler.loadBulkSorted(entitie: "GraphSettings", sort: [graphSort]) {
            
            let query = NSPredicate(format: "graphID == %i", graph.value(forKey: "graphID") as? Int16 ?? 0)

            if selected == Int(graph.value(forKey: "graphID") as? Int16 ?? 0) {
                _ = dataHandler.saveQueriedAttribute(entity: "GraphSettings", attribute: "graphActive", query: query, value: true)
                someGraphIsActive = true
                rowData[Int(graph.value(forKey: "graphID") as? Int16 ?? 0)] = [
                    0:true
                ]
                activeGraphID = Int(graph.value(forKey: "graphID") as? Int16 ?? 0)
                
                var graphSettingsRow = 1
                if UIDevice().model.contains("iPad") {
                    graphSettingsRow = 2
                }
                
                if let cell = graphSettingsTableView.cellForRow(at: IndexPath(row: graphSettingsRow, section: 0)) as? cellGraphSettingsDetailsTVC {
                    if activeGraphID == 0 {
                        cell.label1.text = NSLocalizedString("option1LineChartTitle", comment: "Line Chart Options")
                        
                        cell.segmentControl1.setTitle(NSLocalizedString("lineChartOption1_0", comment: "Balance"), forSegmentAt: 0)
                        cell.segmentControl1.setTitle(NSLocalizedString("lineChartOption1_2", comment: "Savings"), forSegmentAt: 1)
                        if cell.segmentControl1.numberOfSegments >= 3 {
                            cell.segmentControl1.removeSegment(at: 2, animated: false)
                        }
                        
                        cell.segmentControl3.setTitle(NSLocalizedString("lineChartOption1_0", comment: "Balance"), forSegmentAt: 0)
                        cell.segmentControl3.setTitle(NSLocalizedString("lineChartOption1_2", comment: "Savings"), forSegmentAt: 1)
                        if cell.segmentControl3.numberOfSegments >= 3 {
                            cell.segmentControl3.removeSegment(at: 2, animated: false)
                        }
                        
                        if cell.segmentControl2.numberOfSegments < 3 {
                            cell.segmentControl2.insertSegment(withTitle: NSLocalizedString("bottomSegmentAll", comment: "All"), at: 2, animated: false)
                        }
                    } else if activeGraphID == 1 {
                        cell.label1.text = NSLocalizedString("option1PieChartTitle", comment: "Pie Chart Options")
                        
                        cell.segmentControl1.setTitle(NSLocalizedString("pieChartOption1_0", comment: "Category"), forSegmentAt: 0)
                        cell.segmentControl1.setTitle(NSLocalizedString("pieChartOption1_1", comment: "Tags"), forSegmentAt: 1)
                        if cell.segmentControl1.numberOfSegments < 3 {
                            cell.segmentControl1.insertSegment(withTitle: NSLocalizedString("lineChartOption1_2", comment: "Savings"), at: 2, animated: false)
                        }
                        
                        cell.segmentControl3.setTitle(NSLocalizedString("pieChartOption1_0", comment: "Category"), forSegmentAt: 0)
                        cell.segmentControl3.setTitle(NSLocalizedString("pieChartOption1_1", comment: "Tags"), forSegmentAt: 1)
                        if cell.segmentControl3.numberOfSegments < 3 {
                            cell.segmentControl3.insertSegment(withTitle: NSLocalizedString("lineChartOption1_2", comment: "Savings"), at: 2, animated: false)
                        }
                        
                        if cell.segmentControl2.numberOfSegments < 3 {
                            cell.segmentControl2.insertSegment(withTitle: NSLocalizedString("bottomSegmentAll", comment: "All"), at: 2, animated: false)
                        }
                    } else if activeGraphID == 2 {
                        cell.label1.text = NSLocalizedString("option1BarChartTitle", comment: "Bar Chart Options")
                        
                        cell.segmentControl1.setTitle(NSLocalizedString("barChartOption1_0", comment: "Balance"), forSegmentAt: 0)
                        cell.segmentControl1.setTitle(NSLocalizedString("barChartOption1_1", comment: "Savings"), forSegmentAt: 1)
                        if cell.segmentControl1.numberOfSegments >= 3 {
                            cell.segmentControl1.removeSegment(at: 2, animated: false)
                        }
                        
                        cell.segmentControl3.setTitle(NSLocalizedString("barChartOption1_0", comment: "Balance"), forSegmentAt: 0)
                        cell.segmentControl3.setTitle(NSLocalizedString("barChartOption1_1", comment: "Savings"), forSegmentAt: 1)
                        if cell.segmentControl3.numberOfSegments >= 3 {
                            cell.segmentControl3.removeSegment(at: 2, animated: false)
                        }
                        
                        if cell.segmentControl2.numberOfSegments >= 3 {
                            cell.segmentControl2.removeSegment(at: 2, animated: false)
                        }
                    }
                    cell.segmentControl1.selectedSegmentIndex = Int(graph.value(forKey: "graphOption1") as? Int16 ?? 0)
                    cell.segmentControl2.selectedSegmentIndex = Int(graph.value(forKey: "graphOption2") as? Int16 ?? 0)
                    cell.segmentControl3.selectedSegmentIndex = Int(graph.value(forKey: "graphOption3") as? Int16 ?? 0)
                }
            } else {
                _ = dataHandler.saveQueriedAttribute(entity: "GraphSettings", attribute: "graphActive", query: query, value: false)
                rowData[Int(graph.value(forKey: "graphID") as? Int16 ?? 0)] = [
                    0:false
                ]
            }
        }
        if !someGraphIsActive {
            let query = NSPredicate(format: "graphID == %i", Int16(selected))
            _ = dataHandler.saveQueriedAttribute(entity: "GraphSettings", attribute: "graphActive", query: query, value: true)
        }
    }
}

extension graphSettingsTVC: cellGraphSettingsDetailsTVCDelegate {
    func graphOption1Changed(selected: Int) {
        let query = NSPredicate(format: "graphActive == %@", NSNumber(value: true))
        _ = dataHandler.saveQueriedAttribute(entity: "GraphSettings", attribute: "graphOption1", query: query, value: Int16(selected))
    }
    
    func graphOption2Changed(selected: Int) {
        let query = NSPredicate(format: "graphActive == %@", NSNumber(value: true))
        _ = dataHandler.saveQueriedAttribute(entity: "GraphSettings", attribute: "graphOption2", query: query, value: Int16(selected))
    }
    
    func graphOption3Changed(selected: Int) {
        let query = NSPredicate(format: "graphActive == %@", NSNumber(value: true))
        _ = dataHandler.saveQueriedAttribute(entity: "GraphSettings", attribute: "graphOption3", query: query, value: Int16(selected))
    }
}

extension graphSettingsTVC: cellGraphSettingsSecondTVCDelegate {
    func secondSwitchChanged(newState:Bool) {
        if UIDevice().model.contains("iPad") {           
            if newState {
                UserDefaults.standard.setValue(true, forKey: "showSecondGraph")
            } else {
                UserDefaults.standard.setValue(false, forKey: "showSecondGraph")
            }

            rowData[activeGraphID]?[4] = newState
            
            graphSettingsTableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        }
    }
}

//extension graphSettingsTVC {
//    // MARK: -DATA
//
//    // MARK: LOAD
//    func loadBulkSorted(entitie:String, sort:[NSSortDescriptor]) -> [NSManagedObject] {
//        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentLocalContainer.viewContext
//        managedContext.automaticallyMergesChangesFromParent = true
//        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
//        fetchRequest.returnsObjectsAsFaults = false
//        fetchRequest.sortDescriptors = sort
//        do {
//            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
//            if loadData.count > 0 {
//                return loadData
//            }
//        } catch {
//            print("Could not fetch. \(error)")
//        }
//        return [NSManagedObject]()
//    }
//
//    // MARK: SAVE
//    func saveNewGraphs() {
//        deleteDataBulk(entity: "GraphSettingsLocal")
//        for i in 0...1 {
//            let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentLocalContainer.viewContext
//
//            managedContext.automaticallyMergesChangesFromParent = true
//            managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
//            let graphSave = GraphSettingsLocal(context: managedContext)
//
//            graphSave.graphID = Int16(i)
//            if i == 0 {
//                graphSave.graphName = NSLocalizedString("lineChartTitle", comment: "Line Cahrt")
//                graphSave.graphActive = false
//            } else if i == 1 {
//                graphSave.graphName = NSLocalizedString("barChartTitle", comment: "Bar Cahrt")
//                graphSave.graphActive = true
//            }
//            graphSave.graphOption1 = Int16(0)
//            graphSave.graphOption2 = Int16(0)
//
//            do {
//                try managedContext.save()
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
//            }
//        }
//    }
//
//    func saveQueriedAttribute(entity: String, attribute: String, query: NSPredicate ,value: Any) {
//        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentLocalContainer.viewContext
//        managedContext.automaticallyMergesChangesFromParent = true
//        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
//        fetchRequest.returnsObjectsAsFaults = false
//        fetchRequest.predicate = query
//        do {
//            let fetchedData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
//            if fetchedData.count > 1 || fetchedData.count <= 0 {
//                return
//            } else {
//                fetchedData[0].setValue(value, forKey: attribute)
//                try managedContext.save()
//                return
//            }
//        } catch {
//            fatalError("Failed to fetch recordings: \(error)")
//        }
//    }
//
//    // MARK: DELETE
//    func deleteDataBulk(entity: String) {
//        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentLocalContainer.viewContext
//        managedContext.automaticallyMergesChangesFromParent = true
//        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
//        do {
//            let delete = try managedContext.fetch(fetchRequest)
//            for data in delete {
//                managedContext.delete(data as! NSManagedObject)
//            }
//            do {
//                try managedContext.save()
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
//            }
//        } catch {
//            print(error)
//        }
//    }
//}
