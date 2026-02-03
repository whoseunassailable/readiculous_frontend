import 'package:flutter/material.dart';

class GenreDropdown extends StatelessWidget {
  final double width;
  final double height;
  final List<String> genres;
  final String value;
  final ValueChanged<String?> onChanged;

  const GenreDropdown({
    super.key,
    required this.height,
    required this.width,
    required this.genres,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.brown.withOpacity(0.35);

    return Container(
      width: width * 0.42,
      height: height / 17,
      padding: const EdgeInsets.symmetric(horizontal: 12), // ✅ not huge
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 3.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true, // ✅ fill the box
          icon: const Icon(Icons.keyboard_arrow_down),
          items: genres
              .map((g) => DropdownMenuItem<String>(
                    value: g,
                    child: Text(
                      g,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
