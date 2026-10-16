class LostReason {
  const LostReason({required this.id, required this.name});

  final int id;
  final String name;
}

class LostReasonPage {
  const LostReasonPage({required this.records, required this.total});

  final List<LostReason> records;
  final int total;
}
