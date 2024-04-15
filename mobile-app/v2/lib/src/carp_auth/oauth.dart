import 'package:json_annotation/json_annotation.dart';

part 'oauth.g.dart';

/// Holds information of a token issued by an OAuth authorization endpoint.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class OAuthToken {
  /// The OAuth access token.
  final String accessToken;

  /// The OAuth refresh token.
  final String refreshToken;

  /// The type of token.
  final String tokenType;

  /// Scope of this token:
  /// - read
  /// - read write
  // TODO : anything else?
  final String scope;

  /// Expires in seconds.
  int expiresIn;

  /// The date the access token was issued.
  final DateTime issuedDate = DateTime.now();

  /// Constructor
  OAuthToken(this.accessToken, this.refreshToken, this.tokenType,
      this.expiresIn, this.scope);

  /// Constructor taking a Map.
  OAuthToken.fromMap(Map<String, dynamic> map)
      : accessToken = map['access_token'],
        refreshToken = map['refresh_token'],
        tokenType = map['token_type'],
        expiresIn = map['expires_in'],
        scope = map['scope'];

  /// Clone this token.
  OAuthToken clone() =>
      OAuthToken(accessToken, refreshToken, tokenType, expiresIn, scope);

  /// Calculate the date of expiration for the access token.
  ///
  /// If access token has expired, the refresh token should be used
  /// in order to acquire a new access token.
  DateTime get accessTokenExpiryDate {
    Duration durationLeft = Duration(seconds: expiresIn);
    DateTime expiryDate = issuedDate.add(durationLeft);
    return expiryDate;
  }

  /// Expire the authenticated OAuth token for this user.
  void expire() => expiresIn = 0;

  /// Has the access token expired?
  bool get hasExpired => DateTime.now().isAfter(accessTokenExpiryDate);

  String get tokenInfo => "Access Token: $accessToken, "
      "Refresh Token: $refreshToken, "
      "Expiry date: $accessTokenExpiryDate";

  factory OAuthToken.fromJson(Map<String, dynamic> json) =>
      _$OAuthTokenFromJson(json);
  Map<String, dynamic> toJson() => _$OAuthTokenToJson(this);

  @override
  String toString() =>
      'OAuthToken - accessToken: $accessToken, refresh_token: $refreshToken, token_type: $tokenType, expires_in: $expiresIn, scope: $scope';
}

/// Specifies an OAuth 2.0 REST endpoint.
class OAuthEndPoint {
  /// The OAuth 2.0 client id.
  String clientID;

  /// The OAuth 2.0 client secret.
  String clientSecret;

  /// Path of the authentication endpoint.
  /// Default is `/oauth/token`
  String path;

  OAuthEndPoint({
    required this.clientID,
    required this.clientSecret,
    this.path = "/oauth/token",
  });
}
