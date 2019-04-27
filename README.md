![SwiftTrigger](https://github.com/guoyingtao/repo/blob/master/images/Trigger.png)

# SwiftTrigger

SwiftTrigger is used to easily check if some events should be trigged by executing times:
- The first time run
- The Nth time run
- every N times run
- every N times run but stops after repeating M times

## Events Storage
SwiftTrigger uses coredata to storage events. All the storage files are in its own subfolder whose default name is "SwiftTriggerDB". You can always change it by setting TriggerConfig.dbFolder to the name whatever you want.

## Requirements

* iOS 10.0+
* Xcode 9.0+

## Install

### CocoaPods

To integrate SwiftTrigger into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'SwiftTrigger', '~> 0.1.14'
```

### Cathage

```ruby
github "guoyingtao/Trigger"
```

## usage

### check if an event runs first time
```swift
SwiftTrigger().firstRunCheck(byEventId: "Event1") {
  // do something
}
```

### check if an event runs for the N time
```swift
SwiftTrigger().check(byEventId: "Event2", targetCount: N) { {
  // do something
}
```

### create an event trigged every N times
```swift
SwiftTrigger().check(byEventId: "Event3", targetCount: N, repeat: 0) {
  // do something
}
```

### create an event trigged every N times but stop after repeating M times
```swift
SwiftTrigger().check(byEventId: "Event4", targetCount: N, repeat: M) {
  // do something
}
```

### clear events
```swift
SwiftTrigger().clear(byEventId: "Event1")
SwiftTrigger().clear(byEventIdList: "Event1", "Event2")
SwiftTrigger().clear(byEventIdList: ["Event1", "Event2"])
SwiftTrigger().clearAllEvents()
```


