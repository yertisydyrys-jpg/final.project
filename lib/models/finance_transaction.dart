enum TransactionType {
  expense,
  income;

  String get label => this == TransactionType.expense ? 'Expense' : 'Income';
}

class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.cardId,
    required this.merchant,
    required this.amount,
    required this.date,
    required this.type,
    this.isStarred = false,
  });

  final String id;
  final String cardId;
  final String merchant;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final bool isStarred;

  double get signedAmount =>
      type == TransactionType.expense ? -amount : amount;

  FinanceTransaction copyWith({bool? isStarred}) => FinanceTransaction(
        id: id,
        cardId: cardId,
        merchant: merchant,
        amount: amount,
        date: date,
        type: type,
        isStarred: isStarred ?? this.isStarred,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'cardId': cardId,
        'merchant': merchant,
        'amount': amount,
        'date': date.toIso8601String(),
        'type': type.name,
        'isStarred': isStarred,
      };

  factory FinanceTransaction.fromMap(Map<dynamic, dynamic> map) =>
      FinanceTransaction(
        id: map['id'] as String,
        cardId: map['cardId'] as String,
        merchant: map['merchant'] as String,
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        type: TransactionType.values.byName(map['type'] as String),
        isStarred: map['isStarred'] as bool? ?? false,
      );
}
