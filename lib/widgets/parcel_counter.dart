
import 'package:flutter/material.dart';

class ParcelCounter extends StatelessWidget {
  final int totalParcels;
  final VoidCallback onAddParcel;
  final VoidCallback onUndo;

  const ParcelCounter({
    super.key,
    required this.totalParcels,
    required this.onAddParcel,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Total Delivered Parcels',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '$totalParcels',
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Blue Add Parcel Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddParcel,
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: const Text(
                  'Add Delivered Parcel',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Undo Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: totalParcels > 0 ? onUndo : null,
                icon: const Icon(Icons.undo),
                label: const Text('Undo Last Parcel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
