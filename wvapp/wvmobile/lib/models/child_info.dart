class ChildInfo {
  final String status;
  final String childId;
  final String name;
  final String givenName;
  final String familyName;
  final String birthdate;
  final String genderCode;
  final String favoriteSubject;
  final String favoritePlay;
  final String schoolLevel;
  final String thumb;
  final String image;
  final String text;

  ChildInfo({
    required this.status,
    required this.childId,
    required this.name,
    required this.givenName,
    required this.familyName,
    required this.birthdate,
    required this.genderCode,
    required this.favoriteSubject,
    required this.favoritePlay,
    required this.schoolLevel,
    required this.thumb,
    required this.image,
    required this.text,
  });

  factory ChildInfo.fromJson(Map<String, dynamic> json) {
    return ChildInfo(
      status: json['status'] ?? '',
      childId: json['child_id'] ?? '',
      name: json['name'] ?? '',
      givenName: json['given_name'] ?? '',
      familyName: json['family_name'] ?? '',
      birthdate: json['birthdate'] ?? '',
      genderCode: json['gender_code'] ?? '',
      favoriteSubject: json['favorite_subject'] ?? '',
      favoritePlay: json['favorite_play'] ?? '',
      schoolLevel: json['school_level'] ?? '',
      thumb: json['thumb'] ?? '',
      image: json['image'] ?? '',
      text: json['paragraph_body'] ?? '',
    );
  }
}
