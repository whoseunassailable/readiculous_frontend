import 'package:flutter/cupertino.dart';

class HeaderBookDatabase extends StatelessWidget {
  final String title;
  const HeaderBookDatabase({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      height: height * 0.1,
      width: width * 0.8,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/book_details_header.png',
          ),
          fit: BoxFit.contain, // or BoxFit.fitWidth
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: height / 30,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
