//
//  TriggerProtocal.swift
//  SwiftTrigger
//
//  Created by Echo on 5/10/18.
//  Copyright © 2018 Echo. All rights reserved.
//

import Foundation

protocol TriggerProtocal {
  /// If a event is ran for the first time, then execute an action
  func firstRunCheck(byEventId id: String, action:@escaping ()->Void)
  
  /**
   ## Normal check function.
   ### repeatTime
      - After execute time meets targetCount,
      the check can start over again for specified times
      If repeatTime equals 0, then this cycle can be forever.
  */
  func check(byEventId id: String,
             targetCount: UInt,
             repeatTime: UInt,
             action:@escaping ()->Void)
  
  
  /// clear functions can make checking event to start over
  func clear(byEventIdList list: String...)
  func clear(byEventIdList list: [String])
  func clear(byEventId id: String)
  func clearAll()
}
