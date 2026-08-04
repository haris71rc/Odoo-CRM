import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/widgets/loading_view.dart';
import 'package:odoocrm/features/activities/domain/entities/activity_type_entity.dart';
import 'package:odoocrm/features/activities/presentation/providers/activity_notifier.dart';
import 'package:odoocrm/features/auth/domain/entities/user_entity.dart' as auth;
import 'package:odoocrm/features/users/domain/entities/user_entity.dart';
import 'package:odoocrm/features/users/presentation/providers/users_notifier.dart';

/// Result returned when the user schedules an activity.
class ScheduleActivityResult {
  const ScheduleActivityResult({
    required this.activityTypeId,
    required this.summary,
    required this.note,
    required this.dueDate,
    required this.userId,
  });

  final int activityTypeId;
  final String summary;
  final String? note;
  final DateTime dueDate;
  final int userId;
}

Future<ScheduleActivityResult?> showScheduleActivityDialog({
  required BuildContext context,
  required WidgetRef ref,
  required auth.UserEntity currentUser,
}) {
  return showDialog<ScheduleActivityResult>(
    context: context,
    builder: (_) => ScheduleActivityDialog(currentUser: currentUser),
  );
}

class ScheduleActivityDialog extends HookConsumerWidget {
  const ScheduleActivityDialog({super.key, required this.currentUser});

  final auth.UserEntity currentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(activityTypesNotifierProvider);
    final usersAsync = ref.watch(usersNotifierProvider);
    final summaryController = useTextEditingController();
    final noteController = useTextEditingController();
    final selectedTypeId = useState<int?>(null);
    final selectedUserId = useState<int?>(currentUser.id);
    final dueDate = useState<DateTime>(
      DateTime.now().add(const Duration(days: 1)),
    );
    final dateFormat = DateFormat('dd MMM yyyy');

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: dueDate.value,
        firstDate: DateTime.now().subtract(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      );
      if (picked != null) {
        dueDate.value = picked;
      }
    }

    final isLoading = typesAsync.isLoading || usersAsync.isLoading;
    final typeError = typesAsync.asError?.error;
    final userError = usersAsync.asError?.error;

    Widget buildForm({
      required List<ActivityTypeEntity> types,
      required List<UserEntity> users,
    }) {
      if (types.isEmpty) {
        return const Text('No activity types available');
      }
      if (users.isEmpty) {
        return const Text('No users available');
      }

      final effectiveTypeId = selectedTypeId.value ?? types.first.id;
      final selectedType = types.firstWhere(
        (type) => type.id == effectiveTypeId,
        orElse: () => types.first,
      );

      final effectiveUserId = selectedUserId.value ??
          (users.any((u) => u.id == currentUser.id)
              ? currentUser.id
              : users.first.id);
      final selectedUser = users.firstWhere(
        (user) => user.id == effectiveUserId,
        orElse: () => users.first,
      );

      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              // ignore: deprecated_member_use
              value: selectedType.id,
              isExpanded: true,
              menuMaxHeight: 240,
              decoration: const InputDecoration(
                labelText: 'Activity Type',
              ),
              items: types
                  .map(
                    (type) => DropdownMenuItem<int>(
                      value: type.id,
                      child: Text(
                        type.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedTypeId.value = value;
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: summaryController,
              decoration: const InputDecoration(
                labelText: 'Summary',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: pickDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                'Due Date: ${dateFormat.format(dueDate.value)}',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              // ignore: deprecated_member_use
              value: selectedUser.id,
              isExpanded: true,
              menuMaxHeight: 240,
              decoration: const InputDecoration(
                labelText: 'Assigned To',
              ),
              items: users
                  .map(
                    (user) => DropdownMenuItem<int>(
                      value: user.id,
                      child: Text(
                        user.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedUserId.value = value;
                }
              },
            ),
          ],
        ),
      );
    }

    return AlertDialog(
      title: const Text('Schedule Activity'),
      content: SizedBox(
        width: double.maxFinite,
        child: isLoading
            ? const SizedBox(
                height: 120,
                child: LoadingView(message: 'Loading...'),
              )
            : typeError != null
                ? Text(
                    typeError is Failure
                        ? typeError.message
                        : typeError.toString(),
                  )
                : userError != null
                    ? Text(
                        userError is Failure
                            ? userError.message
                            : userError.toString(),
                      )
                    : buildForm(
                        types: typesAsync.valueOrNull ?? const [],
                        users: usersAsync.valueOrNull ?? const [],
                      ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final types = typesAsync.valueOrNull;
            final users = usersAsync.valueOrNull;
            if (types == null || types.isEmpty) return;
            if (users == null || users.isEmpty) return;

            final typeId = selectedTypeId.value ?? types.first.id;
            final userId = selectedUserId.value ??
                (users.any((u) => u.id == currentUser.id)
                    ? currentUser.id
                    : users.first.id);
            final summary = summaryController.text.trim();
            if (summary.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Summary is required')),
              );
              return;
            }

            Navigator.pop(
              context,
              ScheduleActivityResult(
                activityTypeId: typeId,
                summary: summary,
                note: noteController.text.trim().isEmpty
                    ? null
                    : noteController.text.trim(),
                dueDate: dueDate.value,
                userId: userId,
              ),
            );
          },
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}
