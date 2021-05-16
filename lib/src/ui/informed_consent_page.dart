part of postcovid_ai;

class InformedConsentPage extends StatelessWidget {
  String _encode(Object object) =>
      const JsonEncoder.withIndent(' ').convert(object);

  void resultCallback(RPTaskResult result) {
    // Do anything with the result
    print(_encode(result));
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