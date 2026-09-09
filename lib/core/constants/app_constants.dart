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
}
