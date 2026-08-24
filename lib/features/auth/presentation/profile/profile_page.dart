import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/providers/app_permissions_provider.dart';
import 'package:odoocrm/core/providers/tenant_notifier.dart';
import 'package:odoocrm/core/services/app_permission.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/core/utils/initials.dart';
import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(appPermissionsNotifierProvider.notifier).refresh();
    }
  }

  Future<void> _onPermissionToggled(
    AppPermissionStatus item,
    bool enabled,
  ) async {
    if (!item.supported) return;

    if (!enabled && item.granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Open system settings to turn this permission off.',
          ),
        ),
      );
    }

    await ref
        .read(appPermissionsNotifierProvider.notifier)
        .setEnabled(item.kind, enabled);

    if (!mounted) return;
    final statuses = ref.read(appPermissionsNotifierProvider).valueOrNull;
    final updated = statuses?.where((s) => s.kind == item.kind).firstOrNull;
    if (enabled && updated != null && !updated.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.permanentlyDenied
                ? 'Permission blocked. Enable ${item.kind.title} in Settings.'
                : '${item.kind.title} was not granted.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final permissionsAsync = ref.watch(appPermissionsNotifierProvider);
    final tenant = ref.watch(tenantNotifierProvider).valueOrNull;
    final name = user?.name ?? 'User';
    final email = user?.email ?? user?.login ?? '—';
    final host = tenant?.host ?? '—';

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
          const SizedBox(height: 20),
          const Text(
            'APP PERMISSIONS',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 0.12,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enable permissions denied during setup so calls and WhatsApp work correctly.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textBody,
                ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.elevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: permissionsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, _) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Unable to load permission status.',
                  style: TextStyle(color: AppTheme.textBody),
                ),
              ),
              data: (statuses) {
                final items =
                    statuses.where((status) => status.supported).toList();
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No managed permissions on this platform.',
                      style: TextStyle(color: AppTheme.textBody),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 1, color: Color(0xFFF2F4F7)),
                      _PermissionToggleRow(
                        status: items[i],
                        onChanged: (value) =>
                            _onPermissionToggled(items[i], value),
                      ),
                    ],
                  ],
                );
              },
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

class _PermissionToggleRow extends StatelessWidget {
  const _PermissionToggleRow({
    required this.status,
    required this.onChanged,
  });

  final AppPermissionStatus status;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      value: status.granted,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: AppTheme.navy,
      title: Text(
        status.kind.title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        status.permanentlyDenied && !status.granted
            ? '${status.kind.subtitle}\nBlocked — tap to open Settings'
            : status.kind.subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textBody,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
