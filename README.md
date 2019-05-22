<p align="center">
  <img src="logo.png" height="100" max-width="90%" alt="Swift Trigger" />
</p>

<p align="center">
<img src="https://img.shields.io/badge/swift-5.0-orange.svg" alt="swift 5.0 badge" />
<img src="https://img.shields.io/badge/platform-iOS-lightgrey.svg" alt="platform iOS badge" />
<img src="https://img.shields.io/badge/license-MIT-black.svg" alt="license MIT badge" />   
</p>


# SwiftTrigger

SwiftTrigger is used to easily check if some events should be trigged by executing times:
- The first time run
- The Nth time run
- every Nth times run
- every Nth times run but stops after repeating M times

## Events Storage
Behind the scene, SwiftTrigger uses coredata to save events. All the coredata files are in its own folder whose default name is "SwiftTriggerDB". You can always change it by setting SwiftTrigger.Config.containerFolder to your favorite name.

## Requirements

* iOS 10.0+
* Xcode 9.0+

## Install

### CocoaPods

To integrate SwiftTrigger into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'SwiftTrigger', '~> 2.0.2'
```

### Cathage

```ruby
github "guoyingtao/Trigger"
```

## Usage

### Create an event triggered only for the first time run
```swift
SwiftTrigger().oneshotCheck("MyEvent") {
  // do something
}
```

### Create an event triggered for the Nth time run then stop triggering after that
```swift
let event = SwiftTrigger.Event(id: "MyEvent", targetRunningTimes: N)
SwiftTrigger().monitor(event) { {
  // do something
}
```

### Create an event triggered for the every Nth times run
```swift
let event = SwiftTrigger.Event(id: "MyEvent", targetRunningTimes: N, repeatTimes: 0)
SwiftTrigger().monitor(event) {
  // do something
}
```

### Create an event triggered for the every Nth times fun but stop triggering after the event repeated for M times
```swift
let event = SwiftTrigger.Event(id: "MyEvent", targetRunningTimes: N, repeatTimes: M)
SwiftTrigger().monitor(event) {
  // do something
}
```

### Clear triggers for events
```swift
let event1 = "MyEvent1"
let event2 = "MyEvent2"
SwiftTrigger().clearEvent(by: event1)
SwiftTrigger().clearEvents(by: event1, event2)
SwiftTrigger().clearEvents(by: [event1, event2])
SwiftTrigger().clearAll()
```


