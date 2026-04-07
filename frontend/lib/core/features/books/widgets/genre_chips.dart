import 'package:flutter/material.dart';

class GenreChips extends StatefulWidget {
  const GenreChips({
    super.key,
    required this.genres,
    this.initialSelected = const {},
    this.onChanged,
    this.onAddGenre,
  });

  final List<String> genres;
  final Set<String> initialSelected;
  final ValueChanged<Set<String>>? onChanged;
  final VoidCallback? onAddGenre;

  @override
  State<GenreChips> createState() => _GenreChipsState();
}

class _GenreChipsState extends State<GenreChips> {
  late final Set<String> _selected = {...widget.initialSelected};

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final h = size.height;
    final w = size.width;
    final base = h < w ? h : w;

    final m = _ChipMetrics(
      spacing: base / 35,
      runSpacing: base / 35,
      padH: base / 18,
      padV: base / 42,
      radius: base / 30,
      borderWidth: base / 260,
      shadowBlur: base / 70,
      shadowOffsetY: base / 220,
      iconSize: base / 34,
      gap: base / 80,
      fontSize: base / 28,
    );

    return Wrap(
      spacing: m.spacing,
      runSpacing: m.runSpacing,
      children: [
        for (final g in widget.genres)
          _GenreChip(
            metrics: m,
            label: g,
            selected: _selected.contains(g),
            onTap: () {
              setState(() {
                if (_selected.contains(g)) {
                  _selected.remove(g);
                } else {
                  _selected.add(g);
                }
              });
              widget.onChanged?.call({..._selected});
            },
          ),
        if (widget.onAddGenre != null)
          _GenreChip(
            metrics: m,
            label: 'Add Genre',
            selected: false,
            isAddChip: true,
            leading: Icon(Icons.add, size: m.iconSize),
            onTap: widget.onAddGenre!,
          ),
      ],
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({
    required this.metrics,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
    this.isAddChip = false,
  });

  final _ChipMetrics metrics;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;
  final bool isAddChip;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? const Color(0xFF6F8FA6) // muted blue (selected)
        : isAddChip
            ? const Color(0xFFEEDBCB) // warm tan (+ Add)
            : const Color(0xFFE7D7C7); // warm paper

    final fg = selected ? Colors.white : const Color(0xFF3A2E2A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(metrics.radius),
      child: Ink(
        padding: EdgeInsets.symmetric(
          horizontal: metrics.padH,
          vertical: metrics.padV,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(metrics.radius),
          border: Border.all(
            color: const Color(0xFF3A2E2A).withOpacity(0.55),
            width: metrics.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: metrics.shadowBlur,
              offset: Offset(0, metrics.shadowOffsetY),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              IconTheme(data: IconThemeData(color: fg), child: leading!),
              SizedBox(width: metrics.gap),
            ],
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: metrics.fontSize,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipMetrics {
  const _ChipMetrics({
    required this.spacing,
    required this.runSpacing,
    required this.padH,
    required this.padV,
    required this.radius,
    required this.borderWidth,
    required this.shadowBlur,
    required this.shadowOffsetY,
    required this.iconSize,
    required this.gap,
    required this.fontSize,
  });

  final double spacing;
  final double runSpacing;
  final double padH;
  final double padV;
  final double radius;
  final double borderWidth;
  final double shadowBlur;
  final double shadowOffsetY;
  final double iconSize;
  final double gap;
  final double fontSize;
}
