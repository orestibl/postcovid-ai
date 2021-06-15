part of postcovid_ai;

class SensingBLoC {
  CAMSMasterDeviceDeployment get deployment => Sensing().deployment;
  StudyDeploymentModel _model;

  /// Dummy object to register json deserialization functions
  RPTask rpTask = new RPTask('ignored');

  /// The list of available app tasks for the user to address.
  List<UserTask> get tasks => AppTaskController().userTaskQueue;

  /// Is sensing running, i.e. has the study executor been resumed?
  bool get isRunning =>
      (Sensing().controller != null) &&
      Sensing().controller.executor.state == ProbeState.resumed;

  /// Get the study for this app.
  StudyDeploymentModel get studyDeploymentModel =>
      _model ??= StudyDeploymentModel(deployment);

  /// Get a list of running probes
  Iterable<ProbeModel> get runningProbes =>
      Sensing().runningProbes.map((probe) => ProbeModel(probe));

  /// Get a list of running devices
  Iterable<DeviceModel> get runningDevices =>
      Sensing().runningDevices.map((device) => DeviceModel(device));

  void connectToDevice(DeviceModel device) {
    Sensing().client?.deviceRegistry?.devices[device.type].connect();
  }

  Future initialize() async {
    await Settings().init();
    Settings().debugLevel = DebugLevel.DEBUG; //TODO: remove for production
    info('$runtimeType initialized');
  }

  void resume() async => Sensing().controller.resume();
  void pause() => Sensing().controller.pause();
  void stop() async => Sensing().controller.stop();
  void dispose() async => Sensing().controller.stop();
}

final bloc = SensingBLoC();
