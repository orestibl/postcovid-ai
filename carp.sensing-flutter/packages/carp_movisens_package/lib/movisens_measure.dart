/*
 * Copyright 2019 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
part of movisens;

/// A [Measure] for configuring a Movisens EcgMove device.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class MovisensMeasure extends CAMSMeasure {
  /// The MAC address of the sensor.
  String address;

  /// The user-friendly name of the sensor.
  String deviceName;

  /// Weight of the person wearing the Movisens device in kg.
  int weight;

  /// Height of the person wearing the Movisens device in cm.
  int height;

  /// Age of the person wearing the Movisens device in years.
  int age;

  /// Gender of the person wearing the Movisens device, male or female.
  Gender gender;

  /// Sensor placement on body
  SensorLocation sensorLocation;

  MovisensMeasure({
    String type,
    String name,
    String description,
    bool enabled,
    this.address,
    this.sensorLocation,
    this.gender,
    this.deviceName,
    this.height,
    this.weight,
    this.age,
  })
      : super(
            type: type, name: name, description: description, enabled: enabled);

  Function get fromJsonFunction => _$MovisensMeasureFromJson;
  factory MovisensMeasure.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);
  Map<String, dynamic> toJson() => _$MovisensMeasureToJson(this);
}
