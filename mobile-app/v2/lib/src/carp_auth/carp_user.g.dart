// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carp_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarpUser _$CarpUserFromJson(Map<String, dynamic> json) => CarpUser(
      username: json['username'] as String,
      id: json['id'] as int?,
      accountId: json['account_id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      isActivated: json['is_activated'] as bool? ?? true,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      department: json['department'] as String?,
      organization: json['organization'] as String?,
    )
      ..termsAgreed = json['terms_agreed'] == null
          ? null
          : DateTime.parse(json['terms_agreed'] as String)
      ..created = json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String)
      ..role = (json['role'] as List<dynamic>).map((e) => e as String).toList()
      ..token = json['token'] == null
          ? null
          : OAuthToken.fromJson(json['token'] as Map<String, dynamic>);

Map<String, dynamic> _$CarpUserToJson(CarpUser instance) {
  final val = <String, dynamic>{
    'username': instance.username,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('account_id', instance.accountId);
  writeNotNull('is_activated', instance.isActivated);
  writeNotNull('email', instance.email);
  writeNotNull('first_name', instance.firstName);
  writeNotNull('last_name', instance.lastName);
  writeNotNull('phone', instance.phone);
  writeNotNull('department', instance.department);
  writeNotNull('organization', instance.organization);
  writeNotNull('terms_agreed', instance.termsAgreed?.toIso8601String());
  writeNotNull('created', instance.created?.toIso8601String());
  val['role'] = instance.role;
  writeNotNull('token', instance.token);
  return val;
}
