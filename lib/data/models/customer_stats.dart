import 'package:flutter/material.dart';

class CustomerStats {
  final double willGive;
  final double willGet;
  final double qrCollections;

  CustomerStats({
    required this.willGive,
    required this.willGet,
    required this.qrCollections,
  });
}

// Provider for managing customer statistics
class CustomerStatsProvider extends ChangeNotifier {
  CustomerStats _stats = CustomerStats(
    willGive: 0,
    willGet: 0,
    qrCollections: 0,
  );

  CustomerStats get stats => _stats;

  // Update stats from database or API
  Future<void> fetchStats() async {
    // Simulate API call or database query
    await Future.delayed(const Duration(milliseconds: 500));


    _stats = CustomerStats(
      willGive: 1250.0,  // Example values
      willGet: 5400.0,   // Replace with real data from your backend
      qrCollections: 750.0,
    );

    notifyListeners();
  }

  // Update individual stat values (can be called after transactions)
  void updateWillGive(double amount) {
    _stats = CustomerStats(
      willGive: amount,
      willGet: _stats.willGet,
      qrCollections: _stats.qrCollections,
    );
    notifyListeners();
  }

  void updateWillGet(double amount) {
    _stats = CustomerStats(
      willGive: _stats.willGive,
      willGet: amount,
      qrCollections: _stats.qrCollections,
    );
    notifyListeners();
  }

  void updateQrCollections(double amount) {
    _stats = CustomerStats(
      willGive: _stats.willGive,
      willGet: _stats.willGet,
      qrCollections: amount,
    );
    notifyListeners();
  }
}