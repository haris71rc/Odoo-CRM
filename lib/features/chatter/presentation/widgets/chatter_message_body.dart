import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:odoocrm/core/widgets/html_content.dart';

/// Odoo-style HTML rendering for chatter / timeline messages.
class ChatterMessageBody extends StatelessWidget {
  const ChatterMessageBody({
    super.key,
    required this.html,
  });

  final String? html;

  static const Color _trackingNewValueColor = Color(0xFF2DD4BF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HtmlContent(
      html: html,
      emptyPlaceholder: '',
      styleOverrides: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(theme.textTheme.bodyMedium?.fontSize ?? 14),
          color: theme.colorScheme.onSurface,
          lineHeight: LineHeight.number(1.45),
        ),
        'p': Style(
          margin: Margins.only(bottom: 6),
        ),
        'ul': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.only(left: 16),
        ),
        'li': Style(
          margin: Margins.only(bottom: 4),
        ),
        'a': Style(
          color: _trackingNewValueColor,
          textDecoration: TextDecoration.underline,
          textDecorationColor: _trackingNewValueColor,
        ),
        '.o_Message_trackingValueNewValue': Style(
          color: _trackingNewValueColor,
          fontWeight: FontWeight.w600,
        ),
        '.o-mail-Message-trackingNewValue': Style(
          color: _trackingNewValueColor,
          fontWeight: FontWeight.w600,
        ),
      },
    );
  }
}
