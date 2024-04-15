import 'dart:convert';

import 'package:android_long_task/long_task/service_data.dart';
import 'package:flutter/services.dart';

class ServiceClient {
  static const CHANNEL_NAME = "APP_SERVICE_CHANNEL_NAME";
  static const SET_SERVICE_DATA = 'SET_SERVICE_DATA';
  static const STOP_SERVICE = 'STOP_SERVICE';
  static const END_EXECUTION = 'END_EXECUTION';
  static const SEND_ACK = 'SEND_ACK';
  static var channel = MethodChannel(CHANNEL_NAME);
  // Future<dynamic> Function(Map<String, dynamic>) runDartCodeCallback;
  // Future<dynamic> Function() endDartCodeCallback;

  static Future<String> update(ServiceData data) async {
    var dataWrapper = ServiceDataWrapper(data);
    print("HH_ service_client.dart: update. Invocando SET_SERVICE_DATA");
    return channel.invokeMethod(SET_SERVICE_DATA, dataWrapper.toJson());
  }

  static setExecutionCallback(
      Future runDartCodeCallback(Map<String, dynamic> initialData),
      Future endDartCodeCallback(),
      Future uiPresentCallBack(),
      Future uiNotPresentCallBack()) {
    print(
        "HH_ service_client.dart: setExecutionCallback para que responda cuando se invoque el método runDartCode del canal $CHANNEL_NAME");
    channel.setMethodCallHandler((call) async {
      print(
          "HH_MethodCallHandler de $CHANNEL_NAME service_client.dart: ${call.method}-> ${call.arguments?.toString()}");
      if (call.method == "runDartCode") {
        var json = jsonDecode(call.arguments as String);
        await runDartCodeCallback(json);
      }
      if (call.method == "endDartCode") {
        await endDartCodeCallback();
      }
      if (call.method == "uiPresent") {
        await uiPresentCallBack();
      }
      if (call.method == "uiNotPresent") {
        await uiNotPresentCallBack();
      }
      if (call.method == "AckToLongTask") {
        print(
            "HH_service_client.dart: recibo AckToLongTask. Con eso compruebo que channel.setMethodCallHandler de service_client.dart sigue funcionando");
      }
    });
  }

  static Future<void> endExecution(ServiceData data) async {
    print("HH_ service_client.dart endExecution. Invoco END_EXECUTION");
    var dataWrapper = ServiceDataWrapper(data);
    return channel.invokeMethod(END_EXECUTION, dataWrapper.toJson());
  }

  static Future<String> stopService() {
    print("HH_ service_client.dart stopService. Invoco STOP_SERVICE");
    return (channel.invokeMethod(STOP_SERVICE));
  }

  static Future<String> sendAck() {
    print("HH_ service_client.dart sendAck. Invoco SEND_ACK");
    return (channel.invokeMethod(SEND_ACK));
  }
}
