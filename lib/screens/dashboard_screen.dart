import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';

// Enum to represent different time intervals
enum TimeInterval { day, week, month }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TimeInterval _selectedInterval = TimeInterval.month;

  @override
  void initState() {
    super.initState();
    // Ensure expenses are fetched
    Future.delayed(Duration.zero, () {
      Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses();
    });
  }

  // Method to group expenses based on selected interval
  Map<String, double> _getGroupedExpenses(ExpenseProvider expenseProvider) {
    final expenses = expenseProvider.expenses;
    Map<String, double> groupedExpenses = {};

    for (var expense in expenses) {
      String key;
      switch (_selectedInterval) {
        case TimeInterval.day:
          key = DateFormat('yyyy-MM-dd').format(expense.date);
          break;
        case TimeInterval.week:
          DateTime weekStart =
              expense.date.subtract(Duration(days: expense.date.weekday - 1));
          key = DateFormat('yyyy-MM-dd').format(weekStart);
          break;
        case TimeInterval.month:
          key = DateFormat('yyyy-MM').format(expense.date);
          break;
      }

      groupedExpenses[key] = (groupedExpenses[key] ?? 0) + expense.amount;
    }

    return groupedExpenses;
  }

  // Method to show interval selection bottom sheet
  void _showIntervalBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Time Interval',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              _buildIntervalButton(TimeInterval.day, 'Day-wise'),
              SizedBox(height: 8),
              _buildIntervalButton(TimeInterval.week, 'Week-wise'),
              SizedBox(height: 8),
              _buildIntervalButton(TimeInterval.month, 'Month-wise'),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build interval selection buttons
  Widget _buildIntervalButton(TimeInterval interval, String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedInterval = interval;
        });
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedInterval == interval
            ? Colors.blue.shade700
            : Colors.blue.shade50,
        foregroundColor:
            _selectedInterval == interval ? Colors.white : Colors.blue.shade700,
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Expense Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          final intervalExpenses = _getGroupedExpenses(expenseProvider);
          final categoryBreakdown = expenseProvider.getCategoryBreakdown();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getIntervalTitle(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        TextButton(
                          onPressed: _showIntervalBottomSheet,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue.shade700,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Change Interval',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.swap_horiz, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildExpensesChart(intervalExpenses),
                _buildCategoryBreakdown(categoryBreakdown),
                _buildTotalExpensesSummary(expenseProvider.getTotalExpenses()),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getIntervalTitle() {
    switch (_selectedInterval) {
      case TimeInterval.day:
        return 'Day-wise Expenses';
      case TimeInterval.week:
        return 'Week-wise Expenses';
      case TimeInterval.month:
        return 'Monthly Expenses';
    }
  }

  Widget _buildExpensesChart(Map<String, double> intervalExpenses) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getIntervalTitle(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: intervalExpenses.isEmpty
                ? Center(child: Text('No expenses to display'))
                : BarChart(
                    BarChartData(
                      barGroups: intervalExpenses.entries.map((entry) {
                        return BarChartGroupData(
                          x: intervalExpenses.keys.toList().indexOf(entry.key),
                          barRods: [
                            BarChartRodData(
                              toY: entry.value,
                              color: Colors.blue.shade700,
                              width: 16,
                            )
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final intervalKeys =
                                  intervalExpenses.keys.toList();
                              return Text(
                                intervalKeys[value.toInt()],
                                style: TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(Map<String, double> categoryBreakdown) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 16),
          Column(
            children: categoryBreakdown.entries.map((entry) {
              return ListTile(
                leading: Icon(
                  _getCategoryIcon(entry.key),
                  color: _getCategoryColor(entry.key),
                ),
                title: Text(entry.key),
                trailing: Text(
                  '\$${entry.value.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalExpensesSummary(double totalExpenses) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade500, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Expenses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '\$${totalExpenses.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(
            Icons.trending_down,
            color: Colors.white,
            size: 40,
          ),
        ],
      ),
    );
  }

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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.green;
      case 'Transport':
        return Colors.blue;
      case 'Entertainment':
        return Colors.red;
      case 'Utilities':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
