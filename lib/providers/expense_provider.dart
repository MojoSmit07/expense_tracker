import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../helpers/db_helper.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Expense> get expenses => [..._expenses];

  Future<void> fetchExpenses() async {
    _expenses = await _dbHelper.getExpenses();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    int id = await _dbHelper.insertExpense(expense);
    _expenses.add(expense.copyWith(id: id));
    notifyListeners();
  }

  Future<void> removeExpense(Expense expense) async {
    await _dbHelper.deleteExpense(expense.id!);
    _expenses.remove(expense);
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await _dbHelper.updateExpense(expense);
    int index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  // Get total expenses
  double getTotalExpenses() {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get monthly expenses
  Map<String, double> getMonthlyExpenses() {
    Map<String, double> monthlyExpenses = {};

    for (var expense in _expenses) {
      String monthKey = DateFormat('yyyy-MM').format(expense.date);
      monthlyExpenses[monthKey] =
          (monthlyExpenses[monthKey] ?? 0) + expense.amount;
    }

    return monthlyExpenses;
  }

  // Get expenses for a specific month
  List<Expense> getExpensesForMonth(DateTime month) {
    return _expenses.where((expense) {
      return expense.date.year == month.year &&
          expense.date.month == month.month;
    }).toList();
  }

  // Get total expenses for a specific category
  double getTotalExpensesByCategory(String category) {
    return _expenses
        .where((expense) => expense.category == category)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get category-wise breakdown
  Map<String, double> getCategoryBreakdown() {
    Map<String, double> categoryBreakdown = {};

    for (var expense in _expenses) {
      categoryBreakdown[expense.category] =
          (categoryBreakdown[expense.category] ?? 0) + expense.amount;
    }

    return categoryBreakdown;
  }
}

// Existing extension method remains the same
extension ExpenseCopy on Expense {
  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }
}
