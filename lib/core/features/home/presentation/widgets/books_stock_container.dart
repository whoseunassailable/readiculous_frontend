import 'package:flutter/material.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/fetch_book_data.dart';
import '../../../../../generated/l10n.dart';
import '../../../../widgets/crayon_genre_chip.dart';

class BooksStockContainer extends StatefulWidget {
  final double height;
  final double width;
  const BooksStockContainer({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  State<BooksStockContainer> createState() => _BooksStockContainerState();
}

class _BooksStockContainerState extends State<BooksStockContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height * 0.42,
      width: widget.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFB8743A),
          width: 5,
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/container_for_books.png'),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "assets/icons/blue_book_icon.png",
              height: widget.height / 12,
            ),
            SizedBox(width: widget.width / 40),
            FetchBookData(
              height: widget.height,
              width: widget.width,
              nameOfBook: S.of(context).theNameOfTheWind,
              bookAuthor: S.of(context).patrickRothfus,
              primaryGenre: S.of(context).fantasy,
            ),
            SizedBox(width: widget.width / 40),
            SizedBox(
              width: widget.width / 6.5,
              height: widget.height / 20,
              child: CrayonGenreChip(
                label: 'Add',
                selected: false,
                onTap: () => {},
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
