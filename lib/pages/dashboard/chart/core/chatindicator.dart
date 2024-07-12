import 'package:Intranet/pages/dashboard/chart/core/expenses.dart';
import 'package:flutter/material.dart';

class ExpenseWidget extends StatelessWidget {
  final Expense expense;

  const ExpenseWidget({Key? key, required this.expense}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      child: Row(
        children: [
          Container(
            height: 10,
            width: 10,
            margin: const EdgeInsets.only(right: 18),
            decoration: BoxDecoration(
              color: expense.color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              "${expense.expenseName} - ${expense.actual} / ${expense.target}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}