import 'package:flutter/material.dart';
import 'package:odoocrm/features/chatter/domain/entities/tracking_value_entity.dart';

class ChatterTrackingValues extends StatelessWidget {
  const ChatterTrackingValues({
    super.key,
    required this.values,
  });

  final List<TrackingValueEntity> values;

  static const Color _newValueColor = Color(0xFF008784);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: values.map((value) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _TrackingLine(value: value, theme: theme),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TrackingLine extends StatelessWidget {
  const _TrackingLine({
    required this.value,
    required this.theme,
  });

  final TrackingValueEntity value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final oldValue = value.oldValue?.trim();
    final newValue = value.newValue?.trim();
    final fieldLabel = value.changedField.trim();
    final showArrow = oldValue != null &&
        oldValue.isNotEmpty &&
        newValue != null &&
        newValue.isNotEmpty &&
        oldValue != newValue;

    final baseStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.45);
    final newStyle = baseStyle?.copyWith(
      color: ChatterTrackingValues._newValueColor,
      fontWeight: FontWeight.w600,
    );
    final mutedStyle = baseStyle?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 2,
      children: [
        if (oldValue != null && oldValue.isNotEmpty)
          Text(oldValue, style: baseStyle),
        if (showArrow)
          Icon(
            Icons.arrow_forward,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        if (newValue != null && newValue.isNotEmpty)
          Text(newValue, style: newStyle),
        if (fieldLabel.isNotEmpty)
          Text(
            '($fieldLabel)',
            style: mutedStyle,
          ),
      ],
    );
  }
}
