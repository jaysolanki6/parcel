
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/parcel.dart';

class ParcelHistoryItem extends StatelessWidget {
  final Parcel parcel;

  const ParcelHistoryItem({
    super.key,
    required this.parcel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.local_shipping),
        ),
        title: const Text('Parcel Delivered'),
        subtitle: Text(
          DateFormat('dd MMM yyyy, hh:mm a').format(parcel.date),
        ),
        trailing: const Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
      ),
    );
  }
}
