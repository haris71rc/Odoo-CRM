import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/core/utils/date_formatters.dart';
import 'package:odoocrm/core/widgets/empty_view.dart';
import 'package:odoocrm/core/widgets/error_view.dart';
import 'package:odoocrm/core/widgets/loading_view.dart';
import 'package:odoocrm/core/widgets/section_header.dart';
import 'package:odoocrm/features/chatter/domain/entities/chatter_message_entity.dart';
import 'package:odoocrm/features/chatter/presentation/providers/chatter_notifier.dart';
import 'package:odoocrm/features/chatter/presentation/widgets/chatter_avatar.dart';
import 'package:odoocrm/features/chatter/presentation/widgets/chatter_message_body.dart';
import 'package:odoocrm/features/chatter/presentation/widgets/chatter_tracking_values.dart';
import 'package:odoocrm/features/chatter/presentation/widgets/log_note_sheet.dart';

class TimelineSection extends ConsumerWidget {
  const TimelineSection({super.key, required this.leadId});

  final int leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(chatterNotifierProvider(leadId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Timeline',
          trailing: TextButton.icon(
            onPressed: () => showLogNoteSheet(
              context: context,
              ref: ref,
              leadId: leadId,
            ),
            icon: const Icon(Icons.sticky_note_2_outlined, size: 18),
            label: const Text('Log Note'),
          ),
        ),
        const SizedBox(height: 8),
        messagesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LoadingView(),
          ),
          error: (error, _) => ErrorView(
            message: error is Failure ? error.message : error.toString(),
            onRetry: () =>
                ref.read(chatterNotifierProvider(leadId).notifier).refresh(),
          ),
          data: (messages) {
            if (messages.isEmpty) {
              return const EmptyView(
                message: 'No Timeline Available',
                icon: Icons.forum_outlined,
              );
            }
            return _TimelineList(messages: messages);
          },
        ),
      ],
    );
  }
}

class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.messages});

  final List<ChatterMessageEntity> messages;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    String? currentGroup;

    for (final message in messages) {
      final group = DateFormatters.formatChatterDateGroup(message.date);
      if (group != currentGroup) {
        currentGroup = group;
        items.add(_DateSeparator(label: group));
      }
      items.add(_TimelineMessage(message: message));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppTheme.border, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppTheme.border, height: 1)),
        ],
      ),
    );
  }
}

class _TimelineMessage extends StatelessWidget {
  const _TimelineMessage({required this.message});

  final ChatterMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authorName = message.authorName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChatterAvatar(
            name: authorName,
            partnerId: message.author?.id,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(
                      authorName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (message.isNote)
                      const Icon(
                        Icons.sticky_note_2_outlined,
                        size: 14,
                        color: Color(0xFFFBBF24),
                      ),
                    if (message.isDiscussion)
                      const Icon(
                        Icons.mail_outline,
                        size: 14,
                        color: Color(0xFF34D399),
                      ),
                    Text(
                      DateFormatters.formatChatterDateTime(message.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                if (message.subtypeDescription?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(
                    message.subtypeDescription!.trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (message.hasTracking) ...[
                  const SizedBox(height: 4),
                  ChatterTrackingValues(values: message.trackingValues),
                ],
                if (message.hasBody) ...[
                  const SizedBox(height: 4),
                  _MessageBody(message: message),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({required this.message});

  final ChatterMessageEntity message;

  Color? _backgroundFor() {
    if (message.isDiscussion) {
      return const Color(0xFF10241C);
    }
    if (message.isNote) {
      return const Color(0xFF2A2114);
    }
    return null;
  }

  Color? _borderFor() {
    if (message.isDiscussion) {
      return const Color(0xFF1F4D3A);
    }
    if (message.isNote) {
      return const Color(0xFF5C4420);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final background = _backgroundFor();
    final border = _borderFor();
    final content = ChatterMessageBody(html: message.body);

    if (background == null) {
      return content;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border ?? AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: content,
      ),
    );
  }
}
