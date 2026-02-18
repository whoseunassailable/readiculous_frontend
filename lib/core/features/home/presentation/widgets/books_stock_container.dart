import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../generated/l10n.dart';
import '../../../../constants/routes.dart';
import '../../../../widgets/crayon_genre_chip.dart';
import '../../application/controllers/stock_controller.dart';
import '../../application/providers/home_providers.dart';
import 'fetch_book_data.dart';

class BooksStockContainer extends ConsumerWidget {
  final double height;
  final double width;
  final bool homePage;

  const BooksStockContainer({
    super.key,
    required this.height,
    required this.width,
    required this.homePage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredBookAsync = ref.watch(featuredBookProvider);

    return Container(
      height: homePage ? height * 0.42 : height * 0.5,
      width: width * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFB8743A), width: 5),
        image: const DecorationImage(
          image: AssetImage('assets/images/container_for_books.png'),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/icons/blue_book_icon.png",
                  height: height / 12,
                ),
                SizedBox(width: width / 40),
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
                    final inStock =
                        ref.watch(stockControllerProvider).contains(book.id);

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
                        SizedBox(
                          width: width / 6.5,
                          height: height / 20,
                          child: CrayonGenreChip(
                            label: homePage
                                ? (inStock
                                    ? S.of(context).alreadyInDb
                                    : S.of(context).add)
                                : (inStock
                                    ? S.of(context).inStock
                                    : S.of(context).add),
                            selected: inStock,
                            onTap: () {
                              // final controller =
                              //     ref.read(stockControllerProvider.notifier);
                              // if (inStock) {
                              //   controller.removeBook(book);
                              // } else {
                              //   controller.addBook(book);
                              // }
                              context.goNamed(RouteNames.viewBookDetailsPage);
                            },
                            color: inStock ? Colors.greenAccent : Colors.red,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const Divider(color: Colors.brown, thickness: 2),
            const Spacer(),
            // --- BOTTOM BUTTONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: width * 0.32,
                  height: height / 18,
                  child: CrayonGenreChip(
                    label:
                        homePage ? S.of(context).addBook : S.of(context).home,
                    selected: false,
                    onTap: () => homePage
                        ? context.pushNamed(RouteNames.addBook)
                        : context.goNamed(RouteNames.homePage),
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: width * 0.32,
                  height: height / 18,
                  child: CrayonGenreChip(
                    label: homePage
                        ? S.of(context).viewDatabase
                        : S.of(context).deleteBooks,
                    selected: false,
                    onTap: () => context.pushNamed(RouteNames.viewDatabase),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
