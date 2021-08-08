//
//  listMasterTVC.swift
//  FIN
//
//  Created by Florian Riel on 07.08.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData
import ScalingCarousel
import CoreFoundation

class listMasterTVC: UITableViewController {
    
    @IBOutlet var listTable: UITableView!
    
    let activityIndicator = UIActivityIndicatorView()
    
    var timeInterval: Int? // Weekly: 1, Monthly: 2, Yearly: 3, All: 0
    var fromDateShown: Date?
    var toDateShown: Date?
    
    //var fileredCategoriesArray = [Int]()
    var filteredTagsArray = [String]()
    
    var carouselScrollingId: Int = 0
    var carouselScrollingTodayId: Int = 0
    
    var transferData = [Int:[Int:Any]]()
    var collectionCellData = [Int:[Int:Any]]()
    
    var dateOfSelectedRow:Date?
    var selectedRowIndex: Int?
    
    var isWideScreen: Bool = false
    
    var mediumDate = DateFormatter()
    var shortDate = DateFormatter()
    
    var numberFormatter = NumberFormatter()
    
    var collectionView:listCollectionView = {
        let nib = UINib(nibName: "listCollectionView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! listCollectionView
    }()
    let collectionViewHeightFactor:CGFloat = 0.29335
    var listInset = false
    var viewDisappear = false
    var navTitle = "Title"
    
    var viewAppeared = false
    var viewInitialLoad = true
    
    var searchController:UISearchController?
    var showsSearchBar: Bool = false
    var searchBarWide = false
    var searchBar:searchBar = {
        let nib = UINib(nibName: "searchBar", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! searchBar
    }()
    var widthAnchorConstraintSearchBar: NSLayoutConstraint?
    var yAnchorConstraintSearchBar: NSLayoutConstraint?
    
    var searchbarNavTitle:String = NSLocalizedString("searchTitle", comment: "Title during Search")
    var searchbarBackupTitle:String?
    
    var listBottomBar:listBottomBar = {
        let nib = UINib(nibName: "listBottomBar", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! listBottomBar
    }()
    var widthAnchorConstraintBottomBar: NSLayoutConstraint?
    var bottomAnchorConstraintBottomBar: NSLayoutConstraint?
    
    var tab:UITapGestureRecognizer?
    let nc = NotificationCenter.default
    
    var nameUser:String?
    var createDateUser:Date?
    var userDatePlus:Date = Date()
    var userDateMinus:Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""
        
        // Keyboard dismiss
        listTable.keyboardDismissMode = .onDrag
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(transactionAdded), name: Notification.Name("filterChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionAdded), name: Notification.Name("transactionAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionAdded), name: Notification.Name("dataImported"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionDeleted), name: Notification.Name("transactionDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionAdded), name: Notification.Name("groupPersonAdded"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(transactionAdded), name: Notification.Name("groupPersonUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(carouselScrolling(notification:)), name: Notification.Name("collectionViewChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionUpdated(notification:)), name: Notification.Name("transactionUpdated"), object: nil)
        
        mediumDate.dateStyle = .medium
        shortDate.dateStyle = .short
        
        numberFormatter.numberStyle = .decimal
//        numberFormatter.locale = Locale.current
        
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = Locale.current.groupingSeparator
        numberFormatter.groupingSize = 3
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        if timeInterval == nil { // Default: Monthly
            timeInterval = 2
        }
        initTagFilter()
        setInitialToFromMaxDates()
        setCollectionCellData(completion: {(success) -> Void in })
        initView()
        setData(timeInterval: timeInterval ?? 2, fDateShown: collectionCellData[carouselScrollingTodayId]?[4] as? Date ?? Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if reloadListView && viewAppeared {
            reloadListView = false
            transactionAdded()
        }
        if viewInitialLoad {
            nc.post(name: Notification.Name("collectionViewScrollTo"), object: nil, userInfo: ["toIndex": carouselScrollingTodayId])
            viewInitialLoad = false
        }
        initFirstSelected()
        
        viewAppeared = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        viewAppeared = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        updateCellIconAlpha()
        collectionView.updatePosition()
        if !viewDisappear {
            if UIDevice().model.contains("iPhone") && UIDevice.current.orientation.isLandscape {
                if collectionView.frame.origin.y <= 0 {
                    super.navigationController?.navigationBar.topItem?.title = navTitle
                } else {
                    super.navigationController?.navigationBar.topItem?.title = ""
                }
            } else {
                if collectionView.frame.origin.y <= (collectionView.headerLabel.frame.height) {
                    super.navigationController?.navigationBar.topItem?.title = navTitle
                } else {
                    super.navigationController?.navigationBar.topItem?.title = ""
                }
            }
        }
        viewDisappear = false
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        initBottomBarSize()
        collectionView.viewTransition()
        collectionView.updatePosition()
//        let splitViewController = self.splitViewController as! listSplitVC
//        splitViewController.initFirstSelected()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.navigationController?.view.backgroundColor = backgroundGeneralColor
            view.backgroundColor = backgroundGeneralColor
            listTable.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            listTable.backgroundColor = .secondarySystemBackground
        }
        
        initBottomBarSize()
        collectionView.viewTransition()
        collectionView.updatePosition()
        initFirstSelected()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (transferData.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getEntryCell(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (listTable.cellForRow(at: indexPath) as? cellListEntry) != nil {
            initRows(indexPathSelected: indexPath)
    //        UISelectionFeedbackGenerator().selectionChanged()
            selectedRowIndex = indexPath.row
            dateOfSelectedRow = transferData[(indexPath.row)]?[11] as? Date ?? Date()
            
            if UIDevice().model.contains("iPad") {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "rowSelected", sender: nil)
                }
            } else {
                let listDetailStoryBoard: UIStoryboard = UIStoryboard(name: "listTSB", bundle: nil)
                let listDetailVC = listDetailStoryBoard.instantiateViewController(withIdentifier: "TransactionDetail") as! listDetailTVC
                listDetailVC.selectedRowIndex = selectedRowIndex
                listDetailVC.dateOfSelectedRow = dateOfSelectedRow
                listDetailVC.modalPresentationStyle = .fullScreen
                selectedRowIndex = nil
                self.navigationController?.pushViewController(listDetailVC, animated: true)
            }
        }
    }

    // MARK: -FUNCTIONS
    @objc func transactionAdded(scrollToId: Int = -1, reload: Bool = true) {
        reloadFinView = true
        initRows(clearRows: true)
        activityIndicator.startAnimating()
        initTagFilter()
        checkRegularPayments()
        setInitialToFromMaxDates(scrollToId: scrollToId, reload: reload)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.setCollectionCellData(scrollToId: scrollToId, completion: {(success) -> Void in
                self.setData(timeInterval: self.timeInterval ?? 2, fDateShown: self.collectionCellData[self.carouselScrollingId]?[4] as? Date ?? Date())
                self.collectionView.carousel.reloadData()
                self.listTable.reloadData()
                self.activityIndicator.stopAnimating()
    //            activityIndicator.isHidden = true
            })
            self.carouselScrollingId = scrollToId
            
//            self.selectedRowIndex = nil
            self.initRows()
            self.initFirstSelected()
            self.setBarButtons()
        }
    }
    
    @objc func transactionDeleted(scrollToId: Int = -1) {
        var scrollToIdFUNC = scrollToId
        if carouselScrollingId != -1 {
            scrollToIdFUNC = carouselScrollingId
        }
        setCollectionCellData(scrollToId: scrollToIdFUNC, completion: {(success) -> Void in })
        collectionView.carousel.reloadData()
        carouselScrollingId = scrollToIdFUNC
        setData(timeInterval: self.timeInterval ?? 2, fDateShown: self.collectionCellData[self.carouselScrollingId]?[4] as? Date ?? Date())
        selectedRowIndex = nil
        initRows()
        initFirstSelected()
        listTable.reloadData()
    }
    
    @objc func transactionUpdated(notification: Notification) {
        if let userInfo = notification.userInfo, let _ = userInfo["transactionCreateDate"] as? Date {
            if (userInfo["oldCreateDate"] as? Date) != nil {
//                if oldCreateDate != transactionCreateDate {
                    setCollectionCellData(scrollToId: carouselScrollingId, completion: {(success) -> Void in })
                    collectionView.carousel.reloadData()
                    setData(timeInterval: self.timeInterval ?? 2, fDateShown: self.collectionCellData[self.carouselScrollingId]?[4] as? Date ?? Date())
                    selectedRowIndex = nil
                    initRows()
                    initFirstSelected()
                    listTable.reloadData()
//                }
            }
        }
    }

    func getEntryCell(indexPath: IndexPath) -> cellListEntry {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellListEntry", for: indexPath) as! cellListEntry
        
        if (transferData[(indexPath.row)]?[14] as? String ?? "").count > 0 {
            cell.circleImage.isHidden = false
            cell.circleLabel.isHidden = true
            
            var selectedImage = (transferData[(indexPath.row)]?[14] as? String ?? "").replacingOccurrences(of: "_white", with: "")
            if (transferData[(indexPath.row)]?[15] as? Bool ?? true) {
                selectedImage = selectedImage + "_white"
            }
            
            cell.circleImage.image = UIImage(named: selectedImage)
        } else {
            cell.circleLabel.isHidden = false
            cell.circleImage.isHidden = true
            
            cell.circleLabel.text = transferData[(indexPath.row)]?[8] as? String ?? ""
            if (transferData[(indexPath.row)]?[15] as? Bool ?? true) {
                cell.circleLabel.textColor = .white
            } else {
                cell.circleLabel.textColor = .black
            }
        }
        
        cell.circleView.backgroundColor = transferData[(indexPath.row)]?[9] as? UIColor ?? UIColor.blue
        cell.circleView.layer.borderColor = (transferData[(indexPath.row)]?[9] as? UIColor ?? UIColor.blue).cgColor
        
        cell.descriptionLabel.text = transferData[(indexPath.row)]?[6] as? String ?? ""
        cell.dateLabel.text = transferData[(indexPath.row)]?[7] as? String ?? ""

        var amount = (transferData[(indexPath.row)]?[0] as? Double ?? 0.00) // (transferData[(indexPath.row)]?[2] as? Double ?? 1.00)
        if (!(transferData[(indexPath.row)]?[5] as? Bool ?? false)) && (!(transferData[(indexPath.row)]?[4] as? Bool ?? false)) {
            amount = (-1)*amount
        }
        cell.amountLabel.text = (transferData[(indexPath.row)]?[1] as? String ?? "€") + " " + (numberFormatter.string(for: amount) ?? "0.00")
        
        if (transferData[(indexPath.row)]?[12] as? Int ?? 0) > 0 || (transferData[(indexPath.row)]?[4] as? Bool ?? false) {
            cell.splitIcon.isHidden = false
            if (transferData[(indexPath.row)]?[4] as? Bool ?? false) {
                cell.splitIcon.image = UIImage(named: "safe")?.withRenderingMode(.alwaysTemplate)
            } else if (transferData[(indexPath.row)]?[12] as? Int ?? 0) == 1 {
                cell.splitIcon.image = UIImage(named: "tabPersonSelected")?.withRenderingMode(.alwaysTemplate)
            } else if (transferData[(indexPath.row)]?[12] as? Int ?? 0) == 2 {
                cell.splitIcon.image = UIImage(named: "tabPersonsSelected")?.withRenderingMode(.alwaysTemplate)
            } else {
                cell.splitIcon.isHidden = true
            }
        } else {
            cell.splitIcon.isHidden = true
        }
        cell.amountLabel.sizeToFit()
        cell.descriptionLabel.sizeToFit()
        cell.dateLabel.sizeToFit()
        cell.layoutIfNeeded()
        
        if selectedRowIndex != indexPath.row {
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            if userInterfaceStyle == .light {
                cell.outlineView.backgroundColor = .white
                cell.outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            } else {
                cell.outlineView.backgroundColor = .black
                cell.outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
            }
        } else {
            cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
            cell.outlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
        }
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.outlineView.addInteraction(interaction)
        cell.outlineView.tag = indexPath.row
        
        return cell
    }
    
    func initView() {
        initSearchBar()
        initBottomBar()
        initCollectionView()
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.navigationController?.view.backgroundColor = backgroundGeneralColor
            view.backgroundColor = backgroundGeneralColor
            listTable.backgroundColor = backgroundGeneralColor
        } else {
            self.navigationController?.view.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
            listTable.backgroundColor = .secondarySystemBackground
        }
        
        setBarButtons()
        setNameDateUser()
    }
    
    func initCollectionView() {
        listTable.sectionHeaderHeight = UITableView.automaticDimension
        
        collectionView.initView()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.frame.width,
            height: 195//max(view.frame.height, view.frame.width) * collectionViewHeightFactor
        )
        
        collectionView.maxHeight = (max(listTable.frame.height, listTable.frame.width) * collectionViewHeightFactor) * 2.2

        collectionView.scrollView = listTable
        collectionView.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: 0)
                        
        listTable.backgroundView = UIView()
        listTable.backgroundView?.addSubview(collectionView)
        
        activityIndicator.style = .medium
        activityIndicator.hidesWhenStopped = true
        listTable.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerYAnchor.constraint(equalTo: listTable.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: listTable.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        
        toggleListViewContentInset()
    }
    
    func updateCellIconAlpha() {
        let heightTableView = listTable.visibleSize.height
        let heightTableViewP = 0.2 * heightTableView
        
        for cell in listTable.visibleCells {
            let cellConverted = cell as! cellListEntry
            
            let yTopPosition = listTable.convert(cellConverted.frame, to: nil).maxY
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
    
    func setNameDateUser() {
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
        
        for data in dataHandler.loadDataSorted(entitie: "SplitPersons", query: queryUser, sortBy: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
        
        userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
    }
    
    func initRows(indexPathSelected: IndexPath = IndexPath(row: 0, section: 0), clearRows: Bool = false) {
        for (row, _) in transferData {
            let indexPathRAM: IndexPath = IndexPath(row: row, section: 0)
            if let cell = listTable.cellForRow(at: indexPathRAM) as? cellListEntry {
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
        if !clearRows {
            if let cell = listTable.cellForRow(at: indexPathSelected) as? cellListEntry {
                cell.outlineView.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
                cell.outlineView.layer.borderColor = CGColor(srgbRed: 64/255, green: 156/255, blue: 255/255, alpha: 0.1)
            }
        }
    }
    
    func initFirstSelected() {
        if selectedRowIndex == nil && UIDevice().model.contains("iPad") {
            selectedRowIndex = 0
            initRows(indexPathSelected: IndexPath(row: selectedRowIndex ?? 0, section: 0))
            dateOfSelectedRow = transferData[(selectedRowIndex ?? 0)]?[11] as? Date ?? Date()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "rowSelected", sender: nil)
            }
        } else if selectedRowIndex != nil && UIDevice().model.contains("iPad") {
            initRows(indexPathSelected: IndexPath(row: selectedRowIndex ?? 0, section: 0), clearRows: false)
            dateOfSelectedRow = transferData[(selectedRowIndex ?? 0)]?[11] as? Date ?? Date()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "rowSelected", sender: nil)
            }
        } else {
            initRows(clearRows: true)
        }
    }
    
    func toggleListViewContentInset() {
        if !listInset {
            listTable.contentInset = UIEdgeInsets(
                top: 195,//(max(view.frame.height,view.frame.width) * collectionViewHeightFactor),
                left: 0,
                bottom: 35,
                right: 0
            )
            listInset = true
        } else {
            listTable.contentInset = UIEdgeInsets(
                top: 60,
                left: 0,
                bottom: 0,
                right: 0
            )
            listInset = false
        }
    }
    
    func initBottomBar() {
        listBottomBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(listBottomBar, aboveSubview: listTable)
        listBottomBar.initView()
        
        initBottomBarSize()
        
        listBottomBar.delegete = self
    }
    
    func initBottomBarSize() {
        widthAnchorConstraintBottomBar?.isActive = false
        widthAnchorConstraintBottomBar = listBottomBar.widthAnchor.constraint(equalToConstant: min(view.frame.width, 400))
        widthAnchorConstraintBottomBar?.isActive = true
        
        bottomAnchorConstraintBottomBar?.isActive = false
        bottomAnchorConstraintBottomBar = listBottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        bottomAnchorConstraintBottomBar?.isActive = true
        
        listBottomBar.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 1.0).isActive = true
    }
    
    func hideBottomBar() {
        bottomAnchorConstraintBottomBar?.isActive = false
        bottomAnchorConstraintBottomBar = listBottomBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        bottomAnchorConstraintBottomBar?.isActive = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        } , completion: { finished in
            self.listBottomBar.isHidden = true
        })
    }
    
    func showBottomBar() {
        bottomAnchorConstraintBottomBar?.isActive = false
        bottomAnchorConstraintBottomBar = listBottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        bottomAnchorConstraintBottomBar?.isActive = true
        self.listBottomBar.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        } , completion: { finished in
            
        })
    }
    
    func initSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(searchBar, aboveSubview: listTable)
        searchBar.initView()
        
        yAnchorConstraintSearchBar?.isActive = false
        widthAnchorConstraintSearchBar?.isActive = false
        
        widthAnchorConstraintSearchBar = searchBar.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1.0)
        widthAnchorConstraintSearchBar?.isActive = true
        
        searchBar.centerXAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.centerXAnchor, multiplier: 1.0).isActive = true
        
        yAnchorConstraintSearchBar = searchBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        yAnchorConstraintSearchBar?.isActive = true
        
        searchBar.isUserInteractionEnabled = true
        searchBar.delegate = self
    }
    
    @objc func toggleSearchBar() {
        if !self.searchBarWide {
            self.hideBottomBar()
        }
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
        self.yAnchorConstraintSearchBar?.isActive = false
        if !self.searchBarWide {
            self.searchbarBackupTitle = self.navTitle
            self.navTitle = self.searchbarNavTitle
            self.searchBarWide = true
            self.yAnchorConstraintSearchBar = self.searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0.0)
            self.yAnchorConstraintSearchBar?.isActive = true
        } else {
            self.navTitle = self.searchbarBackupTitle ?? ""
            self.searchBarWide = false
            self.yAnchorConstraintSearchBar = self.searchBar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0)
            self.yAnchorConstraintSearchBar?.isActive = true
            
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("searchBarDissappeared"), object: nil)
        }
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            if self.searchBarWide {
                self.searchBar.searchBar.isHidden = false
                self.searchBar.searchBar.alpha = 1.0
                self.collectionView.isHidden = true
                self.collectionView.alpha = 0.0
            } else {
                self.searchBar.searchBar.alpha = 0.0
                self.collectionView.alpha = 1.0
                self.collectionView.isHidden = false
            }
            self.toggleListViewContentInset()
        }, completion: { finished in
            if self.searchBarWide {
                self.tab?.isEnabled = false
                self.collectionView.isHidden = true
            } else {
                self.searchBar.searchBar.isHidden = true
                self.tab?.isEnabled = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                if self.listTable.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
                    self.listTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                } else {
                    self.listTable.scrollsToTop = true
                }
                if !self.searchBarWide {
                    self.showBottomBar()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        self.seachBarTextChanged(searchText: "")
                    })
                }
            })
        })
        //})
    }
    
    @objc func filterButtonTabbed() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showFilter", sender: nil)
        }
    }
    
    func setInitialToFromMaxDates(scrollToId: Int = -1, reload: Bool = false) {
        //if fromDateMax == nil || toDateMax == nil || reload {
            let dateSortHighestFirst = NSSortDescriptor(key: "dateTime", ascending: false)
            let highestDate = dataHandler.loadBulkSortedForMaxMinDate(entitie: "Transactions", sort: [dateSortHighestFirst])
            if highestDate.count <= 0 {
                toDateMax = Date()
            } else {
                for i in 0...(highestDate.count-1) {
//                    if (highestDate[i].value(forKey: "isSplit") as? Int16 ?? 0) > 0 {
//                        if userPartOfSplit(dateTime: (highestDate[i].value(forKey: "dateTime") as? Date ?? Date())){
//                            toDateMax = highestDate[i].value(forKey: "dateTime") as? Date ?? Date()
//                            break
//                        }
//                    } else {
                        toDateMax = highestDate[i].value(forKey: "dateTime") as? Date ?? Date()
                        break
//                    }
                }
            }
            let dateSortLowestFirst = NSSortDescriptor(key: "dateTime", ascending: true)
            let lowestDate = dataHandler.loadBulkSortedForMaxMinDate(entitie: "Transactions", sort: [dateSortLowestFirst])
            if lowestDate.count <= 0 {
                fromDateMax = Date()
            } else {
                for i in 0...(lowestDate.count-1) {
//                    if Int(lowestDate[i].value(forKey: "isSplit") as? Int16 ?? 0) > 0 {
//                        if userPartOfSplit(dateTime: (lowestDate[i].value(forKey: "dateTime") as? Date ?? Date())) {
//                            fromDateMax = lowestDate[i].value(forKey: "dateTime") as? Date ?? Date()
//                            break
//                        }
//                    } else {
                        fromDateMax = lowestDate[i].value(forKey: "dateTime") as? Date ?? Date()
                        break
//                    }
                }
            }
            if fromDateShown == nil {
                fromDateShown = Date()
            }
        //}
    }
    
    func setCollectionCellData(scrollToId: Int = -1,completion: (Bool) -> ()) {
        var numberTimeIntervalls:Int = 0
        
        collectionCellData.removeAll()
        carouselScrollingTodayId = -1
        
        switch timeInterval {
        case 1: // Weekly
            numberTimeIntervalls = max(((Calendar.current.dateComponents([.weekday], from: fromDateMax?.startOfWeek ?? Date(), to: toDateMax?.endOfWeek ?? Date()).weekday ?? 1)+7)/7,1)
            fromDateShown = fromDateMax?.startOfWeek ?? Date()
            var i = 0
            for j in 0...numberTimeIntervalls-1 {
                var components = DateComponents()
                components.weekday = 7
                toDateShown = Calendar(identifier: .gregorian).date(byAdding: components, to: fromDateShown?.startOfWeek ?? Date())!
                if setCollectionData(collectionCellDataIndex: i, totalIndex: j) {
                    if fromDateShown?.startOfWeek == Date().startOfWeek {
                        carouselScrollingTodayId = i
                    }
                    i = i + 1
                }
                components.weekday = 0
                components.second = 1
                fromDateShown = Calendar(identifier: .gregorian).date(byAdding: components, to: toDateShown?.startOfWeek ?? Date())!
            }
            break
        case 2: // Monthly
            numberTimeIntervalls = max(((Calendar.current.dateComponents([.month], from: fromDateMax?.startOfMonth ?? Date(), to: toDateMax?.endOfMonth ?? Date()).month ?? 1)+1),1)
            fromDateShown = fromDateMax?.startOfMonth ?? Date()
            var i = 0
            for j in 0...numberTimeIntervalls-1 {
                var components = DateComponents()
                components.month = 1
                toDateShown = Calendar(identifier: .gregorian).date(byAdding: components, to: fromDateShown?.startOfMonth ?? Date())!
                if setCollectionData(collectionCellDataIndex: i, totalIndex: j) {
                    if fromDateShown?.startOfMonth == Date().startOfMonth {
                        carouselScrollingTodayId = i
                    }
                    i = i + 1
                }
                components.month = 0
                components.second = 1
                fromDateShown = Calendar(identifier: .gregorian).date(byAdding: components, to: toDateShown?.startOfMonth ?? Date())!
            }
            break
        case 3: // Yearly
            numberTimeIntervalls = max(((Calendar.current.dateComponents([.year], from: fromDateMax?.startOfYear ?? Date(), to: toDateMax?.endOfYear ?? Date()).year ?? 1)+1),1)
            fromDateShown = fromDateMax?.startOfYear ?? Date()
            var i = 0
            for j in 0...numberTimeIntervalls-1 {
                var components = DateComponents()
                components.year = 1
                toDateShown = Calendar(identifier: .gregorian).date(byAdding: components, to: fromDateShown?.startOfYear ?? Date())!
                if setCollectionData(collectionCellDataIndex: i, totalIndex: j) {
                    if fromDateShown?.startOfYear == Date().startOfYear {
                        carouselScrollingTodayId = i
                    }
                    i = i + 1
                }
                components.year = 0
                components.second = 1
                fromDateShown = Calendar(identifier: .gregorian).date(byAdding: components, to: toDateShown?.startOfYear ?? Date())!
            }
            break
        default: // All
            numberTimeIntervalls = 1
            fromDateShown = fromDateMax
            toDateShown = toDateMax
            _ = setCollectionData(collectionCellDataIndex: 0, totalIndex: 0)
            carouselScrollingTodayId = 0
            break
        }
        
        if carouselScrollingTodayId == -1 {
            if collectionCellData.count != 0 {
                carouselScrollingTodayId = collectionCellData.count-1
            } else {
                carouselScrollingTodayId = 0
            }
        }
        if scrollToId != -1 {
            var scrollToIdRAM:Int?
            if scrollToId > collectionCellData.count-1 {
                scrollToIdRAM = collectionCellData.count-1
            } else {
                scrollToIdRAM = scrollToId
            }
            nc.post(name: Notification.Name("collectionViewScrollTo"), object: nil, userInfo: ["toIndex": scrollToIdRAM ?? 0])
            carouselScrollingId = scrollToIdRAM ?? 0
        } else {
            nc.post(name: Notification.Name("collectionViewScrollTo"), object: nil, userInfo: ["toIndex": carouselScrollingTodayId])
            carouselScrollingId = carouselScrollingTodayId
        }
        completion(true)
    }
    
    func setData(timeInterval: Int, fDateShown: Date = Date()) {
        // fromDate is the base
        fromDateShown = fDateShown
        switch timeInterval {
        case 1: // Weekly
            fromDateShown = fromDateShown?.startOfWeek
            toDateShown = Calendar.current.date(byAdding: .day, value: 7, to: fromDateShown ?? Date())
            break
        case 2: // Monthly
            fromDateShown = fromDateShown?.startOfMonth
            toDateShown = fromDateShown?.endOfMonth
            break
        case 3: // Yearly
            fromDateShown = fromDateShown?.startOfYear
            toDateShown = fromDateShown?.endOfYear
            break
        default: // All
            fromDateShown = fromDateMax
            toDateShown = toDateMax
            break
        }
        
        collectionView.headerLabel.text = getDateString(timeInterval: timeInterval, stringFromDate: fromDateShown ?? Date(), stringToDate: toDateShown ?? Date())
        
        if fromDateShown ?? Date() < fromDateMax ?? Date() {
            fromDateShown = fromDateMax
        }
        if toDateShown ?? Date() > toDateMax ?? Date() {
            toDateShown = toDateMax
        }
        
//        let categorySort = NSSortDescriptor(key: "categoryID", ascending: true)
        let dateSort = NSSortDescriptor(key: "dateTime", ascending: false)
        let query = NSPredicate(format: "dateTime >= %@ AND dateTime <= %@", (fromDateShown ?? Date()) as NSDate, (toDateShown ?? Date()) as NSDate)
        
        transferData = createTransactionDataFromCoreData(result: dataHandler.loadDataSorted(entitie: "Transactions", query: query, sortBy: [dateSort]))
        navTitle = collectionView.headerLabel.text ?? NSLocalizedString("viewTitle", comment: "Default Title")
    }
    
    func setCollectionData(collectionCellDataIndex: Int, totalIndex: Int) -> Bool {
        if transactionsZero() {
            return false
        } else {
            let expenses = getSumExpenses()
            let earnings = getSumIncome()
            let savings = getBalanceSavings()
            let ramDict = [
                0:totalIndex, // index if in every month/week etc. is an entry
                1:expenses,
                2:earnings,
                3:savings,
                4:fromDateShown ?? Date(),
                5:toDateShown ?? Date()
                ] as [Int : Any]
            collectionCellData[collectionCellDataIndex] = ramDict
            return true
        }
    }
    
    func checkRegularPayments() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let query = NSPredicate(format: "dateTimeNext < %@", Date() as NSDate)
        
        let dummyDate = Calendar.current.date(from: DateComponents(calendar: Calendar.current, year: 1900, month: 1, day: 1, hour: 1, minute: 1, second: 1)) ?? Date()
        
        for regularPayment in dataHandler.loadDataSorted(entitie: "RegularPayments", query: query, sortBy: [NSSortDescriptor(key: "dateTimeNext", ascending: true)]) {
            let amount = regularPayment.value(forKey: "amount") as? Double ?? 0.00
            let categoryID = regularPayment.value(forKey: "categoryID") as? Int16 ?? 0
            let currencyCode = regularPayment.value(forKey: "currencyCode") as? String ?? "EUR"
            let dateTime = regularPayment.value(forKey: "dateTimeNext") as? Date ?? Date()
            let descriptionNote = regularPayment.value(forKey: "descriptionNote") as? String ?? ""
            let exchangeRate = regularPayment.value(forKey: "exchangeRate") as? Double ?? 1.00
            let isLiquid = regularPayment.value(forKey: "isLiquid") as? Bool ?? true
            let isSave = regularPayment.value(forKey: "isSave") as? Bool ?? false
            let isSplit = regularPayment.value(forKey: "isSplit") as? Int16 ?? 0
            let realAmount = regularPayment.value(forKey: "realAmount") as? Double ?? 0.00
            let tags = regularPayment.value(forKey: "tags") as? String ?? ""
            
            if dataHandler.saveTransaction(amount: amount, realAmount: realAmount, category: categoryID, currencyCode: currencyCode, dateTime: dateTime, descriptionNote: descriptionNote, exchangeRate: exchangeRate, tags: tags, isSave: isSave, isLiquid: isLiquid, isSplit: isSplit) {
                let dateTimePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTime)!
                let dateTimeMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTime)!
                
                let querySplit = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", dateTimePlus as NSDate, dateTimeMinus as NSDate)
                
                for split in dataHandler.loadDataSorted(entitie: "SplitsRegularPayments", query: querySplit, sortBy: [NSSortDescriptor(key: "dateTimeTransaction", ascending: true)]) {
                    let createDateGroup = split.value(forKey: "createDateGroup") as? Date ?? dummyDate
                    let createDatePerson = split.value(forKey: "createDatePerson") as? Date ?? dummyDate
                    let createDatePersonWhoPaid = split.value(forKey: "createDatePersonWhoPaid") as? Date ?? dummyDate
                    let dateTimeTransaction = split.value(forKey: "dateTimeTransaction") as? Date ?? dummyDate
                    let nameGroup = split.value(forKey: "nameGroup") as? String ?? ""
                    let namePerson = split.value(forKey: "namePerson") as? String ?? ""
                    let namePersonWhoPaid = split.value(forKey: "namePersonWhoPaid") as? String ?? ""
                    let paidByUser = split.value(forKey: "paidByUser") as? Bool ?? true
                    let ratio = split.value(forKey: "ratio") as? Double ?? 0.00
                    let settled = split.value(forKey: "settled") as? Double ?? 0.00
                    
                    dataHandler.saveSplit(createDateGroup: createDateGroup, createDatePerson: createDatePerson, createDatePersonWhoPaid: createDatePersonWhoPaid, dateTimeTransaction: dateTimeTransaction, nameGroup: nameGroup, namePerson: namePerson, namePersonWhoPaid: namePersonWhoPaid, paidByUser: paidByUser, ratio: ratio, settled: settled)
                }
                
                var nextDateTime:Date?
                switch (regularPayment.value(forKey: "frequency") as? Int16 ?? 0) {
                case 0: // Weekly
                    nextDateTime = Calendar.current.date(byAdding: .day, value: 7, to: dateTime)!
                    break
                case 1: // Monthly
                    nextDateTime = Calendar.current.date(byAdding: .month, value: 1, to: dateTime)!
                    break
                case 2: // Yearly
                    nextDateTime = Calendar.current.date(byAdding: .year, value: 1, to: dateTime)!
                    break
                default: // Daily
                    nextDateTime = Calendar.current.date(byAdding: .day, value: 1, to: dateTime)!
                    break
                }
                
                nextDateTime = Calendar.current.date(from: DateComponents(calendar: Calendar.current, year: nextDateTime?.get(.year), month: nextDateTime?.get(.month), day: nextDateTime?.get(.day), hour: 6, minute: 0, second: 0))
                
                var doubleTransaction = true
                
                repeat {
                    let dateTimeTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: nextDateTime ?? dummyDate)!
                    let dateTimeTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: nextDateTime ?? dummyDate)!
                    
                    let querySaveTransaction = NSPredicate(format: "dateTime < %@ AND dateTime > %@", dateTimeTransactionPlus as NSDate, dateTimeTransactionMinus as NSDate)
                    
                    if dataHandler.loadBulkQueried(entitie: "Transactions", query: querySaveTransaction).count > 0 {
                        doubleTransaction = true
                        nextDateTime = dateTimeTransactionPlus
                    } else {
                        doubleTransaction = false
                    }
                } while doubleTransaction
                
                let querySaveRegularPayment = NSPredicate(format: "dateTimeNext < %@ AND dateTimeNext > %@", dateTimePlus as NSDate, dateTimeMinus as NSDate)
                
                dataHandler.saveQueriedAttributeMultiple(entity: "RegularPayments", attribute: "dateTimeNext", query: querySaveRegularPayment, value: nextDateTime ?? dummyDate)
                dataHandler.saveQueriedAttributeMultiple(entity: "SplitsRegularPayments", attribute: "dateTimeTransaction", query: querySplit, value: nextDateTime ?? dummyDate)
                
                let manager = LocalNotificationManager()
                
                let longDate = DateFormatter()
                longDate.dateFormat = "ddMMyyyyHHmmss"
                
                let comps = Calendar.current.dateComponents([.year, .month, .day , .hour, .minute, .second], from: nextDateTime ?? Date())
                let notificationMsg = NSLocalizedString("regularPaymentsTitle", comment: "Regular Payment") + ": " + (descriptionNote) + " " + NSLocalizedString("hasBeenAdded", comment: "has been added")
                
                manager.notifications = [LocalNotificationManager.Notification(id: longDate.string(from: nextDateTime ?? Date()), title: notificationMsg, datetime: comps)]
                manager.schedule()
            }
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
    
    func isValidDate(dateString: String) -> Bool {
        let dateFormatterGet1 = DateFormatter()
        let dateFormatterGet2 = DateFormatter()
        let dateFormatterGet3 = DateFormatter()
        let dateFormatterGet4 = DateFormatter()
        let dateFormatterGet5 = DateFormatter()
        let dateFormatterGet6 = DateFormatter()
        
        dateFormatterGet1.dateFormat = "yyyy-MM-dd"
        dateFormatterGet2.dateFormat = "yyyy/MM/dd"
        dateFormatterGet3.dateFormat = "dd-MM-yyyy"
        dateFormatterGet4.dateFormat = "dd/MM/yyyy"
        dateFormatterGet5.dateFormat = "dd.MM.yyyy"
        dateFormatterGet6.dateFormat = "MM-dd-yyyy"
        
        if let _ = dateFormatterGet1.date(from: dateString) {
            return true
        } else if let _ = dateFormatterGet2.date(from: dateString) {
            return true
        } else if let _ = dateFormatterGet3.date(from: dateString) {
            return true
        } else if let _ = dateFormatterGet4.date(from: dateString) {
            return true
        } else if let _ = dateFormatterGet5.date(from: dateString) {
            return true
        } else if let _ = dateFormatterGet6.date(from: dateString) {
            return true
        } else {
            return false
        }
    }
    
    func getDateString(timeInterval: Int, stringFromDate: Date, stringToDate: Date) -> String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        
        let today = Date().get(.year, .month, .weekOfYear, .weekday)
        let stringFromDateComponents = stringFromDate.get(.year, .month, .weekOfYear, .weekday)
        let stringToDateComponents = stringToDate.get(.year, .month, .weekOfYear, .weekday)
        
        switch timeInterval {
        case 1: // Weekly
            if today.year == stringFromDateComponents.year && today.weekOfYear == stringFromDateComponents.weekOfYear {
                return NSLocalizedString("thisWeek", comment: "This Week")
            } else if today.year == stringFromDateComponents.year && ((today.weekOfYear ?? 2)-1) == stringFromDateComponents.weekOfYear {
                return NSLocalizedString("lastWeek", comment: "Last Week")
            } else if today.year == stringFromDateComponents.year && ((today.weekOfYear ?? 2)+1) == stringFromDateComponents.weekOfYear {
                return NSLocalizedString("nextWeek", comment: "Next Week")
            } else {
                if today.year == stringFromDateComponents.year {
                    if stringFromDateComponents.month == stringToDateComponents.month {
                        return stringFromDate.formattedFromComponents(styleAttitude: .long, year: false, month: true, day: true, hour: false, minute: false, second: false, locale: .current)
                    } else {
                        return stringFromDate.formattedFromComponents(styleAttitude: .long, year: false, month: true, day: true, hour: false, minute: false, second: false, locale: .current)
                    }
                } else {
                    if stringFromDateComponents.month == stringToDateComponents.month {
                        return stringFromDate.formattedFromComponents(styleAttitude: .long, year: true, month: true, day: true, hour: false, minute: false, second: false, locale: .current)
                    } else {
                        return stringFromDate.formattedFromComponents(styleAttitude: .long, year: true, month: true, day: true, hour: false, minute: false, second: false, locale: .current)
                    }
                }
            }
        case 2: // Monthly
            if (stringFromDateComponents.year == today.year) {
                return monthFormatter.string(from: stringFromDate)
            } else {
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "MMMM, YYYY"
                return monthFormatter.string(from: stringFromDate)
            }
        case 3: // Yearly
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "YYYY"
            let newDate = Calendar.current.date(byAdding: .month, value: 1, to: stringFromDate)!
            return yearFormatter.string(from: newDate)
        default: // All
            if stringFromDateComponents.year == stringToDateComponents.year {
                return shortDate.string(from: fromDateShown ?? Date()) + " " + NSLocalizedString("to", comment: "To Connector Word") + " " + shortDate.string(from: toDateShown ?? Date())
            } else {
                return mediumDate.string(from: fromDateShown ?? Date()) + " " + NSLocalizedString("to", comment: "To Connector Word") + " " + mediumDate.string(from: toDateShown ?? Date())
            }
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
    
    @objc func setBarButtons() {
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(toggleSearchBar))
        if filteredCategoriesZero || filteredTagsZero {
            let filter = UIBarButtonItem(image: UIImage(named: "filterSelected"), style: .plain, target: self, action: #selector(filterButtonTabbed))
            navigationItem.rightBarButtonItems = [search, filter]
        } else {
            let filter = UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(filterButtonTabbed))
            navigationItem.rightBarButtonItems = [search, filter]
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(transactionAdded))
    }
    
    func userPartOfSplit(dateTime: Date) -> Bool {
        let datePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTime)!
        let dateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTime)!
        
        let query = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePerson == %@ AND createDatePerson > %@ AND createDatePerson < %@", (dateMinus as NSDate), (datePlus as NSDate), ((nameUser ?? "") as NSString), ((userDateMinus) as NSDate), ((userDatePlus) as NSDate))
        return dataHandler.loadBulkQueriedSortedUser(query: query)
    }
    
    // MARK: -GET TRANSACTIONS
    func createTransactionDataFromCoreData(result: [NSManagedObject]) -> [Int:[Int:Any]] {
        var ramDictionary = [Int:[Int:Any]]()
//        var light = false
//
//        let userInterfaceStyle = traitCollection.userInterfaceStyle
//        if userInterfaceStyle == .light {
//            light = true
//        }
        
        var i = 0
        
//        0: Amount
//        1: Currency
//        2: Exchange Rate
//        3: If this && category isSave -> Withdraw -> Amount = negative
//        4: Category Save?
//        5: Category Income?
//        6: Description
//        7: Date as String
//        8: Category Name
//        9: Category Color
//        10: Text Color for Circle
//        11: Date as Date
//        12: isSplit?
//        13: isAdd?,
//        14:icon,
//        15:iconLight,
//        16:uuid

        for data in result {
            if ((data.value(forKey: "isSplit") as? Int16) == 0) || userPartOfSplit(dateTime: data.value(forKey: "dateTime") as? Date ?? Date())  {
                let categoryID = data.value(forKey: "categoryID") as? Int16 ?? 0
                if categorySelectedForFilter(categoryID: categoryID) && tagIsSelectedInFilter(tag: (data.value(forKey: "tags") as? String ?? "-1y")) {
                    
                    var uuid:UUID?
                    if ((data.value(forKey: "uuid") as? UUID) != nil) {
                        uuid = (data.value(forKey: "uuid") as? UUID)
                    }
                    
                    let categoryQuery = NSPredicate(format: "cID == \(categoryID)")
                    ramDictionary[i] = [
                        0:data.value(forKey: "realAmount") as? Double ?? 0.00,  // AMOUNT
                        //1:getSymbol(forCurrencyCode: data.value(forKey: "currencyCode") as? String ?? "EUR") ?? "€", // Currency
                        1:getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€",
                        2:data.value(forKey: "exchangeRate") as? Double ?? 1.00,   // ExchangeRate
                        3:data.value(forKey: "isSave") as? Bool ?? false,   // If this && category isSave -> Withdraw -> Amount = negative
                        4:dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isSave", query: categoryQuery) as? Bool ?? false, // Category Save?
                        5:dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: categoryQuery) as? Bool ?? false, // Category Income?
                        6:data.value(forKey: "descriptionNote") as? String ?? "", // Description
                        7:getDayForDate(dayDate: data.value(forKey: "dateTime") as? Date ?? Date()), // mediumDate.string(from: data.value(forKey: "dateTime") as? Date ?? Date()),    // Date
                        8:(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: categoryQuery) as? String ?? "").prefix(2).uppercased(), // Category Name
                        9:UIColor.randomColor(color: Int(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "color", query: categoryQuery) as? Int16 ?? 0)), // Category Color
                        10:UIColor.randomColor(color: Int(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "color", query: categoryQuery) as? Int16 ?? 0)),
                        11:data.value(forKey: "dateTime") as? Date ?? Date(),
                        12:Int((data.value(forKey: "isSplit") as? Int16 ?? 0)),
                        13:false,
                        14:dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "icon", query: categoryQuery) as? String ?? "",
                        15:dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "iconLight", query: categoryQuery) as? Bool ?? true,
                        16:uuid as Any
                    ]
                    i = i + 1
                }
            }
        }
        return ramDictionary
    }
    
    func categorySelectedForFilter(categoryID:Int16) -> Bool {
        let categoryFilterQuery = NSPredicate(format: "cID == \(categoryID)")
        return (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "selectedForFilter", query: categoryFilterQuery) as? Bool ?? true)
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier ?? "") {
        case "rowSelected":
            guard let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.topViewController as? listDetailTVC
            else {
                fatalError()
            }
            
//            viewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            viewController.navigationItem.leftItemsSupplementBackButton = true
            viewController.dateOfSelectedRow = dateOfSelectedRow
            break
        default:
            break
        }
    }
}

// Context Menu
extension listMasterTVC: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if UIDevice().model.contains("iPad") {
            return UIContextMenuConfiguration(
                identifier: IndexPath(row: (interaction.view?.tag ?? -1), section: 0) as NSIndexPath,
                previewProvider: nil,
                  actionProvider: { _ in
                    let children: [UIMenuElement] = [self.makeEditAction(row: (interaction.view?.tag ?? -1)),self.makeDeleteAction(rowString: String(interaction.view?.tag ?? -1))]
                    return UIMenu(title: "", children: children)
                  })
        } else {
            return UIContextMenuConfiguration(
                identifier: IndexPath(row: (interaction.view?.tag ?? -1), section: 0) as NSIndexPath,
                previewProvider: { self.makeDetailPreview(row: (interaction.view?.tag ?? -1)) },
                  actionProvider: { _ in
                    let children: [UIMenuElement] = [self.makeDeleteAction(rowString: String(interaction.view?.tag ?? -1))]
                    return UIMenu(title: "", children: children)
                  })
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            self.show(self.makeDetailPreview(row: (interaction.view?.tag ?? -1)), sender: self)
        }
    }
    
    func makeDetailPreview(row: Int) -> UIViewController {
        let finStoryBoard: UIStoryboard = UIStoryboard(name: "finTSB", bundle: nil)
        let addVC = finStoryBoard.instantiateViewController(withIdentifier: "addTVC") as! addTVC
        
        if let latestTransactionDate = (transferData[(row)]?[11] as? Date) {
            addVC.updateCreateDate = latestTransactionDate
        }
        
        let navigationVC = UINavigationController(rootViewController: addVC)
        return navigationVC
    }
    
    func makeDeleteAction(rowString: String) -> UIAction {
      return UIAction(
        title: NSLocalizedString("deleteButton", comment: "Delete"),
        image: UIImage(systemName: "trash"),
        identifier: UIAction.Identifier(rowString),
        attributes: .destructive,
        handler: deleteTransaction)
    }
    
    func makeEditAction(row: Int) -> UIAction {
        return UIAction(
            title: NSLocalizedString("editSomethingLabel", comment: "Edit"),
            image: UIImage(systemName: "pencil"),
            identifier: UIAction.Identifier(String(row)+"_edit"),
            handler: openEdit)
    }
    
    func openEdit(from action: UIAction) {
        let identifier = String(action.identifier.rawValue).replacingOccurrences(of: "_edit", with: "")
        let numFormater = NumberFormatter()
        numFormater.numberStyle = .none
        
        let finStoryBoard: UIStoryboard = UIStoryboard(name: "finTSB", bundle: nil)
        let addVC = finStoryBoard.instantiateViewController(withIdentifier: "addTVC") as! addTVC
        
        let row = Int(truncating: numFormater.number(from: identifier) ?? -1)
        
        if row != -1 {
            addVC.updateCreateDate = (transferData[(row)]?[11] as? Date ?? Date())
        }
        
        let navigationVC = UINavigationController(rootViewController: addVC)
        
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func deleteTransaction(from action: UIAction) {
        let identifier = String(action.identifier.rawValue)
        
        let numFormater = NumberFormatter()
        numFormater.numberStyle = .none
        
        let row = Int(truncating: numFormater.number(from: identifier) ?? -1)

        if row != -1 {
            let transactionDate = (transferData[(row)]?[11] as? Date ?? Date())
            
            let dateTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: transactionDate)!
            let dateTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: transactionDate)!

            var queryDelete = NSPredicate(format: "dateTime < %@ AND dateTime > %@", dateTransactionPlus as NSDate, dateTransactionMinus as NSDate)
            
            if (transferData[(row)]?[11] as? UUID) != nil {
                queryDelete = NSPredicate(format: "uuid == %@", (transferData[(row)]?[11] as? UUID)?.uuidString ?? "")
            }
            
            dataHandler.deleteData(entity: "Transactions", query: queryDelete)

            let querySplits = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", dateTransactionPlus as NSDate, dateTransactionMinus as NSDate)
            dataHandler.deleteData(entity: "Splits", query: querySplits)
            
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("transactionDeleted"), object: nil)
        }
    }
}

extension listMasterTVC {
    // MARK: -DATA
    func getSumIncome() -> String {
        // Get Categories which are incomes
        let incomesCategoriesPredicate = NSPredicate(format: "isIncome == %@ AND isSave == %@ AND selectedForFilter == %@", NSNumber(value: true), NSNumber(value: false), NSNumber(value: true))
        var incomesCategories = [Int16]()
        for data in dataHandler.loadBulkQueried(entitie: "Categories", query: incomesCategoriesPredicate) {
            incomesCategories.append(data.value(forKey: "cID") as? Int16 ?? 0)
        }
        
        var tagFilterPredicateString = ""
        
        if filteredTagsArray.count > 0 {
            for i in 0...(filteredTagsArray.count-1) {
                if i == 0 {
                    tagFilterPredicateString = " AND (tags CONTAINS[c] '" + filteredTagsArray[i] + "'"
                } else if i != (filteredTagsArray.count-1) {
                    tagFilterPredicateString = tagFilterPredicateString + " OR tags CONTAINS[c] '" + filteredTagsArray[i] + "'"
                }
                if i == (filteredTagsArray.count-1) {
                    if i != 0 {
                        tagFilterPredicateString = tagFilterPredicateString + " OR tags CONTAINS[c] '" + filteredTagsArray[i] + "')"
                    } else {
                        tagFilterPredicateString = tagFilterPredicateString + ")"
                    }
                }
            }
        }
        
        // Get transactions with those categories
        var sumIncomes = 0.00
        
        if incomesCategories.count > 0 {
            let incomePredicate = NSPredicate(format: ("categoryID IN %@ AND dateTime >= %@ AND dateTime < %@ AND dateTime != nil" + tagFilterPredicateString), incomesCategories, fromDateShown! as NSDate, toDateShown! as NSDate)
            let dataIncome = dataHandler.loadDataSUM(entitie: "Transactions", query: incomePredicate)  as? [[String:Any]]
            if (dataIncome?.count ?? 0) > 0 {
                for i in 0...((dataIncome?.count ?? 1)-1) {
                    sumIncomes = (dataIncome?[i]["sum"] as? Double ?? 0.00) + sumIncomes
                }
            }
        }
        
//        if incomesCategories.count > 0 {
//            for data in incomesCategories {
//                let incomePredicate = NSPredicate(format: ("categoryID == \(data) AND dateTime >= %@ AND dateTime <= %@" + tagFilterPredicateString), fromDateShown! as NSDate, toDateShown! as NSDate)
//                for incomes in loadBulkQueried(entitie: "Transactions", query: incomePredicate) {
////                    if tagIsSelectedInFilter(tag: (incomes.value(forKey: "tags") as? String ?? "-1y")) {
//                        sumIncomes = sumIncomes + ((incomes.value(forKey: "amount") as? Double ?? 0.00) / (incomes.value(forKey: "exchangeRate") as? Double ?? 1.00))
////                    }
//                }
//            }
//        }
        return ((getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(for: sumIncomes) ?? "0.00"))
    }
    
    func getSumExpenses() -> String {
        // Get Categories which are expenses
        let expensesCategoriesPredicate = NSPredicate(format: "isIncome == %@ AND isSave == %@ AND selectedForFilter == %@", NSNumber(value: false), NSNumber(value: false), NSNumber(value: true))
        var expensesCategories = [Int16]()
        for data in dataHandler.loadBulkQueried(entitie: "Categories", query: expensesCategoriesPredicate) {
            expensesCategories.append(data.value(forKey: "cID") as? Int16 ?? 0)
        }
        var tagFilterPredicateString = ""
        
        if filteredTagsArray.count > 0 {
            for i in 0...(filteredTagsArray.count-1) {
                if i == 0 {
                    tagFilterPredicateString = " AND (tags CONTAINS[c] '" + filteredTagsArray[i] + "'"
                } else if i != (filteredTagsArray.count-1) {
                    tagFilterPredicateString = tagFilterPredicateString + " OR tags CONTAINS[c] '" + filteredTagsArray[i] + "'"
                }
                if i == (filteredTagsArray.count-1) {
                    if i != 0 {
                        tagFilterPredicateString = tagFilterPredicateString + " OR tags CONTAINS[c] '" + filteredTagsArray[i] + "')"
                    } else {
                        tagFilterPredicateString = tagFilterPredicateString + ")"
                    }
                }
            }
        }
        // Get transactions with those categories
        var sumExpenses = 0.00
        
        if expensesCategories.count > 0 {
            let expensePredicate = NSPredicate(format: ("categoryID IN %@ AND dateTime >= %@ AND dateTime <= %@ AND dateTime != nil" + tagFilterPredicateString), expensesCategories, fromDateShown! as NSDate, toDateShown! as NSDate)
            let dataExpenses = dataHandler.loadDataSUM(entitie: "Transactions", query: expensePredicate)  as? [[String:Any]]
            if (dataExpenses?.count ?? 0) > 0 {
                for i in 0...((dataExpenses?.count ?? 1)-1) {
                    sumExpenses = (dataExpenses?[i]["sum"] as? Double ?? 0.00) + sumExpenses
                }
            }
        }
        return ((getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " -" + (numberFormatter.string(for: sumExpenses) ?? "0.00"))
    }
    
    func getBalanceSavings() -> String {
        // Get Categories which are expenses
        let savingsCategoriesPredicate = NSPredicate(format: "isSave == %@ AND selectedForFilter == %@", NSNumber(value: true), NSNumber(value: true))
        var savingsCategories = [Int16]()
        for data in dataHandler.loadBulkQueried(entitie: "Categories", query: savingsCategoriesPredicate) {
            savingsCategories.append(data.value(forKey: "cID") as? Int16 ?? 0)
        }
        
        var tagFilterPredicateString = ""
        
        if filteredTagsArray.count > 0 {
            for i in 0...(filteredTagsArray.count-1) {
                if i == 0 {
                    tagFilterPredicateString = " AND (tags CONTAINS[c] '" + filteredTagsArray[i] + "'"
                } else if i != (filteredTagsArray.count-1) {
                    tagFilterPredicateString = " OR tags CONTAINS[c] '" + filteredTagsArray[i] + "'"
                }
                if i == (filteredTagsArray.count-1) {
                    if i != 0 {
                        tagFilterPredicateString = tagFilterPredicateString + " OR tags CONTAINS[c] '" + filteredTagsArray[i] + "')"
                    } else {
                        tagFilterPredicateString = tagFilterPredicateString + ")"
                    }
                }
            }
        }

        // Get transactions with those categories
        var sumSavings = 0.00
        if savingsCategories.count > 0 {
            for data in savingsCategories {
                let savePredicate = NSPredicate(format: ("categoryID == \(data) AND dateTime >= %@ AND dateTime < %@ AND dateTime != nil" + tagFilterPredicateString), fromDateShown! as NSDate, toDateShown! as NSDate)
                for savings in dataHandler.loadBulkQueried(entitie: "Transactions", query: savePredicate) {
//                    if tagIsSelectedInFilter(tag: (savings.value(forKey: "tags") as? String ?? "-1y")) {
                        if (savings.value(forKey: "isSave") as? Bool ?? false) {
                            sumSavings = sumSavings + ((savings.value(forKey: "amount") as? Double ?? 0.00) / (savings.value(forKey: "exchangeRate") as? Double ?? 1.00))
                        } else {
                            sumSavings = sumSavings - ((savings.value(forKey: "amount") as? Double ?? 0.00) / (savings.value(forKey: "exchangeRate") as? Double ?? 1.00))
                        }
//                    }
                }
            }
        }
        return ((getSymbol(forCurrencyCode: Locale.current.currencyCode ?? "EUR") ?? "€") + " " + (numberFormatter.string(for: sumSavings) ?? "0.00"))
    }
    
    func transactionsZero() -> Bool {
        let transCategoriesPredicate = NSPredicate(format: "selectedForFilter == %@", NSNumber(value: true))
        var transCategories = [Int]()
        for data in dataHandler.loadBulkQueried(entitie: "Categories", query: transCategoriesPredicate) {
            transCategories.append(Int((data.value(forKey: "cID") as? Int16 ?? 0)))
        }
        
        if transCategories.count > 0 {
            let predicate = NSPredicate(format: "dateTime >= %@ AND dateTime < %@", (fromDateShown ?? Date()) as NSDate, (toDateShown ?? Date()) as NSDate)
            for data in dataHandler.loadBulkQueried(entitie: "Transactions", query: predicate) {
                if transCategories.contains(Int(data.value(forKey: "categoryID") as? Int16 ?? -1)) && tagIsSelectedInFilter(tag: (data.value(forKey: "tags") as? String ?? "-1y")) {
                    return false
                }
            }
            return true
        } else {
            return true
        }
    }
    
//    func filteredCategoriesZero() -> Bool {
//        let categoriesPredicate = NSPredicate(format: "selectedForFilter == %@", NSNumber(value: false))
//        if loadBulkQueried(entitie: "Categories", query: categoriesPredicate).count > 0 {
//            return true
//        } else {
//            return false
//        }
//    }
//
//    func filteredTagsZero() -> Bool {
//        let categoriesPredicate = NSPredicate(format: "selectedForFilter == %@", NSNumber(value: false))
//        if loadBulkQueried(entitie: "Tags", query: categoriesPredicate).count > 0 {
//            return true
//        } else {
//            return false
//        }
//    }
    
    func initTagFilter() {
        filteredTagsArray.removeAll()
        if filteredTagsZero {
            let tagsPredicate = NSPredicate(format: "selectedForFilter == %@", NSNumber(value: true))
            for data in dataHandler.loadBulkQueried(entitie: "Tags", query: tagsPredicate) {
                filteredTagsArray.append(data.value(forKey: "tagName") as? String ?? "")
            }
        }
    }
    
    func tagIsSelectedInFilter(tag: String) -> Bool {
        if !filteredTagsZero {
            return true
        }
        for tags in filteredTagsArray {
            if tag.contains(tags) {
                return true
            }
        }
        return false
    }
}

extension listMasterTVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionCellData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCollectionViewCell", for: indexPath) as! listCollectionViewCell
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            cell.mainView.backgroundColor = .white
        } else {
            cell.mainView.backgroundColor = .black
        }
        cell.cornerRadius = 10

        cell.expensesAmount.text = collectionCellData[indexPath.row]?[1] as? String
        cell.earningsAmount.text = collectionCellData[indexPath.row]?[2] as? String
        cell.savedAmount.text = collectionCellData[indexPath.row]?[3] as? String
        
        if indexPath.row == 0 {
            cell.arrowLeft.isHidden = true
        } else {
            cell.arrowLeft.isHidden = false
        }
        
        if indexPath.row == (collectionCellData.count-1) {
            cell.arrowRight.isHidden = true
        } else {
            cell.arrowRight.isHidden = false
        }
        
        DispatchQueue.main.async {
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }

        return cell
    }
}

extension listMasterTVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }
}

extension listMasterTVC: searchBarDelegate {
    func cancelButtonPressed() {
        toggleSearchBar()
    }
    
    func seachBarTextChanged(searchText: String) {
        if (searchText.count) > 0 {
            transferData.removeAll()

            let categorySort = NSSortDescriptor(key: "categoryID", ascending: true)
            let dateSort = NSSortDescriptor(key: "dateTime", ascending: true)
                        
            let query = NSPredicate(format: "descriptionNote CONTAINS %@ AND dateTime >= %@ AND dateTime <= %@", searchText, fromDateShown! as NSDate, toDateShown! as NSDate)
                        
            transferData = createTransactionDataFromCoreData(result: dataHandler.loadDataSorted(entitie: "Transactions", query: query, sortBy: [categorySort, dateSort]))

            listTable.reloadData()
        } else {
            self.transactionAdded(scrollToId: carouselScrollingId, reload: false)
        }
    }
    
    func toggleScrolling(disabled: Bool) {
        listTable.isScrollEnabled = disabled
    }
}

extension listMasterTVC: listBottomBarDelegate {
    func segmentControlChanged(selected: Int) {
        activityIndicator.startAnimating()
        
        switch selected {
        case 1:
            timeInterval = 2
            break
        case 2:
            timeInterval = 3
            break
        case 3:
            timeInterval = 0
            break
        default:
            timeInterval = 1
            break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.setCollectionCellData(completion: {(success) -> Void in
                self.activityIndicator.stopAnimating()
            })
            self.setData(timeInterval: self.timeInterval ?? 2, fDateShown: self.collectionCellData[self.carouselScrollingId]?[4] as? Date ?? Date())
            
            self.listTable.reloadData()
            self.collectionView.carousel.reloadData()
        }
    }
}

extension listMasterTVC {
    @objc func carouselScrolling(notification: Notification) {
        if let userInfo = notification.userInfo, let currentCenterIndex = userInfo["currentCenterIndex"] as? Int {
            if currentCenterIndex != carouselScrollingId && viewAppeared {
                carouselScrollingId = currentCenterIndex
//                activityIndicator.startAnimating()
                
                var seconds:Double = 0.1
                switch timeInterval {
                case 1: // Weekly
                    seconds = 0.05
                    break
                case 2: // Monthly
                    seconds = 0.1
                    break
                case 3: // Yearly
                    seconds = 0.2
                    break
                default:
                    seconds = 0.1
                    break
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.setData(timeInterval: self.timeInterval ?? 2, fDateShown: self.collectionCellData[self.carouselScrollingId]?[4] as? Date ?? Date())
                    self.selectedRowIndex = nil
//                    self.activityIndicator.stopAnimating()
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.initFirstSelected()
                        self.listTable.reloadData()
//                    }
                }
            }
        }
    }
}

extension Date {
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: Calendar.current.firstWeekday, to: sunday)
    }
    
    var endOfWeek: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfWeek ?? Date())!
    }
    
    var startOfMonth: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        return  calendar.date(from: components)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    var startOfYear: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year], from: self)
        return  calendar.date(from: components)!
    }
    
    var endOfYear: Date {
        var components = DateComponents()
        components.year = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfYear)!
    }
    
    var currentMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: self)
    }
    
    var currentYear: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    func formattedFromComponents(styleAttitude: DateFormatter.Style, year: Bool = false, month: Bool = false, day: Bool = false, hour: Bool = false, minute: Bool = false, second: Bool = false, locale: Locale = Locale.current) -> String {
        let long = styleAttitude == .long || styleAttitude == .full
        let short = styleAttitude == .short
        var comps = ""

        if year { comps += long ? "yyyy" : "yy" }
        if month { comps += long ? "MMMM" : (short ? "MM" : "MMM") }
        if day { comps += long ? "dd" : "d" }

        if hour { comps += long ? "HH" : "H" }
        if minute { comps += long ? "mm" : "m" }
        if second { comps += long ? "ss" : "s" }
        let format = DateFormatter.dateFormat(fromTemplate: comps, options: 0, locale: locale)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

