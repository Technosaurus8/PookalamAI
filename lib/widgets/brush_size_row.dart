// lib/widgets/brush_size_row.dart
import 'package:flutter/material.dart';
import '../constants/brush_sizes.dart';

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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black87 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.black87,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
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
            const Icon(Icons.circle, size: 6, color: Colors.grey),
            Expanded(
              child: Slider(
                min: 1.0,
                max: 24.0,
                value: selectedWidth.clamp(1.0, 24.0),
                onChanged: onWidthSelected,
              ),
            ),
            const Icon(Icons.circle, size: 18, color: Colors.grey),
          ],
        ),
      ],
    );
  }
}
