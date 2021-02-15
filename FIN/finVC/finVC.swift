//
//  finVC.swift
//  FIN
//
//  Created by Florian Riel on 05.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData
import Charts

class finTVC: UITableViewController {

    @IBOutlet var finTableView: UITableView!
    
    var numberRows = 5
    
    var topOverviewCellData = [Int:Any]()
    var splitOverviewCellData = [Int:Any]()
    var categoryData = [[Int:Any]]()
    
    var numberFormatter = NumberFormatter()
    var mediumDate = DateFormatter()
    
    var initialView:Bool = true
        
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.tabBarController as? tabController)?.previousIndex = 0
        
//        saveInitialTransaction(amount: 100.0, descriptionNote: "INITIAL BALANCE", isSave: false)
        
//        print("lfjsdlfjdsfds")
//        print(loadBulkQueried(entitie: "Transactions", query: NSPredicate(format: "dateTime == nil")))
        
        // Init Data
        initSettingsAndData()
        
        self.title = ""
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTransactionTabbed))
        NotificationCenter.default.addObserver(self, selector: #selector(addTransactionTabbed), name: Notification.Name("showAddVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("updateFinVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("dataImported"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("transactionDeleted"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("transactionUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: Notification.Name("transactionAdded"), object: nil)
        
        mediumDate.dateStyle = .medium
        
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        
        initView()
        initData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if reloadFinView {//&& !initialView {
            reloadFinView = false
            refreshView()
        }
        initialView = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
        if let cell = finTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellTopOverview {
            cell.pieChart.clear()
            cell.pieChart.data?.dataSets.removeAll()
            
            let dataSet = PieChartDataSet(entries: (topOverviewCellData[1] as? [PieChartDataEntry]), label: "")
            dataSet.colors = (topOverviewCellData[2] as? [UIColor] ?? [UIColor.red])
            
            let data = PieChartData(dataSet: dataSet)
            
            cell.pieChart.data = data
            cell.pieChart.legend.enabled = false
            cell.pieChart.drawEntryLabelsEnabled = false
            cell.pieChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
            cell.pieChart.data?.setDrawValues(false)
            cell.pieChart.backgroundColor = .clear
            cell.pieChart.holeColor = .clear
            cell.pieChart.notifyDataSetChanged()

            let monthInt = Calendar.current.component(.month, from: Date())
            let monthStr = Calendar.current.monthSymbols[monthInt-1]
            
            var textColor = UIColor.white
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            if userInterfaceStyle == .light {
                textColor = UIColor.black
            }
            let centerTextText = monthStr.prefix(1).uppercased()
            let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
            let centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
            
            cell.pieChart.centerAttributedText = centerText
            
            let tabRecongnizerPie = UITapGestureRecognizer(target: self, action: #selector(switchToGraphs))
            cell.pieChart.addGestureRecognizer(tabRecongnizerPie)
            
            cell.pieChart.notifyDataSetChanged()
        }
    }
    
    // MARK: -TABLE
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 1:
            return getSubLabelCell(indexPath: indexPath)
        case 2:
            return getSplitTopOverviewCell(indexPath: indexPath)
        case 3:
            return getSubLabelCell(indexPath: indexPath)
        case 4:
            return getCategoriesOverviewCell(indexPath: indexPath)
        case 5:
            return getSavingsOverviewCell(indexPath: indexPath)
        default:
            return getTopOverviewCell(indexPath: indexPath)
        }
    }
    
    func getTopOverviewCell(indexPath: IndexPath) -> cellTopOverview {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTopOverview", for: indexPath) as! cellTopOverview
        
        cell.subLabel.text = NSLocalizedString("availableLabel", comment: "Available")
        cell.secondSubLabel.text = NSLocalizedString("lastEntryLabel", comment: "Latest Transaction")
        
        cell.mainLabel.text = numberFormatter.string(from: NSNumber(value: topOverviewCellData[0] as? Double ?? 0.00))
        
        if (topOverviewCellData[0] as? Double ?? 0.00) < 0.00 {
            cell.mainLabel.textColor = .red
        } else {
            cell.mainLabel.textColor = .label
        }
        
        cell.pieChart.clear()
        cell.pieChart.data?.dataSets.removeAll()
        
        let dataSet = PieChartDataSet(entries: (topOverviewCellData[1] as? [PieChartDataEntry]), label: "")
        dataSet.colors = (topOverviewCellData[2] as? [UIColor] ?? [UIColor.red])
        
        let data = PieChartData(dataSet: dataSet)
        
        cell.pieChart.data = data
        cell.pieChart.legend.enabled = false
        cell.pieChart.drawEntryLabelsEnabled = false
        cell.pieChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutQuart)
        cell.pieChart.data?.setDrawValues(false)
        cell.pieChart.backgroundColor = .clear
        cell.pieChart.holeColor = .clear
        cell.pieChart.notifyDataSetChanged()
        
        let monthInt = Calendar.current.component(.month, from: Date())
        let monthStr = Calendar.current.monthSymbols[monthInt-1]
        
        var textColor = UIColor.white
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            textColor = UIColor.black
        }
        let centerTextText = monthStr.prefix(1).uppercased()
        let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
        let centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
        
        cell.pieChart.centerAttributedText = centerText
        
        let tabRecongnizerPie = UITapGestureRecognizer(target: self, action: #selector(switchToGraphs))
        cell.pieChart.addGestureRecognizer(tabRecongnizerPie)
        
//        topOverviewCellData = [
//            0:getTotalBalance(),
//            1:pieChartData.0,
//            2:pieChartData.1,
//            3:realAmount,
//            4:descriptionNote,
//            5:color,
//            6:categoryName,
//            7:dateTime,
//            8:isSave,
//            9:isSplit
//        ]
        
        cell.circleView.backgroundColor = UIColor.randomColor(color: Int(topOverviewCellData[5] as? Int16 ?? 0), returnText: false, light: false)
        cell.circleView.layer.borderColor = cell.circleView.backgroundColor?.cgColor
        
        if (topOverviewCellData[6] as? String ?? "").count > 2 {
            cell.circleLabel.text = (topOverviewCellData[6] as? String ?? "").prefix(2).uppercased()
        } else if (topOverviewCellData[6] as? String ?? "").count > 1 {
            cell.circleLabel.text = (topOverviewCellData[6] as? String ?? "").prefix(1).uppercased()
        } else {
            cell.circleLabel.text = "CA"
        }
        cell.circleLabel.textColor = UIColor.randomColor(color: Int(topOverviewCellData[5] as? Int16 ?? 0), returnText: true, light: false)
        
        cell.transactionDescriptionLabel.text = (topOverviewCellData[4] as? String ?? "")
        
        if (topOverviewCellData[8] as? Bool ?? false) {
            cell.transactionIcon.isHidden = false
            cell.transactionIcon.image = UIImage(named: "safe")?.withRenderingMode(.alwaysTemplate)
        } else if (topOverviewCellData[9] as? Int16 ?? 0) == Int16(1) {
            cell.transactionIcon.isHidden = false
            cell.transactionIcon.image = UIImage(named: "tabPersonSelected")?.withRenderingMode(.alwaysTemplate)
        } else if (topOverviewCellData[9] as? Int16 ?? 0) == Int16(2) {
            cell.transactionIcon.isHidden = false
            cell.transactionIcon.image = UIImage(named: "tabPersonsSelected")?.withRenderingMode(.alwaysTemplate)
        } else {
            cell.transactionIcon.isHidden = true
        }
        
        cell.transactionSubLabel.text = getDayForDate(dayDate: (topOverviewCellData[7] as? Date ?? Date()))
        
        cell.transactionAmount.text = numberFormatter.string(from: NSNumber(value: (topOverviewCellData[3] as? Double ?? 0.00)))
        
        cell.transactionArrowIcon.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        
        if (topOverviewCellData[7] as? Date) != nil {
            if !UIDevice().model.contains("iPad") {
                let interaction = UIContextMenuInteraction(delegate: self)
                cell.latestTransactionStackView.addInteraction(interaction)
            }
            
            let tabRecongnizer = UITapGestureRecognizer(target: self, action: #selector(switchToList))
            cell.latestTransactionStackView.addGestureRecognizer(tabRecongnizer)
        }
        
        return cell
    }
    
    func getSplitTopOverviewCell(indexPath: IndexPath) -> cellSplitTopOverview {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSplitTopOverview", for: indexPath) as! cellSplitTopOverview
        
        cell.leftSubLabel.text = splitOverviewCellData[0] as? String ?? ""
        cell.leftIcon.image = UIImage(named: "tabPersonSelected")?.withRenderingMode(.alwaysTemplate)
        cell.leftAmountLabel.text = numberFormatter.string(from: NSNumber(value: (splitOverviewCellData[1] as? Double ?? 0.00)))
        
        cell.rightSubLabel.text = splitOverviewCellData[2] as? String ?? ""
        cell.rightIcon.image = UIImage(named: "tabPersonSelected")?.withRenderingMode(.alwaysTemplate)
        cell.rightAmountLabel.text = numberFormatter.string(from: NSNumber(value: (splitOverviewCellData[3] as? Double ?? 0.00)))
        
        let tabRecongnizerRight = UITapGestureRecognizer(target: self, action: #selector(switchToSplitsRight))
        cell.rightOutlineView.addGestureRecognizer(tabRecongnizerRight)
        
        let tabRecongnizerLeft = UITapGestureRecognizer(target: self, action: #selector(switchToSplitsLeft))
        cell.leftOutlineView.addGestureRecognizer(tabRecongnizerLeft)
        
        return cell
    }
    
    func getCategoriesOverviewCell(indexPath: IndexPath) -> cellCategoriesOverview {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategoriesOverview", for: indexPath) as! cellCategoriesOverview
        cell.Delegate = self
        return cell
    }
    
    func getSavingsOverviewCell(indexPath: IndexPath) -> cellSavingsOverview {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSavingsOverview", for: indexPath) as! cellSavingsOverview
        return cell
    }
    
    func getSubLabelCell(indexPath: IndexPath) -> subtitleCellTVC {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath) as! subtitleCellTVC
        
        if indexPath.row == 1 {
            cell.subtitleLabel.text = NSLocalizedString("splitsSubLabel", comment: "Splits")
        } else if indexPath.row == 3 {
            let monthInt = Calendar.current.component(.month, from: Date())
            let monthStr = Calendar.current.monthSymbols[monthInt-1]
            cell.subtitleLabel.text = monthStr
            // cell.subtitleLabel.text = NSLocalizedString("categoriesSubLabel", comment: "Categories")
        }
        return cell
    }
    
    // MARK: -VIEW
    func initView() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.navigationController?.view.backgroundColor = backgroundGeneralColor
            view.backgroundColor = backgroundGeneralColor
            finTableView.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            finTableView.backgroundColor = .secondarySystemBackground
        }
        
        finTableView.contentInset = UIEdgeInsets(
            top: 0,//(max(view.frame.height,view.frame.width) * collectionViewHeightFactor),
            left: 0,
            bottom: 5,
            right: 0
        )
    }
    
    // MARK: -Init Data
    func initData() {
        topOverviewCellData.removeAll()
        splitOverviewCellData.removeAll()
        
        getTopOverViewData()
        getSplitOverviewData()
    }
    
    func getTopOverViewData() {
        let pieChartData = getPieChartDate()
        
        var realAmount:Double = 0.00
        var descriptionNote:String = NSLocalizedString("noTransaction", comment: "None yet")
        var color:Int16 = 0
        var categoryName:String = "Category"
        var dateTime:Date?
        var isSave:Bool = false
        var isSplit:Int16 = 2
        
        let dateSort = NSSortDescriptor(key: "dateTime", ascending: false)
        if let transaction = loadBulkSortedOneEntry(entitie: "Transactions", sort: [dateSort]) as? NSManagedObject {
            realAmount = transaction.value(forKey: "realAmount") as? Double ?? 0.00
            descriptionNote = transaction.value(forKey: "descriptionNote") as? String ?? ""
            dateTime = transaction.value(forKey: "dateTime") as? Date ?? Date()
            isSplit = transaction.value(forKey: "isSplit") as? Int16 ?? 0
            
            let queryCategory = NSPredicate(format: "cID == %i", (transaction.value(forKey: "categoryID") as? Int16 ?? 0))
            color = loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0
            categoryName = loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? ""
            isSave = loadQueriedAttribute(entitie: "Categories", attibute: "isSave", query: queryCategory) as? Bool ?? false
            if !isSave && !(loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false) {
                realAmount = -realAmount
            }
        }
        
        topOverviewCellData = [
            0:getTotalBalance(),
            1:pieChartData.0,
            2:pieChartData.1,
            3:realAmount,
            4:descriptionNote,
            5:color,
            6:categoryName,
            7:dateTime as Any,
            8:isSave,
            9:isSplit
        ]
    }
    
    func getSplitOverviewData() {
        let splitBalances = getSplitBalances()
        
        splitOverviewCellData = [
            0:NSLocalizedString("youAreOwedLabel", comment: "you get"),
            1:splitBalances.0,
            2:NSLocalizedString("youBorrowedLabel", comment: "you get"),
            3:splitBalances.1
        ]
    }
    
    func getTotalBalance() -> Double {
        var balance = 0.00
        
        // get Sum Expenses
        // get Category IDs which are Expenses
        var expensesIDsArray = [Int16]()
        let queryExpenses = NSPredicate(format: "isSave == %@ AND isIncome == %@", NSNumber(value: false), NSNumber(value: false))
        for expense in loadBulkQueried(entitie: "Categories", query: queryExpenses) {
            expensesIDsArray.append(expense.value(forKey: "cID") as? Int16 ?? 0)
        }
        let queryExpensesSum = NSPredicate(format: "categoryID IN %@ AND dateTime != nil", expensesIDsArray)
        let ramValueExpenses = (loadDataSUM(entitie: "Transactions", query: queryExpensesSum) as? [[String:Any]])
        if (ramValueExpenses?.count ?? 0) > 0 {
            balance = (ramValueExpenses?[0]["sum"] as? Double ?? 0.00)
        }
        
        // get Sum Income
        // get Category IDs which are Income
        var incomeIDsArray = [Int16]()
        let queryIncome = NSPredicate(format: "isSave == %@ AND isIncome == %@", NSNumber(value: false), NSNumber(value: true))
        for income in loadBulkQueried(entitie: "Categories", query: queryIncome) {
            incomeIDsArray.append(income.value(forKey: "cID") as? Int16 ?? 0)
        }
        let queryIncomeSum = NSPredicate(format: "categoryID IN %@ AND dateTime != nil", incomeIDsArray)
        let ramValueIncome = (loadDataSUM(entitie: "Transactions", query: queryIncomeSum) as? [[String:Any]])
        if (ramValueIncome?.count ?? 0) > 0 {
            balance = (ramValueIncome?[0]["sum"] as? Double ?? 0.00) - balance
        }
        
        // get Sum Savings
        var savingsIDsArray = [Int16]()
        let querySavings = NSPredicate(format: "isSave == %@", NSNumber(value: true))
        for saving in loadBulkQueried(entitie: "Categories", query: querySavings) {
            savingsIDsArray.append(saving.value(forKey: "cID") as? Int16 ?? 0)
        }
        let querySavingsSum = NSPredicate(format: "categoryID IN %@ AND isLiquid == %@ AND dateTime != nil", savingsIDsArray, NSNumber(value: true))
        let ramValueSave = (loadDataSUM(entitie: "Transactions", query: querySavingsSum) as? [[String:Any]])
        if (ramValueSave?.count ?? 0) > 0 {
            balance = balance - (ramValueSave?[0]["sum"] as? Double ?? 0.00)
        }
        
        // Get Initial Payments
        let queryInitialExpense = NSPredicate(format: "dateTime == nil")
        for initialTransaction in loadBulkQueried(entitie: "Transactions", query: queryInitialExpense) {
            let queryCategory = NSPredicate(format: "cID == %i", (initialTransaction.value(forKey: "categoryID") as? Int16 ?? -1))
            let isIncome = loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false
            
            if (initialTransaction.value(forKey: "isLiquid") as? Bool ?? false) {
                if isIncome {
                    balance = balance + (initialTransaction.value(forKey: "realAmount") as? Double ?? 0.00)
                } else {
                    balance = balance - (initialTransaction.value(forKey: "realAmount") as? Double ?? 0.00)
                }
            }
        }
        
        return balance
    }
    
    func getPieChartDate() -> ([PieChartDataEntry],[UIColor]) {
        var entries = [PieChartDataEntry]()
        var colors = [UIColor]()
        
        let fromDate = Date().startOfMonth
        let toDate = Date().endOfMonth
        
        var expensesIDsArray = [Int16]()
        let queryExpenses = NSPredicate(format: "isSave == %@ AND isIncome == %@", NSNumber(value: false), NSNumber(value: false))
        for expense in loadBulkQueried(entitie: "Categories", query: queryExpenses) {
            expensesIDsArray.append(expense.value(forKey: "cID") as? Int16 ?? 0)
        }
        
        let queryPieChart = NSPredicate(format: "dateTime > %@ AND dateTime <= %@ AND categoryID IN %@", fromDate as NSDate, toDate as NSDate, expensesIDsArray)
        
        let data = loadDataGroupedSUM(entitie: "Transactions", groupByColumn: "categoryID", query: queryPieChart) as? [[String:Any]]
        if (data?.count ?? 0) > 0 {
            for i in 0...((data?.count ?? 1)-1) {
                let queryCategory = NSPredicate(format: "cID == %i", (data?[i]["categoryID"] as? Int16 ?? 0))
                entries.append(PieChartDataEntry(value: (data?[i]["sum"] as? Double ?? 0.00), label: (loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? "")))
                colors.append(UIColor.randomColor(color: Int((loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0)), returnText: false, light: false))
            }
        }
        return (entries,colors)
    }
    
    func getSplitBalances() -> (Double,Double) {
        var sumOwed = 0.00
        var sumBorrowed = 0.00
        
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        let queryIsUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
        
        var nameUser:String?
        var createDateUser:Date?
        
        for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryIsUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
        
        let userDateUserPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        let userDateUserMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
        
        let dateSort = NSSortDescriptor(key: "createDate", ascending: false)
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: false))
        
        for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [dateSort]) {
            var sum = 0.00

            let createDatePerson = (data.value(forKey: "createDate") as? Date ?? Date())
            
            let createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDatePerson)!
            let createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDatePerson)!
            
            let query = NSPredicate(format: "namePerson == %@ AND createDatePerson < %@ AND createDatePerson > %@", (data.value(forKey: "namePerson") as! NSString), (createDatePersonPlus as NSDate), (createDatePersonMinus as NSDate))
            let dateSort = NSSortDescriptor(key: "dateTimeTransaction", ascending: false)
            
            var userIsPartOfSplit:Bool?
            
            for split in loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [dateSort]) {
                if userPartOfSplit(dateTime: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date())) {
                    userIsPartOfSplit = true
                } else {
                    continue
                }
                
                if !personOrUserPaid(dateTimeTransaction: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()), namePerson: (data.value(forKey: "namePerson") as? String ?? ""), dateTimeUser: createDatePerson) {
                    continue
                }
                
                let createTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                let createTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (split.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                
                let query = NSPredicate(format: "dateTime < %@ AND dateTime > %@", (createTransactionPlus as NSDate), (createTransactionMinus as NSDate))
                let dateSort = NSSortDescriptor(key: "dateTime", ascending: false)
                
                for transaction in loadBulkQueriedSorted(entitie: "Transactions", query: query, sort: [dateSort]) {
                    let exchangeRate = (transaction.value(forKey: "exchangeRate") as? Double ?? 1.00)
                    
                    let settled = (split.value(forKey: "settled") as? Double ?? 0.00)/exchangeRate
                    let sumTransaction = (transaction.value(forKey: "amount") as? Double ?? 0.00)/exchangeRate
                    
                    if userIsPartOfSplit ?? false {
                        if (split.value(forKey: "paidByUser") as? Bool ?? true) {
                            let ratio = (split.value(forKey: "ratio") as? Double ?? 0.00)
                            sum = sum - (sumTransaction*ratio) + settled
                        } else {
                            let queryUserRatio = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@ AND dateTimeTransaction < %@ AND dateTimeTransaction > %@", (userDateUserPlus as NSDate), (userDateUserMinus as NSDate), (nameUser ?? "") as NSString, (createTransactionPlus as NSDate), (createTransactionMinus as NSDate))
                            let ratio = loadQueriedAttribute(entitie: "Splits", attibute: "ratio", query: queryUserRatio) as? Double ?? (1-(split.value(forKey: "ratio") as? Double ?? 0.00))
                            let settledUser = (loadQueriedAttribute(entitie: "Splits", attibute: "settled", query: queryUserRatio) as? Double ?? (1-(split.value(forKey: "ratio") as? Double ?? 0.00)))/exchangeRate
                            sum = sum + sumTransaction*ratio - settledUser
                        }
                    }
                }
            }
            if sum < 0 {
                sum = abs(sum)
                sumOwed = sumOwed + sum
            } else {
                sumBorrowed = sumBorrowed + sum
            }
        }
        return (sumOwed,sumBorrowed)
    }
    
    @objc func refreshView() {
        initData()
        finTableView.reloadData()
    }
    
    @objc func addTransactionTabbed() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toAddSeque", sender: nil)
        }
    }
    
    @objc func switchToList() {
        if let cell = finTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellTopOverview {
            UIView.animate(withDuration: 0.1, animations: {
                cell.latestTransactionStackView.transform = cell.latestTransactionStackView.transform.scaledBy(x: 0.96, y: 0.96)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.1, animations: {
                    cell.latestTransactionStackView.transform = CGAffineTransform.identity
                }, completion: { _ in
                    self.openEditTransaction()
                })
            })
        }
    }
    
    func openEditTransaction() {
        let listStoryBoard: UIStoryboard = UIStoryboard(name: "listTSB", bundle: nil)
        let detailVC = listStoryBoard.instantiateViewController(withIdentifier: "TransactionDetail") as! listDetailTVC
    
        if let latestTransactionDate = topOverviewCellData[7] as? Date {
            detailVC.dateOfSelectedRow = latestTransactionDate
            detailVC.superSplit = true
        }
    
        let navigationVC = UINavigationController(rootViewController: detailVC)
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func switchToListByCategory() {
        
        (self.tabBarController as? tabController)?.previousIndex = 1
        self.tabBarController?.selectedIndex = 1
    }
    
    @objc func switchToGraphs() {
        if let cell = finTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? cellTopOverview {
            UIView.animate(withDuration: 0.1, animations: {
                cell.pieChart.transform = cell.pieChart.transform.scaledBy(x: 0.9, y: 0.9)
                }, completion: { _ in
                  // Step 2
                  UIView.animate(withDuration: 0.1, animations: {
                    cell.pieChart.transform = CGAffineTransform.identity
//                    UIImpactFeedbackGenerator().impactOccurred()
                  }, completion: { _ in
                    (self.tabBarController as? tabController)?.previousIndex = 2
                    self.tabBarController?.selectedIndex = 2
                  })
                })
        }
    }
    
    @objc func switchToSplitsLeft() {
        if let cell = finTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? cellSplitTopOverview {
            UIView.animate(withDuration: 0.1, animations: {
                cell.leftOutlineView.transform = cell.leftOutlineView.transform.scaledBy(x: 0.93, y: 0.93)
                }, completion: { _ in
                  // Step 2
                  UIView.animate(withDuration: 0.1, animations: {
                    cell.leftOutlineView.transform = CGAffineTransform.identity
//                    UIImpactFeedbackGenerator().impactOccurred()
                  }, completion: { _ in
                    (self.tabBarController as? tabController)?.previousIndex = 3
                    self.tabBarController?.selectedIndex = 3
                  })
                })
        }
    }
    
    @objc func switchToSplitsRight() {
        if let cell = finTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? cellSplitTopOverview {
            UIView.animate(withDuration: 0.1, animations: {
                cell.rightOutlineView.transform = cell.rightOutlineView.transform.scaledBy(x: 0.93, y: 0.93)
                }, completion: { _ in
                  // Step 2
                  UIView.animate(withDuration: 0.1, animations: {
                    cell.rightOutlineView.transform = CGAffineTransform.identity
//                    UIImpactFeedbackGenerator().impactOccurred()
                  }, completion: { _ in
                    (self.tabBarController as? tabController)?.previousIndex = 3
                    self.tabBarController?.selectedIndex = 3
                  })
                })
        }
    }
    
    // MARK: -HELPER FUNCTIONS
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
    
    func userPartOfSplit(dateTime: Date) -> Bool {
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
        
        let datePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTime)!
        let dateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTime)!
        
        let query = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePerson == %@ AND createDatePerson > %@ AND createDatePerson < %@", (dateMinus as NSDate), (datePlus as NSDate), ((nameUser ?? "") as NSString), ((userDateMinus) as NSDate), ((userDatePlus) as NSDate))
        if loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [nameSort]).count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func personOrUserPaid(dateTimeTransaction: Date, namePerson: String, dateTimeUser: Date) -> Bool {
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        
        let personDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTimeUser)!
        let personDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTimeUser)!
        
        let dateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTimeTransaction)!
        let dateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTimeTransaction)!
        
        let query = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePersonWhoPaid == %@ AND createDatePersonWhoPaid > %@ AND createDatePersonWhoPaid < %@", (dateTransactionMinus as NSDate), (dateTransactionPlus as NSDate), (namePerson as NSString), (personDateMinus as NSDate), (personDatePlus as NSDate))
        
        if loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [nameSort]).count > 0 {
            return true
        }
        
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
            
        var nameUser:String?
        var createDateUser:Date?
        
        for data in loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
            
        let userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        let userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
            
        let queryUserPaid = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePersonWhoPaid == %@ AND createDatePersonWhoPaid > %@ AND createDatePersonWhoPaid < %@", (dateTransactionMinus as NSDate), (dateTransactionPlus as NSDate), ((nameUser ?? "") as NSString), (userDateMinus as NSDate), (userDatePlus as NSDate))
            
        if loadBulkQueriedSorted(entitie: "Splits", query: queryUserPaid, sort: [nameSort]).count <= 0 {
            return false
        } else {
            return true
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

// MARK: CHARTDELEGATE
extension finTVC: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        return
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        return
    }
}

extension finTVC: cellCategoriesOverviewDelegate {
    func switchToListPressed() {
        switchToListByCategory()
    }
}

extension finTVC: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
              identifier: nil,
              previewProvider: makeDetailPreview,
              actionProvider: { _ in
                let children: [UIMenuElement] = [self.makeDeleteAction()]
                return UIMenu(title: "", children: children)
            })
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            self.show(self.makeDetailPreview(), sender: self)
        }
    }
    
    func makeDeleteAction() -> UIAction {
      return UIAction(
        title: "Delete",
        image: UIImage(systemName: "trash"),
        attributes: .destructive,
        handler: deleteTransaction)
    }
    
    func makeDetailPreview() -> UIViewController {
        let finStoryBoard: UIStoryboard = UIStoryboard(name: "finTSB", bundle: nil)
        let addVC = finStoryBoard.instantiateViewController(withIdentifier: "addTVC") as! addTVC
        
        if let latestTransactionDate = topOverviewCellData[7] as? Date {
            addVC.updateCreateDate = latestTransactionDate
        }
        
        let navigationVC = UINavigationController(rootViewController: addVC)
        return navigationVC
    }
    
    func deleteTransaction(from action: UIAction) {
        let dateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: topOverviewCellData[7] as? Date ?? Date())!
        let dateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: topOverviewCellData[7] as? Date ?? Date())!
        
        let queryDelete = NSPredicate(format: "dateTime < %@ AND dateTime > %@", dateTransactionPlus as NSDate, dateTransactionMinus as NSDate)
        deleteDataQueried(entity: "Transactions", query: queryDelete)
        
        let querySplits = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", dateTransactionPlus as NSDate, dateTransactionMinus as NSDate)
        deleteDataQueried(entity: "Splits", query: querySplits)
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("transactionDeleted"), object: nil)
    }
}

// MARK: -DATA
extension finTVC {
    func saveInitialTransaction(amount: Double, descriptionNote: String?,isSave: Bool = false, isLiquid:Bool = true) -> Bool {
        let currencyCodeSave = Locale.current.currencyCode ?? "EUR"
        let isSplit:Int16 = 0

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let transactionSave = Transactions(context: managedContext)
        
        transactionSave.amount = amount
        transactionSave.realAmount = amount
        transactionSave.categoryID = 0
        transactionSave.currencyCode = currencyCodeSave
        transactionSave.dateTime = nil
        transactionSave.descriptionNote = descriptionNote ?? ""
        transactionSave.exchangeRate = 1.0
        transactionSave.tags = ""
        transactionSave.isSave = isSave
        transactionSave.isSplit = isSplit
        transactionSave.isLiquid = isLiquid
                
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
        return true
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
    
    func loadDataSUM(entitie:String, query:NSPredicate) -> Any {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
        let keypathExp1 = NSExpression(forKeyPath: "realAmount") // can be any column
        let expression1 = NSExpression(forFunction: "sum:", arguments: [keypathExp1])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression1
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToFetch = [sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let loadData = try managedContext.fetch(fetchRequest)
            return loadData
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
    
    func loadBulkSortedOneEntry(entitie:String, sort:[NSSortDescriptor]) -> Any {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "dateTime != nil")
        fetchRequest.sortDescriptors = sort
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if loadData.count > 0 {
                return loadData[0]
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
    
    func loadDataGroupedSUM(entitie:String, groupByColumn:String, query:NSPredicate) -> Any {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
        let keypathExp1 = NSExpression(forKeyPath: "realAmount") // can be any column
        let expression1 = NSExpression(forFunction: "sum:", arguments: [keypathExp1])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression1
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        
        let keypathExp2 = NSExpression(forKeyPath: groupByColumn) // can be any column
        let expression2 = NSExpression(forFunction: "count:", arguments: [keypathExp2])
        
        let countDesc = NSExpressionDescription()
        countDesc.expression = expression2
        countDesc.name = "count"
        countDesc.expressionResultType = .integer64AttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = [groupByColumn]
        fetchRequest.propertiesToFetch = [groupByColumn, countDesc ,sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let loadData = try managedContext.fetch(fetchRequest)
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return false
    }
    
    func deleteDataQueried(entity: String, query: NSPredicate) {
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
    
    // MARK: -INIT DATA
    func initSettingsAndData() {
        saveNewSettings()
        
        let numberCurrencies = loadBulk(entitie: "Currency").count
        if numberCurrencies != 33 {
            deleteData(entity: "Currency")
            saveExchangeRates()
        }

        if loadBulk(entitie: "GraphSettings").count <= 0 {
            saveNewGraphs()
        }
    }
    
    func saveNewSettings() {
        let countSettings = loadBulk(entitie: "Settings").count
        var firstDate = Date()
        var showAddsRAM:Bool = true
        var trueUserName = NSLocalizedString("userTitle", comment: "User")
    
        let loginEnabledSafe = false
        var firstLaunch = true
        var filteredTagsZero = false
        var filteredCategoriesZero = false
        var recoveryMail = ""
        var lastCurrencyCodeSafe = Locale.current.currencyCode ?? "EUR"
        var userColorSafe = Int16(0)
        var userCodeSafe = ""
        
        if countSettings > 1 {
            trueUserName = loadSettingsOldest(entitie: "Settings", attibute: "userName") as? String ?? NSLocalizedString("userTitle", comment: "User")
            firstDate = loadSettingsOldest(entitie: "Settings", attibute: "firstLaunchDate") as? Date ?? Date()
            showAddsRAM = loadSettingsOldest(entitie: "Settings", attibute: "showAdds") as? Bool ?? true
//            loginEnabledSafe = loadSettingsOldest(entitie: "Settings", attibute: "loginEnabled") as? Bool ?? false
            firstLaunch = loadSettingsOldest(entitie: "Settings", attibute: "firstLaunch") as? Bool ?? false
            filteredTagsZero = loadSettingsOldest(entitie: "Settings", attibute: "filteredTagsZero") as? Bool ?? false
            filteredCategoriesZero = loadSettingsOldest(entitie: "Settings", attibute: "filteredCategoriesZero") as? Bool ?? false
            recoveryMail = loadSettingsOldest(entitie: "Settings", attibute: "recoveryMail") as? String ?? ""
            lastCurrencyCodeSafe = loadSettingsOldest(entitie: "Settings", attibute: "lastCurrencyCode") as? String ?? ""
            userColorSafe = loadSettingsOldest(entitie: "Settings", attibute: "userColor") as? Int16 ?? 0
            userCodeSafe = loadSettingsOldest(entitie: "Settings", attibute: "userCode") as? String ?? ""
            
            deleteData(entity: "Settings")
        }
        
        let countSettings2 = loadBulk(entitie: "Settings").count
        if countSettings2 <= 0 {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedContext = appDelegate!.persistentContainer.viewContext
            managedContext.automaticallyMergesChangesFromParent = true
            managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
            let settingsSave = Settings(context: managedContext)
            
            settingsSave.userCode = ""
            settingsSave.showAdds = true
            settingsSave.firstLaunchDate = Date()
                
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
        if countSettings > 1 {
            saveSettings(settingsChange: "firstLaunch", newValue: false)
            saveSettings(settingsChange: "firstLaunchDate", newValue: firstDate)
            saveSettings(settingsChange: "showAdds", newValue: showAddsRAM)
            saveSettings(settingsChange: "userName", newValue: trueUserName)
            saveSettings(settingsChange: "loginEnabled", newValue: loginEnabledSafe)
            saveSettings(settingsChange: "firstLaunch", newValue: firstLaunch)
            saveSettings(settingsChange: "filteredTagsZero", newValue: filteredTagsZero)
            saveSettings(settingsChange: "filteredCategoriesZero", newValue: filteredCategoriesZero)
            saveSettings(settingsChange: "recoveryMail", newValue: recoveryMail)
            saveSettings(settingsChange: "lastCurrencyCode", newValue: lastCurrencyCodeSafe)
            saveSettings(settingsChange: "userColor", newValue: userColorSafe)
            saveSettings(settingsChange: "userCode", newValue: userCodeSafe)
        }
    }
    
    func loadBulk(entitie:String) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
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
    
    func deleteData(entity: String) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
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
    
    func saveSettings(settingsChange: String, newValue: Any) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fetchedSettings = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if fetchedSettings.count > 0 {
                fetchedSettings[0].setValue(newValue, forKey: settingsChange)
            }
            try managedContext.save()
        } catch {
            fatalError("Failed to fetch recordings: \(error)")
        }
    }
    
    func loadSettings(entitie:String, attibute:String) -> Any {
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
    
    func loadSettingsOldest(entitie:String, attibute:String) -> Any {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstLaunchDate", ascending: true)]
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
    
    func saveNewGraphs() {
        for i in 0...1 {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedContext = appDelegate!.persistentContainer.viewContext
            managedContext.automaticallyMergesChangesFromParent = true
            managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
            let graphSave = GraphSettings(context: managedContext)
            
            graphSave.graphID = Int16(i)
            if i == 0 {
                graphSave.graphName = NSLocalizedString("lineChartTitle", comment: "Line Cahrt")
                graphSave.graphActive = false
            } else if i == 1 {
                graphSave.graphName = NSLocalizedString("barChartTitle", comment: "Bar Cahrt")
                graphSave.graphActive = true
            }
            graphSave.graphOption1 = Int16(0)
            graphSave.graphOption2 = Int16(0)
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func saveExchangeRates() {
        var data = readDataFromCSV(fileName: "currency_table", fileType: "csv")
        data = cleanRows(file: data ?? "")
        let csvRows = csv(data: data ?? "", sep: ";")
        
        var j:Int16 = 0
        for currency in csvRows {
            self.saveCurrency(currencyCode: currency[0], exchangeRate: 1.0, automated: false, id: j)
            j = j+1
        }
    }
    
    func csv(data: String, sep: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: sep)
            result.append(columns)
        }
        return result
    }
        
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
    
    func saveCurrency(currencyCode: String, exchangeRate: Double?, automated: Bool, id: Int16) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let currencySave = Currency(context: managedContext)
        
        currencySave.currencyCode = currencyCode
        currencySave.exchangeRate = exchangeRate ?? 1.0
        currencySave.automated = automated
        currencySave.saved = Date()
        currencySave.id = id
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
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
}
