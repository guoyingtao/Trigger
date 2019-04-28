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
      let event = SwiftTrigger.Event(id: "Event")
      trigger.oneshotSet(for: event) {
        fired = true
      }
      
      XCTAssertTrue(fired)
      fired = false
      
      trigger.oneshotSet(for: event) {
        fired = true
      }
      
      XCTAssertFalse(fired)
    }
  }
  
  func testFiniteRunNoRepeat() {
    if let trigger = trigger {
      let target = UInt(3)
      let event = SwiftTrigger.Event(id: "Event")
      var fired = false
      
      for i in 1...target {
        trigger.set(for: event, targetCount: target) {
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
        trigger.set(for: event, targetCount: target) {
          fired = true
        }
        
        XCTAssertFalse(fired)
      }
      
    }
  }
  
  func testFiniteRunRepeatForever() {
    if let trigger = trigger {
      let target = UInt(3)
      let times = UInt(0)
      let event = SwiftTrigger.Event(id: "Event")
      var fired = false
      
      for _ in 1...10 { // Repeat cycle
        for i in 1...target {
          trigger.set(for: event, targetCount: target, repeat: times) {
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
      let times = UInt(3)
      let event = SwiftTrigger.Event(id: "Event")
      var fired = false
      
      for cycle in 1...10 {
        for i in 1...target {
          trigger.set(for: event, targetCount: target, repeat: times) {
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
  }
  
  func testClear() {
    if let trigger = trigger {
      var fired1 = false
      var fired2 = false
      let event1 = SwiftTrigger.Event(id: "Event1")
      let event2 = SwiftTrigger.Event(id: "Event2")
      trigger.oneshotSet(for: event1) {
        fired1 = true
      }
      trigger.oneshotSet(for: event2) {
        fired2 = true
      }
      
      XCTAssertTrue(fired1)
      fired1 = false
      XCTAssertTrue(fired2)
      fired2 = false
      
      /// Test clear all
      trigger.clearAll()
      trigger.oneshotSet(for: event1) {
        fired1 = true
      }
      trigger.oneshotSet(for: event2) {
        fired2 = true
      }
      
      XCTAssertTrue(fired1)
      fired1 = false
      XCTAssertTrue(fired2)
      fired2 = false

      /// Test clear by [event id]
      trigger.clear(forEvents: [event1, event2])
      trigger.oneshotSet(for: event1) {
        fired1 = true
      }
      trigger.oneshotSet(for: event2) {
        fired2 = true
      }

      XCTAssertTrue(fired1)
      fired1 = false
      XCTAssertTrue(fired2)
      fired2 = false

      /// Test clear by variable args
      trigger.clear(forEvents: event1, event2)
      trigger.oneshotSet(for: event1) {
        fired1 = true
      }
      trigger.oneshotSet(for: event2) {
        fired2 = true
      }

      XCTAssertTrue(fired1)
      fired1 = false
      XCTAssertTrue(fired2)
      fired2 = false

      /// Test clear by event id
      trigger.clear(forEvent: event1)
      trigger.clear(forEvent: event2)
      trigger.oneshotSet(for: event1) {
        fired1 = true
      }
      trigger.oneshotSet(for: event2) {
        fired2 = true
      }

      XCTAssertTrue(fired1)
      fired1 = false
      XCTAssertTrue(fired2)
      fired2 = false
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
