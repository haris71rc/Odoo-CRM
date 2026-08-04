String initialsOf(String? name) {
  final value = name?.trim() ?? '';
  if (value.isEmpty || value.toLowerCase() == 'unassigned') return '?';
  final parts = value.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final word = parts.first;
    return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
  }
  return ('${parts[0][0]}${parts[1][0]}').toUpperCase();
}
