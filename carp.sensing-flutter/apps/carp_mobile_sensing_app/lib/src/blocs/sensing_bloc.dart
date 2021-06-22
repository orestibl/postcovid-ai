part of mobile_sensing_app;

class SensingBLoC {
  CAMSMasterDeviceDeployment get deployment => Sensing().deployment;
  StudyDeploymentModel _model;

  /// What kind of deployment are we running - local or CARP?
  DeploymentMode deploymentMode = DeploymentMode.LOCAL;

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

  Future initialize([DeploymentMode deploymentMode]) async {
    this.deploymentMode = deploymentMode ?? DeploymentMode.LOCAL;
    await Settings().init();
    info('$runtimeType initialized');
  }

  void resume() async => Sensing().controller.resume();
  void pause() => Sensing().controller.pause();
  void stop() async => Sensing().controller.stop();
  void dispose() async => Sensing().controller.stop();
}

final bloc = SensingBLoC();
