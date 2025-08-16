// lib/data/services/connectivity_service.dart

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'data_sync_services.dart';

class ConnectivityService {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  final _dataSyncService = DataSyncService();
  bool _isOnline = false;

  void startListening() {
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool newIsOnline = results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);

      if (newIsOnline && !_isOnline) {
        // The user just came back online.
        print("Device is back online. Syncing pending data...");
        _dataSyncService.syncPendingData();
      }
      _isOnline = newIsOnline;
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}