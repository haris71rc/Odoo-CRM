class AppConstants {
  AppConstants._();

  static const String authenticatePath = '/web/session/authenticate';
  static const String callKwPath = '/web/dataset/call_kw';
  static const String mailMessagePostPath = '/mail/message/post';
  static const String mailThreadMessagesPath = '/mail/thread/messages';

  /// Odoo web button action endpoint, e.g. crm.lead/action_sale_quotations_new.
  static String callButtonPath(String model, String method) =>
      '/web/dataset/call_button/$model/$method';

  static const String sessionIdKey = 'session_id';
  static const String uidKey = 'uid';
  static const String userLoginKey = 'user_login';
  static const String tenantKey = 'app_tenant';

  /// Durable Growth `/api/v1/calls/log` outbox (pending + recent acks).
  static const String growthCallOutboxKey = 'growth_call_outbox_v1';

  /// Incremental inbound device-call sync cursor (Android CallLog watermark).
  static const String inboundCallSyncCursorKey = 'inbound_call_sync_cursor_v1';

  /// CRM-initiated outbound dial waiting for the Android call log.
  static const String pendingOutboundDialKey = 'pending_outbound_dial_v1';

  /// Per-lead Android call rows already applied to the Odoo call log.
  static const String leadCallSyncCursorKey = 'lead_call_sync_cursor_v1';
}
