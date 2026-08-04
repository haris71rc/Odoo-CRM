import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/features/chatter/presentation/providers/chatter_notifier.dart';

Future<void> showLogNoteSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int leadId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _LogNoteSheet(leadId: leadId),
  );
}

class _LogNoteSheet extends HookConsumerWidget {
  const _LogNoteSheet({required this.leadId});

  final int leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final isSaving = useState(false);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    Future<void> save() async {
      final note = controller.text.trim();
      if (note.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a note')),
        );
        return;
      }

      isSaving.value = true;
      final error = await ref
          .read(chatterNotifierProvider(leadId).notifier)
          .logNote(note);
      isSaving.value = false;

      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Note logged successfully')),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Log Note',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 5,
            minLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write an internal note...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      isSaving.value ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: isSaving.value ? null : save,
                  child: isSaving.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
