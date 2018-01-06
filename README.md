![SwiftTrigger](https://github.com/guoyingtao/repo/blob/master/images/Trigger.png)

# SwiftTrigger

SwiftTrigger is used to easily check if some events should be trigged by executing times:
- The first time
- The N time
- every N times
- every N times but stop after repeating M times

## Requirements

* iOS 10.0+
* Xcode 9.0+

## Install

### CocoaPods

To integrate SwiftTrigger into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'SwiftTrigger'
```

### Cathage

```ruby
github "guoyingtao/Trigger"
```

## usage

### check if an event runs first time
```swift
SwiftTrigger().firstRunCheck("Event1") {
  // do something
}
```

### check if an event runs for the N time
```swift
SwiftTrigger().check("Event2", targetCount: N) { {
  // do something
}
```

### create an event trigged every N times
```swift
SwiftTrigger().check("Event3", targetCount: N, repeatTime: 0) {
  // do something
}
```

### create an event trigged every N times but stop after repeating M times
```swift
SwiftTrigger().check("Event4", targetCount: N, repeatTime: M) {
  // do something
}
```

### clear an event
```swift
SwiftTrigger().clear("Event1")
```

### clear all events
```swift
SwiftTrigger().clearAll()
```


