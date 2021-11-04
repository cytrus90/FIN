//
//  dataClass.swift
//  FIN
//
//  Created by Florian Riel on 13.07.21.
//  Copyright © 2021 Alpako. All rights reserved.
//

import Foundation
import CoreData

class dataClass {
    let persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "FIN")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        guard let containerStoreDescription = container.persistentStoreDescriptions.first else {
            fatalError("\(#function): Failed to retrieve a persistent store description.")
        }
        containerStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
//    lazy var managedObjectContext: NSManagedObjectContext = {
//        let coordinator = persistentContainer.persistentStoreCoordinator
//        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        managedObjectContext.persistentStoreCoordinator = coordinator
//        return managedObjectContext
//    }()
    
//    func saveContext () {
//        let context = persistentContainer.viewContext
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
    
    // MARK: -LOAD
    func loadDataBulk(entity:String) -> [NSManagedObject] {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func loadBulk(entitie:String) -> [NSManagedObject] {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func loadBulkData(entitie:String, orderBy:String) -> [NSManagedObject] {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: orderBy, ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
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
    
    func loadDataSorted(entitie:String, query: NSPredicate, sortBy: [NSSortDescriptor]) -> [NSManagedObject] {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func loadBulkSorted(entitie:String, sort:[NSSortDescriptor]) -> [NSManagedObject] {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func loadBulkQueried(entitie:String, query:NSPredicate) -> [NSManagedObject] {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
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
    
    func loadBulkQueriedSorted(entitie:String, query:NSPredicate, sort:[NSSortDescriptor]) -> [NSManagedObject] {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = sort
        fetchRequest.predicate = query
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
    
    func loadData(entitie:String, attibute:String) -> Any {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func loadBulkSortedForMaxMinDate(entitie:String, sort:[NSSortDescriptor]) -> [NSManagedObject] {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "dateTime != nil")
        fetchRequest.sortDescriptors = sort
        fetchRequest.fetchLimit = 1
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
    
    func loadDataSUM(entitie:String, query:NSPredicate) -> Any {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let keypathExp1 = NSExpression(forKeyPath: "realAmount") // can be any column
        let expression1 = NSExpression(forFunction: "sum:", arguments: [keypathExp1])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression1
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToFetch = [sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let loadData = try managedContext.fetch(fetchRequest)
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return false
    }
    
    func loadDataSUMEntries(entitie:String, query:NSPredicate) -> Any {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let keypathExp1 = NSExpression(forKeyPath: "countEntries") // can be any column
        let expression1 = NSExpression(forFunction: "sum:", arguments: [keypathExp1])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression1
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToFetch = [sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let loadData = try managedContext.fetch(fetchRequest)
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return false
    }
    
    func loadDataGroupedSUM(entitie:String, groupByColumn:String, query:NSPredicate) -> Any {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let keypathExp1 = NSExpression(forKeyPath: "realAmount") // can be any column
        let expression1 = NSExpression(forFunction: "sum:", arguments: [keypathExp1])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression1
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        
        let keypathExp2 = NSExpression(forKeyPath: groupByColumn) // can be any column
        let expression2 = NSExpression(forFunction: "count:", arguments: [keypathExp2])
        
        let countDesc = NSExpressionDescription()
        countDesc.expression = expression2
        countDesc.name = "count"
        countDesc.expressionResultType = .integer64AttributeType
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = [groupByColumn]
        fetchRequest.propertiesToFetch = [groupByColumn, countDesc ,sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let loadData = try managedContext.fetch(fetchRequest)
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return false
    }
    
    func loadBulkQueriedSortedUser(query:NSPredicate) -> Bool {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Splits")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
//        fetchRequest.fetchLimit = 1
        
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if loadData.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            print("Could not fetch. \(error)")
        }
        return false
    }
    
    func loadBulkDataWithQuery(entitie:String, query:NSPredicate) -> [NSManagedObject] {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return [NSManagedObject]()
    }
    
    func loadBulkDataWithQuery(entitie:String, query:NSPredicate, sort:[NSSortDescriptor]) -> [NSManagedObject] {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        fetchRequest.sortDescriptors = sort
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return [NSManagedObject]()
    }
    
    func loadBulkDataSorted(entitie:String, sort:[NSSortDescriptor]) -> [NSManagedObject] {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = sort
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return [NSManagedObject]()
    }
    
    func loadBulkDataWithQueryLimited(entitie:String, query:NSPredicate) -> [NSManagedObject] {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func loadQueriedAttribute(entitie:String, attibute:String, query:NSPredicate) -> Any {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func loadQueriedAttributeSorted(entitie:String, attibute:String, query:NSPredicate, sort:[NSSortDescriptor]) -> Any {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        fetchRequest.sortDescriptors = sort
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
    
    func loadBulkSortedOneEntry(entitie:String, sort:[NSSortDescriptor]) -> Any {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "dateTime != nil")
        fetchRequest.sortDescriptors = sort
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if loadData.count > 0 {
                return loadData[0]
            }
        } catch {
            print("Could not fetch. \(error)")
        }
        return false
    }
    
    func loadBulkQueriedSortedCount(entitie:String, query:NSPredicate, sort:[NSSortDescriptor]) -> [NSManagedObject] {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = sort
        fetchRequest.predicate = query
        fetchRequest.fetchLimit = 1
        
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
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func loadDataGroupedQueriedSorted(entitie:String, groupByColumn:String, query:NSPredicate, sort:[NSSortDescriptor]) -> Any {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
        fetchRequest.predicate = query
        fetchRequest.sortDescriptors = sort
        
        do {
            let loadData = try managedContext.fetch(fetchRequest)
            return loadData
        } catch {
            print("Could not fetch. \(error)")
        }
        return false
    }
    
    func loadDataInitialTransactionsGrouped(entitie:String, groupByColumn:String) -> Any {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
        
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func loadFirstCategory() -> Int16 {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        fetchRequest.fetchLimit = 1
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if loadData.count > 0 {
                return loadData[0].value(forKey: "cID") as? Int16 ?? -1
            }
        } catch {
            print("Could not fetch. \(error)")
        }
        return -1
    }
    
    func isUser(createDate:Date, namePerson:String) -> Bool {
        let plusCreateDate = Calendar.current.date(byAdding: .second, value: 1, to: createDate)!
        let minusCreateDate = Calendar.current.date(byAdding: .second, value: -1, to: createDate)!
        
        let query = NSPredicate(format: "createDate < %@ AND createDate > %@ AND namePerson == %@", (plusCreateDate as NSDate), (minusCreateDate as NSDate) , (namePerson as NSString))
        
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SplitPersons")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                if data.value(forKey: "isUser") != nil {
                    return data.value(forKey: "isUser") as? Bool ?? false
                }
            }
        } catch {
            print("Could not fetch. \(error)")
        }
        
        return false
    }
    
    
    
    func loadIfBudget() -> Bool {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "budget != nil AND budget > %f", 0.01)
        fetchRequest.fetchLimit = 1
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if loadData.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            print("Could not fetch. \(error)")
        }
        return false
    }
    
    // MARK: LOAD SETTINGS
    func loadSettings(entitie:String, attibute:String) -> Any {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func loadSettingsFirstLaunch() {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Settings")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let settings = try managedContext.fetch(fetchRequest)
            if settings.count > 0 {
                saveSettings(settingsChange: "firstLaunch", newValue: false)
                saveSettings(settingsChange: "firstLaunchDate", newValue: Date())
            } else {
                saveNewInitialSettings()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func loadSettingsOldest(entitie:String, attibute:String) -> Any {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func loadBulkQueriedLimited(entitie:String, query: NSPredicate) -> [NSManagedObject] {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entitie)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        fetchRequest.fetchLimit = 2
        
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
    
    // MARK: -SAVE
    
    func saveQueriedAttributeReturn(entity: String, attribute: String, query: NSPredicate ,value: Any) -> Bool {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        do {
            let fetchedData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if fetchedData.count > 1 || fetchedData.count <= 0 {
                return false
            } else {
                fetchedData[0].setValue(value, forKey: attribute)
                try managedContext.save()
                return true
            }
        } catch {
            fatalError("Failed to fetch recordings: \(error)")
        }
    }
    
    // MARK: SAVE CURRENCY
    func saveCurrency(currencyCode: String, exchangeRate: Double?, automated: Bool, id: Int16) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let currencySave = Currency(context: managedContext)
        
        currencySave.currencyCode = currencyCode
        currencySave.exchangeRate = exchangeRate ?? 1.0
        currencySave.automated = automated
        currencySave.saved = Date()
        currencySave.id = id
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: SAVE GRAPHS
    func saveNewGraphs() {
        deleteDataBulk(entity: "GraphSettings")
        for i in 0...2 {
            var managedContext:NSManagedObjectContext {
                persistentContainer.viewContext
            }
            let graphSave = GraphSettings(context: managedContext)
            
            graphSave.graphID = Int16(i)
            if i == 0 {
                graphSave.graphName = NSLocalizedString("lineChartTitle", comment: "Line Cahrt")
                graphSave.graphActive = false
            } else if i == 1 {
                graphSave.graphName = NSLocalizedString("pieChartTitle", comment: "Pie Chart")
                graphSave.graphActive = false
            } else if i == 2 {
                graphSave.graphName = NSLocalizedString("barChartTitle", comment: "Bar Chart")
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
    
    // MARK: SAVE SETTINGS
    func saveNewSettings() {
        let countSettings = loadDataBulk(entity: "Settings").count
        if countSettings <= 0 {
            var managedContext:NSManagedObjectContext {
                persistentContainer.viewContext
            }
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
    
    func saveNewInitialSettings() {
        let countSettings = loadDataBulk(entity: "Settings").count
        var firstDate = Date()
        var showAddsRAM:Bool = true
        var trueUserName = NSLocalizedString("userTitle", comment: "User")
    
        let loginEnabledSafe = false
        var firstLaunch = true
//        var filteredTagsZero = false
//        var filteredCategoriesZero = false
        var recoveryMail = ""
        var lastCurrencyCodeSafe = Locale.current.currencyCode ?? "EUR"
        var userColorSafe = Int16(0)
//        var userCodeSafe = ""
        
        if countSettings > 1 {
            trueUserName = loadSettingsOldest(entitie: "Settings", attibute: "userName") as? String ?? NSLocalizedString("userTitle", comment: "User")
            firstDate = loadSettingsOldest(entitie: "Settings", attibute: "firstLaunchDate") as? Date ?? Date()
            showAddsRAM = loadSettingsOldest(entitie: "Settings", attibute: "showAdds") as? Bool ?? true
//            loginEnabledSafe = loadSettingsOldest(entitie: "Settings", attibute: "loginEnabled") as? Bool ?? false
            firstLaunch = loadSettingsOldest(entitie: "Settings", attibute: "firstLaunch") as? Bool ?? false
//            filteredTagsZero = loadSettingsOldest(entitie: "Settings", attibute: "filteredTagsZero") as? Bool ?? false
//            filteredCategoriesZero = loadSettingsOldest(entitie: "Settings", attibute: "filteredCategoriesZero") as? Bool ?? false
            recoveryMail = loadSettingsOldest(entitie: "Settings", attibute: "recoveryMail") as? String ?? ""
            lastCurrencyCodeSafe = loadSettingsOldest(entitie: "Settings", attibute: "lastCurrencyCode") as? String ?? ""
            userColorSafe = loadSettingsOldest(entitie: "Settings", attibute: "userColor") as? Int16 ?? 0
//            userCodeSafe = loadSettingsOldest(entitie: "Settings", attibute: "userCode") as? String ?? ""
            
            deleteDataBulk(entity: "Settings")
        }
        
        let countSettings2 = loadDataBulk(entity: "Settings").count
        if countSettings2 <= 0 {
            var managedContext:NSManagedObjectContext {
                persistentContainer.viewContext
            }
            let settingsSave = Settings(context: managedContext)
            
//            settingsSave.userCode = ""
            settingsSave.showAdds = true
            settingsSave.firstLaunchDate = Date()
                
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
        if countSettings > 1 {
            saveSettings(settingsChange: "firstLaunch", newValue: false)
            saveSettings(settingsChange: "firstLaunchDate", newValue: firstDate)
            saveSettings(settingsChange: "showAdds", newValue: showAddsRAM)
            saveSettings(settingsChange: "userName", newValue: trueUserName)
            saveSettings(settingsChange: "loginEnabled", newValue: loginEnabledSafe)
            saveSettings(settingsChange: "firstLaunch", newValue: firstLaunch)
//            saveSettings(settingsChange: "filteredTagsZero", newValue: filteredTagsZero)
//            saveSettings(settingsChange: "filteredCategoriesZero", newValue: filteredCategoriesZero)
            saveSettings(settingsChange: "recoveryMail", newValue: recoveryMail)
            saveSettings(settingsChange: "lastCurrencyCode", newValue: lastCurrencyCodeSafe)
            saveSettings(settingsChange: "userColor", newValue: userColorSafe)
//            saveSettings(settingsChange: "userCode", newValue: userCodeSafe)
        }
    }
    
    func saveSettings(settingsChange: String, newValue: Any) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    // MARK: SAVE GENERAL
    func saveSingleData(entity:String, attibute: String, newValue: Any, query: NSPredicate) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                let managedObject = data
                managedObject.setValue(newValue, forKey: attibute)
                try managedContext.save()
                break
            }
        } catch {
            print("ERROR. \(error)")
        }
    }
    
    func saveSingleDataInt16(entity:String, attibute: String, newValue: Int16, query: NSPredicate, sort: [NSSortDescriptor]) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func saveSingleDataInt64(entity:String, attibute: String, newValue: Int64, query: NSPredicate) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                if data.value(forKey: attibute) != nil {
                    let managedObject = data
                    managedObject.setValue(newValue, forKey: attibute)
                    try managedContext.save()
                }
            }
        } catch {
            print("ERROR. \(error)")
        }
    }
    
    func saveSingleDataInt(entity:String, attibute: String, newValue: Int, query: NSPredicate) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query

        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                if data.value(forKey: attibute) != nil {
                    let managedObject = data
                    managedObject.setValue(newValue, forKey: attibute)
                    try managedContext.save()
                }
            }
        } catch {
            print("ERROR. \(error)")
        }
    }
    
    func saveSingleDataDouble(entity:String, attibute: String, newValue: Double, query: NSPredicate) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query

        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                if data.value(forKey: attibute) != nil {
                    let managedObject = data
                    managedObject.setValue(newValue, forKey: attibute)
                    try managedContext.save()
                }
            }
        } catch {
            print("ERROR. \(error)")
        }
    }
    
    func saveSingleDataString(entity:String, attibute: String, newValue: String, query: NSPredicate) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                if data.value(forKey: attibute) != nil {
                    let managedObject = data
                    managedObject.setValue(newValue, forKey: attibute)
                    try managedContext.save()
                }
            }
        } catch {
            print("ERROR. \(error)")
        }
    }
    
    func saveSingleInt(entity:String, attibute: String, newValue: Int64, query: NSPredicate) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                if data.value(forKey: attibute) != nil {
                    let managedObject = data
                    managedObject.setValue(newValue, forKey: attibute)
                    try managedContext.save()
                }
            }
        } catch {
            print("ERROR. \(error)")
        }
    }
    
    func saveSingleDate(entity:String, attibute: String, newValue: Date, query: NSPredicate) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        
        do {
            let loadData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in loadData {
                if data.value(forKey: attibute) != nil {
                    let managedObject = data
                    managedObject.setValue(newValue, forKey: attibute)
                    try managedContext.save()
                }
            }
        } catch {
            print("ERROR. \(error)")
        }
    }
    
    func saveInitialTransaction(amount: Double, isSave: Bool, categoryID: Int16, uuid:UUID = UUID()) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let transactionSave = Transactions(context: managedContext)
        
        transactionSave.amount = amount
        transactionSave.realAmount = amount
        transactionSave.categoryID = categoryID
        transactionSave.currencyCode = Locale.current.currencyCode ?? "EUR"
        transactionSave.dateTime = nil
        transactionSave.descriptionNote = "Initial"
        transactionSave.exchangeRate = 1.0
        transactionSave.tags = ""
        transactionSave.isSave = isSave
        transactionSave.isSplit = 0
        transactionSave.isLiquid = !isSave
        transactionSave.uuid = uuid
                
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return
        }
    }
    
    func saveInitialTransaction(amount: Double, descriptionNote: String?,isSave: Bool = false, isLiquid:Bool = true, uuid:UUID = UUID()) -> Bool {
        let currencyCodeSave = Locale.current.currencyCode ?? "EUR"
        let isSplit:Int16 = 0

        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let transactionSave = Transactions(context: managedContext)
        
        transactionSave.amount = amount
        transactionSave.realAmount = amount
        transactionSave.categoryID = 0
        transactionSave.currencyCode = currencyCodeSave
        transactionSave.dateTime = nil
        transactionSave.descriptionNote = descriptionNote ?? ""
        transactionSave.exchangeRate = 1.0
        transactionSave.tags = ""
        transactionSave.isSave = isSave
        transactionSave.isSplit = isSplit
        transactionSave.isLiquid = isLiquid
        transactionSave.uuid = uuid
                
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    func saveTransaction(amount: Double, realAmount:Double, category: Int16, currencyCode: String, dateTime: Date, descriptionNote: String, exchangeRate: Double, tags: String, isSave: Bool = false, isLiquid:Bool, isSplit:Int16, uuid:UUID) -> Bool {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let transactionSave = Transactions(context: managedContext)
        
        transactionSave.amount = amount
        transactionSave.realAmount = realAmount
        transactionSave.categoryID = category
        transactionSave.currencyCode = currencyCode
        transactionSave.dateTime = dateTime
        transactionSave.descriptionNote = descriptionNote
        transactionSave.exchangeRate = exchangeRate
        transactionSave.tags = tags
        transactionSave.isSave = isSave
        transactionSave.isSplit = isSplit
        transactionSave.isLiquid = isLiquid
        transactionSave.uuid = uuid
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    func saveSplit(createDateGroup: Date, createDatePerson: Date, createDatePersonWhoPaid:Date, dateTimeTransaction: Date, nameGroup: String, namePerson: String, namePersonWhoPaid:String, paidByUser:Bool, ratio:Double, settled:Double, uuid:UUID = UUID()) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let splitSave = Splits(context: managedContext)
        
        splitSave.createDateGroup = createDateGroup
        splitSave.createDatePerson = createDatePerson
        splitSave.createDatePersonWhoPaid = createDatePersonWhoPaid
        splitSave.dateTimeTransaction = dateTimeTransaction
        splitSave.nameGroup = nameGroup
        splitSave.namePerson = namePerson
        splitSave.namePersonWhoPaid = namePersonWhoPaid
        splitSave.paidByUser = paidByUser
        splitSave.ratio = ratio
        splitSave.settled = settled
        splitSave.uuid = uuid
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveCategory(name: String, color: Int16 = 0, countEntries: Int64 = 0, isIncome: Bool, isSave: Bool, icon: String?) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let categorySave = Categories(context: managedContext)
        let id = loadNextCategoryID()
        
        categorySave.cID = id
        categorySave.order = id
        categorySave.name = name
        categorySave.color = color
        categorySave.countEntries = countEntries
        categorySave.isIncome = isIncome
        categorySave.isSave = isSave
        categorySave.createDate = Date()
        categorySave.icon = icon
        categorySave.iconLight = true
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveCategoryWithID(name: String, color: Int16 = 0, countEntries: Int64 = 0, isIncome: Bool, isSave: Bool) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let categorySave = Categories(context: managedContext)
        
        categorySave.cID = Int16(2)
        categorySave.name = name
        categorySave.color = color
        categorySave.countEntries = countEntries
        categorySave.isIncome = isIncome
        categorySave.isSave = isSave
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // No Icon
    func saveCategory(name: String, color: Int16 = 0, countEntries: Int64 = 0, isIncome: Bool, isSave: Bool) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let categorySave = Categories(context: managedContext)
        let id = loadNextCategoryID()
        
        categorySave.cID = id
        categorySave.name = name
        categorySave.color = color
        categorySave.countEntries = countEntries
        categorySave.isIncome = isIncome
        categorySave.isSave = isSave
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveQueriedAttributeMultiple(entity: String, attribute: String, query: NSPredicate ,value: Any) { // HERE ERROR
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        do {
            let fetchedData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if fetchedData.count <= 0 {
                return
            } else {
                for data in fetchedData {
                    data.setValue(value, forKey: attribute)
                }
                try managedContext.save()
            }
        } catch {
            fatalError("Failed to fetch recordings: \(error)")
        }
    }
    
    func saveQueriedAttribute(entity: String, attribute: String, query: NSPredicate ,value: Any) -> Bool {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = query
        do {
            let fetchedData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if fetchedData.count > 1 || fetchedData.count <= 0 {
                return false
            } else {
                fetchedData[0].setValue(value, forKey: attribute)
                try managedContext.save()
                return true
            }
        } catch {
            fatalError("Failed to fetch recordings: \(error)")
        }
    }
    
    func initUserSplitPerson() {
        if (loadBulkData(entitie: "SplitPersons", orderBy: "createDate")).count <= 0 {
            var managedContext:NSManagedObjectContext {
                persistentContainer.viewContext
            }
            let userSplitPersonSave = SplitPersons(context: managedContext)
            
            userSplitPersonSave.isUser = true
            userSplitPersonSave.createDate = Date()
            userSplitPersonSave.color = Int16(21)
            userSplitPersonSave.namePerson = loadSettings(entitie: "Settings", attibute: "userName") as? String ?? "User"
            userSplitPersonSave.uuid = UUID()
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func saveBulk(entity: String, attribute: String, value: Any) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let fetchedData = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if fetchedData.count > 1 || fetchedData.count <= 0 {
                return
            } else {
                for data in fetchedData {
                    data.setValue(value, forKey: attribute)
                }
                try managedContext.save()
            }
        } catch {
            fatalError("Failed to fetch recordings: \(error)")
        }
    }
    
    func saveRAMTransaction(amount: Double, realAmount:Double, category: String, currencyCode: String?, dateTime: Date, descriptionNote: String?, exchangeRate: Double = 1.0, cID: Int16, isSave: Bool) {
        let currencyCodeSave: String?
        if currencyCode == nil {
            currencyCodeSave = Locale.current.currencyCode ?? "EUR"
        } else {
            currencyCodeSave = currencyCode
        }

        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    // MARK: -DELETE
    func deleteDataBulk(entity: String) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func deleteData(entity: String, query: NSPredicate) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func deleteData(entity: String) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func deleteDataSingle(entity: String, query: NSPredicate) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func deleteDataQueried(entity: String, query: NSPredicate) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
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
    
    func deleteDataReturn(entity: String, query: NSPredicate) -> Bool {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = query
        do {
            let delete = try managedContext.fetch(fetchRequest)
            for data in delete {
                managedContext.delete(data as! NSManagedObject)
            }
            do {
                try managedContext.save()
                return true
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                return false
            }
        } catch {
            print(error)
            return false
        }
    }
    
    // MARK: -ADDVC
    // MARK: SAVE
    func saveTransaction(amount: Double, category: Int16, currencyCode: String?, dateTime: Date?, descriptionNote: String?, exchangeRate: Double = 1.0, tags: String?, isSave: Bool = false, isLiquid:Bool, uuid:UUID) -> (Bool,Date?) {
        let currencyCodeSave: String?
        if currencyCode == nil {
            currencyCodeSave = Locale.current.currencyCode ?? "EUR"
        } else {
            currencyCodeSave = currencyCode
        }
        var isSplit:Int16 = 0
        if split.count != 0 {
            isSplit = saveSplit(dateTime: dateTime ?? Date())
        }

        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let transactionSave = Transactions(context: managedContext)
        
        transactionSave.amount = amount
        transactionSave.categoryID = category
        transactionSave.currencyCode = currencyCodeSave ?? ""
        transactionSave.dateTime = dateTime ?? Date()
        transactionSave.descriptionNote = descriptionNote ?? ""
        transactionSave.exchangeRate = exchangeRate
        transactionSave.tags = tags ?? ""
        transactionSave.isSave = isSave
        transactionSave.isSplit = isSplit
        transactionSave.isLiquid = isLiquid
        transactionSave.uuid = uuid
        
        let transactionDateTime = transactionSave.dateTime
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return (false,nil)
        }
        return (true,transactionDateTime)
    }
    
    func saveSplit(dateTime:Date) -> Int16 {
        var groupSplit:Bool = false
        for (_,value) in split.enumerated() {
            // 0: namePerson
            // 1: createDatePerson
            // 2: nameGroup
            // 3: createDateGroup
            // 4: namePersonWhoPaid
            // 5: createDatePersonWhoPaid
            // 6: paidByUser
            // 7: ratio
            // 8: settled
            // 9: isUser
            
            let namePerson = value.value[0] ?? ""
            let createDatePerson = value.value[1] ?? Date()
            let nameGroup = value.value[2] ?? ""
            let createDateGroup = value.value[3] ?? nil
            let namePersonWhoPaid = value.value[4] ?? ""
            let createDatePersonWhoPaid = value.value[5] ?? Date()
            let paidByUser = value.value[6] ?? false
            let ratio = value.value[7] ?? 0.00
            let settled = value.value[8] ?? 0.00
            
            if ((nameGroup as? String)?.count ?? 0) > 0 {
                groupSplit = true
            }
            
            var managedContext:NSManagedObjectContext {
                persistentContainer.viewContext
            }

            let splitSave = Splits(context: managedContext)
            
            splitSave.namePerson = namePerson as? String ?? ""
            splitSave.createDatePerson = createDatePerson as? Date ?? Date()
            splitSave.nameGroup = nameGroup as? String ?? ""
            splitSave.createDateGroup = createDateGroup as? Date ?? nil
            splitSave.namePersonWhoPaid = namePersonWhoPaid as? String ?? ""
            splitSave.createDatePersonWhoPaid = createDatePersonWhoPaid as? Date ?? Date()
            splitSave.paidByUser = paidByUser as? Bool ?? false
            splitSave.ratio = ratio as? Double ?? 0.00
            splitSave.settled = settled as? Double ?? 0.00
            splitSave.dateTimeTransaction = dateTime
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        if groupSplit {
            return Int16(2)
        } else {
            return Int16(1)
        }
    }
    
    func saveRepeatTransaction(amount: Double, category: Int16, currencyCode: String?, dateTimeNext: Date, descriptionNote: String?, exchangeRate: Double = 1.0, tags: String?, isSave: Bool = false, isLiquid:Bool, repeatFrequency: Int, skipWeekends: Bool, dateTimeNextOriginal: Date) {
        let currencyCodeSave: String?
        if currencyCode == nil {
            currencyCodeSave = Locale.current.currencyCode ?? "EUR"
        } else {
            currencyCodeSave = currencyCode
        }
        var isSplit:Int16 = 0
        if split.count != 0 {
            isSplit = saveRepeatSplit(dateTime: dateTimeNext)
        }

        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let transactionRepeatSave = RegularPayments(context: managedContext)
        
        transactionRepeatSave.amount = amount
        transactionRepeatSave.categoryID = category
        transactionRepeatSave.currencyCode = currencyCodeSave ?? ""
        transactionRepeatSave.dateTimeNext = dateTimeNext
        transactionRepeatSave.dateTimeNextOriginal = dateTimeNextOriginal
        transactionRepeatSave.descriptionNote = descriptionNote ?? ""
        transactionRepeatSave.exchangeRate = exchangeRate
        transactionRepeatSave.tags = tags ?? ""
        transactionRepeatSave.isSave = isSave
        transactionRepeatSave.isSplit = isSplit
        transactionRepeatSave.isLiquid = isLiquid
        transactionRepeatSave.frequency = Int16(repeatFrequency)
        transactionRepeatSave.skipWeekends = skipWeekends
                
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveTransaction(amount: Double, realAmount:Double, category: Int16, currencyCode: String?, dateTime: Date?, descriptionNote: String?, exchangeRate: Double = 1.0, tags: String?, isSave: Bool = false) {
        let currencyCodeSave: String?
        if currencyCode == nil {
            currencyCodeSave = Locale.current.currencyCode ?? "EUR"
        } else {
            currencyCodeSave = currencyCode
        }

        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let transactionSave = Transactions(context: managedContext)
        
        transactionSave.amount = amount
        transactionSave.realAmount = realAmount
        transactionSave.categoryID = category
        transactionSave.currencyCode = currencyCodeSave ?? ""
        transactionSave.dateTime = dateTime ?? Date()
        transactionSave.descriptionNote = descriptionNote ?? ""
        transactionSave.exchangeRate = exchangeRate
        transactionSave.tags = tags ?? ""
        transactionSave.isSave = isSave
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveRepeatSplit(dateTime:Date) -> Int16 {
        var groupSplit:Bool = false
        for (_,value) in split.enumerated() {
            // 0: namePerson
            // 1: createDatePerson
            // 2: nameGroup
            // 3: createDateGroup
            // 4: namePersonWhoPaid
            // 5: createDatePersonWhoPaid
            // 6: paidByUser
            // 7: ratio
            // 8: settled
            // 9: isUser

            let namePerson = value.value[0] ?? ""
            let createDatePerson = value.value[1] ?? Date()
            let nameGroup = value.value[2] ?? ""
            let createDateGroup = value.value[3] ?? nil
            let namePersonWhoPaid = value.value[4] ?? ""
            let createDatePersonWhoPaid = value.value[5] ?? Date()
            let paidByUser = value.value[6] ?? false
            let ratio = value.value[7] ?? 0.00
            let settled = value.value[8] ?? 0.00

            if ((nameGroup as? String)?.count ?? 0) > 0 {
                groupSplit = true
            }

            var managedContext:NSManagedObjectContext {
                persistentContainer.viewContext
            }
            let splitRepeatSave = SplitsRegularPayments(context: managedContext)

            splitRepeatSave.namePerson = namePerson as? String ?? ""
            splitRepeatSave.createDatePerson = createDatePerson as? Date ?? Date()
            splitRepeatSave.nameGroup = nameGroup as? String ?? ""
            splitRepeatSave.createDateGroup = createDateGroup as? Date ?? nil
            splitRepeatSave.namePersonWhoPaid = namePersonWhoPaid as? String ?? ""
            splitRepeatSave.createDatePersonWhoPaid = createDatePersonWhoPaid as? Date ?? Date()
            splitRepeatSave.paidByUser = paidByUser as? Bool ?? false
            splitRepeatSave.ratio = ratio as? Double ?? 0.00
            splitRepeatSave.settled = settled as? Double ?? 0.00
            splitRepeatSave.dateTimeTransaction = dateTime

            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        if groupSplit {
            return Int16(2)
        } else {
            return Int16(1)
        }
    }
    
    func saveTag(tagName: String, tagColor: Int16, selectedForFilter: Bool = true, lastUsed: Date = Date()) {
        var managedContext:NSManagedObjectContext {
            persistentContainer.viewContext
        }
        let tagSave = Tags(context: managedContext)
        
        tagSave.tagName = tagName
        tagSave.tagColor = tagColor
        tagSave.selectedForFilter = selectedForFilter
        tagSave.lastUsed = lastUsed
        tagSave.countEntries = 1
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func incrementCategoryCount(id: Int16, oldID: Int16 = -1, futureRepeatTransaction: Bool) -> Bool {
        if !futureRepeatTransaction {
            if id != oldID {
                var managedContext:NSManagedObjectContext {
                    persistentContainer.viewContext
                }
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Categories")
                fetchRequest.predicate = NSPredicate(format: "cID == \(id)")
                do {
                    let fetchedData = try managedContext.fetch(fetchRequest)
                    for data in fetchedData {
                        data.setValue(((data.value(forKey: "countEntries") as? Int64 ?? 0) + 1), forKey: "countEntries")
                    }
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                    return false
                }
                do {
                    try managedContext.save()
                    return true
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                    return false
                }
            } else {
                var managedContext:NSManagedObjectContext {
                    persistentContainer.viewContext
                }
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Categories")
                fetchRequest.predicate = NSPredicate(format: "cID == \(id) OR cID == \(oldID)")
                do {
                    let fetchedData = try managedContext.fetch(fetchRequest)
                    for data in fetchedData {
                        if (data.value(forKey: "cID") as? Int16 ?? -2) == id {
                            data.setValue(((data.value(forKey: "countEntries") as? Int64 ?? 0) + 1), forKey: "countEntries")
                        } else {
                            data.setValue(((data.value(forKey: "countEntries") as? Int64 ?? 0) - 1), forKey: "countEntries")
                        }
                    }
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                    return false
                }
                do {
                    try managedContext.save()
                    return true
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                    return false
                }
            }
        } else {
            return true
        }
    }
}
