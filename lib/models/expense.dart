import 'package:intl/intl.dart';

class Expense {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  // Convert Expense to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  // Create Expense from a database Map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
    );
  }

  // Formatted date getter
  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}