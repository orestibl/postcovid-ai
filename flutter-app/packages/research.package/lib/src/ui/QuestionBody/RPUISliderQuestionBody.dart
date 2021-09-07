part of research_package_ui;

class RPUISliderQuestionBody extends StatefulWidget {
  final RPSliderAnswerFormat answerFormat;
  final Function(dynamic) onResultChange;

  RPUISliderQuestionBody(this.answerFormat, this.onResultChange);

  @override
  _RPUISliderQuestionBodyState createState() => _RPUISliderQuestionBodyState();
}

class _RPUISliderQuestionBodyState extends State<RPUISliderQuestionBody>
    with AutomaticKeepAliveClientMixin<RPUISliderQuestionBody> {
  double value;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    RPLocalizations locale = RPLocalizations.of(context);
    bool middleLabel = (widget.answerFormat.prefix == "Sí, desagradable");
    return Container(
      padding: EdgeInsets.all(8),
      alignment: Alignment.topLeft,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('${locale?.translate(widget.answerFormat.prefix) ?? widget.answerFormat.prefix}'),
              Text(
                  ((widget.answerFormat.prefix == "") & (widget.answerFormat.suffix == ""))
                      ? '${(value ?? (widget.answerFormat.initValue ?? widget.answerFormat.minValue)).toInt()}'
                      : (middleLabel ? "No" : ''), // This should be empty, specific configuration for the present study
                  style: TextStyle(fontSize: (middleLabel ? 14 : 18))
              ),
              Text('${locale?.translate(widget.answerFormat.suffix) ?? widget.answerFormat.suffix}')
            ]
          ),
          //Text(
          //  '${locale?.translate(widget.answerFormat.prefix) ?? widget.answerFormat.prefix}${(value ?? (widget.answerFormat.initValue ?? widget.answerFormat.minValue)).toInt()}${locale?.translate(widget.answerFormat.suffix) ?? widget.answerFormat.suffix}',
          //  style: TextStyle(fontSize: 18),
          //),
          Slider(
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Theme.of(context).primaryColor.withOpacity(0.2),
            value: value ?? (widget.answerFormat.initValue ?? widget.answerFormat.minValue),
            onChanged: (double newValue) {
              setState(() {
                value = newValue;
              });
              widget.onResultChange(value);
            },
            min: widget.answerFormat.minValue,
            max: widget.answerFormat.maxValue,
            divisions: widget.answerFormat.divisions,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
