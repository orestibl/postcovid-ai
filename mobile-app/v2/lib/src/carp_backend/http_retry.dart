import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:postcovid_ai_sin_carp/src/carp_backend/carp_backend_modificado.dart';

import '../../main.dart';
import '../../my_logger.dart';
import '../helper_functions.dart';

/// A MultipartFile class which support cloning of the file for re-submission
/// of POST request.
// class MultipartFileRecreatable extends http.MultipartFile {
//   final String filePath;
//
//   MultipartFileRecreatable(
//     this.filePath,
//     super.field,
//     super.stream,
//     super.length, {
//     super.filename,
//     super.contentType,
//   });
//
//   /// Creates a new [MultipartFileRecreatable] from a file specified by
//   /// the [filePath].
//   factory MultipartFileRecreatable.fromFileSync(String filePath) {
//     final file = File(filePath);
//     final length = file.lengthSync();
//     final stream = file.openRead();
//     var name = file.path.split('/').last;
//
//     return MultipartFileRecreatable(
//       filePath,
//       'file',
//       stream,
//       length,
//       filename: name,
//     );
//   }
//
//   /// Make a clone of this [MultipartFileRecreatable].
//   MultipartFileRecreatable clone() => MultipartFileRecreatable.fromFileSync(filePath);
// }

/// A class wrapping all HTTP operations (GET, POST, PUT, DELETE) in a retry manner.
///
/// In case of network problems ([SocketException] or [TimeoutException]),
/// this method will retry the HTTP operation N=15 times, with an increasing
/// delay time as 2^(N+1) * 5 secs (20, 40, , ..., 10.240).
/// I.e., maximum retry time is ca. three hours.
class HTTPRetry {
  // default values (DELAY and TIMEOUT in seconds)
  static const MAX_ATTEMPTS = 3;
  static const DELAY = 5;
  static const TIMEOUT = 30;
  var client = http.Client();

  /// Sends an HTTP GET request with the given [headers] to the given [url].
  Future<http.Response> get(String url,
      {Map<String, String>? headers,
      int maxAttempts = HTTPRetry.MAX_ATTEMPTS,
      int delay = HTTPRetry.DELAY,
      int timeout = HTTPRetry.TIMEOUT}) async {
    debugPrint("HECTOR:HTTP_RETRY.DART: get");
    debugPrint(Uri.encodeFull(url));
    debugPrint("headers:\n$headers");

    for (int i = 1; i <= maxAttempts; i++) {
      try {
        final http.Response response = await client
            .get(
              Uri.parse(Uri.encodeFull(url)),
              headers: headers,
            )
            .timeout(Duration(seconds: timeout));
        // debugPrintWrapped("HECTOR: Respuesta: ${response.body}");
        return response;
      } catch (e) {
        await Future.delayed(Duration(seconds: delay));
        if (e is SocketException || e is TimeoutException || e is http.ClientException) {
          // lo seguimos intentando
          final cadena = 'HECTOR: ${e.runtimeType.toString()} - Retrying to GET $url: Error: ${e.toString()}';
          milog.shout(cadena);
        } else {
          final cadena = 'HECTOR: ${e.runtimeType.toString()} - Excepción fuera de lo esperado en GET $url: Error: ${e.toString()}';
          milog.shout(cadena);
          break;
        }
      }
    }
    throw CarpServiceException(httpStatus: HTTPStatus(500));
    // return http.Response("", 500);
  }

  /// Sends an HTTP POST request with the given [headers] and [body] to the given [url].
  Future<http.Response> post(String url,
      {Map<String, String>? headers,
      body,
      Encoding? encoding,
      int maxAttempts = HTTPRetry.MAX_ATTEMPTS,
      int delay = HTTPRetry.DELAY,
      int timeout = HTTPRetry.TIMEOUT}) async {
    // calling the http POST method using the retry approach
    // HECTOR: PARA VER QUÉ PASA EXACTAMENTE CON EL SERVIDOR
    // HECTOR: le añado que se puedan pasar los maxAttempts como parámetro opcional
    debugPrint("HECTOR:HTTP_RETRY.DART: post");
    debugPrint(Uri.encodeFull(url));
    debugPrint("headers:\n$headers");
    debugPrint("body:\n$body");
    for (int i = 1; i <= maxAttempts; i++) {
      try {
        final http.Response response = await client
            .post(
              Uri.parse(Uri.encodeFull(url)),
              headers: headers,
              body: body,
              encoding: encoding,
            )
            .timeout(Duration(seconds: timeout));
        debugPrintWrapped("HECTOR: Respuesta: ${response.body}");
        return response;
      } catch (e) {
        await Future.delayed(Duration(seconds: delay));
        if (e is SocketException || e is TimeoutException || e is http.ClientException) {
          // lo seguimos intentando
          final cadena = 'HECTOR: ${e.runtimeType.toString()} - Retrying to POST $url: Error: ${e.toString()}';
          milog.shout(cadena);
        } else {
          final cadena = 'HECTOR: ${e.runtimeType.toString()} - Excepción fuera de lo esperado en POST $url: Error: ${e.toString()}';
          milog.shout(cadena);
          break;
        }
      }
    }
    throw CarpServiceException(httpStatus: HTTPStatus(500));
  }

  /// Sends an HTTP PUT request with the given [headers] and [body] to the given [url].
  Future<http.Response> put(String url,
      {Map<String, String>? headers,
      body,
      Encoding? encoding,
      int maxAttempts = HTTPRetry.MAX_ATTEMPTS,
      int delay = HTTPRetry.DELAY,
      int timeout = HTTPRetry.TIMEOUT}) async {
    // calling the http PUT method using the retry approach
    debugPrint("HECTOR:HTTP_RETRY.DART: put");
    debugPrint(Uri.encodeFull(url));
    debugPrint("headers:\n$headers");
    for (int i = 1; i <= maxAttempts; i++) {
      try {
        final http.Response response = await client
            .put(
              Uri.parse(Uri.encodeFull(url)),
              headers: headers,
              body: body,
              encoding: encoding,
            )
            .timeout(Duration(seconds: timeout));
        debugPrintWrapped("HECTOR: Respuesta: ${response.body}");
        return response;
      } catch (e) {
        await Future.delayed(Duration(seconds: delay));
        if (e is SocketException || e is TimeoutException || e is http.ClientException) {
          // lo seguimos intentando
          final cadena = 'HECTOR: ${e.runtimeType.toString()} - Retrying to PUT $url: Error: ${e.toString()}';
          milog.shout(cadena);
        } else {
          final cadena = 'HECTOR: ${e.runtimeType.toString()} - Excepción fuera de lo esperado en PUT $url: Error: ${e.toString()}';
          milog.shout(cadena);
          break;
        }
      }
    }
    throw CarpServiceException(httpStatus: HTTPStatus(500));
  }

  /// Sends an HTTP DELETE request with the given [headers] to the given [url].
  Future<http.Response> delete(String url,
      {Map<String, String>? headers,
      int maxAttempts = HTTPRetry.MAX_ATTEMPTS,
      int delay = HTTPRetry.DELAY,
      int timeout = HTTPRetry.TIMEOUT}) async {
    // calling the http DELETE method using the retry approach
    debugPrint("HECTOR:HTTP_RETRY.DART: delete");
    debugPrint(Uri.encodeFull(url));
    debugPrint("headers:\n$headers");
    for (int i = 1; i <= maxAttempts; i++) {
      try {
        final http.Response response = await client
            .delete(
              Uri.parse(Uri.encodeFull(url)),
              headers: headers,
            )
            .timeout(Duration(seconds: timeout));

        debugPrintWrapped("HECTOR: Respuesta: ${response.body}");
        return response;
      } catch (e) {
        await Future.delayed(Duration(seconds: delay));
        if (e is SocketException || e is TimeoutException || e is http.ClientException) {
          // lo seguimos intentando
          final cadena = 'HECTOR: ${e.runtimeType.toString()} - Retrying to DELETE $url: Error: ${e.toString()}';
          milog.shout(cadena);
        } else {
          final cadena = 'HECTOR: ${e.runtimeType.toString()} - Excepción fuera de lo esperado en DELETE $url: Error: ${e.toString()}';
          milog.shout(cadena);
          break;
        }
      }
    }
    throw CarpServiceException(httpStatus: HTTPStatus(500));
  }

  Future<bool> batchPostDataLongString(String longString, String url, Map<String, String> headers,
      {int maxAttempts = 1, int timeoutSeconds = MI_TIMEOUT, int delay = 5}) async {
    // var client = http.Client();

    debugPrint("HECTOR:batchPostDataLongString");
    debugPrint(url.toString());
    debugPrint(headers.toString());

    for (int i = 1; i <= maxAttempts; i++) {
      try {
        milog.info("batchPostDataLongString: intento $i");
        var request = http.MultipartRequest("POST", Uri.parse(url));
        request.headers['Authorization'] = headers['Authorization']!;
        request.headers['Content-Type'] = 'multipart/form-data';
        request.headers['cache-control'] = 'no-cache';
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            utf8.encode(longString),
            filename: "file${Random().nextInt(100000)}.txt",
            contentType: MediaType('application', 'json'),
          ),
        );
        final response = await client.send(request).timeout(Duration(seconds: timeoutSeconds));
        final httpStatusCode = response.statusCode;
        if ((httpStatusCode == HttpStatus.ok) || (httpStatusCode == HttpStatus.created)) {
          return true;
        } else {
          final primero = await response.stream.toStringStream().first;
          final Map<String, dynamic> responseJson = json.decode(primero);
          milog.shout(
              "batchPostDataPointLongString: Algo ha salido mal, y parece culpa nuestra -> devuelvo true para quitar esos datos: $httpStatusCode, ${response.reasonPhrase}, ${responseJson['message']}, ${responseJson['path']}");
          // throw CarpServiceException(
          //   httpStatus: HTTPStatus(httpStatusCode, response.reasonPhrase),
          //   message: responseJson["message"],
          //   path: responseJson["path"],
          // );
          //return false;
          // HECTOR: MUCHO OJO, A PESAR DEL ERROR DEVUELVO TRUE PORQUE NO SE DEBE A UN ERROR DEL SERVIDOR: EL SERVIDOR SÍ HA CONTESTADO ->
          // NO HAY NADA QUE SE PUEDA HACER YA -> QUE EL PROGRAMA SIGA CREYENDO QUE SE HA ENVIADO ESE BATCH CON LA ESPERANZA DE QUE
          // ESE "OFFENDING DATAPOINT" SE BORRE.
          return true;
        }
      } catch (e) {
        if (e is SocketException || e is TimeoutException || e is http.ClientException) {
          // lo seguimos intentando
          final cadena = 'HECTOR: ${e.runtimeType.toString()} - Retrying to SEND: Error: ${e.toString()}';
          milog.shout(cadena);
          if (i < maxAttempts) {
            milog.info("batchPostDataLongString: tras el fallo, hacemos un delay de $delay segundos");
            await Future.delayed(Duration(seconds: delay));
          }
        } else {
          final cadena =
              'HECTOR: ${e.runtimeType.toString()} - Excepción fuera de lo esperado en SEND. Devolvemos false: Error: ${e.toString()}';
          milog.shout(cadena);
          return false;
        }
      }
    }
    milog.shout("batchPostDataLongString. Devolvemos false después de $maxAttempts intentos");
    return false;
  }

  // /// Sends an generic HTTP [MultipartRequest].
  // Future<http.StreamedResponse> send(http.MultipartRequest request,
  //     {int maxAttempts = HTTPRetry.MAX_ATTEMPTS, int delay = HTTPRetry.DELAY, int timeout = HTTPRetry.TIMEOUT}) async {
  //   debugPrint("HECTOR:HTTP_RETRY.DART: send");
  //   debugPrint(request.url.toString());
  //   debugPrint(request.headers.toString());
  //
  //   // final response = await request.send();  // FUNCIONA!!!
  //   // debugPrint(response.toString());
  //
  //   // final response = await client.send(request); //FUNCIONA!!!
  //   // debugPrint(response.toString());
  //
  //   http.MultipartRequest sending = request;
  //
  //   for (int i = 1; i <= maxAttempts; i++) {
  //     try {
  //       final response = await client.send(sending).timeout(Duration(seconds: timeout));
  //       return response;
  //     } catch (e) {
  //       if (e is SocketException || e is TimeoutException || e is http.ClientException) {
  //         // lo seguimos intentando
  //         final cadena = 'HECTOR: ${e.runtimeType.toString()} - Retrying to SEND: Error: ${e.toString()}';
  //         milog.shout(cadena);
  //         await Future.delayed(Duration(seconds: delay));
  //         // when retrying sending form data, the request needs to be cloned
  //         // see e.g. >> https://github.com/flutterchina/dio/issues/482
  //         sending = http.MultipartRequest(request.method, request.url);
  //         sending.headers.addAll(request.headers);
  //         sending.fields.addAll(request.fields);
  //
  //         for (var file in request.files) {
  //           if (file is MultipartFileRecreatable) {
  //             sending.files.add(file.clone());
  //           }
  //         }
  //       } else {
  //         final cadena = 'HECTOR: ${e.runtimeType.toString()} - Excepción fuera de lo esperado en SEND: Error: ${e.toString()}';
  //         milog.shout(cadena);
  //         throw CarpServiceException(httpStatus: HTTPStatus(500));
  //       }
  //     }
  //   }
  //   throw CarpServiceException(httpStatus: HTTPStatus(500));
  // }
}
