part of postcovid_ai;

class SurveyPage extends StatelessWidget {
  /// RPOrderedTask to be presented as the survey
  final RPOrderedTask surveyTask;
  final String code;

  SurveyPage({this.surveyTask, this.code}) : super();

  Future<void> resultCallback(BuildContext context, RPTaskResult result) async {
    // Create data point
    RPTaskResultDatum datum = RPTaskResultDatum(result);
    DataPoint data = DataPoint.fromData(datum)
    ..carpHeader.studyId = Sensing().studyDeploymentId
    ..carpHeader.userId = bloc.studyDeploymentModel.userID
    ..carpHeader.dataFormat = DataFormat.fromString("dk.cachet.carp.survey")
    ..carpHeader.deviceRoleName = "masterphone";

    // Upload the result to the database
    await CarpService().getDataPointReference().postDataPoint(data);

    // Only execute this for initial survey, otherwise just pop
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("isInitialSurveyUploaded")) {
      // Mark the survey as uploaded
      prefs.setBool("isInitialSurveyUploaded", true);

      // Push main screen
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              LoadingPage(text: code)));
    } else {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RPUITask(
      task: surveyTask,
      onSubmit: (result) {
        resultCallback(context, result);
      },
    );
  }
}