library postcovid_ai;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notification;
import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'package:android_long_task/android_long_task.dart';
import 'package:carp_audio_package/audio.dart';
import 'package:carp_backend/carp_backend.dart';
import 'package:carp_context_package/context.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_survey_package/survey.dart';
import 'package:carp_webservices/carp_auth/carp_auth.dart';
import 'package:carp_webservices/carp_services/carp_services.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:research_package/research_package.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'app_service_config.dart';
import 'my_logger.dart';
import 'src/sensing/credentials.dart';

part 'src/app.dart';
part 'src/blocs/carp_backend.dart';
part 'src/blocs/sensing_bloc.dart';
part 'src/exceptions.dart';
part 'src/models/deployment_model.dart';
part 'src/models/device_models.dart';
part 'src/models/probe_description.dart';
part 'src/models/probe_models.dart';
part 'src/sensing/local_study_protocol_manager.dart';
part 'src/sensing/sensing.dart';
part 'src/ui/informed_consent_page.dart';
part 'src/ui/loading_page.dart';
part 'src/ui/login_page.dart';
part 'src/ui/service_not_available_page.dart';
part 'src/ui/survey_page.dart';
part 'src/ui/shared/app_theme.dart';
part 'src/ui/shared/strings.dart';

bool letAppGetClosed = true;
AppServiceData appServiceData = AppServiceData(); // esta variable la usa la UI y la long task (pero son diferentes)
StreamSubscription<UserTask> userTaskEventsHandler;

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
