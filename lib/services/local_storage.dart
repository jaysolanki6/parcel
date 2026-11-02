import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/parcel.dart';

class LocalStorage {
  static const String _parcelKey = 'daily_parcel_records';
  static const String _phoneKey = 'user_phone';
  static const String _rateKey = 'universal_parcel_rate';

  static const double defaultRate = 12.0;

  // Get all parcel records
  Future<List<Parcel>> getParcels() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_parcelKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(data);

      final parcels = decoded.map((item) {
        return Parcel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();

      parcels.sort((a, b) => b.date.compareTo(a.date));

      return parcels;
    } catch (e) {
      return [];
    }
  }

  // Get universal parcel rate
  Future<double> getParcelRate() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getDouble(_rateKey) ?? defaultRate;
  }

  // Change universal rate and update all old records
  Future<void> setParcelRate(double newRate) async {
    if (newRate <= 0) {
      throw Exception('Rate must be greater than zero');
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble(_rateKey, newRate);

    final parcels = await getParcels();

    final updatedParcels = parcels.map((parcel) {
      return Parcel(
        id: parcel.id,
        date: parcel.date,
        parcelCount: parcel.parcelCount,
        totalAmount: parcel.parcelCount * newRate,
      );
    }).toList();

    await prefs.setString(
      _parcelKey,
      jsonEncode(
        updatedParcels.map((parcel) => parcel.toJson()).toList(),
      ),
    );
  }

  // Add parcels to selected date
  Future<void> addDailyParcels({
    required DateTime date,
    required int count,
  }) async {
    if (count <= 0) {
      throw Exception('Parcel quantity must be greater than zero');
    }

    final prefs = await SharedPreferences.getInstance();

    final parcels = await getParcels();
    final currentRate = await getParcelRate();

    final selectedDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final id =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    final index = parcels.indexWhere(
          (parcel) => parcel.id == id,
    );

    if (index != -1) {
      final oldParcel = parcels[index];
      final newCount = oldParcel.parcelCount + count;

      parcels[index] = Parcel(
        id: id,
        date: selectedDate,
        parcelCount: newCount,
        totalAmount: newCount * currentRate,
      );
    } else {
      parcels.add(
        Parcel(
          id: id,
          date: selectedDate,
          parcelCount: count,
          totalAmount: count * currentRate,
        ),
      );
    }

    parcels.sort((a, b) => b.date.compareTo(a.date));

    await prefs.setString(
      _parcelKey,
      jsonEncode(
        parcels.map((parcel) => parcel.toJson()).toList(),
      ),
    );
  }

  // Delete daily record
  Future<void> removeParcel(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final parcels = await getParcels();

    parcels.removeWhere((parcel) => parcel.id == id);

    await prefs.setString(
      _parcelKey,
      jsonEncode(
        parcels.map((parcel) => parcel.toJson()).toList(),
      ),
    );
  }

  // Login phone methods - STATIC
  static Future<void> savePhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phone);
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneKey);
  }
}