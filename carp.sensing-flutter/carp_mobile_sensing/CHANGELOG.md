## 0.21.4
* small bug fixes
* upgrade to carp_code `0.21.4`

## 0.21.3
* **NOTE** - `DataEndPoint` is no longer specified as part of a `StudyProtocol`. 
    * Specifying where and how to store or upload data is really not part of specifying a study protocol, but rather a deployment issues. Therefore, the `DataEndPoint` is now part of a `MasterDeviceDeployment`. 
    * The `SmartphoneDeploymentService` will use the `FileDataEndpoint` per default if not specified in the deployment. Hence, data is saved as files on the phone.
    * The `StudyDeploymentController.configure()` method now takes an optional `DataEndPoint` parameter to specify the data endpoint, if it should be different to what is specified in the deployment.
    * The `StudyDeploymentController.configure()` method also takes a `askForPermissions` parameter - if `false`, then CAMS will not ask for permissions, but hands this over to the app, which can show appropiate information to the user.
* settings are now a singleton accessed using `Settings()` (similar to other singletons in the framework)
* better support for handling json functions
 
## 0.21.2
* update to `carp_core` v. 0.21.2

## 0.21.1
* update to `carp_core` v. 0.21.0

## 0.21.0
* update to `carp_core` v. 0.21.0 client domain model
* support for using a `SmartPhoneClientManager` for executing multiple studies
* adjusted examples and example app to use the carp_core_client domain model

## 0.20.5
* Added a `RandomRecurrentTrigger` as a new trigger type (Issue [#170](https://github.com/cph-cachet/carp.sensing-flutter/issues/170))

## 0.20.4
* removed localization support again - this has to be handled on an application level, not as part of sensing.
* removed the `ConsentSection` also - again, this is separate to sensing.

## 0.20.3
* update to `carp_core` v. 0.20.3 (json serialization)

## 0.20.0 
* **BREAKING**: Now using the [`carp_core`](https://pub.dev/packages/carp_core) domain models in order to align with the overall [domain-driven design of CARP](https://carp.cachet.dk/core/). 
* This has an impact on the **naming** used in the API. The most important changes are:
    * `Study` is now called `StudyProtocol` and a CAMS-specific protocol called `CAMSStudyProtocol` is available
    * `PrincipalInvestigator` is now called `ProtocolOwner`
    * `Task` is now called `TaskDescriptor`
    * `Device` is now called `DeviceDescriptor`
    * `ManualTrigger` is now called `PassiveTrigger`
    * `ScheduledTrigger` is now called `DateTimeTrigger`
    * `Measure` is now called `CAMSMeasure` (but `Measure` is part of `carp_core`)
* A `StudyProtocol` now uses the concept of a [`TriggeredTask`](https://pub.dev/documentation/carp_core/latest/carp_core/TriggeredTask-class.html) which is slightly different to the previous `Study` model. See the [example](https://pub.dev/packages/carp_core/example).
* A `CAMSStudyProtocol` now supports localization. A `StudyProtocolDescription` and a list of `ConsentSection` can be added to a protocol for each locale (i.e., language code).
* Similarly, measures now also supports localization. For each `CAMSMeasure` there is the option to specify its `MeasureDescription` for each locale.  
* All json serialization of a protocol now use `camelCase` instead of `snake_case` to be consistent with `carp_core` in Kotlin.
   * Note, however, that `DataPoint` objects are still serialized as `snake_case` json.
* All the `events` streams are now called `data` and streams `DataPoint` data objects (instead of just the `Datum` data objects). 
* The `DataPoint` comply to version 1.2 definition (Issue [#162](https://github.com/cph-cachet/carp.sensing-flutter/issues/162))

## 0.12.3
* extension of `Study` to include `purpose`, `title` and `PrincipalInvestigator`

## 0.12.2
* support for canceling `UserTask`

## 0.12.1
* small refactor for `Device` model.

## 0.12.0
* feature: support for handling devices as part of a study configuration.
* refactor: rename of `Device` to `DeviceInfo`

## 0.11.1
* feature: support for storing and retrieving study json protocols on the local file system.
* refactor: the `deploymentId` has been removed from `Study` since this is CARP specific info.

## 0.11.0
* refactor: improved (de)serialization in the `Serialization` class.
* refactor: named constructors in the `Study` and `Measure` classes.
* feature: support for handling local settings on the phone in the `Settings`.
* feature: added `description` property to `Measure`.
* feature: added support for an `AppTask` can expire, i.e. be removed from the queue.
* fix: issue [#139](https://github.com/cph-cachet/carp.sensing-flutter/issues/139)
* fix: issue [#140](https://github.com/cph-cachet/carp.sensing-flutter/issues/140)

## 0.10.1
* fix: issue [#123](https://github.com/cph-cachet/carp.sensing-flutter/issues/123)
* based on issue [#134](https://github.com/cph-cachet/carp.sensing-flutter/issues/134)
  the following measures has changed
    * `periodic_accelerometer` and `periodic_gyroscope` has been added
    * the "old" `accelerometer` and `gyroscope` measures are made to run continously
    * This implies that they need to be started and stopped using a `Trigger` instead. 
    * This, however, open up for triggering the collection of accelerometer data as part of an `AppTask`. For example, sampling accelerometer data while a Parkinson's patient fill in a survey.

## 0.10.0
* **BREAKING**: a new `AppTask` model is implemented
   * see documentation on the CAMS [wiki](https://github.com/cph-cachet/carp.sensing-flutter/wiki/3.1-The-AppTask-Model).
   * see the [Pulmonary app](https://github.com/cph-cachet/pulmonary_monitor_app) for an example on how to use this new model.
* fix: issue [#98](https://github.com/cph-cachet/carp.sensing-flutter/issues/98)
* fix: issue [#114](https://github.com/cph-cachet/carp.sensing-flutter/issues/114)

## 0.9.6
* fix: issue [#113](https://github.com/cph-cachet/carp.sensing-flutter/issues/113)

## 0.9.5
* feature: added the `validNextState()` method to the `Probe` class, which checks if a probe can be move to a next state.
* fix : issue [#112](https://github.com/cph-cachet/carp.sensing-flutter/issues/112) 
   * this means that the `initialize()` method is no longer a `Future` (and hence cannot be awaited)

## 0.9.4+1
* fix: issue [#106](https://github.com/cph-cachet/carp.sensing-flutter/issues/106).
* fix: fix of race condition in `FileDataManager`
* fix: small error in monthly recurrence in `RecurrentScheduledTrigger`
* refactor: `Device()` is now a singleton.

## 0.9.3
* refactor: all singleton adhering to the [Dart Singleton Pattern](https://scottt2.github.io/design-patterns-in-dart/singleton/).
  * `SamplingPackageRegistry`
  * `ProbeRegistry`
  * `TransformerSchemaRegistry`
  * `DataManagerRegistry`
* fix: fixed issue [#100](https://github.com/cph-cachet/carp.sensing-flutter/issues/100)
* feature: support for the `CronScheduledTrigger` that takes a cron expression for scheduling


## 0.9.2
* fix: error in screen probe
* refactor: small pedantic formatting issues
* refactor: `TransformerSchemaRegistry` and `SamplingPackageRegistry` are now accessed using an instance singleton

## 0.9.1
* refactor: using [pedantic](https://pub.dev/packages/pedantic#using-the-lints)

## 0.9.0
* refactor: new polymorphic JSON serialization using `$type` for class type identifier.
* docs: update of documentation and examples ([#92](https://github.com/cph-cachet/carp.sensing-flutter/issues/92))

## 0.8.8
* feature: support for saving ("remembering") `RecurrentScheduledTrigger` across app shutdown ([#80](https://github.com/cph-cachet/carp.sensing-flutter/issues/80))

## 0.8.7
* feature: support for monthly recurrences in `RecurrentScheduledTrigger` ([#78](https://github.com/cph-cachet/carp.sensing-flutter/issues/78))

## 0.8.6
* update: updated to the new pedometer API

## 0.8.5
* refactor: removed the Apps package and moved this to an external package

## 0.8.2
* refactor: converted from a plugin to a package by overhauling the project

## 0.8.1
* feature: support for Deployment ID in `Study`.
* update: upgrade to `screen_state` v. 1.x
* update: upgrade to [Android Embedding v2](https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects).

## 0.8.0
* using the Dart `Duration` class in many places where duration previously was specified using miliseconds.
* added the `MarkedMeasure` class for creating measures that collect all measures since last time data was collected.
Useful for collecting things like log entries and health data.
* added the `settings` global variable providing access to:
   * [`SharedPreferences`](https://pub.dev/documentation/shared_preferences/latest/shared_preferences/SharedPreferences-class.html) 
   * [`PackageInfo`](https://pub.dev/documentation/package_info/latest/package_info/PackageInfo-class.html), and 
   * a method for getting a unique, persistent user id 

## 0.7.2
* added support for better logging using the `DebugLevel` settings

## 0.7.1
* Added `trigger_id` to the `Trigger` class.
* Made `Task` abstract rather than deprecated.
* Fixed issue [#61](https://github.com/cph-cachet/carp.sensing-flutter/issues/61).

## 0.7.0
* **BREAKING**: this release break some parts of the previous API.
* Extended Task model -- introduction of a `AutomaticTask` and `AppTask`.
* Added support for "manually" adding data points (`Datum`) and errors to the data stream (`events`). This is part of the `StudyExecutor` API.
* The `start()` method on all executors (probes, and study, trigger & task executors) has been removed. 
Now an executor is 'started' by resuming it (calling `resume()`).
* Fixed a bug in `BufferingPeriodicStreamProbe`.
* Added the `FileDatum` data type which can hold a reference to a file. 
For example, an audio file (see the `carp_audio_package`).

## 0.6.5
* upgrade to `persmission_handler` v. 5.x

## 0.6.4
* Support 1.0.0 version of stable dependencies. ([dart_lsc](https://github.com/amirh/dart_lsc))

## 0.6.3
* moved the `connectivity` sampling package to an external [`carp_connectivity_package`](https://pub.dev/packages/carp_connectivity_package) 
  due to [issue#46](https://github.com/cph-cachet/carp.sensing-flutter/issues/46).

## 0.6.2
* intensive test of data upload to CARP and Firebase on both Android and iOS
* support for retry in upload of data to CARP
* handling that a study id can only be an integer in the CARP web services

## 0.6.1
* Thorough testing on iOS.
* Better handling of probes not available on iOS via the `initialize` method.
* Centralized concept for handling permissions.

## 0.6.0
* Extension of `Study` domain model to include support for
 `Trigger`, which manages the temporal triggering of data sampling.
 See the [documentation](https://github.com/cph-cachet/carp.sensing-flutter/wiki/2.-Domain-Model) on how to defined a study with triggers.
* Adjustment of runtime environment to reflect the new study model
   * Addition of a `TriggerExecutor`
   * Update to `Executors`, i.e. `StudyExecutor`, `TaskExecutor` and `Probe`
* The data manager model has been updated
   * A `DataManager` now expose a stream of state `events` as defined in `DataManagerEventTypes`
   * A `DataManager` now has a `type` which is a string as defined in `DataEndPointTypes`
   * These changes are also implemented for the file and CARP data managers.
* Minor refactoring
   * Apps and AppUsage are no longer periodic measure, but one-off measures.
     Hence, use the new trigger model to sample installed apps and their usage e.g. on a daily basis.
   * The `BluetoothDatum` now lists all devices found in a scan.
   * The pedometer now works as a simple step stream which sense and report each step taken.
   * `datastore` library have been renamed to `data_managers`.    
   
## 0.5.1
* Update of readme file.

## 0.5.0
* **BREAKING** This version has been migrated from the deprecated Android Support Library to *AndroidX*. 
This should not result in any functional changes, but it requires any Android app using this plugin to also 
[migrate](https://developer.android.com/jetpack/androidx/migrate) if they're using the original support library. 
   * See Flutter [AndroidX compatibility](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility)
* Fixed error in `PedometerProbe`

## 0.4.0
* support for data transformers
   * OMH Geolocation
   * OMH PhysicalActivity
* support for privacy schema
   * added support for hashing bluetooth names in the bluetooth package
* upgrade to json_serializable v.2

## 0.3.10
* minor change to the `StreamProbe` API - now non-static streams can be used by implementing the `get stream` method.
* update of the relevant sampling packages using `StreamProbe`

## 0.3.8+9
* update and rename of `CARPDataPoint` to `DataPoint` to reflect new CARP API.
* moved CARP web service specific data model to `CARPDataPoint` to the `carp_webservices` package.


## 0.3.5+7
* rename of `packages` folder to `sampling_packages` (seems like Dart Pub don't like folders called `packages`)
* rename of `core` folder to `domain`

## 0.3.3
* update to new versions of [CACHET Flutter Plugins](https://github.com/cph-cachet/flutter-plugins)
* rename of `probes` folder to `packages`
* upgrade and test on Flutter v. 1.3.4 Dart v. 2.2.1 

## 0.3.2
* support for dividing probes into separate sampling packages
* included in `carp_mobile_sensing` are
     * `device` (device, screen, memory, battery)
     * `sensors` (sensors, light, pedometer)
     * `connectivity` (connectivity, bluetooth)
     * `apps` (installed apps, app usage)
* implementation of the following **external** probe packages:
     * `communication` (sms & call log)
     * `context` (location, activity, weather)
     * `audio` (noise, audio recording)
     * `movisens` (Movisens Move/ECG devices)

## 0.3.1
* small updates to the data format incl. documentation on the [wiki](https://github.com/cph-cachet/carp.sensing-flutter/wiki/Sampling-Data-Formats).
* fixed error in the `stop` method.

## 0.3.0 - Domain Model update
* major updates to the domain model as a `core` library
    * `Measure` now have a `configuration`
* simplification to probe implementations
* all probes now uses the Dart `Stream` API and supports a reactive programming model
* all probes adjusted to a stream model
* implementation of `SamplingSchema` architecture
* support for power-aware sampling using different sampling schemas

## 0.2.6
* fixed small bug in `weater` probe.

## 0.2.5 
* small bug fixes in connectivity datum model (to work w. `carp_firebase_backend).
* `weather` probe added. 

## 0.2.4 
* error in `light` probe fixed.
* `noise` probe added.
* using the `carp_core` domain model

## 0.2.3
* fixed error in `readme` file.

## 0.2.2 
* `phone_log` probe added
* `audio` probe added
* `activity` probe added
* improvement to `readme` file on `manifest.xml` and `Info.plist`.


## 0.2.1 
* re-organization of github location and outline
* improvements to `FileDataManager` to avoid race conditions
* improved API documentation


## 0.2.0 
* refactor of organization of classes into libraries 
* complete API documentation

## 0.1.1 
* small improvements incl. documentation

## 0.1.0 
* removal of all remote backend code to separate packages

## 0.0.1 
* Initial version by Jakob E. Bardram 
* Transferring the old implementation to this carp.sensing-flutter framework 
* General refactor and clean-up

