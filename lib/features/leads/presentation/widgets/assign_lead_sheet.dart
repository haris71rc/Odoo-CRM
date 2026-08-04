import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/widgets/empty_view.dart';
import 'package:odoocrm/core/widgets/error_view.dart';
import 'package:odoocrm/core/widgets/loading_view.dart';
import 'package:odoocrm/features/leads/presentation/providers/assign_lead_notifier.dart';
import 'package:odoocrm/features/users/domain/entities/user_entity.dart';
import 'package:odoocrm/features/users/presentation/providers/users_notifier.dart';

Future<void> showAssignLeadSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int leadId,
  int? currentAssigneeId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => AssignLeadSheet(
      leadId: leadId,
      currentAssigneeId: currentAssigneeId,
    ),
  );
}

class AssignLeadSheet extends HookConsumerWidget {
  const AssignLeadSheet({
    super.key,
    required this.leadId,
    this.currentAssigneeId,
  });

  final int leadId;
  final int? currentAssigneeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersNotifierProvider);
    final assignAsync = ref.watch(assignLeadNotifierProvider(leadId));
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final isAssigning = assignAsync.isLoading;

    useEffect(() {
      void listener() => searchQuery.value = searchController.text;
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final height = MediaQuery.sizeOf(context).height * 0.75;

    Future<void> onUserTap(UserEntity user) async {
      if (isAssigning) return;
      if (user.id == currentAssigneeId) {
        Navigator.pop(context);
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Assign Lead'),
            content: Text('Assign lead to\n${user.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Assign'),
              ),
            ],
          );
        },
      );

      if (confirmed != true || !context.mounted) return;

      final error = await ref
          .read(assignLeadNotifierProvider(leadId).notifier)
          .assign(userId: user.id);

      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'Lead assigned successfully.',
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Assign Lead',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search users by name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: usersAsync.when(
                loading: () => const LoadingView(message: 'Loading users...'),
                error: (error, _) => ErrorView(
                  message:
                      error is Failure ? error.message : error.toString(),
                  onRetry: () =>
                      ref.read(usersNotifierProvider.notifier).refresh(),
                ),
                data: (users) {
                  final query = searchQuery.value.trim().toLowerCase();
                  final filtered = query.isEmpty
                      ? users
                      : users
                          .where(
                            (user) =>
                                user.name.toLowerCase().contains(query),
                          )
                          .toList();

                  if (filtered.isEmpty) {
                    return const EmptyView(
                      message: 'No users found',
                      icon: Icons.person_search_outlined,
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = filtered[index];
                      final isSelected = user.id == currentAssigneeId;
                      return _UserTile(
                        user: user,
                        isSelected: isSelected,
                        enabled: !isAssigning,
                        onTap: () => onUserTap(user),
                      );
                    },
                  );
                },
              ),
            ),
            if (isAssigning)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final UserEntity user;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = user.name.trim().isNotEmpty
        ? user.name.trim().substring(0, 1).toUpperCase()
        : '?';

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
          : Colors.transparent,
      child: ListTile(
        enabled: enabled,
        onTap: onTap,
        leading: _UserAvatar(user: user, initials: initials),
        title: Text(
          user.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          user.email ?? user.login ?? '—',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : null,
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user, required this.initials});

  final UserEntity user;
  final String initials;

  ImageProvider? _imageProvider() {
    final raw = user.imageBase64;
    if (raw == null || raw.isEmpty || raw == 'false') return null;

    try {
      final cleaned = raw.contains(',') ? raw.split(',').last : raw;
      final bytes = base64Decode(cleaned);
      if (bytes.isEmpty) return null;
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = _imageProvider();

    if (image != null) {
      return CircleAvatar(backgroundImage: image);
    }

    return CircleAvatar(
      backgroundColor: theme.colorScheme.secondaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
