import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/core/utils/initials.dart';
import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final name = user?.name ?? 'User';
    final email = user?.email ?? user?.login ?? '—';
    final host = Uri.tryParse(AppConstants.baseUrl)?.host ?? AppConstants.baseUrl;

    final rows = [
      ('Email', email),
      ('Login', user?.login ?? '—'),
      ('Team', 'Inside Sales'),
      ('Database', host),
    ];

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: const Text('My Profile'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: AppTheme.navy,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initialsOf(name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.02,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Telecaller · Inside Sales',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textBody,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.elevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: Color(0xFFF2F4F7)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            rows[i].$1,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textBody,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            rows[i].$2,
                            textAlign: TextAlign.right,
                            style: AppTheme.mono(
                              fontSize: 12.5,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.lostBorder, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Log out',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
