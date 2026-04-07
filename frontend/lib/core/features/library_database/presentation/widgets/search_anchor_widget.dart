import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../../../../generated/l10n.dart';
import '../../../home/domain/entities/book.dart';

class SearchAnchorWidget extends StatefulWidget {
  final SearchController searchController;
  final double height;
  final double width;
  final String selectedGenre;

  const SearchAnchorWidget({
    super.key,
    required this.searchController,
    required this.height,
    required this.width,
    required this.selectedGenre,
  });

  @override
  State<SearchAnchorWidget> createState() => _SearchAnchorWidgetState();
}

class _SearchAnchorWidgetState extends State<SearchAnchorWidget> {
  final _books = const <Book>[
    Book(
      id: '1',
      title: 'The Name of the Wind',
      author: 'Patrick Rothfuss',
      primaryGenre: 'Fantasy',
    ),
    Book(
      id: '2',
      title: 'Gone Girl',
      author: 'Gillian Flynn',
      primaryGenre: 'Mystery',
    ),
    Book(
      id: '3',
      title: 'Project Hail Mary',
      author: 'Andy Weir',
      primaryGenre: 'Sci-Fi',
    ),
    Book(
      id: '4',
      title: 'The Book Thief',
      author: 'Markus Zusak',
      primaryGenre: 'Historical',
    ),
    Book(
      id: '5',
      title: 'The Notebook',
      author: 'Nicholas Sparks',
      primaryGenre: 'Romance',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.brown.withOpacity(0.35);
    final radius = BorderRadius.circular(14);

    return SearchAnchor(
      searchController: widget.searchController,
      isFullScreen: true,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 3.0),
            borderRadius: radius,
          ),
          child: Row(
            children: [
              // Text field
              SizedBox(
                height: widget.height / 18.5,
                width: widget.width / 3,
                child: SearchBar(
                  controller: controller,
                  hintText: 'Search books...',
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor:
                      const WidgetStatePropertyAll(Colors.transparent),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onTap: controller.openView,
                  onChanged: (_) => controller.openView(),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: radius),
                  ),
                  leading: const SizedBox.shrink(),
                ),
              ),

              // Search button
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  width: 44,
                  height: widget.height / 22,
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 3.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(MaterialCommunityIcons.search_web),
                    onPressed: controller.openView,
                    tooltip: S.of(context).search,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      suggestionsBuilder: (context, controller) {
        final q = controller.text.trim().toLowerCase();

        final results = _books.where((b) {
          final matchesText = q.isEmpty ||
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q);

          final matchesGenre = widget.selectedGenre == 'All Genres' ||
              b.primaryGenre == widget.selectedGenre;

          return matchesText && matchesGenre;
        }).toList();

        return results.map(
          (b) {
            return ListTile(
              leading: const Icon(Icons.book_outlined),
              title: Text(b.title),
              subtitle: Text('${b.author} • ${b.primaryGenre}'),
              onTap: () => controller.closeView(b.title),
            );
          },
        );
      },
    );
  }
}
