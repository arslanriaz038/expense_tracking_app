import 'dart:async';

import 'package:expense_tracking_app/utils/network_status.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Uploads queued receipt images when the device comes back online.
class ConnectivitySyncListener extends StatefulWidget {
  const ConnectivitySyncListener({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivitySyncListener> createState() =>
      _ConnectivitySyncListenerState();
}

class _ConnectivitySyncListenerState extends State<ConnectivitySyncListener> {
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = NetworkStatus.onConnectivityChanged.listen((online) {
      if (online && mounted) {
        context.read<ExpensesCubit>().syncPendingReceipts();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
