class AddUserGenresRequestDto {
  final String userId;
  final List<int> genreIds;

  const AddUserGenresRequestDto({required this.userId, required this.genreIds});

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'genre_ids': genreIds,
      };
}
