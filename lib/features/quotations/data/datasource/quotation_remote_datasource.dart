import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/constants/app_environment.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/network/dio_client.dart';
import 'package:odoocrm/core/network/json_rpc_request.dart';
import 'package:odoocrm/core/storage/secure_storage_service.dart';
import 'package:odoocrm/features/quotations/data/dto/odoo_action_response.dart';
import 'package:odoocrm/features/quotations/data/dto/odoo_onchange_response.dart';
import 'package:odoocrm/features/quotations/data/dto/odoo_web_save_response.dart';
import 'package:odoocrm/features/quotations/data/quotation_value_normalizer.dart';
import 'package:odoocrm/features/quotations/domain/entities/quotation_result.dart';

/// Reproduces the Odoo website quotation initialization sequence:
/// 1. `crm.lead/action_sale_quotations_new`
/// 2. `sale.order/onchange`
/// 3. `sale.order/web_save`
class QuotationRemoteDatasource {
  QuotationRemoteDatasource({
    required DioClient dioClient,
    required SecureStorageService secureStorage,
    QuotationValueNormalizer normalizer = const QuotationValueNormalizer(),
  })  : _dioClient = dioClient,
        _secureStorage = secureStorage,
        _normalizer = normalizer;

  final DioClient _dioClient;
  final SecureStorageService _secureStorage;
  final QuotationValueNormalizer _normalizer;

  /// Minimal field specification for `sale.order` onchange / web_save.
  ///
  /// Kept inside the datasource so the UI never sees Odoo form specs.
  static const Map<String, dynamic> _saleOrderFieldSpec = {
    'display_name': {},
    'partner_id': {
      'fields': {
        'display_name': {},
      },
    },
    'partner_invoice_id': {
      'fields': {
        'display_name': {},
      },
    },
    'partner_shipping_id': {
      'fields': {
        'display_name': {},
      },
    },
    'pricelist_id': {
      'fields': {
        'display_name': {},
      },
    },
    'currency_id': {
      'fields': {
        'display_name': {},
      },
    },
    'payment_term_id': {
      'fields': {
        'display_name': {},
      },
    },
    'fiscal_position_id': {
      'fields': {
        'display_name': {},
      },
    },
    'company_id': {
      'fields': {
        'display_name': {},
      },
    },
    'user_id': {
      'fields': {
        'display_name': {},
      },
    },
    'team_id': {
      'fields': {
        'display_name': {},
      },
    },
    'opportunity_id': {
      'fields': {
        'display_name': {},
      },
    },
    'campaign_id': {
      'fields': {
        'display_name': {},
      },
    },
    'medium_id': {
      'fields': {
        'display_name': {},
      },
    },
    'source_id': {
      'fields': {
        'display_name': {},
      },
    },
    'origin': {},
    'tag_ids': {
      'fields': {
        'display_name': {},
      },
    },
    'date_order': {},
    'validity_date': {},
    'client_order_ref': {},
    'note': {},
    'warehouse_id': {
      'fields': {
        'display_name': {},
      },
    },
    'incoterm': {
      'fields': {
        'display_name': {},
      },
    },
    'require_signature': {},
    'require_payment': {},
    'order_line': {
      'fields': {
        'display_name': {},
        'product_id': {
          'fields': {
            'display_name': {},
          },
        },
        'product_uom_qty': {},
        'price_unit': {},
      },
      'limit': 40,
      'order': 'sequence, id',
    },
    'name': {},
    'state': {},
    'id': {},
  };

  static const Map<String, dynamic> _webSaveSpec = {
    'id': {},
    'name': {},
    'partner_id': {
      'fields': {
        'display_name': {},
      },
    },
    'opportunity_id': {
      'fields': {
        'display_name': {},
      },
    },
  };

  Future<QuotationResult> createQuotationForLead(int leadId) async {
    final uid = await _secureStorage.getUid();
    if (uid == null) {
      throw const AuthFailure('No authenticated user');
    }

    final existing = await findExistingQuotation(leadId);
    if (existing != null) {
      await moveLeadToProposalStage(leadId);
      return QuotationResult(
        quotationId: existing.quotationId,
        quotationNumber: existing.quotationNumber,
        alreadyExisted: true,
      );
    }

    final companyIds = AppEnvironment.allowedCompanyIds;

    // Step 1 — same button action as Odoo CRM website.
    final action = await actionSaleQuotationsNew(
      leadId: leadId,
      uid: uid,
      allowedCompanyIds: companyIds,
    );

    if (action.requiresPartner || !action.isNewQuotationAction) {
      throw const ApiFailure(
        'Set a customer on this lead before creating a quotation.',
      );
    }

    final requestContext = _buildQuotationContext(
      leadId: leadId,
      uid: uid,
      allowedCompanyIds: companyIds,
      actionContext: action.context,
    );

    // Step 2 — initialize sale.order values via onchange.
    final onchange = await onchangeSaleOrder(context: requestContext);
    final values = _normalizer.toWebSaveValues(
      onchange.value,
      actionContext: action.context,
    );

    if (values['partner_id'] == null) {
      throw const ApiFailure(
        'Set a customer on this lead before creating a quotation.',
      );
    }

    // Step 3 — persist the quotation.
    final saved = await webSaveSaleOrder(
      values: values,
      context: requestContext,
    );

    // Step 4 — move CRM lead to Proposal / Proposition.
    await moveLeadToProposalStage(leadId);

    return QuotationResult(
      quotationId: saved.quotationId,
      quotationNumber: saved.quotationNumber,
    );
  }

  /// Moves [leadId] to the Proposal/Proposition CRM stage.
  Future<void> moveLeadToProposalStage(int leadId) async {
    final proposalStageId = await findProposalStageId();
    if (proposalStageId == null) {
      throw const ApiFailure('Proposal stage not found');
    }

    final currentStageId = await _readLeadStageId(leadId);
    if (currentStageId == proposalStageId) return;

    final request = JsonRpcRequest.callKw(
      model: 'crm.lead',
      method: 'write',
      args: [
        [leadId],
        {'stage_id': proposalStageId},
      ],
    );

    await _dioClient.postJsonRpc(AppConstants.callKwPath, request);
  }

  /// Resolves DigiLawyer Proposal / Odoo Proposition stage id.
  Future<int?> findProposalStageId() async {
    final request = JsonRpcRequest.callKw(
      model: 'crm.stage',
      method: 'search_read',
      args: const [<List<dynamic>>[]],
      kwargs: const {
        'fields': ['id', 'name', 'sequence'],
        'order': 'sequence asc',
      },
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    final result = response['result'];
    if (result is! List) {
      throw const ParsingFailure('Unexpected stages response');
    }

    int? fallback;
    for (final item in result) {
      if (item is! Map) continue;
      final record = Map<String, dynamic>.from(item);
      final id = record['id'];
      final name = (record['name']?.toString() ?? '').toLowerCase().trim();
      if (id is! int || name.isEmpty) continue;

      if (name == 'proposal' || name == 'proposition') return id;
      if (fallback == null &&
          (name.contains('proposal') || name.contains('proposition'))) {
        fallback = id;
      }
    }
    return fallback;
  }

  Future<int?> _readLeadStageId(int leadId) async {
    final request = JsonRpcRequest.callKw(
      model: 'crm.lead',
      method: 'read',
      args: [
        [leadId],
        ['stage_id'],
      ],
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    final result = response['result'];
    if (result is! List || result.isEmpty) return null;

    final first = result.first;
    if (first is! Map) return null;

    final stageId = first['stage_id'];
    if (stageId is int) return stageId;
    if (stageId is List && stageId.isNotEmpty && stageId.first is int) {
      return stageId.first as int;
    }
    return null;
  }

  Future<QuotationResult?> findExistingQuotation(int leadId) async {
    final request = JsonRpcRequest.callKw(
      model: 'sale.order',
      method: 'search_read',
      args: [
        [
          ['opportunity_id', '=', leadId],
          ['state', 'in', ['draft', 'sent']],
        ],
      ],
      kwargs: const {
        'fields': ['id', 'name'],
        'limit': 1,
        'order': 'id desc',
      },
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    final result = response['result'];
    if (result is! List || result.isEmpty) return null;

    final first = result.first;
    if (first is! Map) return null;

    final record = Map<String, dynamic>.from(first);
    final id = record['id'];
    if (id is! int) return null;

    final name = record['name'];
    return QuotationResult(
      quotationId: id,
      quotationNumber: name is String && name.isNotEmpty ? name : null,
      alreadyExisted: true,
    );
  }

  Future<OdooActionResponse> actionSaleQuotationsNew({
    required int leadId,
    required int uid,
    required List<int> allowedCompanyIds,
  }) async {
    final context = <String, dynamic>{
      'default_type': 'opportunity',
      'lang': 'en_US',
      'tz': 'Asia/Kolkata',
      'uid': uid,
      if (allowedCompanyIds.isNotEmpty)
        'allowed_company_ids': allowedCompanyIds,
    };

    final request = JsonRpcRequest.callButton(
      model: 'crm.lead',
      method: 'action_sale_quotations_new',
      args: [
        [leadId],
      ],
      kwargs: {
        'context': context,
      },
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callButtonPath(
        'crm.lead',
        'action_sale_quotations_new',
      ),
      request,
    );

    final result = response['result'];
    if (result is! Map) {
      throw const ParsingFailure(
        'Unexpected action_sale_quotations_new response',
      );
    }

    return OdooActionResponse.fromJson(Map<String, dynamic>.from(result));
  }

  Future<OdooOnchangeResponse> onchangeSaleOrder({
    required Map<String, dynamic> context,
  }) async {
    final request = JsonRpcRequest.callKw(
      model: 'sale.order',
      method: 'onchange',
      args: [
        <int>[],
        <String, dynamic>{},
        <String>[],
        _saleOrderFieldSpec,
      ],
      kwargs: {
        'context': context,
      },
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    return OdooOnchangeResponse.fromJson(response['result']);
  }

  Future<OdooWebSaveResponse> webSaveSaleOrder({
    required Map<String, dynamic> values,
    required Map<String, dynamic> context,
  }) async {
    final request = JsonRpcRequest.callKw(
      model: 'sale.order',
      method: 'web_save',
      args: [
        <int>[],
        values,
      ],
      kwargs: {
        'context': context,
        'specification': _webSaveSpec,
      },
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    try {
      return OdooWebSaveResponse.fromJson(response['result']);
    } on FormatException catch (e) {
      throw ParsingFailure(e.message);
    }
  }

  Map<String, dynamic> _buildQuotationContext({
    required int leadId,
    required int uid,
    required List<int> allowedCompanyIds,
    required Map<String, dynamic> actionContext,
  }) {
    final context = <String, dynamic>{
      'lang': 'en_US',
      'tz': 'Asia/Kolkata',
      'uid': uid,
      if (allowedCompanyIds.isNotEmpty)
        'allowed_company_ids': allowedCompanyIds,
      'active_model': 'crm.lead',
      'active_id': leadId,
      'active_ids': [leadId],
    };

    // Preserve defaults returned by Odoo (partner, team, company, tags, …).
    for (final entry in actionContext.entries) {
      context[entry.key] = entry.value;
    }

    return context;
  }
}
