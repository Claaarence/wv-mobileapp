import '../models/partner.dart';

class User {
  final int partnerId;
  final String avatarUrl;
  final Partner partner;

  User({
    required this.partnerId,
    required this.avatarUrl,
    required this.partner,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      partnerId: json["partner_id"],
      avatarUrl: json["avatar_url"] ?? "",
      partner: Partner.fromJson(json["partner"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "partner_id": partnerId,
      "avatar_url": avatarUrl,
      "partner": partner.toJson(),
    };
  }
}
