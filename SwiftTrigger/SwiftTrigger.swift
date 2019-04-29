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
   - parameter event: event to be triggered
   - parameter action: action will be excuted if the trigger will be pulled
   */
  public func oneshotCheck(_ event: Event,
                           trigger action: @escaping ()->Void) {
    monitor(event, targetCount: 1, trigger: action)
  }
  
  /**
   ## Normal check function.
   After execute time meets targetCount,
   the check can start over again for specified times
   If repeat times equals 0, then this cycle can be forever.
   - parameter event: event to be triggered
   - parameter targetCount: trigger target count
   - parameter times: repeat times
   - parameter action: action will be excuted if the trigger will be pulled
   */
  public func monitor(_ event: Event,
                    targetCount: UInt,
                    repeat times: UInt = 1,
                    trigger action:@escaping ()->Void) {
    if isFire(for: event, targetCount: targetCount, repeat: times) {
      action()
    }
  }
  
  // MARK: functions below are "clear functions" which can start over triggers
  public func clear(forEvent event: Event) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntityName)
    fetchRequest.predicate = NSPredicate(format: "id == %@", event.id)
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }

  public func clear(forEvents events: [Event]) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntityName)
    let ids = events.map{ $0.id }
    fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }

  public func clear(forEvents events: Event...) {
    clear(forEvents: events)
  }
  
  public func clearAll() {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntityName)
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }
}

// MARK: private methods for pull trigger
extension SwiftTrigger {
  private func isFire(for event: Event,
                      targetCount: UInt = 1,
                      repeat times: UInt = 1) -> Bool {
    guard let tasks = getTasks(by: event) else { return false }

    if tasks.count > 0 {
      return checkIsFire(byTask: tasks[0])
    } else {
      addNewTask(for: event, targetCount: targetCount, repeat: times)
      // Fire for oneshot trigger
      return targetCount == 1
    }
  }

  private func checkIsFire(byTask task: CounterTask) -> Bool {
    guard task.valid else {
      return false
    }
    
    /* Every time when deciding if pulling trigger, we have actually
     executed the task. So we plus 1 to task.currentCount */
    task.currentCount += 1
    var fire = false
    
    if(task.currentCount == task.targetCount) {
      if task.repeatTime == 0 { // valid forever
        task.valid = true
        task.currentCount = 0
        fire = true
      } else {
        task.currentRepeatTime += 1
        
        if (task.currentRepeatTime >= task.repeatTime) {
          task.valid = false
        } else {
          // reset to begin next round counting
          task.currentCount = 0
        }
        
        fire = true
      }
    }
    
    save()
    
    return fire
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
  
  fileprivate func addNewTask(for event: Event,
                              targetCount: UInt,
                              repeat times: UInt = 1){
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
      print("Unexpected error: \(error), \(error.userInfo)")
    }
  }
}

// MARK: internal methods for inside test
extension SwiftTrigger {
  @discardableResult func reset(for event: Event,
                                targetCount: UInt,
                                repeat times: UInt) -> CounterTask? {
    if let tasks = getTasks(by: event) {
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
}

// MARK: deprecated APIs
extension SwiftTrigger {
  @available(*, deprecated, renamed: "oneshotCheck(event:trigger:)")
  public func firstRunCheck(byEventId id: String, action: @escaping ()->Void) {
    oneshotCheck(Event(id: id), trigger: action)
  }
  
  @available(*, deprecated, renamed: "clear(events:)")
  public func clear(byEventIdList list: String...) {
    clear(byEventIdList: list)
  }
  
  @available(*, deprecated, renamed: "clear(events:)")
  public func clear(byEventIdList list: [String]) {
    clear(forEvents: list.map{ Event(id: $0)})
  }
  
  @available(*, deprecated, renamed: "clear(event:)")
  public func clear(byEventId id: String) {
    clear(forEvents: Event(id: id))
  }

  @available(*, deprecated, renamed: "monitor(event:targetCount:repeat:trigger:)")
  public func check(byEventId id: String, targetCount: UInt, repeatTime: UInt, action:@escaping ()->Void) {
    monitor(Event(id: id), targetCount: targetCount, repeat: repeatTime, trigger: action)
  }
}


