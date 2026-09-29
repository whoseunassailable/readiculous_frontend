import '../../domain/entities/library.dart';

class LibraryDto {
  final int libraryId;
  final String name;
  final String? location;
  final int? verified;

  const LibraryDto({
    required this.libraryId,
    required this.name,
    this.location,
    this.verified,
  });

  factory LibraryDto.fromJson(Map<String, dynamic> json) {
    return LibraryDto(
      libraryId: json['library_id'] as int,
      name: json['name'] as String,
      location: json['location'] as String?,
      verified: json['verified'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'library_id': libraryId,
        'name': name,
        'location': location,
        'verified': verified,
      };

  Library toEntity() => Library(
        libraryId: libraryId,
        name: name,
        location: location,
        verified: verified,
      );
}
