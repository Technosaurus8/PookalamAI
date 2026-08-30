import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../constants/onam_palette.dart';
import '../theme/app_theme.dart';

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
        return AppDecor.themedDialog(
          title: Text('Pick a color', style: AppText.heading(size: 18)),
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
              child: Text(
                'Cancel',
                style: AppText.body(color: AppColors.green),
              ),
            ),
            ElevatedButton(
              style: AppDecor.primaryButton,
              onPressed: () {
                onColorSelected(tempColor);
                Navigator.of(ctx).pop();
              },
              child: Text('Select', style: AppText.button(size: 14)),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: isSelected ? 42 : 36,
        height: isSelected ? 42 : 36,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? AppColors.gold
                : AppColors.cream.withOpacity(0.35),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ]
              : null,
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
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cream.withOpacity(0.35)),
          ),
          child: IconButton(
            icon: const Icon(Icons.palette_outlined),
            color: AppColors.cream,
            tooltip: 'More colors',
            onPressed: () => _openFullPicker(context),
          ),
        ),
      ],
    );
  }
}
