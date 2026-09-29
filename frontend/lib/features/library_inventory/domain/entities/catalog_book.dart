/// A book from the catalog, as offered when adding one to the library.
class CatalogBook {
  final int bookId;
  final String title;
  final String? author;

  const CatalogBook({
    required this.bookId,
    required this.title,
    this.author,
  });
}
