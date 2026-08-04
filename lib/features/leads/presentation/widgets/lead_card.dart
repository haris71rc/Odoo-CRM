import 'package:flutter/material.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/core/theme/stage_colors.dart';
import 'package:odoocrm/core/utils/date_formatters.dart';
import 'package:odoocrm/core/utils/initials.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadCard extends StatelessWidget {
  const LeadCard({
    super.key,
    required this.lead,
    required this.onTap,
    this.onWon,
    this.onLost,
    this.isWon = false,
    this.isLost = false,
    this.hasFollowUp = false,
  });

  final LeadEntity lead;
  final VoidCallback onTap;
  final VoidCallback? onWon;
  final VoidCallback? onLost;
  final bool isWon;
  final bool isLost;
  final bool hasFollowUp;

  Future<void> _call(BuildContext context) async {
    final number = lead.phone;
    if (number == null || number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number available')),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: number);
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stageName = lead.stage?.name;
    final accent = StageColors.forName(stageName);
    final owner = lead.assignedUser?.name ?? 'Unassigned';
    final contact = lead.partnerName?.isNotEmpty == true
        ? lead.partnerName!
        : (lead.phone ?? '—');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.01,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$contact · ${lead.partnerName ?? '—'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textBody,
                            fontSize: 12.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (stageName != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: StageColors.backgroundFor(stageName),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        stageName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: owner == 'Unassigned'
                          ? const Color(0xFFF2F4F7)
                          : AppTheme.navyTint,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initialsOf(owner),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: owner == 'Unassigned'
                            ? AppTheme.textMuted
                            : AppTheme.navy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      owner,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: owner == 'Unassigned'
                            ? AppTheme.textMuted
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasFollowUp)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.followUpBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.followUpBorder),
                      ),
                      child: const Text(
                        'FOLLOW-UP',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.followUpFg,
                          letterSpacing: 0.02,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 11),
              const Divider(height: 1, color: Color(0xFFF2F4F7)),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (lead.phone != null) ...[
                          Text(
                            lead.phone!,
                            style: AppTheme.mono(
                              fontSize: 12.5,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          DateFormatters.formatDate(lead.createdDate)
                              .replaceAll(RegExp(r'\s+\d{4}$'), ''),
                          style: AppTheme.mono(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ActionChip(
                    label: 'Won',
                    active: isWon,
                    fg: AppTheme.wonFg,
                    bg: AppTheme.wonBg,
                    border: AppTheme.wonBorder,
                    onTap: onWon,
                  ),
                  const SizedBox(width: 7),
                  _ActionChip(
                    label: 'Lost',
                    active: isLost,
                    fg: AppTheme.lostFg,
                    bg: AppTheme.lostBg,
                    border: AppTheme.lostBorder,
                    onTap: onLost,
                  ),
                  const SizedBox(width: 7),
                  InkWell(
                    onTap: () => _call(context),
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: AppTheme.borderStrong),
                      ),
                      child: const Icon(
                        Icons.phone_outlined,
                        size: 18,
                        color: AppTheme.callGreen,
                      ),
                    ),
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

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.active,
    required this.fg,
    required this.bg,
    required this.border,
    this.onTap,
  });

  final String label;
  final bool active;
  final Color fg;
  final Color bg;
  final Color border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        constraints: const BoxConstraints(minWidth: 52, minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? bg : AppTheme.surface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: active ? border : const Color(0xFFD0D5DD),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.02,
            color: active ? fg : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
