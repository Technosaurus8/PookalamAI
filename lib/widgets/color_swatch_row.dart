// lib/widgets/color_swatch_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../constants/onam_palette.dart';

class ColorSwatchRow extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorSwatchRow({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  void _openFullPicker(BuildContext context) {
    Color tempColor = selectedColor;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (c) => tempColor = c,
              enableAlpha: false,
              labelTypes: const [],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onColorSelected(tempColor);
                Navigator.of(ctx).pop();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  Widget _swatch(Color color) {
    final isSelected = color.value == selectedColor.value;
    return GestureDetector(
      onTap: () => onColorSelected(color),
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade400,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...onamPalette.map(_swatch),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.palette_outlined),
          tooltip: 'More colors',
          onPressed: () => _openFullPicker(context),
        ),
      ],
    );
  }
}
