import 'package:flutter/material.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/core/theme/stage_colors.dart';
import 'package:odoocrm/core/utils/date_formatters.dart';
import 'package:odoocrm/core/widgets/app_card.dart';
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
    final stageName = lead.stage?.name;
    final accent = StageColors.forName(stageName);

    return AppCard(
      onTap: onTap,
      accentColor: accent,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  lead.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (stageName != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: StageColors.backgroundFor(stageName),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: accent.withValues(alpha: 0.45)),
                  ),
                  child: Text(
                    stageName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (lead.partnerName != null && lead.partnerName!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              lead.partnerName!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 14),
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
        Icon(
          icon,
          size: 15,
          color: bold ? AppTheme.secondary : AppTheme.textMuted,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: bold ? AppTheme.textPrimary : AppTheme.textMuted,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
