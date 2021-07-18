//
//  cellCategoryTVC.swift
//  FIN
//
//  Created by Florian Riel on 21.07.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import SmoothPicker
import CoreData

var incomeOrSaveSelected:Bool = true

class cellCategoryTVC: UITableViewCell, SmoothPickerViewDelegate, SmoothPickerViewDataSource {

    @IBOutlet weak var cellCategoryOutlineView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    weak var delegate: cellCategoryTVCDelecate?
    
    let buttonBackgroundColor:UIColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 0.2)
    let buttonBorderColor:CGColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1).cgColor
    let buttonTextColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    let buttonSelectedBackgroundColor: UIColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
    let buttonSelectedTextColor = UIColor.white
    
    var categories = [Int:[Int:Any]]()
    var categoryViews = [UIView]()
    
    var categoryPickerView:categoryPickerView = {
        let nib = UINib(nibName: "categoryPickerView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! categoryPickerView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellCategoryOutlineView.layer.borderWidth = 1
        cellCategoryOutlineView.layer.cornerRadius = 10
                
        initUI()
        
        initCategories()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initUI()
        initCategories(traitDidChange: true)
    }
    
    func initUI() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .light {
            self.backgroundColor = .clear
            cellCategoryOutlineView.backgroundColor = .white
            cellCategoryOutlineView.layer.borderColor = CGColor(srgbRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        } else {
            self.backgroundColor = .clear
            cellCategoryOutlineView.backgroundColor = .black
            cellCategoryOutlineView.layer.borderColor = CGColor(srgbRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        }
    }
    
    func initCategories(traitDidChange:Bool = false) {
        if traitDidChange {
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            if userInterfaceStyle == .light {
                mainStackView.arrangedSubviews[0].backgroundColor = .white
                mainStackView.arrangedSubviews[0].layer.borderColor = UIColor.white.cgColor
            } else {
                mainStackView.arrangedSubviews[0].backgroundColor = .black
                mainStackView.arrangedSubviews[0].layer.borderColor = UIColor.black.cgColor
            }
        } else {
            getCategories()
                    
            let pickerView = SmoothPickerView()
            pickerView.delegate = self
            pickerView.dataSource = self
                    
            pickerView.layer.borderWidth = 1
            pickerView.layer.cornerRadius = 5
                    
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            if userInterfaceStyle == .light {
                pickerView.backgroundColor = .white
                pickerView.layer.borderColor = UIColor.white.cgColor
            } else {
                pickerView.backgroundColor = .black
                pickerView.layer.borderColor = UIColor.black.cgColor
            }
                        
            SmoothPickerConfiguration.setSelectionStyle(selectionStyle: .colored)
            SmoothPickerConfiguration.setColors(selectedColor: buttonSelectedBackgroundColor, dimmedColor: buttonBackgroundColor)
            categoryViews.removeAll()
            if categories.count > 0 {
                for i in 0...(categories.count-1) {
                    let categoryPickerView:categoryPickerView = {
                        let nib = UINib(nibName: "categoryPickerView", bundle: nil)
                        return nib.instantiate(withOwner: self, options: nil).first as! categoryPickerView
                    }()
                    categoryPickerView.categoryLabel.text = categories[i]?[1] as? String ?? ""
                    categoryPickerView.layer.borderColor = buttonBorderColor
                    categoryPickerView.initView()
                    categoryViews.append(categoryPickerView)
                }
                        
                pickerView.firstselectedItem = getCategoryIndex(cID: selectedCategory)
                pickerView.reloadData()
                    
                let label = UILabel()
                label.font = .preferredFont(forTextStyle: .body)
                        
                pickerView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
                
                mainStackView.insertArrangedSubview(pickerView, at: 0)
                
                incomeOrSaveSelected = isCategoryIncomeOrSave(index: selectedCategory)
            }
        }
    }
    
    func getCategoryIndex(cID: Int) -> Int {
        let categoryID = Int16(cID)
        for i in 0...(categories.count-1) {
            if categoryID == (categories[i]?[0] as? Int16 ?? 999) {
                return i
            }
        }
        return 0
    }

    func didSelectItem(index: Int, view: UIView, pickerView: SmoothPickerView) {
        selectedCategory = index
        
        incomeOrSaveSelected = isCategoryIncomeOrSave(index: index)
        
        for i in 0...(categoryViews.count-1) {
            let viewLoop = categoryViews[i] as? categoryPickerView
            if i == index {
                viewLoop?.categoryLabel.textColor = buttonSelectedTextColor
            } else {
                viewLoop?.categoryLabel.textColor = buttonTextColor
            }
        }
        self.delegate?.categoryPicked(category: categories[index] ?? [0:-1])
//        UIImpactFeedbackGenerator().impactOccurred()
    }
    
    func numberOfItems(pickerView: SmoothPickerView) -> Int {
        return categoryViews.count
    }
    
    func itemForIndex(index: Int, pickerView: SmoothPickerView) -> UIView {
        return categoryViews[index]
    }
    
    // MARK: -DATA
    func getCategories() {
        categories.removeAll()
        var i = 0
        // Get Expense Categories
        let predicateExpenses:NSPredicate = NSPredicate(format: "isIncome == false && isSave == false")
        let expenses = dataHandler.loadBulkQueried(entitie: "Categories", query: predicateExpenses)
        if expenses.count != 0 {
            for expense in expenses {
                categories[i] = [
                    0:expense.value(forKey: "cID") as? Int16 ?? 0,
                    1:expense.value(forKey: "name") as? String ?? "",
                    2:expense.value(forKey: "color") as? Int16 ?? 0,
                    3:expense.value(forKey: "isIncome") as? Bool ?? false,
                    4:expense.value(forKey: "isSave") as? Bool ?? false
                ]
                i = i + 1
            }
        }
        // Get Income Categories
        let predicateIncome:NSPredicate = NSPredicate(format: "isIncome == true && isSave == false")
        let incomes = dataHandler.loadBulkQueried(entitie: "Categories", query: predicateIncome)
        if incomes.count != 0 {
            for income in incomes {
                categories[i] = [
                    0:income.value(forKey: "cID") as? Int16 ?? 0,
                    1:income.value(forKey: "name") as? String ?? "",
                    2:income.value(forKey: "color") as? Int16 ?? 0,
                    3:income.value(forKey: "isIncome") as? Bool ?? false,
                    4:income.value(forKey: "isSave") as? Bool ?? false
                ]
                i = i + 1
            }
        }
        // Get Savings Income Categories
        let predicateSaveDeposit:NSPredicate = NSPredicate(format: "isIncome == false && isSave == true")
        let savesDeposit = dataHandler.loadBulkQueried(entitie: "Categories", query: predicateSaveDeposit)
        if savesDeposit.count != 0 {
            for saveIncome in savesDeposit {
                categories[i] = [
                    0:saveIncome.value(forKey: "cID") as? Int16 ?? 0,
                    1:saveIncome.value(forKey: "name") as? String ?? "",
                    2:saveIncome.value(forKey: "color") as? Int16 ?? 0,
                    3:saveIncome.value(forKey: "isIncome") as? Bool ?? false,
                    4:saveIncome.value(forKey: "isSave") as? Bool ?? false
                ]
                i = i + 1
            }
        }
        // Get Savings Expense Categories
        let predicateSaveWithdraw:NSPredicate = NSPredicate(format: "isIncome == true && isSave == true")
        let savesWithdraw = dataHandler.loadBulkQueried(entitie: "Categories", query: predicateSaveWithdraw)
        if savesWithdraw.count != 0 {
            for saveExpense in savesWithdraw {
                categories[i] = [
                    0:saveExpense.value(forKey: "cID") as? Int16 ?? 0,
                    1:saveExpense.value(forKey: "name") as? String ?? "",
                    2:saveExpense.value(forKey: "color") as? Int16 ?? 0,
                    3:saveExpense.value(forKey: "isIncome") as? Bool ?? false,
                    4:saveExpense.value(forKey: "isSave") as? Bool ?? false
                ]
                i = i + 1
            }
        }
//        if categories.count <= 0 {
//            initCategoriesINITIAL() // PUT IN FIRST VIEW
//            getCategories()
//        }
    }
    
    public func isCategoryIncomeOrSave(index:Int) -> Bool {
        if (categories[index]?[3] as? Bool ?? false) || (categories[index]?[4] as? Bool ?? false) {
            return true
        } else {
            return false
        }
    }
    
//    // MARK: PUT IN FIRST VIEW
//    func initCategoriesINITIAL() {
//            if (loadBulkData(entitie: "Categories", orderBy: "cID")).count == 0 {
//    //            if loadData(entitie: "Settings", attibute: "firstLaunch") {
//    //
//    //            }
//                for i in 0...4 {
//                    switch i {
//                    case 1:
//                        saveCategory(name: "Sport", color: 10, isIncome: false, isSave: false)
//                        break
//                    case 2:
//                        saveCategory(name: "Other", color: 2, isIncome: false, isSave: false)
//                        break
//                    case 3:
//                        saveCategory(name: "Savings", color: 1, isIncome: false, isSave: true)
//                        break
//                    case 4:
//                        saveCategory(name: "Salary", color: 4, isIncome: true, isSave: false)
//                        break
//                    default:
//                        saveCategory(name: "Household", color: 8, isIncome: false, isSave: false)
//                        break
//                    }
//                }
//            }
//        }
}

protocol cellCategoryTVCDelecate: AnyObject {
    func categoryPicked(category: [Int:Any])
}
