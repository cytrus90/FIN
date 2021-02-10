//
//  UserTVC.swift
//  FIN
//
//  Created by Florian Riel on 08.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData
import StoreKit

class userMasterVC: UITableViewController {
    @IBOutlet var userTable: UITableView!
    
    let activityIndicator = UIActivityIndicatorView()
    
    weak var delegate: userSelectionDelegate?
    
    let headerHeightFactor = CGFloat(0.10)
    var navTitle = NSLocalizedString("userTitle", comment: "User VC Title")
    var selectedRow: String?
    var selectedRowIndex: Int?
    var viewDisappear: Bool = false
    var isWideScreen: Bool = false
    
    // In-App
    var productsArray: Array<SKProduct> = []
    
    // var productsRequest = SKProductsRequest()
    
    var selectedProductIndex: Int!
    var transactionInProgress = false
    var canPerformPurchase = false
    
    let cellTitle = [
//        0:NSLocalizedString("quickTitle", comment: "Quick Buttons"),
        0:NSLocalizedString("regularPaymentsTitle", comment: "Regular Payments"),
//        2:NSLocalizedString("budgetMonthlyTitle", comment: "Budget Monthly"),
        1:NSLocalizedString("categoriesTitle", comment: "Categories"),
        2:NSLocalizedString("exportTitle", comment: "Export / Import Title"),
        3:NSLocalizedString("settingsTitle", comment: "Settings"),
        4:NSLocalizedString("aboutTitle", comment: "About")
    ]
    
    let cellText = [
//        0:NSLocalizedString("quickText", comment: "Quick Buttons"),
        0:NSLocalizedString("regularPaymentsText", comment: "Regular Payments"),
//        2:NSLocalizedString("budgetMonthlyText", comment: "Budget Monthly"),
        1:NSLocalizedString("categoriesText", comment: "Categories"),
        2:NSLocalizedString("exportText", comment: "Export / Import Text"),
        3:NSLocalizedString("settingsText", comment: "Settings"),
        4:NSLocalizedString("aboutTitle", comment: "About")
    ]
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        initView(table: userTable)
        headerView.updatePosition()
//        (self.splitViewController as! userSplitVC).initFirstSelected()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if showAdds {
            NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailed), name: Notification.Name("purchaseFailed"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(purchaseDone), name: Notification.Name("purchaseDone"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(purchaseRestored), name: Notification.Name("purchaseRestored"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(restoreNotFound), name: Notification.Name("restoreNotFound"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(purchaseFinished), name: Notification.Name("purchaseFinished"), object: nil)
            
            PKIAPHandler.shared.setProductIds(ids: ["removeads.alpako.fin"])
            PKIAPHandler.shared.fetchAvailableProducts { [weak self](products) in
               guard let sSelf = self else {return}
               sSelf.productsArray = products
               //sSelf.tableView.reloadData() //reload you table or collection view
            }
            canPerformPurchase = PKIAPHandler.shared.canMakePurchases()
        }
        
        initFirstSelected()
        initView(table: userTable)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        activityIndicator.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        initFirstSelected()
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
        userTable.reloadData()
        initFirstSelected()
        initView(table: userTable)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showAdds {
            return 6
        } else {
            return 5
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userMainCell", for: indexPath) as! userTVCell

        if indexPath == IndexPath(row: selectedRowIndex ?? 0, section: 0) && selectedRowIndex != nil {
            cell.cellOutlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
            cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
        }
        
        switch indexPath.row {
        case 1:
            cell.cellLabel.text = cellTitle[indexPath.row]
//            cell.cellLabelImage.image = UIImage(systemName: "arrow.clockwise")
            cell.cellLabelImage.image = UIImage(systemName: "rectangle.3.offgrid")
            break
        case 2:
            cell.cellLabel.text = cellTitle[indexPath.row]
//            cell.cellLabelImage.image = UIImage(systemName: "exclamationmark.triangle")
            cell.cellLabelImage.image = UIImage(systemName: "doc")?.withRenderingMode(.alwaysTemplate)
            break
        case 3:
            cell.cellLabel.text = cellTitle[indexPath.row]
//            cell.cellLabelImage.image = UIImage(systemName: "rectangle.3.offgrid")
            cell.cellLabelImage.image = UIImage(named: "settingsIcon")?.withRenderingMode(.alwaysTemplate)
            break
        case 4:
            cell.cellLabel.text = cellTitle[indexPath.row]
            cell.cellLabelImage.image = UIImage(systemName: "info.circle")?.withRenderingMode(.alwaysTemplate)
            break
        case 5:
            return getPurchaseRestoreButton(indexPath: indexPath)
        default:
            cell.cellLabel.text = cellTitle[indexPath.row]
//            cell.cellLabelImage.image = UIImage(systemName: "wand.and.rays.inverse")
            cell.cellLabelImage.image = UIImage(named: "repeatCalender")?.withRenderingMode(.alwaysTemplate)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 5 {
            if showAdds && indexPath.row == 2 { // Import / Export, not bought
                let purchaseText = NSLocalizedString("purchaseText", comment: "Unlock Features Text")
                let purchaseTitle = NSLocalizedString("purchaseTitle", comment: "Unlock Features Title")
                let purchasePrompt = UIAlertController(title: purchaseTitle, message: purchaseText, preferredStyle: .alert)

                purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteYes", comment: "Delete Yes"), style: .cancel, handler: { action in
                    self.purchaseButtonPressed()
                }))
                purchasePrompt.addAction(UIAlertAction(title: NSLocalizedString("deleteNo", comment: "Delete No"), style: .default, handler: nil))
                
                purchasePrompt.popoverPresentationController?.sourceView = self.view
                purchasePrompt.popoverPresentationController?.sourceRect = self.view.bounds
                
                self.present(purchasePrompt, animated: true)
                
            } else {
                initRows(indexPathSelected: indexPath)
        //        UISelectionFeedbackGenerator().selectionChanged()
                selectedRowIndex = indexPath.row
                selectedRow = cellTitle[indexPath.row]
                if UIDevice().model.contains("iPad") {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "masterSelected", sender: nil)
                    }
                } else {
                    let userDetailStoryBoard: UIStoryboard = UIStoryboard(name: "userTSB", bundle: nil)
                    let userDetailVC = userDetailStoryBoard.instantiateViewController(withIdentifier: "userDetailVC") as! userDetailVC
                    userDetailVC.selectedRow = selectedRow
                    userDetailVC.selectedRowForCells = selectedRowIndex
                    userDetailVC.modalPresentationStyle = .fullScreen
                    selectedRowIndex = nil
                    self.navigationController?.pushViewController(userDetailVC, animated: true)
                }
            }
        }
    }
    
    // MARK: -FUNCTIONS
    func initView(table: UITableView) {
        table.sectionHeaderHeight = UITableView.automaticDimension
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            userTable.backgroundColor = backgroundGeneralColor
            headerView.backgroundColor = backgroundGeneralColor
        } else {
            userTable.backgroundColor = .secondarySystemBackground
            headerView.backgroundColor = .secondarySystemBackground
        }
        
        headerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let userName = loadData(entitie: "Settings", attibute: "userName") as? String ?? "User"
        if userName == "User" {
            headerView.headerLabel.text = navTitle
        } else {
            headerView.headerLabel.text = userName
            navTitle = userName
        }
        
        headerView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.frame.width,
            height: 85//view.frame.height * headerHeightFactor
        )
        
        headerView.maxHeight = view.frame.height * headerHeightFactor
        headerView.maxLabelPointSize = headerView.headerLabel.font.pointSize
        headerView.minLabelPointSize = 20.0
        headerView.scrollView = table
        
        table.backgroundView = UIView()
        table.backgroundView?.addSubview(headerView)
        table.contentInset = UIEdgeInsets(
            top: 85,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 0,
            right: 0
        )
        
        activityIndicator.style = .medium
        activityIndicator.hidesWhenStopped = true
        table.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerYAnchor.constraint(equalTo: table.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: table.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
    }
    
    func initRows(indexPathSelected: IndexPath = IndexPath(row: 0, section: 0), clearRows: Bool = false) {
        for (row, _) in cellTitle {
            let indexPathRAM: IndexPath = IndexPath(row: row, section: 0)
            if let cell = userTable.cellForRow(at: indexPathRAM) as? userTVCell {
                let userInterfaceStyle = traitCollection.userInterfaceStyle
                if userInterfaceStyle == .light {
                    cell.cellOutlineView.backgroundColor = .white
                    cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                } else {
                    cell.cellOutlineView.backgroundColor = .black
                    cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
                }
            }
        }
        if !clearRows {
            if let cell = userTable.cellForRow(at: indexPathSelected) as? userTVCell {
                cell.cellOutlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                cell.cellOutlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
            }
        }
    }
    
    func initFirstSelected() {
        if selectedRowIndex == nil && UIDevice().model.contains("iPad") {
            selectedRowIndex = 0
            initRows(indexPathSelected: IndexPath(row: selectedRowIndex ?? 0, section: 0))
            selectedRow = cellTitle[0]
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "masterSelected", sender: nil)
            }
        } else if selectedRowIndex != nil && UIDevice().model.contains("iPad") {
            initRows(indexPathSelected: IndexPath(row: selectedRowIndex ?? 0, section: 0), clearRows: false)
        } else {
            initRows(clearRows: true)
        }
    }
    
    func getPurchaseRestoreButton(indexPath: IndexPath) -> cellPurchase {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPurchase", for: indexPath) as! cellPurchase
        cell.delegate = self
        return cell
    }
    
    // MARK: -DATA
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier ?? "") {
        case "masterSelected":
            guard let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.topViewController as? userDetailVC
            else {
                fatalError()
            }
            
//            viewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            viewController.navigationItem.leftItemsSupplementBackButton = true
            viewController.selectedRow = selectedRow
            viewController.selectedRowForCells = selectedRowIndex
            break
        default:
            break
        }
    }
}

extension userMasterVC {
    // MARK: -In-App Purchase
    @objc func purchaseFailed() {
        activityIndicator.stopAnimating()
    }
    
    @objc func purchaseFinished() {
        activityIndicator.stopAnimating()
    }
    
    @objc func purchaseDone() {
        transactionInProgress = false
        showAdds = false
        saveSettings(settingsChange: "showAdds", newValue: false)
        activityIndicator.stopAnimating()
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("updateFinVC"), object: nil) // reload finVC
        nc.post(name: Notification.Name("dataImported"), object: nil) // reload listMasterVC
        nc.post(name: Notification.Name("filterChangedForGraph"), object: nil) // reload graphsVC
        userTable.reloadData()
    }
    
    @objc func purchaseRestored() {
        showAdds = false
        saveSettings(settingsChange: "showAdds", newValue: false)
        activityIndicator.stopAnimating()
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("updateFinVC"), object: nil) // reload finVC
        nc.post(name: Notification.Name("dataImported"), object: nil) // reload listMasterVC
        nc.post(name: Notification.Name("filterChangedForGraph"), object: nil) // reload graphsVC
        userTable.reloadData()
        
        let alert = UIAlertController(title: NSLocalizedString("foundTitle", comment: "Success"), message: NSLocalizedString("purchaseRestoredText", comment: "Purchase Restored"), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("noNameOk", comment: "Ok"), style: UIAlertAction.Style.default, handler: nil))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        present(alert, animated: true, completion: nil)
    }
    
    @objc func restoreNotFound() {
        let alert = UIAlertController(title: NSLocalizedString("notFoundTitle", comment: "Not found"), message: NSLocalizedString("notFoundText", comment: "Not found text"), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("noNameOk", comment: "Ok"), style: UIAlertAction.Style.default, handler: nil))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        present(alert, animated: true, completion: nil)
        activityIndicator.stopAnimating()
    }
}

protocol userSelectionDelegate: AnyObject {
    func userRowSelected()
}

extension userMasterVC: cellPurchaseDelegate {
    func purchaseButtonPressed() {
        if canPerformPurchase {
            activityIndicator.startAnimating()
            selectedProductIndex = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                if self.productsArray.count > 0 {
                    PKIAPHandler.shared.purchase(product: self.productsArray[0]) { (alert, product, transaction) in
                        if let _ = transaction, let _ = product {
                         //use transaction details and purchased product as you want
                       }
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: NSLocalizedString("errorProductRequestTitle", comment: "Error"), message: NSLocalizedString("notAuthorisedText", comment: "Not authorised text"), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("noNameOk", comment: "Ok"), style: UIAlertAction.Style.default, handler: nil))
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = self.view.bounds
            present(alert, animated: true, completion: { self.activityIndicator.stopAnimating() })
        }
    }
    
    func restoreButtonPressed() {
        if canPerformPurchase {
            activityIndicator.startAnimating()
            
            PKIAPHandler.shared.restorePurchase()
        } else {
            let alert = UIAlertController(title: NSLocalizedString("errorProductRequestTitle", comment: "Error"), message: NSLocalizedString("notAuthorisedText", comment: "Not authorised text"), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("noNameOk", comment: "Ok"), style: UIAlertAction.Style.default, handler: nil))
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = self.view.bounds
            present(alert, animated: true, completion: { self.activityIndicator.stopAnimating() })
        }
    }
}

