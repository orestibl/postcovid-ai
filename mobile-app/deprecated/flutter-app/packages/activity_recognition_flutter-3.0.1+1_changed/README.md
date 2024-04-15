# activity_recognition_flutter

[![pub package](https://img.shields.io/pub/v/activity_recognition_flutter.svg)](https://pub.dartlang.org/packages/activity_recognition)

## Important
This package uses the Android Embedding API v2. In order to use this in pre-Flutter 1.12 projects, you need to follow this guide: https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects
Activity recognition plugin for Android and iOS. Only working while App is running (= not terminated by the user or OS).

## Getting Started

Check out the `example` directory for a sample app using activity recognition.

### Android Configuration
Add the following entries inside the `<manifest>` tag:
```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="com.google.android.gms.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

Next, add the plugin's service inside the `<application>` tag:
```xml
<service android:name="dk.cachet.activity_recognition_flutter.ActivityRecognizedService" />
<service android:name="dk.cachet.activity_recognition_flutter.ForegroundService" />
```

#### Known quirks
If you update from SDK <=28 to >=29 remember to run `flutter clean` 
> (see e.g. [this post](https://stackoverflow.com/questions/55407939/permission-requests-are-not-propagated-when-launching-with-flutter-but-are-when/57072913))

### iOS Configuration

An iOS app linked on or after iOS 10.0 must include usage description keys in its *Info.plist* file
for the types of data it needs. Failure to include these keys will cause the app to crash.
To access motion and fitness data specifically, it must include `NSMotionUsageDescription`, see example below.

```xml
<key>NSMotionUsageDescription</key>
<string>Detects human activity</string>
```

### Flutter Usage
To use this plugin, you need to also use the permission handler plugin (https://pub.dev/packages/permission_handler), or some other way of requesting permission. If in doubt, see the example app. 

NOTE: You should not use the permission handler plugin for requesting activity recognition on iOS, since it is not needed and will make your iOS app crash.

## Data types
Each detected activity will have an activity type, which is one of the following:
* IN_VEHICLE
* ON_BICYCLE
* ON_FOOT
* RUNNING
* STILL
* TILTING
* UNKNOWN
* WALKING
* INVALID (used for parsing errors)

As well as a confidence expressed in percentages (i.e. a value from 0-100).

