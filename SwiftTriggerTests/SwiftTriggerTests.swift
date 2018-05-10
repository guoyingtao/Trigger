//
//  TriggerTests.swift
//  TriggerTests
//
//  Created by Echo on 1/3/18.
//  Copyright © 2018 Echo. All rights reserved.
//

import XCTest
@testable import SwiftTrigger

class TriggerTests: XCTestCase {
  var trigger: SwiftTrigger?
  
  override func setUp() {
    trigger = SwiftTrigger()
    if let trigger = trigger {
      trigger.clearAll()
    }
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    trigger?.clearAll()
    trigger = nil
    super.tearDown()
  }
  
  func testFirstRun() {
    if let trigger = trigger {
      var fired = false
      let event = "Event"
      trigger.firstRunCheck(forId: event) {
        fired = true
      }
      
      XCTAssertTrue(fired)
      fired = false
      
      trigger.firstRunCheck(forId: event) {
        fired = true
      }
      
      XCTAssertFalse(fired)
    }
  }
  
  func testFiniteRunNoRepeat() {
    if let trigger = trigger {
      let target = UInt(3)
      let event = "Event"
      var fired = false
      
      for i in 1...target {
        trigger.check(byId: event, targetCount: target) {
          fired = true
        }
        
        if i < target {
          XCTAssertFalse(fired)
        } else if i == target {
          XCTAssertTrue(fired) // fired
          fired = false
        }
      }
      
      for _ in 1...100 {
        trigger.check(byId: event, targetCount: target) {
          fired = true
        }
        
        XCTAssertFalse(fired)
      }
      
    }
  }
  
  func testFiniteRunRepeatForever() {
    if let trigger = trigger {
      let target = UInt(3)
      let repeatTime = UInt(0)
      let event = "Event"
      var fired = false
      
      for _ in 1...10 {
        for i in 1...target {
          trigger.check(byId: event, targetCount: target, repeatTime: repeatTime) {
            fired = true
          }
          
          if i < target {
            XCTAssertFalse(fired)
          } else if i == target {
            XCTAssertTrue(fired) // fired
            fired = false
          }
        }
      }
    }
  }
  
  
  func testFiniteRunFiniteRepeat() {
    if let trigger = trigger {
      let target = UInt(3)
      let repeatTime = UInt(3)
      let event = "Event"
      var fired = false
      
      for cycle in 1...10 {
        for i in 1...target {
          trigger.check(byId: event, targetCount: target, repeatTime: repeatTime) {
            fired = true
          }
          
          if cycle > repeatTime {
            XCTAssertFalse(fired)
          } else {
            if i < target {
              XCTAssertFalse(fired)
            } else if i == target {
              XCTAssertTrue(fired) // fired
              fired = false
            }
          }          
        }
      }
    }
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
