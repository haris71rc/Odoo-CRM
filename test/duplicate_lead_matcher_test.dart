import 'package:flutter_test/flutter_test.dart';
import 'package:odoocrm/features/leads/domain/entities/duplicate_lead_candidate.dart';
import 'package:odoocrm/features/leads/domain/utils/duplicate_lead_matcher.dart';

void main() {
  DuplicateLeadCandidate lead({
    required int id,
    String? phone,
    String? mobile,
    DateTime? createdDate,
    DateTime? firstCallDate,
    int totalOutboundCalls = 0,
  }) {
    return DuplicateLeadCandidate(
      id: id,
      phone: phone,
      mobile: mobile,
      createdDate: createdDate,
      firstCallDate: firstCallDate,
      totalOutboundCalls: totalOutboundCalls,
    );
  }

  test('newer lead is duplicate when the older one was called', () {
    final ids = DuplicateLeadMatcher.duplicateIds([
      lead(
        id: 10,
        phone: '9876543210',
        createdDate: DateTime(2026, 1, 1),
        firstCallDate: DateTime(2026, 1, 2),
      ),
      lead(id: 11, phone: '9876543210', createdDate: DateTime(2026, 2, 1)),
    ]);

    expect(ids, {11});
  });

  test('matches +91 numbers with a local 10-digit number', () {
    final ids = DuplicateLeadMatcher.duplicateIds([
      lead(
        id: 1,
        phone: '+91 98765 43210',
        firstCallDate: DateTime(2026, 3, 1),
      ),
      lead(id: 2, phone: '9876543210'),
    ]);

    expect(ids, {2});
  });

  test('matches phone on one lead with mobile on the other', () {
    final ids = DuplicateLeadMatcher.duplicateIds([
      lead(id: 1, phone: '9876543210', totalOutboundCalls: 1),
      lead(id: 2, mobile: '+91-98765-43210'),
    ]);

    expect(ids, {2});
  });

  test('tags nothing when nobody has called the number', () {
    final ids = DuplicateLeadMatcher.duplicateIds([
      lead(id: 1, phone: '9876543210', createdDate: DateTime(2026, 1, 1)),
      lead(id: 2, phone: '9876543210', createdDate: DateTime(2026, 1, 2)),
    ]);

    expect(ids, isEmpty);
  });

  test('keeps the earliest called lead clear among three', () {
    final ids = DuplicateLeadMatcher.duplicateIds([
      lead(
        id: 1,
        phone: '9999999999',
        createdDate: DateTime(2026, 1, 1),
        firstCallDate: DateTime(2026, 1, 2),
      ),
      lead(
        id: 2,
        phone: '9999999999',
        createdDate: DateTime(2026, 1, 3),
        firstCallDate: DateTime(2026, 1, 4),
      ),
      lead(id: 3, phone: '9999999999', createdDate: DateTime(2026, 1, 5)),
    ]);

    expect(ids, {2, 3});
  });

  test('ignores leads with different numbers', () {
    final ids = DuplicateLeadMatcher.duplicateIds([
      lead(id: 1, phone: '9876543210', firstCallDate: DateTime(2026, 1, 2)),
      lead(id: 2, phone: '9123456780'),
    ]);

    expect(ids, isEmpty);
  });
}
