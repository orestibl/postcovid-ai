import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../credentials.dart';
import '../../main.dart';
import '../carp_auth/carp_user.dart';
import '../carp_auth/oauth.dart';

// String _encode(Object object) =>
//     const JsonEncoder.withIndent(' ').convert(object);

/// Exception for CARP REST/HTTP service communication.
class CarpServiceException implements Exception {
  HTTPStatus? httpStatus;
  String? message;
  String? path;

  CarpServiceException({this.httpStatus, this.message, this.path});

  @override
  String toString() => "CarpServiceException: ${(httpStatus != null) ? "$httpStatus - " : ""} ${message ?? ""} - ${path ?? ""}";
}

/// Implements HTTP Response Code and associated Reason Phrase.
/// See https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
class HTTPStatus {
  /// Mapping of the most common HTTP status code to text.
  /// See https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
  static const Map<int, String> httpStatusPhrases = {
    100: "Continue",
    200: "OK",
    201: "Created",
    202: "Accepted",
    300: "Multiple Choices",
    301: "Moved Permanently",
    400: "Bad Request",
    401: "Unauthorized",
    402: "Payment Required",
    403: "Forbidden",
    404: "Not Found",
    405: "Method Not Allowed",
    408: "Request Timeout",
    409: "Conflict",
    410: "Gone",
    500: "Internal Server Error",
    501: "Not Implemented",
    502: "Bad Gateway",
    503: "Service Unavailable",
    504: "Gateway Timeout",
    505: "HTTP Version Not Supported",
  };

  int httpResponseCode;
  String? httpReasonPhrase;

  HTTPStatus(this.httpResponseCode, [String? httpPhrase]) {
    httpReasonPhrase = ((httpPhrase == null) || (httpPhrase.isEmpty)) ? httpStatusPhrases[httpResponseCode] : httpPhrase;
  }

  @override
  String toString() => "$httpResponseCode $httpReasonPhrase";
}

/// Represents a CARP web service app endpoint.
class CarpApp {
  /// The name of this app. The name has to be unique.
  final String name;

  /// URI of the CARP web service
  final Uri uri;

  /// The OAuth 2.0 endpoint.
  final OAuthEndPoint oauth;

  /// The CARP study id for this app.
  String? studyId;

  /// The CARP study deployment id of this app.
  String? studyDeploymentId;

  /// Create a [CarpApp] which know how to access a CARP backend.
  ///
  /// [name], [uri], and [oauth] are required parameters in order to identify,
  /// address, and authenticate this client.
  ///
  /// A [studyDeploymentId] and a [study] may be specified, if known at the
  /// creation time.
  CarpApp({
    required this.name,
    required this.uri,
    required this.oauth,
    this.studyDeploymentId,
    this.studyId,
  });

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(other) => name == other;

  @override
  String toString() => 'CarpApp - name: $name, uri: $uri, studyDeploymentId: $studyDeploymentId, studyId: $studyId';
}

/// An abstract base service class for all CARP Services:
///  * [CarpService]
///  * [DeploymentService]
///  * [ProtocolService]
///  * [ParticipationService]
///
abstract class CarpBaseService {
  CarpApp? _app;
  CarpUser? _currentUser;

  /// The CARP app associated with the CARP Web Service.
  /// Returns `null` if this service has not yet been congfigured via the
  /// [configure] method.
  CarpApp? get app => _app;

  /// Has this service been configured?
  bool get isConfigured => (_app != null);

  /// Configure the this instance of a Carp Service.
  void configure(CarpApp app) {
    _app = app;
  }

  /// Configure from another [service] which has alreay been configured
  /// and potentially authenticated.
  void configureFrom(CarpBaseService service) {
    _app = service._app;
    _currentUser = service._currentUser;
  }

  /// Gets the current user.
  /// Returns `null` if no user is authenticated.
  CarpUser? get currentUser => _currentUser;

  /// The endpoint name for this service at CARP.
  String get rpcEndpointName;

  /// The URL for this service's endpoint at CARP.
  ///
  /// Typically on the form:
  /// `{{PROTOCOL}}://{{SERVER_HOST}}:{{SERVER_PORT}}/api/...`
  String get rpcEndpointUri => "${app!.uri.toString()}/api/$rpcEndpointName";

  /// The headers for any authenticated HTTP REST call to a [CarpBaseService].
  Map<String, String> get headers {
    if (CarpService().currentUser!.token == null) {
      throw CarpServiceException(message: "OAuth token is null. Call 'CarpService().authenticate()' first.");
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "bearer ${CarpService().currentUser!.token!.accessToken}",
      "cache-control": "no-cache"
    };
  }
}

/// Provide access to a CARP web service endpoint.
///
/// The (current) assumption is that each Flutter app (using this library) will
/// only connect to one CARP web service backend.
/// Therefore the `CarpService` class is a singleton and should be used like:
///
/// ```dart
///   CarpService().configure(myApp);
///   CarpUser user = await CarpService().authenticate(username: "user@dtu.dk", password: "password");
/// ```
class CarpService extends CarpBaseService {
  static final CarpService _instance = CarpService._();
  CarpService._();

  /// Returns the singleton default instance of the [CarpService].
  /// Before this instance can be used, it must be configured using the
  /// [configure] method.
  factory CarpService() => _instance;

  @override
  // RPC is not used in the CarpService endpoints which are named differently.
  String get rpcEndpointName => throw UnimplementedError();

  // --------------------------------------------------------------------------
  // AUTHENTICATION
  // --------------------------------------------------------------------------

  String get _authHeaderBase64 => base64.encode(utf8.encode("${_app!.oauth.clientID}:${_app!.oauth.clientSecret}"));

  /// The URI for the authenticated endpoint for this [CarpService].
  ///
  /// The fomat is `https://cans.cachet.dk/forgotten` for the production host
  /// and `https://cans.cachet.dk/portal/stage/forgotten` for the stage, test,
  /// and dev hosts.
  String get authEndpointUri => "${_app!.uri}${_app!.oauth.path}";

  /// The URL for the reset password page for this [CarpService].
  String get resetPasswordUrl {
    String url = "${_app!.uri}";
    String host = '';
    if (url.contains('dev')) host = 'dev';
    if (url.contains('test')) host = 'test';
    if (url.contains('stage')) host = 'stage';
    if (host.isNotEmpty) {
      String rawUri = url.substring(0, url.indexOf(host));
      url = '${rawUri}portal/$host';
    }
    url += '/forgotten';

    debugPrint('url = $url');

    return url;
  }

  /// The HTTP header for the authentication requests.
  Map<String, String> get _authenticationHeader =>
      {"Authorization": "Basic $_authHeaderBase64", "Content-Type": "application/x-www-form-urlencoded", "Accept": "application/json"};

  /// Is a user authenticated?
  /// If `true`, the authenticated user is [currentUser].
  bool get authenticated => (_currentUser != null);

  final StreamController<AuthEvent> _authEventController = StreamController.broadcast();

  /// Notifies about changes to the user's authentication state (such as sign-in or
  /// sign-out) as defined in [AuthEvent].
  Stream<AuthEvent> get authStateChanges => _authEventController.stream.asBroadcastStream();

  /// Authenticate to this CARP service using a [username] and [password].
  ///
  /// Return the signed in user (with an [OAuthToken] access token), if successful.
  /// Throws a [CarpServiceException] if not successful.
  Future<CarpUser> authenticate({
    required String username,
    required String password,
  }) async {
    if (_app == null) {
      throw CarpServiceException(message: "CARP Service not initialized. Call 'CarpService().configure()' first.");
    }

    _currentUser = CarpUser(username: username);

    final loginBody = {
      "client_id": _app!.oauth.clientID,
      "client_secret": _app!.oauth.clientSecret,
      "grant_type": "password",
      "scope": "read",
      "username": username,
      "password": password
    };

    final http.Response response = await httpr.post(
      Uri.encodeFull(authEndpointUri),
      headers: _authenticationHeader,
      body: loginBody,
    );

    int httpStatusCode = response.statusCode;
    Map<String, dynamic> responseJson = json.decode(response.body);

    if (httpStatusCode == HttpStatus.ok) {
      _currentUser!.authenticated(OAuthToken.fromMap(responseJson));
      await getCurrentUserProfile();
      _authEventController.add(AuthEvent.authenticated);
      return _currentUser!;
    }

    // All other cases are treated as a failed attempt and throws an error
    _authEventController.add(AuthEvent.failed);
    _currentUser = null;

    // auth error response from CARP is on the form
    //      {error: invalid_grant, error_description: Bad credentials}
    throw CarpServiceException(
      httpStatus: HTTPStatus(httpStatusCode, response.reasonPhrase),
      message: responseJson["error_description"],
    );
  }

  /// Authenticate to this CARP web service using username and a previously
  /// stored [OAuthToken] access token.
  ///
  /// This method can be used to re-authenticate a user if the token (and username)
  /// is known locally on the phone.
  /// Useful for keeping the token locally on the phone between starting/stopping
  /// the app.
  ///
  /// Return the signed in user (with an [OAuthToken] access token), if successful.
  /// Throws a [CarpServiceException] if not successful.
  Future<CarpUser> authenticateWithToken({
    required String username,
    required OAuthToken token,
  }) async {
    _currentUser = CarpUser(username: username)..authenticated(token);

    // refresh the token - it might have expired since it was saved.
    await refresh();

    await getCurrentUserProfile();
    _authEventController.add(AuthEvent.authenticated);
    return _currentUser!;
  }

  /// Get a new access token for the current user based on the
  /// previously granted refresh token.
  Future<OAuthToken> refresh() async {
    if (_app == null) {
      throw CarpServiceException(message: "CARP Service not initialized. Call 'CarpService().configure()' first.");
    }
    if (_currentUser == null) {
      throw CarpServiceException(message: "No user is authenticated. Call 'CarpService().autheticate()' first.");
    }

    // --data "refresh_token=my-refresh-token&grant_type=refresh_token"
    final loginBody = {"refresh_token": _currentUser!.token!.refreshToken, "grant_type": "refresh_token"};

    final http.Response response = await httpr.post(
      Uri.encodeFull(authEndpointUri),
      headers: _authenticationHeader,
      body: loginBody,
    );

    int httpStatusCode = response.statusCode;
    Map<String, dynamic> responseJson = json.decode(response.body);

    if (httpStatusCode == HttpStatus.ok) {
      OAuthToken refreshedToken = OAuthToken.fromMap(responseJson);
      _currentUser!.authenticated(refreshedToken);
      _authEventController.add(AuthEvent.refreshed);
      return refreshedToken;
    }

    // All other cases are treated as a failed attempt and throws an error
    _authEventController.add(AuthEvent.failed);
    _currentUser = null;
    throw CarpServiceException(
      httpStatus: HTTPStatus(httpStatusCode, response.reasonPhrase),
      message: responseJson["error_description"],
    );
  }

  /// The URL for sending email about a forgotten password.
  String get forgottenPasswordEmailUri => "${_app!.uri.toString()}/api/users/forgotten-password/send";

  /// Triggers the CARP backend to send a password-reset email to the given
  /// email address, which must correspond to an existing user of the current [app].
  ///
  /// Returns the email address returned from CARP, if successful.
  /// Throws a [CarpServiceException] if not successful.
  Future<String> sendForgottenPasswordEmail({
    required String email,
  }) async {
    if (_app == null) {
      throw CarpServiceException(message: "CARP Service not initialized. Call 'CarpService().configure()' first.");
    }
    final String body = '{	"emailAddress": "$email" }';
    final http.Response response = await httpr.post(
      Uri.encodeFull(authEndpointUri),
      headers: _authenticationHeader,
      body: body,
    );

    int httpStatusCode = response.statusCode;
    Map<String, dynamic> responseJson = json.decode(response.body);

    if (httpStatusCode == HttpStatus.ok) {
      _authEventController.add(AuthEvent.reset);
      return responseJson['emailAddress'];
    }

    // All other cases are treated as an error
    throw CarpServiceException(
      httpStatus: HTTPStatus(httpStatusCode, response.reasonPhrase),
      message: responseJson["error_description"],
    );
  }

  /// Logout from CARP
  Future<void> logout() async {
    _currentUser = null;
  }

  // --------------------------------------------------------------------------
  // USERS
  // --------------------------------------------------------------------------

  /// The URL for the current user end point for this [CarpService].
  String get currentUserEndpointUri => "${_app!.uri.toString()}/api/users/current";

  /// The URL for the user endpoint for this [CarpService].
  String get userEndpointUri => "${_app!.uri.toString()}/api/users";

  /// The headers for any authenticated HTTP REST call to this [CarpService].
  @override
  Map<String, String> get headers {
    if (_currentUser!.token == null) {
      throw CarpServiceException(message: "OAuth token is null. Call 'CarpService().authenticate()' first.");
    }

    return {"Content-Type": "application/json", "Authorization": "bearer ${_currentUser!.token!.accessToken}", "cache-control": "no-cache"};
  }

  /// Asynchronously gets the CARP profile of the current user.
  Future<CarpUser> getCurrentUserProfile() async {
    if (currentUser == null || !currentUser!.isAuthenticated) {
      throw CarpServiceException(message: 'No user is authenticated.');
    }

    http.Response response = await httpr.get(Uri.encodeFull('$userEndpointUri/current'), headers: headers);
    int httpStatusCode = response.statusCode;
    Map<String, dynamic> responseJson = json.decode(response.body);

    if (httpStatusCode == HttpStatus.ok) {
      return _currentUser!
        ..id = responseJson['id']
        ..accountId = responseJson['accountId']
        ..isActivated = responseJson['isActivated'] as bool?
        ..firstName = responseJson['firstName']
        ..lastName = responseJson['lastName'];
    }

    // All other cases are treated as an error.
    throw CarpServiceException(
      httpStatus: HTTPStatus(httpStatusCode, response.reasonPhrase),
      message: responseJson["error_description"],
    );
  }

  /// Change the password of the current user.
  ///
  /// Return the signed in user (with an [OAuthToken] access token), if successful.
  /// Throws a [CarpServiceException] if not successful.
  Future<CarpUser> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    assert(newPassword.length >= 8, 'A new password must be longer than 8 characters.');

    if (currentUser == null || !currentUser!.isAuthenticated) {
      throw CarpServiceException(message: 'Must authenticate before password can be changed.');
    }

    final http.Response response = await httpr.put(
      Uri.encodeFull('$userEndpointUri/password'),
      headers: headers,
      body: '{"oldPassword":"$currentPassword","newPassword":"$newPassword"}',
    );

    if (response.statusCode == HttpStatus.ok) {
      // on success, CARP return nothing (empty string)
      // but we return the current logged in user anyway
      return _currentUser!;
    }

    // All other cases are treated as an error.
    Map<String, dynamic> responseJson = json.decode(response.body);
    throw CarpServiceException(
      httpStatus: HTTPStatus(response.statusCode, response.reasonPhrase),
      message: responseJson["message"],
      path: responseJson["path"],
    );
  }

  /// Sign out the current user.
  Future signOut() async {
    if (currentUser == null || !currentUser!.isAuthenticated) {
      throw CarpServiceException(message: 'No user is authenticated.');
    }

    _currentUser!.signOut();
    _currentUser = null;
    _authEventController.add(AuthEvent.unauthenticated);
  }
}

/// Authentication state change events.
enum AuthEvent {
  /// The user has successful been authenticated (signed in).
  authenticated,

  /// The user has been unauthenticated (signed out).
  unauthenticated,

  /// Authentication failed.
  failed,

  /// The user's token has successfully been refreshed.
  refreshed,

  /// A password reset email has been send to the user.
  reset,
}

class CarpBackend {
  static final CarpBackend _instance = CarpBackend._();

  CarpBackend._() : super();

  factory CarpBackend() => _instance;

  CarpApp? _app;

  CarpApp? get app => _app;

  Future initialize({required Map credentials}) async {
    _app = CarpApp(
      name: "CANS Production @ UGR",
      uri: Uri.parse(serverUri),
      oauth: OAuthEndPoint(clientID: credentials['client_id'], clientSecret: credentials['client_secret']),
    );

    // Configure and authenticate
    CarpService().configure(app!);
    await CarpService().authenticate(username: credentials['username'], password: credentials['password']);
  }
}
