import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:readiculous_frontend/core/constants/routes.dart';
import 'package:readiculous_frontend/core/features/books/widgets/book_title_field.dart';
import 'package:readiculous_frontend/core/features/books/widgets/genre_chips.dart';
import 'package:readiculous_frontend/core/features/home/presentation/pages/home_page.dart';

import '../../../../generated/l10n.dart';
import '../../../constants/app_font_size.dart';
import '../../../widgets/crayon_genre_chip.dart';
import '../../library_database/presentation/widgets/header_book_database.dart';
import '../../services/auth_service.dart';

class AddBook extends StatefulWidget {
  const AddBook({super.key});

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  @override
  Widget build(BuildContext context) {
    final List<String> genres = [
      'Fantasy',
      'Mystery',
      'Sci-Fi',
      'Romance',
    ];

    Set<String> selectedGenres = {"Fantasy"};
    final genreColors = <String, Color>{
      "Fantasy": const Color(0xFFB7D8FF), // soft blue
      "Mystery": const Color(0xFFBFE3C0), // muted green
      "Sci-Fi": const Color(0xFFD7C6FF), // lavender
      "Romance": const Color(0xFFFFC7C2), // peach/pink
      "History": const Color(0xFFE8D2B0), // tan
    };

    final _titleController = TextEditingController();
    final _authorController = TextEditingController();

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_page.png'),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: height / 20),
            HeaderBookDatabase(title: S.of(context).addBook),
            SizedBox(height: height / 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: width * 0.9,
                  height: height * 0.55,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    border: Border.all(color: Colors.white70),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(24),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(height / 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border:
                          Border.all(color: const Color(0xFFB8743A), width: 5),
                      image: const DecorationImage(
                        image:
                            AssetImage('assets/images/container_for_books.png'),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        FormTextField(
                          controller: _titleController,
                          text: S.of(context).title,
                          fieldLabel: S.of(context).enterBookTitle,
                        ),
                        SizedBox(height: height / 90),
                        FormTextField(
                          controller: _authorController,
                          text: S.of(context).author,
                          fieldLabel: S.of(context).enterAuthorsName,
                        ),
                        SizedBox(height: height / 90),
                        Row(
                          children: [
                            Text(
                              S.of(context).genre,
                              style: TextStyle(
                                fontSize: height * AppFontSize.m,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Container(
                                height: height / 350, // line thickness
                                color: Colors.brown, // brown
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: height / 30),
                          child: CrayonGenreChipRow(
                            genres: genres,
                            selected: selectedGenres,
                            genreColors: genreColors,
                            onChanged: (next) =>
                                setState(() => selectedGenres = next),
                          ),
                        ),
                        Divider(thickness: height / 350, color: Colors.brown),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            customizedButton(
                              context: context,
                              text: S.of(context).save,
                              pageName: RouteNames.homePage,
                              width: width,
                              height: height,
                              color: Color(0xffC4B384),
                            ),
                            customizedButton(
                              context: context,
                              text: S.of(context).cancel,
                              pageName: RouteNames.homePage,
                              width: width,
                              height: height,
                              color: Color(0xff69573A),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  customizedButton(
      {required BuildContext context,
      required String text,
      required String pageName,
      required double width,
      required double height,
      required Color color}) {
    return SizedBox(
      width: width * 0.3,
      child: ElevatedButton(
        onPressed: () {
          final authService = AuthService();
          authService.clearStudentDetails();
          context.pushNamed(pageName);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(
            color: Colors.brown,
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: height * AppFontSize.xxs,
          ),
        ),
      ),
    );
  }
}
