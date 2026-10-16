import 'package:flutter/material.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Help and support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Support',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(color: accentColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('Need help? Start here', textAlign: TextAlign.center),
            const SizedBox(height: 28),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_reset_outlined),
                    title: const Text('About reset account password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Reset your account password'),
                        content: const Text(
                          'To reset your password, open the sign-in screen '
                          'and choose “Forgot password?”. Follow the '
                          'instructions sent to your registered email.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.credit_card_outlined),
                    title: const Text('Billing and Subscriptions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const BillingSubscriptionsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BillingSubscriptionsScreen extends StatelessWidget {
  const BillingSubscriptionsScreen({super.key});

  static const _topics = [
    ('Request a refund', Icons.currency_exchange_outlined),
    ('View your purchase history', Icons.receipt_long_outlined),
    ('Manage your payment information', Icons.payment_outlined),
    ("If you're unable to make purchases", Icons.shopping_cart_outlined),
    ("If you don't recognize a charge", Icons.report_gmailerrorred_outlined),
    ('Access purchases across all your devices', Icons.devices_outlined),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Billing and Subscriptions')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Billing and Subscriptions',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a topic to find help with your purchases and payment details.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < _topics.length; index++) ...[
                if (index > 0) const Divider(height: 1),
                ListTile(
                  leading: Icon(_topics[index].$2),
                  title: Text(_topics[index].$1),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
