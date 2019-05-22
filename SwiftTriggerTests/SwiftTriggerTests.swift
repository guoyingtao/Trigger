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
  var trigger: SwiftTrigger!
  
  override func setUp() {
    trigger = SwiftTrigger()
    trigger.clearAll()
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    trigger.clearAll()
    super.tearDown()
  }
  
  func testFirstRun() {
    var fired = false
    trigger.oneshotCheck("Event") {
      fired = true
    }
    
    XCTAssertTrue(fired)
    fired = false
    
    trigger.oneshotCheck("Event") {
      fired = true
    }
    
    XCTAssertFalse(fired)
  }
  
  func testFiniteRunNoRepeat() {
    let target = UInt(3)
    let event = SwiftTrigger.Event(id: "Event", targetRunningTimes: target)
    var fired = false
    
    for i in 1...target {
      trigger.monitor(event) {
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
      trigger.monitor(event) {
        fired = true
      }
      
      XCTAssertFalse(fired)
    }
  }
  
  func testFiniteRunRepeatForever() {
    let target = UInt(3)
    let times = UInt(0)
    let event = SwiftTrigger.Event(id: "Event", targetRunningTimes: target, repeatTimes: times)
    var fired = false
    
    for _ in 1...10 { // Repeat cycle
      for i in 1...target {
        trigger.monitor(event) {
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
  
  
  func testFiniteRunFiniteRepeat() {
    let target = UInt(3)
    let times = UInt(3)
    let event = SwiftTrigger.Event(id: "Event", targetRunningTimes: target, repeatTimes: times)
    var fired = false
    
    for cycle in 1...10 {
      for i in 1...target {
        trigger.monitor(event) {
          fired = true
        }
        
        if cycle > times {
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
  
  func testReset() {
    var fired = false
    let event = SwiftTrigger.Event(id: "Event")
    trigger.oneshotCheck(event.id) {
      fired = true
    }
    
    XCTAssertTrue(fired)
    fired = false
    
    trigger.oneshotCheck(event.id) {
      fired = true
    }
    
    XCTAssertFalse(fired)
    
    fired = false
    let target = UInt(3)
    let times = UInt(3)

    trigger.reset(for: event, targetCount: target, repeat: times)
    let newEvent = SwiftTrigger.Event(id: event.id, targetRunningTimes: target, repeatTimes: times)
    
    for cycle in 1...10 {
      for i in 1...target {
        trigger.monitor(newEvent) {
          fired = true
        }
        
        if cycle > times {
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
  
  func testClear() {
    var fired1 = false
    var fired2 = false
    let event1 = "Event1"
    let event2 = "Event2"
    trigger.oneshotCheck(event1) {
      fired1 = true
    }
    trigger.oneshotCheck(event2) {
      fired2 = true
    }
    
    XCTAssertTrue(fired1)
    fired1 = false
    XCTAssertTrue(fired2)
    fired2 = false
    
    /// Test clear all
    trigger.clearAll()
    trigger.oneshotCheck(event1) {
      fired1 = true
    }
    trigger.oneshotCheck(event2) {
      fired2 = true
    }
    
    XCTAssertTrue(fired1)
    fired1 = false
    XCTAssertTrue(fired2)
    fired2 = false
    
    /// Test clear by [event id]
    trigger.clearEvents(by: [event1, event2])
    trigger.oneshotCheck(event1) {
      fired1 = true
    }
    trigger.oneshotCheck(event2) {
      fired2 = true
    }
    
    XCTAssertTrue(fired1)
    fired1 = false
    XCTAssertTrue(fired2)
    fired2 = false
    
    /// Test clear by variable args
    trigger.clearEvents(by: event1, event2)
    trigger.oneshotCheck(event1) {
      fired1 = true
    }
    trigger.oneshotCheck(event2) {
      fired2 = true
    }
    
    XCTAssertTrue(fired1)
    fired1 = false
    XCTAssertTrue(fired2)
    fired2 = false
    
    /// Test clear by event id
    trigger.clearEvent(by: event1)
    trigger.clearEvent(by: event2)
    trigger.oneshotCheck(event1) {
      fired1 = true
    }
    trigger.oneshotCheck(event2) {
      fired2 = true
    }
    
    XCTAssertTrue(fired1)
    fired1 = false
    XCTAssertTrue(fired2)
    fired2 = false
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
