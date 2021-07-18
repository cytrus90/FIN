//
//  exportTVC.swift
//  FIN
//
//  Created by Florian Riel on 24.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

class exportTVC: UITableViewController {

    @IBOutlet var exportTableView: UITableView!
    
    let delimiters = [";",",","\t"]
    let delimitersTitle = [";",",","tab"]
    
    var numberFormatter = NumberFormatter()
    var mediumDate = DateFormatter()
    
    var selectedDelimiter:Int = 1
    
    let exportTotalFormater = DateFormatter()
    
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("backButton", comment: "Back"), style: .done, target: self, action: #selector(cancel))
        self.title = ""
        
        numberFormatter.numberStyle = .decimal
//        numberFormatter.usesGroupingSeparator = true
//        numberFormatter.groupingSeparator = Locale.current.groupingSeparator
//        numberFormatter.groupingSize = 3
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        mediumDate.dateStyle = .medium
        
        initView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("detailListDisappeared"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        navigationBarAppearace.barTintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellExportText", for: indexPath) as! cellExportTextTVC
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellImportOptions", for: indexPath) as! cellImportOptions
            
            cell.label.text = NSLocalizedString("delimiterTitle", comment: "Delimiter")
            
            cell.segment.setTitle(delimitersTitle[0], forSegmentAt: 0)
            cell.segment.setTitle(delimitersTitle[1], forSegmentAt: 1)
            cell.segment.setTitle(delimitersTitle[2], forSegmentAt: 2)
            
            cell.segment.selectedSegmentIndex = selectedDelimiter
            
            cell.tag = indexPath.row
            
            cell.delegete = self
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellImportStartButton", for: indexPath) as! cellImportStartButton
            
            cell.startButton.setTitle(NSLocalizedString("startButtonExportTitle", comment: "Export CSV"), for: .normal)
            
            cell.delegate = self
            return cell
        }
    }

    // MARK: -initViewFunctions
    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            exportTableView.backgroundColor = backgroundGeneralColor
        } else {
            exportTableView.backgroundColor = .secondarySystemBackground
        }
        
        activityIndicator.style = .medium
        activityIndicator.hidesWhenStopped = true
        exportTableView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerYAnchor.constraint(equalTo: exportTableView.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: exportTableView.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        activityIndicator.stopAnimating()
    }

    func exportData() {
        let columns = [
            NSLocalizedString("bullet2", comment: "Date"),
            NSLocalizedString("bullet1", comment: "Amount"),
            NSLocalizedString("bullet4", comment: "Description"),
            NSLocalizedString("bullet3", comment: "Category"),
            NSLocalizedString("importBullet5", comment: "Currency Code"),
            NSLocalizedString("bullet6", comment: "Exchange Rate"),
        ]
        
        exportTotalFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let fileName = "FIN_export_" + exportTotalFormater.string(from: Date()) + ".csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)!
        
        var csvText = ""
        
        for index in 0...columns.count-1 {
            if index == columns.count-1 {
                csvText = csvText + columns[index] + "\n"
            } else {
                csvText = csvText + columns[index] + delimiters[selectedDelimiter]
            }
        }
        
        let dateSort = NSSortDescriptor(key: "dateTime", ascending: false)
        
        for transaction in dataHandler.loadBulkSorted(entitie: "Transactions", sort: [dateSort]) {
            csvText.append(exportTotalFormater.string(from: (transaction.value(forKey: "dateTime") as? Date ?? Date())))
            csvText.append(delimiters[selectedDelimiter])
            csvText.append((numberFormatter.string(from: NSNumber(value: (transaction.value(forKey: "amount") as? Double ?? 0.00))) ?? "0.00").replacingOccurrences(of: delimiters[selectedDelimiter], with: ""))
            csvText.append(delimiters[selectedDelimiter])
            csvText.append((transaction.value(forKey: "descriptionNote") as? String ?? "").replacingOccurrences(of: delimiters[selectedDelimiter], with: ""))
            csvText.append(delimiters[selectedDelimiter])
            let queryCategory = NSPredicate(format: "cID == %i", (transaction.value(forKey: "categoryID") as? Int16 ?? 0))
            csvText.append((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? (transaction.value(forKey: "descriptionNote") as? String ?? "")).replacingOccurrences(of: delimiters[selectedDelimiter], with: ""))
            csvText.append(delimiters[selectedDelimiter])
            csvText.append((transaction.value(forKey: "currencyCode") as? String ?? ""))
            csvText.append(delimiters[selectedDelimiter])
            csvText.append(numberFormatter.string(from: NSNumber(value: (transaction.value(forKey: "exchangeRate") as? Double ?? 1.00))) ?? "1.00")
            csvText.append("\n")
        }
        
        do {
            try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = self.view
        vc.popoverPresentationController?.sourceRect = self.view.bounds
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
    //        navigationBarAppearace.barTintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    //        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        }
        
        present(vc, animated: true, completion: {
            self.activityIndicator.stopAnimating()
        })
    }
    
    @objc func cancel() {
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        navigationBarAppearace.barTintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
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

extension exportTVC: cellImportStartButtonDelegate {
    func startButtonPressed() {
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.exportData()
        }
    }
}

extension exportTVC:cellImportOptionsDelegate {
    func segmentControlChanged(selected: Int, tag:Int) {
        if tag == 1 {
            selectedDelimiter = selected
        }
    }
}
