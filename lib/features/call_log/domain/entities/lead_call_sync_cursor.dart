/// Remembers which Android call rows were already applied for one lead.
class LeadCallSyncCursor {
  const LeadCallSyncCursor({
    this.keys = const {},
    this.seeded = false,
  });

  /// Fingerprints of device rows already applied.
  final Set<String> keys;

  /// True after the first successful catch-up, including a no-op.
  final bool seeded;

  static const empty = LeadCallSyncCursor();
}
