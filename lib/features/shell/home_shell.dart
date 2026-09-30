import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/providers/app_permissions_provider.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';
import 'package:odoocrm/features/call_log/presentation/providers/growth_call_log_providers.dart';
import 'package:odoocrm/features/call_log/presentation/providers/outbound_dial_sync_provider.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell>
    with WidgetsBindingObserver {
  Timer? _resumeSyncDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appPermissionsNotifierProvider.notifier).requestStartupIfNeeded();
      // Creates the outbound-dial observer so a call still syncs after the
      // process was backgrounded or killed, even from the lead list.
      ref.read(outboundDialSyncServiceProvider);
      _triggerInboundSync();
    });
  }

  @override
  void dispose() {
    _resumeSyncDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _resumeSyncDebounce?.cancel();
    _resumeSyncDebounce = Timer(const Duration(seconds: 2), _triggerInboundSync);
  }

  void _triggerInboundSync() {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;
    unawaited(
      ref.read(inboundCallSyncServiceProvider).syncIfNeeded(
            salesperson: user.name,
          ),
    );
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: const Border(
            top: BorderSide(color: AppTheme.border),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textPrimary.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                _NavItem(
                  label: 'Leads',
                  icon: Icons.view_list_rounded,
                  selected: widget.navigationShell.currentIndex == 0,
                  onTap: () => _onTap(0),
                ),
                _NavItem(
                  label: 'Analytics',
                  icon: Icons.bar_chart_rounded,
                  selected: widget.navigationShell.currentIndex == 1,
                  onTap: () => _onTap(1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 52,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 64,
                height: 32,
                decoration: BoxDecoration(
                  color: selected ? AppTheme.navyTint : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: selected ? AppTheme.navy : AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? AppTheme.navy : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
