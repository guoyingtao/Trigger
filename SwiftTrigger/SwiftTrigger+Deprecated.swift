//
//  SwiftTrigger+Deprecated.swift
//  SwiftTrigger
//
//  Created by Echo on 5/22/19.
//  Copyright © 2019 Echo. All rights reserved.
//

import Foundation

// MARK: deprecated APIs
extension SwiftTrigger {
  
  /**
   If a event is ran for the first time, then execute an action
   - parameter event: event to be triggered
   - parameter action: action will be excuted if the trigger will be pulled
   */
  @available(*, deprecated, renamed: "onshotCheck(eventId:trigger:)")
  public func oneshotCheck(_ event: Event,
                           trigger action: @escaping ()->Void) {
    let oneshotEvent = Event(id: event.id)
    monitor(oneshotEvent, trigger: action)
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
  @available(*, deprecated, renamed: "monitor(event:trigger:)")
  public func monitor(_ event: Event,
                      targetCount: UInt,
                      repeat times: UInt = 1,
                      trigger action:@escaping ()->Void) {
    let newEvent = Event(id: event.id, targetRunningTimes: targetCount, repeatTimes: times)
    if isFire(for: newEvent) {
      action()
    }
  }
  
  @available(*, deprecated, renamed: "oneshotCheck(event:trigger:)")
  public func firstRunCheck(byEventId id: String, action: @escaping ()->Void) {
    oneshotCheck(Event(id: id), trigger: action)
  }
  
  @available(*, deprecated, renamed: "clearEvent(by:)")
  public func clear(forEvent event: Event) {
    clearEvent(by: event.id)
  }
  
  @available(*, deprecated, renamed: "clearEvents(by:)")
  public func clear(forEvents events: [Event]) {
    let ids = events.map{ $0.id }
    clearEvents(by: ids)
  }
  
  @available(*, deprecated, renamed: "clearEvents(by:)")
  public func clear(forEvents events: Event...) {
    clear(forEvents: events)
  }

  
  @available(*, deprecated, renamed: "clearEvents(by:)")
  public func clear(byEventIdList list: String...) {
    clear(byEventIdList: list)
  }
  
  @available(*, deprecated, renamed: "clearEvents(by:)")
  public func clear(byEventIdList list: [String]) {
    clear(forEvents: list.map{ Event(id: $0)})
  }
  
  @available(*, deprecated, renamed: "clearEvent(by:)")
  public func clear(byEventId id: String) {
    clear(forEvents: Event(id: id))
  }
  
  @available(*, deprecated, renamed: "monitor(event:trigger:)")
  public func check(byEventId id: String, targetCount: UInt, repeatTime: UInt, action:@escaping ()->Void) {
    monitor(Event(id: id), targetCount: targetCount, repeat: repeatTime, trigger: action)
  }
}

