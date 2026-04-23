class BudgetPeriod {
  final DateTime start;
  final DateTime end;
  final int budgetYear;
  final int budgetMonth;

  const BudgetPeriod({
    required this.start,
    required this.end,
    required this.budgetYear,
    required this.budgetMonth,
  });

  String get label {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[budgetMonth]} $budgetYear';
  }

  @override
  bool operator ==(Object other) =>
      other is BudgetPeriod &&
      budgetYear == other.budgetYear &&
      budgetMonth == other.budgetMonth;

  @override
  int get hashCode => Object.hash(budgetYear, budgetMonth);
}
