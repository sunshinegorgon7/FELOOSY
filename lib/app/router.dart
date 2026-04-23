import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/budget/budget_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/transactions/transaction_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ScaffoldWithNavBar(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/transactions',
              builder: (context, state) => const TransactionListScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/budget',
              builder: (context, state) => const BudgetScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen()),
        ]),
      ],
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
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
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
