part of context;

/// Specify the configuration on how to measure mobility features
@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false)
class MobilityMeasure extends CAMSMeasure {
  /// Should prior computed context be used?
  bool usePriorContexts;

  // The radius of a stop.
  double stopRadius;

  // The radius for registring a place.
  double placeRadius;

  /// The duration of a stop (minimum).
  Duration stopDuration;

  MobilityMeasure({
    @required String type,
    String name,
    String description,
    bool enabled,
    this.usePriorContexts,
    this.stopRadius,
    this.placeRadius,
    this.stopDuration,
  })
      : super(
            type: type, name: name, description: description, enabled: enabled);

  Function get fromJsonFunction => _$MobilityMeasureFromJson;

  factory MobilityMeasure.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);

  Map<String, dynamic> toJson() => _$MobilityMeasureToJson(this);

  String toString() =>
      super.toString() +
      ',usePriorContext: $usePriorContexts,'
      'stopRadius: $stopRadius,'
      'placeRadius: $placeRadius,'
      'stopDuration: $stopDuration';
}
