import 'package:flutter_test/flutter_test.dart';
import 'package:odoocrm/core/utils/odoo_field_parser.dart';

void main() {
  group('OdooFieldParser', () {
    test('parses many2one tuple', () {
      final result = OdooFieldParser.asMany2One([12, 'John Doe']);
      expect(result?.id, 12);
      expect(result?.name, 'John Doe');
    });

    test('treats false as null', () {
      expect(OdooFieldParser.asString(false), isNull);
      expect(OdooFieldParser.asInt(false), isNull);
      expect(OdooFieldParser.asMany2One(false), isNull);
    });
  });
}
