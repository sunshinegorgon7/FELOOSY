import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feloosy/data/models/app_settings.dart';
import 'package:feloosy/data/models/category.dart';
import 'package:feloosy/data/models/transaction.dart';
import 'package:feloosy/presentation/transactions/widgets/transaction_tile.dart';
import 'package:feloosy/providers/settings_provider.dart';

void main() {
  testWidgets('TransactionTile renders formatted amount and category', (
    tester,
  ) async {
    final settings = AppSettings(
      currencyCode: 'USD',
      currencySymbol: r'$',
      currencySymbolLeading: true,
      updatedAt: DateTime(2026, 1, 1),
    );

    final tx = Transaction(
      uuid: 'tx-1',
      accountId: 1,
      amount: 12.5,
      type: TransactionType.expense,
      description: 'Coffee run',
      categoryUuid: 'cat-1',
      transactionDate: DateTime(2026, 3, 14),
      createdAt: DateTime(2026, 3, 14),
      updatedAt: DateTime(2026, 3, 14),
    );

    final category = Category(
      uuid: 'cat-1',
      name: 'Coffee',
      colorValue: Colors.brown.toARGB32(),
      iconCodePoint: Icons.coffee.codePoint,
      iconFontFamily: Icons.coffee.fontFamily ?? 'MaterialIcons',
      isCustom: false,
      isActive: true,
      sortOrder: 0,
      createdAt: DateTime(2026, 3, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(() => _FakeSettingsNotifier(settings)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: TransactionTile(transaction: tx, category: category),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Coffee run'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text(r'$ 12.50'), findsOneWidget);
  });
}

class _FakeSettingsNotifier extends SettingsNotifier {
  final AppSettings _settings;
  _FakeSettingsNotifier(this._settings);

  @override
  Future<AppSettings> build() async => _settings;
}
