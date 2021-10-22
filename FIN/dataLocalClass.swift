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
}
