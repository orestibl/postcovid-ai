part of postcovid_ai;

class StudyDeploymentModel {
  CAMSMasterDeviceDeployment deployment;

  String get name => deployment?.name ?? '';
  String get title => deployment?.protocolDescription?.title ?? '';
  String get description =>
      deployment?.protocolDescription?.description ??
      'No description available.';
  Image get image => Image.asset('assets/logo/app_icon.png');
  String get studyId => deployment?.studyId ?? '';
  String get studyDeploymentId => deployment?.studyDeploymentId ?? '';
  String get userID => deployment?.userId ?? '';
  // String get samplingStrategy => 'NORMAL';
  String get dataEndpoint => deployment?.dataEndPoint.toString() ?? '';

  /// Events on the state of the study executor
  Stream<ProbeState> get studyExecutorStateEvents =>
      Sensing().controller.executor.stateEvents;

  /// Current state of the study executor (e.g., resumed, paused, ...)
  ProbeState get studyState => Sensing().controller.executor.state;

  /// Get all sesing events (i.e. all [Datum] objects being collected).
  Stream<DataPoint> get data => Sensing().controller.data;

  /// The total sampling size so far since this study was started.
  int get samplingSize => Sensing().controller.samplingSize;

  StudyDeploymentModel(this.deployment)
      : assert(deployment != null,
            'A StudyDeploymentModel must be initialized with a non-null CAMSMasterDeviceDeployment.'),
        super();
}
