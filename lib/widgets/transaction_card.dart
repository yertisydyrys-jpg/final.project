import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final String date;
  final bool isStarred;
  final VoidCallback onStarPressed;

  const TransactionCard({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.isStarred,
    required this.onStarPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = amount < 0;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpense ? Colors.red.shade50 : Colors.green.shade50,
          child: Icon(
            isExpense ? Icons.shopping_bag_outlined : Icons.account_balance_wallet_outlined,
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text('$category • $date'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isExpense ? "" : "+"}\$${amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isExpense ? Colors.red : Colors.green,
              ),
            ),
            IconButton(
              icon: Icon(
                isStarred ? Icons.star : Icons.star_border,
                color: isStarred ? Colors.amber : Colors.grey,
              ),
              onPressed: onStarPressed,
            ),
          ],
        ),
      ),
    );
  }
}