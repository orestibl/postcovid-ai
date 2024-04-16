part of research_package_model;

/// Class representing an Answer Format that lets participants use a slider
/// to choose a value.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class RPSliderAnswerFormat extends RPAnswerFormat {
  /// The minimum value of the range.
  double minValue;

  /// The maximum value of the range.
  double maxValue;

  /// The divisions of the range.
  int divisions;

  /// The initial value of the slider.
  double initValue;

  /// The prefix displayed before the value.
  String prefix;

  /// The suffix displayed after yhe value.
  String suffix;

  RPSliderAnswerFormat({
    this.minValue,
    this.maxValue,
    this.divisions,
    this.initValue,
    this.prefix = '',
    this.suffix = '',
  }) : super();

  @override
  get questionType => RPQuestionType.Scale;

  Function get fromJsonFunction => _$RPSliderAnswerFormatFromJson;
  factory RPSliderAnswerFormat.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);
  Map<String, dynamic> toJson() => _$RPSliderAnswerFormatToJson(this);
}
