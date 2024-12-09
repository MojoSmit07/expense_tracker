import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'expense_item.dart';
import '../screens/add_expense_screen.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseList({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          'No expenses yet. Add your first expense!',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Dismissible(
          key: ValueKey(expense.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          secondaryBackground: Container(
            color: Colors.blue,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Delete confirmation dialog
              return await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Expense'),
                  content: const Text(
                      'Are you sure you want to delete this expense?'),
                  actions: [
                    TextButton(
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                    ),
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                      },
                    ),
                  ],
                ),
              );
            } else if (direction == DismissDirection.startToEnd) {
              // Navigate to edit screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddExpenseScreen(
                    existingExpense: expense,
                  ),
                ),
              );
              return false; // Prevent dismissal
            }
            return null;
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              Provider.of<ExpenseProvider>(context, listen: false)
                  .removeExpense(expense);
            }
          },
          child: GestureDetector(
            onTap: () {
              // Allow editing by tapping the expense item
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddExpenseScreen(
                    existingExpense: expense,
                  ),
                ),
              );
            },
            child: ExpenseItem(expense: expense),
          ),
        );
      },
    );
  }
}
