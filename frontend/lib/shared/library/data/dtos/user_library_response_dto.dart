import 'library_dto.dart';

class UserLibraryResponseDto {
  /// Null when the user hasn't picked a library yet (`{"library": null}`).
  final LibraryDto? library;

  UserLibraryResponseDto({required this.library});

  factory UserLibraryResponseDto.fromJson(Map<String, dynamic> json) {
    final library = json['library'];
    return UserLibraryResponseDto(
      library: library == null
          ? null
          : LibraryDto.fromJson(library as Map<String, dynamic>),
    );
  }
}
