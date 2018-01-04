//
//  ViewController.swift
//  TriggerExample
//
//  Created by Echo on 1/3/18.
//  Copyright © 2018 Echo. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
  
  @IBOutlet weak var event1RunTimesLabel: UILabel!
  @IBOutlet weak var event2RunTimesLabel: UILabel!
  @IBOutlet weak var event3RunTimesLabel: UILabel!
  @IBOutlet weak var event4RunTimesLabel: UILabel!
  
  @IBOutlet weak var event1TriggedLabel: UILabel!
  @IBOutlet weak var event2TriggedLabel: UILabel!
  @IBOutlet weak var event3TriggedLabel: UILabel!
  @IBOutlet weak var event4TriggedLabel: UILabel!
  
  @IBOutlet weak var event4TriggedTimesLabel: UILabel!
  
  var even1RunTimes = 0
  var even2RunTimes = 0
  var even3RunTimes = 0
  var even4RunTimes = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func clearAll(_ sender: Any) {
    Trigger().clearAll()
    event1TriggedLabel.isHidden = true
    event2TriggedLabel.isHidden = true
    event3TriggedLabel.isHidden = true
    event4TriggedLabel.isHidden = true
    
    even1RunTimes = 0
    even2RunTimes = 0
    even3RunTimes = 0
    even4RunTimes = 0
    
    event1RunTimesLabel.text = String(format:"%i times", even1RunTimes)
    event2RunTimesLabel.text = String(format:"%i times", even2RunTimes)
    event3RunTimesLabel.text = String(format:"%i times", even3RunTimes)
    event4RunTimesLabel.text = String(format:"%i times", even4RunTimes)
  }
  
  @IBAction func runForEvent1(_ sender: Any) {
    self.event1TriggedLabel.isHidden = true
    Trigger().firstRunCheck("Event1") {
      self.event1TriggedLabel.isHidden = false
    }
    even1RunTimes += 1
    event1RunTimesLabel.text = String(format:"%i times", even1RunTimes)
  }
  
  @IBAction func runForEvent2(_ sender: Any) {
    self.event2TriggedLabel.isHidden = true
    Trigger().check("Event2", targetCount: 3) {
      self.event2TriggedLabel.isHidden = false
    }
    even2RunTimes += 1
    event2RunTimesLabel.text = String(format:"%i times", even2RunTimes)
  }
  
  @IBAction func runForEvent3(_ sender: Any) {
    self.event3TriggedLabel.isHidden = true
    Trigger().check("Event3", targetCount: 3, repeatTime: 0) {
      self.event3TriggedLabel.isHidden = false
    }
    even3RunTimes += 1
    event3RunTimesLabel.text = String(format:"%i times", even3RunTimes)
  }
  
  @IBAction func runForEvent4(_ sender: Any) {
    self.event4TriggedLabel.isHidden = true
    Trigger().check("Event4", targetCount: 3, repeatTime: 2) {
      self.event4TriggedLabel.isHidden = false
    }
    even4RunTimes += 1
    event4RunTimesLabel.text = String(format:"%i times", even4RunTimes)
    
    let repeatTime = Trigger().getCurrentRepeatTime("Event4")
    event4TriggedTimesLabel.text = String(format:"repeat %i times", repeatTime)
  }
}

