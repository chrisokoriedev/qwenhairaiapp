import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ConnectivityStatus { online, offline }

/// Streams online/offline status derived from connectivity_plus.
class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  ConnectivityCubit(this._connectivity) : super(ConnectivityStatus.online);

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void start() {
    _subscription = _connectivity.onConnectivityChanged.listen(_emit);
    // Seed with current state.
    _connectivity.checkConnectivity().then(_emit);
  }

  void _emit(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    emit(online ? ConnectivityStatus.online : ConnectivityStatus.offline);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
