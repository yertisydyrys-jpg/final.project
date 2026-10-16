import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/finance_transaction.dart';
import '../models/virtual_card.dart';

class CardSummary {
  const CardSummary({
    required this.income,
    required this.expenses,
  });

  final double income;
  final double expenses;

  double get balance => income - expenses;
}

class FinanceState {
  FinanceState({
    required List<VirtualCard> cards,
    required List<FinanceTransaction> transactions,
  })  : cards = List.unmodifiable(cards),
        transactions = List.unmodifiable(transactions);

  final List<VirtualCard> cards;
  final List<FinanceTransaction> transactions;

  double get totalIncome => transactions
      .where((transaction) => transaction.type == TransactionType.income)
      .fold(0, (total, transaction) => total + transaction.amount);

  double get totalExpenses => transactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .fold(0, (total, transaction) => total + transaction.amount);

  double get totalBalance => totalIncome - totalExpenses;

  CardSummary summaryFor(String cardId) {
    final cardTransactions =
        transactions.where((transaction) => transaction.cardId == cardId);
    final income = cardTransactions
        .where((transaction) => transaction.type == TransactionType.income)
        .fold(0.0, (total, transaction) => total + transaction.amount);
    final expenses = cardTransactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold(0.0, (total, transaction) => total + transaction.amount);
    return CardSummary(income: income, expenses: expenses);
  }
}

class FinanceController extends StateNotifier<FinanceState> {
  FinanceController({
    required Box<Map> cardsBox,
    required Box<Map> transactionsBox,
  })  : _cardsBox = cardsBox,
        _transactionsBox = transactionsBox,
        super(
          FinanceState(
            cards: cardsBox.values
                .map((value) => VirtualCard.fromMap(value))
                .toList(),
            transactions: transactionsBox.values
                .map((value) => FinanceTransaction.fromMap(value))
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date)),
          ),
        );

  final Box<Map> _cardsBox;
  final Box<Map> _transactionsBox;

  Future<void> addCard({
    required String fullName,
    required String bankName,
    required String cardNumber,
    required String expiryDate,
  }) async {
    if (!VirtualCard.isValidCardNumber(cardNumber)) {
      throw ArgumentError.value(
        cardNumber,
        'cardNumber',
        'Must be a valid 16-digit card number.',
      );
    }
    final digits = VirtualCard.normalizedDigits(cardNumber);
    final expiryDigits = expiryDate.replaceAll(RegExp(r'\D'), '');
    if (expiryDigits.length != 4) {
      throw ArgumentError.value(expiryDate, 'expiryDate', 'Must use MM/YY.');
    }
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final card = VirtualCard(
      id: id,
      fullName: fullName.trim(),
      bankName: bankName.trim(),
      lastFourDigits: digits.substring(12),
      expiryDate:
          '${expiryDigits.substring(0, 2)}/${expiryDigits.substring(2)}',
    );
    await _cardsBox.put(id, card.toMap());
    state = FinanceState(cards: [...state.cards, card], transactions: state.transactions);
  }

  Future<void> deleteCard(String cardId) async {
    await _cardsBox.delete(cardId);
    final relatedTransactions =
        state.transactions.where((transaction) => transaction.cardId == cardId);
    for (final transaction in relatedTransactions) {
      await _transactionsBox.delete(transaction.id);
    }
    state = FinanceState(
      cards: state.cards.where((card) => card.id != cardId).toList(),
      transactions: state.transactions
          .where((transaction) => transaction.cardId != cardId)
          .toList(),
    );
  }

  Future<void> addTransaction({
    required String cardId,
    required String merchant,
    required double amount,
    required DateTime date,
    required TransactionType type,
  }) async {
    if (!state.cards.any((card) => card.id == cardId)) {
      throw StateError('The selected card no longer exists.');
    }
    if (amount <= 0 || !amount.isFinite) {
      throw ArgumentError.value(amount, 'amount', 'Must be a positive amount.');
    }
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final transaction = FinanceTransaction(
      id: id,
      cardId: cardId,
      merchant: merchant.trim(),
      amount: amount,
      date: date,
      type: type,
    );
    await _transactionsBox.put(id, transaction.toMap());
    state = FinanceState(
      cards: state.cards,
      transactions: [...state.transactions, transaction]
        ..sort((a, b) => b.date.compareTo(a.date)),
    );
  }

  Future<void> toggleStar(String transactionId) async {
    final index = state.transactions
        .indexWhere((transaction) => transaction.id == transactionId);
    if (index == -1) return;

    final updated = state.transactions[index].copyWith(
      isStarred: !state.transactions[index].isStarred,
    );
    await _transactionsBox.put(updated.id, updated.toMap());
    final transactions = [...state.transactions];
    transactions[index] = updated;
    state = FinanceState(cards: state.cards, transactions: transactions);
  }
}

final financeProvider =
    StateNotifierProvider<FinanceController, FinanceState>((ref) {
  throw StateError('FinanceProvider must be overridden after Hive initializes.');
});
