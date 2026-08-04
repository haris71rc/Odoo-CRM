import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';

Future<void> showLeadSearchSheet({required BuildContext context}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    builder: (_) => const LeadSearchSheet(),
  );
}

class LeadSearchSheet extends HookConsumerWidget {
  const LeadSearchSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(leadFilterNotifierProvider);
    final controller = useTextEditingController(text: filter.searchQuery);
    final query = useState(filter.searchQuery);
    final leads = ref.watch(leadNotifierProvider).valueOrNull ?? const [];

    final suggestions = () {
      final q = query.value.trim().toLowerCase();
      if (q.isEmpty) return const <(String, String)>[];
      final out = <(String, String)>[];
      for (final lead in leads) {
        if (lead.name.toLowerCase().contains(q)) {
          out.add((lead.name, 'Name'));
        }
        if (lead.phone != null && lead.phone!.toLowerCase().contains(q)) {
          out.add((lead.phone!, 'Phone'));
        }
        if (lead.partnerName != null &&
            lead.partnerName!.toLowerCase().contains(q)) {
          out.add((lead.partnerName!, 'Contact'));
        }
        if (out.length >= 8) break;
      }
      return out;
    }();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.92,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                  Expanded(
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        onChanged: (v) => query.value = v,
                        onSubmitted: (v) {
                          ref
                              .read(leadFilterNotifierProvider.notifier)
                              .setSearch(v.trim());
                          Navigator.pop(context);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Name, phone or email',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'NAME, PHONE OR EMAIL',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.1,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final item = suggestions[index];
                  return InkWell(
                    onTap: () {
                      ref
                          .read(leadFilterNotifierProvider.notifier)
                          .setSearch(item.$1);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFF2F4F7)),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            size: 15,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.$1,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            item.$2,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
