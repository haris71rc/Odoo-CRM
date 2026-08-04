/// App flavor controlled via `--dart-define=APP_ENV=dev|prod`.
///
/// Dev adds Odoo domain filter: `["company_id", "=", 6]`.
class AppEnvironment {
  AppEnvironment._();

  static const String name = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );

  static bool get isDev => name == 'dev';
  static bool get isProd => !isDev;

  /// Company used to scope Dev data.
  static const int devCompanyId = 6;

  /// Companies allowed in Odoo request context / cookie `cids`.
  static List<int> get allowedCompanyIds {
    if (isDev) return const [devCompanyId];
    return const [];
  }

  /// Base Odoo domain for the active environment.
  ///
  /// Dev:
  /// ```json
  /// [["company_id", "=", 6]]
  /// ```
  ///
  /// Prod: empty domain (no company filter).
  static List<List<dynamic>> get baseDomain {
    if (!isDev) return const [];
    return const [
      ['company_id', '=', devCompanyId],
    ];
  }

  /// Merges environment domain with additional filters.
  static List<List<dynamic>> mergeDomain([
    List<List<dynamic>> extra = const [],
  ]) {
    return [...baseDomain, ...extra];
  }
}
