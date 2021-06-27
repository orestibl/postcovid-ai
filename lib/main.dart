library postcovid_ai;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:carp_audio_package/audio.dart';
import 'package:carp_backend/carp_backend.dart';
//import 'package:carp_connectivity_package/connectivity.dart';
import 'package:carp_context_package/context.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_survey_package/survey.dart';
import 'package:carp_communication_package/communication.dart';
import 'package:carp_apps_package/apps.dart';

import 'package:carp_webservices/carp_auth/carp_auth.dart';
import 'package:carp_webservices/carp_services/carp_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:research_package/research_package.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
part 'src/ui/shared/app_theme.dart';
part 'src/ui/homepage.dart';
part 'src/ui/informed_consent_page.dart';
part 'src/ui/loading_page.dart';
part 'src/ui/login_page.dart';
part 'src/ui/shared/strings.dart';
part 'src/ui/survey_page.dart';
part 'src/ui/surveys_page.dart';
part 'src/ui/widgets/clipper_widget.dart';
part 'src/ui/widgets/wave_widget.dart';

void main() {
  runApp(App());
}
