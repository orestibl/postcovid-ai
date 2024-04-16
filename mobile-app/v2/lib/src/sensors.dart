import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:light/light.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:noise_meter/noise_meter.dart';
import 'package:screen_state/screen_state.dart';

import '../main.dart';
import '../my_logger.dart';
import 'helper_functions.dart';

Future<void> measureLight({int durationSeconds = 1, required String code, required String deviceInfo}) async {
  // Esta función crea un listener de light durante samplingTime segundos.
  // Finalmente, escribe el dato y se auto-cierra
  milog.info("Entrando en measureLight");
  await lightSubscription?.cancel(); // por si acaso
  final startTime = DateTime.now().millisecondsSinceEpoch;
  int minLux = 10000000;
  int maxLux = -10000000;
  int sumLux = 0;
  int sumLuxSquared = 0;
  int numSamples = 0;
  try {
    lightSubscription = Light().lightSensorStream.listen((int? result) async {
      try {
        if (result == null) return; // por si acaso
        debugPrint("HECTOR: Light Event: $result");
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        if (currentTime - startTime > durationSeconds * 1000) {
          // ya hemos terminado -> sacamos los datos
          await lightSubscription?.cancel();
          if (numSamples > 0) {
            final double meanLux = sumLux / numSamples;
            final double stdDevLux = numSamples > 1 ? sqrt(((sumLuxSquared / numSamples) - (meanLux * meanLux)).abs()) : 0.0;
            milog.info("Ya hemos recopilado los datos de Light durante $durationSeconds segundos");
            final dato =
                "minLux = $minLux, maxLux = $maxLux, sumLux = $sumLux, sumLuxSquared = $sumLuxSquared, numSamples = $numSamples, meanLux = $meanLux, stdDevLux = $stdDevLux";
            // milog.info(dato);
            // const CEDILLA = "Ç";
            // const DOBLES_LLAVES_CERRADAS = "}}";
            final data = await createDataPoint(dato, dataType: "light", code: code, deviceInfo: deviceInfo);
            String jsonEncodedData = jsonEncode(data.toJson()); // formato nuevo
            // y ahora el formato antiguo
            try {
              final Map<String, dynamic> dataMap = data.toJson();
              if (dataMap.containsKey("carp_body")) {
                final Map<String, dynamic> dataMapCarpBody = dataMap['carp_body'];
                dataMapCarpBody.remove("datameasured");
                dataMapCarpBody['max_lux'] = maxLux.toString();
                dataMapCarpBody['mean_lux'] = meanLux.toString();
                dataMapCarpBody['min_lux'] = minLux.toString();
                dataMapCarpBody['std_lux'] = stdDevLux.toString();
                dataMapCarpBody['num_samples'] = numSamples.toString();
                jsonEncodedData = jsonEncode(dataMap);
              }
            } catch (e) {
              milog.shout("Fallo usando dataMap en light. Usamos formato moderno: e=${e.toString()}");
            }
            listaDataPoints.add(jsonEncodedData);
            // var position = jsonEncodedData.lastIndexOf(DOBLES_LLAVES_CERRADAS).clamp(0, jsonEncodedData.length);
            // if (position > 0) {
            //   jsonEncodedData = jsonEncodedData.replaceFirst(DOBLES_LLAVES_CERRADAS, "", position);
            //   jsonEncodedData = jsonEncodedData.replaceFirst("datameasured", "max_lux").replaceFirst(CEDILLA, maxLux.toString());
            //   jsonEncodedData = '$jsonEncodedData,"mean_lux":"$meanLux"';
            //   jsonEncodedData = '$jsonEncodedData,"min_lux":"$minLux"';
            //   jsonEncodedData = '$jsonEncodedData,"std_lux":"$stdDevLux"}}';
            //   listaDataPoints.add(jsonEncodedData);
            // } else {
            //   milog.shout("Ojo, position no es > 0 en light listener.");
          } else {
            milog.info("No envío este dato de luz porque numSamples = 0");
          }
        } else {
          // seguimos recopilando datos
          if (result < minLux) minLux = result;
          if (result > maxLux) maxLux = result;
          numSamples++;
          sumLux += result;
          sumLuxSquared += result * result;
        }
      } catch (e) {
        final mensaje = "HECTOR: Error en el listener de Light:  ${e.toString()}\n";
        debugPrint(mensaje);
        // Pero no hacemos nada más
      }
    });
  } on LightException catch (e) {
    milog.shout("No puedo instalar el listener de Light!!! Error: ${e.toString()}");
  }
}

Future<void> measureNoise({int durationSeconds = 1, required String code, required String deviceInfo}) async {
  // Esta función crea un listener de noise durante samplingTime segundos.
  // Finalmente, escribe el dato y se auto-cierra
  milog.info("Entrando en measureNoise");
  if (!canUseNoiseMeter) {
    milog.info("Ya vimos que NO podemos usar NoiseMeter -> no insistas");
    return;
  }
  // if (USE_SCREEN_STATE && (lastScreenState != ScreenStateEvent.SCREEN_OFF)) {
  //   milog.info("No mido el ruido porque la pantalla no está apagada -> no quiero interferir con el micrófono si el usuario lo usa");
  //   return;
  // }
  try {
    await noiseSubscription?.cancel(); // por si acaso
  } catch (_) {}
  final startTime = DateTime.now().millisecondsSinceEpoch;
  int numSamples = 0;
  double minMeanDecibel = double.infinity;
  double maxMeanDecibel = double.negativeInfinity;
  double sumMeanDecibel = 0.0;
  double sumMeanDecibelSquared = 0.0;
  double maxMaxDecibel = double.negativeInfinity;

  void onError(Object error) {
    milog.shout("NoiseMeter nos da un error: no podemos medir el ruido: ${error.toString()}");
    canUseNoiseMeter = false;
  }

  noiseMeter ??= NoiseMeter(onError);
  if (!canUseNoiseMeter) {
    milog.shout("NO podemos usar NoiseMeter.");
    return;
  }
  try {
    if (!await Permission.microphone.isGranted) {
      milog.info("NO tenemos permiso de micrófono.");
      return;
    }
  } catch (e) {
    milog.shout("No tenemos ahora permiso de micrófono -> volvemos");
    return;
  }

  // Si llegamos aquí, se puede usar NoiseMeter
  try {
    noiseSubscription = noiseMeter?.noiseStream.listen((NoiseReading? result) async {
      try {
        if (result == null) return; // por si acaso
        debugPrint("HECTOR: Noise Event: ${result.toString()}");
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        if (currentTime - startTime > durationSeconds * 1000) {
          // ya hemos terminado -> sacamos los datos
          await noiseSubscription?.cancel();
          if ((numSamples) > 0 && (maxMaxDecibel != double.negativeInfinity)) {
            final double meanNoise = sumMeanDecibel / numSamples;
            final double stdDevNoise = numSamples > 1 ? sqrt(((sumMeanDecibelSquared / numSamples) - (meanNoise * meanNoise)).abs()) : 0.0;

            milog.info("Ya hemos recopilado los datos de noise durante $durationSeconds segundos");
            final dato = "maxMeanDecibel = $maxMeanDecibel, "
                "minMeanDecibel = $minMeanDecibel, "
                "sumMeanDecibel = $sumMeanDecibel, "
                "sumMeanDecibelSquared = $sumMeanDecibelSquared, "
                "meanNoise = $meanNoise, "
                "stdDevNoise = $stdDevNoise, "
                "maxMaxDecibel = $maxMaxDecibel, numSamples = $numSamples";
            // milog.info(dato);
            // const CEDILLA = "Ç";
            // const DOBLES_LLAVES_CERRADAS = "}}";
            final data = await createDataPoint(dato, dataType: "noise", code: code, deviceInfo: deviceInfo);
            String jsonEncodedData = jsonEncode(data.toJson());
            // y ahora el formato antiguo
            try {
              final Map<String, dynamic> dataMap = data.toJson();
              if (dataMap.containsKey("carp_body")) {
                final Map<String, dynamic> dataMapCarpBody = dataMap['carp_body'];
                dataMapCarpBody.remove("datameasured");
                dataMapCarpBody['max_decibel'] = maxMaxDecibel.toString();
                dataMapCarpBody['min_decibel'] = minMeanDecibel.toString();
                dataMapCarpBody['mean_decibel'] = meanNoise.toString();
                dataMapCarpBody['std_decibel'] = stdDevNoise.toString();
                dataMapCarpBody['num_samples'] = numSamples.toString();
                jsonEncodedData = jsonEncode(dataMap);
              }
            } catch (e) {
              milog.shout("Fallo usando dataMap en noise. Usamos formato moderno: e=${e.toString()}");
            }
            listaDataPoints.add(jsonEncodedData);
          } else {
            milog.info("Este dato no lo enviamos ya que maxMaxDecibel sigue al valor inicial -Infinity o numSamples = 0");
          }
          // var position = jsonEncodedData.lastIndexOf(DOBLES_LLAVES_CERRADAS).clamp(0, jsonEncodedData.length);
          // if (position > 0) {
          //   jsonEncodedData = jsonEncodedData.replaceFirst(DOBLES_LLAVES_CERRADAS, "", position);
          //   jsonEncodedData = jsonEncodedData.replaceFirst("datameasured", "max_decibel").replaceFirst(CEDILLA, maxMaxDecibel.toString());
          //   jsonEncodedData = '$jsonEncodedData,"min_decibel":"$minMeanDecibel"';
          //   jsonEncodedData = '$jsonEncodedData,"mean_decibel":"$meanNoise"';
          //   jsonEncodedData = '$jsonEncodedData,"std_decibel":"$stdDevNoise"}}';
          //   listaDataPoints.add(jsonEncodedData);
          // } else {
          //   milog.shout("Ojo, position no es > 0 en noise listener.");
          // }
        } else {
          // seguimos recopilando datos
          if (result.maxDecibel > maxMaxDecibel) maxMaxDecibel = result.maxDecibel;
          if (result.meanDecibel.isFinite) {
            numSamples++;
            if (result.meanDecibel > maxMeanDecibel) maxMeanDecibel = result.meanDecibel;
            if (result.meanDecibel < minMeanDecibel) minMeanDecibel = result.meanDecibel;
            sumMeanDecibel += result.meanDecibel;
            sumMeanDecibelSquared += result.meanDecibel * result.meanDecibel;
          } else {
            // si no es finito -> no seguimos recopilando datos, no merece la pena
            milog.info("Cancelamos la subscripción actual de ruido: no se están cogiendo datos finitos");
            await noiseSubscription?.cancel();
          }
        }
      } catch (e) {
        final mensaje = "HECTOR: Error en el listener de Noise Meter:  ${e.toString()}\n";
        debugPrint(mensaje);
        // Pero no hacemos nada más
      }
    });
  } catch (e) {
    milog.shout("No puedo instalar el listener de Noise Neter!!! Error: ${e.toString()}");
  }
}

Future<void> arrancaListeners({
  required String code,
  required String deviceInfo,
}) async {
  // aquí pongo info general que ya se debería conocer cuando se ejecuta esta función
  milog.info("Arrancando listeners");

  // para filtrar muchos eventos de activity seguidos
  int horaInicial = -1;
  String lastActivityResult = "";

  Future<void> sacaWifiInfo() async {
    String? wifiName, wifiBSSID, wifiIPv4;

    final NetworkInfo networkInfo = NetworkInfo();

    try {
      wifiName = await networkInfo.getWifiName();
      wifiName = wifiName?.replaceAll('"', '');
      if (wifiName != null && ENCRYPT_WIFI_INFO) {
        wifiName = md5.convert(utf8.encode(wifiName)).toString();
      }
      wifiName ??= 'Failed to get Wifi Name';
    } /*on PlatformException */ catch (e) {
      milog.warning('Failed to get Wifi Name: ${e.toString()}');
      wifiName = 'Failed to get Wifi Name';
    }

    try {
      wifiBSSID = await networkInfo.getWifiBSSID();
      if (wifiBSSID != null && ENCRYPT_WIFI_INFO) {
        wifiBSSID = md5.convert(utf8.encode(wifiBSSID)).toString();
      }
      wifiBSSID ??= 'Failed to get Wifi BSSID';
    } /*on PlatformException*/ catch (e) {
      milog.warning('Failed to get Wifi BSSID: ${e.toString()}');
      wifiBSSID = 'Failed to get Wifi BSSID';
    }

    try {
      wifiIPv4 = await networkInfo.getWifiIP();
      wifiIPv4 ??= 'Failed to get Wifi IPv4';
    } on PlatformException catch (e) {
      milog.warning('Failed to get Wifi IPv4: ${e.toString()}');
      wifiIPv4 = 'Failed to get Wifi IPv4';
    }

    final wifiInfo = 'Wifi Name: $wifiName,'
        'Wifi BSSID: $wifiBSSID, '
        'Wifi IPv4: $wifiIPv4';
    milog.info("wifiInfo: $wifiInfo");
    final data = await createDataPoint(wifiInfo, dataType: "wifi", code: code, deviceInfo: deviceInfo);
    String jsonEncodedData = jsonEncode(data.toJson()); // formato nuevo
    // y ahora el formato antiguo
    try {
      final Map<String, dynamic> dataMap = data.toJson();
      if (dataMap.containsKey("carp_body")) {
        final Map<String, dynamic> dataMapCarpBody = dataMap['carp_body'];
        dataMapCarpBody.remove("datameasured");
        dataMapCarpBody['ssid'] = wifiName;
        dataMapCarpBody['bssid'] = wifiBSSID;
        dataMapCarpBody['ipv4'] = wifiIPv4;
        jsonEncodedData = jsonEncode(dataMap);
      }
    } catch (e) {
      milog.shout("Fallo usando dataMap en wifi. Usamos formato moderno: e=${e.toString()}");
    }
    // Otra forma de hacerlo "a lo bestia"
    // String jsonEncodedData = jsonEncode(data.toJson());
    // var position = jsonEncodedData.lastIndexOf(DOBLES_LLAVES_CERRADAS).clamp(0, jsonEncodedData.length);
    // if (position > 0) {
    //   jsonEncodedData = jsonEncodedData.replaceFirst(DOBLES_LLAVES_CERRADAS, "", position);
    //   jsonEncodedData = jsonEncodedData.replaceFirst("datameasured", "ssid").replaceFirst(CEDILLA, wifiName ?? "");
    //   jsonEncodedData = '$jsonEncodedData,"bssid":"$wifiBSSID"';
    //   jsonEncodedData = '$jsonEncodedData,"ipv4":"$wifiIPv4"}}';
    //   milog.info(jsonEncodedData);

    listaDataPoints.add(jsonEncodedData);
  }

  if (USE_CONNECTIVITY) {
    // Al ser la primera vez, debemos guardar el dato de connectivity y la info de la wifi, si estamos en wifi
    final connectivityStatus = await Connectivity().checkConnectivity();
    final data = await createDataPoint(connectivityStatus.toString(), dataType: "connectivity", code: code, deviceInfo: deviceInfo);
    String jsonEncodedData = jsonEncode(data.toJson());
    jsonEncodedData = jsonEncodedData.replaceFirst("datameasured", "connectivity_status").replaceFirst("ConnectivityResult.", "");
    listaDataPoints.add(jsonEncodedData);
    if (USE_WIFI_INFO && (connectivityStatus == ConnectivityResult.wifi)) {
      unawaited(sacaWifiInfo());
    }
    connectivitySubscription2 = Connectivity().onConnectivityChanged.listen((ConnectivityResult? result) async {
      try {
        if (result == null) return; // por si acaso
        debugPrint("HECTOR: Connectivity Event: ${result.toString()}");
        final dato = result.toString();
        final data = await createDataPoint(dato, dataType: "connectivity", code: code, deviceInfo: deviceInfo);
        String jsonEncodedData = jsonEncode(data.toJson());
        jsonEncodedData = jsonEncodedData.replaceFirst("datameasured", "connectivity_status").replaceFirst("ConnectivityResult.", "");
        listaDataPoints.add(jsonEncodedData);
        if (USE_WIFI_INFO && (result == ConnectivityResult.wifi)) {
          unawaited(sacaWifiInfo());
        }
      } catch (e) {
        final mensaje = "HECTOR: Error en el listener de Connectivity:  ${e.toString()}\n";
        debugPrint(mensaje);
        // Pero no hacemos nada más
      }
    });
  }

  if (USE_SCREEN_STATE) {
    try {
      screenStateSubscription = Screen().screenStateStream!.listen((ScreenStateEvent? result) async {
        try {
          if (result == null) return; // por si acaso
          lastScreenState = result;
          debugPrint("HECTOR: ScreenState Event: ${result.toString()}");
          final dato = result.toString().replaceFirst("ScreenStateEvent.", "");
          final data = await createDataPoint(dato, dataType: "screen", code: code, deviceInfo: deviceInfo);
          String jsonEncodedData = jsonEncode(data.toJson());
          jsonEncodedData = jsonEncodedData.replaceFirst("datameasured", "screen_event");
          listaDataPoints.add(jsonEncodedData);
        } catch (e) {
          final mensaje = "HECTOR: Error en el listener de ScreenState:  ${e.toString()}\n";
          debugPrint(mensaje);
          // Pero no hacemos nada más
        }
      });
    } on ScreenStateException catch (e) {
      milog.shout("No puedo instalar el listener de ScreenState!!! Error: ${e.toString()}");
    }
  }

  if (USE_AR) {
    activitySubscription = activityRecognition.activityStream.handleError((e) {
      milog.shout("No puedo instalar el listener de ScreenState!!! Error: ${e.toString()}");
    }).listen((Activity? result) async {
      try {
        if (result == null) return; // por si acaso
        String actividad = "${result.type.toString()}:${result.confidence.toString()}";
        final horaActual = DateTime.now().millisecondsSinceEpoch;
        if (FILTRAR_DATOS_AR_SEGUIDOS) {
          if (horaActual - horaInicial < NUM_MS_MINIMO_ENTRE_MUESTRAS_IGUALES) {
            milog.info(
                "Este dato de AR ha llegado demasiado junto al anterior y son iguales. Lo ignoro. Esto es más robusto que comprobar si eran o no iguales");
            return;
          }
          // if ((horaActual - horaInicial < NUM_MS_MINIMO_ENTRE_MUESTRAS_IGUALES) && (actividad == lastActivityResult)) {
          //   milog.info("Este dato de AR ha llegado demasiado junto al anterior y son iguales. Lo ignoro");
          //   return;
          // }
        }
        milog.info("HECTOR: Activity Event: $actividad");
        // const CEDILLA = "Ç";
        // const DOBLES_LLAVES_CERRADAS = "}}";
        final data = await createDataPoint(actividad, dataType: "activity", code: code, deviceInfo: deviceInfo);
        String jsonEncodedData = jsonEncode(data.toJson());
        // y ahora el formato antiguo
        try {
          final Map<String, dynamic> dataMap = data.toJson();
          if (dataMap.containsKey("carp_body")) {
            final Map<String, dynamic> dataMapCarpBody = dataMap['carp_body'];
            dataMapCarpBody.remove("datameasured");
            dataMapCarpBody['type'] = result.type.toString();
            dataMapCarpBody['confidence'] = result.confidence.toString();
            jsonEncodedData = jsonEncode(dataMap);
            horaInicial = horaActual;
            lastActivityResult = actividad;
          }
        } catch (e) {
          milog.shout("Fallo usando dataMap en activity. Usamos formato moderno: e=${e.toString()}");
        }
        listaDataPoints.add(jsonEncodedData);
        // var position = jsonEncodedData.lastIndexOf(DOBLES_LLAVES_CERRADAS).clamp(0, jsonEncodedData.length);
        // if (position > 0) {
        //   jsonEncodedData = jsonEncodedData.replaceFirst(DOBLES_LLAVES_CERRADAS, "", position);
        //   jsonEncodedData = jsonEncodedData.replaceFirst("datameasured", "confidence").replaceFirst(CEDILLA, result.confidence.toString());
        //   jsonEncodedData = '$jsonEncodedData,"type":"${result.type.toString()}"}}';
        //   listaDataPoints.add(jsonEncodedData);
        //   horaInicial = horaActual;
        //   lastActivityResult = actividad;
        // } else {
        //   milog.severe(
        //       "Ojo, position no es > 0 en activity listener. No hago milog.shout por no saturar el servidor ya que esto puede repetirse mucho!!!");
        // }
      } catch (e) {
        final mensaje = "HECTOR: Error en el listener de Activity:  ${e.toString()}\n";
        debugPrint(mensaje);
        // Pero no hacemos nada más
      }
    });
  }
}

Future<void> cancelaListeners() async {
  if (USE_CONNECTIVITY) {
    await connectivitySubscription2?.cancel();
  }
  if (USE_SCREEN_STATE) {
    await screenStateSubscription?.cancel();
  }
  if (USE_AR) {
    await activitySubscription?.cancel();
  }
  // if (USE_LIGHT) {
  //   await lightSubscription?.cancel();
  // }
  // if (USE_NOISE_METER) {
  //   await noiseSubscription?.cancel();
  // }
}
