//
//  SwiftTrigger+InsideTypes.swift
//  SwiftTrigger
//
//  Created by Echo on 5/22/19.
//  Copyright © 2019 Echo. All rights reserved.
//

import Foundation

extension SwiftTrigger {
  public enum Config {
    static var containerFolder = "SwiftTriggerDB"
  }
  
  public typealias EventId = String
  
  public struct Event {
    let id: String
    
    /// Hold the trigger when running the event for targetRunningTimes
    let targetRunningTimes: UInt
    
    /** How many times for pulling trigger when running the event for every targetRunningTimes. **0 means infinite**
     */
    let repeatTimes: UInt
    
    public init(id: String, targetRunningTimes: UInt = 1, repeatTimes: UInt = 1) {
      self.id = id
      self.targetRunningTimes = targetRunningTimes
      self.repeatTimes = repeatTimes
    }
    
    static func makeOneShot(id: String) -> Event {
      return Event(id: id)
    }
  }
}

