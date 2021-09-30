part of postcovid_ai;

class InformedConsentPage extends StatelessWidget {
  /// RPOrderedTask to be presented as informed consent
  final RPOrderedTask consentTask;
  final String code;

  InformedConsentPage({this.consentTask, this.code}) : super();

  Future<void> resultCallback(BuildContext context, RPTaskResult result) async {
    // Extract signature from informed consent result and identify participant
    RPConsentSignatureResult signature = result.results['consentreviewstepID'].results.values.elementAt(0);
    signature.userID = code;

    // Upload the signature to the database
    await CarpService().createConsentDocument(signature.toJson());

    // Mark the document as uploaded
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isConsentUploaded", true);

    // Push main screen
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) =>
            LoadingPage(text: code, loadingText: Strings.loadingAppText)));
  }

  @override
  Widget build(BuildContext context) {
    return RPUITask(
      task: consentTask,
      onSubmit: (result) {
        resultCallback(context, result);
      }
    );
  }
}