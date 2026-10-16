import 'package:flutter/material.dart';
import 'package:odoocrm/core/theme/app_theme.dart';

enum TopNoticeKind { info, success, error }

VoidCallback? _dismissActiveNotice;

/// A short message shown above page content, below the status bar.
void showTopNotice(
  BuildContext context,
  String message, {
  TopNoticeKind kind = TopNoticeKind.info,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final topInset = MediaQuery.viewPaddingOf(context).top;
  showTopNoticeInOverlay(overlay, topInset, message, kind: kind);
}

/// Use a captured overlay when the widget that started an async action closes.
void showTopNoticeInOverlay(
  OverlayState overlay,
  double topInset,
  String message, {
  TopNoticeKind kind = TopNoticeKind.info,
}) {
  _dismissActiveNotice?.call();
  final accent = kind == TopNoticeKind.error
      ? AppTheme.lostBorder
      : AppTheme.goldSoft;
  final icon = switch (kind) {
    TopNoticeKind.success => Icons.check_circle_rounded,
    TopNoticeKind.error => Icons.error_outline_rounded,
    TopNoticeKind.info => Icons.info_outline_rounded,
  };
  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => Positioned(
      top: topInset + 12,
      left: 16,
      right: 16,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        builder: (context, progress, child) => Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, -24 * (1 - progress)),
            child: child,
          ),
        ),
        child: Material(
          color: AppTheme.navy,
          elevation: 8,
          shadowColor: AppTheme.navy.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.55)),
            ),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 21),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  var dismissed = false;
  void dismiss() {
    if (dismissed) return;
    dismissed = true;
    if (entry.mounted) entry.remove();
    entry.dispose();
    if (identical(_dismissActiveNotice, dismiss)) {
      _dismissActiveNotice = null;
    }
  }

  overlay.insert(entry);
  _dismissActiveNotice = dismiss;
  Future<void>.delayed(const Duration(seconds: 3), dismiss);
}
