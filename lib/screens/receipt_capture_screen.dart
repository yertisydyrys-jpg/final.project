import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/finance_transaction.dart';
import '../providers/finance_provider.dart';
import '../services/receipt_scanner_service.dart';
import 'card_management_screen.dart';

class ReceiptCaptureScreen extends ConsumerStatefulWidget {
  const ReceiptCaptureScreen({super.key});

  @override
  ConsumerState<ReceiptCaptureScreen> createState() =>
      _ReceiptCaptureScreenState();
}

class _ReceiptCaptureScreenState extends ConsumerState<ReceiptCaptureScreen> {
  final _picker = ImagePicker();
  final _scanner = ReceiptScannerService();
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  Uint8List? _imageBytes;
  DateTime? _transactionDate;
  TransactionType _type = TransactionType.expense;
  String? _selectedCardId;
  bool _isScanning = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2200,
      );
      if (image == null) return;
      setState(() {
        _isScanning = true;
        _imageBytes = null;
        _merchantController.clear();
        _amountController.clear();
        _transactionDate = null;
      });
      final bytes = await image.readAsBytes();
      final result = await _scanner.scanReceipt(image);
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _merchantController.text = result.merchant;
        _amountController.text = result.amount.toStringAsFixed(2);
        _transactionDate = result.date;
        _type = result.type;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not scan receipt: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _transactionDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
    );
    if (selected != null) setState(() => _transactionDate = selected);
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCardId == null || _transactionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a card and scan a receipt first.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(financeProvider.notifier)
          .addTransaction(
            cardId: _selectedCardId!,
            merchant: _merchantController.text,
            amount: double.parse(_amountController.text),
            date: _transactionDate!,
            type: _type,
          );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save transaction: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _dateLabel(DateTime? date) {
    if (date == null) return 'Choose transaction date';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financeProvider);
    if (state.cards.isNotEmpty &&
        !state.cards.any((card) => card.id == _selectedCardId)) {
      _selectedCardId = state.cards.first.id;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Scan receipt')),
      body: state.cards.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Add a card before saving a receipt transaction.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CardManagementScreen(),
                        ),
                      ),
                      child: const Text('Manage cards'),
                    ),
                  ],
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isScanning
                              ? null
                              : () => _pickReceipt(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Take photo'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isScanning
                              ? null
                              : () => _pickReceipt(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Upload'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isScanning)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Analyzing receipt…'),
                          ],
                        ),
                      ),
                    )
                  else if (_imageBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _imageBytes!,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 140,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Take a photo or select a receipt image.',
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'Demo OCR result — verify every field before saving.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_selectedCardId),
                    initialValue: _selectedCardId,
                    decoration: const InputDecoration(
                      labelText: 'Link to card',
                      border: OutlineInputBorder(),
                    ),
                    items: state.cards
                        .map(
                          (card) => DropdownMenuItem(
                            value: card.id,
                            child: Text(
                              '${card.bankName} •••• ${card.lastFourDigits}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCardId = value),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _merchantController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Merchant',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Enter the merchant name.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final amount = double.tryParse(value ?? '');
                      return amount == null || amount <= 0 || !amount.isFinite
                          ? 'Enter a valid amount greater than zero.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(_dateLabel(_transactionDate)),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<TransactionType>(
                    initialValue: _type,
                    decoration: const InputDecoration(
                      labelText: 'Transaction type',
                      border: OutlineInputBorder(),
                    ),
                    items: TransactionType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _type = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isSaving || _isScanning
                        ? null
                        : _saveTransaction,
                    icon: const Icon(Icons.save_outlined),
                    label: _isSaving
                        ? const Text('Saving…')
                        : const Text('Save transaction'),
                  ),
                ],
              ),
            ),
    );
  }
}
