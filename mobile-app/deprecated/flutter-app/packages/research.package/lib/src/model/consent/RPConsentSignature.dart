part of research_package_model;

/// Class representing a signature in a consent document
///
/// Signatures can be collected during a [RPConsentReviewStep].
///
/// The signature object has no concept of a cryptographic signature – it is merely
/// a record of any input the user made during a consent review step.
/// Also, the object does not verify or vouch for user identity.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class RPConsentSignature extends Serializable {
  /// The parameter to decide if the signature requires name.
  ///
  /// If set to [true] it requires an entered name.
  bool requiresName;

  /// The parameter to decide if the signature requires a signature image.
  ///
  /// If set to [true] the participant has to draw their signature which will
  /// be saved as a picture later.
  bool requiresSignatureImage;

  /// Not implemented yet
  bool requiresBirthDate;

  /// Unique identifier of the signature. This identifies the signature in the
  /// result hierarchy.
  ///
  /// In a result object of a task which collects signature the identifier of
  /// the [RPConsentSignatureResult] object on the deepest level is identical to
  /// this identifier.
  String identifier;

  /// The title
  String title;

  /// The default constructor. Returns a signature where both the name and the signature image is required
  RPConsentSignature(
    this.identifier, {
    this.title,
    this.requiresName = true,
    this.requiresSignatureImage = true,
    this.requiresBirthDate = false,
  });

  Function get fromJsonFunction => _$RPConsentSignatureFromJson;
  factory RPConsentSignature.fromJson(Map<String, dynamic> json) =>
      FromJsonFactory().fromJson(json);
  Map<String, dynamic> toJson() => _$RPConsentSignatureToJson(this);
}
