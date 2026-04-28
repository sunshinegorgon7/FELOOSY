import 'package:go_router/go_router.dart';
import '../data/models/category.dart';
import '../data/models/transaction.dart';
import '../presentation/budget/budget_screen.dart';
import '../presentation/budget/set_budget_sheet.dart';
import '../presentation/categories/categories_screen.dart';
import '../presentation/categories/edit_category_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/transactions/add_transaction_screen.dart';
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
      builder: (context, state) => const BudgetScreen(),
    ),

    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
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
      path: '/categories/edit',
      builder: (context, state) {
        final category = state.extra as Category?;
        return EditCategoryScreen(category: category);
      },
    ),
  ],
);
