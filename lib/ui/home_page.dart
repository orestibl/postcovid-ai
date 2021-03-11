part of postcovid_ai;

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState(bloc.study);
}

class _HomePageState extends State<HomePage> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  final double _appBarHeight = 256.0;

  final StudyModel study;

  _HomePageState(this.study) : super();

  @override
  Widget build(BuildContext context) {
    if (bloc.study != null) {
      return _buildHomePage(context, study);
    } else {
      return _buildEmptyHomePage(context);
    }
  }

  // TODO en el futuro solo quedará este método, el otro es para debug
  Widget _buildEmptyHomePage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study'),
      ),
      body: Center(
        child: Icon(
          Icons.school,
          size: 100,
          color: CACHET.ORANGE,
        ),
      ),
    );
  }

  Widget _buildHomePage(BuildContext context, StudyModel study) {
    // TODO al iniciar la app, study=null y pega un pete
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: _appBarHeight,
            pinned: true,
            floating: false,
            snap: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(study.name, style: TextStyle(color: CACHET.BLACK)),
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[study.image],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.dark,
                child: _buildStudyControllerPanel(context, study),
              ),
              FloatingActionButton.extended(
                  heroTag: "informedConsent",
                  onPressed: _showInformedConsent,
                  icon: Icon(Icons.assignment_turned_in_outlined),
                  label: Text("Informed consent"),
                  // This will prompt automatically
                  backgroundColor: CACHET.CACHET_BLUE),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyControllerPanel(BuildContext context, StudyModel study) {
    final ThemeData themeData = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: themeData.dividerColor))),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.subtitle1,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  width: 72.0,
                  child: Icon(Icons.lightbulb_outline,
                      size: 50, color: CACHET.CACHET_BLUE)),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _StudyControllerLine(study.description),
                    _StudyControllerLine(study.userID, heading: 'User ID'),
                    _StudyControllerLine(study.samplingStrategy,
                        heading: 'Sampling Strategy'),
                    _StudyControllerLine(study.dataEndpoint,
                        heading: 'Data Endpoint'),
                    StreamBuilder<Datum>(
                        stream: study.samplingEvents,
                        builder: (context, AsyncSnapshot<Datum> snapshot) {
                          return _StudyControllerLine('${study.samplingSize}',
                              heading: 'Sample Size');
                        }),
                  ]))
            ],
          ),
        ),
      ),
    );
  }

  void _showInformedConsent() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => InformedConsentPage()));
  }
}

class _StudyControllerLine extends StatelessWidget {
  final String line, heading;

  _StudyControllerLine(this.line, {this.heading}) : super();

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: (heading == null)
                ? Text(line, textAlign: TextAlign.left, softWrap: true)
                : Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: '$heading: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: line),
                      ],
                    ),
                  )));
  }
}
