import 'package:flutter/material.dart';

import '../models/parcel.dart';
import '../services/local_storage.dart';

class HomeScreen extends StatefulWidget {
  final String phone;

  const HomeScreen({
    super.key,
    this.phone = '',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalStorage storage = LocalStorage();

  final TextEditingController quantityController =
  TextEditingController();

  final TextEditingController rateController =
  TextEditingController();

  List<Parcel> allParcels = [];

  DateTime selectedDate = DateTime.now();

  DateTime? customStartDate;
  DateTime? customEndDate;

  String selectedFilter = 'All Time';

  double rate = LocalStorage.defaultRate;

  bool isLoading = true;
  bool isSaving = false;
  bool isUpdatingRate = false;

  final List<String> filters = [
    'All Time',
    'Today',
    'Last 7 Days',
    'Last 30 Days',
    'This Month',
    'Last Month',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    quantityController.dispose();
    rateController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    final data = await storage.getParcels();
    final savedRate = await storage.getParcelRate();

    if (!mounted) return;

    setState(() {
      allParcels = data;
      rate = savedRate;
      rateController.text = savedRate.toString();
      isLoading = false;
    });
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> selectParcelDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
      customStartDate != null && customEndDate != null
          ? DateTimeRange(
        start: customStartDate!,
        end: customEndDate!,
      )
          : null,
    );

    if (picked != null) {
      setState(() {
        customStartDate = dateOnly(picked.start);
        customEndDate = dateOnly(picked.end);
        selectedFilter = 'Custom';
      });
    }
  }

  List<Parcel> get filteredParcels {
    final today = dateOnly(DateTime.now());

    DateTime? start;
    DateTime? end;

    switch (selectedFilter) {
      case 'Today':
        start = today;
        end = today;
        break;

      case 'Last 7 Days':
        start = today.subtract(const Duration(days: 6));
        end = today;
        break;

      case 'Last 30 Days':
        start = today.subtract(const Duration(days: 29));
        end = today;
        break;

      case 'This Month':
        start = DateTime(today.year, today.month, 1);
        end = today;
        break;

      case 'Last Month':
        start = DateTime(today.year, today.month - 1, 1);
        end = DateTime(today.year, today.month, 0);
        break;

      case 'Custom':
        start = customStartDate;
        end = customEndDate;
        break;

      case 'All Time':
      default:
        return List.from(allParcels);
    }

    if (start == null || end == null) {
      return [];
    }

    return allParcels.where((parcel) {
      final parcelDate = dateOnly(parcel.date);

      return !parcelDate.isBefore(start!) &&
          !parcelDate.isAfter(end!);
    }).toList();
  }

  int get allTimeCount {
    return allParcels.fold(
      0,
          (sum, parcel) => sum + parcel.parcelCount,
    );
  }

  double get allTimeAmount {
    return allParcels.fold(
      0.0,
          (sum, parcel) => sum + parcel.totalAmount,
    );
  }

  int get filteredCount {
    return filteredParcels.fold(
      0,
          (sum, parcel) => sum + parcel.parcelCount,
    );
  }

  double get filteredAmount {
    return filteredParcels.fold(
      0.0,
          (sum, parcel) => sum + parcel.totalAmount,
    );
  }

  void showMessage(
      String message, {
        Color color = Colors.red,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // Update universal rate
  Future<void> updateUniversalRate() async {
    final newRate = double.tryParse(
      rateController.text.trim(),
    );

    if (newRate == null || newRate <= 0) {
      showMessage('Please enter a valid rate');
      return;
    }

    setState(() {
      isUpdatingRate = true;
    });

    try {
      await storage.setParcelRate(newRate);

      await loadData();

      if (!mounted) return;

      showMessage(
        'Universal rate updated. All parcel amounts recalculated!',
        color: Colors.green,
      );
    } catch (e) {
      if (mounted) {
        showMessage('Error updating rate: $e');
      }
    }

    if (mounted) {
      setState(() {
        isUpdatingRate = false;
      });
    }
  }

  Future<void> saveParcels() async {
    final count = int.tryParse(
      quantityController.text.trim(),
    );

    if (count == null || count <= 0) {
      showMessage('Please enter a valid parcel quantity');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await storage.addDailyParcels(
        date: selectedDate,
        count: count,
      );

      quantityController.clear();

      await loadData();

      if (!mounted) return;

      showMessage(
        '$count parcels saved successfully',
        color: Colors.green,
      );
    } catch (e) {
      if (mounted) {
        showMessage('Error: $e');
      }
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  Future<void> deleteParcel(Parcel parcel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record?'),
        content: Text(
          'Delete parcel record of ${formatDate(parcel.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await storage.removeParcel(parcel.id);
      await loadData();

      if (mounted) {
        showMessage('Record deleted', color: Colors.green);
      }
    }
  }

  Widget summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 27),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              FittedBox(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget filterButton(String filter) {
    final isSelected = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(filter),
        selected: isSelected,
        selectedColor: Colors.blue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) async {
          if (filter == 'Custom') {
            await selectCustomRange();
          } else {
            setState(() {
              selectedFilter = filter;
            });
          }
        },
      ),
    );
  }

  Widget parcelHistoryCard(Parcel parcel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.12),
          child: const Icon(
            Icons.local_shipping,
            color: Colors.blue,
          ),
        ),
        title: Text(
          formatDate(parcel.date),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${parcel.parcelCount} Parcels × ${formatAmount(rate)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatAmount(parcel.totalAmount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 14,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              onPressed: () => deleteParcel(parcel),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quantity =
        int.tryParse(quantityController.text.trim()) ?? 0;

    final previewAmount = quantity * rate;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mayur Bambhanya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Overall Summary',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                summaryCard(
                  title: 'Total Parcels',
                  value: allTimeCount.toString(),
                  icon: Icons.inventory_2,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                summaryCard(
                  title: 'Total Amount',
                  value: formatAmount(allTimeAmount),
                  icon: Icons.currency_rupee,
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Universal Rate Setting
            const Text(
              'Universal Parcel Rate',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set rate per parcel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: rateController,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.currency_rupee),
                        hintText: 'Example: 12.5',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: isUpdatingRate
                            ? null
                            : updateUniversalRate,
                        icon: const Icon(Icons.currency_exchange),
                        label: Text(
                          isUpdatingRate
                              ? 'Updating...'
                              : 'Update Universal Rate',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Current rate: ${formatAmount(rate)} per parcel',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Changing the rate will automatically update all old and new parcel amounts.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Add Daily Parcels',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    OutlinedButton.icon(
                      onPressed: selectParcelDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(formatDate(selectedDate)),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Enter Total Parcels',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Example: 100',
                        prefixIcon: Icon(Icons.inventory),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rate: ${formatAmount(rate)} / parcel',
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Total Amount: ${formatAmount(previewAmount)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : saveParcels,
                        icon: const Icon(Icons.save),
                        label: Text(
                          isSaving ? 'Saving...' : 'Save Parcels',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Parcel History',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map(filterButton).toList(),
              ),
            ),

            if (selectedFilter == 'Custom' &&
                customStartDate != null &&
                customEndDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${formatDate(customStartDate!)} - ${formatDate(customEndDate!)}',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtered Parcels: $filteredCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Filtered Amount: ${formatAmount(filteredAmount)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            if (filteredParcels.isEmpty)
              const Padding(
                padding: EdgeInsets.all(25),
                child: Center(
                  child: Text(
                    'No parcel records found for this filter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...filteredParcels.map(parcelHistoryCard),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}