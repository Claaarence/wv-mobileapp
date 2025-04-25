class Partner {
  final int partnerId;
  final String givenName;
  final String familyName;

  Partner({
    required this.partnerId,
    required this.givenName,
    required this.familyName,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      partnerId: json["partner_id"],
      givenName: json["given_name"] ?? "",
      familyName: json["family_name"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "partner_id": partnerId,
      "given_name": givenName,
      "family_name": familyName,
    };
  }
}
