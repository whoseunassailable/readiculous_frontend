// To parse this JSON data, do
//
//     final createUser = createUserFromJson(jsonString);

import 'dart:convert';

CreateUserGenreModel createUserFromJson(String str) =>
    CreateUserGenreModel.fromJson(json.decode(str));

String createUserToJson(CreateUserGenreModel data) =>
    json.encode(data.toJson());

class CreateUserGenreModel {
  final String? userId;
  final List<int>? genreIds;

  CreateUserGenreModel({
    this.userId,
    this.genreIds,
  });

  CreateUserGenreModel copyWith({
    String? userId,
    List<int>? genreIds,
  }) =>
      CreateUserGenreModel(
        userId: userId ?? this.userId,
        genreIds: genreIds ?? this.genreIds,
      );

  factory CreateUserGenreModel.fromJson(Map<String, dynamic> json) =>
      CreateUserGenreModel(
        userId: json["user_id"],
        genreIds: json["genre_ids"] == null
            ? []
            : List<int>.from(json["genre_ids"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "genre_ids":
            genreIds == null ? [] : List<dynamic>.from(genreIds!.map((x) => x)),
      };
}
