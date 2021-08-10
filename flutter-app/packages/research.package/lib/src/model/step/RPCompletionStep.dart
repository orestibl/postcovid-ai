part of research_package_model;

/// A step which can be used as a "Thank you" or completion step in a task.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class RPCompletionStep extends RPStep {
  RPCompletionStep(String identifier) : super(identifier);

  /// The widget (UI representation) of the step
  ///
  /// It shows the [title] with large font and the [text] in smaller font.
  /// Also it shows the participant an animation and a "Done" button.
  @override
  Widget get stepWidget => RPUICompletionStep(step: this);

  Function get fromJsonFunction => _$RPCompletionStepFromJson;
  factory RPCompletionStep.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);
  Map<String, dynamic> toJson() => _$RPCompletionStepToJson(this);
}
