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
      var fired = 0
      let event = "Event"
      trigger.firstRunCheck(forId: event) {
        fired += 1
      }
      
      XCTAssertTrue(fired == 1)
      
      trigger.firstRunCheck(forId: event) {
        fired += 1
      }

      XCTAssertTrue(fired == 1)
    }
  }
  
  func testFiniteRunNoRepeat() {
    if let trigger = trigger {
      let target = UInt(3)
      let event = "Event"
      var fired = 0
      
      for i in 1...target {
        trigger.check(byId: event, targetCount: target) {
          fired += 1
        }
        
        if i < target {
          XCTAssertTrue(fired == 0)
        } else if i == target {
          XCTAssertTrue(fired == 1) // fired
        }
      }
      
      for _ in 1...target {
        trigger.check(byId: event, targetCount: target) {
          fired += 1
        }
        
        XCTAssertTrue(fired == 1)
      }

    }
  }

  func testFiniteRunRepeatForever() {
    if let trigger = trigger {
      let target = UInt(3)
      let event = "Event"
      var fired = 0

      for i in 1...target {
        trigger.check(byId: event, targetCount: target, repeatTime: 0) {
          fired += 1
        }
        
        if i < target {
          XCTAssertTrue(fired == 0)
        } else if i == target {
          XCTAssertTrue(fired == 1) // fired
        }
      }
      
      for i in 1...target {
        trigger.check(byId: event, targetCount: target, repeatTime: 0) {
          fired += 1
        }
        
        if i < target {
          XCTAssertTrue(fired == 1)
        } else if i == target {
          XCTAssertTrue(fired == 2) // fired
        }
      }
      
      for i in 1...target {
        trigger.check(byId: event, targetCount: target, repeatTime: 0) {
          fired += 1
        }
        
        if i < target {
          XCTAssertTrue(fired == 2)
        } else if i == target {
          XCTAssertTrue(fired == 3) // fired
        }
      }

    }
  }

  
  func testFiniteRunFiniteRepeat() {
    if let trigger = trigger {
      let target = UInt(3)
      let event = "Event"
      var fired = 0
      
      for i in 1...target {
        trigger.check(byId: event, targetCount: target, repeatTime: 2) {
          fired += 1
        }
        
        if i < target {
          XCTAssertTrue(fired == 0)
        } else if i == target {
          XCTAssertTrue(fired == 1) // fired
        }
      }
      
      for i in 1...target {
        trigger.check(byId: event, targetCount: target, repeatTime: 2) {
          fired += 1
        }
        
        if i < target {
          XCTAssertTrue(fired == 1)
        } else if i == target {
          XCTAssertTrue(fired == 2) // fired
        }
      }
      
      for _ in 1...target {
        trigger.check(byId: event, targetCount: target, repeatTime: 2) {
          fired += 1
        }
        
        XCTAssertTrue(fired == 2)
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
