![Trigger](https://github.com/guoyingtao/repo/blob/master/images/Trigger.png)

# Trigger

Trigger is used to easily check if some conditions are fulfilled like following:
- The first time happen
- The N time happen
- repeat N time
- The N days later - TODO
- repeat N days - TODO

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

### create an event trigged every N times and repeat M times then stop
```swift
Trigger().check("Event4", targetCount: N, repeatTime: M) {
  // do something
}
```

