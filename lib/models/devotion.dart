class Devotion {
  final int id;
  final String title;
  final String devoDate;
  final String url;
  final String createdAt;

  Devotion({
    required this.id,
    required this.title,
    required this.devoDate,
    required this.url,
    required this.createdAt,
  });

  factory Devotion.fromJson(Map<String, dynamic> json) {
    return Devotion(
      id: json['id'],
      title: json['title'] ?? '',
      devoDate: json['devo_date'] ?? '',
      url: json['url'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
