//
//  AppDelegate.swift
//  FIN
//
//  Created by Florian Riel on 22.06.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData
import SWXMLHash
import SwiftUI

var loginSuccessfull = false
var loginEnabled = true
let backgroundGeneralColor = UIColor(red: 240/255, green: 243/255, blue: 255/255, alpha: 1.0)

var reloadAddView: Bool = false
var reloadCategoryView: Bool = false

var filteredCategoriesZero: Bool = false
var filteredTagsZero: Bool = false

var reloadListView:Bool = false
var reloadFinView:Bool = false
var reloadGraphView:Bool = false
var reloadSplitView:Bool = false

var showAdds:Bool = true
var graphShowCounter:Int = 0

var openNewTransaction = false

let dataHandler = dataClass()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Navbar customization
        
//        navigationBarAppearace.isTranslucent = false
//        navigationBarAppearace.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
//        navigationBarAppearace.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
//        navigationBarAppearace.barTintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
//        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
//        navigationBarAppearace.backgroundColor = UIColor(red: 240/255, green: 243/255, blue: 255/255, alpha: 1.0)
//        navigationBarAppearace.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
//        navigationBarAppearace.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        // Since iOS 15:
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        navigationBarAppearace.standardAppearance = appearance
        navigationBarAppearace.scrollEdgeAppearance = appearance
        
        dataHandler.saveNewSettings()
                    
//        let numbersOpened = UserDefaults.standard.integer(forKey: "numbersOpened")
//        if numbersOpened % 3 == 0 {
//            checkForCategoryDuplicates()
//            checkTags()
//            // checkForTransactionDuplicates()
//        }
        checkForCategoryDuplicates()
        checkTags()
        checkForTagDuplicates()
        checkForTransactionDuplicates()
        checkForInitialTransactionDuplicates()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: FUNCTIONS
    func checkForCategoryDuplicates() {
        var duplicateIDs = [Int16]()
        
        let categoriesCountArray = dataHandler.loadDataGrouped(entitie: "Categories", groupByColumn: "cID") as? [[String:Any]]
        if (categoriesCountArray?.count ?? 0) > 0 {
            for i in 0...((categoriesCountArray?.count ?? 1)-1) {
                if categoriesCountArray?[i]["count"] as? Int64 ?? 0 > 1 {
                    duplicateIDs.append(categoriesCountArray?[i]["cID"] as? Int16 ?? 0)
                }
            }
        }
        // 1402 x 897
        if duplicateIDs.count > 0 {
            for duplicate in duplicateIDs {
                let nextID = dataHandler.loadNextCategoryID()
                let query = NSPredicate(format: "cID == %i", duplicate)
                dataHandler.saveSingleDataInt16(entity: "Categories", attibute: "cID", newValue: nextID, query: query, sort: [NSSortDescriptor(key: "createDate", ascending: false)])
            }
            checkForCategoryDuplicates()
        }
    }
    
    func checkTags() {
        for tag in dataHandler.loadDataBulk(entity: "Tags") {
            let query = NSPredicate(format: "tags CONTAINS %@", (tag.value(forKey: "tagName") as? String ?? "*;*") as NSString)
            if (dataHandler.loadBulkDataWithQueryLimited(entitie: "Transactions", query: query).count <= 0) && (dataHandler.loadBulkDataWithQueryLimited(entitie: "RegularPayments", query: query).count <= 0) {
                let queryDelete = NSPredicate(format: "tagName == %@", (tag.value(forKey: "tagName") as? String ?? "*;*") as NSString)
                if dataHandler.loadBulkDataWithQueryLimited(entitie: "Tags", query: queryDelete).count == 1 {
                    dataHandler.deleteData(entity: "Tags", query: queryDelete)
                }
            }
        }
    }
    
    func checkForTagDuplicates() {
        var duplicateTagNames = [String]()
        
        let tagCountArray = dataHandler.loadDataGrouped(entitie: "Tags", groupByColumn: "tagName") as? [[String:Any]]
        if (tagCountArray?.count ?? 0) > 0 {
            for i in 0...((tagCountArray?.count ?? 1)-1) {
                if tagCountArray?[i]["count"] as? Int64 ?? 0 > 1 {
                    duplicateTagNames.append(tagCountArray?[i]["tagName"] as? String ?? "")
                }
            }
        }
        
        if duplicateTagNames.count > 0 {
            for duplicate in duplicateTagNames {
                let queryDelete = NSPredicate(format: "tagName == %@", duplicate as NSString)
                dataHandler.deleteDataSingle(entity: "Tags", query: queryDelete)
            }
            checkForTagDuplicates()
        }
    }
    
    func checkForTransactionDuplicates() {
        var duplicateDates = [Date]()
        
        let transactionsCountArray = dataHandler.loadDataGrouped(entitie: "Transactions", groupByColumn: "dateTime") as? [[String:Any]]
        if (transactionsCountArray?.count ?? 0) > 0 {
            for i in 0...((transactionsCountArray?.count ?? 1)-1) {
                if transactionsCountArray?[i]["count"] as? Int64 ?? 0 > 1 {
                    duplicateDates.append(transactionsCountArray?[i]["dateTime"] as? Date ?? Date())
                }
            }
        }
        
        if duplicateDates.count > 0 {
            for duplicate in duplicateDates {
                let transactionPlus = Calendar.current.date(byAdding: .second, value: 1, to: duplicate)!
                let transactionMinus = Calendar.current.date(byAdding: .second, value: -1, to: duplicate)!
                
                let queryDelete = NSPredicate(format: "dateTime < %@ AND dateTime > %@", transactionPlus as NSDate, transactionMinus as NSDate)
                dataHandler.deleteDataSingle(entity: "Transactions", query: queryDelete)
            }
            checkForTransactionDuplicates()
        }
    }
    
    func checkForInitialTransactionDuplicates() {
        var duplicateInt = [Int16]()
        
        let transactionsCountArray = dataHandler.loadDataInitialTransactionsGrouped(entitie: "Transactions", groupByColumn: "categoryID") as? [[String:Any]]
        if (transactionsCountArray?.count ?? 0) > 0 {
            for i in 0...((transactionsCountArray?.count ?? 1)-1) {
                if transactionsCountArray?[i]["count"] as? Int64 ?? 0 > 1 {
                    duplicateInt.append(transactionsCountArray?[i]["categoryID"] as? Int16 ?? -2)
                }
            }
        }
        
        if duplicateInt.count > 0 {
            for duplicate in duplicateInt {
                let queryDelete = NSPredicate(format: "dateTime == nil AND categoryID == %i", duplicate)
                dataHandler.deleteDataSingle(entity: "Transactions", query: queryDelete)
            }
            checkForInitialTransactionDuplicates()
        }
    }
    
    // MARK: -ORIENTATION
    // set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }
    
    // MARK: - Core Data stack
//    lazy var persistentContainer: NSPersistentCloudKitContainer = {
//        /*
//         The persistent container for the application. This implementation
//         creates and returns a container, having loaded the store for the
//         application to it. This property is optional since there are legitimate
//         error conditions that could cause the creation of the store to fail.
//        */
//        let container = NSPersistentCloudKitContainer(name: "FIN")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//
//                /*
//                 Typical reasons for an error here include:
//                 * The parent directory does not exist, cannot be created, or disallows writing.
//                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                 * The device is out of space.
//                 * The store could not be migrated to the current model version.
//                 Check the error message to determine what the actual problem was.
//                 */
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()

//    lazy var persistentLocalContainer: NSPersistentContainer = {
//        /*
//         The persistent container for the application. This implementation
//         creates and returns a container, having loaded the store for the
//         application to it. This property is optional since there are legitimate
//         error conditions that could cause the creation of the store to fail.
//        */
//        let container = NSPersistentContainer(name: "FIN_local")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//
//                /*
//                 Typical reasons for an error here include:
//                 * The parent directory does not exist, cannot be created, or disallows writing.
//                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                 * The device is out of space.
//                 * The store could not be migrated to the current model version.
//                 Check the error message to determine what the actual problem was.
//                 */
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
//
//    func saveContext () {
//        let context = persistentLocalContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }

    
    // MARK: - Core Data Saving support
}

// Has to be added, to show Notifications while App is in Foreground
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent
            notification: UNNotification, withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void) {

            // show alert while app is running in foreground
        return completionHandler(UNNotificationPresentationOptions.banner)
        }
}

struct AppUtility {

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {

        self.lockOrientation(orientation)

        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
}
