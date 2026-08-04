import 'package:html/parser.dart' as html_parser;

/// Converts between Odoo HTML fields and plain text for editing.
class HtmlTextUtils {
  HtmlTextUtils._();

  /// Renders HTML as editable plain text (tags removed, breaks → newlines).
  /// Anchor tags become `label (url)` so links are not lost while editing.
  static String toPlainText(String? html) {
    if (html == null || html.trim().isEmpty) return '';

    var normalized = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</div\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</li\s*>', caseSensitive: false), '\n');

    normalized = normalized.replaceAllMapped(
      RegExp(
        r'''<a[^>]*href=["']([^"']+)["'][^>]*>(.*?)</a>''',
        caseSensitive: false,
        dotAll: true,
      ),
      (match) {
        final url = match.group(1) ?? '';
        final label =
            (html_parser.parseFragment(match.group(2) ?? '').text ?? '')
                .trim();
        if (label.isEmpty) return url;
        if (label == url) return url;
        return '$label ($url)';
      },
    );

    final document = html_parser.parse(normalized);
    final text = document.body?.text ?? normalized;
    return text
        .replaceAll('\u00A0', ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// Wraps plain text as simple HTML for Odoo `description` fields.
  /// Bare URLs are converted to clickable anchors.
  static String toHtml(String plainText) {
    final trimmed = plainText.trim();
    if (trimmed.isEmpty) return '';

    final escaped = trimmed
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');

    final withLinks = escaped.replaceAllMapped(
      RegExp(r'(https?:\/\/[^\s<>]+)'),
      (match) {
        final url = match.group(1)!;
        return '<a href="$url" target="_blank">$url</a>';
      },
    );

    final withBreaks = withLinks.replaceAll('\n', '<br>');
    return '<p>$withBreaks</p>';
  }

  static bool looksLikeHtml(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'<[^>]+>').hasMatch(value);
  }
}
