//
//  tabControllerVC.swift
//  FIN
//
//  Created by Florian Riel on 26.06.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class tabController: UITabBarController {
    
    var previousIndex:Int?
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory Warning received")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
                
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            if userInterfaceStyle == .light {
                appearance.backgroundColor = .white
            } else {
                appearance.backgroundColor = .black
            }
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
        
        showAdds = (dataHandler.loadSettings(entitie: "Settings", attibute: "showAdds") as? Bool ?? true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appear), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.tabBar.tintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        
        let addStoryBoard: UIStoryboard = UIStoryboard(name: "finTSB", bundle: nil)
        let addViewController = addStoryBoard.instantiateViewController(withIdentifier: "finNC") as! UINavigationController
        addViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabPlusPort"), tag: 0)
        addViewController.tabBarItem.landscapeImagePhone = UIImage(named: "tabPlusLand")
//        addViewController.tabBarItem.selectedImage = UIImage(named: "tabPlusLand")
        
        let listStoryBoard: UIStoryboard = UIStoryboard(name: "listTSB", bundle: nil)
        var listViewController = listStoryBoard.instantiateViewController(withIdentifier: "listSplitVC")
        if UIDevice().model.contains("iPad") {
            listViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabListPort"), tag: 1)
            listViewController.tabBarItem.landscapeImagePhone = UIImage(named: "tabListPort")
        } else {
            let listVC = listStoryBoard.instantiateViewController(identifier: "listMasterTVC") as! listMasterTVC
            listViewController = UINavigationController(rootViewController: listVC)
            listViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabListPort"), tag: 1)
            listViewController.tabBarItem.landscapeImagePhone = UIImage(named: "tabListPort")
        }
        
        let graphStoryBoard: UIStoryboard = UIStoryboard(name: "graphsTSB", bundle: nil)
        let graphViewController = graphStoryBoard.instantiateViewController(withIdentifier: "graphsNC")
        graphViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabGraphPort"), tag: 2)
        graphViewController.tabBarItem.landscapeImagePhone = UIImage(named: "tabGraphLand")
        graphViewController.tabBarItem.selectedImage = UIImage(named: "tabGraphSelected")
        
        let splitStoryBoard: UIStoryboard = UIStoryboard(name: "splitTSB", bundle: nil)
        var splitViewController = splitStoryBoard.instantiateViewController(withIdentifier: "splitVC")
        if UIDevice().model.contains("iPad") {
            splitViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabPersonsPort"), tag: 3)
            splitViewController.tabBarItem.landscapeImagePhone = UIImage(named: "tabPersonsLand")
            splitViewController.tabBarItem.selectedImage = UIImage(named: "tabPersonsSelected")
        } else {
            let splitVC = splitStoryBoard.instantiateViewController(identifier: "splitMasterTVC") as! splitMasterTVC
            splitViewController = UINavigationController(rootViewController: splitVC)
            splitViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabPersonsPort"), tag: 3)
            splitViewController.tabBarItem.landscapeImagePhone = UIImage(named: "tabPersonsLand")
            splitViewController.tabBarItem.selectedImage = UIImage(named: "tabPersonsSelected")
        }
        
        let userStoryBoard: UIStoryboard = UIStoryboard(name: "userTSB", bundle: nil)
        var userViewController = userStoryBoard.instantiateViewController(withIdentifier: "userSplitVC")
        if UIDevice().model.contains("iPad") {
            userViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabPersonPort"), tag: 4)
            userViewController.tabBarItem.landscapeImagePhone = UIImage(named: "tabPersonLand")
            userViewController.tabBarItem.selectedImage = UIImage(named: "tabPersonSelected")
        } else {
            let userVC = userStoryBoard.instantiateViewController(identifier: "userMasterVC") as! userMasterVC
            userViewController = UINavigationController(rootViewController: userVC)
            userViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tabPersonPort"), tag: 4)
            userViewController.tabBarItem.landscapeImagePhone = UIImage(named: "tabPersonLand")
            userViewController.tabBarItem.selectedImage = UIImage(named: "tabPersonSelected")
        }
        
        let tabBarList = [addViewController, listViewController, graphViewController, splitViewController, userViewController]
        
        viewControllers = tabBarList
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        loginEnabled = UserDefaults.standard.bool(forKey: "loginEnabled")
        if !loginSuccessfull && loginEnabled {
            self.performSegue(withIdentifier: "unwindToLogin", sender: nil)
        }
        
        let numbersOpened = UserDefaults.standard.integer(forKey: "numbersOpened")
        
        let update140 = UserDefaults.standard.integer(forKey: "update140")
        
        if numbersOpened == 0 {
            if !UIDevice().model.contains("iPad") {
                AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
            }
            
            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let introVC = mainStoryBoard.instantiateViewController(withIdentifier: "introVC") as! introVC
            let navigationVC = UINavigationController(rootViewController: introVC)
            navigationVC.isNavigationBarHidden = true
            self.present(navigationVC, animated: true, completion: nil)
            
            UserDefaults.standard.setValue((numbersOpened+1), forKey: "numbersOpened")
            UserDefaults.standard.setValue(1, forKey: "update140")
        } else if update140 == 0 {
            if !UIDevice().model.contains("iPad") {
                AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
            }
            
            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let introVC = mainStoryBoard.instantiateViewController(withIdentifier: "updateVC") as! updateVC
            let navigationVC = UINavigationController(rootViewController: introVC)
            navigationVC.isNavigationBarHidden = true
            self.present(navigationVC, animated: true, completion: nil)
            
            UserDefaults.standard.setValue(1, forKey: "update140")
        } else if numbersOpened == 10 {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
            UserDefaults.standard.setValue((numbersOpened+1), forKey: "numbersOpened")
        } else if numbersOpened < 21 {
            UserDefaults.standard.setValue((numbersOpened+1), forKey: "numbersOpened")
        } else if numbersOpened >= 21 {
            UserDefaults.standard.setValue((11), forKey: "numbersOpened")
        }
        
        let update150 = UserDefaults.standard.integer(forKey: "update150")
        if update150 == 0 {
            doUpdate150()
        }
        
        let update160 = UserDefaults.standard.integer(forKey: "update160")
        if update160 == 0 {
            doUpdate160()
        }
        
        let update170 = UserDefaults.standard.bool(forKey: "update170")
        if update170 {
            doUpdate170()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            if userInterfaceStyle == .light {
                appearance.backgroundColor = .white
            } else {
                appearance.backgroundColor = .black
            }
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        UIImpactFeedbackGenerator().impactOccurred()
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        navigationBarAppearace.barTintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05, execute: {
            if self.selectedIndex == 0 && self.previousIndex == 0 {
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name("showAddVC"), object: nil)
            } else {
                self.previousIndex = self.selectedIndex
            }
        })
    }
    
    @objc func appear() {
        loginEnabled = UserDefaults.standard.bool(forKey: "loginEnabled")
        if !loginSuccessfull && loginEnabled {
            self.performSegue(withIdentifier: "unwindToLogin", sender: nil)
        }
        let numbersOpened = UserDefaults.standard.integer(forKey: "numbersOpened")
        if numbersOpened > 0 && (openNewTransaction || scanNewBill) {
            openNewTransaction = false
            let finStoryBoard: UIStoryboard = UIStoryboard(name: "finTSB", bundle: nil)
            let addVC = finStoryBoard.instantiateViewController(withIdentifier: "addTVC") as! addTVC
            
            let navigationVC = UINavigationController(rootViewController: addVC)
            self.present(navigationVC, animated: true, completion: nil)
        }
    }
        
    // MARK: - Navigation
    // MARK: Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "unwindToLogin":
            guard segue.destination is loginVC else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            break
        default:
            break
        }
    }
}

extension tabController {
    func doUpdate170() {
        let userCode = dataHandler.loadSettings(entitie: "Settings", attibute: "userCode") as? String ?? ""
        let loginEnabled = dataHandler.loadSettings(entitie: "Settings", attibute: "loginEnabled") as? Bool ?? false
        
        UserDefaults.standard.set(userCode, forKey: "userCode")
        UserDefaults.standard.set(loginEnabled, forKey: "loginEnabled")
        UserDefaults.standard.set(false, forKey: "filteredCategoriesZero")
        UserDefaults.standard.set(false, forKey: "filteredTagsZero")
        
        
        if UIDevice().model.contains("iPhone") {
            UserDefaults.standard.set(false, forKey: "showSecondGraph")
        } else {
            UserDefaults.standard.set(true, forKey: "showSecondGraph")
        }
        
        UserDefaults.standard.set(false, forKey: "update170")
    }
    
    func doUpdate160() { // Initiate Cloud Sync
        
        // Categories
        dataHandler.saveBulk(entity: "Categories", attribute: "initiateCloudSync", value: true)
        // Currency
        dataHandler.saveBulk(entity: "Currency", attribute: "initiateCloudSync", value: true)
        // RegularPayments
        dataHandler.saveBulk(entity: "RegularPayments", attribute: "initiateCloudSync", value: true)
        // Settings
        dataHandler.saveBulk(entity: "Settings", attribute: "initiateCloudSync", value: true)
        // SplitGroups
        dataHandler.saveBulk(entity: "SplitGroups", attribute: "initiateCloudSync", value: true)
        // SplitPersons
        dataHandler.saveBulk(entity: "SplitPersons", attribute: "initiateCloudSync", value: true)
        // Splits
        dataHandler.saveBulk(entity: "Splits", attribute: "initiateCloudSync", value: true)
        // SplitsRegularPayments
        dataHandler.saveBulk(entity: "SplitsRegularPayments", attribute: "initiateCloudSync", value: true)
        // Tags
        dataHandler.saveBulk(entity: "Tags", attribute: "initiateCloudSync", value: true)
        // Transactions
        dataHandler.saveBulk(entity: "Transactions", attribute: "initiateCloudSync", value: true)
        
        UserDefaults.standard.setValue(1, forKey: "update160")
    }
    
    func doUpdate150() {
        // Transactions
        for data in dataHandler.loadDataBulk(entity: "Transactions") {
            if (data.value(forKey: "uuid") as? UUID) == nil {
                let createTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (data.value(forKey: "dateTime") as? Date ?? Date()))!
                let createTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (data.value(forKey: "dateTime") as? Date ?? Date()))!
                
                let query = NSPredicate(format: "dateTime < %@ AND dateTime > %@", (createTransactionPlus as NSDate), (createTransactionMinus as NSDate))
                
                _ = dataHandler.saveQueriedAttribute(entity: "Transactions", attribute: "uuid", query: query, value: UUID())
            }
        }
        
        // Tags
        for data in dataHandler.loadDataBulk(entity: "Tags") {
            if (data.value(forKey: "uuid") as? UUID) == nil {
                let query = NSPredicate(format: "tagName == %@", (data.value(forKey: "tagName") as? String ?? "") as NSString)
                _ = dataHandler.saveQueriedAttribute(entity: "Tags", attribute: "uuid", query: query, value: UUID())
            }
        }
        
        // SplitRegularPayments
        for data in dataHandler.loadDataBulk(entity: "SplitsRegularPayments") {
            if (data.value(forKey: "uuid") as? UUID) == nil {
                let createTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (data.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                let createTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (data.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                
                let query = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", (createTransactionPlus as NSDate), (createTransactionMinus as NSDate))
                
                _ = dataHandler.saveQueriedAttribute(entity: "SplitsRegularPayments", attribute: "uuid", query: query, value: UUID())
            }
        }
        
        // Splits
        for data in dataHandler.loadDataBulk(entity: "Splits") {
            if (data.value(forKey: "uuid") as? UUID) == nil {
                let createTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (data.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                let createTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (data.value(forKey: "dateTimeTransaction") as? Date ?? Date()))!
                
                let query = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", (createTransactionPlus as NSDate), (createTransactionMinus as NSDate))
                
                _ = dataHandler.saveQueriedAttribute(entity: "Splits", attribute: "uuid", query: query, value: UUID())
            }
        }
        
        // SplitPersons
        for data in dataHandler.loadDataBulk(entity: "SplitPersons") {
            if (data.value(forKey: "uuid") as? UUID) == nil {
                let createTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (data.value(forKey: "createDate") as? Date ?? Date()))!
                let createTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (data.value(forKey: "createDate") as? Date ?? Date()))!
                
                let query = NSPredicate(format: "createDate < %@ AND createDate > %@", (createTransactionPlus as NSDate), (createTransactionMinus as NSDate))
                
                _ = dataHandler.saveQueriedAttribute(entity: "SplitPersons", attribute: "uuid", query: query, value: UUID())
            }
        }
        
        // SplitGroups
        for data in dataHandler.loadDataBulk(entity: "SplitGroups") {
            if (data.value(forKey: "uuid") as? UUID) == nil {
                let createTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (data.value(forKey: "createDate") as? Date ?? Date()))!
                let createTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (data.value(forKey: "createDate") as? Date ?? Date()))!
                
                let query = NSPredicate(format: "createDate < %@ AND createDate > %@", (createTransactionPlus as NSDate), (createTransactionMinus as NSDate))
                
                _ = dataHandler.saveQueriedAttribute(entity: "SplitGroups", attribute: "uuid", query: query, value: UUID())
            }
        }
        
        // RegularPayments
        for data in dataHandler.loadDataBulk(entity: "RegularPayments") {
            if (data.value(forKey: "uuid") as? UUID) == nil {
                let createTransactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: (data.value(forKey: "dateTimeNext") as? Date ?? Date()))!
                let createTransactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: (data.value(forKey: "dateTimeNext") as? Date ?? Date()))!
                
                let query = NSPredicate(format: "dateTimeNext < %@ AND dateTimeNext > %@", (createTransactionPlus as NSDate), (createTransactionMinus as NSDate))
                
                _ = dataHandler.saveQueriedAttribute(entity: "RegularPayments", attribute: "uuid", query: query, value: UUID())
            }
        }
        
        UserDefaults.standard.setValue(1, forKey: "update150")
    }
}
