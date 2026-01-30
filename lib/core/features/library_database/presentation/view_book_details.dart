import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:readiculous_frontend/core/constants/routes.dart';
import 'package:readiculous_frontend/core/widgets/crayon_genre_chip.dart';

import '../../../../generated/l10n.dart';
import '../../home/application/controllers/stock_controller.dart';
import '../../home/application/providers/home_providers.dart';
import '../../home/presentation/widgets/fetch_book_data.dart';

class ViewBookDetails extends ConsumerWidget {
  const ViewBookDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredBookAsync = ref.watch(featuredBookProvider);

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_page.png'),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: height / 10),
            Container(
              height: height * 0.1,
              width: width * 0.8,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/book_details_header.png'),
                  fit: BoxFit.contain, // or BoxFit.fitWidth
                ),
              ),
              child: Text(
                S.of(context).bookDetails,
                style: TextStyle(
                  fontSize: height / 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: height / 15),
            Container(
              height: height * 0.5,
              width: width * 0.85,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_for_add_books.png'),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height / 40),
                  Row(
                    children: [
                      SizedBox(width: width / 15),
                      Icon(
                        MaterialCommunityIcons.book,
                        size: height / 8,
                      ), // Book
                      SizedBox(width: width / 60),
                      featuredBookAsync.when(
                        loading: () => SizedBox(
                          width: width * 0.45,
                          child: const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: LinearProgressIndicator(),
                          ),
                        ),
                        error: (e, st) => SizedBox(
                          width: width * 0.45,
                          child: Text('Failed: $e'),
                        ),
                        data: (book) {
                          final inStock = ref
                              .watch(stockControllerProvider)
                              .contains(book.id);
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FetchBookData(
                                height: height,
                                width: width,
                                primaryGenre: book.primaryGenre,
                                nameOfBook: book.title,
                                bookAuthor: book.author,
                              ),
                              SizedBox(width: width / 40),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: height / 20),
                    child: Text(S.of(context).whyItIsRecommended),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: height / 20),
                    child: const Divider(color: Colors.brown, thickness: 2),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: height / 20),
                    child: Text(S.of(context).bookDescription),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: height / 20),
                    child: const Divider(color: Colors.brown, thickness: 2),
                  ),
                  const Spacer(),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: width / 4),
                    padding: EdgeInsets.only(bottom: height / 30),
                    child: Center(
                      child: CrayonGenreChip(
                        label: S.of(context).viewDatabase,
                        selected: false,
                        onTap: () {},
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: width / 4),
                    padding: EdgeInsets.only(bottom: height / 30),
                    child: Center(
                      child: CrayonGenreChip(
                        label: S.of(context).close,
                        selected: false,
                        onTap: () => context.replaceNamed(RouteNames.homePage),
                        color: Colors.brown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
