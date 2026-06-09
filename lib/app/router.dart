import 'package:go_router/go_router.dart';
import '../data/models/category.dart';
import '../data/models/sms_rule.dart';
import '../data/models/transaction.dart';
import '../presentation/budget/history_screen.dart';
import '../presentation/budget/set_budget_sheet.dart';
import '../presentation/categories/categories_screen.dart';
import '../presentation/categories/edit_category_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/settings/manage_accounts_screen.dart';
import '../presentation/settings/privacy_policy_screen.dart';
import '../presentation/sms_rules/sms_rule_form_screen.dart';
import '../presentation/sms_rules/sms_rules_screen.dart';
import '../presentation/transactions/add_transaction_screen.dart';
import '../presentation/paywall/paywall_screen.dart';
import '../presentation/admin/license_admin_screen.dart';
import 'package:flutter/material.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: '/budget',
      builder: (context, state) => const HistoryScreen(),
    ),

    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/accounts',
      builder: (context, state) => const ManageAccountsScreen(),
    ),
    GoRoute(
      path: '/settings/privacy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),

    GoRoute(
      path: '/transactions/add',
      builder: (context, state) {
        final type = state.uri.queryParameters['type'] ?? 'expense';
        return AddTransactionScreen(type: type);
      },
    ),

    GoRoute(
      path: '/transactions/edit',
      builder: (context, state) {
        final tx = state.extra! as Transaction;
        return AddTransactionScreen(
          type: tx.type == TransactionType.expense ? 'expense' : 'income',
          initialTransaction: tx,
        );
      },
    ),

    GoRoute(
      path: '/budget/set',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Set Budget')),
        body: const SafeArea(
          top: false,
          child: SetBudgetSheet(),
        ),
      ),
    ),

    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesScreen(),
    ),

    GoRoute(
      path: '/paywall',
      builder: (context, state) => const PaywallScreen(),
    ),

    GoRoute(
      path: '/admin/licenses',
      builder: (context, state) => const LicenseAdminScreen(),
    ),

    GoRoute(
      path: '/sms-rules',
      builder: (context, state) => const SmsRulesScreen(),
    ),
    GoRoute(
      path: '/sms-rules/edit',
      builder: (context, state) {
        final extra = state.extra;
        return SmsRuleFormScreen(rule: extra is SmsRule ? extra : null);
      },
    ),

    GoRoute(
      path: '/categories/edit',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is Category) return EditCategoryScreen(category: extra);
        if (extra is Map<String, dynamic>) {
          return EditCategoryScreen(
            category: extra['category'] as Category?,
            defaultType: extra['defaultType'] as String?,
          );
        }
        return const EditCategoryScreen();
      },
    ),
  ],
);
