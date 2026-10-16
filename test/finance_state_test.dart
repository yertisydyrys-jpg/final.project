import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hello_yer/models/finance_transaction.dart';
import 'package:flutter_hello_yer/models/virtual_card.dart';
import 'package:flutter_hello_yer/providers/finance_provider.dart';

void main() {
  group('VirtualCard card number validation', () {
    test('accepts valid Luhn numbers with optional spaces or hyphens', () {
      expect(VirtualCard.isValidCardNumber('4111111111111111'), isTrue);
      expect(VirtualCard.isValidCardNumber('4111 1111 1111 1111'), isTrue);
      expect(VirtualCard.isValidCardNumber('4111-1111-1111-1111'), isTrue);
    });

    test('rejects invalid checksums, repeated digits, and wrong lengths', () {
      expect(VirtualCard.isValidCardNumber('4111111111111112'), isFalse);
      expect(VirtualCard.isValidCardNumber('0000000000000000'), isFalse);
      expect(VirtualCard.isValidCardNumber('411111111111111'), isFalse);
      expect(VirtualCard.isValidCardNumber('4111a11111111111'), isFalse);
    });
  });

  group('FinanceState balances', () {
    const firstCard = VirtualCard(
      id: 'card-1',
      fullName: 'Alex Example',
      bankName: 'Everyday',
      lastFourDigits: '1234',
      expiryDate: '12/30',
    );
    const secondCard = VirtualCard(
      id: 'card-2',
      fullName: 'Alex Example',
      bankName: 'Savings',
      lastFourDigits: '5678',
      expiryDate: '06/29',
    );

    test('calculates account and per-card income, spending, and balance', () {
      final state = FinanceState(
        cards: const [firstCard, secondCard],
        transactions: [
          FinanceTransaction(
            id: 'income',
            cardId: firstCard.id,
            merchant: 'Salary',
            amount: 1000,
            date: DateTime(2026, 1, 1),
            type: TransactionType.income,
          ),
          FinanceTransaction(
            id: 'expense',
            cardId: firstCard.id,
            merchant: 'Grocer',
            amount: 125.50,
            date: DateTime(2026, 1, 2),
            type: TransactionType.expense,
          ),
          FinanceTransaction(
            id: 'other-card-expense',
            cardId: secondCard.id,
            merchant: 'Cafe',
            amount: 20,
            date: DateTime(2026, 1, 3),
            type: TransactionType.expense,
          ),
        ],
      );

      expect(state.totalIncome, 1000);
      expect(state.totalExpenses, 145.50);
      expect(state.totalBalance, 854.50);
      expect(state.summaryFor(firstCard.id).balance, 874.50);
      expect(state.summaryFor(firstCard.id).expenses, 125.50);
      expect(state.summaryFor(secondCard.id).balance, -20);
    });

    test('serializes transactions with their card association', () {
      final transaction = FinanceTransaction(
        id: 'transaction-1',
        cardId: firstCard.id,
        merchant: 'Market',
        amount: 42,
        date: DateTime(2026, 3, 4),
        type: TransactionType.expense,
      );

      final restored = FinanceTransaction.fromMap(transaction.toMap());

      expect(restored.cardId, firstCard.id);
      expect(restored.amount, 42);
      expect(restored.type, TransactionType.expense);
      expect(restored.signedAmount, -42);
    });
  });
}
