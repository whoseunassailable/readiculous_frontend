// To parse this JSON data, do
//
//     final userSpecificGenreModel = userSpecificGenreModelFromJson(jsonString);

import 'dart:convert';

List<UserSpecificGenreModel> userSpecificGenreModelFromJson(String str) =>
    List<UserSpecificGenreModel>.from(
        json.decode(str).map((x) => UserSpecificGenreModel.fromJson(x)));

String userSpecificGenreModelToJson(List<UserSpecificGenreModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserSpecificGenreModel {
  final int? genreId;
  final String? name;

  UserSpecificGenreModel({
    this.genreId,
    this.name,
  });

  UserSpecificGenreModel copyWith({
    int? genreId,
    String? name,
  }) =>
      UserSpecificGenreModel(
        genreId: genreId ?? this.genreId,
        name: name ?? this.name,
      );

  factory UserSpecificGenreModel.fromJson(Map<String, dynamic> json) =>
      UserSpecificGenreModel(
        genreId: json["genre_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "genre_id": genreId,
        "name": name,
      };
}
