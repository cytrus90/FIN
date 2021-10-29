//
//  ViewController.swift
//  FIN
//
//  Created by Florian Riel on 25.12.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import ScalingCarousel
import Charts
import SwiftUI
import CoreData

class graphsVC: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var chartStackView: UIStackView!
    @IBOutlet weak var labelStackView: UIStackView!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var chartTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var carouselView: UICollectionView!
    @IBOutlet weak var secondCarouselView: UICollectionView!
    
    @IBOutlet weak var carouselStackView: UIStackView!
    
    @IBOutlet weak var outlineViewTopConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelLeft: UILabel!
    
    let activityIndicator = UIActivityIndicatorView()
    
    var filteredTagsArray = [String]()
    
    var collectionCellData = [Int:[Int:Any]]()
    var carouselScrollingId: Int = 0
    var carouselScrollingTodayId: Int = 0
    
    var secondCarouselScrollingId:Int = 0
    
    var outlineTopViewConstraint:NSLayoutConstraint?
    
    var firstCarouselWidthConstraints = [NSLayoutConstraint]()
    var secondCarouselWidthConstraints = [NSLayoutConstraint]()
    
    var viewDisappear = false
    var viewAppeared = false
    var scrollViewScrolling = false
    
    var mediumDate = DateFormatter()
    var shortDate = DateFormatter()
    var monthNameFormat = DateFormatter()
    var yearNameFormat = DateFormatter()
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    var numberFormatter = NumberFormatter()
    var lineNumberFormatter = NumberFormatter()
    var numberFormatterPercent = NumberFormatter()
    
    var graphName:String?
    var graphIDActive:Int?
    var graphOption1:Int? // Balance, EX.vs.EA, Tags, Categories...
    var graphOption2:Int? // Monthly, Yearly, All
    
    var secondGraph:Bool = true
    var graphOption3:Int? // Balance, EX.vs.EA, Tags, Categories...
    
    let secondOutlineView = UIView()
    let secondChartStackView = UIStackView()
    
    let secondLabel = UILabel()
    let secondLeftLabel = UILabel()
    
    var fromDateShown: Date?
    var toDateShown: Date?
    
    var nameUser:String?
    var createDateUser:Date?
    var userDatePlus:Date = Date()
    var userDateMinus:Date = Date()

    let pieChart = PieChartView()
    var pieChartSum:Double?
    var pieChartLabels:[String]?
    
    let secondPieChart = PieChartView()
    var secondPieChartSum:Double?
    var secondPieChartLabels:[String]?
    
    var secondChartTopConstraint:NSLayoutConstraint?
    
    let lineChart = LineChartView()
    let secondLineChart = LineChartView()
    
    struct LineChartEntry {
        var value:Double
        var dateTime:Date
        var index:Int
    }
    
    var lineChartEntries = [LineChartEntry]()
    var lineChartEntriesExpenses = [LineChartEntry]()
    
    var secondLineChartEntries = [LineChartEntry]()
    
    var lineChartMax = 0.00
    var lineCharMin = 0.00
    var lineChartDates = [Date]()
    var lineChartRealValues = [Double]()
    var lineChartDifference = 0.00
    
    var secondLineChartMax = 0.00
    var secondLineCharMin = 0.00
    var secondLineChartDates = [Date]()
    var secondLineChartRealValues = [Double]()
    var secondLineChartDifference = 0.00
    
    let barChart = BarChartView()
    let secondBarChart = BarChartView()
    
    var barChartDifference = 0.00
    var secondBarChartDifference = 0.00
    
    var barChartEntriesCount = 0
    
    var initialLoad:Bool = true
    
    override func loadView() {
        super.loadView()
        initChartSettings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        axisFormatDelegate = self
        
        label.text = ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("filterChangedForGraph"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setBarButtons), name: Notification.Name("filterChanged"), object: nil)
        
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        
        lineNumberFormatter.numberStyle = .currency
        lineNumberFormatter.locale = Locale.current
        lineNumberFormatter.positivePrefix = "+"
        
        numberFormatterPercent.numberStyle = .decimal
        numberFormatterPercent.usesGroupingSeparator = true
        numberFormatterPercent.groupingSeparator = Locale.current.groupingSeparator
        numberFormatterPercent.groupingSize = 3
        numberFormatterPercent.minimumFractionDigits = 2
        numberFormatterPercent.maximumFractionDigits = 2
        
        let nib = UINib(nibName: "graphCarouselCell", bundle: nil)
        carouselView.register(nib, forCellWithReuseIdentifier: "graphCarouselCell")
        setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: 0)
        
        secondCarouselView.register(nib, forCellWithReuseIdentifier: "graphCarouselCell")
        setSecondCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: 0)
        
        if secondGraph {
            carouselStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            carouselStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
            
            carouselStackView.spacing = -10
        } else {
            carouselStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            carouselStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
            
            carouselStackView.spacing = 0
        }
        
        mediumDate.dateStyle = .medium
        shortDate.dateStyle = .short
        
        monthNameFormat.dateFormat = "MMMM"
        yearNameFormat.dateFormat = "YY"
        
        initView()
        initTagFilter()
        setInitialToFromMaxDates()
        setCollectionCellData(completion: {(success) -> Void in
            carouselView.reloadData()
            if secondGraph {
                print("00000000")
                secondCarouselView.reloadData()
            }
        })
        
        //carouselView.backgroundColor = .blue
        //secondCarouselView.backgroundColor = .red
        
        showChart()
        print("55555_666666")
        self.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("666666_666666")
        if UIDevice().model.contains("iPhone") && (view.frame.height < view.frame.width) {
            hideCarouselView()
        } else if UIDevice().model.contains("iPhone") && (view.frame.height > view.frame.width) {
            showCarouselView()
        }
        print("6666666")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        viewAppeared = true
        viewDisappear = false
        showChart(viewAppeared: true)
        print("777777777")
        // secondCarouselView.layoutSubviews()
        if reloadGraphView && !initialLoad {
            reloadGraphView = false
            refresh()
        }
        print("888888888")
        initialLoad = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        viewDisappear = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !viewDisappear {
            if UIDevice.current.orientation.isLandscape {
                if UIDevice().model.contains("iPhone") {
                    hideCarouselView()
                }
            } else if UIDevice.current.orientation.isPortrait {
                if UIDevice().model.contains("iPhone") {
                    showCarouselView()
                }
            }
        }
        setCellLayout()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        initView()
        showChart(refresh: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if carouselView != nil {
            //carouselView.deviceRotated()
            carouselView.layoutIfNeeded()
        }
        if secondCarouselView != nil && secondGraph {
            //secondCarouselView.deviceRotated()
            secondCarouselView.layoutIfNeeded()
        }
    }
    
    // MARK: -INITVIEW
    func initView() {
        outlineView.layer.borderWidth = 1
        outlineView.layer.cornerRadius = 10
        
        secondOutlineView.layer.borderWidth = 1
        secondOutlineView.layer.cornerRadius = 10
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            outlineView.backgroundColor = .white
            outlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            secondOutlineView.backgroundColor = .white
            secondOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.view.backgroundColor = backgroundGeneralColor
        } else {
            self.view.backgroundColor = .secondarySystemBackground
            outlineView.backgroundColor = .black
            outlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
            secondOutlineView.backgroundColor = .black
            secondOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
            self.view.backgroundColor = .secondarySystemBackground
        }
        
        setBarButtons()
        setNameDateUser()
        
        activityIndicator.style = .medium
        activityIndicator.hidesWhenStopped = true
        mainStackView.addSubview(activityIndicator)
        mainStackView.bringSubviewToFront(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerYAnchor.constraint(equalTo: mainStackView.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: mainStackView.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
    }
    
    func initSecondOutlineView() {
        mainStackView.addArrangedSubview(secondOutlineView)
        mainStackView.spacing = 10
        
        secondLabel.font = UIFont.preferredFont(forTextStyle: .body)
        secondLabel.textAlignment = .right
        
        secondLeftLabel.font = UIFont.preferredFont(forTextStyle: .body)
        secondLeftLabel.textAlignment = .left
                
        if graphIDActive == 0 {
            secondLeftLabel.text = NSLocalizedString("changeLabel", comment: "Balance")
        } else {
            if graphOption2 == 0 {
                secondLeftLabel.text = NSLocalizedString("pieChartOption1_0", comment: "Expense")
            } else if graphOption2 == 1 {
                secondLeftLabel.text = NSLocalizedString("pieChartOption1_1", comment: "Income")
            } else {
                secondLeftLabel.text = NSLocalizedString("pieChartOption1_2", comment: "Savings")
            }
        }

        let secondLabelStackView = UIStackView()
        secondLabelStackView.translatesAutoresizingMaskIntoConstraints = false
        
        secondLabelStackView.axis = .horizontal
        secondLabelStackView.alignment = .fill
        secondLabelStackView.distribution = .fillEqually
        secondLabelStackView.spacing = 0
        
        secondLabelStackView.addArrangedSubview(secondLeftLabel)
        secondLabelStackView.addArrangedSubview(secondLabel)
        
        secondOutlineView.addSubview(secondLabelStackView)
        secondLabelStackView.leadingAnchor.constraint(equalTo: secondOutlineView.leadingAnchor, constant: 15).isActive = true
        secondLabelStackView.trailingAnchor.constraint(equalTo: secondOutlineView.trailingAnchor, constant: -15).isActive = true
        secondLabelStackView.topAnchor.constraint(equalTo: secondOutlineView.topAnchor, constant: 15).isActive = true
                
        secondChartStackView.translatesAutoresizingMaskIntoConstraints = false
        secondOutlineView.addSubview(secondChartStackView)
        secondChartStackView.leadingAnchor.constraint(equalTo: secondOutlineView.leadingAnchor, constant: 5).isActive = true
        secondChartStackView.trailingAnchor.constraint(equalTo: secondOutlineView.trailingAnchor, constant: -5).isActive = true
        secondChartStackView.topAnchor.constraint(equalTo: secondLabel.bottomAnchor, constant: 0).isActive = true
        secondChartStackView.bottomAnchor.constraint(equalTo: secondOutlineView.bottomAnchor, constant: -5).isActive = true
    }
    
    func initSecondCarouselView() {
        //let nib = UINib(nibName: "graphCarouselCell", bundle: nil)
        //secondCarouselView.register(nib, forCellWithReuseIdentifier: "graphCarouselCell")
        //setSecondCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: 0)
        
        //carouselStackView.addArrangedSubview(secondCarouselView)
        //carouselStackView.spacing = 15
        // secondCarouselView.backgroundColor = .red
    }
    
    // MARK: ScrollView
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        // carousel.delegate = dataSourceDelegate
        carouselView.delegate = self
        carouselView.dataSource = dataSourceDelegate
        carouselView.tag = row
        carouselView.reloadData()
    }
    
    func setSecondCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        secondCarouselView.delegate = self
        secondCarouselView.dataSource = dataSourceDelegate
        secondCarouselView.tag = row
        secondCarouselView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewScrolling = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView == carouselView) && viewAppeared {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                for cell in self.carouselView.visibleCells {
                    guard let currentCenterIndex = self.carouselView.indexPath(for: cell)?.row else { return }
                    
                    let cellRect = self.carouselView.convert(cell.frame, to: nil)
                        
                    let lowerBound = cellRect.midX - 20
                    let upperBound = cellRect.midX + 20
                    let centerCarousel = self.carouselView.frame.midX
                        
                    if centerCarousel > lowerBound && centerCarousel < upperBound {
                        self.carouselScrollingId = currentCenterIndex
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            if self.graphIDActive == 0 { // Line
                                self.viewLineChart()
                            } else if self.graphIDActive == 1 { // Pie
                                if self.graphOption1 == 0 {
                                    self.labelLeft.text = NSLocalizedString("pieChartOption1_0", comment: "Expense")
                                } else if self.graphOption1 == 1 {
                                    self.labelLeft.text = NSLocalizedString("pieChartOption1_1", comment: "Income")
                                } else {
                                    self.labelLeft.text = NSLocalizedString("pieChartOption1_2", comment: "Savings")
                                }
                                if self.view.frame.height > self.view.frame.width {
                                    self.viewPieChart()
                                } else {
                                    self.viewPieChart()
                                }
                            } else if self.graphIDActive == 2 {
                                self.viewBarChart()
                            }
                        }
                        self.scrollViewScrolling = false
                        return
                    }
                }
            }
        } else if (scrollView == secondCarouselView) && viewAppeared {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                for cell in self.secondCarouselView.visibleCells {
                    guard let currentCenterIndex = self.secondCarouselView.indexPath(for: cell)?.row else { return }
                        
                    let cellRect = self.secondCarouselView.convert(cell.frame, to: nil)

                    let lowerBound = cellRect.midX - 20
                    let upperBound = cellRect.midX + 20
                    let centerCarousel = self.secondCarouselView.frame.midX
                    
                    if centerCarousel > lowerBound && centerCarousel < upperBound {
                        self.secondCarouselScrollingId = currentCenterIndex
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            if self.graphIDActive == 0 { // Line
                                self.viewSecondLineChart()
                            } else if self.graphIDActive == 1 { // Pie
                                if self.graphOption3 == 0 {
                                    self.secondLeftLabel.text = NSLocalizedString("pieChartOption1_0", comment: "Expense")
                                } else if self.graphOption3 == 1 {
                                    self.secondLeftLabel.text = NSLocalizedString("pieChartOption1_1", comment: "Income")
                                } else {
                                    self.secondLeftLabel.text = NSLocalizedString("pieChartOption1_2", comment: "Savings")
                                }
                                if self.view.frame.height > self.view.frame.width {
                                    self.viewSecondPieChart()
                                } else {
                                    self.viewSecondPieChart()
                                }
                            } else if self.graphIDActive == 2 { // Bar
                                self.viewSecondBarChart()
                            }
                        }
                        self.scrollViewScrolling = false
                        return
                    }
                }
            }
        }
    }
    
    // MARK: ANIMATIONS
    func hideCarouselView() {
        outlineViewTopConstraint?.isActive = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.carouselStackView.alpha = 0.0
            if self.secondGraph {
                self.secondCarouselView.alpha = 0.0
            }
            self.outlineTopViewConstraint?.isActive = false
            self.outlineTopViewConstraint = self.outlineView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10)
            self.outlineTopViewConstraint?.isActive = true
        })
    }
    
    func showCarouselView() {
        outlineViewTopConstraint?.isActive = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.carouselStackView.alpha = 1.0
            if self.secondGraph {
                self.secondCarouselView.alpha = 1.0
            }
            self.outlineTopViewConstraint?.isActive = false
            self.outlineTopViewConstraint = self.outlineView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 70)
            self.outlineTopViewConstraint?.isActive = true
        })
    }
    
    // MARK: -FUNCTIONS
    // MARK: CHART FUNCTIONS
    func showChart(viewAppeared:Bool = false, refresh: Bool = false) {
//        if secondGraph && (viewAppeared || refresh) {
//            print("111111111")
//            initSecondCarouselView()
//        }
        print("11111111")
        print(graphIDActive)
        if graphIDActive == 0 && (viewAppeared || refresh) { // Line Chart
            activityIndicator.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.viewLineChart(createNew: true)
            }
            labelLeft.text = NSLocalizedString("changeLabel", comment: "Balance")
            
            if secondGraph {
                initSecondOutlineView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.viewSecondLineChart(createNew: true)
                }
            }
        } else if graphIDActive == 1 && (!viewAppeared || refresh) { // Pie Chart
            if graphOption1 == 0 {
                labelLeft.text = NSLocalizedString("pieChartOption1_0", comment: "Expense")
            } else if graphOption1 == 1 {
                labelLeft.text = NSLocalizedString("pieChartOption1_1", comment: "Income")
            } else {
                labelLeft.text = NSLocalizedString("pieChartOption1_2", comment: "Savings")
            }
            if self.view.frame.height > self.view.frame.width {
                viewPieChart(createNew: true)
            } else {
                viewPieChart(createNew: true)
            }
            
            if secondGraph {
                initSecondOutlineView()
                
                if graphOption3 == 0 {
                    secondLeftLabel.text = NSLocalizedString("pieChartOption1_0", comment: "Expense")
                } else if graphOption3 == 1 {
                    secondLeftLabel.text = NSLocalizedString("pieChartOption1_1", comment: "Income")
                } else {
                    secondLeftLabel.text = NSLocalizedString("pieChartOption1_2", comment: "Savings")
                }
                
                if self.view.frame.height > self.view.frame.width {
                    viewSecondPieChart(createNew: true)
                } else {
                    viewSecondPieChart(createNew: true)
                }
            }
        } else if graphIDActive == 2 && (viewAppeared || refresh) { // Bar Chart
            viewBarChart(createNew: true)
            print("22222222")
            if secondGraph {
                initSecondOutlineView()
                print("333333333")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    print("4444444")
                    self.viewSecondBarChart(createNew: true)
                    print("55555555")
                }
            }
        }
        print("55555555888888")
    }
    
    func viewPieChart(createNew:Bool = false) {
        label.isHidden = false
        labelLeft.isHidden = false
        if createNew {
            if chartTopConstraint.isActive {
                chartTopConstraint.isActive = false
            }
            chartTopConstraint = chartStackView.topAnchor.constraint(equalTo: outlineView.topAnchor, constant: 5)
            chartTopConstraint.isActive = true
            
            chartStackView.subviews.forEach({ $0.removeFromSuperview() })
            chartStackView.addArrangedSubview(pieChart)
            chartStackView.layoutSubviews()
            
            chartStackView.isUserInteractionEnabled = true
        }
        pieChart.clear()
        pieChart.data?.dataSets.removeAll()
        
        pieChart.tag = 0
        
        let pieData = getPieChartData()
        
        pieChartSum = pieData.2
        pieChartLabels = pieData.3
        
        label.text = numberFormatter.string(from: NSNumber(value: pieChartSum ?? 0.00))
        
        let dataSet = PieChartDataSet(entries: pieData.0, label: "")
        dataSet.colors = pieData.1
        
        let data = PieChartData(dataSet: dataSet)
        
        pieChart.data = data
        pieChart.legend.enabled = true
        pieChart.legend.font = .preferredFont(forTextStyle: .footnote)
//        pieChart.entryLabelFont = .preferredFont(forTextStyle: .footnote)
//        pieChart.data?.setValueFont(.preferredFont(forTextStyle: .footnote))
//        pieChart.data?.setValueTextColor(.black)
        pieChart.drawEntryLabelsEnabled = false
        pieChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutQuart)
        pieChart.data?.setDrawValues(false)
        pieChart.backgroundColor = .clear
        
        pieChart.holeColor = .clear
        pieChart.delegate = self
        
        var textColor = UIColor.white
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            textColor = UIColor.black
        }
        let centerTextText = (numberFormatterPercent.string(from: NSNumber(value: 100.00)) ?? "100.00") + "%"
        let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
        let centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
        
        pieChart.centerAttributedText = centerText
        
        pieChart.setSmoothSelected(true)
        
        pieChart.notifyDataSetChanged()
    }
    
    func viewSecondPieChart(createNew:Bool = false) {
        secondLabel.isHidden = false
        secondLeftLabel.isHidden = false
        if createNew {
            secondChartStackView.subviews.forEach({ $0.removeFromSuperview() })
            secondChartStackView.addArrangedSubview(secondPieChart)
            
            secondChartStackView.isUserInteractionEnabled = true
        }
        
        secondPieChart.clear()
        secondPieChart.data?.dataSets.removeAll()
        
        secondPieChart.tag = 1
        
        let secondPieData = getSecondPieChartData()
        
        secondPieChartSum = secondPieData.2
        secondPieChartLabels = secondPieData.3
        
        secondLabel.text = numberFormatter.string(from: NSNumber(value: secondPieChartSum ?? 0.00))
        
        let dataSet = PieChartDataSet(entries: secondPieData.0, label: "")
        dataSet.colors = secondPieData.1
        
        let data = PieChartData(dataSet: dataSet)
        
        secondPieChart.data = data
        secondPieChart.legend.enabled = true
        secondPieChart.legend.font = .preferredFont(forTextStyle: .footnote)
//        pieChart.entryLabelFont = .preferredFont(forTextStyle: .footnote)
//        pieChart.data?.setValueFont(.preferredFont(forTextStyle: .footnote))
//        pieChart.data?.setValueTextColor(.black)
        secondPieChart.drawEntryLabelsEnabled = false
        secondPieChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutQuart)
        secondPieChart.data?.setDrawValues(false)
        secondPieChart.backgroundColor = .clear
        
        secondPieChart.holeColor = .clear
        secondPieChart.delegate = self
        
        var textColor = UIColor.white
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            textColor = UIColor.black
        }
        let centerTextText = (numberFormatterPercent.string(from: NSNumber(value: 100.00)) ?? "100.00") + "%"
        let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
        let centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
        
        secondPieChart.centerAttributedText = centerText
        
        secondPieChart.setSmoothSelected(true)
        
        secondPieChart.notifyDataSetChanged()
    }
    
    func viewLineChart(createNew:Bool = false) {
//        label.isHidden = true
//        labelLeft.isHidden = true
        if createNew {
            if chartTopConstraint.isActive {
                chartTopConstraint.isActive = false
            }
            chartTopConstraint = chartStackView.topAnchor.constraint(equalTo: labelStackView.bottomAnchor, constant: 0)
            chartTopConstraint.isActive = true
            
            chartStackView.subviews.forEach({ $0.removeFromSuperview() })
            chartStackView.addArrangedSubview(lineChart)
            chartStackView.layoutSubviews()
            
            chartStackView.isUserInteractionEnabled = true
        }
        
        lineChart.clear()
        
        let lineData = getLineChartData()
        
        let data = LineChartData()
        
        lineChartDates.removeAll()
        lineChartDates = lineData.1
        
        var chartTitle = ""
        switch graphOption1 {
        case 2: // Expenses vs. Income
            chartTitle = NSLocalizedString("pieChartOption1_1", comment: "Income")
            
            let lineDataExpenses = getLineChartData(getExpenses: true)
            
            let line2 = LineChartDataSet(entries: lineDataExpenses.0, label: NSLocalizedString("pieChartOption1_0", comment: "Expenses"))
            
            line2.drawCirclesEnabled = false
            line2.drawFilledEnabled = true
            line2.mode = .cubicBezier
            
            line2.colors.removeAll()
            line2.colors = [NSUIColor.red]
//            line2.fillColor = NSUIColor.red.withAlphaComponent(0.2)
            line2.fillColor = .clear
            
            data.addDataSet(line2)
            
            break
        case 1: // Savings
            chartTitle = NSLocalizedString("lineChartOption1_2", comment: "Savings")
            break
        default: // Balance
            chartTitle = NSLocalizedString("lineChartOption1_0", comment: "Balance")
            break
        }
        
        let line1 = LineChartDataSet(entries: lineData.0, label: chartTitle)
        line1.mode = .linear
        line1.drawCirclesEnabled = false
        line1.drawFilledEnabled = true
        line1.fillColor = .clear
        
        // Body Text Sizes:
        // 14.0
        // 15.0
        // 16.0
        // 17.0
        // 19.0
        // 21.0
        // 23.0
        if label.font.pointSize < 16 {
            line1.lineWidth = 1
        } else if label.font.pointSize < 19 {
            line1.lineWidth = 2
        } else {
            line1.lineWidth = 3
        }
        
        data.addDataSet(line1)
        
        lineChart.data = data
        lineChart.data?.setDrawValues(false)
        
        lineChart.drawGridBackgroundEnabled = false
        lineChart.drawBordersEnabled = false
        lineChart.drawMarkers = false
        lineChart.backgroundColor = .clear
        lineChart.doubleTapToZoomEnabled = false
        
        lineChart.rightAxis.enabled = false
        lineChart.drawGridBackgroundEnabled = false
        
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.gridLineWidth = 0.00
        lineChart.xAxis.enabled = false
        
        lineChart.leftAxis.gridLineWidth = 0.00
        
        lineChart.leftAxis.enabled = false
        
        if graphOption2 != 0 && (lineData.0.count > 10) {
            lineChart.animate(xAxisDuration: 2.0, easingOption: .easeInOutQuart)
        }
        
        var isDark:Bool = true
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            isDark = false
        }
        
        if lineData.2 && (graphOption1 != 2) {
            line1.colors.removeAll()
            if !isDark {
                line1.colors = [NSUIColor.init(cgColor: CGColor(srgbRed: 204/255, green: 0/255, blue: 0/255, alpha: 1.0))]
            } else {
                line1.colors = [NSUIColor.init(cgColor: CGColor(srgbRed: 255/255, green: 26/255, blue: 26/255, alpha: 1.0))]
            }
//            line1.fillColor = NSUIColor.red.withAlphaComponent(0.2)
        } else if !lineData.2 && (graphOption1 != 2) {
            line1.colors.removeAll()
            if !isDark {
                line1.colors = [NSUIColor.init(cgColor: CGColor(srgbRed: 0/255, green: 153/255, blue: 51/255, alpha: 1.0))]
            } else {
                line1.colors = [NSUIColor.init(cgColor: CGColor(srgbRed: 0/255, green: 255/255, blue: 0/255, alpha: 1.0))]
            }
//            line1.fillColor = NSUIColor.green.withAlphaComponent(0.2)
        } else {
            line1.colors.removeAll()
            if !isDark {
                line1.colors = [NSUIColor.init(cgColor: CGColor(srgbRed: 0/255, green: 153/255, blue: 51/255, alpha: 1.0))]
            } else {
                line1.colors = [NSUIColor.init(cgColor: CGColor(srgbRed: 0/255, green: 255/255, blue: 0/255, alpha: 1.0))]
            }
//            line1.fillColor = NSUIColor.green.withAlphaComponent(0.2)
        }
        
        labelLeft.text = NSLocalizedString("changeLabel", comment: "Balance")
        label.text = lineNumberFormatter.string(from: NSNumber(value: lineData.3))
        lineChartDifference = lineData.3
        
        lineChart.delegate = self
        lineChart.tag = 0
        
        lineChart.notifyDataSetChanged()
        activityIndicator.stopAnimating()
    }
        
    func viewSecondLineChart(createNew:Bool = false) {
        if createNew {
            secondChartStackView.subviews.forEach({ $0.removeFromSuperview() })
            secondChartStackView.addArrangedSubview(secondLineChart)
            secondChartStackView.layoutSubviews()
            
            secondChartStackView.isUserInteractionEnabled = true
        }
        
        secondLineChart.clear()
        
        let lineData = getSecondLineChartData()
        
        let data = LineChartData()
        
        secondLineChartDates.removeAll()
        secondLineChartDates = lineData.1
        
        var chartTitle = ""
        switch graphOption3 {
        case 1: // Savings
            chartTitle = NSLocalizedString("lineChartOption1_2", comment: "Savings")
            break
        default: // Balance
            chartTitle = NSLocalizedString("lineChartOption1_0", comment: "Balance")
            break
        }
        
        let line1 = LineChartDataSet(entries: lineData.0, label: chartTitle)
        line1.mode = .linear
        line1.drawCirclesEnabled = false
        line1.drawFilledEnabled = true
        line1.fillColor = .clear
        
        // Body Text Sizes:
        // 14.0
        // 15.0
        // 16.0
        // 17.0
        // 19.0
        // 21.0
        // 23.0
        if label.font.pointSize < 16 {
            line1.lineWidth = 1
        } else if label.font.pointSize < 19 {
            line1.lineWidth = 2
        } else {
            line1.lineWidth = 3
        }
        
        data.addDataSet(line1)
        
        secondLineChart.data = data
        secondLineChart.data?.setDrawValues(false)
        
        secondLineChart.drawGridBackgroundEnabled = false
        secondLineChart.drawBordersEnabled = false
        secondLineChart.drawMarkers = false
        secondLineChart.backgroundColor = .clear
        secondLineChart.doubleTapToZoomEnabled = false
        
        secondLineChart.rightAxis.enabled = false
        secondLineChart.drawGridBackgroundEnabled = false
        
        secondLineChart.xAxis.labelPosition = .bottom
        secondLineChart.xAxis.gridLineWidth = 0.00
        secondLineChart.xAxis.enabled = false
        
        secondLineChart.leftAxis.gridLineWidth = 0.00
        
        secondLineChart.leftAxis.enabled = false
        
        if graphOption2 != 0 && (lineData.0.count > 10) {
            secondLineChart.animate(xAxisDuration: 2.0, easingOption: .easeInOutQuart)
        }
        
        var isDark:Bool = true
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            isDark = false
        }
        
        if lineData.2 && (graphOption3 != 2) {
            line1.colors.removeAll()
            if !isDark {
                line1.colors = [NSUIColor.init(cgColor: CGColor(srgbRed: 204/255, green: 0/255, blue: 0/255, alpha: 1.0))]
            } else {
                line1.colors = [NSUIColor.init(cgColor: CGColor(srgbRed: 255/255, green: 26/255, blue: 26/255, alpha: 1.0))]
            }
//            line1.fillColor = NSUIColor.red.withAlphaComponent(0.2)
        } else if !lineData.2 && (graphOption3 != 2) {
            line1.colors.removeAll()
            if !isDark {
                line1.colors = [NSUIColor.init(cgColor: CGColor(srgbRed: 0/255, green: 153/255, blue: 51/255, alpha: 1.0))]
            } else {
                line1.colors = [NSUIColor.init(cgColor: CGColor(srgbRed: 0/255, green: 255/255, blue: 0/255, alpha: 1.0))]
            }
//            line1.fillColor = NSUIColor.green.withAlphaComponent(0.2)
        } else {
            line1.colors.removeAll()
            if !isDark {
                line1.colors = [NSUIColor.init(cgColor: CGColor(srgbRed: 0/255, green: 153/255, blue: 51/255, alpha: 1.0))]
            } else {
                line1.colors = [NSUIColor.init(cgColor: CGColor(srgbRed: 0/255, green: 255/255, blue: 0/255, alpha: 1.0))]
            }
//            line1.fillColor = NSUIColor.green.withAlphaComponent(0.2)
        }
        
        secondLeftLabel.text = NSLocalizedString("changeLabel", comment: "Balance")
        secondLabel.text = lineNumberFormatter.string(from: NSNumber(value: lineData.3))
        secondLineChartDifference = lineData.3
        
        secondLineChart.delegate = self
        secondLineChart.tag = 1
        
        secondLineChart.notifyDataSetChanged()
        activityIndicator.stopAnimating()
    }
    
    func viewBarChart(createNew:Bool = false) {
        if createNew {
            if chartTopConstraint.isActive {
                chartTopConstraint.isActive = false
            }
            chartTopConstraint = chartStackView.topAnchor.constraint(equalTo: labelStackView.bottomAnchor, constant: 0)
            chartTopConstraint.isActive = true
            
            chartStackView.subviews.forEach({ $0.removeFromSuperview() })
            chartStackView.addArrangedSubview(barChart)
            chartStackView.layoutSubviews()
            
            chartStackView.isUserInteractionEnabled = true
        }
        
        barChart.clear()
        barChart.data?.dataSets.removeAll()
        
        barChart.doubleTapToZoomEnabled = false
        
        let barData = getBarChartData()
        barChartEntriesCount = barData.2.count
        let dataSet = BarChartDataSet(entries: barData.0, label: "")
        dataSet.colors.removeAll()
        dataSet.colors = barData.1
        dataSet.setColors(barData.1, alpha: 1.0)
        
        let data = BarChartData(dataSets: [dataSet])

        barChart.data = data
        barChart.legend.enabled = false
        barChart.drawGridBackgroundEnabled = false
        
        barChart.rightAxis.enabled = false
        barChart.leftAxis.enabled = false
        
        barChart.drawValueAboveBarEnabled = false
        
        barChart.xAxis.labelFont = .preferredFont(forTextStyle: .footnote)
        barChart.xAxis.wordWrapEnabled = true
        barChart.xAxis.axisLineWidth = 0.00
        barChart.xAxis.gridLineWidth = 0.00
//        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: barData.2)
        
        barChart.xAxis.labelPosition = .bottomInside
        barChart.xAxis.labelCount = barData.2.count
        if barData.2.count < 2 && barData.2.count > 0 {
            barChart.xAxis.drawLabelsEnabled = false
            let dateFormatterRAM = DateFormatter()
            dateFormatterRAM.dateFormat = "dd/MM/yy"
            let valueString = "02/" + barData.2[0] + "/2021"
            let dateRAM = dateFormatterRAM.date(from: valueString) ?? Date()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            labelLeft.text = dateFormatter.string(from: dateRAM)
            barChart.animate(yAxisDuration: 1.0, easingOption: .easeInOutQuart)
        } else {
            barChart.xAxis.drawLabelsEnabled = true
            labelLeft.text = NSLocalizedString("changeLabel", comment: "Change")
            barChart.animate(yAxisDuration: 2.0, easingOption: .easeInOutQuart)
        }
        label.text = numberFormatter.string(from: NSNumber(value: barChartDifference))
//        barChart.xAxis.drawLabelsEnabled = false
//        barChart.xAxis.granularityEnabled = false
//        barChart.xAxis.granularity = 2
        
        barChart.xAxis.valueFormatter = axisFormatDelegate
        
        barChart.barData?.setValueFont(.preferredFont(forTextStyle: .footnote))
        
        barChart.barData?.setDrawValues(false)
        
        barChart.setSmoothSelected(true)
        
        barChart.delegate = self
        barChart.tag = 0
        
        barChart.notifyDataSetChanged()
        
//        if graphOption1 == 0 {
//            labelLeft.text = NSLocalizedString("barChartOption1_0", comment: "Balance")
//        } else {
//            labelLeft.text = NSLocalizedString("barChartOption1_1", comment: "Savings")
//        }
//
//        label.text = ""
    }
    
    func viewSecondBarChart(createNew:Bool = false) {
        if createNew {
            secondChartStackView.subviews.forEach({ $0.removeFromSuperview() })
            secondChartStackView.addArrangedSubview(secondBarChart)
            
            secondChartStackView.isUserInteractionEnabled = true
        }
        
        secondBarChart.clear()
        secondBarChart.data?.dataSets.removeAll()
        
        secondBarChart.doubleTapToZoomEnabled = false
        
        let barData = getSecondBarChartData()
        barChartEntriesCount = barData.2.count
        let dataSet = BarChartDataSet(entries: barData.0, label: "")
        dataSet.colors.removeAll()
        dataSet.colors = barData.1
        dataSet.setColors(barData.1, alpha: 1.0)
        
        let data = BarChartData(dataSets: [dataSet])

        secondBarChart.data = data
        secondBarChart.legend.enabled = false
        secondBarChart.drawGridBackgroundEnabled = false
        
        secondBarChart.rightAxis.enabled = false
        secondBarChart.leftAxis.enabled = false
        
        secondBarChart.xAxis.labelFont = .preferredFont(forTextStyle: .footnote)
        secondBarChart.xAxis.wordWrapEnabled = true
        secondBarChart.xAxis.axisLineWidth = 0.00
        secondBarChart.xAxis.gridLineWidth = 0.00
//        secondBarChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: barData.2)
        
        secondBarChart.xAxis.labelPosition = .bottomInside
        secondBarChart.xAxis.labelCount = barData.2.count
        if barData.2.count < 2  && barData.2.count > 0 {
            secondBarChart.xAxis.drawLabelsEnabled = false
            let dateFormatterRAM = DateFormatter()
            dateFormatterRAM.dateFormat = "dd/MM/yy"
            let valueString = "02/" + barData.2[0] + "/2021"
            let dateRAM = dateFormatterRAM.date(from: valueString) ?? Date()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            secondLeftLabel.text = dateFormatter.string(from: dateRAM)
            secondBarChart.animate(yAxisDuration: 1.0, easingOption: .easeInOutQuart)
        } else {
            secondBarChart.xAxis.drawLabelsEnabled = true
            secondLeftLabel.text = NSLocalizedString("changeLabel", comment: "Change")
            secondBarChart.animate(yAxisDuration: 2.0, easingOption: .easeInOutQuart)
        }
        secondLabel.text = numberFormatter.string(from: NSNumber(value: secondBarChartDifference))
//        secondBarChart.xAxis.drawLabelsEnabled = false
//        secondBarChart.xAxis.granularityEnabled = false
//        secondBarChart.xAxis.granularity = 2
        
        secondBarChart.xAxis.valueFormatter = axisFormatDelegate
        
        secondBarChart.barData?.setValueFont(.preferredFont(forTextStyle: .footnote))
        
        secondBarChart.barData?.setDrawValues(false)
        
        secondBarChart.animate(yAxisDuration: 2.0, easingOption: .easeInOutQuart)
        
        secondBarChart.setSmoothSelected(true)
        
        secondBarChart.delegate = self
        secondBarChart.tag = 1
        
        secondBarChart.notifyDataSetChanged()
        
//        if graphOption3 == 0 {
//            secondLeftLabel.text = NSLocalizedString("barChartOption1_0", comment: "Balance")
//        } else {
//            secondLeftLabel.text = NSLocalizedString("barChartOption1_1", comment: "Savings")
//        }
//
//        secondLabel.text = ""
    }
    
    func initChartSettings() {
        let graphSort = NSSortDescriptor(key: "graphID", ascending: true)
        if dataHandler.loadBulkSorted(entitie: "GraphSettings", sort: [graphSort]).count <= 0 {
            dataHandler.saveNewGraphs()
        }
        
        let queryGraphActive = NSPredicate(format: "graphActive == %@", NSNumber(value: true))
        
        graphName = dataHandler.loadQueriedAttribute(entitie: "GraphSettings", attibute: "graphName", query: queryGraphActive) as? String ?? "Line"
        graphIDActive = Int(dataHandler.loadQueriedAttribute(entitie: "GraphSettings", attibute: "graphID", query: queryGraphActive) as? Int16 ?? 0)
        graphOption1 = Int(dataHandler.loadQueriedAttribute(entitie: "GraphSettings", attibute: "graphOption1", query: queryGraphActive) as? Int16 ?? 0)
        graphOption2 = Int(dataHandler.loadQueriedAttribute(entitie: "GraphSettings", attibute: "graphOption2", query: queryGraphActive) as? Int16 ?? 0)
        
        if graphIDActive == 2 {
            graphOption2 = (graphOption2 ?? 0) + 1
        }

        if !UIDevice().model.contains("iPhone") {
            let showSecondGraphLocal = UserDefaults.standard.bool(forKey: "showSecondGraph")
            if showSecondGraphLocal {
                secondGraph = true
            } else {
                secondGraph = false
            }
            graphOption3 = Int(dataHandler.loadQueriedAttribute(entitie: "GraphSettings", attibute: "graphOption3", query: queryGraphActive) as? Int16 ?? 0)
        } else {
            secondGraph = false
            graphOption3 = nil
        }
        if secondGraph {
            secondOutlineView.isHidden = false
            secondOutlineView.isUserInteractionEnabled = true
        } else {
            secondOutlineView.isHidden = true
            secondOutlineView.isUserInteractionEnabled = false
        }
        
        if secondGraph {
            secondCarouselView.isHidden = false
        } else {
            secondCarouselView.isHidden = true
        }
    }
    
    @objc func setBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        let graphSettings = UIBarButtonItem(image: UIImage(named: "graphSettings"), style: .done, target: self, action: #selector(showGraphSettings))
        if filteredCategoriesZero || filteredTagsZero {
            let filter = UIBarButtonItem(image: UIImage(named: "filterSelected"), style: .plain, target: self, action: #selector(filterButtonTabbed))
            navigationItem.rightBarButtonItems = [graphSettings, filter]
        } else {
            let filter = UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(filterButtonTabbed))
            navigationItem.rightBarButtonItems = [graphSettings, filter]
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "graphSettings"), style: .done, target: self, action: #selector(showGraphSettings))
    }
    
    // MARK: -DATA FUNCTIONS
    func getLineChartData(getExpenses:Bool = false) -> ([ChartDataEntry],[Date],Bool,Double) {
        var entries = [ChartDataEntry]()
        var dates = [Date]()
        var lastNegative = false
        var differenceFirstLast = 0.00
        
        let fromDate = collectionCellData[carouselScrollingId]?[1] as? Date ?? Date()
        let toDate = collectionCellData[carouselScrollingId]?[2] as? Date ?? Date()
        
        if graphOption1 == 2 { // Expenses vs. Income
            if lineChartEntries.count <= 0 || lineChartEntriesExpenses.count <= 0 {
                loadLineChartData()
            }
            
            if getExpenses {
                let selected = lineChartEntriesExpenses.filter { $0.dateTime >= fromDate && $0.dateTime <= toDate }
                let firstEntryValue = selected[0].value
                if selected.count > 0 {
                    for i in 0...selected.count-1 {
                        entries.append(ChartDataEntry(x: Double(i), y: selected[i].value))
                        dates.append(selected[i].dateTime)
                        if i == (selected.count-1) && selected[i].value < firstEntryValue {
                            lastNegative = true
                        }
                    }
                }
            } else {
                let selected = lineChartEntries.filter { $0.dateTime >= fromDate && $0.dateTime <= toDate }
                let firstEntryValue = selected[0].value
                if selected.count > 0 {
                    for i in 0...selected.count-1 {
                        entries.append(ChartDataEntry(x: Double(i), y: selected[i].value))
                        dates.append(selected[i].dateTime)
                        if i == (selected.count-1) && selected[i].value > firstEntryValue {
                            lastNegative = true
                        }
                    }
                }
            }
        } else {
            if lineChartEntries.count <= 0 {
                loadLineChartData()
            }
            lineChartRealValues.removeAll()
            var selected = lineChartEntries.filter { $0.dateTime >= fromDate && $0.dateTime <= toDate }
            
            if selected.count == 1 {
                let value = selected[0].value
                let selecteRAM = selected[0]
                let indexRAM = selected[0].index
                selected.removeAll()
                selected.append(LineChartEntry(value: value, dateTime: fromDate, index: (indexRAM-1)))
                selected.append(selecteRAM)
            }
            
            if selected.count > 0 {
                var ma = 1
                if selected.count > 500 {
                    switch graphOption2 {
                    case 1: // Yearly
                        ma = 4
                        break
                    case 2: // All
                        ma = 12
                        break
                    default: // Monthly
                        ma = 1
                        break
                    }
                }
                
                var firstEntryValue = selected[0].value
                if lineChartEntries.indices.contains(selected[0].index-1) {
                    firstEntryValue = lineChartEntries[selected[0].index-1].value
                }
                for i in 0...selected.count-1 {
                    var movingAverage = selected[i].value
                    if ma != 1 {
                        var selectedArray = [Double]()
                        for j in 1...ma {
                            let m = i - j
                            if m > 0 {
                                selectedArray.append(selected[m].value)
                            }
                        }
                        selectedArray.append(selected[i].value)
                        for j in 1...ma {
                            let m = i + j
                            if m < selected.count-1 {
                                selectedArray.append(selected[m].value)
                            }
                        }
                        movingAverage = (selectedArray.reduce(0, +)) / Double(selectedArray.count)
                    }
                    
                    entries.append(ChartDataEntry(x: Double(i), y: movingAverage))
                    lineChartRealValues.append(selected[i].value)
                    dates.append(selected[i].dateTime)
                    if i == (selected.count-1) {
                        if (selected[i].value <= firstEntryValue) {
                            lastNegative = true
                        }
                        differenceFirstLast =  selected[i].value - firstEntryValue
                    }
                }
            }
        }
        return (entries,dates,lastNegative,differenceFirstLast)
    }
    
    func loadLineChartData() {
        lineChartMax = 0.00
        lineCharMin = 0.00
        
        switch graphOption1 {
        case 2: // Expenses vs. Income
            if fromDateMax == nil || toDateMax == nil  {
                setInitialToFromMaxDates()
            }
            
            let queryCountEntriesExpenses = NSPredicate(format: "isSave == %@ AND isIncome == %@", NSNumber(value: false), NSNumber(value: false))
            let countEntriesExpenses = (dataHandler.loadDataSUMEntries(entitie: "Categories", query: queryCountEntriesExpenses) as? [[String:Any]])?[0]["sum"] as? Double ?? 1.00
            var numberEntriesExpeses:Double = 1000.00
            if countEntriesExpenses > 1000 && countEntriesExpenses <= 3000 {
                numberEntriesExpeses = (0.9 * countEntriesExpenses)
            } else if countEntriesExpenses > 3000 && countEntriesExpenses <= 5000 {
                numberEntriesExpeses = (0.8 * countEntriesExpenses)
            } else if countEntriesExpenses > 5000 && countEntriesExpenses <= 10000 {
                numberEntriesExpeses = (0.7 * countEntriesExpenses)
            } else {
                numberEntriesExpeses = 7000.00
            }
            let nEntriesExpenses = Int(countEntriesExpenses/numberEntriesExpeses)
            
            let queryCountEntriesIncome = NSPredicate(format: "isSave == %@ AND isIncome == %@", NSNumber(value: false), NSNumber(value: true))
            let countEntriesIncome = (dataHandler.loadDataSUMEntries(entitie: "Categories", query: queryCountEntriesIncome) as? [[String:Any]])?[0]["sum"] as? Double ?? 1.00
            var numberEntriesIncome:Double = 1000.00
            if countEntriesIncome > 1000 && countEntriesIncome <= 3000 {
                numberEntriesIncome = (0.9 * countEntriesIncome)
            } else if countEntriesIncome > 3000 && countEntriesIncome <= 5000 {
                numberEntriesIncome = (0.8 * countEntriesIncome)
            } else if countEntriesIncome > 5000 && countEntriesIncome <= 10000 {
                numberEntriesIncome = (0.7 * countEntriesIncome)
            } else {
                numberEntriesIncome = 7000.00
            }
            let nEntriesIncome = Int(countEntriesIncome/numberEntriesIncome)
            
            let dateSort = NSSortDescriptor(key: "dateTime", ascending: true)
            let query = NSPredicate(format: "isSave == %@", NSNumber(value: false))
            
            var expenses:Double = 0.00
            var income:Double = 0.00
            var i = 0
            var j = 0
            var indexExpenses = 1
            var indexIncome = 1
            
            var preDateIncome:Date = (Calendar.current.date(byAdding: .minute, value: -1, to: (fromDateMax ?? Date()))!)
            var preDateExpense:Date = (Calendar.current.date(byAdding: .minute, value: -1, to: (fromDateMax ?? Date()))!)
            lineChartEntries.append(LineChartEntry(value: 0.00, dateTime: (fromDateMax ?? Date()).startOfMonth, index: 0)) // Income
            lineChartEntriesExpenses.append(LineChartEntry(value: 0.00, dateTime: (fromDateMax ?? Date()).startOfMonth, index: 0)) // Expenses
            
            for transaction in dataHandler.loadBulkQueriedSorted(entitie: "Transactions", query: query, sort: [dateSort]) {
                let query = NSPredicate(format: "cID == %i", (transaction.value(forKey: "categoryID") as? Int16 ?? 0))
                
                if !(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isSave", query: query) as? Bool ?? false) && (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: query) as? Bool ?? false) { // Income
                    if preDateIncome.compare(transaction.value(forKey: "dateTime") as? Date ?? Date()) == .orderedAscending {
                        repeat {
                            lineChartEntries.append(LineChartEntry(value: income, dateTime: preDateIncome.endOfMonth, index: indexIncome))
                            indexIncome = indexIncome + 1
                            preDateIncome = (Calendar.current.date(byAdding: .day, value: 1, to: preDateIncome)!).startOfMonth
                            lineChartEntries.append(LineChartEntry(value: income, dateTime: preDateIncome, index: indexIncome))
                            indexIncome = indexIncome + 1
                        } while preDateIncome.compare(transaction.value(forKey: "dateTime") as? Date ?? Date()) == .orderedAscending
                    }
                    income = income + (transaction.value(forKey: "realAmount") as? Double ?? 0.00)
                    if i == 0 {
                        lineChartEntries.append(LineChartEntry(value: income, dateTime: (transaction.value(forKey: "dateTime") as? Date ?? Date()), index: indexIncome))
                        indexIncome = indexIncome + 1
                    }
                    
                    i = i + 1
                    if i > nEntriesIncome {
                        i = 0
                    }
                    
                } else if !(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isSave", query: query) as? Bool ?? false) && !(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: query) as? Bool ?? false) { // expense
                    if preDateExpense.compare(transaction.value(forKey: "dateTime") as? Date ?? Date()) == .orderedAscending {
                        repeat {
                            lineChartEntries.append(LineChartEntry(value: expenses, dateTime: preDateExpense.endOfMonth, index: indexExpenses))
                            indexExpenses = indexExpenses + 1
                            preDateExpense = (Calendar.current.date(byAdding: .day, value: 1, to: preDateExpense)!).startOfMonth
                            lineChartEntries.append(LineChartEntry(value: expenses, dateTime: preDateExpense, index: indexExpenses))
                            indexExpenses = indexExpenses + 1
                        } while preDateExpense.compare(transaction.value(forKey: "dateTime") as? Date ?? Date()) == .orderedAscending
                    }
                    expenses = expenses + (transaction.value(forKey: "realAmount") as? Double ?? 0.00)
                    if j == 0 {
                        lineChartEntriesExpenses.append(LineChartEntry(value: expenses, dateTime: (transaction.value(forKey: "dateTime") as? Date ?? Date()), index: indexExpenses))
                        indexExpenses = indexExpenses + 1
                    }
                    
                    j = j + 1
                    if j > nEntriesExpenses {
                        j = 0
                    }
                }
            }
            break
        case 1: // Savings
            if fromDateMax == nil || toDateMax == nil  {
                setInitialToFromMaxDates()
            }
            
//            let queryCountEntries = NSPredicate(format: "isSave == %@", NSNumber(value: true))
//            let countEntries = (loadDataSUMEntries(entitie: "Categories", query: queryCountEntries) as? [[String:Any]])?[0]["sum"] as? Double ?? 1.00
//            var numberEntries:Double = 1000.00
//            if countEntries > 1000 && countEntries <= 3000 {
//                numberEntries = (0.9 * countEntries)
//            } else if countEntries > 3000 && countEntries <= 5000 {
//                numberEntries = (0.8 * countEntries)
//            } else if countEntries > 5000 && countEntries <= 10000 {
//                numberEntries = (0.7 * countEntries)
//            } else {
//                numberEntries = 7000.00
//            }
            
//            let nEntries = max(Int(countEntries/numberEntries),1000)
            
            let dateSort = NSSortDescriptor(key: "dateTime", ascending: true)

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
            
            var savings:Double = 0.00
            
            let query = NSPredicate(format: "categoryID != %i AND dateTime != nil" + tagFilterPredicateString, -1)
            let queryInitial = NSPredicate(format: "categoryID != %i AND dateTime == nil AND isSave == true" + tagFilterPredicateString, -1)
            
            for initialTransaction in dataHandler.loadBulkQueried(entitie: "Transactions", query: queryInitial) {
                savings = savings + (initialTransaction.value(forKey: "realAmount") as? Double ?? 0.00)
            }
//            var i = 0
            var index = 1
            
            var preDate:Date = (Calendar.current.date(byAdding: .minute, value: -1, to: (fromDateMax ?? Date()))!)
            lineChartEntries.append(LineChartEntry(value: savings, dateTime: (fromDateMax ?? Date()).startOfMonth, index: 0))
            
            for transaction in dataHandler.loadBulkQueriedSorted(entitie: "Transactions", query: query, sort: [dateSort]) {
                if preDate.compare(transaction.value(forKey: "dateTime") as? Date ?? Date()) == .orderedAscending {
                    repeat {
                        if preDate.endOfMonth < (transaction.value(forKey: "dateTime") as? Date ?? Date()) {
                            lineChartEntries.append(LineChartEntry(value: savings, dateTime: preDate.endOfMonth, index: index))
                            index = index + 1
                        }
                        preDate = (Calendar.current.date(byAdding: .month, value: 1, to: preDate)!).startOfMonth
                    } while preDate.compare(transaction.value(forKey: "dateTime") as? Date ?? Date()) == .orderedAscending
                }
                
                let query = NSPredicate(format: "cID == %i", (transaction.value(forKey: "categoryID") as? Int16 ?? 0))
                if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isSave", query: query) as? Bool ?? false) {
                    savings = savings + (transaction.value(forKey: "realAmount") as? Double ?? 0.00)
                    lineChartEntries.append(LineChartEntry(value: savings, dateTime: (transaction.value(forKey: "dateTime") as? Date ?? Date()), index: index))
                    index = index + 1
                }
            }
            lineChartEntries.append(LineChartEntry(value: savings, dateTime: toDateMax ?? Date(), index: index))
            break
        default: // Balance
            if fromDateMax == nil || toDateMax == nil  {
                setInitialToFromMaxDates()
            }
            
            let dateSort = NSSortDescriptor(key: "dateTime", ascending: true)
            
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
            let query = NSPredicate(format: "categoryID != %i AND dateTime != nil" + tagFilterPredicateString, -1)
            
            var balance:Double = 0.00
            var index = 1
            let queryInitial = NSPredicate(format: "categoryID != %i AND dateTime == nil AND isSave == false" + tagFilterPredicateString, -1)
            for transaction in dataHandler.loadBulkQueried(entitie: "Transactions", query: queryInitial) {
                let queryCategory = NSPredicate(format: "cID == %i", (transaction.value(forKey: "categoryID") as? Int16 ?? -1))
                let isIncome = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false
                if isIncome {
                    balance = balance + (transaction.value(forKey: "realAmount") as? Double ?? 0.00)
                } else {
                    balance = balance - (transaction.value(forKey: "realAmount") as? Double ?? 0.00)
                }
            }
            var preDate:Date = (Calendar.current.date(byAdding: .minute, value: -1, to: (fromDateMax ?? Date()))!)
            lineChartEntries.append(LineChartEntry(value: balance, dateTime: (fromDateMax ?? Date()).startOfMonth, index: 0))
            
            for transaction in dataHandler.loadBulkQueriedSorted(entitie: "Transactions", query: query, sort: [dateSort]) {
                if preDate.compare(transaction.value(forKey: "dateTime") as? Date ?? Date()) == .orderedAscending {
                    repeat {
                        if preDate.endOfMonth < (transaction.value(forKey: "dateTime") as? Date ?? Date()) {
                            lineChartEntries.append(LineChartEntry(value: balance, dateTime: preDate.endOfMonth, index: index))
                            index = index + 1
                        }
                        preDate = (Calendar.current.date(byAdding: .month, value: 1, to: preDate)!).startOfMonth
                    } while preDate.compare(transaction.value(forKey: "dateTime") as? Date ?? Date()) == .orderedAscending
                }
                
                let query = NSPredicate(format: "cID == %i", (transaction.value(forKey: "categoryID") as? Int16 ?? 0))
                if !(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isSave", query: query) as? Bool ?? false) {
                    if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: query) as? Bool ?? false) {
                        balance = balance + (transaction.value(forKey: "realAmount") as? Double ?? 0.00)
                    } else {
                        balance = balance - (transaction.value(forKey: "realAmount") as? Double ?? 0.00)
                    }

                    lineChartEntries.append(LineChartEntry(value: balance, dateTime: (transaction.value(forKey: "dateTime") as? Date ?? Date()), index: index))
                    index = index + 1
                }
            }
            lineChartEntries.append(LineChartEntry(value: balance, dateTime: toDateMax ?? Date(), index: index))
            break
        }
        if lineChartEntries.count > 0 {
            lineChartEntries.sort { $0.dateTime < $1.dateTime }
        }
        if lineChartEntriesExpenses.count > 0 {
            lineChartEntriesExpenses.sort { $0.dateTime < $1.dateTime }
        }
    }
    
    func getSecondLineChartData(getExpenses:Bool = false) -> ([ChartDataEntry],[Date],Bool,Double) {
        var entries = [ChartDataEntry]()
        var dates = [Date]()
        var lastNegative = false
        var differenceFirstLast = 0.00
        
        let fromDate = collectionCellData[secondCarouselScrollingId]?[1] as? Date ?? Date()
        let toDate = collectionCellData[secondCarouselScrollingId]?[2] as? Date ?? Date()
        
        if graphOption3 == 2 { // Expenses vs. Income
            if lineChartEntries.count <= 0 || lineChartEntriesExpenses.count <= 0 {
                loadLineChartData()
            }
            
            if getExpenses {
                let selected = lineChartEntriesExpenses.filter { $0.dateTime >= fromDate && $0.dateTime <= toDate }
                let firstEntryValue = selected[0].value
                if selected.count > 0 {
                    for i in 0...selected.count-1 {
                        entries.append(ChartDataEntry(x: Double(i), y: selected[i].value))
                        dates.append(selected[i].dateTime)
                        if i == (selected.count-1) && selected[i].value < firstEntryValue {
                            lastNegative = true
                        }
                    }
                }
            } else {
                let selected = lineChartEntries.filter { $0.dateTime >= fromDate && $0.dateTime <= toDate }
                let firstEntryValue = selected[0].value
                if selected.count > 0 {
                    for i in 0...selected.count-1 {
                        entries.append(ChartDataEntry(x: Double(i), y: selected[i].value))
                        dates.append(selected[i].dateTime)
                        if i == (selected.count-1) && selected[i].value > firstEntryValue {
                            lastNegative = true
                        }
                    }
                }
            }
        } else {
            if secondLineChartEntries.count <= 0 {
                loadSecondLineChartData()
            }
            secondLineChartRealValues.removeAll()
            var selected = secondLineChartEntries.filter { $0.dateTime >= fromDate && $0.dateTime <= toDate }
            
            if selected.count == 1 {
                let value = selected[0].value
                let selecteRAM = selected[0]
                let indexRAM = selected[0].index
                selected.removeAll()
                selected.append(LineChartEntry(value: value, dateTime: fromDate, index: (indexRAM-1)))
                selected.append(selecteRAM)
            }
            
            if selected.count > 0 {
                var ma = 1
                if selected.count > 500 {
                    switch graphOption2 {
                    case 1: // Yearly
                        ma = 4
                        break
                    case 2: // All
                        ma = 12
                        break
                    default: // Monthly
                        ma = 1
                        break
                    }
                }
                
                var firstEntryValue = selected[0].value
                if secondLineChartEntries.indices.contains(selected[0].index-1) {
                    firstEntryValue = secondLineChartEntries[selected[0].index-1].value
                }
                for i in 0...selected.count-1 {
                    var movingAverage = selected[i].value
                    if ma != 1 {
                        var selectedArray = [Double]()
                        for j in 1...ma {
                            let m = i - j
                            if m > 0 {
                                selectedArray.append(selected[m].value)
                            }
                        }
                        selectedArray.append(selected[i].value)
                        for j in 1...ma {
                            let m = i + j
                            if m < selected.count-1 {
                                selectedArray.append(selected[m].value)
                            }
                        }
                        movingAverage = (selectedArray.reduce(0, +)) / Double(selectedArray.count)
                    }
                    
                    entries.append(ChartDataEntry(x: Double(i), y: movingAverage))
                    secondLineChartRealValues.append(selected[i].value)
                    dates.append(selected[i].dateTime)
                    if i == (selected.count-1) {
                        if (selected[i].value <= firstEntryValue) {
                            lastNegative = true
                        }
                        differenceFirstLast =  selected[i].value - firstEntryValue
                    }
                }
            }
        }
        return (entries,dates,lastNegative,differenceFirstLast)
    }
    
    func loadSecondLineChartData() {
        lineChartMax = 0.00
        lineCharMin = 0.00
        
        switch graphOption3 {
        case 2: // Expenses vs. Income
            
            break
        case 1: // Savings
            if fromDateMax == nil || toDateMax == nil  {
                setInitialToFromMaxDates()
            }
            
//            let queryCountEntries = NSPredicate(format: "isSave == %@", NSNumber(value: true))
//            let countEntries = (loadDataSUMEntries(entitie: "Categories", query: queryCountEntries) as? [[String:Any]])?[0]["sum"] as? Double ?? 1.00
//            var numberEntries:Double = 1000.00
//            if countEntries > 1000 && countEntries <= 3000 {
//                numberEntries = (0.9 * countEntries)
//            } else if countEntries > 3000 && countEntries <= 5000 {
//                numberEntries = (0.8 * countEntries)
//            } else if countEntries > 5000 && countEntries <= 10000 {
//                numberEntries = (0.7 * countEntries)
//            } else {
//                numberEntries = 7000.00
//            }
            
//            let nEntries = max(Int(countEntries/numberEntries),1000)
            
            let dateSort = NSSortDescriptor(key: "dateTime", ascending: true)

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
            
            var savings:Double = 0.00
            
            let query = NSPredicate(format: "categoryID != %i AND dateTime != nil" + tagFilterPredicateString, -1)
            let queryInitial = NSPredicate(format: "categoryID != %i AND dateTime == nil AND isSave == true" + tagFilterPredicateString, -1)
            
            for initialTransaction in dataHandler.loadBulkQueried(entitie: "Transactions", query: queryInitial) {
                savings = savings + (initialTransaction.value(forKey: "realAmount") as? Double ?? 0.00)
            }
//            var i = 0
            var index = 1
            
            var preDate:Date = (Calendar.current.date(byAdding: .minute, value: -1, to: (fromDateMax ?? Date()))!)
            secondLineChartEntries.append(LineChartEntry(value: savings, dateTime: (fromDateMax ?? Date()).startOfMonth, index: 0))
            
            for transaction in dataHandler.loadBulkQueriedSorted(entitie: "Transactions", query: query, sort: [dateSort]) {
                if preDate.compare(transaction.value(forKey: "dateTime") as? Date ?? Date()) == .orderedAscending {
                    repeat {
                        if preDate.endOfMonth < (transaction.value(forKey: "dateTime") as? Date ?? Date()) {
                            secondLineChartEntries.append(LineChartEntry(value: savings, dateTime: preDate.endOfMonth, index: index))
                            index = index + 1
                        }
                        preDate = (Calendar.current.date(byAdding: .month, value: 1, to: preDate)!).startOfMonth
                    } while preDate.compare(transaction.value(forKey: "dateTime") as? Date ?? Date()) == .orderedAscending
                }
                
                let query = NSPredicate(format: "cID == %i", (transaction.value(forKey: "categoryID") as? Int16 ?? 0))
                if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isSave", query: query) as? Bool ?? false) {
                    savings = savings + (transaction.value(forKey: "realAmount") as? Double ?? 0.00)
                    secondLineChartEntries.append(LineChartEntry(value: savings, dateTime: (transaction.value(forKey: "dateTime") as? Date ?? Date()), index: index))
                    index = index + 1
                }
            }
            secondLineChartEntries.append(LineChartEntry(value: savings, dateTime: toDateMax ?? Date(), index: index))
            break
        default: // Balance
            if fromDateMax == nil || toDateMax == nil  {
                setInitialToFromMaxDates()
            }
            
            let dateSort = NSSortDescriptor(key: "dateTime", ascending: true)
            
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
            let query = NSPredicate(format: "categoryID != %i AND dateTime != nil" + tagFilterPredicateString, -1)
            
            var balance:Double = 0.00
            var index = 1
            let queryInitial = NSPredicate(format: "categoryID != %i AND dateTime == nil AND isSave == false" + tagFilterPredicateString, -1)
            for transaction in dataHandler.loadBulkQueried(entitie: "Transactions", query: queryInitial) {
                let queryCategory = NSPredicate(format: "cID == %i", (transaction.value(forKey: "categoryID") as? Int16 ?? -1))
                let isIncome = dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false
                if isIncome {
                    balance = balance + (transaction.value(forKey: "realAmount") as? Double ?? 0.00)
                } else {
                    balance = balance - (transaction.value(forKey: "realAmount") as? Double ?? 0.00)
                }
            }
            var preDate:Date = (Calendar.current.date(byAdding: .minute, value: -1, to: (fromDateMax ?? Date()))!)
            secondLineChartEntries.append(LineChartEntry(value: balance, dateTime: (fromDateMax ?? Date()).startOfMonth, index: 0))
            
            for transaction in dataHandler.loadBulkQueriedSorted(entitie: "Transactions", query: query, sort: [dateSort]) {
                if preDate.compare(transaction.value(forKey: "dateTime") as? Date ?? Date()) == .orderedAscending {
                    repeat {
                        if preDate.endOfMonth < (transaction.value(forKey: "dateTime") as? Date ?? Date()) {
                            secondLineChartEntries.append(LineChartEntry(value: balance, dateTime: preDate.endOfMonth, index: index))
                            index = index + 1
                        }
                        preDate = (Calendar.current.date(byAdding: .month, value: 1, to: preDate)!).startOfMonth
                    } while preDate.compare(transaction.value(forKey: "dateTime") as? Date ?? Date()) == .orderedAscending
                }
                
                let query = NSPredicate(format: "cID == %i", (transaction.value(forKey: "categoryID") as? Int16 ?? 0))
                if !(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isSave", query: query) as? Bool ?? false) {
                    if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: query) as? Bool ?? false) {
                        balance = balance + (transaction.value(forKey: "realAmount") as? Double ?? 0.00)
                    } else {
                        balance = balance - (transaction.value(forKey: "realAmount") as? Double ?? 0.00)
                    }

                    secondLineChartEntries.append(LineChartEntry(value: balance, dateTime: (transaction.value(forKey: "dateTime") as? Date ?? Date()), index: index))
                    index = index + 1
                }
            }
            secondLineChartEntries.append(LineChartEntry(value: balance, dateTime: toDateMax ?? Date(), index: index))
            break
        }
        if secondLineChartEntries.count > 0 {
            secondLineChartEntries.sort { $0.dateTime < $1.dateTime }
        }
    }
    
    func getPieChartData()-> ([PieChartDataEntry],[UIColor], Double, [String]) {
        var entries = [PieChartDataEntry]()
        var colors = [UIColor]()
        var sum:Double = 0.00
        var labels = [String]()
        
        let fromDate = collectionCellData[carouselScrollingId]?[1] as? Date ?? Date()
        let toDate = collectionCellData[carouselScrollingId]?[2] as? Date ?? Date()
        
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

        let queryPieChart = NSPredicate(format: ("dateTime >= %@ AND dateTime <= %@" + tagFilterPredicateString), fromDate as NSDate, toDate as NSDate)
        
        let data = dataHandler.loadDataGroupedSUM(entitie: "Transactions", groupByColumn: "categoryID", query: queryPieChart) as? [[String:Any]]
        if (data?.count ?? 0) > 0 {
            if graphOption1 == 2 {
                for i in 0...((data?.count ?? 1)-1) {
                    let queryCategory = NSPredicate(format: "cID == %i AND isSave == %@", (data?[i]["categoryID"] as? Int16 ?? 0), NSNumber(value: true))
                    if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "selectedForFilter", query: queryCategory) as? Bool ?? false) {
                        entries.append(PieChartDataEntry(value: (round(100*(data?[i]["sum"] as? Double ?? 0.00))/100), label: (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? "")))
                        colors.append(UIColor.randomColor(color: Int((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0))))
                        sum = sum + (round(100*(data?[i]["sum"] as? Double ?? 0.00))/100)
                        labels.append((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? ""))
                    }
                }
            } else {
                for i in 0...((data?.count ?? 1)-1) {
                    let queryCategory = NSPredicate(format: "cID == %i AND isSave == %@", (data?[i]["categoryID"] as? Int16 ?? 0), NSNumber(value: false))
                    if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "selectedForFilter", query: queryCategory) as? Bool ?? false) {
                        if (graphOption1 == 1) && (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false) {
                            entries.append(PieChartDataEntry(value: (round(100*(data?[i]["sum"] as? Double ?? 0.00))/100), label: (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? "")))
                            colors.append(UIColor.randomColor(color: Int((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0))))
                            sum = sum + (round(100*(data?[i]["sum"] as? Double ?? 0.00))/100)
                            labels.append((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? ""))
                        } else if (graphOption1 == 0) && !(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false) {
                            entries.append(PieChartDataEntry(value: (round(100*(data?[i]["sum"] as? Double ?? 0.00))/100), label: (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? "")))
                            colors.append(UIColor.randomColor(color: Int((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0))))
                            sum = sum + (round(100*(data?[i]["sum"] as? Double ?? 0.00))/100)
                            labels.append((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? ""))
                        }
                    }
                }
            }
        }
        return (entries, colors, sum, labels)
    }
    
    func getSecondPieChartData()-> ([PieChartDataEntry],[UIColor], Double, [String]) {
        var entries = [PieChartDataEntry]()
        var colors = [UIColor]()
        var sum:Double = 0.00
        var labels = [String]()
        
        let fromDate = collectionCellData[secondCarouselScrollingId]?[1] as? Date ?? Date()
        let toDate = collectionCellData[secondCarouselScrollingId]?[2] as? Date ?? Date()
        
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

        let queryPieChart = NSPredicate(format: ("dateTime >= %@ AND dateTime <= %@" + tagFilterPredicateString), fromDate as NSDate, toDate as NSDate)
        
        let data = dataHandler.loadDataGroupedSUM(entitie: "Transactions", groupByColumn: "categoryID", query: queryPieChart) as? [[String:Any]]
        if (data?.count ?? 0) > 0 {
            if graphOption3 == 2 {
                for i in 0...((data?.count ?? 1)-1) {
                    let queryCategory = NSPredicate(format: "cID == %i AND isSave == %@", (data?[i]["categoryID"] as? Int16 ?? 0), NSNumber(value: true))
                    if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "selectedForFilter", query: queryCategory) as? Bool ?? false) {
                        entries.append(PieChartDataEntry(value: (round(100*(data?[i]["sum"] as? Double ?? 0.00))/100), label: (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? "")))
                        colors.append(UIColor.randomColor(color: Int((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0))))
                        sum = sum + (round(100*(data?[i]["sum"] as? Double ?? 0.00))/100)
                        labels.append((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? ""))
                    }
                }
            } else {
                for i in 0...((data?.count ?? 1)-1) {
                    let queryCategory = NSPredicate(format: "cID == %i AND isSave == %@", (data?[i]["categoryID"] as? Int16 ?? 0), NSNumber(value: false))
                    if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "selectedForFilter", query: queryCategory) as? Bool ?? false) {
                        if (graphOption3 == 1) && (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false) {
                            entries.append(PieChartDataEntry(value: (round(100*(data?[i]["sum"] as? Double ?? 0.00))/100), label: (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? "")))
                            colors.append(UIColor.randomColor(color: Int((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0))))
                            sum = sum + (round(100*(data?[i]["sum"] as? Double ?? 0.00))/100)
                            labels.append((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? ""))
                        } else if (graphOption3 == 0) && !(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false) {
                            entries.append(PieChartDataEntry(value: (round(100*(data?[i]["sum"] as? Double ?? 0.00))/100), label: (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? "")))
                            colors.append(UIColor.randomColor(color: Int((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "color", query: queryCategory) as? Int16 ?? 0))))
                            sum = sum + (round(100*(data?[i]["sum"] as? Double ?? 0.00))/100)
                            labels.append((dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "name", query: queryCategory) as? String ?? ""))
                        }
                    }
                }
            }
        }
        return (entries, colors, sum, labels)
    }
    
    func getBarChartData() -> ([BarChartDataEntry],[UIColor],[String]) {
        var entries = [BarChartDataEntry]()
        var colors = [UIColor]()
        var labels = [String]()
        
        barChartDifference = 0.00
        
        // let fromDate = collectionCellData[carouselScrollingId]?[1] as? Date ?? Date()
        let toDate = collectionCellData[carouselScrollingId]?[2] as? Date ?? Date()
        
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
        
        switch graphOption2 {
        case 1: // Monthly
            var fromDateLOOP = (collectionCellData[carouselScrollingId]?[1] as? Date ?? Date()).startOfYear
            var toDateLOOP = fromDateLOOP.endOfMonth
            var j = 0
            
            repeat {
                j = j + 1
                
                var balanceLOOP = 0.00
                
                let queryBarChart = NSPredicate(format: "dateTime > %@ AND dateTime <= %@" + tagFilterPredicateString, fromDateLOOP as NSDate, toDateLOOP as NSDate)
                let data = dataHandler.loadDataGroupedSUM(entitie: "Transactions", groupByColumn: "categoryID", query: queryBarChart)  as? [[String:Any]]
                
                if (data?.count ?? 0) > 0 {
                    for i in 0...((data?.count ?? 1)-1) {
                        var querySave = false
                        if (graphOption1 == 1) {
                            querySave = true
                        }
                        let queryCategory = NSPredicate(format: "cID == %i AND isSave == %@", (data?[i]["categoryID"] as? Int16 ?? 0), NSNumber(value: querySave))
                        if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "selectedForFilter", query: queryCategory) as? Bool ?? false) {
                            if (graphOption1 == 0) { // Balance
                                if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false)  { // Income
                                    balanceLOOP = balanceLOOP + (data?[i]["sum"] as? Double ?? 0.00)
                                } else if !(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false) { // Expense
                                    balanceLOOP = balanceLOOP - (data?[i]["sum"] as? Double ?? 0.00)
                                }
                            } else if (graphOption1 == 1) { // Savings
                                balanceLOOP = balanceLOOP + (data?[i]["sum"] as? Double ?? 0.00)
                            }
                        }
                    }
                    
                    entries.append((BarChartDataEntry(x: Double(Calendar.current.component(.month, from: fromDateLOOP)), y: (round(100.00 * balanceLOOP) / 100.00))))
                    if balanceLOOP < 0.00 {
                        colors.append(NSUIColor.init(cgColor: CGColor(srgbRed: 204/255, green: 0/255, blue: 0/255, alpha: 1.0)))
                    } else {
                        colors.append(NSUIColor.init(cgColor: CGColor(srgbRed: 0/255, green: 153/255, blue: 51/255, alpha: 1.0)))
                    }
                    labels.append(monthNameFormat.string(from: fromDateLOOP))
//                } else {
//                    entries.append((BarChartDataEntry(x: Double(j), y: 0.00)))
//                    colors.append(UIColor.green)
//                    labels.append(monthNameFormat.string(from: fromDateLOOP))
                }
                
                barChartDifference = barChartDifference + balanceLOOP
                
                fromDateLOOP = (Calendar.current.date(byAdding: .month, value: 1, to: fromDateLOOP) ?? Date()).startOfMonth
                toDateLOOP = (Calendar.current.date(byAdding: .month, value: 1, to: toDateLOOP) ?? Date()).endOfMonth
            } while(fromDateLOOP < toDate)
            break
        case 2: // Yearly
            var fromDateLOOP = (collectionCellData[carouselScrollingId]?[1] as? Date ?? Date()).startOfYear
            var toDateLOOP = fromDateLOOP.endOfYear
            var j = 1000
            
            repeat {
                j = j + 10
                
                var balanceLOOP = 0.00
                
                let queryBarChart = NSPredicate(format: "dateTime > %@ AND dateTime <= %@" + tagFilterPredicateString, fromDateLOOP as NSDate, toDateLOOP as NSDate)
                let data = dataHandler.loadDataGroupedSUM(entitie: "Transactions", groupByColumn: "categoryID", query: queryBarChart)  as? [[String:Any]]
                
                if (data?.count ?? 0) > 0 {
                    for i in 0...((data?.count ?? 1)-1) {
                        var querySave = false
                        if (graphOption1 == 1) {
                            querySave = true
                        }
                        let queryCategory = NSPredicate(format: "cID == %i AND isSave == %@", (data?[i]["categoryID"] as? Int16 ?? 0), NSNumber(value: querySave))
                        if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "selectedForFilter", query: queryCategory) as? Bool ?? false) {
                            if (graphOption1 == 0) { // Balance
                                if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false)  { // Income
                                    balanceLOOP = balanceLOOP + (data?[i]["sum"] as? Double ?? 0.00)
                                } else if !(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false) { // Expense
                                    balanceLOOP = balanceLOOP - (data?[i]["sum"] as? Double ?? 0.00)
                                }
                            } else if (graphOption1 == 1) { // Savings
                                balanceLOOP = balanceLOOP + (data?[i]["sum"] as? Double ?? 0.00)
                            }
                        }
                    }
                    entries.append((BarChartDataEntry(x: Double(Calendar.current.component(.year, from: fromDateLOOP)), y: (round(100.00 * balanceLOOP) / 100.00))))
                    if balanceLOOP < 0.00 {
                        colors.append(NSUIColor.init(cgColor: CGColor(srgbRed: 204/255, green: 0/255, blue: 0/255, alpha: 1.0)))
                    } else {
                        colors.append(NSUIColor.init(cgColor: CGColor(srgbRed: 0/255, green: 153/255, blue: 51/255, alpha: 1.0)))
                    }
                    labels.append(yearNameFormat.string(from: fromDateLOOP))
//                } else {
//
//                    entries.append((BarChartDataEntry(x: Double(Calendar.current.component(.year, from: fromDateLOOP)), y: 0.00)))
//                    colors.append(UIColor.green)
//                    labels.append(yearNameFormat.string(from: fromDateLOOP))
                }
                
                barChartDifference = barChartDifference + balanceLOOP
                
                fromDateLOOP = (Calendar.current.date(byAdding: .year, value: 1, to: fromDateLOOP) ?? Date())
                toDateLOOP = (Calendar.current.date(byAdding: .year, value: 1, to: toDateLOOP) ?? Date())
            } while(fromDateLOOP <= toDate)
            break
        default:
            break
        }
        
        return (entries, colors, labels)
    }
    
    func getSecondBarChartData() -> ([BarChartDataEntry],[UIColor],[String]) {
        var entries = [BarChartDataEntry]()
        var colors = [UIColor]()
        var labels = [String]()
        
        secondBarChartDifference = 0.00
        
        // let fromDate = collectionCellData[carouselScrollingId]?[1] as? Date ?? Date()
        let toDate = collectionCellData[secondCarouselScrollingId]?[2] as? Date ?? Date()
        
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
        
        switch graphOption2 {
        case 1: // Monthly
            var fromDateLOOP = (collectionCellData[secondCarouselScrollingId]?[1] as? Date ?? Date()).startOfYear
            var toDateLOOP = fromDateLOOP.endOfMonth
            var j = 0
            
            repeat {
                j = j + 1
                
                var balanceLOOP = 0.00
                
                let queryBarChart = NSPredicate(format: "dateTime > %@ AND dateTime <= %@" + tagFilterPredicateString, fromDateLOOP as NSDate, toDateLOOP as NSDate)
                let data = dataHandler.loadDataGroupedSUM(entitie: "Transactions", groupByColumn: "categoryID", query: queryBarChart)  as? [[String:Any]]
                
                if (data?.count ?? 0) > 0 {
                    for i in 0...((data?.count ?? 1)-1) {
                        var querySave = false
                        if (graphOption3 == 1) {
                            querySave = true
                        }
                        let queryCategory = NSPredicate(format: "cID == %i AND isSave == %@", (data?[i]["categoryID"] as? Int16 ?? 0), NSNumber(value: querySave))
                        if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "selectedForFilter", query: queryCategory) as? Bool ?? false) {
                            if (graphOption3 == 0) { // Balance
                                if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false)  { // Income
                                    balanceLOOP = balanceLOOP + (data?[i]["sum"] as? Double ?? 0.00)
                                } else if !(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false) { // Expense
                                    balanceLOOP = balanceLOOP - (data?[i]["sum"] as? Double ?? 0.00)
                                }
                            } else if (graphOption3 == 1) { // Savings
                                balanceLOOP = balanceLOOP + (data?[i]["sum"] as? Double ?? 0.00)
                            }
                        }
                    }
                    
                    entries.append((BarChartDataEntry(x: Double(Calendar.current.component(.month, from: fromDateLOOP)), y: (round(100.00 * balanceLOOP) / 100.00))))
                    if balanceLOOP < 0.00 {
                        colors.append(NSUIColor.init(cgColor: CGColor(srgbRed: 204/255, green: 0/255, blue: 0/255, alpha: 1.0)))
                    } else {
                        colors.append(NSUIColor.init(cgColor: CGColor(srgbRed: 0/255, green: 153/255, blue: 51/255, alpha: 1.0)))
                    }
                    labels.append(monthNameFormat.string(from: fromDateLOOP))
//                } else {
//
//                    entries.append((BarChartDataEntry(x: Double(j), y: 0.00)))
//                    colors.append(UIColor.green)
//                    labels.append(monthNameFormat.string(from: fromDateLOOP))
                }
                
                secondBarChartDifference = secondBarChartDifference + balanceLOOP
                
                fromDateLOOP = (Calendar.current.date(byAdding: .month, value: 1, to: fromDateLOOP) ?? Date()).startOfMonth
                toDateLOOP = (Calendar.current.date(byAdding: .month, value: 1, to: toDateLOOP) ?? Date()).endOfMonth
            } while(fromDateLOOP < toDate)
            break
        case 2: // Yearly
            var fromDateLOOP = (collectionCellData[secondCarouselScrollingId]?[1] as? Date ?? Date()).startOfYear
            var toDateLOOP = fromDateLOOP.endOfYear
            var j = 1000
            
            repeat {
                j = j + 10
                
                var balanceLOOP = 0.00
                
                let queryBarChart = NSPredicate(format: "dateTime > %@ AND dateTime <= %@" + tagFilterPredicateString, fromDateLOOP as NSDate, toDateLOOP as NSDate)
                let data = dataHandler.loadDataGroupedSUM(entitie: "Transactions", groupByColumn: "categoryID", query: queryBarChart)  as? [[String:Any]]
                
                if (data?.count ?? 0) > 0 {
                    for i in 0...((data?.count ?? 1)-1) {
                        var querySave = false
                        if (graphOption3 == 1) {
                            querySave = true
                        }
                        let queryCategory = NSPredicate(format: "cID == %i AND isSave == %@", (data?[i]["categoryID"] as? Int16 ?? 0), NSNumber(value: querySave))
                        if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "selectedForFilter", query: queryCategory) as? Bool ?? false) {
                            if (graphOption3 == 0) { // Balance
                                if (dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false)  { // Income
                                    balanceLOOP = balanceLOOP + (data?[i]["sum"] as? Double ?? 0.00)
                                } else if !(dataHandler.loadQueriedAttribute(entitie: "Categories", attibute: "isIncome", query: queryCategory) as? Bool ?? false) { // Expense
                                    balanceLOOP = balanceLOOP - (data?[i]["sum"] as? Double ?? 0.00)
                                }
                            } else if (graphOption1 == 1) { // Savings
                                balanceLOOP = balanceLOOP + (data?[i]["sum"] as? Double ?? 0.00)
                            }
                        }
                    }
                    entries.append((BarChartDataEntry(x: Double(Calendar.current.component(.year, from: fromDateLOOP)), y: (round(100.00 * balanceLOOP) / 100.00))))
                    if balanceLOOP < 0.00 {
                        colors.append(NSUIColor.init(cgColor: CGColor(srgbRed: 204/255, green: 0/255, blue: 0/255, alpha: 1.0)))
                    } else {
                        colors.append(NSUIColor.init(cgColor: CGColor(srgbRed: 0/255, green: 153/255, blue: 51/255, alpha: 1.0)))
                    }
                    labels.append(yearNameFormat.string(from: fromDateLOOP))
//                } else {
//
//                    entries.append((BarChartDataEntry(x: Double(Calendar.current.component(.year, from: fromDateLOOP)), y: 0.00)))
//                    colors.append(UIColor.green)
//                    labels.append(yearNameFormat.string(from: fromDateLOOP))
                }
                
                secondBarChartDifference = secondBarChartDifference + balanceLOOP
                
                fromDateLOOP = (Calendar.current.date(byAdding: .year, value: 1, to: fromDateLOOP) ?? Date())
                toDateLOOP = (Calendar.current.date(byAdding: .year, value: 1, to: toDateLOOP) ?? Date())
            } while(fromDateLOOP <= toDate)
            break
        default:
            break
        }
        
        return (entries, colors, labels)
    }
    
    func setCollectionCellData(scrollToId: Int = -1,completion: (Bool) -> ()) {
        var numberTimeIntervalls:Int = 0
        
        collectionCellData.removeAll()
        carouselScrollingTodayId = -1
        
        switch graphOption2 {
        case 0: // Monthly
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
        case 1: // Yearly
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
        print("aaaaaaaa")
        print(carouselScrollingTodayId)
        if carouselScrollingTodayId == -1 {
            if collectionCellData.count != 0 {
                carouselScrollingTodayId = max((collectionCellData.count-1),0)
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
            if (carouselView.cellForItem(at: IndexPath(row: (scrollToIdRAM ?? 0), section: 0)) as? graphCarouselCell) != nil {
                carouselView.scrollToItem(at: IndexPath(row: (scrollToIdRAM ?? 0), section: 0), at: .centeredHorizontally, animated: true)
            } else if carouselView.numberOfItems(inSection: 0) > 0 {
                carouselView.scrollToItem(at: IndexPath(row: (carouselView.numberOfItems(inSection: 0) - 1), section: 0), at: .centeredHorizontally, animated: true)
            }
            
            if secondGraph {
                print("eeeeeeeee")
                if (secondCarouselView.cellForItem(at: IndexPath(row: (scrollToIdRAM ?? 0), section: 0)) as? graphCarouselCell) != nil {
                    print("ffffffff")
                    secondCarouselView.scrollToItem(at: IndexPath(row: (scrollToIdRAM ?? 0), section: 0), at: .centeredHorizontally, animated: true)
                } else if secondCarouselView.numberOfItems(inSection: 0) > 0 {
                    print("gggggggg")
                    secondCarouselView.scrollToItem(at: IndexPath(row: (secondCarouselView.numberOfItems(inSection: 0) - 1), section: 0), at: .centeredHorizontally, animated: true)
                }
            }
            carouselScrollingId = scrollToIdRAM ?? 0
            secondCarouselScrollingId = scrollToIdRAM ?? 0
        } else {
            if (carouselView.cellForItem(at: IndexPath(row: carouselScrollingTodayId, section: 0)) as? graphCarouselCell) != nil {
                carouselView.scrollToItem(at: IndexPath(row: carouselScrollingTodayId, section: 0), at: .centeredHorizontally, animated: true)
            } else if carouselView.numberOfItems(inSection: 0) > 0 {
                carouselView.scrollToItem(at: IndexPath(row: (carouselView.numberOfItems(inSection: 0) - 1), section: 0), at: .centeredHorizontally, animated: true)
            }
            if secondGraph {
                print("hhhhhhhhh")
                if (secondCarouselView.cellForItem(at: IndexPath(row: carouselScrollingTodayId, section: 0)) as? graphCarouselCell) != nil {
                    print("iiiiiiiii")
                    secondCarouselView.scrollToItem(at: IndexPath(row: carouselScrollingTodayId, section: 0), at: .centeredHorizontally, animated: true)
                } else if secondCarouselView.numberOfItems(inSection: 0) > 0 {
                    print("jjjjjjjj")
                    secondCarouselView.scrollToItem(at: IndexPath(row: (secondCarouselView.numberOfItems(inSection: 0) - 1), section: 0), at: .centeredHorizontally, animated: true)
                }
            }
            carouselScrollingId = carouselScrollingTodayId
            secondCarouselScrollingId = carouselScrollingTodayId
        }
        print("kkkkkkkkk")
        completion(true)
    }
    
    func setCollectionData(collectionCellDataIndex: Int, totalIndex: Int) -> Bool {
        if transactionsZero() {
            return false
        } else {
            let ramDict = [
                0:totalIndex, // index if in every month/week etc. is an entry
                1:fromDateShown ?? Date(),
                2:toDateShown ?? Date()
                ] as [Int : Any]
            collectionCellData[collectionCellDataIndex] = ramDict
            return true
        }
    }
    
    func setInitialToFromMaxDates(scrollToId: Int = -1, reload: Bool = false) {
        //if fromDateMax == nil || toDateMax == nil || reload {
        let dateSortHighestFirst = NSSortDescriptor(key: "dateTime", ascending: false)
        let highestDate = dataHandler.loadBulkQueriedSorted(entitie: "Transactions", query: NSPredicate(format: "dateTime != nil"), sort: [dateSortHighestFirst])
            if highestDate.count <= 0 {
                toDateMax = Date()
            } else {
                for i in 0...(highestDate.count-1) {
                    if Int(highestDate[i].value(forKey: "isSplit") as? Int16 ?? 0) > 0 {
                        if userPartOfSplit(dateTime: (highestDate[i].value(forKey: "dateTime") as? Date ?? Date())){
                            toDateMax = highestDate[i].value(forKey: "dateTime") as? Date ?? Date()
                            break
                        }
                    } else {
                        toDateMax = highestDate[i].value(forKey: "dateTime") as? Date ?? Date()
                        break
                    }
                }
            }
            let dateSortLowestFirst = NSSortDescriptor(key: "dateTime", ascending: true)
        let lowestDate = dataHandler.loadBulkQueriedSorted(entitie: "Transactions", query: NSPredicate(format: "dateTime != nil"), sort: [dateSortLowestFirst])
            if lowestDate.count <= 0 {
                fromDateMax = Date()
            } else {
                for i in 0...(lowestDate.count-1) {
                    if Int(lowestDate[i].value(forKey: "isSplit") as? Int16 ?? 0) > 0 {
                        if userPartOfSplit(dateTime: (lowestDate[i].value(forKey: "dateTime") as? Date ?? Date())) {
                            fromDateMax = (Calendar.current.date(byAdding: .minute, value: -1, to: (lowestDate[i].value(forKey: "dateTime") as? Date ?? Date()))!)
                            break
                        }
                    } else {
                        fromDateMax = (Calendar.current.date(byAdding: .minute, value: -1, to: (lowestDate[i].value(forKey: "dateTime") as? Date ?? Date()))!)
//                        fromDateMax = lowestDate[i].value(forKey: "dateTime") as? Date ?? Date()
                        break
                    }
                }
            }
        fromDateMax = fromDateMax?.startOfMonth
            if fromDateShown == nil {
                fromDateShown = Date()
            }
        //}
    }
    
    // MARK: DATA HELPER FUNCTIONS
    func setNameDateUser() {
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        let queryUser = NSPredicate(format: "isUser == %@", NSNumber(value: true))
        
        for data in dataHandler.loadBulkQueriedSorted(entitie: "SplitPersons", query: queryUser, sort: [nameSort]) {
            nameUser = data.value(forKey: "namePerson") as? String ?? ""
            createDateUser = data.value(forKey: "createDate") as? Date ?? Date()
        }
        
        userDatePlus = Calendar.current.date(byAdding: .second, value: 1, to: createDateUser ?? Date())!
        userDateMinus = Calendar.current.date(byAdding: .second, value: -1, to: createDateUser ?? Date())!
    }
    
    func userPartOfSplit(dateTime: Date) -> Bool {
        let nameSort = NSSortDescriptor(key: "namePerson", ascending: false)
        
        let datePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTime)!
        let dateMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTime)!
        
        let query = NSPredicate(format: "dateTimeTransaction > %@ AND dateTimeTransaction < %@ AND namePerson == %@ AND createDatePerson > %@ AND createDatePerson < %@", (dateMinus as NSDate), (datePlus as NSDate), ((nameUser ?? "") as NSString), ((userDateMinus) as NSDate), ((userDatePlus) as NSDate))
        if dataHandler.loadBulkQueriedSorted(entitie: "Splits", query: query, sort: [nameSort]).count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func transactionsZero() -> Bool {
        let transCategoriesPredicate = NSPredicate(format: "selectedForFilter == %@", NSNumber(value: true))
        var transCategories = [Int]()
        for data in dataHandler.loadBulkQueried(entitie: "Categories", query: transCategoriesPredicate) {
            transCategories.append(Int((data.value(forKey: "cID") as? Int16 ?? 0)))
        }
        
        if transCategories.count > 0 {
            let predicate = NSPredicate(format: "dateTime >= %@ AND dateTime <= %@", fromDateShown! as NSDate, toDateShown! as NSDate)
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
    
    func initTagFilter() {
        filteredTagsArray.removeAll()
        if filteredTagsZero {
            let tagsPredicate = NSPredicate(format: "selectedForFilter == %@", NSNumber(value: true))
            for data in dataHandler.loadBulkQueried(entitie: "Tags", query: tagsPredicate) {
                filteredTagsArray.append(data.value(forKey: "tagName") as? String ?? "")
            }
        }
    }
    
    // MARK: VIEW HELPER FUNCTIONS
    func getDateString(timeInterval: Int, stringFromDate: Date, stringToDate: Date) -> String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        
        let today = Date().get(.year, .month, .weekOfYear, .weekday)
        let stringFromDateComponents = stringFromDate.get(.year, .month, .weekOfYear, .weekday)
        let stringToDateComponents = stringToDate.get(.year, .month, .weekOfYear, .weekday)
        
        switch timeInterval {
        case 0: // Monthly
            if (stringFromDateComponents.year == today.year) {
                return monthFormatter.string(from: stringFromDate)
            } else {
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "MMMM, YYYY"
                return monthFormatter.string(from: stringFromDate)
            }
        case 1: // Yearly
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
    
    @objc func showGraphSettings() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showGraphFilter", sender: nil)
        }
    }
    
    @objc func filterButtonTabbed() {
        let filterStoryBoard: UIStoryboard = UIStoryboard(name: "listTSB", bundle: nil)
        let filterVC = filterStoryBoard.instantiateViewController(withIdentifier: "Filter") as! listFilterTVC
        
        filterVC.fromGraphsView = true
        
        let navigationVC = UINavigationController(rootViewController: filterVC)
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    @objc func refresh() {
        fromDateShown = nil
        toDateShown = nil
        lineChartEntries.removeAll()
        lineChartEntriesExpenses.removeAll()
        secondLineChartEntries.removeAll()
        initChartSettings()
        initTagFilter()
        setBarButtons()
        setInitialToFromMaxDates()
        
        if secondGraph {
            carouselStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            carouselStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
            
            carouselStackView.spacing = -10
        } else {
            carouselStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            carouselStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
            
            carouselStackView.spacing = 0
        }
        
        setCollectionCellData(completion: {(success) -> Void in
            carouselView.reloadData()
            if secondGraph {
                secondCarouselView.reloadData()
            }
        })
        showChart(refresh: true)
    }
    
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

extension graphsVC: UICollectionViewDataSource {
    func setCellLayout(appearing: Bool = false) {
        if !scrollViewScrolling {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                if self.firstCarouselWidthConstraints.count > 0 {
                    for index in 0...(self.firstCarouselWidthConstraints.count-1) {
                        self.firstCarouselWidthConstraints[index].isActive = false
                    }
                    self.firstCarouselWidthConstraints.removeAll()
                }
                
                for index in 0...9999999 {
                    let path = IndexPath(row: index, section: 0)
                    if let cell = self.carouselView.cellForItem(at: path) {
                        self.firstCarouselWidthConstraints.append(cell.widthAnchor.constraint(equalToConstant: self.carouselView.frame.width))
                        self.firstCarouselWidthConstraints[index].isActive = true
                    } else {
                        break
                    }
                }
                self.carouselView.layoutIfNeeded()
                self.carouselView.collectionViewLayout.invalidateLayout()
                self.carouselView.reloadData()
                if self.secondGraph {
                    if self.secondCarouselWidthConstraints.count > 0 {
                        for index in 0...(self.secondCarouselWidthConstraints.count-1) {
                            self.secondCarouselWidthConstraints[index].isActive = false
                        }
                        self.secondCarouselWidthConstraints.removeAll()
                    }
                    
                    for index in 0...9999999 {
                        let path = IndexPath(row: index, section: 0)
                        if let cell = self.secondCarouselView.cellForItem(at: path) {
                            self.secondCarouselWidthConstraints.append(cell.widthAnchor.constraint(equalToConstant: self.secondCarouselView.frame.width))
                            self.secondCarouselWidthConstraints[index].isActive = true
                        } else {
                            break
                        }
                    }
                }
                self.secondCarouselView.layoutIfNeeded()
                self.secondCarouselView.collectionViewLayout.invalidateLayout()
                
                self.carouselView.scrollToItem(at: IndexPath(row: self.carouselScrollingId, section: 0), at: .centeredHorizontally, animated: true)
                if self.secondGraph {
                    self.secondCarouselView.reloadData()
                    self.secondCarouselView.scrollToItem(at: IndexPath(row: self.secondCarouselScrollingId, section: 0), at: .centeredHorizontally, animated: true)
                }
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionCellData.count > 0 {
            return collectionCellData.count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "graphCarouselCell", for: indexPath) as! graphCarouselCell
        if collectionCellData.count > 0 {
            cell.label.text = getDateString(timeInterval: graphOption2 ?? 0, stringFromDate: (collectionCellData[indexPath.row]?[1] as? Date ?? Date()), stringToDate: (collectionCellData[indexPath.row]?[2] as? Date ?? Date()))
        } else {
            cell.label.text = NSLocalizedString("noTransactionsScrollViewText", comment: "No transactions")
        }
        
        if indexPath.row == 0 {
            cell.arrowLeft.isHidden = true
        } else {
            if collectionCellData.count > 0 {
                cell.arrowLeft.isHidden = false
            } else {
                cell.arrowLeft.isHidden = true
            }
        }
        
        if indexPath.row == (collectionCellData.count-1) {
            cell.arrowRight.isHidden = true
        } else {
            if collectionCellData.count > 0 {
                cell.arrowRight.isHidden = false
            } else {
                cell.arrowRight.isHidden = true
            }
        }
        
        if collectionView == carouselView {
            if firstCarouselWidthConstraints.indices.contains(indexPath.row) {
                firstCarouselWidthConstraints[indexPath.row].isActive = false
            }
            firstCarouselWidthConstraints.append(cell.widthAnchor.constraint(equalToConstant: carouselView.frame.width))
            firstCarouselWidthConstraints[firstCarouselWidthConstraints.count-1].isActive = true
        } else if collectionView == secondCarouselView {
            if secondCarouselWidthConstraints.indices.contains(indexPath.row) {
                secondCarouselWidthConstraints[indexPath.row].isActive = false
            }
            secondCarouselWidthConstraints.append(cell.widthAnchor.constraint(equalToConstant: secondCarouselView.frame.width))
            secondCarouselWidthConstraints[secondCarouselWidthConstraints.count-1].isActive = true
        }
        
        //cell.setNeedsLayout()
        //cell.layoutIfNeeded()
        cell.tag = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width , height: collectionView.frame.size.height)
    }
}

extension graphsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension graphsVC: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if chartView.isMember(of: PieChartView.self) {
            if chartView.tag == 0 {
                let value = (entry.y/(pieChartSum ?? 1.00)) * 100
                
                var textColor = UIColor.white
                let userInterfaceStyle = traitCollection.userInterfaceStyle
                if userInterfaceStyle == .light {
                    textColor = UIColor.black
                }
                let centerTextText = (numberFormatterPercent.string(from: NSNumber(value: value)) ?? "0.00") + "%"
                let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
                let centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
                
                pieChart.centerAttributedText = centerText
                
                labelLeft.text = pieChartLabels?[Int(highlight.x)]
                label.text = numberFormatter.string(from: NSNumber(value: entry.y))
            } else {
                let value = (entry.y/(secondPieChartSum ?? 1.00)) * 100
                
                var textColor = UIColor.white
                let userInterfaceStyle = traitCollection.userInterfaceStyle
                if userInterfaceStyle == .light {
                    textColor = UIColor.black
                }
                let centerTextText = (numberFormatterPercent.string(from: NSNumber(value: value)) ?? "0.00") + "%"
                let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
                let centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
                
                secondPieChart.centerAttributedText = centerText
                
                secondLeftLabel.text = secondPieChartLabels?[Int(highlight.x)]
                secondLabel.text = numberFormatter.string(from: NSNumber(value: entry.y))
            }
        } else if chartView.isMember(of: LineChartView.self) {
            if chartView.tag == 0 {
                labelLeft.text = mediumDate.string(from: lineChartDates[Int(entry.x)])
                label.text = lineNumberFormatter.string(from: NSNumber(value: lineChartRealValues[Int(entry.x)]))
            } else {
                secondLeftLabel.text = mediumDate.string(from: secondLineChartDates[Int(entry.x)])
                secondLabel.text = lineNumberFormatter.string(from: NSNumber(value: secondLineChartRealValues[Int(entry.x)]))
            }
        } else if chartView.isMember(of: BarChartView.self) {
            if chartView.tag == 0 {
                if graphOption2 == 1 {
                    let dateFormatterRAM = DateFormatter()
                    dateFormatterRAM.dateFormat = "dd/MM/yy"
                    let valueString = "02/" + String(Int(entry.x)) + "/2021"
                    let dateRAM = dateFormatterRAM.date(from: valueString) ?? Date()
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMMM"
                    labelLeft.text = dateFormatter.string(from: dateRAM)
                    label.text = numberFormatter.string(from: NSNumber(value: entry.y))
                } else {
                    let dateFormatterRAM = DateFormatter()
                    dateFormatterRAM.dateFormat = "dd/MM/yy"
                    let valueString = "02/10/" + String(Int(entry.x))
                    let dateRAM = dateFormatterRAM.date(from: valueString) ?? Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy"
                    labelLeft.text = dateFormatter.string(from: dateRAM)
                    label.text = numberFormatter.string(from: NSNumber(value: entry.y))
                }
            } else if chartView.tag == 1 {
                if graphOption2 == 1 {
                    let dateFormatterRAM = DateFormatter()
                    dateFormatterRAM.dateFormat = "dd/MM/yy"
                    let valueString = "02/" + String(Int(entry.x)) + "/2021"
                    let dateRAM = dateFormatterRAM.date(from: valueString) ?? Date()
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMMM"
                    secondLeftLabel.text = dateFormatter.string(from: dateRAM)
                    secondLabel.text = numberFormatter.string(from: NSNumber(value: entry.y))
                } else {
                    let dateFormatterRAM = DateFormatter()
                    dateFormatterRAM.dateFormat = "dd/MM/yy"
                    let valueString = "02/10/" + String(Int(entry.x))
                    let dateRAM = dateFormatterRAM.date(from: valueString) ?? Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy"
                    secondLeftLabel.text = dateFormatter.string(from: dateRAM)
                    secondLabel.text = numberFormatter.string(from: NSNumber(value: entry.y))
                }
            }
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        if chartView.isMember(of: PieChartView.self) {
            if chartView.tag == 0 {
                var textColor = UIColor.white
                let userInterfaceStyle = traitCollection.userInterfaceStyle
                if userInterfaceStyle == .light {
                    textColor = UIColor.black
                }
                let centerTextText = (numberFormatterPercent.string(from: NSNumber(value: 100.00)) ?? "100.00") + "%"
                let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
                let centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
                
                pieChart.centerAttributedText = centerText
                
                if graphOption1 == 0 {
                    labelLeft.text = NSLocalizedString("pieChartOption1_0", comment: "Expense")
                    label.text = numberFormatter.string(from: NSNumber(value: pieChartSum ?? 0.00))
                } else if graphOption1 == 1 {
                    labelLeft.text = NSLocalizedString("pieChartOption1_1", comment: "Income")
                    label.text = numberFormatter.string(from: NSNumber(value: pieChartSum ?? 0.00))
                } else {
                    labelLeft.text = NSLocalizedString("pieChartOption1_2", comment: "Savings")
                    label.text = numberFormatter.string(from: NSNumber(value: pieChartSum ?? 0.00))
                }
            } else {
                var textColor = UIColor.white
                let userInterfaceStyle = traitCollection.userInterfaceStyle
                if userInterfaceStyle == .light {
                    textColor = UIColor.black
                }
                let centerTextText = (numberFormatterPercent.string(from: NSNumber(value: 100.00)) ?? "100.00") + "%"
                let textAttribute = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote), NSAttributedString.Key.foregroundColor: textColor]
                let centerText = NSAttributedString(string: centerTextText, attributes: textAttribute)
                
                secondPieChart.centerAttributedText = centerText
                
                if graphOption3 == 0 {
                    secondLeftLabel.text = NSLocalizedString("pieChartOption1_0", comment: "Expense")
                    secondLabel.text = numberFormatter.string(from: NSNumber(value: secondPieChartSum ?? 0.00))
                } else if graphOption3 == 1 {
                    secondLeftLabel.text = NSLocalizedString("pieChartOption1_1", comment: "Income")
                    secondLabel.text = numberFormatter.string(from: NSNumber(value: secondPieChartSum ?? 0.00))
                } else {
                    secondLeftLabel.text = NSLocalizedString("pieChartOption1_2", comment: "Savings")
                    secondLabel.text = numberFormatter.string(from: NSNumber(value: secondPieChartSum ?? 0.00))
                }
            }
        } else if chartView.isMember(of: LineChartView.self) {
            if chartView.tag == 0 {
                labelLeft.text = NSLocalizedString("changeLabel", comment: "Balance")
                label.text = lineNumberFormatter.string(from: NSNumber(value: lineChartDifference))
            } else {
                secondLeftLabel.text = NSLocalizedString("changeLabel", comment: "Balance")
                secondLabel.text = lineNumberFormatter.string(from: NSNumber(value: secondLineChartDifference))
            }
        } else if chartView.isMember(of: BarChartView.self) {
            if chartView.tag == 0 {
                labelLeft.text = NSLocalizedString("changeLabel", comment: "Change")
                label.text = numberFormatter.string(from: NSNumber(value: barChartDifference))
            } else {
                secondLeftLabel.text = NSLocalizedString("changeLabel", comment: "Change")
                secondLabel.text = numberFormatter.string(from: NSNumber(value: barChartDifference))
            }
        }
    }
}

// MARK: axisFormatDelegate
extension graphsVC: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if graphOption2 == 1 { // Monthly
            let dateFormatterRAM = DateFormatter()
            dateFormatterRAM.dateFormat = "dd/MM/yy"
            let valueString = "02/" + String(Int(value)) + "/2021"
            let dateRAM = dateFormatterRAM.date(from: valueString) ?? Date()
            
            let dateFormatter = DateFormatter()
            if barChartEntriesCount <= 2 {
                dateFormatter.dateFormat = "MMMM"
            } else if barChartEntriesCount > 2 && barChartEntriesCount <= 4 {
                dateFormatter.dateFormat = "MMM"
            } else {
                dateFormatter.dateFormat = "MMMMM"
            }
            return dateFormatter.string(from: dateRAM)
        } else { // Yearly
            let dateFormatterRAM = DateFormatter()
            dateFormatterRAM.dateFormat = "dd/MM/yy"
            let valueString = "02/10/" + String(Int(value))
            let dateRAM = dateFormatterRAM.date(from: valueString) ?? Date()
            if barChartEntriesCount > 2 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yy"
                return dateFormatter.string(from: dateRAM)
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy"
                return dateFormatter.string(from: dateRAM)
            }
        }
    }
}

//extension graphsVC {
//    // MARK: -DATA
//
//    // MARK: SAVE GRAPHS
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
//    // MARK: -LOAD
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
//    func loadQueriedAttribute(entitie:String, attibute:String, query:NSPredicate) -> Any {
//        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentLocalContainer.viewContext
//        managedContext.automaticallyMergesChangesFromParent = true
//        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
//        fetchRequest.returnsObjectsAsFaults = false
//        fetchRequest.predicate = query
//        do {
//            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
//            for data in loadData {
//                if data.value(forKey: attibute) != nil {
//                    return data.value(forKey: attibute) ?? false
//                }
//            }
//        } catch {
//            print("Could not fetch. \(error)")
//        }
//        return false
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
