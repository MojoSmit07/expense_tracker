import 'package:flutter/foundation.dart';
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

  // Optional: Get total expenses
  double getTotalExpenses() {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }
}

// Extension method to create a copy with optional updates
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