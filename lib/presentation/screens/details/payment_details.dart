import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentDetailsScreen extends StatelessWidget {
  final String? payee;
  final double? amount;
  final String? currency;
  final String? paymentUri; // e.g., UPI or payment deep link

  const PaymentDetailsScreen({
    super.key,
    this.payee,
    this.amount,
    this.currency,
    this.paymentUri,
  });

  Future<void> _redirectToPaymentApp() async {
    final Uri paymentUriObj = Uri.parse(
      paymentUri!,
    ); // Make sure paymentUri is a String

    if (await canLaunchUrl(paymentUriObj)) {
      await launchUrl(paymentUriObj);
    } else {
      throw 'Could not launch $paymentUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payee: $payee', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                      'Amount: $currency ${amount?.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text('Proceed to Pay'),
                onPressed: _redirectToPaymentApp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
