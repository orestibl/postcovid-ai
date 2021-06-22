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

  String userID;

  /// Create a new CAMS study protocol.
  Future<StudyProtocol> getStudyProtocol(String ignored) async {
    CAMSStudyProtocol protocol = CAMSStudyProtocol()
      ..name = 'test_protocol_rp'
      ..description = 'Remote test protocol with RP tasks'
      ..ownerId = userID;

    // Define which devices are used for data collection.
    Smartphone phone = Smartphone();
    protocol..addMasterDevice(phone);

    // Sensors
    protocol.addTriggeredTask(
        ImmediateTrigger(),
        AutomaticTask()
          ..measures = [
            NoiseMeasure(
              type: AudioSamplingPackage.NOISE,
              name: 'Ambient Noise',
              description:
                  "Collects noise in the background from the phone's microphone",
              enabled: true,
              frequency: Duration(minutes: 1), // Sample each minute
              duration: Duration(
                  seconds: 5), // Measures during 5 secs and outputs the average
            ),
            CAMSMeasure(
              type: ContextSamplingPackage.ACTIVITY,
              description:
                  "Collects activity type from the phone's activity recognition module",
              enabled: true,
            ),
            MobilityMeasure(
              type: ContextSamplingPackage.MOBILITY,
              name: 'Mobility Features',
              description:
                  "Extracts mobility features based on location tracking",
              enabled: true,
              placeRadius: 50,
              stopRadius: 25,
              usePriorContexts: true,
              stopDuration: Duration(minutes: 3),
            ),
            WeatherMeasure(
                type: ContextSamplingPackage.WEATHER,
                name: 'Weather',
                description:
                    "Collects local weather from the WeatherAPI web service",
                enabled: true,
                apiKey: '12b6e28582eb9298577c734a31ba9f4f'),
            LocationMeasure(
              type: ContextSamplingPackage.GEOLOCATION,
              name: 'Geolocation',
              description: "Collects location from the phone's GPS sensor",
              enabled: true,
              frequency: Duration(seconds: 1), // Measure every second
              notificationTitle: "POSTCOVID-AI",
              notificationMsg:
                  "Notification of Location Measure to keep the app sensing",
            ),
          ],
        phone);

    // Survey
    protocol.addTriggeredTask(
        PeriodicTrigger(period: Duration(seconds: 15) // Frequency of the survey
            ),
        AppTask(
          type: SurveyUserTask.SURVEY_TYPE,
          title: "SURVEY",
          description: "test of survey",
        )..measures = [
            RPTaskMeasure(
                type: 'dk.cachet.carp.survey',
                enabled: true,
                surveyTask: RPOrderedTask("surveyTaskID", [
                  RPInstructionStep(
                    "instructionID",
                    title: "Welcome!",
                    detailText: "This is a test of a instruction step",
                  )..text = "Please fill out this questionnaire!",
                  RPQuestionStep("questionID",
                      title: "Boolean question",
                      answerFormat: RPBooleanAnswerFormat(
                          trueText: "YES", falseText: "NO"))
                ]))
          ],
        phone);

    /// Create a new CustomProtocol
    StudyProtocol customProtocol = StudyProtocol(
        name: protocol.name,
        description: protocol.description,
        ownerId: protocol.ownerId);

    // Define which devices are used for data collection.
    CustomProtocolDevice customDevice = CustomProtocolDevice();
    customProtocol..addMasterDevice(customDevice);

    // Add task
    customProtocol.addTriggeredTask(
        ElapsedTimeTrigger(elapsedTime: Duration(seconds: 0))
          ..sourceDeviceRoleName = customDevice.roleName,
        CustomProtocolTask(
            name: 'Custom device task', studyProtocol: toJsonString(protocol)),
        customDevice);

    return customProtocol;
  }

  Future<bool> saveStudyProtocol(String studyId, StudyProtocol protocol) async {
    throw UnimplementedError();
  }
}
