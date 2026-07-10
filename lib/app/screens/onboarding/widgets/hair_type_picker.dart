import 'package:flutter/material.dart';
import '../../../../core/entities/hair_type.dart';

class HairTypePicker extends StatelessWidget {
  const HairTypePicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final HairType? selected;
  final ValueChanged<HairType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: HairType.values.map((type) {
        final isSelected = type == selected;
        return ChoiceChip(
          label: Text(type.label),
          selected: isSelected,
          onSelected: (_) => onChanged(type),
        );
      }).toList(),
    );
  }
}
