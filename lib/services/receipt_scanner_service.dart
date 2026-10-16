import 'package:image_picker/image_picker.dart';

import '../models/finance_transaction.dart';

class ScannedReceipt {
  const ScannedReceipt({
    required this.amount,
    required this.date,
    required this.merchant,
    required this.type,
  });

  final double amount;
  final DateTime date;
  final String merchant;
  final TransactionType type;
}

class ReceiptScannerService {
  Future<ScannedReceipt> scanReceipt(XFile image) async {
    if (await image.length() == 0) {
      throw const FormatException('The selected receipt image is empty.');
    }

    await Future<void>.delayed(const Duration(milliseconds: 900));
    return ScannedReceipt(
      amount: 24.99,
      date: DateTime.now(),
      merchant: 'Sample Merchant',
      type: TransactionType.expense,
    );
  }
}
