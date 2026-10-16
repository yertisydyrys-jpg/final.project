class VirtualCard {
  const VirtualCard({
    required this.id,
    required this.fullName,
    required this.bankName,
    required this.lastFourDigits,
    required this.expiryDate,
  });

  final String id;
  final String fullName;
  final String bankName;
  final String lastFourDigits;
  final String expiryDate;

  String get maskedNumber => '•••• •••• •••• $lastFourDigits';

  static String normalizedDigits(String cardNumber) =>
      cardNumber.replaceAll(RegExp(r'[\s-]'), '');

  static bool isValidCardNumber(String cardNumber) {
    print(cardNumber);
    final digits = normalizedDigits(cardNumber);
    if (!RegExp(r'^\d{16}$').hasMatch(digits) ||
        RegExp(r'^(\d)\1{15}$').hasMatch(digits)) {
          print('Invalid card number: $cardNumber');
      return false;
    }
    print('Valid card number: $cardNumber');
    return true;
    // var sum = 0;
    // var doubleDigit = false;
    // for (final digit in digits.split('').reversed) {
    //   var value = int.parse(digit);
    //   if (doubleDigit) {
    //     value *= 2;
    //     if (value > 9) value -= 9;
    //   }
    //   sum += value;
    //   doubleDigit = !doubleDigit;
    // }
    // return sum % 10 == 0;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'bankName': bankName,
        'lastFourDigits': lastFourDigits,
        'expiryDate': expiryDate,
      };

  factory VirtualCard.fromMap(Map<dynamic, dynamic> map) => VirtualCard(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        bankName: map['bankName'] as String,
        lastFourDigits: map['lastFourDigits'] as String,
        expiryDate: map['expiryDate'] as String,
      );
}
