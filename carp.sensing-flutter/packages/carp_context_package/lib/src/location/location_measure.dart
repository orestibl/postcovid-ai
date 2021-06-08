/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of context;

enum GeolocationAccuracy {
  lowest,
  low,
  medium,
  high,
  best,
  bestForNavigation,
}

/// Specify the configuration on how to collect location data.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class LocationMeasure extends PeriodicMeasure {
  /// Defines the desired accuracy that should be used to determine the location data.
  ///
  /// The default value for this field is GeolocationAccuracy.best.
  GeolocationAccuracy accuracy;

  /// The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
  ///
  /// Specify 0 when you want to be notified of all movements. The default is 0.
  double distance = 0;

  /// The title of the notification to be shown to the user when
  /// location tracking takes place in the background.
  String notificationTitle = 'CARP Location Probe';

  /// The message in the notification to be shown to the user when
  /// location tracking takes place in the background.
  String notificationMsg = 'CARP location tracking';

  LocationMeasure({
    @required String type,
    String name,
    String description,
    bool enabled,
    Duration frequency,
    Duration duration,
    this.accuracy = GeolocationAccuracy.best,
    this.distance = 0,
    this.notificationTitle,
    this.notificationMsg,
  })
      : super(
            type: type,
            name: name,
            description: description,
            enabled: enabled,
            frequency: frequency,
            duration: duration);

  Function get fromJsonFunction => _$LocationMeasureFromJson;
  factory LocationMeasure.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);
  Map<String, dynamic> toJson() => _$LocationMeasureToJson(this);

  String toString() => super.toString() + ', accuracy: $accuracy';
}
