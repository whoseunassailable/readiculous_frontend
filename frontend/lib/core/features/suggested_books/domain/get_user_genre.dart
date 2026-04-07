// To parse this JSON data, do
//
//     final createUser = createUserFromJson(jsonString);

import 'dart:convert';

List<GetUserGenreModel> createUserFromJson(String str) =>
    List<GetUserGenreModel>.from(
        json.decode(str).map((x) => GetUserGenreModel.fromJson(x)));

String createUserToJson(List<GetUserGenreModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetUserGenreModel {
  final int? genreId;
  final String? name;

  GetUserGenreModel({
    this.genreId,
    this.name,
  });

  GetUserGenreModel copyWith({
    int? genreId,
    String? name,
  }) =>
      GetUserGenreModel(
        genreId: genreId ?? this.genreId,
        name: name ?? this.name,
      );

  factory GetUserGenreModel.fromJson(Map<String, dynamic> json) =>
      GetUserGenreModel(
        genreId: json["genre_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "genre_id": genreId,
        "name": name,
      };
}
