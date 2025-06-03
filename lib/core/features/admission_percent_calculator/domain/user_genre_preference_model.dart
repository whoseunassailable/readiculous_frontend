// To parse this JSON data, do
//
//     final userGenrePreferenceModel = userGenrePreferenceModelFromJson(jsonString);

import 'dart:convert';

UserGenrePreferenceModel userGenrePreferenceModelFromJson(String str) =>
    UserGenrePreferenceModel.fromJson(json.decode(str));

String userGenrePreferenceModelToJson(UserGenrePreferenceModel data) =>
    json.encode(data.toJson());

class UserGenrePreferenceModel {
  final List<String>? genres;
  final int? topN;

  UserGenrePreferenceModel({
    this.genres,
    this.topN,
  });

  UserGenrePreferenceModel copyWith({
    List<String>? genres,
    int? topN,
  }) =>
      UserGenrePreferenceModel(
        genres: genres ?? this.genres,
        topN: topN ?? this.topN,
      );

  factory UserGenrePreferenceModel.fromJson(Map<String, dynamic> json) =>
      UserGenrePreferenceModel(
        genres: json["genres"] == null
            ? []
            : List<String>.from(json["genres"]!.map((x) => x)),
        topN: json["top_n"],
      );

  Map<String, dynamic> toJson() => {
        "genres":
            genres == null ? [] : List<dynamic>.from(genres!.map((x) => x)),
        "top_n": topN,
      };
}
