part of research_package_model;

/// The [RPTask] class defines a task to be carried out by a
/// participant in a research study.
///
/// This class is the base class in different types of tasks, like [RPOrderedTask]
/// and not used as such.
///
/// Extend this [RPTask] class to enable dynamic selection of the steps for a given
/// task. By default, [RPOrderedTask] extends this class for simple
/// sequential tasks. Each step ([RPStep]) in a task roughly corresponds to one
/// screen through their [stepWidget] Widget, and represents the primary unit of
/// work in any task presented by a task view controller.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class RPTask extends Serializable {
  String _identifier;

  RPTask(String identifier, {this.closeAfterFinished}) {
    _registerFromJsonFunctions();
    this._identifier = identifier;
  }

  /// A unique identifier of the Task. This identifier connects the Task to its
  /// result ([RPTaskResult]) object.
  String get identifier => _identifier;

  /// If set to `true` the Task will close after the participant has finished
  /// the task. If it's set to `false` no navigation function is called.
  ///
  /// Navigation or closing is still possible for example in the [onSubmit]
  /// function of [RPUIOrderedTask].
  bool closeAfterFinished;

  /// Returns the step after a specified step if there's any.
  RPStep getStepAfterStep(RPStep step, RPTaskResult result) => null;

  /// Returns the step that precedes the specified step, if there is one.
  RPStep getStepBeforeStep(RPStep step, RPTaskResult result) => null;

  /// Returns the step that matches the specified [identifier].
  RPStep getStepWithIdentifier(String identifier) => null;

//  /// Returns the progress of the current step.
//  RPTaskProgress getProgressOfCurrentStep(RPStep step, RPTaskResult result);

  /// Returns the title of a given [step]
  String getTitleForStep(RPStep step) => '';

  //TODO: Validates the task parameters.

  Function get fromJsonFunction => _$RPTaskFromJson;
  factory RPTask.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);
  Map<String, dynamic> toJson() => _$RPTaskToJson(this);
}

/// Simple class for keeping track the progress of the task. It contains the
/// number of the current step and the total number of steps.
///
/// Used by the counter in [RPUIQuestionStep] in the App Bar
class RPTaskProgress {
  int _current;
  int _total;

  RPTaskProgress(this._current, this._total);

  /// Number of the current step
  get current => this._current;

  /// Total number of steps in task
  get total => this._total;
}
