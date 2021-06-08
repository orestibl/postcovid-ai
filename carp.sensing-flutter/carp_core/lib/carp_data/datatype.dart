/*
 * Copyright 2021 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
part of carp_core_data;

/// Specifies the type of a [Measure].
///
/// Defines a type of data which can be processed by the platform
/// (e.g., measured / collected / uploaded).
/// This is used by the infrastructure to determine whether the requested data
/// can be collected on a device, how to upload it, how to process it in a
/// secondary data stream, or how triggers can act on it.
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class DataType {
  static const DataType UNKNOWN = DataType(NameSpace.UNKNOWN, 'unknown');

  /// The data type namespace. See [NameSpace].
  ///
  /// Uniquely identifies the organization/person who determines how to
  /// interpret [name].
  /// To prevent conflicts, a reverse domain namespace is suggested:
  /// e.g., "org.openmhealth" or "dk.cachet.carp".
  final String namespace;

  /// The name of this data format.
  ///
  /// Uniquely identifies something within the [namespace].
  /// The name may not contain any periods. Periods are reserved for namespaces.
  final String name;

  /// Create a [DataType].
  const DataType(this.namespace, this.name) : super();

  factory DataType.fromString(String type) {
    assert(type.contains('.'),
        "A data type must contain both a namespace and a name separated with a '.'");
    final String name = type.split('.').last;
    final String namespace = type.substring(0, type.indexOf(name) - 1);
    return DataType(namespace, name);
  }

  String toString() => '$namespace.$name';

  bool operator ==(other) {
    if (other is! String) return false;
    return (other.namespace == namespace && other.name == name);
  }

  // taken from https://dart.dev/guides/libraries/library-tour#implementing-map-keys
  int get hashCode {
    var result = 17;
    result = 37 * result + namespace.hashCode;
    result = 37 * result + name.hashCode;
    return result;
  }

  factory DataType.fromJson(Map<String, dynamic> json) =>
      _$DataTypeFromJson(json);
  Map<String, dynamic> toJson() => _$DataTypeToJson(this);
}

/// Enumeration of data type namespaces.
///
/// Namespaces are used in specification of [String] both when sensing
/// and uploading [Data].
///
/// Currently know namespaces include:
/// * `dk.cachet.carp`  : CACHET Research Platform (CARP)
/// *            `omh`  : Open mHealth
class NameSpace {
  static const String UNKNOWN = 'unknown';
  static const String OMH = 'omh';
  static const String CARP = 'dk.cachet.carp';
}
