import 'package:flutter/material.dart';

import '../../../../widgets/genre_chip.dart';

class FetchBookData extends StatefulWidget {
  final double height;
  final double width;
  final String nameOfBook;
  final String bookAuthor;
  final String primaryGenre;

  const FetchBookData({
    super.key,
    required this.height,
    required this.width,
    required this.nameOfBook,
    required this.bookAuthor,
    required this.primaryGenre,
  });

  @override
  State<FetchBookData> createState() => _FetchBookDataState();
}

class _FetchBookDataState extends State<FetchBookData> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.nameOfBook,
          style: TextStyle(
              fontSize: widget.height / 50, fontWeight: FontWeight.w600),
        ),
        Text(
          widget.bookAuthor,
          style: TextStyle(fontSize: widget.height / 60),
        ),
        GenreChip(
          genreText: widget.primaryGenre,
          textColor: Colors.white,
          bgColor: Colors.black,
        ),
      ],
    );
  }
}
