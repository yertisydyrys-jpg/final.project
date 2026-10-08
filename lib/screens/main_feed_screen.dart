import 'package:flutter/material.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_card.dart';
import 'detail_screen.dart';

class MainFeedScreen extends StatefulWidget {
  const MainFeedScreen({super.key});

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Shopping', 'Salary', 'Food', 'Bills'];

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Supermarket Grocery',
      'category': 'Shopping',
      'amount': -120.50,
      'date': 'Today',
      'isStarred': false,
    },
    {
      'title': 'Monthly Salary',
      'category': 'Salary',
      'amount': 3500.00,
      'date': 'Yesterday',
      'isStarred': true,
    },
    {
      'title': 'Coffee & Bakery',
      'category': 'Food',
      'amount': -14.20,
      'date': 'Oct 7',
      'isStarred': false,
    },
    {
      'title': 'Electricity Bill',
      'category': 'Bills',
      'amount': -85.00,
      'date': 'Oct 5',
      'isStarred': false,
    },
  ];

  void _toggleStar(int index) {
    setState(() {
      _transactions[index]['isStarred'] = !_transactions[index]['isStarred'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _selectedCategoryIndex == 0
        ? _transactions
        : _transactions
            .where((t) => t['category'] == _categories[_selectedCategoryIndex])
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Finance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.credit_card),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DetailScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BalanceCard(
                balance: 8420.30,
                income: 3500.00,
                expense: 219.70,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
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
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(_categories[index]),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${filteredTransactions.length} items',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  final item = filteredTransactions[index];
                  final originalIndex = _transactions.indexOf(item);
                  return TransactionCard(
                    title: item['title'],
                    category: item['category'],
                    amount: item['amount'],
                    date: item['date'],
                    isStarred: item['isStarred'],
                    onStarPressed: () => _toggleStar(originalIndex),
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