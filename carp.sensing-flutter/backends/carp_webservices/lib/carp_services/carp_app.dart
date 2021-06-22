/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
part of carp_services;

/// Represents a CARP web service app endpoint.
class CarpApp {
  /// The name of this app.
  final String name;

  /// URI of the CARP web service
  final Uri uri;

  /// The OAuth 2.0 endpoint.
  final OAuthEndPoint oauth;

  /// The CARP study id for this app.
  String studyId;

  /// The CARP study deployment id of this app.
  String studyDeploymentId;

  // /// The CARP study for this app.
  // Study study;

  /// Create a [CarpApp] which know how to access a CARP backend.
  ///
  /// [name], [uri], and [oauth] are required parameters in order to identify,
  /// address, and authenticate this client.
  ///
  /// A [studyDeploymentId] and a [study] may be specified, if known at the
  /// creation time.
  CarpApp({
    @required this.name,
    @required this.uri,
    @required this.oauth,
    this.studyDeploymentId,
    this.studyId,
  }) {
    assert(name != null);
    assert(uri != null);
    assert(oauth != null);
    assert(oauth.clientID != null);
    assert(oauth.clientSecret != null);
  }

  int get hashCode => name.hashCode;

  bool operator ==(other) => name == other;

  String toString() =>
      'CarpApp - name: $name, uri: $uri, studyDeploymentId: $studyDeploymentId, studyId: $studyId';
}
