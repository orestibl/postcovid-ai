part of research_package_ui;

class RPUIFormStep extends StatefulWidget {
  final RPFormStep formStep;

  RPUIFormStep(this.formStep);

  @override
  _RPUIFormStepState createState() => _RPUIFormStepState();
}

class _RPUIFormStepState extends State<RPUIFormStep> with WidgetsBindingObserver {
  bool readyToProceed;
  RPStepResult stepResult;
  RPTaskProgress recentTaskProgress;

  // Since the QuestionBody's are sending null if they are not answered yet we can loop through the
  // results of the steps.
  // If any of them is null it means the participant can not proceed to the next step because not all the
  // questions are answered.
  void checkReadyToProceed() {
    bool temp = true;
    stepResult.results.values.forEach((result) {
      if ((result as RPStepResult).results[RPStepResult.DEFAULT_KEY] == null) {
        temp = false;
      }
    });
    setState(() {
      readyToProceed = temp;
    });
    createAndSendResult();
    blocQuestion.sendReadyToProceed(temp);
  }

  @override
  void initState() {
    // Instantiating the result object here to start the time counter (startDate)
    stepResult = RPStepResult(widget.formStep);
    stepResult.questionTitle =
        "Form Step - See titles for every question included";

    // Filling up the results with nulls
    widget.formStep.steps.forEach((item) {
      stepResult.setResultForIdentifier(item.identifier, RPStepResult(item));
    });

    readyToProceed = false;
    blocQuestion.sendReadyToProceed(false);
    recentTaskProgress = blocTask.lastProgressValue;

    // checkReadyToProceed is executed after the widget is created, to allow
    // continuing with default values in case all the questions are sliders
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => checkReadyToProceed());

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Returning the according step body widget based on the answerFormat of each step
  Widget stepBody(String id, RPAnswerFormat answerFormat) {
    // TODO: Let's convert these operations into a function

    switch (answerFormat.runtimeType) {
      case RPIntegerAnswerFormat:
        return RPUIIntegerQuestionBody(answerFormat, (result) {
          RPStepResult tempResult = stepResult.results[id] as RPStepResult;
          tempResult.questionTitle = widget.formStep.steps
              .where((step) => step.identifier == id)
              .first
              .title;
          tempResult.setResult(result);

          checkReadyToProceed();
        });
      case RPChoiceAnswerFormat:
        return RPUIChoiceQuestionBody(answerFormat, (result) {
          RPStepResult tempResult = stepResult.results[id] as RPStepResult;
          tempResult.questionTitle = widget.formStep.steps
              .where((step) => step.identifier == id)
              .first
              .title;
          tempResult.setResult(result);

          checkReadyToProceed();
        });
      case RPSliderAnswerFormat:
        // Only for sliders, at the beginning the result should be the initial value
        if (stepResult.results[id].results[RPStepResult.DEFAULT_KEY] == null) {
          RPSliderAnswerFormat rpSliderAnswerFormat = widget.formStep.steps
              .where((step) => step.identifier == id).first.answerFormat as RPSliderAnswerFormat;

          stepResult.results[id].setResult(rpSliderAnswerFormat.initValue ?? rpSliderAnswerFormat.minValue);
        }
        return RPUISliderQuestionBody(answerFormat, (result) {
          RPStepResult tempResult = stepResult.results[id] as RPStepResult;
          tempResult.questionTitle = widget.formStep.steps
              .where((step) => step.identifier == id)
              .first
              .title;
          tempResult.setResult(result);

          checkReadyToProceed();
        });
      case RPImageChoiceAnswerFormat:
        return RPUIImageChoiceQuestionBody(answerFormat, (result) {
          RPStepResult tempResult = stepResult.results[id] as RPStepResult;
          tempResult.questionTitle = widget.formStep.steps
              .where((step) => step.identifier == id)
              .first
              .title;
          tempResult.setResult(result);

          checkReadyToProceed();
        });
      case RPDateTimeAnswerFormat:
        return RPUIDateTimeQuestionBody(answerFormat, (result) {
          RPStepResult tempResult = stepResult.results[id] as RPStepResult;
          tempResult.questionTitle = widget.formStep.steps
              .where((step) => step.identifier == id)
              .first
              .title;
          tempResult.setResult(result);

          checkReadyToProceed();
        });
      case RPBooleanAnswerFormat:
        return RPUIBooleanQuestionBody(answerFormat, (result) {
          RPStepResult tempResult = stepResult.results[id] as RPStepResult;
          tempResult.questionTitle = widget.formStep.steps
              .where((step) => step.identifier == id)
              .first
              .title;
          tempResult.setResult(result);

          checkReadyToProceed();
        });
      default:
        return Container();
    }
  }

  skipQuestion() {
    stepResult.results.keys.forEach((key) {
      (stepResult.results[key] as RPStepResult).setResult(null);
    });
    blocTask.sendStatus(RPStepStatus.Finished);
    createAndSendResult();
  }

  Widget formItemBuilder(context, index) {
    if (index == 0) {
      return (widget.formStep.title != null)
          ? Padding(
              padding:
                  const EdgeInsets.only(bottom: 24, left: 8, right: 8, top: 8),
              child: Text(
                RPLocalizations.of(context)?.translate(widget.formStep.title) ??
                    widget.formStep.title,
                style: RPStyles.h3,
                textAlign: TextAlign.left,
              ),
            )
          : null;
    }
    index -= 1;

    if (index == widget.formStep.steps.length) {
      // return widget.formStep.optional
      //     ? Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: FlatButton(
      //           onPressed: () => skipQuestion(),
      //           child: Text(RPLocalizations.of(context)
      //                   .translate("Skip these questions") ??
      //               "Skip these questions"),
      //         ),
      //       )
      //     :
      return Padding(
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // if first question or there is only one
            recentTaskProgress.current == 1 || recentTaskProgress.total == 1
                ? Container()
                : FlatButton(
                    onPressed: () =>
                        blocTask.sendStatus(RPStepStatus.Back),
                    child: Text(
                      RPLocalizations.of(context)
                          ?.translate('BACK') ??
                          "BACK",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
            StreamBuilder<bool>(
              stream: blocQuestion.questionReadyToProceed,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(
                      recentTaskProgress.current == recentTaskProgress.total
                        ? RPLocalizations.of(context)
                          ?.translate('SEND') ??
                          "SEND"
                        : RPLocalizations.of(context)
                          ?.translate('NEXT') ??
                          "NEXT"
                    ),
                    onPressed: snapshot.data
                        ? () {
                      blocTask
                          .sendStatus(RPStepStatus.Finished);
                    }
                        : null,
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              RPLocalizations.of(context)
                      ?.translate(widget.formStep.steps[index].title) ??
                  widget.formStep.steps[index].title,
              style: RPStyles.h3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: stepBody(
              widget.formStep.steps[index].identifier,
              widget.formStep.steps[index].answerFormat,
            ),
          ),
          Divider(
              indent: 1,
              endIndent: 1,
              color: Theme.of(context).dividerColor,
              thickness: 2)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: formItemBuilder,
                itemCount: widget.formStep.steps.length + 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void createAndSendResult() {
    // In this case the result is already created, the only needed thing left is to send it
    blocTask.sendStepResult(stepResult);
  }
}
