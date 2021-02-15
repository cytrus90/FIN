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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Navbar customization
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        navigationBarAppearace.barTintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
//        navigationBarAppearace.backgroundColor = UIColor(red: 240/255, green: 243/255, blue: 255/255, alpha: 1.0)
//        navigationBarAppearace.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
//        navigationBarAppearace.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Load Login Settings
        UNUserNotificationCenter.current().delegate = self
        
        saveNewSettings()
                    
//        let numbersOpened = UserDefaults.standard.integer(forKey: "numbersOpened")
//        if numbersOpened % 3 == 0 {
//            checkForCategoryDuplicates()
//            checkTags()
//            // checkForTransactionDuplicates()
//        }
        checkForCategoryDuplicates()
        checkTags()
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
        
        let categoriesCountArray = loadDataGrouped(entitie: "Categories", groupByColumn: "cID") as? [[String:Any]]
        if (categoriesCountArray?.count ?? 0) > 0 {
            for i in 0...((categoriesCountArray?.count ?? 1)-1) {
                if categoriesCountArray?[i]["count"] as? Int64 ?? 0 > 1 {
                    duplicateIDs.append(categoriesCountArray?[i]["cID"] as? Int16 ?? 0)
                }
            }
        }
        
        if duplicateIDs.count > 0 {
            for duplicate in duplicateIDs {
                let nextID = loadNextCategoryID()
                let query = NSPredicate(format: "cID == %i", duplicate)
                saveSingleDataInt16(entity: "Categories", attibute: "cID", newValue: nextID, query: query, sort: [NSSortDescriptor(key: "createDate", ascending: false)])
            }
            checkForCategoryDuplicates()
        }
    }
    
    func checkTags() {
        for tag in loadBulk(entitie: "Tags") {
            let query = NSPredicate(format: "tags CONTAINS %@", (tag.value(forKey: "tagName") as? String ?? "*;*") as NSString)
            if (loadBulkDataWithQueryLimited(entitie: "Transactions", query: query).count <= 0) && (loadBulkDataWithQueryLimited(entitie: "RegularPayments", query: query).count <= 0) {
                let queryDelete = NSPredicate(format: "tagName == %@", (tag.value(forKey: "tagName") as? String ?? "*;*") as NSString)
                if loadBulkDataWithQueryLimited(entitie: "Tags", query: queryDelete).count == 1 {
                    deleteData(entity: "Tags", query: queryDelete)
                }
            }
        }
    }
    
    func checkForTransactionDuplicates() {
        var duplicateDates = [Date]()
        
        let transactionsCountArray = loadDataGrouped(entitie: "Transactions", groupByColumn: "dateTime") as? [[String:Any]]
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
                deleteDataSingle(entity: "Transactions", query: queryDelete)
            }
            checkForTransactionDuplicates()
        }
    }
    
    func checkForInitialTransactionDuplicates() {
        var duplicateInt = [Int16]()
        
        let transactionsCountArray = loadDataInitialTransactionsGrouped(entitie: "Transactions", groupByColumn: "categoryID") as? [[String:Any]]
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
                deleteDataSingle(entity: "Transactions", query: queryDelete)
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
    
    // MARK: -DATA
    
    // MARK: SETTINGS
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
    
    func loadDataSorted(entitie:String, query: NSPredicate, sortBy: [NSSortDescriptor]) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        fetchRequest.sortDescriptors = sortBy
        
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return [NSManagedObject]()
    }
    
    func loadBulkDataWithQueryLimited(entitie:String, query:NSPredicate) -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        fetchRequest.fetchLimit = 1
        
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return [NSManagedObject]()
    }
    
    func saveNewSettings() {
        let countSettings = loadBulk(entitie: "Settings").count
        if countSettings <= 0 {
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
    
    func saveSingleDataInt16(entity:String, attibute: String, newValue: Int16, query: NSPredicate, sort: [NSSortDescriptor]) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        fetchRequest.sortDescriptors = sort
        
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                if data.value(forKey: attibute) != nil {
                    let managedObject = data
                    managedObject.setValue(newValue, forKey: attibute)
                    try managedContext.save()
                    break
                }
            }
        } catch {
            print("ERROR. \(error)")
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
    
    func loadDataInitialTransactionsGrouped(entitie:String, groupByColumn:String) -> Any {
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
        fetchRequest.predicate = NSPredicate(format: "dateTime == nil")
        
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
    
    func deleteData(entity: String, query: NSPredicate) {
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
    
    func deleteDataSingle(entity: String, query: NSPredicate) {
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
                break
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
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "FIN")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var persistentLocalContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "FIN")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
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
