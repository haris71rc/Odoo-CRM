import 'package:flutter/material.dart';
import 'package:odoocrm/core/utils/date_formatters.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_entity.dart';

class LeadCard extends StatelessWidget {
  const LeadCard({
    super.key,
    required this.lead,
    required this.onTap,
  });

  final LeadEntity lead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lead.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (lead.stage != null)
                    Chip(
                      label: Text(lead.stage!.name),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
              if (lead.partnerName != null && lead.partnerName!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  lead.partnerName!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (lead.phone != null)
                    _Meta(
                      icon: Icons.phone_outlined,
                      label: lead.phone!,
                    ),
                  if (lead.assignedUser != null)
                    _Meta(
                      icon: Icons.person_outline,
                      label: lead.assignedUser!.name,
                      bold: true,
                    ),
                  _Meta(
                    icon: Icons.calendar_today_outlined,
                    label: DateFormatters.formatDate(lead.createdDate),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({
    required this.icon,
    required this.label,
    this.bold = false,
  });

  final IconData icon;
  final String label;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.outline),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
