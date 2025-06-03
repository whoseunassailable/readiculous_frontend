class University {
  final String? name;
  final String? greScore;
  final String? toeflScore;
  final String? location;
  final String? tuitionFees;

  University({
    this.name,
    this.greScore,
    this.toeflScore,
    this.location,
    this.tuitionFees,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      greScore: json['gre_score'],
      toeflScore: json['toefl_score'],
      location: json['location'],
      tuitionFees: json['tuition_fees'],
    );
  }
}
