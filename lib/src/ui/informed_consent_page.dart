part of postcovid_ai;

class InformedConsentPage extends StatelessWidget {
  /// RPOrderedTask to be presented as informed consent
  final RPOrderedTask consentTask;

  InformedConsentPage({this.consentTask}) : super();

  String _encode(Object object) =>
      const JsonEncoder.withIndent(' ').convert(object);

  Future<void> resultCallback(RPTaskResult result) async {
    // Do anything with the result
    //print(_encode(result));

    // Extract signature from informed consent result
    RPConsentSignatureResult signature = result.results['consentreviewstepID'].results['consentSignatureID'];

    // Identify the participant
    signature.userID = "test_user_code"; //TODO: replace with the code provided by the user or the device ID

    // Upload the signature to the database
    await CarpService().createConsentDocument(signature.toJson());
  }

  void cancelCallBack() {
    // Do anything with the result at the moment of the cancellation
    print("Cancelled");
  }

  @override
  Widget build(BuildContext context) {
    return RPUITask(
      task: consentTask,
      onSubmit: (result) {
        resultCallback(result);
      },
      onCancel: ([result]) {
        cancelCallBack();
      },
    );
  }
}