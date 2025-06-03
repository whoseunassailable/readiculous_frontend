class GetAllUserPreferences {
  final List<UserPreference>? userPreferences;
  final int? topMGenres;
  final int? topNBooks;

  GetAllUserPreferences({
    this.userPreferences,
    this.topMGenres,
    this.topNBooks,
  });

  factory GetAllUserPreferences.fromJson(Map<String, dynamic> json) {
    return GetAllUserPreferences(
      userPreferences: (json['user_preferences'] as List<dynamic>?)
          ?.map((e) => UserPreference.fromJson(e as Map<String, dynamic>))
          .toList(),
      topMGenres: json['top_m_genres'] as int?,
      topNBooks: json['top_n_books'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_preferences': userPreferences?.map((e) => e.toJson()).toList(),
        'top_m_genres': topMGenres,
        'top_n_books': topNBooks,
      };

  GetAllUserPreferences copyWith({
    List<UserPreference>? userPreferences,
    int? topMGenres,
    int? topNBooks,
  }) =>
      GetAllUserPreferences(
        userPreferences: userPreferences ?? this.userPreferences,
        topMGenres: topMGenres ?? this.topMGenres,
        topNBooks: topNBooks ?? this.topNBooks,
      );
}

class UserPreference {
  final String? userId;
  final String? genres;

  UserPreference({
    this.userId,
    this.genres,
  });

  factory UserPreference.fromJson(Map<String, dynamic> json) {
    return UserPreference(
      userId: json['user_id'] as String?,
      genres: json['genres'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'genres': genres,
      };

  UserPreference copyWith({
    String? userId,
    String? genres,
  }) =>
      UserPreference(
        userId: userId ?? this.userId,
        genres: genres ?? this.genres,
      );
}
