import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseItem extends StatelessWidget {
  final Expense expense;

  const ExpenseItem({super.key, required this.expense});

  // Helper method to get icon for category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood;
      case 'Transport':
        return Icons.directions_car;
      case 'Entertainment':
        return Icons.movie;
      case 'Utilities':
        return Icons.electrical_services;
      default:
        return Icons.category;
    }
  }

  // Helper method to get color for category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.green[100]!;
      case 'Transport':
        return Colors.blue[100]!;
      case 'Entertainment':
        return Colors.purple[100]!;
      case 'Utilities':
        return Colors.orange[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(expense.category),
          child: Icon(
            _getCategoryIcon(expense.category),
            color: Colors.black87,
          ),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          expense.formattedDate,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          '\$${expense.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: expense.amount > 100 ? Colors.red : Colors.black,
          ),
        ),
      ),
    );
  }
}
