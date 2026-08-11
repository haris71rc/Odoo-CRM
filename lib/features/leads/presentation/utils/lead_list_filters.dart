import 'package:odoocrm/features/leads/domain/entities/lead_entity.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';
import 'package:odoocrm/features/stages/domain/entities/stage_entity.dart';

/// Shared local filter helpers for the leads list and pipeline tab counts.
class LeadListFilters {
  LeadListFilters._();

  static bool isWon(String? name) {
    final n = name?.toLowerCase() ?? '';
    return n.contains('won');
  }

  static bool isLost(String? name) {
    final n = name?.toLowerCase() ?? '';
    return n == 'lost' || n.contains('closed lost') || n.endsWith(' lost');
  }

  static bool isFollowUp(String? name) {
    final n = name?.toLowerCase() ?? '';
    return n.contains('follow');
  }

  /// Initial CRM stage used by the Untouched filter.
  static bool isNewProspectStage(String? name) {
    final n = (name ?? '').toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    return n == 'new prospect' || n == 'new prospects';
  }

  /// DigiLawyer "Proposal" and Odoo default "Proposition" stages.
  static bool isProposalStage(String? name) {
    final n = (name ?? '').toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    return n == 'proposal' ||
        n == 'proposition' ||
        n.contains('proposal') ||
        n.contains('proposition');
  }

  /// Resolves New Prospect / New Prospects stage id from fetched stages.
  static int? findNewProspectStageId(Iterable<StageEntity> stages) {
    for (final stage in stages) {
      if (isNewProspectStage(stage.name)) return stage.id;
    }
    return null;
  }

  /// Resolves Proposal / Proposition stage id from fetched stages.
  static int? findProposalStageId(Iterable<StageEntity> stages) {
    for (final stage in stages) {
      final n = stage.name.toLowerCase().trim();
      if (n == 'proposal' || n == 'proposition') return stage.id;
    }
    for (final stage in stages) {
      if (isProposalStage(stage.name)) return stage.id;
    }
    return null;
  }

  static bool isHighPriority(LeadEntity lead) {
    final p = (lead.priority ?? '').trim();
    return p == '1';
  }

  static bool isCreatedToday(LeadEntity lead) {
    final d = lead.createdDate?.toLocal();
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  /// Applies pipeline tab + search on already server-filtered leads.
  ///
  /// Pass [pipelineOverride] when computing counts for a tab other than the
  /// currently selected one.
  static List<LeadEntity> apply({
    required List<LeadEntity> leads,
    required LeadFilterState filter,
    required int? currentUserId,
    LeadPipelineTab? pipelineOverride,
  }) {
    final tab = pipelineOverride ?? filter.pipelineTab;
    var filtered = List<LeadEntity>.from(leads);

    switch (tab) {
      case LeadPipelineTab.mine:
        if (currentUserId != null) {
          filtered = filtered
              .where((l) => l.assignedUser?.id == currentUserId)
              .toList();
        }
      case LeadPipelineTab.followup:
        filtered =
            filtered.where((l) => isFollowUp(l.stage?.name)).toList();
      case LeadPipelineTab.won:
        filtered = filtered.where((l) => isWon(l.stage?.name)).toList();
      case LeadPipelineTab.lost:
        filtered = filtered.where((l) => isLost(l.stage?.name)).toList();
      case LeadPipelineTab.all:
        break;
    }

    final query = filter.searchQuery.trim().toLowerCase().replaceAll(' ', '');
    if (query.isNotEmpty) {
      filtered = filtered.where((lead) {
        final hay = [
          lead.name,
          lead.partnerName,
          lead.phone,
        ].whereType<String>().join(' ').toLowerCase().replaceAll(' ', '');
        return hay.contains(query);
      }).toList();
    }

    return filtered;
  }
}
