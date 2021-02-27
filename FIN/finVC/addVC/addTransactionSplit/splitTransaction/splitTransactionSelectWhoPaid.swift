//
//  splitTransactionSelectWhoPaid.swift
//  FIN
//
//  Created by Florian Riel on 18.10.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

class splitTransactionSelectWhoPaidTVC: UITableViewController {

    @IBOutlet var splitSelectWhoPaidTableView: UITableView!
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    let headerHeightFactor = CGFloat(0.10)
    var navTitle = NSLocalizedString("personWhoPaidSublabel", comment: "person Who Paid Sublabel")
    var viewDisappear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        initView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        viewDisappear = true
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("clearSelectedCell"), object: nil, userInfo: nil)
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
            splitSelectWhoPaidTableView.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            splitSelectWhoPaidTableView.backgroundColor = .secondarySystemBackground
        }
        
        initView()
//        createDataForRows()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return split.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitTransactionGeneral", for: indexPath) as! cellSplitTransactionGeneral

        cell.subLabel.isHidden = true

        if (split[indexPath.row]?[9] as? Bool ?? false) {
            cell.mainLabel.text = (split[indexPath.row]?[0] as? String ?? "") + " [" + NSLocalizedString("youTheUser", comment: "I") + "]"
        } else {
            cell.mainLabel.text = (split[indexPath.row]?[0] as? String ?? "")
        }

        if (split[indexPath.row]?[10] as? String ?? "").count > 0 {
            cell.circleLabel.isHidden = true
            cell.circleImage.isHidden = false
            
            var selectedIcon = (split[indexPath.row]?[10] as? String ?? "").replacingOccurrences(of: "_white", with: "")
            if (split[indexPath.row]?[11] as? Bool ?? true) {
                selectedIcon = selectedIcon + "_white"
            }
            
            cell.circleImage.image = UIImage(named: selectedIcon)
        } else {
            cell.circleLabel.isHidden = false
            cell.circleImage.isHidden = true
            
            if (split[indexPath.row]?[0] as? String ?? "").count <= 0 {
                cell.circleLabel.text = ""
            } else if (split[indexPath.row]?[0] as? String ?? "").count == 1 {
                cell.circleLabel.text = (split[indexPath.row]?[0] as? String ?? "").prefix(1).uppercased()
            } else {
                cell.circleLabel.text = (split[indexPath.row]?[0] as? String ?? "").prefix(2).uppercased()
            }
            
            if (split[indexPath.row]?[11] as? Bool ?? true) {
                cell.circleLabel.textColor = .white
            } else {
                cell.circleLabel.textColor = .black
            }
        }
        
        let datePlusPerson = Calendar.current.date(byAdding: .second, value: 1, to: (split[indexPath.row]?[1] as? Date ?? Date()))!
        let dateMinusPerson = Calendar.current.date(byAdding: .second, value: -1, to: (split[indexPath.row]?[1] as? Date ?? Date()))!
        
        let query = NSPredicate(format: "createDate < %@ AND createDate > %@ AND namePerson == %@", (datePlusPerson as NSDate), (dateMinusPerson as NSDate), ((split[indexPath.row]?[0] as? String ?? "") as NSString))
        
        let colorInt = Int(loadQueriedAttribute(entitie: "SplitPersons", attibute: "color", query: query) as? Int16 ?? 0)
        
        cell.circleView.backgroundColor = UIColor.randomColor(color: colorInt, returnText: false, light: false)
        cell.circleView.layer.borderColor = UIColor.randomColor(color: colorInt, returnText: false, light: false).cgColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if splitSelectWhoPaidTableView.cellForRow(at: indexPath) is cellSplitTransactionGeneral {
            setCellSelected(indexPath: indexPath)
            
            let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
            let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
            
            var nameUser:String?
            var createDateUser:Date?
            var paidByUser:Bool?
            
            for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
                nameUser = data.value(forKey: "namePerson") as? String ?? ""
                createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
            }
            
            let userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
            let userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
            
            let personWhoPaid = split[indexPath.row]?[0] as? String ?? ""
            let personWhoPaidCreateDate = split[indexPath.row]?[1] as? Date ?? Date()
            
            let up = personWhoPaidCreateDate.compare(userDatePlus) == .orderedAscending
            let down = personWhoPaidCreateDate.compare(userDateMinus) == .orderedDescending
            
            if up && down && personWhoPaid == nameUser {
                paidByUser = true
            } else {
                paidByUser = false
            }
            
            for i in 0...(split.count-1) {
                split[i]?[4] = personWhoPaid
                split[i]?[5] = personWhoPaidCreateDate
                split[i]?[6] = paidByUser ?? false
            }
            
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("whoPaidChanged"), object: nil, userInfo: nil)
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
//                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    func setCellSelected(indexPath: IndexPath) {
        if let cell = splitSelectWhoPaidTableView.cellForRow(at: indexPath) as? cellSplitTransactionGeneral {
            cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
            cell.outlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
        }
    }
    
    // MARK: -TABLE DATA FUNCTIONS
    
    // MARK: -VIEW FUNCTIONS
    func initView() {
        initTableAndHeaderView()
    }
    
    func initTableAndHeaderView() {
        splitSelectWhoPaidTableView.sectionHeaderHeight = UITableView.automaticDimension
     
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            splitSelectWhoPaidTableView.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
        } else {
            splitSelectWhoPaidTableView.backgroundColor = .secondarySystemBackground
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
        headerView.scrollView = splitSelectWhoPaidTableView
        
        splitSelectWhoPaidTableView.backgroundView = UIView()
        splitSelectWhoPaidTableView.backgroundView?.addSubview(headerView)
        splitSelectWhoPaidTableView.contentInset = UIEdgeInsets(
            top: 85,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 40,
            right: 0
        )
    }
    
    @objc func cancel() {
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

// MARK: -DATA
extension splitTransactionSelectWhoPaidTVC {
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
