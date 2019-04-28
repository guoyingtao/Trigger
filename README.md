![SwiftTrigger](https://github.com/guoyingtao/repo/blob/master/images/Trigger.png)

# SwiftTrigger

SwiftTrigger is used to easily check if some events should be trigged by executing times:
- The first time run
- The Nth time run
- every N times run
- every N times run but stops after repeating M times

## Events Storage
SwiftTrigger uses coredata to storage events. All the storage files are in its own subfolder whose default name is "SwiftTriggerDB". You can always change it by setting SwiftTrigger.Config.containerFolder to the name whatever you want.

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

### check if an event runs first time
```swift
let event = SwiftTrigger.Event(id: "MyEvent")
SwiftTrigger().oneshotCheck(for: event) {
  // do something
}
```

### check if an event runs for the N time
```swift
let event = SwiftTrigger.Event(id: "MyEvent")
SwiftTrigger().check(for: event, targetCount: N) { {
  // do something
}
```

### create an event trigged every N times
```swift
let event = SwiftTrigger.Event(id: "MyEvent")
SwiftTrigger().check(for: event, targetCount: N, repeat: 0) {
  // do something
}
```

### create an event trigged every N times but stop after repeating M times
```swift
let event = SwiftTrigger.Event(id: "MyEvent")
SwiftTrigger().check(for: event, targetCount: N, repeat: M) {
  // do something
}
```

### clear events
```swift
let event1 = SwiftTrigger.Event(id: "MyEvent1")
let event2 = SwiftTrigger.Event(id: "MyEvent2")
SwiftTrigger().clear(forEvent: event1)
SwiftTrigger().clear(forEvents: event1, event2)
SwiftTrigger().clear(forEvents: [event1, event2])
SwiftTrigger().clearAll()
```


