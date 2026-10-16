import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/finance_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_card.dart';
import 'card_management_screen.dart';
import 'receipt_capture_screen.dart';

class MainFeedScreen extends ConsumerStatefulWidget {
  const MainFeedScreen({super.key});

  @override
  ConsumerState<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends ConsumerState<MainFeedScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Expense', 'Income'];

  Future<void> _toggleStar(String transactionId) async {
    try {
      await ref.read(financeProvider.notifier).toggleStar(transactionId);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update transaction: $error')),
      );
    }
  }

  String _dateLabel(DateTime date) {
    final today = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (dateOnly == todayOnly) return 'Today';
    if (dateOnly == todayOnly.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financeProvider);
    final filteredTransactions = state.transactions.where((transaction) {
      if (_selectedCategoryIndex == 0) return true;
      return transaction.type.label == _categories[_selectedCategoryIndex];
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Finance'),
        actions: [
          IconButton(
            tooltip: 'Manage cards',
            icon: const Icon(Icons.credit_card),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CardManagementScreen(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReceiptCaptureScreen()),
        ),
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text('Scan receipt'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BalanceCard(
                balance: state.totalBalance,
                income: state.totalIncome,
                expense: state.totalExpenses,
              ),
              const SizedBox(height: 10),
              Text(
                'Remaining funds across ${state.cards.length} '
                '${state.cards.length == 1 ? 'card' : 'cards'}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${filteredTransactions.length} items',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCategoryIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_categories[index]),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategoryIndex = index);
                          }
                        },
                        selectedColor: const Color(0xFF02569B),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              if (filteredTransactions.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        state.transactions.isEmpty
                            ? 'No transactions yet. Scan a receipt to get started.'
                            : 'No ${_categories[_selectedCategoryIndex].toLowerCase()} transactions.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return TransactionCard(
                      title: transaction.merchant,
                      category: transaction.type.label,
                      amount: transaction.signedAmount,
                      date: _dateLabel(transaction.date),
                      isStarred: transaction.isStarred,
                      onStarPressed: () => _toggleStar(transaction.id),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
