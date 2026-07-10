import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/connectivity/connectivity_cubit.dart';

void main() {
  test('initial state defaults to online', () {
    final cubit = ConnectivityCubit(Connectivity());
    expect(cubit.state, ConnectivityStatus.online);
  });
}
