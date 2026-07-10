import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qwenhairaiapp/core/design_system/components/home_shell.dart';
import 'package:qwenhairaiapp/core/design_system/connectivity/connectivity_cubit.dart';

void main() {
  testWidgets('renders 5 navigation destinations', (tester) async {
    final shell = _FakeNavigationShell(currentIndex: 0);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ConnectivityCubit>(
          create: (_) => ConnectivityCubit(_FakeConnectivity()),
          child: HomeShell(navigationShell: shell),
        ),
      ),
    );
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Try-On'), findsOneWidget);
    expect(find.text('Diagnostics'), findsOneWidget);
    expect(find.text('Coaching'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('tapping a destination calls goBranch', (tester) async {
    final shell = _FakeNavigationShell(currentIndex: 0);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ConnectivityCubit>(
          create: (_) => ConnectivityCubit(_FakeConnectivity()),
          child: HomeShell(navigationShell: shell),
        ),
      ),
    );
    await tester.tap(find.text('Coaching'));
    await tester.pumpAndSettle();
    expect(shell.goBranchCalls, contains(3));
  });
}

class _FakeNavigationShell extends StatefulWidget implements StatefulNavigationShell {
  _FakeNavigationShell({required this.currentIndex});

  @override
  final int currentIndex;
  final List<int> goBranchCalls = [];

  @override
  void goBranch(int index, {bool initialLocation = false}) {
    goBranchCalls.add(index);
  }

  Widget build(BuildContext context, Widget Function(int) navigatorBuilder) {
    return const SizedBox();
  }

  @override
  State<StatefulWidget> createState() => _FakeNavigationShellState();

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNavigationShellState extends State<_FakeNavigationShell> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class _FakeConnectivity implements Connectivity {
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.wifi];

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
