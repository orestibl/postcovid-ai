part of postcovid_ai;

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);
  static const String routeName = '/study';

  _HomePageState createState() => _HomePageState(bloc.studyDeploymentModel);
}

class _HomePageState extends State<HomePage> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  final double _appBarHeight = 256.0;

  final StudyDeploymentModel studyDeploymentModel;

  _HomePageState(this.studyDeploymentModel) : super();

  Widget build(BuildContext context) =>
      _buildHomePage(context, bloc.studyDeploymentModel);

  Widget _buildHomePage(
    BuildContext context,
    StudyDeploymentModel studyDeploymentModel,
  ) {
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
              title: Text(studyDeploymentModel.name),
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  studyDeploymentModel.image,
//                  Image.asset(
//                    bloc.study.image,
//                    fit: BoxFit.cover,
//                    height: _appBarHeight,
//                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
                _buildStudyPanel(context, studyDeploymentModel)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStudyPanel(
      BuildContext context, StudyDeploymentModel studyDeploymentModel) {
    List<Widget> children = [];

    children.add(AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: _buildStudyControllerPanel(context, studyDeploymentModel),
    ));

    return children;
  }

  Widget _buildStudyControllerPanel(
      BuildContext context, StudyDeploymentModel studyDeploymentModel) {
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
                  child: Icon(Icons.settings,
                      size: 50, color: AppTheme.DARK_COLOR)),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _StudyControllerLine(studyDeploymentModel.title,
                        heading: 'Title'),
                    _StudyControllerLine(studyDeploymentModel.description),
                    _StudyControllerLine(studyDeploymentModel.studyId,
                        heading: 'Study ID'),
                    _StudyControllerLine(studyDeploymentModel.studyDeploymentId,
                        heading: 'Deployment ID'),
                    _StudyControllerLine(studyDeploymentModel.userID,
                        heading: 'User'),
                    _StudyControllerLine(studyDeploymentModel.dataEndpoint,
                        heading: 'Data Endpoint'),
                    StreamBuilder<ProbeState>(
                        stream: studyDeploymentModel.studyExecutorStateEvents,
                        initialData: ProbeState.created,
                        builder: (context, AsyncSnapshot<ProbeState> snapshot) {
                          if (snapshot.hasData)
                            return _StudyControllerLine(
                                probeStateLabel(snapshot.data),
                                heading: 'State');
                          else
                            return _StudyControllerLine(
                                probeStateLabel(ProbeState.initialized),
                                heading: 'State');
                        }),
                    StreamBuilder<DataPoint>(
                        stream: studyDeploymentModel.data,
                        builder: (context, AsyncSnapshot<DataPoint> snapshot) {
                          return _StudyControllerLine(
                              '${studyDeploymentModel.samplingSize}',
                              heading: 'Sample Size');
                        }),
                  ]))
            ],
          ),
        ),
      ),
    );
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
