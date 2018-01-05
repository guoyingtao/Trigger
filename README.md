![Trigger](https://github.com/guoyingtao/repo/blob/master/images/Trigger.png)

# Trigger

Trigger is used to easily check if some events should be trigged by executing times:
- The first time
- The N time
- every N times
- every N times but stop after repeating M times

## Requirements

* iOS 10.0+
* Xcode 9.0+

## usage

### check if an event runs first time
```swift
Trigger().firstRunCheck("Event1") {
  // do something
}
```

### check if an event runs for the N time
```swift
Trigger().check("Event2", targetCount: N) { {
  // do something
}
```

### create an event trigged every N times
```swift
Trigger().check("Event3", targetCount: N, repeatTime: 0) {
  // do something
}
```

### create an event trigged every N times but stop after repeating M times
```swift
Trigger().check("Event4", targetCount: N, repeatTime: M) {
  // do something
}
```

