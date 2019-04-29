<p align="center">
  <img src="logo.png" height="100" max-width="90%" alt="Swift Trigger" />
</p>

# SwiftTrigger

SwiftTrigger is used to easily check if some events should be trigged by executing times:
- The first time run
- The Nth time run
- every N times run
- every N times run but stops after repeating M times

## Events Storage
Behind the scene, SwiftTrigger uses coredata to save events. All the coredata files are in its own folder whose default name is "SwiftTriggerDB". You can always change it by setting SwiftTrigger.Config.containerFolder to your favorite name.

## Requirements

* iOS 10.0+
* Xcode 9.0+

## Install

### CocoaPods

To integrate SwiftTrigger into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'SwiftTrigger', '~> 1.0.0'
```

### Cathage

```ruby
github "guoyingtao/Trigger"
```

## usage

### create an event triggered only for the first time run
```swift
let event = SwiftTrigger.Event(id: "MyEvent")
SwiftTrigger().oneshotCheck(event) {
  // do something
}
```

### create an event triggered for the Nth time run
```swift
let event = SwiftTrigger.Event(id: "MyEvent")
SwiftTrigger().monitor(event, targetCount: N) { {
  // do something
}
```

### create an event triggered for the every Nth times run
```swift
let event = SwiftTrigger.Event(id: "MyEvent")
SwiftTrigger().monitor(event, targetCount: N, repeat: 0) {
  // do something
}
```

### create an event triggered for the every Nth times fun but stop triggering after the event repeated for M times
```swift
let event = SwiftTrigger.Event(id: "MyEvent")
SwiftTrigger().monitor(event, targetCount: N, repeat: M) {
  // do something
}
```

### clear triggers for events
```swift
let event1 = SwiftTrigger.Event(id: "MyEvent1")
let event2 = SwiftTrigger.Event(id: "MyEvent2")
SwiftTrigger().clear(forEvent: event1)
SwiftTrigger().clear(forEvents: event1, event2)
SwiftTrigger().clear(forEvents: [event1, event2])
SwiftTrigger().clearAll()
```


