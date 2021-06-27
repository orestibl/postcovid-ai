part of postcovid_ai;

class SurveyPage extends StatelessWidget {
  /// RPOrderedTask to be presented as the survey
  final RPOrderedTask surveyTask;
  final String code;

  SurveyPage({this.surveyTask, this.code}) : super();

  Future<void> resultCallback(BuildContext context, RPTaskResult result) async {
    RPTaskResultDatum datum = RPTaskResultDatum(result);
    DataPoint data = DataPoint.fromData(datum)
    ..carpHeader.studyId = Sensing().studyDeploymentId
    ..carpHeader.userId = bloc.studyDeploymentModel.userID
    ..carpHeader.dataFormat = DataFormat.fromString("dk.cachet.carp.survey")
    ..carpHeader.deviceRoleName = "masterphone";

    CarpService().getDataPointReference().postDataPoint(data);
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