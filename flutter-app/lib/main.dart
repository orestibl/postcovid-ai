library postcovid_ai;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as notification;
import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'package:android_long_task/android_long_task.dart';
import 'package:carp_audio_package/audio.dart';
import 'package:carp_backend/carp_backend.dart';
import 'package:carp_background_location/carp_background_location.dart';
import 'package:carp_context_package/context.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_survey_package/survey.dart';
import 'package:carp_webservices/carp_auth/carp_auth.dart';
import 'package:carp_webservices/carp_services/carp_services.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:research_package/research_package.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_service_config.dart';
import 'my_logger.dart';
import 'src/sensing/credentials.dart';

part 'src/app.dart';

part 'src/blocs/carp_backend.dart';

part 'src/blocs/sensing_bloc.dart';

part 'src/exceptions.dart';

part 'src/models/data_models.dart';

part 'src/models/deployment_model.dart';

part 'src/models/device_models.dart';

part 'src/models/probe_description.dart';

part 'src/models/probe_models.dart';

part 'src/sensing/local_study_protocol_manager.dart';

part 'src/sensing/sensing.dart';

part 'src/sensing/study_deployment_manager.dart';

part 'src/ui/cachet.dart';

part 'src/ui/homepage.dart';

part 'src/ui/informed_consent_page.dart';

part 'src/ui/loading_page.dart';

part 'src/ui/login_page.dart';

part 'src/ui/shared/app_theme.dart';

part 'src/ui/shared/strings.dart';

part 'src/ui/survey_page.dart';

part 'src/ui/surveys_page.dart';

part 'src/ui/widgets/clipper_widget.dart';

part 'src/ui/widgets/wave_widget.dart';

bool letAppGetClosed = true;
AppServiceData appServiceData = AppServiceData(); // esta variable la usa la UI y la long task (pero son diferentes)
StreamSubscription<UserTask> userTaskEventsHandler;

enum LocationStatus { UNKNOWN, RUNNING, STOPPED }

String dtoToString(LocationDto dto) =>
    'Location ${dto.latitude}, ${dto.longitude} at ${DateTime.fromMillisecondsSinceEpoch(dto.time ~/ 1)}';
LocationDto lastLocation;
DateTime lastTimeLocation;
LocationManager locationManager = LocationManager.instance;
Stream<LocationDto> dtoStream;
StreamSubscription<LocationDto> dtoSubscription;
LocationStatus _statusLocation = LocationStatus.UNKNOWN;

// HÉCTOR. ESTA PARTE ESTÁ COGIDA DE notifications

ActivityRecognition activityRecognition = ActivityRecognition.instance;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
  MyLogger.listen(record,
      useColors: true, showLevelName: true, showTime: true);
  });
 // runApp(AppDebug());
 runApp(App());
}
