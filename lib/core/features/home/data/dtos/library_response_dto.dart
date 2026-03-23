import 'library_dto.dart';

class LibraryResponseDto {
  final LibraryDto library;

  LibraryResponseDto({required this.library});

  factory LibraryResponseDto.fromJson(Map<String, dynamic> json) {
    return LibraryResponseDto(
      library: LibraryDto.fromJson(json['library'] as Map<String, dynamic>),
    );
  }
}
