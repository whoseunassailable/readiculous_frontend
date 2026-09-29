// Request bodies for the recommendation endpoints.

class GenerateUserRecommendationsRequestDto {
  final int topN;
  const GenerateUserRecommendationsRequestDto({required this.topN});
  Map<String, dynamic> toJson() => {'top_n': topN};
}

class GenerateLibraryRecommendationsRequestDto {
  final int topNBooks;
  const GenerateLibraryRecommendationsRequestDto({required this.topNBooks});
  Map<String, dynamic> toJson() => {'top_n_books': topNBooks};
}

class UpdateRecommendationStateRequestDto {
  /// NEW | ORDERED | STOCKED | IGNORED
  final String state;

  /// With ORDERED: copies to add to the library's stock.
  final int? copies;

  const UpdateRecommendationStateRequestDto({required this.state, this.copies});
  Map<String, dynamic> toJson() =>
      {'state': state, if (copies != null) 'copies': copies};
}
