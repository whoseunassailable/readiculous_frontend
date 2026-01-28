import 'package:flutter/material.dart';
import '../../../../../generated/l10n.dart';
import '../../../../widgets/crayon_genre_chip.dart';
import '../../../../widgets/genre_chip.dart';

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
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).theNameOfTheWind,
                  style: TextStyle(
                      fontSize: widget.height / 50,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  S.of(context).patrickRothfus,
                  style: TextStyle(fontSize: widget.height / 60),
                ),
                const GenreChip(
                  genreText: 'Fantasy',
                  textColor: Colors.white,
                  bgColor: Colors.black,
                ),
              ],
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
