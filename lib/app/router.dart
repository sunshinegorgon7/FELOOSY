import 'package:flutter/material.dart';
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

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ScaffoldWithNavBar(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
        ]),

        StatefulShellBranch(routes: [
          GoRoute(
            path: '/budget',
            builder: (context, state) => const BudgetScreen(),
          ),
        ]),

        StatefulShellBranch(routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ]),
      ],
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

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell shell;
  const ScaffoldWithNavBar({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
