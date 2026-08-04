import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders HTML content (e.g. Odoo HTML fields) with tappable links.
class HtmlContent extends StatelessWidget {
  const HtmlContent({
    super.key,
    required this.html,
    this.emptyPlaceholder = 'No description',
  });

  final String? html;
  final String emptyPlaceholder;

  bool get _hasContent => html != null && html!.trim().isNotEmpty;

  Future<void> _openLink(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) {
      return Text(
        emptyPlaceholder,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Html(
      data: html!,
      style: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(theme.textTheme.bodyMedium?.fontSize ?? 14),
          color: theme.colorScheme.onSurface,
          lineHeight: LineHeight.number(1.45),
        ),
        'p': Style(
          margin: Margins.only(bottom: 8),
        ),
        'a': Style(
          color: primary,
          textDecoration: TextDecoration.underline,
          textDecorationColor: primary,
        ),
        'b': Style(fontWeight: FontWeight.w700),
        'strong': Style(fontWeight: FontWeight.w700),
      },
      onLinkTap: (url, attributes, element) {
        _openLink(url);
      },
    );
  }
}
