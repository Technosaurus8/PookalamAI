import 'package:flutter/material.dart';
import '../constants/brush_sizes.dart';
import '../theme/app_theme.dart';

class BrushSizeRow extends StatelessWidget {
  final double selectedWidth;
  final ValueChanged<double> onWidthSelected;

  const BrushSizeRow({
    super.key,
    required this.selectedWidth,
    required this.onWidthSelected,
  });

  Widget _sizeButton(double size, String label) {
    final isSelected = selectedWidth == size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () => onWidthSelected(size),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.gold
                : AppColors.cream.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.gold
                  : AppColors.cream.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size.clamp(6, 18),
                height: size.clamp(6, 18),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.green : AppColors.cream,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: AppText.body(
                  size: 12,
                  weight: FontWeight.w600,
                  color: isSelected ? AppColors.green : AppColors.cream,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _sizeButton(brushThin, 'Thin'),
            _sizeButton(brushMedium, 'Medium'),
            _sizeButton(brushThick, 'Thick'),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.circle,
              size: 6,
              color: AppColors.cream.withOpacity(0.6),
            ),
            Expanded(
              child: SliderTheme(
                data: AppDecor.sliderTheme,
                child: Slider(
                  min: 1.0,
                  max: 24.0,
                  value: selectedWidth.clamp(1.0, 24.0),
                  onChanged: onWidthSelected,
                ),
              ),
            ),
            Icon(
              Icons.circle,
              size: 18,
              color: AppColors.cream.withOpacity(0.6),
            ),
          ],
        ),
      ],
    );
  }
}
