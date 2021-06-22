part of postcovid_ai;

class InformedConsentPage extends StatelessWidget {
  /// RPOrderedTask to be presented as informed consent
  final RPOrderedTask consentTask;
  final String code;

  InformedConsentPage({this.consentTask, this.code}) : super();

  Future<void> resultCallback(BuildContext context, RPTaskResult result) async {
    // Extract signature from informed consent result and identify participant
    RPConsentSignatureResult signature = result.results['consentreviewstepID'].results['consentSignatureID'];
    signature.userID = code;

    // Upload the signature to the database
    await CarpService().createConsentDocument(signature.toJson());

    // Mark the document as uploaded
    Settings().preferences.setBool("isConsentUploaded", true);

    // Push main screen
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) =>
            LoadingPage(text: code)));
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