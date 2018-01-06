//
//  Trigger.swift
//  Trigger
//
//  Created by Echo on 1/3/18.
//  Copyright © 2018 Echo. All rights reserved.
//

import Foundation
import CoreData

public class Trigger {
  private lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "TriggerModel")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        print("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  private var managedObjectContext: NSManagedObjectContext!
  
  public init() {
    managedObjectContext = persistentContainer.viewContext
  }
}

// MARK - public methods
extension Trigger {
  public func clear(id: String) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CounterTask")
    fetchRequest.predicate = NSPredicate(format: "id == %@", id)
    
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }
  
  public func clearAll() {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CounterTask")
    
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }
  
  public func firstRunCheck(_ id: String, action:@escaping ()-> Void) {
    check(id, targetCount:1, action: action)
  }
  
  public func check(_ id: String, targetCount: UInt, repeatTime: UInt = 1, action:@escaping ()-> Void) {
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
  
  public func getCurrentRepeatTime(_ id: String) -> Int {
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
extension Trigger {
  fileprivate func getTasks(id: String) -> [CounterTask]? {
    guard managedObjectContext != nil else {
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
    
//    let t = getCurrentRepeatTime(task.id!)
//    print("\(task.id!) repeat time is \(t)")
    
    return pullTrigger
  }
  
  fileprivate func addNewTask(id: String, targetCount: UInt, repeatTime: UInt = 1) {
    let task = NSEntityDescription.insertNewObject(forEntityName: "CounterTask", into: managedObjectContext) as! CounterTask
    task.id = id
    task.currentCount = 1
    task.targetCount = Int32(targetCount)
    task.repeatTime = Int32(repeatTime)
    task.currentRepeatTime = 0
    task.valid = true
    
    save()
  }
  
  fileprivate func save() {
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
    do {
      try managedObjectContext.execute(request)
    } catch {
      let nserror = error as NSError
      print("Unresolved error \(nserror), \(nserror.userInfo)")
    }
  }
}

