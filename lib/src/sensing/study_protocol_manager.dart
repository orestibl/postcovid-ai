/*
 * Copyright 2021 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */

part of postcovid_ai;

/// This is a simple local [StudyProtocolManager].
///
/// This class shows how to configure a [StudyProtocol] with [Tigger]s,
/// [TaskDescriptor]s and [Measure]s.
class LocalStudyProtocolManager implements StudyProtocolManager {
  Future initialize() async {}

  /// Create a new CAMS study protocol.
  Future<StudyProtocol> getStudyProtocol(String ignored) async {
    CAMSStudyProtocol protocol = CAMSStudyProtocol()
      ..name = '#23-Coverage'
      ..dataEndPoint = CarpDataEndPoint(
          uploadMethod: CarpUploadMethod.DATA_POINT,
          name: 'CARP Staging Server',
          uri: uri,
          clientId: clientID,
          clientSecret: clientSecret,
          email: username,
          password: password)
      ..owner = ProtocolOwner(
        id: 'AB',
        name: 'Alex Boyon',
        email: 'alex@uni.dk',
      )
      ..protocolDescription = StudyProtocolDescription(
        title: 'Sensing Coverage Study',
        description: 'This is a study for testing the coverage of sampling.',
      );

    // Define which devices are used for data collection.
    Smartphone phone = Smartphone();

    protocol..addMasterDevice(phone);

    protocol.addTriggeredTask(
        ImmediateTrigger(),
        AutomaticTask()
          ..measures = SamplingPackageRegistry().common().getMeasureList(
            types: [
              ContextSamplingPackage.ACTIVITY,
              ContextSamplingPackage.MOBILITY,
              ContextSamplingPackage.WEATHER,
              AudioSamplingPackage.NOISE,
              ConnectivitySamplingPackage.CONNECTIVITY,
            ],
          ),
        phone);

    protocol.addTriggeredTask(
        ImmediateTrigger(),
        AutomaticTask()
          ..measures = [
            LocationMeasure(
              type: "dk.cachet.carp.geolocation",
              name: 'Geo-location',
              description: "Collects location from the phone's GPS sensor",
              enabled: false,
              frequency: Duration(hours: 6),
              notificationTitle: "POSTCOVID-AI",
              notificationMsg: "Notification to keep app sensing",
              accuracy: GeolocationAccuracy.low,
              distance: 3,
            )
          ],
        phone);

    protocol.addTriggeredTask(
        ImmediateTrigger(),
        AutomaticTask()
          ..measures = [
            PeriodicMeasure(
              type: 'dk.cachet.carp.periodic_accelerometer',
              name: 'Accelerometer',
              description:
                  'Collects movement data based on the onboard phone accelerometer sensor.',
              enabled: true,
              frequency: const Duration(minutes: 25),
              duration: const Duration(seconds: 1),
            )
          ],
        phone);
/*
    protocol.addTriggeredTask(
        RandomRecurrentTrigger(
          startTime: Time(hour: 23, minute: 56),
          endTime: Time(hour: 24, minute: 0),
          minNumberOfTriggers: 2,
          maxNumberOfTriggers: 8,
        ),
        AutomaticTask()
          ..measures = SamplingPackageRegistry().debug().getMeasureList(
            types: [
              DeviceSamplingPackage.DEVICE,
              ContextSamplingPackage.LOCATION,
            ],
          ),
        phone);

    protocol.addTriggeredTask(
        PeriodicTrigger(period: Duration(minutes: 5)), // 5 min
        AutomaticTask()
          ..measures = SamplingPackageRegistry().debug().getMeasureList(
            types: [
              ContextSamplingPackage.WEATHER,
              ContextSamplingPackage.AIR_QUALITY,
            ],
          ),
        phone);
*/
    return protocol;
  }

  Future<bool> saveStudyProtocol(String studyId, StudyProtocol protocol) async {
    throw UnimplementedError();
  }
}
