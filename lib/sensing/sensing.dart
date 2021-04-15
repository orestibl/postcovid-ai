part of postcovid_ai;

class Sensing implements StudyManager {
  Survey testSurvey = TestSurvey();
  Study study;
  StudyController controller;

  /// the list of running - i.e. used - probes in this study.
  List<Probe> get runningProbes =>
      (controller != null) ? controller.executor.probes : List();

  Sensing() : super() {
    // create and register external sampling packages
    SamplingPackageRegistry().register(ConnectivitySamplingPackage());
    SamplingPackageRegistry().register(ContextSamplingPackage());
    SamplingPackageRegistry().register(AudioSamplingPackage());
    SamplingPackageRegistry().register(SurveySamplingPackage());

    // create and register external data managers
    DataManagerRegistry().register(CarpDataManager());
  }

  /// Start sensing.
  Future start() async {
    // Get the study.
    study = await this.getStudy(settings.studyId);

    // Create a Study Controller that can manage this study, initialize it, and start it.
    controller = StudyController(
      study,
      debugLevel: DebugLevel.DEBUG,
    );
    await controller.initialize();

    // start sensing
    controller.resume();

    // listening on all data events from the study and print it (for debugging purpose).
    controller.events.forEach(print);
  }

  /// Stop sensing.
  void stop() async {
    controller.stop();
    study = null;
  }

  Future initialize() => null;

  Future<Study> getStudy(String studyId) async {
    if (study == null) {
      study = Study(id: studyId, userId: await settings.userId)
        ..name = 'POSTCOVID-AI'
        ..description = "Fork from pulmonary monitor app"
        ..dataEndPoint =
            getDataEndpoint(DataEndPointTypes.CARP) // TODO use CARP here
        // Measure sensors every 5 mins
        ..addTriggerTask(
            PeriodicTrigger(period: Duration(minutes: 5)),
            Task()
              ..measures = SamplingSchema.common()
                  .getMeasureList(namespace: NameSpace.CARP, types: [
                ContextSamplingPackage.LOCATION,
                SensorSamplingPackage.ACCELEROMETER,
                AudioSamplingPackage.AUDIO,
                ConnectivitySamplingPackage.CONNECTIVITY,
                ConnectivitySamplingPackage.BLUETOOTH,
                ConnectivitySamplingPackage.WIFI
              ]))
        // Add a (test) survey every 10 min and catch location value when performing it
        ..addTriggerTask(
            PeriodicTrigger(period: Duration(minutes: 10)),
            AppTask(
              type: SurveyUserTask.SURVEY_TYPE,
              title: testSurvey.title,
              description: testSurvey.description,
              minutesToComplete: testSurvey.minutesToComplete,
            )
              ..measures.add(RPTaskMeasure(
                type: MeasureType(NameSpace.CARP, SurveySamplingPackage.SURVEY),
                name: testSurvey.title,
                enabled: true,
                surveyTask: testSurvey.survey,
              ))
              ..measures.add(Measure(
                type: MeasureType(
                    NameSpace.CARP, ContextSamplingPackage.LOCATION),
              )));
    }

    return study;
  }

//   Future<Study> _getConditionalStudy(String studyId) async {
//     if (study == null) {
//       study = Study(id: studyId, userId: await settings.userId)
//             ..name = 'Conditional Monitor'
//             ..description = 'This is a test study.'
//             ..dataEndPoint = getDataEndpoint(DataEndPointTypes.FILE)
//             ..addTriggerTask(
//                 ConditionalSamplingEventTrigger(
//                   measureType:
//                       MeasureType(NameSpace.CARP, SurveySamplingPackage.SURVEY),
//                   resumeCondition: (Datum datum) => true,
//                   pauseCondition: (Datum datum) => true,
//                 ),
//                 AppTask(
//                   type: SensingUserTask.ONE_TIME_SENSING_TYPE,
//                   title: "Weather & Air Quality",
//                   description: "Collect local weather and air quality",
//                 )..measures = SamplingSchema.common().getMeasureList(
//                     namespace: NameSpace.CARP,
//                     types: [
//                       ContextSamplingPackage.WEATHER,
//                       ContextSamplingPackage.AIR_QUALITY,
//                     ],
//                   ))
//             ..addTriggerTask(
//                 ImmediateTrigger(),
//                 AppTask(
//                   type: SensingUserTask.ONE_TIME_SENSING_TYPE,
//                   title: "Location",
//                   description: "Collect current location",
//                 )..measures = SamplingSchema.common().getMeasureList(
//                     namespace: NameSpace.CARP,
//                     types: [
//                       ContextSamplingPackage.LOCATION,
//                     ],
//                   ))
//             ..addTriggerTask(
//                 ImmediateTrigger(),
//                 AppTask(
//                   type: SurveyUserTask.DEMOGRAPHIC_SURVEY_TYPE,
//                   title: surveys.demographics.title,
//                   description: surveys.demographics.description,
//                   minutesToComplete: surveys.demographics.minutesToComplete,
//                 )
//                   ..measures.add(RPTaskMeasure(
//                     type: MeasureType(
//                         NameSpace.CARP, SurveySamplingPackage.SURVEY),
//                     name: surveys.demographics.title,
//                     enabled: true,
//                     surveyTask: surveys.demographics.survey,
//                   ))
//                   ..measures.add(Measure(
//                     type: MeasureType(
//                         NameSpace.CARP, ContextSamplingPackage.LOCATION),
//                   )))
// //
//             ..addTriggerTask(
//                 PeriodicTrigger(period: Duration(minutes: 1)),
//                 AppTask(
//                   type: SurveyUserTask.SURVEY_TYPE,
//                   title: surveys.symptoms.title,
//                   description: surveys.symptoms.description,
//                   minutesToComplete: surveys.symptoms.minutesToComplete,
//                 )
//                   ..measures.add(RPTaskMeasure(
//                     type: MeasureType(
//                         NameSpace.CARP, SurveySamplingPackage.SURVEY),
//                     name: surveys.symptoms.title,
//                     enabled: true,
//                     surveyTask: surveys.symptoms.survey,
//                   ))
//                   ..measures.add(Measure(
//                     type: MeasureType(
//                         NameSpace.CARP, ContextSamplingPackage.LOCATION),
//                   )))
//           // ..addTriggerTask(
//           //     PeriodicTrigger(period: Duration(minutes: 2)),
//           //     AppTask(
//           //       type: AudioUserTask.AUDIO_TYPE,
//           //       title: "Coughing",
//           //       description:
//           //           'In this small exercise we would like to collect sound samples of coughing.',
//           //       instructions:
//           //           'Please press the record button below, and then cough 5 times.',
//           //       minutesToComplete: 3,
//           //     )
//           //       ..measures.add(AudioMeasure(
//           //         MeasureType(NameSpace.CARP, AudioSamplingPackage.AUDIO),
//           //         name: "Coughing",
//           //         studyId: studyId,
//           //       ))
//           //       ..measures.add(Measure(
//           //         MeasureType(
//           //             NameSpace.CARP, ContextSamplingPackage.LOCATION),
//           //         name: "Current location",
//           //       )))
//           // ..addTriggerTask(
//           //     PeriodicTrigger(period: Duration(minutes: 2)),
//           //     AppTask(
//           //       type: AudioUserTask.AUDIO_TYPE,
//           //       title: "Reading",
//           //       description:
//           //           'In this small exercise we would like to collect sound data while you are reading.',
//           //       instructions:
//           //           'Please press the record button below, and then read the following text.\n\n'
//           //           'Many, many years ago lived an emperor, who thought so much of new clothes that he spent all his money in order to obtain them; his only ambition was to be always well dressed. '
//           //           'He did not care for his soldiers, and the theatre did not amuse him; the only thing, in fact, he thought anything of was to drive out and show a new suit of clothes. '
//           //           'He had a coat for every hour of the day; and as one would say of a king "He is in his cabinet," so one could say of him, "The emperor is in his dressing-room."',
//           //       minutesToComplete: 3,
//           //     )
//           //       ..measures.add(AudioMeasure(
//           //         MeasureType(NameSpace.CARP, AudioSamplingPackage.AUDIO),
//           //         name: "Reading",
//           //         studyId: studyId,
//           //       ))
//           //       ..measures.add(Measure(
//           //         MeasureType(
//           //             NameSpace.CARP, ContextSamplingPackage.LOCATION),
//           //         name: "Current location",
//           //       )))
//
//           //
//           ;
//     }
//     return study;
//   }

  /// Return a [DataEndPoint] of the specified type.
  DataEndPoint getDataEndpoint(String type) {
    assert(type != null);
    switch (type) {
      case DataEndPointTypes.PRINT:
        return new DataEndPoint(type: DataEndPointTypes.PRINT);
      case DataEndPointTypes.FILE:
        return FileDataEndPoint(
            bufferSize: 50 * 1000, zip: true, encrypt: false);
      case DataEndPointTypes.CARP:
        return CarpDataEndPoint(
            uploadMethod: CarpUploadMethod.DATA_POINT,
            name: 'CARP Staging Server',
            uri: settings.uri,
            clientId: settings.clientID,
            clientSecret: settings.clientSecret,
            email: settings.username,
            password: settings.password);
//        return CarpDataEndPoint(
//          CarpUploadMethod.BATCH_DATA_POINT,
//          name: 'CARP Staging Server',
//          uri: uri,
//          clientId: clientID,
//          clientSecret: clientSecret,
//          email: username,
//          password: password,
//          bufferSize: 40 * 1000,
//          zip: false,
//          deleteWhenUploaded: false,
//        );
//        return CarpDataEndPoint(
//          CarpUploadMethod.FILE,
//          name: 'CARP Staging Server',
//          uri: uri,
//          clientId: clientID,
//          clientSecret: clientSecret,
//          email: username,
//          password: password,
//          bufferSize: 20 * 1000,
//          zip: true,
//          deleteWhenUploaded: false,
//        );
      default:
        return new DataEndPoint(type: DataEndPointTypes.PRINT);
    }
  }

  @override
  Future<bool> saveStudy(Study study) {
    // TODO: implement saveStudy
    throw UnimplementedError();
  }
}
