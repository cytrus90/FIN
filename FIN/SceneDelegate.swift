//
//  SceneDelegate.swift
//  FIN
//
//  Created by Florian Riel on 22.06.20.
//  Copyright © 2020 Alpako. All rights reserved.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        // If this scene's self.window is nil then set a new UIWindow object to it.
        let userStoryBoard: UIStoryboard = UIStoryboard(name: "userTSB", bundle: nil)
        guard
            let splitViewController = userStoryBoard.instantiateViewController(withIdentifier: "userSplitVC") as? UISplitViewController,
            let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
            let userMasterVC = leftNavController.viewControllers.first as? userMasterVC,
            let userDetailVC = (splitViewController.viewControllers.last as? UINavigationController)?.topViewController as? userDetailVC
        else { fatalError() }

        userMasterVC.delegate = userDetailVC
        userDetailVC.navigationItem.leftItemsSupplementBackButton = true
        userDetailVC.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        
        if let shortcutItem = connectionOptions.shortcutItem {
            if shortcutItem.type == "info.alpako.fin.new" {
                openNewTransaction = true
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        let icon = UIApplicationShortcutIcon(type: .add)
        let item = UIApplicationShortcutItem(type: "info.alpako.fin.new", localizedTitle: NSLocalizedString("addNewTransactionTitle", comment: "Add new Title"), localizedSubtitle: "", icon: icon, userInfo: nil)
        
        var shortcutItems = UIApplication.shared.shortcutItems ?? []
        if shortcutItems.isEmpty {
            shortcutItems += [item]
        } else {
            if let mutableShortcutItem = shortcutItems.first?.mutableCopy() as? UIMutableApplicationShortcutItem {
                mutableShortcutItem.type = "info.alpako.fin.new"
                mutableShortcutItem.localizedTitle = NSLocalizedString("addNewTransactionTitle", comment: "Add new Title")
                mutableShortcutItem.icon = UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.add)
                shortcutItems[0] = mutableShortcutItem
            }
        }
        UIApplication.shared.shortcutItems = shortcutItems
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        // Load Login Settings
        if (localDataHandler.loadData(entitie: "SettingsLocal", attibute: "userCode") as? String ?? nil != nil) && (localDataHandler.loadData(entitie: "SettingsLocal", attibute: "userCode") as? String != "") && (localDataHandler.loadData(entitie: "SettingsLocal", attibute: "loginEnabled") as? Bool ?? false) {
            loginEnabled = true
            loginSuccessfull = false
            AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        } else {
            loginEnabled = false
            loginSuccessfull = true
            AppUtility.lockOrientation(.all)
        }
        filteredTagsZero = localDataHandler.loadLocalSettings(entitie: "SettingsLocal", attibute: "filteredTagsZero") as? Bool ?? false
        filteredCategoriesZero = localDataHandler.loadLocalSettings(entitie: "SettingsLocal", attibute: "filteredCategoriesZero") as? Bool ?? false
        
        regularPayments()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        dataHandler.saveContext()
        localDataHandler.saveContext()
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "info.alpako.fin.new" {
            openNewTransaction = true
        }
    }
    
    // MARK: -ADDITIONAL FUNCTIONS
    func regularPayments() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let query = NSPredicate(format: "dateTimeNext < %@", Date() as NSDate)
        
        let dummyDate = Calendar.current.date(from: DateComponents(calendar: Calendar.current, year: 1900, month: 1, day: 1, hour: 1, minute: 1, second: 1)) ?? Date()
        
        let regularPaymentsData = dataHandler.loadBulkQueriedSorted(entitie: "RegularPayments", query: query, sort: [NSSortDescriptor(key: "dateTimeNext", ascending: true)])
        
        if regularPaymentsData.count > 0 {
            for regularPayment in regularPaymentsData {
                let amount = regularPayment.value(forKey: "amount") as? Double ?? 0.00
                let categoryID = regularPayment.value(forKey: "categoryID") as? Int16 ?? 0
                let currencyCode = regularPayment.value(forKey: "currencyCode") as? String ?? "EUR"
                let dateTime = regularPayment.value(forKey: "dateTimeNext") as? Date ?? Date()
                let dateTimeOriginal = regularPayment.value(forKey: "dateTimeNextOriginal") as? Date ?? Date()
                let skipWeekends = regularPayment.value(forKey: "skipWeekends") as? Bool ?? true
                let descriptionNote = regularPayment.value(forKey: "descriptionNote") as? String ?? ""
                let exchangeRate = regularPayment.value(forKey: "exchangeRate") as? Double ?? 1.00
                let isLiquid = regularPayment.value(forKey: "isLiquid") as? Bool ?? true
                let isSave = regularPayment.value(forKey: "isSave") as? Bool ?? false
                let isSplit = regularPayment.value(forKey: "isSplit") as? Int16 ?? 0
                let realAmount = regularPayment.value(forKey: "realAmount") as? Double ?? 0.00
                let tags = regularPayment.value(forKey: "tags") as? String ?? ""
                let uuid = regularPayment.value(forKey: "uuid") as? UUID ?? UUID()
                
                let queryTransInDB = NSPredicate(format: "uuid == %@", uuid as CVarArg)
                if dataHandler.loadBulkQueried(entitie: "Transactions", query: queryTransInDB).count <= 0 {
                    if dataHandler.saveTransaction(amount: amount, realAmount: realAmount, category: categoryID, currencyCode: currencyCode, dateTime: dateTime, descriptionNote: descriptionNote, exchangeRate: exchangeRate, tags: tags, isSave: isSave, isLiquid: isLiquid, isSplit: isSplit, uuid: uuid) {
                        let dateTimePlus = Calendar.current.date(byAdding: .second, value: 1, to: dateTime)!
                        let dateTimeMinus = Calendar.current.date(byAdding: .second, value: -1, to: dateTime)!
                        
                        let querySplit = NSPredicate(format: "dateTimeTransaction < %@ AND dateTimeTransaction > %@", dateTimePlus as NSDate, dateTimeMinus as NSDate)
                        
                        for split in dataHandler.loadBulkQueriedSorted(entitie: "SplitsRegularPayments", query: querySplit, sort: [NSSortDescriptor(key: "dateTimeTransaction", ascending: true)]) {
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
                            nextDateTime = Calendar.current.date(byAdding: .day, value: 7, to: dateTimeOriginal)!
                            break
                        case 1: // Monthly
                            nextDateTime = Calendar.current.date(byAdding: .month, value: 1, to: dateTimeOriginal)!
                            break
                        case 2: // Yearly
                            nextDateTime = Calendar.current.date(byAdding: .year, value: 1, to: dateTimeOriginal)!
                            break
                        default: // Daily
                            nextDateTime = Calendar.current.date(byAdding: .day, value: 1, to: dateTimeOriginal)!
                            break
                        }
                        
                        nextDateTime = Calendar.current.date(from: DateComponents(calendar: Calendar.current, year: nextDateTime?.get(.year), month: nextDateTime?.get(.month), day: nextDateTime?.get(.day), hour: nextDateTime?.get(.hour), minute: nextDateTime?.get(.minute), second: nextDateTime?.get(.second)))
                        
                        let nextDateTimeOriginal = nextDateTime
                        
                        if skipWeekends {
                            if Calendar.current.dateComponents([.weekday], from: nextDateTime ?? dummyDate).weekday == 1 {
                                nextDateTime = Calendar.current.date(byAdding: .day, value: 1, to: nextDateTime ?? dummyDate)!
                            } else if Calendar.current.dateComponents([.weekday], from: nextDateTime ?? dummyDate).weekday == 7 {
                                nextDateTime = Calendar.current.date(byAdding: .day, value: 2, to: nextDateTime ?? dummyDate)!
                            }
                        }
                        
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
                        
                        dataHandler.saveQueriedAttributeMultiple(entity: "RegularPayments", attribute: "dateTimeNextOriginal", query: querySaveRegularPayment, value: nextDateTimeOriginal ?? dummyDate)
                        dataHandler.saveQueriedAttributeMultiple(entity: "RegularPayments", attribute: "dateTimeNext", query: querySaveRegularPayment, value: nextDateTime ?? dummyDate)
                        dataHandler.saveQueriedAttributeMultiple(entity: "RegularPayments", attribute: "uuid", query: querySaveRegularPayment, value: UUID())
                        dataHandler.saveQueriedAttributeMultiple(entity: "SplitsRegularPayments", attribute: "dateTimeTransaction", query: querySplit, value: nextDateTime ?? dummyDate)
                        
                        let manager = LocalNotificationManager()
                        
                        let longDate = DateFormatter()
                        longDate.dateFormat = "ddMMyyyyHHmmss"

                        let comps = Calendar.current.dateComponents([.year, .month, .day , .hour, .minute, .second], from: nextDateTime ?? Date())
                        let notificationMsg = NSLocalizedString("regularPaymentsTitle", comment: "Regular Payment") + ": " + (descriptionNote) + " " + NSLocalizedString("hasBeenAdded", comment: "has been added")
                        
                        manager.notifications = [LocalNotificationManager.Notification(id: longDate.string(from: nextDateTime ?? Date()), title: notificationMsg, datetime: comps)]
                        manager.schedule()
                        
                        break
                    }
                }
            }
            regularPayments()
        }
    }
}

