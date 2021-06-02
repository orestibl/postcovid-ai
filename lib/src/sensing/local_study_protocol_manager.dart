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
      ..name = '#24-Local CAMS app protocol'
      ..protocolDescription = StudyProtocolDescription(
        title: 'Sensing Coverage Study',
        description: 'This is a study for testing the coverage of sampling. '
            'This is the version of the protocol generated locally on the phone.',
      );

    // Define which devices are used for data collection.
    Smartphone phone = Smartphone();

    protocol..addMasterDevice(phone);

    protocol.addTriggeredTask(
        ImmediateTrigger(),
        AutomaticTask()
          ..measures = SamplingPackageRegistry().debug().getMeasureList(
            types: [
              // ConnectivitySamplingPackage.CONNECTIVITY,
              // ConnectivitySamplingPackage.WIFI, // 60 s
              AudioSamplingPackage.NOISE, // 60 s
              ContextSamplingPackage.ACTIVITY, // ~3 s
              ContextSamplingPackage.MOBILITY, // ~3 s
              ContextSamplingPackage.WEATHER,
            ],
          ),
        phone);

    // protocol.addTriggeredTask(
    //     RandomRecurrentTrigger(
    //       startTime: Time(hour: 23, minute: 56),
    //       endTime: Time(hour: 24, minute: 0),
    //       minNumberOfTriggers: 2,
    //       maxNumberOfTriggers: 8,
    //     ),
    //     AutomaticTask()
    //       ..measures = SamplingPackageRegistry().debug().getMeasureList(
    //         types: [
    //           DeviceSamplingPackage.DEVICE,
    //           ContextSamplingPackage.LOCATION,
    //         ],
    //       ),
    //     phone);

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

    // collect demographics & location once when the study starts
    // protocol.addTriggeredTask(
    //     ImmediateTrigger(),
    //     AppTask(
    //       type: SurveyUserTask.SURVEY_TYPE,
    //       title: "IMMEDIATE SURVEY",
    //       description: "test of immediate survey",
    //     )..measures.add(RPTaskMeasure(
    //         type: SurveySamplingPackage.SURVEY,
    //         surveyTask: linearSurveyTask,
    //       )),
    //     phone);
    //
    // // collect symptoms on a daily basis
    // protocol.addTriggeredTask(
    //     PeriodicTrigger(period: Duration(minutes: 1)),
    //     AppTask(
    //       type: SurveyUserTask.SURVEY_TYPE,
    //       title: "PERIODIC SURVEY",
    //       description: "test of periodic survey",
    //     )..measures.add(RPTaskMeasure(
    //         type: SurveySamplingPackage.SURVEY,
    //         surveyTask: linearSurveyTask,
    //       )),
    //     phone);

    return protocol;
  }

  Future<bool> saveStudyProtocol(String studyId, StudyProtocol protocol) async {
    throw UnimplementedError();
  }
}
