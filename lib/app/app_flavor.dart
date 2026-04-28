enum Flavor { dev, uat, prod }

class AppFlavor {
  static late Flavor _current;
  static Flavor get current => _current;

  static bool get isDev => _current == Flavor.dev;
  static bool get isUat => _current == Flavor.uat;
  static bool get isProd => _current == Flavor.prod;

  static String get databaseName => switch (_current) {
        Flavor.dev => 'feloosy_dev.db',
        Flavor.uat => 'feloosy_uat.db',
        Flavor.prod => 'feloosy.db',
      };

  static String get displayName => switch (_current) {
        Flavor.dev => 'DEV',
        Flavor.uat => 'UAT',
        Flavor.prod => '',
      };

  static Future<void> initialize(Flavor flavor) async {
    _current = flavor;
  }
}
