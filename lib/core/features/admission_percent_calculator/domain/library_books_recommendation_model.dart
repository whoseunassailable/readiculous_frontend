// To parse this JSON data, do
//
//     final userGenrePreferenceModel = userGenrePreferenceModelFromJson(jsonString);

import 'dart:convert';

LibraryBooksRecommendationModel userGenrePreferenceModelFromJson(String str) =>
    LibraryBooksRecommendationModel.fromJson(json.decode(str));

String userGenrePreferenceModelToJson(LibraryBooksRecommendationModel data) =>
    json.encode(data.toJson());

class LibraryBooksRecommendationModel {
  final List<UserPreference>? userPreferences;
  final int? topMGenres;
  final int? topNBooks;

  LibraryBooksRecommendationModel({
    this.userPreferences,
    this.topMGenres,
    this.topNBooks,
  });

  LibraryBooksRecommendationModel copyWith({
    List<UserPreference>? userPreferences,
    int? topMGenres,
    int? topNBooks,
  }) =>
      LibraryBooksRecommendationModel(
        userPreferences: userPreferences ?? this.userPreferences,
        topMGenres: topMGenres ?? this.topMGenres,
        topNBooks: topNBooks ?? this.topNBooks,
      );

  factory LibraryBooksRecommendationModel.fromJson(Map<String, dynamic> json) =>
      LibraryBooksRecommendationModel(
        userPreferences: json["user_preferences"] == null
            ? []
            : List<UserPreference>.from(json["user_preferences"]!
                .map((x) => UserPreference.fromJson(x))),
        topMGenres: json["top_m_genres"],
        topNBooks: json["top_n_books"],
      );

  Map<String, dynamic> toJson() => {
        "user_preferences": userPreferences == null
            ? []
            : List<dynamic>.from(userPreferences!.map((x) => x.toJson())),
        "top_m_genres": topMGenres,
        "top_n_books": topNBooks,
      };
}

class UserPreference {
  final String? userId;
  final String? genres;

  UserPreference({
    this.userId,
    this.genres,
  });

  UserPreference copyWith({
    String? userId,
    String? genres,
  }) =>
      UserPreference(
        userId: userId ?? this.userId,
        genres: genres ?? this.genres,
      );

  factory UserPreference.fromJson(Map<String, dynamic> json) => UserPreference(
        userId: json["user_id"],
        genres: json["genres"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "genres": genres,
      };
}
