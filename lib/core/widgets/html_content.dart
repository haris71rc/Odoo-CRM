import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';

/// Renders HTML content (e.g. Odoo HTML fields) with tappable links.
class HtmlContent extends StatelessWidget {
  const HtmlContent({
    super.key,
    required this.html,
    this.emptyPlaceholder = 'No description',
    this.styleOverrides = const {},
  });

  final String? html;
  final String emptyPlaceholder;
  final Map<String, Style> styleOverrides;

  bool get _hasContent => html != null && html!.trim().isNotEmpty;

  /// Odoo sometimes stores escaped markup (`&lt;p&gt;...`). Decode once so
  /// flutter_html can render real tags instead of showing them as text.
  String _normalizeHtml(String raw) {
    final trimmed = raw.trim();
    if (!trimmed.contains('&lt;') && !trimmed.contains('&gt;')) {
      return trimmed;
    }

    final decoded = html_parser.parseFragment(trimmed).text ?? trimmed;
    // If decoding produced real HTML tags, use those; otherwise keep original.
    if (decoded.contains('<') && decoded.contains('>')) {
      return decoded;
    }
    return trimmed;
  }

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
    final data = _normalizeHtml(html!);

    return Html(
      data: data,
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
        ...styleOverrides,
      },
      onLinkTap: (url, attributes, element) {
        _openLink(url);
      },
    );
  }
}
