import 'package:json_annotation/json_annotation.dart';

part 'app_setting.g.dart';

@JsonSerializable()
class AppSetting {
  const AppSetting({
    this.websiteName,
    this.websiteDescription,
    this.websiteUrl,
    this.icpNumber,
    this.icpUrl,
    this.companyName,
    this.companyAddress,
    this.companyPhone,
    this.logoUrl,
    this.logoSmallUrl,
    this.logoOnLoginUrl,
    this.logoWithTextUrl,
    this.logoWithTextLightUrl,
    this.customerServicePhone,
    this.customerServiceEmail,
    this.customerServiceQrcodeUrl,
    this.businessContactPhone,
    this.businessContactEmail,
    this.businessContactQrcodeUrl,
    this.privacyAgreementUrl,
    this.privacyPolicyUrl,
  });

  final String? websiteName;
  final String? websiteDescription;
  final String? websiteUrl;
  final String? icpNumber;
  final String? icpUrl;
  final String? companyName;
  final String? companyAddress;
  final String? companyPhone;
  final String? logoUrl;
  final String? logoSmallUrl;
  final String? logoOnLoginUrl;
  final String? logoWithTextUrl;
  final String? logoWithTextLightUrl;
  final String? customerServicePhone;
  final String? customerServiceEmail;
  final String? customerServiceQrcodeUrl;
  final String? businessContactPhone;
  final String? businessContactEmail;
  final String? businessContactQrcodeUrl;
  final String? privacyAgreementUrl;
  final String? privacyPolicyUrl;

  factory AppSetting.fromJson(Map<String, dynamic> json) =>
      _$AppSettingFromJson(json);
  Map<String, dynamic> toJson() => _$AppSettingToJson(this);
}
