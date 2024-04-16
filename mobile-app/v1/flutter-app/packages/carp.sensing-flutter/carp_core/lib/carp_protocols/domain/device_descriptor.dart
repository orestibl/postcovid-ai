/*
 * Copyright 2021 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of carp_core_protocols;

/// Describes any type of electronic device, such as a smartphone, wearable
/// device, a sensor, or internet service (e.g. FitBit API) that collects data
/// which can be part of a [StudyProtocol] configuration and which collects measures
/// via probes.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class DeviceDescriptor extends Serializable {
  static const DEVICE_NAMESPACE = 'dk.cachet.carp.protocols.domain.devices';

  DeviceDescriptor({
    this.roleName,
    this.isMasterDevice = false,
    this.supportedDataTypes,
  })
      : super();

  /// The device type identifier
  @JsonKey(ignore: true)
  String get type => jsonType;

  /// Is this the master device?
  bool isMasterDevice;

  /// The role name of this device in a specific [StudyProtocol].
  /// For example, 'Parent's phone' or 'Child phone'.
  String roleName;

  /// The set of data types which can be collected on this device.
  List<String> supportedDataTypes = [];

  /// Sampling configurations for data types available on this device which
  /// override the default configuration.
  Map<String, SamplingConfiguration> samplingConfiguration = {};

  String toString() =>
      '$runtimeType - roleName: $roleName, isMasterDevice: $isMasterDevice';

  Function get fromJsonFunction => _$DeviceDescriptorFromJson;
  factory DeviceDescriptor.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);
  Map<String, dynamic> toJson() => _$DeviceDescriptorToJson(this);
  String get jsonType => '$DEVICE_NAMESPACE.$runtimeType';
}

/// A device which aggregates, synchronizes, and optionally uploads incoming
/// data received from one or more connected devices (potentially just itself).
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class MasterDeviceDescriptor extends DeviceDescriptor {
  MasterDeviceDescriptor({
    String roleName,
    List<String> supportedDataTypes,
  })
      : super(
          roleName: roleName,
          isMasterDevice: true,
          supportedDataTypes: supportedDataTypes,
        );

  Function get fromJsonFunction => _$MasterDeviceDescriptorFromJson;
  factory MasterDeviceDescriptor.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);
  Map<String, dynamic> toJson() => _$MasterDeviceDescriptorToJson(this);
}

/// A general-purpose master device for custom protols.
/// Only used when downloading custom protocols from the CARP web service.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class CustomProtocolDevice extends MasterDeviceDescriptor {
  /// The default rolename for a custom protocol device.
  static const String DEFAULT_ROLENAME = 'Custom device';

  /// Create a new [CustomProtocolDevice] device descriptor.
  /// If [roleName] is not specified, then the  [DEFAULT_ROLENAME] is used.
  CustomProtocolDevice({
    String roleName = DEFAULT_ROLENAME,
    List<String> supportedDataTypes,
  })
      : super(
          roleName: roleName,
          supportedDataTypes: supportedDataTypes,
        );

  Function get fromJsonFunction => _$CustomProtocolDeviceFromJson;
  factory CustomProtocolDevice.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);
  Map<String, dynamic> toJson() => _$CustomProtocolDeviceToJson(this);
}

/// An internet-connected phone with built-in sensors.
/// Typically this phone for a [StudyProtocol] running on this phone.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class Smartphone extends MasterDeviceDescriptor {
  /// The type of a smartphone master device.
  static const String DEVICE_TYPE =
      '${DeviceDescriptor.DEVICE_NAMESPACE}.Smartphone';

  /// The default rolename for a smartphone master device.
  static const String DEFAULT_ROLENAME = 'masterphone';

  /// Create a new Smartphone device descriptor.
  /// If [roleName] is not specified, then the  [DEFAULT_ROLENAME] is used.
  Smartphone({
    String roleName = DEFAULT_ROLENAME,
    List<String> supportedDataTypes,
  })
      : super(
          roleName: roleName,
          supportedDataTypes: supportedDataTypes,
        );

  Function get fromJsonFunction => _$SmartphoneFromJson;
  factory Smartphone.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);
  Map<String, dynamic> toJson() => _$SmartphoneToJson(this);
}

/// A beacon meeting the open AltBeacon standard.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class AltBeacon extends DeviceDescriptor {
  AltBeacon({
    String roleName,
    List<String> supportedDataTypes,
  })
      : super(
          roleName: roleName,
          isMasterDevice: false,
          supportedDataTypes: supportedDataTypes,
        );

  Function get fromJsonFunction => _$AltBeaconFromJson;
  factory AltBeacon.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);
  Map<String, dynamic> toJson() => _$AltBeaconToJson(this);
}
