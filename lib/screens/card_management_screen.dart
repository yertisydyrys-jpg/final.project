import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../models/virtual_card.dart';
import '../providers/finance_provider.dart';

class CardManagementScreen extends ConsumerWidget {
  const CardManagementScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    VirtualCard card,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete card?'),
        content: Text(
          'Deleting ${card.bankName} also removes its linked transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(financeProvider.notifier).deleteCard(card.id);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete card: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Cards')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCardScreen()),
        ),
        icon: const Icon(Icons.add_card),
        label: const Text('Add new card'),
      ),
      body: state.cards.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.credit_card_off, size: 56, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No cards added yet.'),
                    Text('Add a card to start tracking receipts.'),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: state.cards.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final card = state.cards[index];
                final summary = state.summaryFor(card.id);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              child: Icon(Icons.credit_card),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    card.bankName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(card.maskedNumber),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete card',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  _confirmDelete(context, ref, card),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text('${card.fullName}  •  Expires ${card.expiryDate}'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CardAmount(label: 'Balance', amount: summary.balance),
                            _CardAmount(label: 'Income', amount: summary.income),
                            _CardAmount(
                              label: 'Spent',
                              amount: summary.expenses,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _CardAmount extends StatelessWidget {
  const _CardAmount({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text('\$${amount.toStringAsFixed(2)}'),
        ],
      );
}

class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _bankNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.length < 3 || RegExp(r'\d').hasMatch(name)) {
      return 'Enter the full name shown on the passport.';
    }
    return null;
  }

  String? _validateCardNumber(String? value) {
    final digits = VirtualCard.normalizedDigits(value ?? '');
    if (digits.length != 16) return 'Enter all 16 digits.';
    return VirtualCard.isValidCardNumber(digits)
        ? null
        : 'Check the card number.';
  }

  String? _validateExpiry(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 4) return 'Enter the date as MM/YY.';
    final month = int.parse(digits.substring(0, 2));
    final year = 2000 + int.parse(digits.substring(2));
    if (month < 1 || month > 12) return 'Enter a valid month.';
    final now = DateTime.now();
    if (year < now.year || (year == now.year && month < now.month)) {
      return 'The card has expired.';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    if (!RegExp(r'^\d{3,4}$').hasMatch(value?.trim() ?? '')) {
      return 'CVV must contain 3 or 4 digits.';
    }
    return null;
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(financeProvider.notifier).addCard(
            fullName: _fullNameController.text,
            bankName: _bankNameController.text,
            cardNumber: _cardNumberController.text,
            expiryDate: _expiryController.text,
          );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save card: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add new card')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Only the last four digits are saved. Your full card number '
                  'and CVV are used for validation, then discarded.',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _fullNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _decoration('Full name (passport)', Icons.person),
                  validator: _validateName,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _bankNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _decoration('Custom bank name', Icons.account_balance),
                  validator: (value) => (value?.trim().length ?? 0) < 2
                      ? 'Enter a name for this card.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9 -]')),
                  ],
                  maxLength: 19,
                  decoration: _decoration('16-digit card number', Icons.credit_card)
                      .copyWith(counterText: ''),
                  validator: _validateCardNumber,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                        ],
                        maxLength: 5,
                        decoration: _decoration('Expiry (MM/YY)', Icons.date_range)
                            .copyWith(counterText: ''),
                        validator: _validateExpiry,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        obscureText: true,
                        maxLength: 4,
                        decoration: _decoration('CVV', Icons.lock_outline)
                            .copyWith(counterText: ''),
                        validator: _validateCvv,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSaving ? null : _saveCard,
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : const Text('Save card'),
                ),
              ],
            ),
          ),
        ),
      );
}
