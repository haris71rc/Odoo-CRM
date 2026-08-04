import 'package:odoocrm/core/utils/html_text_utils.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_detail_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'internal_note_notifier.g.dart';

class InternalNoteState {
  const InternalNoteState({
    this.originalNote = '',
    this.currentNote = '',
    this.isEditing = false,
    this.isSaving = false,
  });

  final String originalNote;
  final String currentNote;
  final bool isEditing;
  final bool isSaving;

  bool get hasChanges => currentNote != originalNote;

  InternalNoteState copyWith({
    String? originalNote,
    String? currentNote,
    bool? isEditing,
    bool? isSaving,
  }) {
    return InternalNoteState(
      originalNote: originalNote ?? this.originalNote,
      currentNote: currentNote ?? this.currentNote,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

@riverpod
class InternalNoteNotifier extends _$InternalNoteNotifier {
  @override
  InternalNoteState build(int leadId) {
    ref.listen(leadDetailNotifierProvider(leadId), (previous, next) {
      next.whenData((lead) {
        if (state.isEditing || state.isSaving) return;
        final plain = HtmlTextUtils.toPlainText(lead.description);
        if (plain == state.originalNote && plain == state.currentNote) return;
        state = state.copyWith(originalNote: plain, currentNote: plain);
      });
    });

    final initial = HtmlTextUtils.toPlainText(
      ref.read(leadDetailNotifierProvider(leadId)).valueOrNull?.description,
    );
    return InternalNoteState(originalNote: initial, currentNote: initial);
  }

  void startEditing() {
    if (state.isSaving) return;
    state = state.copyWith(isEditing: true);
  }

  void updateNote(String value) {
    if (!state.isEditing || state.isSaving) return;
    state = state.copyWith(currentNote: value);
  }

  void cancel() {
    if (state.isSaving) return;
    state = state.copyWith(
      currentNote: state.originalNote,
      isEditing: false,
    );
  }

  /// Persists via existing [LeadDetailNotifier.updateRemark] → repository.
  /// Returns an error message on failure, otherwise `null`.
  Future<String?> save() async {
    if (state.isSaving || !state.isEditing) return null;

    state = state.copyWith(isSaving: true);
    final payload = HtmlTextUtils.toHtml(state.currentNote);
    final error = await ref
        .read(leadDetailNotifierProvider(leadId).notifier)
        .updateRemark(payload);

    if (error != null) {
      state = state.copyWith(isSaving: false);
      return error;
    }

    final saved = state.currentNote;
    state = InternalNoteState(
      originalNote: saved,
      currentNote: saved,
    );
    return null;
  }
}
