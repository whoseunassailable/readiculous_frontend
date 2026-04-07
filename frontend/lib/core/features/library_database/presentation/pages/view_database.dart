import 'package:flutter/material.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/books_stock_container.dart';
import 'package:readiculous_frontend/core/features/library_database/presentation/widgets/genre_dropdown.dart';
import 'package:readiculous_frontend/core/features/library_database/presentation/widgets/header_book_database.dart';
import '../../../../../generated/l10n.dart';
import '../../../../constants/app_font_size.dart';
import '../widgets/search_anchor_widget.dart';

class ViewDatabase extends StatefulWidget {
  const ViewDatabase({super.key});

  @override
  State<ViewDatabase> createState() => _ViewDatabaseState();
}

class _ViewDatabaseState extends State<ViewDatabase> {
  static const List<String> _genres = <String>[
    'All Genres',
    'Fantasy',
    'Mystery',
    'Sci-Fi',
    'Historical',
    'Romance',
  ];

  late String _genre = _genres.first;

  final SearchController _searchController = SearchController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_page.png'),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height / 20),
            HeaderBookDatabase(title: S.of(context).libraryDatabase),
            SizedBox(height: height / 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  GenreDropdown(
                    width: width,
                    height: height,
                    genres: _genres,
                    value: _genre,
                    onChanged: (v) {
                      setState(() => _genre = v ?? _genres.first);
                    },
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SearchAnchorWidget(
                      searchController: _searchController,
                      height: height,
                      width: width,
                      selectedGenre: _genre,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height / 40),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: height / 30),
                  child: Text(
                    S.of(context).browseTheListOfBooksCurrentlyInYourDatabase,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: width * AppFontSize.l,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height / 40),
            BooksStockContainer(
              height: height,
              width: width,
              homePage: false,
            ),
          ],
        ),
      ),
    );
  }
}
