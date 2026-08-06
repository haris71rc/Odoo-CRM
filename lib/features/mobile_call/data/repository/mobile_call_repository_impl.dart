import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/chatter/domain/repository/chatter_repository.dart';
import 'package:odoocrm/features/mobile_call/data/mobile_call_log_note_builder.dart';
import 'package:odoocrm/features/mobile_call/data/parser/mobile_call_parser.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/latest_mobile_call_entity.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/stage_call_validation_data.dart';
import 'package:odoocrm/features/mobile_call/domain/repository/mobile_call_repository.dart';

class MobileCallRepositoryImpl implements MobileCallRepository {
  MobileCallRepositoryImpl({
    required ChatterRepository chatterRepository,
    MobileCallParser parser = const MobileCallParser(),
    MobileCallLogNoteBuilder noteBuilder = const MobileCallLogNoteBuilder(),
  })  : _chatterRepository = chatterRepository,
        _parser = parser,
        _noteBuilder = noteBuilder;

  final ChatterRepository _chatterRepository;
  final MobileCallParser _parser;
  final MobileCallLogNoteBuilder _noteBuilder;

  @override
  Future<Result<void>> createMobileCallLog({
    required int leadId,
    required LatestMobileCallEntity call,
  }) async {
    try {
      final body = _noteBuilder.build(call);
      final result = await _chatterRepository.logNote(
        leadId: leadId,
        body: body,
      );
      return result;
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<LatestMobileCallEntity?>> fetchLatestMobileCall(
    int leadId,
  ) async {
    final full = await fetchStageCallValidationData(leadId);
    return full.map((data) => data.latestCall);
  }

  @override
  Future<Result<StageCallValidationData>> fetchStageCallValidationData(
    int leadId,
  ) async {
    try {
      final result = await _chatterRepository.getMessagesForLead(leadId);
      return result.when(
        success: (messages) {
          final calls = _parser.parseAllFromMessages(messages);
          final followUp = _parser.findFollowUpEntry(messages);
          return Success(
            StageCallValidationData(
              latestCall: calls.isEmpty ? null : calls.first,
              mobileCalls: calls,
              followUpEnteredAt: followUp?.at,
              followUpEnteredMessageId: followUp?.messageId,
            ),
          );
        },
        failure: Error.new,
      );
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
