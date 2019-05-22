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
    let oneshotEvent = Event(id: event.id)
    monitor(oneshotEvent, trigger: action)
  }    
  
  /// Monitoring an event and check if need to pull trigger
  ///
  /// - Parameters:
  ///   - event: event to be triggered
  ///   - action: action will be excuted after pulling trigger
  public func monitor(_ event: Event, trigger action:@escaping ()->Void) {
    if isFire(for: event) {
      action()
    }
  }
  
  // MARK: functions below are "clear functions" which can start over triggers
  public func clearEvent(by id: EventId) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntityName)
    fetchRequest.predicate = NSPredicate(format: "id == %@", id)
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }
  
  public func clearEvents(by ids: [EventId]) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntityName)
    fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }
  
  public func clearEvents(by ids: EventId...) {
    clearEvents(by: ids)
  }
    
  public func clearAll() {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntityName)
    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    execute(request)
  }
}

// MARK: internal methods
extension SwiftTrigger {
  func isFire(for event: Event) -> Bool {
    guard let tasks = getTasks(by: event.id) else { return false }
    
    if tasks.count > 0 {
      return checkIsFire(byTask: tasks[0])
    } else {
      addNewTask(for: event)
      // Fire for oneshot trigger
      return event.targetRunningTimes == 1
    }
  }
  
  func getCurrentRepeatTime(by eventId: EventId) -> Int {
    if let tasks = getTasks(by: eventId) {
      
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

// MARK: private methods
extension SwiftTrigger {
  fileprivate func getTasks(by eventId: EventId) -> [CounterTask]? {
    guard let context = managedObjectContext else {
      return nil
    }
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntityName)
    fetchRequest.predicate = NSPredicate(format: "id == %@", eventId)
    
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
  
  fileprivate func addNewTask(for event: Event){
    guard let context = managedObjectContext else {
      return
    }
    
    guard let task = NSEntityDescription.insertNewObject(forEntityName: taskEntityName, into: context) as? CounterTask else {
      return
    }
    task.id = event.id
    task.currentCount = 1
    task.targetCount = Int32(event.targetRunningTimes)
    task.repeatTime = Int32(event.repeatTimes)
    task.currentRepeatTime = 0
    task.valid = (event.targetRunningTimes == 1) ? false : true
    
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
    if let tasks = getTasks(by: event.id) {
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


