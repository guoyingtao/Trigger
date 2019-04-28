//
//  SwiftTrigger.swift
//  SwiftTrigger
//
//  Created by Echo on 1/3/18.
//  Copyright © 2018 Echo. All rights reserved.
//

import Foundation
import CoreData

public class SwiftTrigger {
  
  /**
   Subclass NSPersistentContainer to provide a customized
   storage path for core data database.
   */
  class TriggerPersistentContainer: NSPersistentContainer {
    override open class func defaultDirectoryURL() -> URL {
      let urlForApplicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
      
      let url = urlForApplicationSupportDirectory.appendingPathComponent(Config.containerFolder)
      
      if FileManager.default.fileExists(atPath: url.path) == false {
        do {
          try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
          print("Can not create storage folder!")
        }
      }

      return url
    }
  }

  private let databaseName = "SwiftTriggerModel"
  
  private lazy var persistentContainer: NSPersistentContainer? = {
    let modelURL = Bundle(for: SwiftTrigger.self)
      .url(forResource: databaseName, withExtension: "momd")

    guard let model = modelURL.flatMap(NSManagedObjectModel.init) else {
      print("Fail to load the trigger model!")
      return nil
    }
    
    var container: TriggerPersistentContainer
    
    container = TriggerPersistentContainer(name: databaseName, managedObjectModel: model)
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        print("Unexpected error: \(error), \(error.userInfo)")
      } else if let error = error {
        print("Unexpected error: \(error)")
      }
    })
    
    return container
  }()
  
  private lazy var taskEntityName: String = {
    return String(describing: CounterTask.self)
  } ()
  
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
   - parameter action: action will be excuted if the trigger will be pulled
   - returns Void
   */
  public func setFirstTimeTrigger(for event: Event, action:@escaping ()->Void) {
    setTrigger(for: event, targetCount: 1, action: action)
  }
  
  /**
   ## Normal check function.
   After execute time meets targetCount,
   the check can start over again for specified times
   If repeat times equals 0, then this cycle can be forever.
   */
  public func setTrigger(for event: Event, targetCount: UInt, repeat times: UInt = 1, action:@escaping ()->Void) {
    if isFire(for: event, targetCount: targetCount, repeat: times) {
      action()
    }
  }
  
  // clear functions can make checking event to start over
  public func clear(event: Event) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntityName)
    fetchRequest.predicate = NSPredicate(format: "id == %@", event.id)
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }

  public func clear(events: [Event]) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntityName)
    let ids = events.map{ $0.id }
    fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }

  public func clear(events: Event...) {
    clear(events: events)
  }
  
  public func clearAllEvents() {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntityName)
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }
}

// MARK: private methods for pull trigger
extension SwiftTrigger {
  private func isFire(for event: Event, targetCount: UInt = 1, repeat times: UInt = 1) -> Bool {
    if let tasks = getTasks(by: event) {
      if tasks.count > 0 {
        return checkIsFire(byTask: tasks[0])
      } else {
        addNewTask(for: event, targetCount: targetCount, repeat: times)
        // When users want to trigger something when the event with specified id first run, pull trigger.
        return targetCount == 1
      }
    } else {
      return false
    }
  }

  private func checkIsFire(byTask task: CounterTask) -> Bool {
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

// MARK: enums
extension SwiftTrigger {
  public enum Config {
    static var containerFolder = "SwiftTriggerDB"
  }
  
  /// https://www.swiftbysundell.com/posts/designing-swift-apis
  public struct Event {
    let id: String
  }
}

// MARK: private methods
extension SwiftTrigger {
  fileprivate func getTasks(by event: Event) -> [CounterTask]? {
    guard let context = managedObjectContext else {
      return nil
    }
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntityName)
    fetchRequest.predicate = NSPredicate(format: "id == %@", event.id)
    
    do {
      guard let tasks = try context.fetch(fetchRequest) as? [CounterTask] else {
        return nil
      }
      
      return tasks
    } catch {
      print("Unexpected error: \(error)")
      return nil
    }
  }
  
  fileprivate func addNewTask(for event: Event, targetCount: UInt, repeat times: UInt = 1){
    guard let context = managedObjectContext else {
      return
    }
    
    guard let task = NSEntityDescription.insertNewObject(forEntityName: taskEntityName, into: context) as? CounterTask else {
      return
    }
    task.id = event.id
    task.currentCount = 1
    task.targetCount = Int32(targetCount)
    task.repeatTime = Int32(times)
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

// MARK: internal methods for inside test
extension SwiftTrigger {
  func reset(byEventId id: String, targetCount: UInt, repeat times: UInt) -> CounterTask? {
    if let tasks = getTasks(by: Event(id: id)) {
      guard tasks.count > 0 else {
        return nil
      }
      
      let task = tasks[0]
      task.currentCount = 0
      task.currentRepeatTime = 0
      task.targetCount = Int32(targetCount)
      task.repeatTime = Int32(times)
      task.valid = true
      save()
      
      return task
    } else {
      return nil
    }
  }
  
  func getCurrentRepeatTime(by event: Event) -> Int {
    if let tasks = getTasks(by: event) {
      
      guard tasks.count > 0 else {
        return 0
      }
      
      let task = tasks[0]
      return Int(task.currentRepeatTime)
    }
    
    return 0
  }
  
  func test() {
    CounterTask.description()
  }
  
}

// MARK: deprecated APIs
extension SwiftTrigger {
  @available(*, deprecated, renamed: "setFirstTimerTrigger(for:action:)")
  public func firstRunCheck(byEventId id: String, action: @escaping ()->Void) {
    check(byEventId:id, targetCount:1, repeat: 1, action: action)
  }
  
  @available(*, deprecated, renamed: "setTrigger(for:targetCount:repeat:)")
  public func check(byEventId id: String, targetCount: UInt, repeat times: UInt = 1, action:@escaping ()->Void) {
    if isFire(for: Event(id: id), targetCount: targetCount, repeat: times) {
      action()
    }
  }

  @available(*, deprecated, renamed: "clear(events:)")
  public func clear(byEventIdList list: String...) {
    clear(byEventIdList: list)
  }
  
  @available(*, deprecated, renamed: "clear(events:)")
  public func clear(byEventIdList list: [String]) {
    clear(events: list.map{ Event(id: $0)})
  }
  
  @available(*, deprecated, renamed: "clear(event:)")
  public func clear(byEventId id: String) {
    clear(event: Event(id: id))
  }

  @available(*, deprecated, renamed: "check(byEventId:targetCount:repeat:action:)")
  public func check(byEventId id: String, targetCount: UInt, repeatTime: UInt, action:@escaping ()->Void) {
    check(byEventId: id, targetCount: targetCount, repeat: repeatTime, action: action)
  }
  
  @available(*, deprecated, renamed: "clearAllEvents")
  public func clearAll() {
    clearAllEvents()
  }
}


