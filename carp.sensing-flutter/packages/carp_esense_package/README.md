# CARP eSense Sampling Package

[![pub package](https://img.shields.io/pub/v/carp_esense_package.svg)](https://pub.dartlang.org/packages/carp_esense_package)

This library contains a sampling package for
the [`carp_mobile_sensing`](https://pub.dartlang.org/packages/carp_mobile_sensing) framework
to work with the [eSense](https://www.esense.io) earable computing platform.
This packages supports sampling of the following [`Measure`](https://pub.dev/documentation/carp_core/latest/carp_core/Measure-class.html) types (note that the package defines its own namespace of `dk.cachet.carp.esense`):

* `dk.cachet.carp.esense.button` : eSense button pressed / released events
* `dk.cachet.carp.esense.sensor` : eSense sensor (accelerometer & gyroscope) events.

See the user documentation on the [eSense device](https://www.esense.io/share/eSense-User-Documentation.pdf) for how to use the device. 
See the [`esense_flutter`](https://pub.dev/packages/esense_flutter) Flutter plugin and its [API](https://pub.dev/documentation/esense_flutter/latest/) documentation to understand how sensor data is generated and their data formats. 

See the `carp_mobile_sensing` [wiki](https://github.com/cph-cachet/carp.sensing-flutter/wiki) for further documentation, particularly on available [measure types](https://github.com/cph-cachet/carp.sensing-flutter/wiki/A.-Measure-Types)
and [sampling schemas](https://github.com/cph-cachet/carp.sensing-flutter/wiki/D.-Sampling-Schemas).

For Flutter plugins for other CARP products, see [CARP Mobile Sensing in Flutter](https://github.com/cph-cachet/carp.sensing-flutter).

If you're interested in writing you own sampling packages for CARP, see the description on
how to [extend](https://github.com/cph-cachet/carp.sensing-flutter/wiki/4.-Extending-CARP-Mobile-Sensing) CARP on the wiki.

## Installing

To use this package, add the following to you `pubspc.yaml` file. Note that
this package only works together with `carp_mobile_sensing`.

`````dart
dependencies:
  flutter:
    sdk: flutter
  carp_core: ^0.20.0
  carp_mobile_sensing: ^0.20.0
  carp_esense_package: ^0.20.0
  ...
`````

### Android Integration

Add the following to your app's `manifest.xml` file located in `android/app/src/main`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-feature android:name="android.hardware.bluetooth_le" android:required="true"/>
```

> **NOTE:** The first time the app starts, make sure to allow it to access the phone location. 
This is necessary to use the BLE on Android. 

> **NOTE:** This package only supports AndroidX and hence requires any Android app using this plugin to also 
[migrate](https://developer.android.com/jetpack/androidx/migrate) if they're using the original support library. 
See Flutter [AndroidX compatibility](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility)


### iOS Integration

Requires iOS 10 or later. Hence, in your `Podfile` in the `ios` folder of your app, 
make sure that the platform is set to `10.0`.
 

```
platform :ios, '10.0'
```

Add this permission in the `Info.plist` file located in `ios/Runner`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Uses bluetooth to connect to the eSense device</string>
<key>UIBackgroundModes</key>
  <array>
  <string>audio</string>
  <string>external-accessory</string>
  <string>fetch</string>
</array>

```


## Using it

To use this package, import it into your app together with the
[`carp_mobile_sensing`](https://pub.dartlang.org/packages/carp_mobile_sensing) package:

`````dart
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_esense_package/esense.dart';
`````


`ESenseMeasure`s can be added to a study protocol like this.

```dart
  CAMSStudyProtocol protocol = CAMSStudyProtocol()
    ..name = 'Track patient movement'
    ..owner = ProtocolOwner(
      id: 'AB',
      name: 'Alex Boyon',
      email: 'alex@uni.dk',
    );

  // define which devices are used for data collection - both phone and eSense
  Smartphone phone = Smartphone(roleName: 'The main phone');
  DeviceDescriptor eSense = ESenseDevice(roleName: 'The left eSense earplug');

  protocol
    ..addMasterDevice(phone)
    ..addConnectedDevice(eSense);

  // Add an automatic task that immediately starts collecting eSense button and
  // sensor events from the eSense device.
  protocol.addTriggeredTask(
      ImmediateTrigger(),
      AutomaticTask()
        ..addMeasures([
          ESenseMeasure(
              type: ESenseSamplingPackage.ESENSE_BUTTON,
              name: 'eSense - Button',
              description: "Collects button event from the eSense device",
              deviceName: 'eSense-0332'),
          ESenseMeasure(
              type: ESenseSamplingPackage.ESENSE_SENSOR,
              name: 'eSense - Sensor',
              description:
                  "Collects movement data from the eSense inertial measurement unit (IMU) sensor",
              deviceName: 'eSense-0332',
              samplingRate: 5),
        ]),
      eSense);
````

Before executing a study with an eSense measure, register this package in the 
[SamplingPackageRegistry](https://pub.dartlang.org/documentation/carp_mobile_sensing/latest/runtime/SamplingPackageRegistry.html).

`````dart
SamplingPackageRegistry().register(ESenseSamplingPackage());
`````

> Note that the eSense device must be paired with the phone via BTLE **before** CAMS can connect to it.
