import 'package:intl/intl.dart';
import '../../data/models/app_settings.dart';

class CurrencyFormatter {
  static final _nf = NumberFormat('#,##0.00');

  static String format(double amount, AppSettings settings) {
    final formatted = _nf.format(amount.abs());
    return settings.currencySymbolLeading
        ? '${settings.currencySymbol} $formatted'
        : '$formatted ${settings.currencySymbol}';
  }

  static String formatSigned(double amount, AppSettings settings) {
    final prefix = amount >= 0 ? '+' : '-';
    final formatted = _nf.format(amount.abs());
    return settings.currencySymbolLeading
        ? '$prefix${settings.currencySymbol} $formatted'
        : '$prefix$formatted ${settings.currencySymbol}';
  }
}
