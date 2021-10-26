//
//  dataLocalClass.swift
//  FIN
//
//  Created by Florian Riel on 21.10.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import Foundation
import CoreData

class dataLocalClass {
    let persistentLocalContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FIN_local")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    func saveContext () {
        let context = persistentLocalContainer.viewContext
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
    
    // MARK: -GRAPH
    
    // MARK: SAVE GRAPHS
    func saveNewGraphs() {
        deleteDataBulk(entity: "GraphSettingsLocal")
        for i in 0...1 {
            let managedContext = persistentLocalContainer.viewContext
            
            managedContext.automaticallyMergesChangesFromParent = true
            managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
            let graphSave = GraphSettingsLocal(context: managedContext)
            
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
    
    // MARK: LOAD
    func loadDataBulk(entity:String) -> [NSManagedObject] {
        let managedContext = persistentLocalContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return [NSManagedObject]()
    }
    
    func loadBulkSorted(entitie:String, sort:[NSSortDescriptor]) -> [NSManagedObject] {
        let managedContext = persistentLocalContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = sort
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
    
    func loadQueriedAttribute(entitie:String, attibute:String, query:NSPredicate) -> Any {
        let managedContext = persistentLocalContainer.viewContext
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
    
    // MARK: SAVE
    func saveQueriedAttribute(entity: String, attribute: String, query: NSPredicate ,value: Any) {
        let managedContext = persistentLocalContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        do {
            let fetchedData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if fetchedData.count > 1 || fetchedData.count <= 0 {
                return
            } else {
                fetchedData[0].setValue(value, forKey: attribute)
                try managedContext.save()
                return
            }
        } catch {
            fatalError("Failed to fetch recordings: \(error)")
        }
    }
    
    // MARK: DELETE
    func deleteDataBulk(entity: String) {
        let managedContext = persistentLocalContainer.viewContext
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
    
    // MARK: -IMPORT DATA
    // MARK: SAVE
    func saveRAMTransaction(amount: Double, realAmount:Double, category: String, currencyCode: String?, dateTime: Date, descriptionNote: String?, exchangeRate: Double = 1.0, cID: Int16, isSave: Bool) {
        let currencyCodeSave: String?
        if currencyCode == nil {
            currencyCodeSave = Locale.current.currencyCode ?? "EUR"
        } else {
            currencyCodeSave = currencyCode
        }

        let managedContext = persistentLocalContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let importSave = ImportRAM(context: managedContext)
        
        importSave.amount = amount
        importSave.category = category
        importSave.currencyCode = currencyCodeSave ?? ""
        importSave.dateTime = dateTime
        importSave.descriptionNote = descriptionNote ?? ""
        importSave.exchangeRate = exchangeRate
        importSave.categoryID = cID
        importSave.realAmount = realAmount
        importSave.isSave = isSave
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: LOAD
    func loadBulkLocalSorted(entitie:String, sort:[NSSortDescriptor]) -> [NSManagedObject] {
        let managedContext = persistentLocalContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = sort
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
    
    // MARK: DELETE
    func deleteLocalData(entity: String) {
        let managedContext = persistentLocalContainer.viewContext
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
    
    // MARK: -SETTINGS
    func loadLocalSettingsFirstLaunch() {
        let managedContext = persistentLocalContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SettingsLocal")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let settings = try managedContext.fetch(fetchRequest)
            if settings.count > 0 {
                saveLocalSettings(settingsChange: "firstLaunch", newValue: false)
                saveLocalSettings(settingsChange: "firstLaunchDate", newValue: Date())
            } else {
                checkDoubleLocalSettings()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func loadLocalSettingsOldest(entitie:String, attibute:String) -> Any {
        let managedContext = persistentLocalContainer.viewContext
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
    
    func loadLocalSettings(entitie:String, attibute:String) -> Any {
        let managedContext = persistentLocalContainer.viewContext
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
    
    func loadData(entitie:String, attibute:String) -> Any {
        let managedContext = persistentLocalContainer.viewContext
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
    
    func saveLocalSettings(settingsChange: String, newValue: Any) {
        let managedContext = persistentLocalContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SettingsLocal")
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
    
    func checkDoubleLocalSettings() {
        let countSettings = loadDataBulk(entity: "SettingsLocal").count
        var firstDate = Date()
    
        let loginEnabledSafe = false
        var firstLaunch = true
        var filteredTagsZero = false
        var filteredCategoriesZero = false
        var lastCurrencyCodeSafe = Locale.current.currencyCode ?? "EUR"
        
        if countSettings > 1 {
            firstDate = loadLocalSettingsOldest(entitie: "SettingsLocal", attibute: "firstLaunchDate") as? Date ?? Date()
//            loginEnabledSafe = loadSettingsOldest(entitie: "SettingsLocal", attibute: "loginEnabled") as? Bool ?? false
            firstLaunch = loadLocalSettingsOldest(entitie: "SettingsLocal", attibute: "firstLaunch") as? Bool ?? false
            filteredTagsZero = loadLocalSettingsOldest(entitie: "SettingsLocal", attibute: "filteredTagsZero") as? Bool ?? false
            filteredCategoriesZero = loadLocalSettingsOldest(entitie: "SettingsLocal", attibute: "filteredCategoriesZero") as? Bool ?? false
            lastCurrencyCodeSafe = loadLocalSettingsOldest(entitie: "SettingsLocal", attibute: "lastCurrencyCode") as? String ?? ""
            
            deleteDataBulk(entity: "SettingsLocal")
        }
        
        let countSettings2 = loadDataBulk(entity: "SettingsLocal").count
        if countSettings2 <= 0 {
            let managedContext = persistentLocalContainer.viewContext
            managedContext.automaticallyMergesChangesFromParent = true
            managedContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
            let settingsSave = SettingsLocal(context: managedContext)
            
            settingsSave.userCode = ""
            settingsSave.firstLaunchDate = Date()
                
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
        if countSettings > 1 {
            saveLocalSettings(settingsChange: "firstLaunch", newValue: false)
            saveLocalSettings(settingsChange: "firstLaunchDate", newValue: firstDate)
            saveLocalSettings(settingsChange: "loginEnabled", newValue: loginEnabledSafe)
            saveLocalSettings(settingsChange: "firstLaunch", newValue: firstLaunch)
            saveLocalSettings(settingsChange: "filteredTagsZero", newValue: filteredTagsZero)
            saveLocalSettings(settingsChange: "filteredCategoriesZero", newValue: filteredCategoriesZero)
            saveLocalSettings(settingsChange: "lastCurrencyCode", newValue: lastCurrencyCodeSafe)
        }
    }
}
