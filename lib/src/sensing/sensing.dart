/*
 * Copyright 2021 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of postcovid_ai;

/// This class implements the sensing layer incl. setting up a [StudyProtocol]
/// with [Task]s and [Measure]s.
class Sensing {
  static final Sensing _instance = Sensing._();
  StudyDeploymentStatus _status;
  StudyDeploymentController _controller;

  DeploymentService deploymentService;
  SmartPhoneClientManager client;
  StudyProtocol protocol;

  /// *** Runtime variables ***

  /// The deployment is running on this phone
  CAMSMasterDeviceDeployment get deployment => _controller?.deployment;

  /// Get the latest status of the study deployment.
  StudyDeploymentStatus get status => _status;

  /// The role name of this device in the deployed study
  String get deviceRolename => _status?.masterDeviceStatus?.device?.roleName;

  /// The study deployment id of the deployment running on this phone
  String get studyDeploymentId => _status?.studyDeploymentId;

  /// The study runtime controller for this deployment
  StudyDeploymentController get controller => _controller;

  /// the list of running - i.e. used - probes in this study.
  List<Probe> get runningProbes =>
      (_controller != null) ? _controller.executor.probes : [];

  /// the list of connected devices.
  List<DeviceManager> get runningDevices =>
      client?.deviceRegistry?.devices?.values?.toList();

  /// Get the singleton sensing instance
  factory Sensing() => _instance;

  Sensing._() {
    // create and register external sampling packages
    //SamplingPackageRegistry().register(ConnectivitySamplingPackage());
    SamplingPackageRegistry().register(ContextSamplingPackage());
    SamplingPackageRegistry().register(AudioSamplingPackage());
    SamplingPackageRegistry().register(SurveySamplingPackage());
    //SamplingPackageRegistry().register(CommunicationSamplingPackage());
    //SamplingPackageRegistry().register(SensorSamplingPackage());
  }

  /// *** Initialize and setup sensing ***

  Future<void> initialize() async {
    info('Initializing $runtimeType');

    // set up the devices available on this phone
    DeviceController().registerAllAvailableDevices();

    // use the CARP deployment service that knows how to download a
    // custom protocol
    deploymentService = CustomProtocolDeploymentService();

    // authenticate the user
    if (!CarpService().authenticated)
      await CarpService().authenticate(username: username, password: password);

    // Get current user id
    CarpUser user = await CarpService().getCurrentUserProfile();

    // Download custom protocol
    //protocol = await CANSProtocolService().getBy(StudyProtocolId(user.accountId, testProtocolName));
    // DEBUG - Local protocol
    LocalStudyProtocolManager localStudyProtocolManager = LocalStudyProtocolManager();
    localStudyProtocolManager.userID = user.accountId;
    StudyProtocol protocol = await localStudyProtocolManager.getStudyProtocol("");

    // Create deployment for this user
    _status = await CarpDeploymentService().createStudyDeployment(protocol);

    // Now register the CARP data manager for uploading data back to CARP
    DataManagerRegistry().register(CarpDataManager());

    //create and configure a client manager for this phone
    client = SmartPhoneClientManager(
      deploymentService: deploymentService,
      deviceRegistry: DeviceController(),
    );
    await client.configure(); //TODO: set userId as deviceId in the client configuration. Now is not possible because the study has not been already deployed here, so the userId has not been generated yet.

    // add and deploy this deployment
    _controller = await client.addStudy(studyDeploymentId, deviceRolename);

    // Set data endpoint to deployment
    CarpDataEndPoint dataEndPoint = CarpDataEndPoint(
        uploadMethod: CarpUploadMethod.DATA_POINT,
        uri: uri,
        name: "CANS Production @ UGR",
        clientId: clientID,
        clientSecret: clientSecret,
        email: username,
        password: password
    );
    deployment.dataEndPoint = dataEndPoint;

    // configure the controller with the default privacy schema
    await _controller.configure(
      privacySchemaName: PrivacySchema.DEFAULT,
    );
    // controller.resume();

    // listening on the data stream and print them as json to the debug console
    _controller.data.listen((data) => print(toJsonString(data)));

    info('$runtimeType initialized');
  }
}
