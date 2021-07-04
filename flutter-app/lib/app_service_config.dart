import 'dart:convert';

import 'package:android_long_task/android_long_task.dart';

class AppServiceData extends ServiceData {
  int progress = -1;
  String mensaje = '';
  String miNotificationTitle = "PostCovid-AI";

  @override
  String toJson() {
    var jsonMap = {
      'progress': progress,
      'mensaje': mensaje,
    };
    return jsonEncode(jsonMap);
  }

  static AppServiceData fromJson(Map<String, dynamic> json) {
    return AppServiceData()
      ..progress = (json['progress'] as int)
      ..mensaje = (json['mensaje'] as String);
  }

  @override
  String get notificationTitle {
    //print("miNotificationTitle= $miNotificationTitle");
    return miNotificationTitle;
  }

  @override
  String get notificationDescription => 'Sample Size: $progress';
}
