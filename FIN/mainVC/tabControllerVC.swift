//
//  tabControllerVC.swift
//  FIN
//
//  Created by Florian Riel on 26.06.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import StoreKit

class tabController: UITabBarController {
    
    var previousIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAdds = (loadSettings(entitie: "Settings", attibute: "showAdds") as? Bool ?? true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appear), name: UIApplication.didBecomeActiveNotification, object: nil)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        loginEnabled = loadData(entitie: "Settings", attibute: "loginEnabled") as? Bool ?? true
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
        loginEnabled = loadData(entitie: "Settings", attibute: "loginEnabled") as? Bool ?? true
        if !loginSuccessfull && loginEnabled {
            self.performSegue(withIdentifier: "unwindToLogin", sender: nil)
        }
        let numbersOpened = UserDefaults.standard.integer(forKey: "numbersOpened")
        if numbersOpened > 0 && openNewTransaction {
            openNewTransaction = false
            let finStoryBoard: UIStoryboard = UIStoryboard(name: "finTSB", bundle: nil)
            let addVC = finStoryBoard.instantiateViewController(withIdentifier: "addTVC") as! addTVC
            
            let navigationVC = UINavigationController(rootViewController: addVC)
            self.present(navigationVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - DATA
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
    
    // MARK: - Navigation
    // MARK: Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
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
