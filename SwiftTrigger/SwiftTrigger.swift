//
//  SwiftTrigger.swift
//  SwiftTrigger
//
//  Created by Echo on 1/3/18.
//  Copyright © 2018 Echo. All rights reserved.
//

import Foundation
import CoreData

enum Entity: String {
  case CounterTask = "CounterTask"
}

public class SwiftTrigger {
  
  /**
   Subclass NSPersistentContainer to provide a customized
   storage path for core data database.
   */
  class MyPersistentContainer: NSPersistentContainer {
    override open class func defaultDirectoryURL() -> URL {
      let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
      let url = urls[urls.count - 1].appendingPathComponent("SwiftTriggerDB")
      return url
    }
  }

  private let databaseName = "SwiftTriggerModel"
  
  private lazy var persistentContainer: NSPersistentContainer? = {
    let bundleURL = Bundle(for: SwiftTrigger.self)
    let modelURL = bundleURL.url(forResource: databaseName, withExtension: "momd")

    var container: MyPersistentContainer
    
    guard let model = modelURL.flatMap(NSManagedObjectModel.init) else {
      print("Fail to load the trigger model!")
      return nil
    }
    
    container = MyPersistentContainer(name: databaseName, managedObjectModel: model)
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        print("Unresolved error \(error), \(error.userInfo)")
      }
    })
    
    return container
  }()
  
  private var managedObjectContext: NSManagedObjectContext?
  
  public init?() {
    managedObjectContext = persistentContainer?.viewContext
    
    guard managedObjectContext != nil else {
      print("Cann't get right managed object context.")
      return nil
    }
  }
}

// MARK - public methods
extension SwiftTrigger {
  public func clear(byId id: String) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.CounterTask.rawValue)
    fetchRequest.predicate = NSPredicate(format: "id == %@", id)
    
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }
  
  public func clearAll() {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.CounterTask.rawValue)
    
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }
  
  public func firstRunCheck(forId id: String, action:@escaping ()-> Void) {
    check(byId:id, targetCount:1, action: action)
  }
  
  public func check(byId id: String, targetCount: UInt, repeatTime: UInt = 1, action:@escaping ()-> Void) {
    if isPullTrigger(id, targetCount: targetCount, repeatTime: repeatTime) {
      action()
    }
  }
  
  public func reset(_ id: String, targetCount: UInt, repeatTime: UInt) {
    if let tasks = getTasks(id: id) {
      
      guard tasks.count > 0 else {
        return
      }
      
      let task = tasks[0]
      task.currentCount = 0
      task.currentRepeatTime = 0
      task.targetCount = Int32(targetCount)
      task.repeatTime = Int32(repeatTime)
      save()
    }
  }
  
  public func getCurrentRepeatTime(byId id: String) -> Int {
    if let tasks = getTasks(id: id) {
      
      guard tasks.count > 0 else {
        return 0
      }
      
      let task = tasks[0]
      return Int(task.currentRepeatTime)
    }
    
    return 0
  }
}

// MARK - private methods
extension SwiftTrigger {
  
  fileprivate func getTasks(id: String) -> [CounterTask]? {
    guard let managedObjectContext = managedObjectContext else {
      return nil
    }
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CounterTask")
    fetchRequest.predicate = NSPredicate(format: "id == %@", id)
    
    do {
      let fetchedResults = try managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
      
      guard fetchedResults != nil else {
        return nil
      }
      
      if let tasks = fetchedResults as? [CounterTask] {
        return tasks
      } else {
        return nil
      }
      
    } catch {
      print(error)
      return nil
    }
  }
  
  fileprivate func isPullTrigger(_ id: String, targetCount: UInt = 1, repeatTime: UInt = 1) -> Bool {
    if let tasks = getTasks(id: id) {
      guard tasks.count > 0 else {
        addNewTask(id: id, targetCount: targetCount, repeatTime: repeatTime)
        return targetCount == 1
      }
      
      return isPullTrigger(task: tasks[0])
    } else {
      return false
    }
  }
  
  fileprivate func isPullTrigger(task: CounterTask) -> Bool {
    guard task.valid else {
      return false
    }
    
    task.currentCount += 1
    var pullTrigger = false
    
    if(task.currentCount == task.targetCount) {
      if task.repeatTime == 0 {
        task.currentCount = 0
        pullTrigger = true
      } else {
        task.currentRepeatTime += 1
        if (task.currentRepeatTime <= task.repeatTime) {
          task.currentCount = 0
          pullTrigger = true
        }
      }
    }
    
    // if repeatTime == 0 then it is always valid
    if (task.currentRepeatTime > task.repeatTime) {
      task.currentRepeatTime = task.repeatTime
      task.valid = false
    }
    
    save()
    
    return pullTrigger
  }
  
  fileprivate func addNewTask(id: String, targetCount: UInt, repeatTime: UInt = 1) {
    guard let managedObjectContext = managedObjectContext else {
      return
    }
    
    let task = NSEntityDescription.insertNewObject(forEntityName: Entity.CounterTask.rawValue, into: managedObjectContext) as! CounterTask
    task.id = id
    task.currentCount = 1
    task.targetCount = Int32(targetCount)
    task.repeatTime = Int32(repeatTime)
    task.currentRepeatTime = 0
    task.valid = true
    
    save()
  }
  
  fileprivate func save() {
    guard let managedObjectContext = managedObjectContext else {
      return
    }
    
    if managedObjectContext.hasChanges {
      do {
        try managedObjectContext.save()
      } catch {
        let nserror = error as NSError
        print("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  fileprivate func execute(_ request: NSPersistentStoreRequest) {
    guard let managedObjectContext = managedObjectContext else {
      return
    }
    
    do {
      try managedObjectContext.execute(request)
    } catch {
      let error = error as NSError
      print("Unresolved error \(error), \(error.userInfo)")
    }
  }
}

