/// Odoo workspace the production app can log into.
enum AppTenant {
  digilawyer,
  botshot;

  String get id => name;

  String get displayName => switch (this) {
        digilawyer => 'DigiLawyer',
        botshot => 'Botshot',
      };

  String get mark => switch (this) {
        digilawyer => 'DL',
        botshot => 'BS',
      };

  String get baseUrl => switch (this) {
        digilawyer => 'https://crmdigi.digilawyer.ai',
        botshot => 'https://crmbot.botshot.ai',
      };

  String get databaseName => switch (this) {
        digilawyer => 'crmdigi',
        botshot => 'crmbot',
      };

  String get emailHint => switch (this) {
        digilawyer => 'you@digilawyer.ai',
        botshot => 'you@botshot.ai',
      };

  String get host => Uri.tryParse(baseUrl)?.host ?? baseUrl;

  static const AppTenant fallback = AppTenant.digilawyer;

  static AppTenant fromId(String? id) {
    for (final tenant in AppTenant.values) {
      if (tenant.id == id) return tenant;
    }
    return fallback;
  }
}
