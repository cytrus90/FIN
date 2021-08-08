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
    
    var selectedFirst = 0
    var selectedSecond = 0
    var activeBudget = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.tabBarController as? tabController)?.previousIndex = 0
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(categoyTimeRangeChanged(notification:)), name: Notification.Name("finVCCategoyTimeRangeChanged"), object: nil)
        
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
        
        if let cell = finTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? cellSubtitleStack {
            cell.initSelectedCell(selectedIndex: selectedSecond)
        }
        if let cell = finTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSubtitleStack {
            cell.setLargeStackTrailingConstraint()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
        refreshPieChart()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            if let cell = self.finTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? cellSubtitleStack {
                var numberSegments = 2
                if (self.activeBudget && (self.view.frame.height < self.view.frame.width)) || (!UIDevice().model.contains("iPhone") && self.activeBudget) {
                    numberSegments = 3
                } else if self.selectedSecond >= 3 {
                    self.selectedSecond = 2
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name("finVCCategoyTimeRangeChanged"), object: nil, userInfo: ["selectedLabel": self.selectedSecond, "selectedCell": 3])
                }
                
                if numberSegments == 2 && cell.stackView.arrangedSubviews.count == 4 {
                    cell.stackView.arrangedSubviews[3].removeFromSuperview()
                } else if numberSegments == 3 && cell.stackView.arrangedSubviews.count == 3 {
                    let label = UILabel()
                    
                    label.text = NSLocalizedString("totalLabel", comment: "Total")
                    label.font = UIFont.preferredFont(forTextStyle: .subheadline)
                    label.textColor = .label
                    label.textAlignment = .center
                    label.numberOfLines = 0
                    
                    if self.selectedSecond == 3 {
                        label.alpha = 1.0
                    } else {
                        label.alpha = 0.3
                    }
                    label.tag = 3
                    cell.stackView.addArrangedSubview(label)
                }
                cell.initSelectedCell(selectedIndex: self.selectedSecond)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let cell = finTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? cellSubtitleStack {
            var numberSegments = 2
            if (activeBudget && (view.frame.height < view.frame.width)) || (!UIDevice().model.contains("iPhone") && activeBudget ) {
                numberSegments = 3
            } else if selectedSecond >= 3 {
                selectedSecond = 2
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name("finVCCategoyTimeRangeChanged"), object: nil, userInfo: ["selectedLabel": self.selectedSecond, "selectedCell": 3])
            }
            
            if numberSegments == 2 && cell.stackView.arrangedSubviews.count == 4 {
                cell.stackView.arrangedSubviews[3].removeFromSuperview()
            } else if numberSegments == 3 && cell.stackView.arrangedSubviews.count == 3 {
                let label = UILabel()
                
                label.text = NSLocalizedString("totalLabel", comment: "Total")
                label.font = UIFont.preferredFont(forTextStyle: .subheadline)
                label.textColor = .label
                label.textAlignment = .center
                label.numberOfLines = 0
                
                if selectedSecond == 3 {
                    label.alpha = 1.0
                } else {
                    label.alpha = 0.3
                }
                label.tag = 3
                cell.stackView.addArrangedSubview(label)
            }
            cell.initSelectedCell(selectedIndex: self.selectedSecond)
        }
        if let cell = finTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? cellSubtitleStack {
            cell.setLargeStackTrailingConstraint()
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
        
        var centerText:NSAttributedString?
        var textColor = UIColor.white
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            textColor = UIColor.black
        }
        if selectedSecond == 0 && activeBudget {
            let centerTextText = NSLocalizedString("budgetLabel", comment: "Budget").prefix(1).uppercased()
            let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
            centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
        } else if (selectedSecond == 0 && !activeBudget) || (selectedSecond == 1 && activeBudget) {
            let monthInt = Calendar.current.component(.month, from: Date())
            let monthStr = Calendar.current.monthSymbols[monthInt-1]
            let centerTextText = monthStr.prefix(1).uppercased()
            let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
            centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
        } else if (selectedSecond == 1 && !activeBudget) || (selectedSecond == 2 && activeBudget) {
            let centerTextText = NSLocalizedString("yearOneDigit", comment: "Y")
            let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
            centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
        } else if (selectedSecond == 2 && !activeBudget) || (selectedSecond == 3 && activeBudget) {
            let centerTextText = NSLocalizedString("totalLabel", comment: "Total").prefix(1).uppercased()
            let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
            centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
        }
        
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
//            9:isSplit,
//            10:icon,
//            11:isLight
//        ]
        
        cell.circleView.backgroundColor = UIColor.randomColor(color: Int(topOverviewCellData[5] as? Int16 ?? 0))
        cell.circleView.layer.borderColor = cell.circleView.backgroundColor?.cgColor
        
        if (topOverviewCellData[10] as? String ?? "").count > 0 {
            cell.circleLabel.isHidden = true
            cell.circleImage.isHidden = false
            
            var selectedIcon = (topOverviewCellData[10] as? String ?? "").replacingOccurrences(of: "_white", with: "")
            if (topOverviewCellData[11] as? Bool ?? true) {
                selectedIcon = selectedIcon + "_white"
            }
            cell.circleImage.image = UIImage(named: selectedIcon)
        } else {
            cell.circleImage.isHidden = true
            cell.circleLabel.isHidden = false
            
            if (topOverviewCellData[6] as? String ?? "").count > 2 {
                cell.circleLabel.text = (topOverviewCellData[6] as? String ?? "").prefix(2).uppercased()
            } else if (topOverviewCellData[6] as? String ?? "").count > 1 {
                cell.circleLabel.text = (topOverviewCellData[6] as? String ?? "").prefix(1).uppercased()
            } else {
                cell.circleLabel.text = "CA"
            }
            if (topOverviewCellData[11] as? Bool ?? true) {
                cell.circleLabel.textColor = .white
            } else {
                cell.circleLabel.textColor = .black
            }
        }
        
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
            let interaction = UIContextMenuInteraction(delegate: self)
            cell.latestTransactionStackView.addInteraction(interaction)
            
            let tabRecongnizer = UITapGestureRecognizer(target: self, action: #selector(switchToList))
            cell.latestTransactionStackView.addGestureRecognizer(tabRecongnizer)
        }
        
        //cell.outlineView.dropShadow()
        
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
    
    func getSubLabelCell(indexPath: IndexPath) -> cellSubtitleStack {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSubtitleStack", for: indexPath) as! cellSubtitleStack
        
        cell.stackView.removeFullyAllArrangedSubviews()
        
        if indexPath.row == 1 {
            let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline), NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
            let text = NSAttributedString(string: NSLocalizedString("splitsSubLabel", comment: "Splits"), attributes: textAttribute)
            let label = UILabel()
            label.attributedText = text
            cell.stackView.addArrangedSubview(label)
            
            cell.tag = 1
        } else if indexPath.row == 3 {
            var numberSegments = 2
            if (activeBudget && (view.frame.height < view.frame.width)) || (!UIDevice().model.contains("iPhone") && activeBudget){
                numberSegments = 3
            } else if selectedSecond >= 3 {
                selectedSecond = 2
            }
            
            for i in 0...numberSegments {
                var textString = ""
                if activeBudget {
                    switch i {
                    case 1:
                        let monthInt = Calendar.current.component(.month, from: Date())
                        let monthStr = Calendar.current.monthSymbols[monthInt-1]
                        textString = monthStr
                        break
                    case 2:
                        let yearInt = Calendar.current.component(.year, from: Date())
                        textString = String(yearInt)
                        break
                    case 3:
                        textString = NSLocalizedString("totalLabel", comment: "Total")
                        break
                    default:
                        textString = NSLocalizedString("budgetLabel", comment: "Budget")
                        break
                    }
                } else {
                    switch i {
                    case 1:
                        let yearInt = Calendar.current.component(.year, from: Date())
                        textString = String(yearInt)
                        break
                    case 2:
                        textString = NSLocalizedString("totalLabel", comment: "Total")
                        break
                    default:
                        let monthInt = Calendar.current.component(.month, from: Date())
                        let monthStr = Calendar.current.monthSymbols[monthInt-1]
                        textString = monthStr
                        break
                    }
                }
                
                let label = UILabel()
                
                label.text = textString
                label.font = UIFont.preferredFont(forTextStyle: .subheadline)
                label.textColor = .label
                label.textAlignment = .center
//                label.heightAnchor.constraint(equalToConstant: label.bounds.size.height+20).isActive = true
                label.numberOfLines = 0
                
                if i == selectedSecond {
                    label.alpha = 1.0
                } else {
                    label.alpha = 0.3
                }
                label.tag = i
                
                cell.stackView.addArrangedSubview(label)
            }

            cell.tag = 3
            cell.initCells()
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
        activeBudget = dataHandler.loadIfBudget()
        
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
        var icon = ""
        var isLight = true
        
        let dateSort = NSSortDescriptor(key: "dateTime", ascending: false)
        if let transaction = dataHandler.loadBulkSortedOneEntry(entitie: "Transactions", sort: [dateSort]) as? NSManagedObject {
            realAmount = transaction.value(forKey: "realAmount") as? Double ?? 0.00
            descriptionNote = transaction.value(forKey: "descriptionNote") as? String ?? ""
            dateTime = transaction.value(forKey: "dateTime") as? Date ?? Date()
            isSplit = transaction.value(forKey: "isSplit") as? Int16 ?? 0
            
            let queryCategory = NSPredicate(format: "cID == %i", (transaction.value(forKey: "categoryID") as? Int16 ?? 0))
            color = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0
            categoryName = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? ""
            isSave = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isSave", query: queryCategory) as? Bool ?? false
            if !isSave && !(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false) {
                realAmount = -realAmount
            }
            icon = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "icon", query: queryCategory) as? String ?? ""
            isLight = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "iconLight", query: queryCategory) as? Bool ?? true
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
            9:isSplit,
            10:icon,
            11:isLight
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
        for expense in dataHandler.loadBulkQueried(entitie: "Categories", query: queryExpenses) {
            expensesIDsArray.append(expense.value(forKey: "cID") as? Int16 ?? 0)
        }
        let queryExpensesSum = NSPredicate(format: "categoryID IN %@ AND dateTime != nil", expensesIDsArray)
        let ramValueExpenses = (dataHandler.loadDataSUM(entitie: "Transactions", query: queryExpensesSum) as? [[String:Any]])
        if (ramValueExpenses?.count ?? 0) > 0 {
            balance = (ramValueExpenses?[0]["sum"] as? Double ?? 0.00)
        }
        
        // get Sum Income
        // get Category IDs which are Income
        var incomeIDsArray = [Int16]()
        let queryIncome = NSPredicate(format: "isSave == %@ AND isIncome == %@", NSNumber(value: false), NSNumber(value: true))
        for income in dataHandler.loadBulkQueried(entitie: "Categories", query: queryIncome) {
            incomeIDsArray.append(income.value(forKey: "cID") as? Int16 ?? 0)
        }
        let queryIncomeSum = NSPredicate(format: "categoryID IN %@ AND dateTime != nil", incomeIDsArray)
        let ramValueIncome = (dataHandler.loadDataSUM(entitie: "Transactions", query: queryIncomeSum) as? [[String:Any]])
        if (ramValueIncome?.count ?? 0) > 0 {
            balance = (ramValueIncome?[0]["sum"] as? Double ?? 0.00) - balance
        }
        
        // get Sum Savings
        var savingsIDsArray = [Int16]()
        let querySavings = NSPredicate(format: "isSave == %@", NSNumber(value: true))
        for saving in dataHandler.loadBulkQueried(entitie: "Categories", query: querySavings) {
            savingsIDsArray.append(saving.value(forKey: "cID") as? Int16 ?? 0)
        }
        let querySavingsSum = NSPredicate(format: "categoryID IN %@ AND isLiquid == %@ AND dateTime != nil", savingsIDsArray, NSNumber(value: true))
        let ramValueSave = (dataHandler.loadDataSUM(entitie: "Transactions", query: querySavingsSum) as? [[String:Any]])
        if (ramValueSave?.count ?? 0) > 0 {
            balance = balance - (ramValueSave?[0]["sum"] as? Double ?? 0.00)
        }
        
        // Get Initial Payments
        let queryInitialExpense = NSPredicate(format: "dateTime == nil")
        for initialTransaction in dataHandler.loadBulkQueried(entitie: "Transactions", query: queryInitialExpense) {
            let queryCategory = NSPredicate(format: "cID == %i", (initialTransaction.value(forKey: "categoryID") as? Int16 ?? -1))
            let isIncome = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false
            
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
        
        var fromDate = Date().startOfMonth
        var toDate = Date().endOfMonth
        
        var expensesIDsArray = [Int16]()
        let queryExpenses = NSPredicate(format: "isSave == %@ AND isIncome == %@", NSNumber(value: false), NSNumber(value: false))
        for expense in dataHandler.loadBulkQueried(entitie: "Categories", query: queryExpenses) {
            expensesIDsArray.append(expense.value(forKey: "cID") as? Int16 ?? 0)
        }
        
        var queryPieChart = NSPredicate(format: "dateTime > %@ AND dateTime <= %@ AND isLiquid == true AND categoryID IN %@", fromDate as NSDate, toDate as NSDate, expensesIDsArray)
        if selectedSecond == 0 && activeBudget { // Budget
  
        } else if (selectedSecond == 1 && !activeBudget) || (selectedSecond == 2 && activeBudget) { // Year
            fromDate = Date().startOfYear
            toDate = Date().endOfYear
            queryPieChart = NSPredicate(format: "dateTime > %@ AND dateTime <= %@ AND isLiquid == true AND categoryID IN %@", fromDate as NSDate, toDate as NSDate, expensesIDsArray)
        } else if (selectedSecond == 2 && !activeBudget) || (selectedSecond == 3 && activeBudget) { // Total
            queryPieChart = NSPredicate(format: "categoryID IN %@", expensesIDsArray)
        }
        
        var sumBudget = 0.00
        var sumSpent = 0.00
        
        let data = dataHandler.loadDataGroupedSUM(entitie: "Transactions", groupByColumn: "categoryID", query: queryPieChart) as? [[String:Any]]
        if (data?.count ?? 0) > 0 {
            for i in 0...((data?.count ?? 1)-1) {
                let queryCategory = NSPredicate(format: "cID == %i", (data?[i]["categoryID"] as? Int16 ?? 0))
                if selectedSecond == 0 && activeBudget {
                    if !(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false) && !(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isSave", query: queryCategory) as? Bool ?? false) && (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "budget", query: queryCategory) as? Double ?? 0.00 > 0.00) {
                        sumSpent = sumSpent + (data?[i]["sum"] as? Double ?? 0.00)
                        sumBudget = sumBudget + (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "budget", query: queryCategory) as? Double ?? 0.00)
                    } else {
                        continue
                    }
                } else {
                    entries.append(PieChartDataEntry(value: (data?[i]["sum"] as? Double ?? 0.00), label: (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? "")))
                    colors.append(UIColor.randomColor(color: Int((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0))))
                }
            }
        }
        
        if selectedSecond == 0 && activeBudget {
            entries.append(PieChartDataEntry(value: sumSpent, label: "Spent"))
            colors.append(.red)
            entries.append(PieChartDataEntry(value: max(0,(sumBudget-sumSpent)), label: "Left"))
            colors.append(UIColor(red: 0/255, green: 204/255, blue: 68/255, alpha: 0.8))
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
        
        for data in dataHandler.loadBulkQueriedSorted(entitie: "SplitPersons", query: queryIsUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
        
        let userDateUserPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        let userDateUserMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
        
        let dateSort = NSSortDescriptor(key: "createDate", ascending: false)
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: false))
        
        for data in dataHandler.loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [dateSort]) {
            var sum = 0.00

            let createDatePerson = (data.value(forKey: "createDate") as? Date ?? Date())
            
            let createDatePersonPlus = Calendar.current.date(byAdding: .second, value: 1, to: createDatePerson)!
            let createDatePersonMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDatePerson)!
            
            let query = NSPredicate(format: "namePerson == %@ AND createDatePerson < %@ AND createDatePerson > %@", (data.value(forKey: "namePerson") as! NSString), (createDatePersonPlus as NSDate), (createDatePersonMinus as NSDate))
            let dateSort = NSSortDescriptor(key: "dateTimeTransaction", ascending: false)
            
            var userIsPartOfSplit:Bool?
            
            for split in dataHandler.loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [dateSort]) {
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
                
                for transaction in dataHandler.loadBulkQueriedSorted(entitie: "Transactions", query: query, sort: [dateSort]) {
                    let exchangeRate = (transaction.value(forKey: "exchangeRate") as? Double ?? 1.00)
                    
                    let settled = (split.value(forKey: "settled") as? Double ?? 0.00)/exchangeRate
                    let sumTransaction = (transaction.value(forKey: "amount") as? Double ?? 0.00)/exchangeRate
                    
                    if userIsPartOfSplit ?? false {
                        if (split.value(forKey: "paidByUser") as? Bool ?? true) {
                            let ratio = (split.value(forKey: "ratio") as? Double ?? 0.00)
                            sum = sum - (sumTransaction*ratio) + settled
                        } else {
                            let queryUserRatio = NSPredicate(format: "createDatePerson < %@ AND createDatePerson > %@ AND namePerson == %@ AND dateTimeTransaction < %@ AND dateTimeTransaction > %@", (userDateUserPlus as NSDate), (userDateUserMinus as NSDate), (nameUser ?? "") as NSString, (createTransactionPlus as NSDate), (createTransactionMinus as NSDate))
                            let ratio = dataHandler.loadQueriedAttribute(entitie: "Splits", attibute: "ratio", query: queryUserRatio) as? Double ?? (1-(split.value(forKey: "ratio") as? Double ?? 0.00))
                            let settledUser = (dataHandler.loadQueriedAttribute(entitie: "Splits", attibute: "settled", query: queryUserRatio) as? Double ?? (1-(split.value(forKey: "ratio") as? Double ?? 0.00)))/exchangeRate
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
    
    func refreshPieChart() {
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

            var centerText:NSAttributedString?
            var textColor = UIColor.white
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            if userInterfaceStyle == .light {
                textColor = UIColor.black
            }
            if selectedSecond == 0 && activeBudget {
                let centerTextText = NSLocalizedString("budgetLabel", comment: "Budget").prefix(1).uppercased()
                let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
                centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
            } else if (selectedSecond == 0 && !activeBudget) || (selectedSecond == 1 && activeBudget) {
                let monthInt = Calendar.current.component(.month, from: Date())
                let monthStr = Calendar.current.monthSymbols[monthInt-1]
                let centerTextText = monthStr.prefix(1).uppercased()
                let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
                centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
            } else if (selectedSecond == 1 && !activeBudget) || (selectedSecond == 2 && activeBudget) {
                let centerTextText = NSLocalizedString("yearOneDigit", comment: "Y")
                let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
                centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
            } else if (selectedSecond == 2 && !activeBudget) || (selectedSecond == 3 && activeBudget) {
                let centerTextText = NSLocalizedString("totalLabel", comment: "Total").prefix(1).uppercased()
                let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
                centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
            }
            
            cell.pieChart.centerAttributedText = centerText
            
            let tabRecongnizerPie = UITapGestureRecognizer(target: self, action: #selector(switchToGraphs))
            cell.pieChart.addGestureRecognizer(tabRecongnizerPie)
            
            cell.pieChart.notifyDataSetChanged()
        }
    }
    
    @objc func categoyTimeRangeChanged(notification: Notification) {
        if let userInfo = notification.userInfo, let selectedNew = userInfo["selectedLabel"] as? Int {
            if let selectedCell = userInfo["selectedCell"] as? Int {
                if selectedCell == 1 {
                    selectedFirst = selectedNew
                } else {
                    selectedSecond = selectedNew
                    
                    let newPieChartData = getPieChartDate()
                    topOverviewCellData[1] = newPieChartData.0
                    topOverviewCellData[2] = newPieChartData.1
                    
                    refreshPieChart()
                }
            }
        }
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
        } else if differenceInDays < 7 && differenceInDays > 0 {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: dayDate)
        } else if differenceInDays == -1 {
            return NSLocalizedString("tomorrowText", comment: "Tomorrow")
        } else if differenceInDays == -2 {
            return NSLocalizedString("dayAfterTomorrowText", comment: "Day after Tomorrow")
        } else {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: dayDate).capitalized.prefix(3) + ", " + mediumDate.string(from: dayDate)
        }
    }
    
    func userPartOfSplit(dateTime: Date) -> Bool {
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
        
        var nameUser:String?
        var createDateUser:Date?
        
        for data in dataHandler.loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
        
        let userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        let userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
        
        let datePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTime)!
        let dateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTime)!
        
        let query = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePerson == %@ AND createDatePerson > %@ AND createDatePerson < %@", (dateMinus as NSDate), (datePlus as NSDate), ((nameUser ?? "") as NSString), ((userDateMinus) as NSDate), ((userDatePlus) as NSDate))
        if dataHandler.loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [nameSort]).count > 0 {
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
        
        if dataHandler.loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [nameSort]).count > 0 {
            return true
        }
        
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
            
        var nameUser:String?
        var createDateUser:Date?
        
        for data in dataHandler.loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
            
        let userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        let userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
            
        let queryUserPaid = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePersonWhoPaid == %@ AND createDatePersonWhoPaid > %@ AND createDatePersonWhoPaid < %@", (dateTransactionMinus as NSDate), (dateTransactionPlus as NSDate), ((nameUser ?? "") as NSString), (userDateMinus as NSDate), (userDatePlus as NSDate))
            
        if dataHandler.loadBulkQueriedSorted(entitie: "Splits", query: queryUserPaid, sort: [nameSort]).count <= 0 {
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
        if UIDevice().model.contains("iPad") {
            return UIContextMenuConfiguration(
                  identifier: nil,
                  previewProvider: nil,
                  actionProvider: { _ in
                    let children: [UIMenuElement] = [self.makeEditAction(),self.makeDeleteAction()]
                    return UIMenu(title: "", children: children)
                })
        } else {
            return UIContextMenuConfiguration(
                  identifier: nil,
                  previewProvider: makeDetailPreview,
                  actionProvider: { _ in
                    let children: [UIMenuElement] = [self.makeDeleteAction()]
                    return UIMenu(title: "", children: children)
                })
        }
        
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            self.show(self.makeDetailPreview(), sender: self)
        }
    }
    
    func makeDeleteAction() -> UIAction {
      return UIAction(
        title: NSLocalizedString("deleteButton", comment: "Delete"),
        image: UIImage(systemName: "trash"),
        attributes: .destructive,
        handler: deleteTransaction)
    }
    
    func makeEditAction() -> UIAction {
        return UIAction(
          title: NSLocalizedString("editSomethingLabel", comment: "Edit"),
          image: UIImage(systemName: "pencil"),
          handler: openEdit)
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
    
    func openEdit(from action: UIAction) {
        let finStoryBoard: UIStoryboard = UIStoryboard(name: "finTSB", bundle: nil)
        let addVC = finStoryBoard.instantiateViewController(withIdentifier: "addTVC") as! addTVC
        
        if let latestTransactionDate = topOverviewCellData[7] as? Date {
            addVC.updateCreateDate = latestTransactionDate
        }
        
        let navigationVC = UINavigationController(rootViewController: addVC)
        
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func deleteTransaction(from action: UIAction) {
        let dateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: topOverviewCellData[7] as? Date ?? Date())!
        let dateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: topOverviewCellData[7] as? Date ?? Date())!
        
        let queryDelete = NSPredicate(format: "dateTime < %@ AND dateTime > %@", dateTransactionPlus as NSDate, dateTransactionMinus as NSDate)
        dataHandler.deleteData(entity: "Transactions", query: queryDelete)
        
        let querySplits = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", dateTransactionPlus as NSDate, dateTransactionMinus as NSDate)
        dataHandler.deleteData(entity: "Splits", query: querySplits)
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("transactionDeleted"), object: nil)
    }
}

// MARK: -DATA
extension finTVC {
    
    // MARK: -INIT DATA
    func initSettingsAndData() {
        dataHandler.saveNewSettings()
        
        let numberCurrencies = dataHandler.loadDataBulk(entity: "Currency").count
        if numberCurrencies != 33 {
            dataHandler.deleteDataBulk(entity: "Currency")
            saveExchangeRates()
        }

        if dataHandler.loadDataBulk(entity: "GraphSettings").count <= 0 {
            dataHandler.saveNewGraphs()
        }
    }
    
    func saveExchangeRates() {
        var data = readDataFromCSV(fileName: "currency_table", fileType: "csv")
        data = cleanRows(file: data ?? "")
        let csvRows = csv(data: data ?? "", sep: ";")
        
        var j:Int16 = 0
        for currency in csvRows {
            dataHandler.saveCurrency(currencyCode: currency[0], exchangeRate: 1.0, automated: false, id: j)
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
}

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
