
import 'package:flutter/material.dart';

class EarningsCard extends StatelessWidget {
  final double totalEarnings;
  final double todayEarnings;
  final double parcelRate;

  const EarningsCard({
    super.key,
    required this.totalEarnings,
    required this.todayEarnings,
    required this.parcelRate,
  });

  String money(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total Earnings'),
            const SizedBox(height: 8),
            Text(
              money(totalEarnings),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Today Earnings'),
                Text(
                  money(todayEarnings),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Parcel Rate'),
                Text(
                  money(parcelRate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
