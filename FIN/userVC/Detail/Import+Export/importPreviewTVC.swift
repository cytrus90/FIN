//
//  importPreviewTVC.swift
//  FIN
//
//  Created by Florian Riel on 21.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import CSVImporter
import CoreData

class importPreviewTVC: UITableViewController {

    @IBOutlet var importTableView: UITableView!
    
    var headerView:headerView = {
        let nib = UINib(nibName: "headerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! headerView
    }()
    let headerHeightFactor = CGFloat(0.10)
    var navTitle = NSLocalizedString("importPreviewTitle", comment: "Preview")
    
    let activityIndicator = UIActivityIndicatorView()
    
    var delimiter:String?
//    var newLine:String?
    
    var rowData = [Int:[Int:Any]]()
    
    var numberFormatter = NumberFormatter()
    var mediumDate = DateFormatter()
    
    var isWideScreen: Bool = false
    var viewDisappear = false
    
    var entriesFound:Int?
    
    override func loadView() {
        super.loadView()
        deleteRAMData(entity: "ImportRAM")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.isModalInPresentation = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("importButton", comment: "Import"), style: .done, target: self, action: #selector(doImport))
        
        self.title = ""
        
        numberFormatter.numberStyle = .decimal
//        numberFormatter.locale = .current
        
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = Locale.current.groupingSeparator
        numberFormatter.groupingSize = 3
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        mediumDate.dateStyle = .medium
        
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        attachDocument()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        viewDisappear = true
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        navigationBarAppearace.barTintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
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
//        initRows(clearRows: true)
//        (self.splitViewController as! splitVC).initFirstSelected()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.navigationController?.view.backgroundColor = backgroundGeneralColor
            view.backgroundColor = backgroundGeneralColor
            importTableView.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            importTableView.backgroundColor = .secondarySystemBackground
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellGeneral", for: indexPath) as! cellDetailGeneralTVC

        cell.circleView.backgroundColor =  rowData[(indexPath.row)]?[9] as? UIColor ?? UIColor.blue
        cell.circleView.layer.borderColor = cell.circleView.backgroundColor?.cgColor
        cell.circleLabel.textColor = rowData[(indexPath.row)]?[10] as? UIColor ?? UIColor.blue
        
        if (rowData[(indexPath.row)]?[8] as? String ?? "").count == 1 {
            cell.circleLabel.text = (rowData[(indexPath.row)]?[8] as? String ?? "").prefix(1).uppercased()
        } else {
            cell.circleLabel.text = (rowData[(indexPath.row)]?[8] as? String ?? "").prefix(2).uppercased()
        }
        
        cell.descriptionLabel.text = rowData[(indexPath.row)]?[6] as? String ?? ""
        cell.descriptionSubtitleLabel.text = rowData[(indexPath.row)]?[7] as? String ?? ""
        
        cell.icon.isHidden = true

        cell.amountLabel.text = (rowData[(indexPath.row)]?[1] as? String ?? "") + " " + (numberFormatter.string(from: NSNumber(value: (rowData[(indexPath.row)]?[0] as? Double ?? 0.00))) ?? "0.00")
        
        return cell
    }

    // MARK: -InitView
    
    func initView() {
        importTableView.sectionHeaderHeight = UITableView.automaticDimension
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            importTableView.backgroundColor = backgroundGeneralColor
        } else {
            importTableView.backgroundColor = .secondarySystemBackground
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
        headerView.scrollView = importTableView
        
        importTableView.backgroundView = UIView()
        importTableView.backgroundView?.addSubview(headerView)
        
        importTableView.contentInset = UIEdgeInsets(
            top: 85,//view.frame.height * headerHeightFactor + 20,
            left: 0,
            bottom: 40,
            right: 0
        )
        activityIndicator.style = .medium
        importTableView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerYAnchor.constraint(equalTo: importTableView.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: importTableView.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
    }
    
    // MARK: -FUNCTIONS

    func importData() -> Bool {
        let dateSort = NSSortDescriptor(key: "dateTime", ascending: false)
        
        var i = 0
        
        for importRAM in loadBulkSortedRAM(entitie: "ImportRAM", sort: [dateSort]) {
            let tags = ""
            let isSave = importRAM.value(forKey: "isSave") as? Bool ?? false
            let exchangeRate = importRAM.value(forKey: "exchangeRate") as? Double ?? 1.00
            let descriptionNote = importRAM.value(forKey: "descriptionNote") as? String ?? ""
            var dateTime = importRAM.value(forKey: "dateTime") as? Date ?? Date()
            let currencyCode = importRAM.value(forKey: "currencyCode") as? String ?? "EUR"
            let amount = importRAM.value(forKey: "amount") as? Double ?? 0.00
            let realAmount = importRAM.value(forKey: "realAmount") as? Double ?? 0.00
            
            let color = rowData[i]?[12] as? Int16 ?? 0
            
            var categoryID:Int16 = importRAM.value(forKey: "categoryID") as? Int16 ?? -1
            if (importRAM.value(forKey: "categoryID") as? Int16 ?? -1) == -1 {
                let queryCategory = NSPredicate(format: "name == %@", (importRAM.value(forKey: "category") as? String ?? "") as NSString)
                for category in loadBulkQueried(entitie: "Categories", query: queryCategory) {
                    categoryID = category.value(forKey: "cID") as? Int16 ?? -1
                }
                if categoryID == -1 {
                    categoryID = saveNewCategory(categoryName: importRAM.value(forKey: "category") as? String ?? "", color: color)
                }
            }
            
            var doubleTransaction = true
            
            repeat {
                let dateTimeTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTime)!
                let dateTimeTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTime)!
                
                let querySaveTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", dateTimeTransactionPlus as NSDate, dateTimeTransactionMinus as NSDate)
                
                if loadBulkQueried(entitie: "Transactions", query: querySaveTransaction).count > 0 {
                    doubleTransaction = true
                    dateTime = dateTimeTransactionPlus
                } else {
                    doubleTransaction = false
                }
            } while doubleTransaction
            
            saveTransaction(amount: amount, realAmount: realAmount, category: categoryID, currencyCode: currencyCode, dateTime: dateTime, descriptionNote: descriptionNote, exchangeRate: exchangeRate, tags: tags, isSave: isSave)
            i = i + 1
        }
        
        let categoriesCountArray = loadDataGrouped(entitie: "Transactions", groupByColumn: "categoryID") as? [[String:Any]]
        
        if (categoriesCountArray?.count ?? 0) > 0 {
            for i in 0...((categoriesCountArray?.count ?? 1)-1) {
                let queryCategorySave = NSPredicate(format: "cID == %i", NSInteger((categoriesCountArray?[i]["categoryID"] as? Int16 ?? 0)))
                saveSingleInt(entity: "Categories", attibute: "countEntries", newValue: (categoriesCountArray?[i]["count"] as? Int64 ?? 0), query: queryCategorySave)
            }
        }
        
        let nc = NotificationCenter.default
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            nc.post(name: Notification.Name("dataImported"), object: nil)
            self.deleteRAMData(entity: "ImportRAM")
        })
        return true
    }
    
    func createRowData() {
        //        0: Amount
        //        1: Currency
        //        6: Description
        //        7: Date as String
        //        8: Category Name
        //        9: Category Color
        //        10: Text Color for Circle
        //        11: Date as Date
        //        12: Color Int16
        
        var i = 0
        let dateSort = NSSortDescriptor(key: "dateTime", ascending: false)
        
        for importRAM in loadBulkSortedRAM(entitie: "ImportRAM", sort: [dateSort]) {
            if i >= 10 {
                break
            }
            
            var color = Int16(Int.random(in: 0...35))
            var categoryID:Int16 = -1
            
            if (importRAM.value(forKey: "categoryID") as? Int16 ?? -1) != -1 {
                categoryID = (importRAM.value(forKey: "categoryID") as? Int16 ?? -1)
                
                let queryCategory = NSPredicate(format: "cID == %i", categoryID)
                color = loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0
            }
            
            rowData[i] = [
                0:(importRAM.value(forKey: "realAmount") as? Double ?? 0.00),
                1:getSymbol(forCurrencyCode: importRAM.value(forKey: "currencyCode") as? String ?? "EUR") ?? "€",
                6:(importRAM.value(forKey: "descriptionNote") as? String ?? (importRAM.value(forKey: "category") as? String ?? "")),
                7:mediumDate.string(from: (importRAM.value(forKey: "dateTime") as? Date ?? Date())),
                8:(importRAM.value(forKey: "category") as? String ?? ""),
                9:UIColor.randomColor(color: Int(color), returnText: false, light: false),
                10:UIColor.randomColor(color: Int(color), returnText: true, light: false),
                11:(importRAM.value(forKey: "dateTime") as? Date ?? Date()),
                12:color
            ]
            i = i + 1
        }
        importTableView.reloadData()
        
        let text = String(entriesFound ?? 0) + NSLocalizedString("foundText", comment: "Found Text") + String(i) + NSLocalizedString("foundText2", comment: "Found2")
        let answerSuccess = UIAlertController(title: NSLocalizedString("foundTitle", comment: "Error Title"), message: text, preferredStyle: .alert)
        answerSuccess.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "forgotCodeOK"), style: .cancel, handler: nil))
        answerSuccess.popoverPresentationController?.sourceView = self.view
        answerSuccess.popoverPresentationController?.sourceRect = self.view.bounds
        self.present(answerSuccess, animated: true)
    }
    
    func saveDataToRAMDB(importedRecords: [[String]]) -> Bool {
         // check where the columns are (Int)
        let indexAmount = importedRecords[0].firstIndex(of: NSLocalizedString("bullet1", comment: "Amount")) // Amount
        let indexDate = importedRecords[0].firstIndex(of: NSLocalizedString("bullet2", comment: "Date")) // Date
        let indexCategory = importedRecords[0].firstIndex(of: NSLocalizedString("bullet3", comment: "Category")) // Category
        
        let indexDescription = importedRecords[0].firstIndex(of: NSLocalizedString("bullet4", comment: "Description")) // Description
        let indexCurrencyCode = importedRecords[0].firstIndex(of: NSLocalizedString("importBullet5", comment: "Currency Code")) // Currency Code
        let indexExchangeRate = importedRecords[0].firstIndex(of: NSLocalizedString("bullet6", comment: "Exchange Rate")) // Exchange Rate
        
        for i in 1...(importedRecords.count-1) {
            let date = getDate(dateString: importedRecords[i][indexDate ?? 0])
            if date != nil {
                let amountFormatter = NumberFormatter()
                amountFormatter.locale = .current
                
                let thSep:String = Locale.current.groupingSeparator ?? ","
                
                if let saveAmount = amountFormatter.number(from: (importedRecords[i][indexAmount ?? 0]).replacingOccurrences(of: thSep, with: "")) as? Double {
                    var saveExchangeRate = 1.0
                    if (indexExchangeRate != nil) {
                        if let saveExchangeRateRAM = amountFormatter.number(from: (importedRecords[i][indexExchangeRate ?? 0]).replacingOccurrences(of: thSep, with: "")) as? Double {
                            saveExchangeRate = saveExchangeRateRAM
                        } else {
                            let errorText = NSLocalizedString("errorFirstText", comment: "Error Text") + String(i) + ": " + NSLocalizedString("errorAmountText", comment: "Error Date") + importedRecords[i][indexAmount ?? 0]
                            let errorText2 = NSLocalizedString("errorAmountText2", comment: "Error Text")
                            let answerError = UIAlertController(title: NSLocalizedString("errorTitle", comment: "Error Title"), message: (errorText + errorText2), preferredStyle: .alert)
                            answerError.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "forgotCodeOK"), style: .cancel, handler: { action in
                                self.cancel()
                            }))
                            answerError.popoverPresentationController?.sourceView = self.view
                            answerError.popoverPresentationController?.sourceRect = self.view.bounds
                            self.present(answerError, animated: true)
                            break
                        }
                    }
                    
                    var saveDescription = importedRecords[i][indexCategory ?? 0]
                    if indexDescription != nil {
                        saveDescription = importedRecords[i][indexDescription ?? 0]
                    }
                    
                    var categoryID:Int16 = -1
                    var isSave = false
                    let queryCategory = NSPredicate(format: "name == %@", importedRecords[i][indexCategory ?? 0] as NSString)
                    for category in loadBulkQueried(entitie: "Categories", query: queryCategory) {
                        categoryID = category.value(forKey: "cID") as? Int16 ?? -1
                        isSave = category.value(forKey: "isSave") as? Bool ?? false
                    }
                    
                    var currencyCode = Locale.current.currencyCode ?? "EUR"
                    if indexCurrencyCode != nil {
                        currencyCode = importedRecords[i][indexCurrencyCode ?? 0]
                    }
                    
                    saveRAMTransaction(amount: saveAmount, realAmount: (saveAmount/saveExchangeRate), category: importedRecords[i][indexCategory ?? 0], currencyCode: currencyCode, dateTime: date ?? Date(), descriptionNote: saveDescription, exchangeRate: saveExchangeRate, cID: categoryID, isSave: isSave)
                } else {
                    let errorText = NSLocalizedString("errorFirstText", comment: "Error Text") + String(i) + ": " + NSLocalizedString("errorAmountText", comment: "Error Date") + importedRecords[i][indexAmount ?? 0]
                    let errorText2 = NSLocalizedString("errorAmountText2", comment: "Error Text")
                    let answerError = UIAlertController(title: NSLocalizedString("errorTitle", comment: "Error Title"), message: (errorText + errorText2), preferredStyle: .alert)
                    answerError.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "forgotCodeOK"), style: .cancel, handler: { action in
                        self.cancel()
                    }))
                    answerError.popoverPresentationController?.sourceView = self.view
                    answerError.popoverPresentationController?.sourceRect = self.view.bounds
                    self.present(answerError, animated: true)
                    break
                }
            } else {
                let errorText = NSLocalizedString("errorFirstText", comment: "Error Date Text") + String(i) + ": " + NSLocalizedString("errorDateText", comment: "Error Date") + importedRecords[i][indexDate ?? 0]
                let answerError = UIAlertController(title: NSLocalizedString("errorTitle", comment: "Error Title"), message: errorText, preferredStyle: .alert)
                answerError.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "forgotCodeOK"), style: .cancel, handler: { action in
                    self.cancel()
                }))
                answerError.popoverPresentationController?.sourceView = self.view
                answerError.popoverPresentationController?.sourceRect = self.view.bounds
                self.present(answerError, animated: true)
                break
            }
        }
        return true
    }
    
    func sortRAMData() -> Bool {
        let dateSort = NSSortDescriptor(key: "dateTime", ascending: true)
        
        var timeDiff:Int = 1
        
        var preDate = Date()
        for importRAM in loadBulkSortedRAM(entitie: "ImportRAM", sort: [dateSort]) {
            
            let createDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: (importRAM.value(forKey: "dateTime") as? Date ?? Date()))!
            let createDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: (importRAM.value(forKey: "dateTime") as? Date ?? Date()))!
            
            let up = createDateMinus.compare(preDate) == .orderedAscending
            let down = createDatePlus.compare(preDate) == .orderedDescending
            
            if up && down {
                let dateTimeNew = Calendar.current.date(byAdding: .second, value: timeDiff, to: (importRAM.value(forKey: "dateTime") as? Date ?? Date()))!
                
                let querySave = NSPredicate(format: "dateTime < %@ AND dateTime > %@", createDatePlus as NSDate, createDateMinus as NSDate)
                
                saveSingleDate(entity: "ImportRAM", attibute: "dateTime", newValue: dateTimeNew, query: querySave)
                preDate = createDatePlus
                timeDiff = timeDiff + 1
            } else {
                preDate = (importRAM.value(forKey: "dateTime") as? Date ?? Date())
                timeDiff = 1
            }
        }
        return true
    }
    
    func getDate(dateString: String) -> Date? {
        let dateFormatterGet7 = DateFormatter()
        let dateFormatterGet8 = DateFormatter()
        let dateFormatterGet9 = DateFormatter()
        let dateFormatterGet10 = DateFormatter()
        let dateFormatterGet11 = DateFormatter()
        let dateFormatterGet12 = DateFormatter()
        let dateFormatterGet13 = DateFormatter()
        
        dateFormatterGet7.dateFormat = "yyyy-MM-dd"
        dateFormatterGet8.dateFormat = "yyyy/MM/dd"
        dateFormatterGet9.dateFormat = "dd-MM-yyyy"
        dateFormatterGet10.dateFormat = "dd/MM/yyyy"
        dateFormatterGet11.dateFormat = "dd.MM.yyyy"
        dateFormatterGet12.dateFormat = "MM-dd-yyyy"
        dateFormatterGet13.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = dateFormatterGet7.date(from: dateString) {
            return date
        } else if let date = dateFormatterGet7.date(from: dateString) {
            return date
        } else if let date = dateFormatterGet8.date(from: dateString) {
            return date
        } else if let date = dateFormatterGet9.date(from: dateString) {
            return date
        } else if let date = dateFormatterGet10.date(from: dateString) {
            return date
        } else if let date = dateFormatterGet11.date(from: dateString) {
            return date
        } else if let date = dateFormatterGet12.date(from: dateString) {
            return date
        } else if let date = dateFormatterGet13.date(from: dateString) {
            return date
        } else {
            return nil
        }
    }
    
    func getDayForDate(dayDate: Date) -> String {
        let calendar = Calendar.current
        
        let dayDateDateOnly = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: dayDate)
        let nowDateOnly = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: Date())
        
        let differenceInDays = Calendar.current.dateComponents([.day], from: dayDateDateOnly, to: nowDateOnly).day!
        
        if differenceInDays == 0 {
            return NSLocalizedString("today", comment: "Today")
        } else if differenceInDays == 1 {
            return NSLocalizedString("yesterday", comment: "Yesterday")
        } else if differenceInDays <= 7 && differenceInDays > 0 {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: dayDate)
        } else if differenceInDays == -1 {
            return NSLocalizedString("tomorrowText", comment: "Tomorrow")
        } else if differenceInDays == -2 {
            return NSLocalizedString("dayAfterTomorrowText", comment: "Day after Tomorrow")
        } else {
            return mediumDate.string(from: dayDate)
        }
    }
    
    @objc func doImport() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        let askImport = UIAlertController(title: NSLocalizedString("importTitle", comment: "Import Title"), message: NSLocalizedString("importText", comment: "Import Text"), preferredStyle: .alert)
        askImport.addAction(UIAlertAction(title: NSLocalizedString("deleteYes", comment: "Delete Yes"), style: .default, handler: { action in
            
            if self.importData() {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()

                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        }))
        askImport.addAction(UIAlertAction(title: NSLocalizedString("cancelImport", comment: "Cancel Import"), style: .cancel, handler: { action in
            self.activityIndicator.stopAnimating()
        }))
        askImport.popoverPresentationController?.sourceView = self.view
        askImport.popoverPresentationController?.sourceRect = self.view.bounds
        self.present(askImport, animated: true)
    }
    
    @objc func cancel() {
        deleteRAMData(entity: "ImportRAM")
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: -Document Picker
    func attachDocument() {
        let supportedTypes: [UTType] = [UTType.commaSeparatedText]
        let importMenu = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        if #available(iOS 11.0, *) {
            importMenu.allowsMultipleSelection = false
        }
        importMenu.shouldShowFileExtensions = true
        importMenu.modalPresentationStyle = .formSheet
        importMenu.delegate = self
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
    //        navigationBarAppearace.barTintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    //        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        }
        present(importMenu, animated: true)
    }
    
    func loadPreviewDATA(filePath:URL?) {
        readDataFromCSV(filePath: filePath, fileType: "csv")
    }
    
    // MARK: CSV
    func readDataFromCSV(filePath:URL?, fileType: String) {
        let fileName = filePath?.path
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        let importer = CSVImporter<[String]>(path: fileName ?? "", delimiter: delimiter ?? ";")
        importer.startImportingRecords() { $0 }.onFail {

            print("The CSV file couldn't be read.")
            
        }.onProgress { importedDataLinesCount in

        }.onFinish { importedRecords in
            self.entriesFound = importedRecords.count-1
            if self.checkHeader(header: importedRecords[0]) {
                if self.saveDataToRAMDB(importedRecords: importedRecords) {
                    if self.sortRAMData() {
                        self.createRowData()
                    }
                }
            } else {
                let answerError = UIAlertController(title: NSLocalizedString("errorTitle", comment: "Error Title"), message: NSLocalizedString("errorText", comment: "Error Text"), preferredStyle: .alert)
                answerError.addAction(UIAlertAction(title: NSLocalizedString("forgotCodeOK", comment: "forgotCodeOK"), style: .cancel, handler: { action in
                    self.cancel()
                }))
                answerError.popoverPresentationController?.sourceView = self.view
                answerError.popoverPresentationController?.sourceRect = self.view.bounds
                self.present(answerError, animated: true)
            }
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    func checkHeader(header:[String]) -> Bool {
        if header.contains(NSLocalizedString("bullet1", comment: "Amount")) && header.contains(NSLocalizedString("bullet2", comment: "Date")) && header.contains(NSLocalizedString("bullet3", comment: "Category")) {
            return true
        } else {
            return false
        }
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

extension importPreviewTVC {
    // MARK: - DATA
    // MARK: SAVE
    func saveRAMTransaction(amount: Double, realAmount:Double, category: String, currencyCode: String?, dateTime: Date, descriptionNote: String?, exchangeRate: Double = 1.0, cID: Int16, isSave: Bool) {
        let currencyCodeSave: String?
        if currencyCode == nil {
            currencyCodeSave = Locale.current.currencyCode ?? "EUR"
        } else {
            currencyCodeSave = currencyCode
        }

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentLocalContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let importSave = ImportRAM(context: managedContext)
        
        importSave.amount = amount
        importSave.category = category
        importSave.currencyCode = currencyCodeSave ?? ""
        importSave.dateTime = dateTime
        importSave.descriptionNote = descriptionNote ?? ""
        importSave.exchangeRate = exchangeRate
        importSave.categoryID = cID
        importSave.realAmount = realAmount
        importSave.isSave = isSave
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveNewCategory(categoryName:String, color: Int16) -> Int16 {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let categorySave = Categories(context: managedContext)
        
        let newCID = loadNextCategoryID()
        
        categorySave.cID = newCID
        categorySave.name = categoryName
        categorySave.isIncome = false
        categorySave.isSave = false
        categorySave.color = color
        categorySave.countEntries = 0
        
        var newCategoryDate = Date()
        
        var doubleCategory = true
        repeat {
            let dateTimeCategoryPlus = Calendar.current.date(byAdding: .second, value: 1, to: newCategoryDate)!
            let dateTimeCategoryMinus = Calendar.current.date(byAdding: .second, value: -1, to: newCategoryDate)!
            
            let querySaveTransaction = NSPredicate(format: "createDate < %@ AND createDate > %@", dateTimeCategoryPlus as NSDate, dateTimeCategoryMinus as NSDate)
            
            if loadBulkQueried(entitie: "Categories", query: querySaveTransaction).count > 0 {
                doubleCategory = true
                newCategoryDate = dateTimeCategoryPlus
            } else {
                doubleCategory = false
            }
        } while doubleCategory
        
        categorySave.createDate = newCategoryDate
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return -1
        }
        return newCID
    }
    
    func saveSingleDate(entity:String, attibute: String, newValue: Date, query: NSPredicate) {
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
    
    func saveSingleInt(entity:String, attibute: String, newValue: Int64, query: NSPredicate) {
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
    
    func saveTransaction(amount: Double, realAmount:Double, category: Int16, currencyCode: String?, dateTime: Date?, descriptionNote: String?, exchangeRate: Double = 1.0, tags: String?, isSave: Bool = false) {
        let currencyCodeSave: String?
        if currencyCode == nil {
            currencyCodeSave = Locale.current.currencyCode ?? "EUR"
        } else {
            currencyCodeSave = currencyCode
        }

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let transactionSave = Transactions(context: managedContext)
        
        transactionSave.amount = amount
        transactionSave.realAmount = realAmount
        transactionSave.categoryID = category
        transactionSave.currencyCode = currencyCodeSave ?? ""
        transactionSave.dateTime = dateTime ?? Date()
        transactionSave.descriptionNote = descriptionNote ?? ""
        transactionSave.exchangeRate = exchangeRate
        transactionSave.tags = tags ?? ""
        transactionSave.isSave = isSave
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func loadDataGrouped(entitie:String, groupByColumn:String) -> Any {
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
        
        do {
            let loadData = try managedContext.fetch(fetchRequest)
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return false
    }
    
    func loadNextCategoryID() -> Int16 {
        var i:Int16 = 0
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
        fetchRequest.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Categories.cID), ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let loadCategories = try managedContext.fetch(fetchRequest) as! [Categories]
            for data in loadCategories {
                if data.cID == i {
                    i = i + 1
                } else {
                    break
                }
            }
        } catch {
            print("Could not fetch. \(error)")
        }
        return i
    }
    
    // MARK: DELETE
    func deleteRAMData(entity: String) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentLocalContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
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
    
    // MARK: LOAD
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
    
    func loadBulkSortedRAM(entitie:String, sort:[NSSortDescriptor]) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentLocalContainer.viewContext
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
}

extension importPreviewTVC: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        loadPreviewDATA(filePath: urls[0])
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        navigationBarAppearace.barTintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
    }
    
     func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        navigationBarAppearace.barTintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        cancel()
    }
}
