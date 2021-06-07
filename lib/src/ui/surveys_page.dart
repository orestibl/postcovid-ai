part of postcovid_ai;

class TaskList extends StatefulWidget {
  const TaskList({Key key}) : super(key: key);

  static const String routeName = '/tasklist';

  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    List<UserTask> tasks = bloc.tasks.reversed.toList();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Surveys'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Theme.of(context).platform == TargetPlatform.iOS
                  ? Icons.more_horiz
                  : Icons.more_vert,
            ),
            tooltip: 'Settings',
            onPressed: _showSettings,
          ),
        ],
      ),
      body: StreamBuilder<UserTask>(
        stream: AppTaskController().userTaskEvents,
        builder: (context, AsyncSnapshot<UserTask> snapshot) {
          print('>> $snapshot');
          return Scrollbar(
            child: ListView.builder(
              itemCount: tasks.length,
              padding: EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (context, index) =>
                  _buildTaskCard(context, tasks[index]),
            ),
          );
        },
      ),
    );
  }

  void _showSettings() {
    Scaffold.of(context).showSnackBar(
        const SnackBar(content: Text('Settings not implemented yet...')));
  }

  Widget _buildTaskCard(BuildContext context, UserTask userTask) {
    return Center(
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: StreamBuilder<UserTaskState>(
          stream: userTask.stateEvents,
          initialData: UserTaskState.initialized,
          builder: (context, AsyncSnapshot<UserTaskState> snapshot) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  leading: Icon(
                    Icons.description,
                    color: CACHET.ORANGE,
                    size: 40,
                  ), // TODO fix when research package is installedtaskTypeIcon[userTask.type],
                  title: Text(userTask.title),
                  subtitle: Text(userTask.description),
                  trailing: Icon(
                    Icons.description,
                    color: CACHET.ORANGE,
                    size: 40,
                  ) //taskStateIcon[userTask.state], TODO fix when research package is installed
                  ),
              // TODO - only add button if there is a task to do. Might be an info card.
              (userTask.state == UserTaskState.enqueued ||
                  userTask.state == UserTaskState.canceled)
                  ? ButtonBar(
                      children: <Widget>[
                        FlatButton(
                            child: const Text('PRESS HERE TO FINISH TASK'),
                            onPressed: () => userTask.onStart(context)),
                      ],
                    )
                  : Text(""),
            ],
          ),
        ),
      ),
    );
  }
/*
  Map<String, Icon> get taskTypeIcon => {
        SurveyUserTask.WHO5_SURVEY_TYPE: Icon(
          Icons.design_services,
          color: CACHET.ORANGE,
          size: 40,
        ),
        SurveyUserTask.DEMOGRAPHIC_SURVEY_TYPE: Icon(
          Icons.person,
          color: CACHET.ORANGE,
          size: 40,
        ),
        SurveyUserTask.SURVEY_TYPE: Icon(
          Icons.description,
          color: CACHET.ORANGE,
          size: 40,
        ),
        SensingUserTask.SENSING_TYPE: Icon(
          Icons.settings_input_antenna,
          color: CACHET.CACHET_BLUE,
          size: 40,
        ),
        SensingUserTask.ONE_TIME_SENSING_TYPE: Icon(
          Icons.settings_input_component,
          color: CACHET.CACHET_BLUE,
          size: 40,
        ),
      };

  Map<UserTaskState, Icon> get taskStateIcon => {
        UserTaskState.initialized: Icon(Icons.stream, color: CACHET.YELLOW),
        UserTaskState.enqueued: Icon(Icons.notifications, color: CACHET.YELLOW),
        UserTaskState.dequeued: Icon(Icons.stop, color: CACHET.YELLOW),
        UserTaskState.started: Icon(Icons.play_arrow, color: CACHET.GREY_4),
        UserTaskState.done: Icon(Icons.check, color: CACHET.GREEN),
      };

 */
}
