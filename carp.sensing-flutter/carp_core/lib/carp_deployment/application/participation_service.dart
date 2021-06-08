/*
 * Copyright 2021 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
part of carp_core_deployment;

/// Application service which allows inviting participants, retrieving participations
/// for study deployments, and managing data related to participants which is
/// input by users.
abstract class ParticipationService {
  /// Let the person with the specified [identity] participate in the study
  /// deployment with [studyDeploymentId], using the master devices with the
  /// specified [assignedMasterDeviceRoleNames].
  ///
  /// In case no account is associated to the specified [identity], a new account
  /// is created.
  ///
  /// An [invitation] (and account details) is delivered to the person managing
  /// the [identity], or should be handed out manually to the relevant participant
  /// by the person managing the specified [identity].
  Future<Participation> addParticipation(
    String studyDeploymentId,
    Set<String> assignedMasterDeviceRoleNames,
    AccountIdentity identity,
    StudyInvitation invitation,
  );

  /// Get all participations of active study deployments the account with the
  /// given [accountId] has been invited to.
  Future<List<ActiveParticipationInvitation>> getActiveParticipationInvitations(
      String accountId);

  /// Get currently set data for all expected participant data in the study
  /// deployment with [studyDeploymentId].
  /// Data which is not set equals null.
  Future<ParticipantData> getParticipantData(String studyDeploymentId);

  /// Get currently set data for all expected participant data for a set of study
  /// deployments with [studyDeploymentIds].
  /// Data which is not set equals null.
  Future<List<ParticipantData>> getParticipantDataList(
      List<String> studyDeploymentIds);

  /// Set participant [data] for the given [inputDataType] in the study deployment
  /// with [studyDeploymentId].
  ///
  /// Returns all data for the specified study deployment, including the newly
  /// set data.
  Future<ParticipantData> setParticipantData(
    String studyDeploymentId,
    String inputDataType,
    ParticipantData data,
  );
}
