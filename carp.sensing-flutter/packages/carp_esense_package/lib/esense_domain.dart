/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of esense;

/// Specify the configuration on how to collect eSense data.
/// Needs an [deviceName] for the eSense device to connect to.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class ESenseMeasure extends CAMSMeasure {
  /// The name of the eSense device.
  /// Used for connecting to the eSense hardware device over BTLE.
  String deviceName;

  /// The sampling rate in Hz of getting sensor data from the device.
  ///
  /// Default sampling rate is 10 Hz.
  int samplingRate = 10;

  /// Create an eSense messure confgiration.
  /// [type] and [deviceName] are required.
  ESenseMeasure({
    String type,
    String name,
    String description,
    enabled = true,
    this.deviceName,
    this.samplingRate = 10,
  })
      : super(
            type: type, name: name, description: description, enabled: enabled);

  Function get fromJsonFunction => _$ESenseMeasureFromJson;
  factory ESenseMeasure.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);
  Map<String, dynamic> toJson() => _$ESenseMeasureToJson(this);

  String toString() => super.toString() + ', deviceName: $deviceName';
}

/// Abstract eSense datum class.
abstract class ESenseDatum extends Datum {
  /// The name of eSense device.
  String deviceName;

  ESenseDatum([this.deviceName]) : super();
}

/// Holds information about an eSense button pressed event.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ESenseButtonDatum extends ESenseDatum {
  DataFormat get format =>
      DataFormat.fromString(ESenseSamplingPackage.ESENSE_BUTTON);

  ESenseButtonDatum({String deviceName, this.pressed}) : super(deviceName);

  factory ESenseButtonDatum.fromButtonEventChanged(ButtonEventChanged event) =>
      ESenseButtonDatum(deviceName: '', pressed: event.pressed);

  factory ESenseButtonDatum.fromJson(Map<String, dynamic> json) =>
      _$ESenseButtonDatumFromJson(json);

  Map<String, dynamic> toJson() => _$ESenseButtonDatumToJson(this);

  /// true if the button is pressed, false if it is released
  bool pressed;

  String toString() => super.toString() + ', button pressed: $pressed';
}

/// Holds information about an eSense button pressed event.
///
/// This datum is a 1:1 mapping of the
/// eSense [SensorEvent](https://pub.dev/documentation/esense/latest/esense/SensorEvent-class.html) event.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ESenseSensorDatum extends ESenseDatum {
  DataFormat get format =>
      DataFormat.fromString(ESenseSamplingPackage.ESENSE_SENSOR);

  /// Sequential number of sensor packet
  ///
  /// The eSense device don't have a clock, so this index reflect the order of reading.
  int packetIndex;

  /// 3-elements array with X, Y and Z axis for accelerometer
  List<int> accel;

  /// 3-elements array with X, Y and Z axis for gyroscope
  List<int> gyro;

  ESenseSensorDatum(
      {String deviceName,
      DateTime timestamp,
      this.packetIndex,
      this.accel,
      this.gyro})
      : super(deviceName) {
    this.timestamp ??= timestamp;
  }

  factory ESenseSensorDatum.fromSensorEvent(
          {String deviceName, SensorEvent event}) =>
      ESenseSensorDatum(
          deviceName: deviceName,
          timestamp: event.timestamp,
          packetIndex: event.packetIndex,
          gyro: event.gyro,
          accel: event.accel);

  factory ESenseSensorDatum.fromJson(Map<String, dynamic> json) =>
      _$ESenseSensorDatumFromJson(json);

  Map<String, dynamic> toJson() => _$ESenseSensorDatumToJson(this);

  String toString() =>
      super.toString() +
      ', packetIndex: $packetIndex, accl: [${accel[0]},${accel[1]},${accel[2]}], gyro: [${gyro[0]},${gyro[1]},${gyro[2]}]';
}
