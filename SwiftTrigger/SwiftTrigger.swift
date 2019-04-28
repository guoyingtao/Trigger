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
      let urlForApplicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
      
      let url = urlForApplicationSupportDirectory.appendingPathComponent(TriggerConfig.dbFolder)
      
      if !FileManager.default.fileExists(atPath: url.path) {
        do {
          try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
          print("Can not create storage folder.")
        }
      }

      return url
    }
  }

  private let databaseName = "SwiftTriggerModel"
  private lazy var persistentContainer: NSPersistentContainer? = {
    let modelURL = Bundle(for: SwiftTrigger.self).url(forResource: databaseName, withExtension: "momd")

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

// MARK: Public APIs
extension SwiftTrigger {
  /**
   If a event is ran for the first time, then execute an action
   - parameter id: Event Id
   - parameter action: action to be excuted after trigger is pulled
   - returns Void
   */
  public func firstRunCheck(byEventId id: String, action: @escaping ()->Void) {
    check(byEventId:id, targetCount:1, repeat: 1, action: action)
  }
  
  @available(*, deprecated, renamed: "check(byEventId:targetCount:repeat:action:)")
  public func check(byEventId id: String, targetCount: UInt, repeatTime: UInt, action:@escaping ()->Void) {
    check(byEventId: id, targetCount: targetCount, repeat: repeatTime, action: action)
  }
  
  /**
   ## Normal check function.
   ### repeatTime
   - After execute time meets targetCount,
   the check can start over again for specified times
   If repeatTime equals 0, then this cycle can be forever.
   */
  public func check(byEventId id: String, targetCount: UInt, repeat repeatTime: UInt = 1, action:@escaping ()->Void) {
    if isPullTrigger(id, targetCount: targetCount, repeat: repeatTime) {
      action()
    }
  }

  // clear functions can make checking event to start over
  public func clear(byEventIdList list: String...) {
    clear(byEventIdList: list)
  }
  
  public func clear(byEventIdList list: [String]) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.CounterTask.rawValue)
    fetchRequest.predicate = NSPredicate(format: "id IN %@", list)
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }
  
  public func clear(byEventId id: String) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.CounterTask.rawValue)
    fetchRequest.predicate = NSPredicate(format: "id == %@", id)
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }
  
  public func clearAllEvents() {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.CounterTask.rawValue)
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }
  
  @available(*, deprecated, renamed: "clearAllEvents")
  public func clearAll() {
    clearAllEvents()
  }
}

// MARK: internal methods for inside test
extension SwiftTrigger {
  internal func reset(byEventId id: String, targetCount: UInt, repeatTime: UInt) -> CounterTask? {
    if let tasks = getTasks(id: id) {
      
      guard tasks.count > 0 else {
        return nil
      }
      
      let task = tasks[0]
      task.currentCount = 0
      task.currentRepeatTime = 0
      task.targetCount = Int32(targetCount)
      task.repeatTime = Int32(repeatTime)
      task.valid = true
      save()
      
      return task
    } else {
      return nil
    }
  }

  internal func getCurrentRepeatTime(byEventId id: String) -> Int {
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

// MARK: private methods for pull trigger
extension SwiftTrigger {
  private func isPullTrigger(_ id: String, targetCount: UInt = 1, repeat repeatTime: UInt = 1) -> Bool {
    if let tasks = getTasks(id: id) {
      if tasks.count > 0 {
        return checkIsPullTrigger(byTask: tasks[0])
      } else {
        addNewTask(id: id, targetCount: targetCount, repeatTime: repeatTime)
        // When users want to trigger something when the event with specified id first run, pull trigger.
        return targetCount == 1
      }
    } else {
      return false
    }
  }
  
  private func checkIsPullTrigger(byTask task: CounterTask) -> Bool {
    guard task.valid else {
      return false
    }
    
    /* Every time when deciding if pulling trigger, we have actually
     executed the task. So we plus 1 to task.currentCount */
    task.currentCount += 1
    var pullTrigger = false
    
    if(task.currentCount == task.targetCount) {
      if task.repeatTime == 0 { // valid forever
        task.valid = true
        task.currentCount = 0
        pullTrigger = true
      } else {
        task.currentRepeatTime += 1
        
        if (task.currentRepeatTime >= task.repeatTime) {
          task.valid = false
        } else {
          // reset to begin next round counting
          task.currentCount = 0
        }
        
        pullTrigger = true
      }
    }
    
    save()
    
    return pullTrigger
  }
}


// MARK: private methods
extension SwiftTrigger {  
  fileprivate func getTasks(id: String) -> [CounterTask]? {
    guard let managedObjectContext = managedObjectContext else {
      return nil
    }
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.CounterTask.rawValue)
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
  
  fileprivate func addNewTask(id: String, targetCount: UInt, repeatTime: UInt = 1){
    guard let managedObjectContext = managedObjectContext else {
      return
    }
    
    let task = NSEntityDescription.insertNewObject(forEntityName: Entity.CounterTask.rawValue, into: managedObjectContext) as! CounterTask
    task.id = id
    task.currentCount = 1
    task.targetCount = Int32(targetCount)
    task.repeatTime = Int32(repeatTime)
    task.currentRepeatTime = 0
    task.valid = (targetCount == 1) ? false : true
    
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

