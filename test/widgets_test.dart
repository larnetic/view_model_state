import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:view_model_state/view_model_state.dart';

class TestViewModel extends ViewModel {
  late final counter = createMutableState(42);
}

class TestViewModelWidget extends ViewModelWidget<TestViewModel> {
  TestViewModelWidget({super.key, required super.create});

  late final localCounter = createMutableState(42);

  @override
  Widget build(BuildContext context, TestViewModel viewModel) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text('Counter: ${viewModel.counter.value}'),
            TextButton(onPressed: () => viewModel.counter.value++, child: const Text('Increment')),
            Text('Local counter: ${localCounter.value}'),
            TextButton(onPressed: () => localCounter.value++, child: const Text('Increment (local)')),
          ],
        ),
      ),
    );
  }
}

class TestStateScopeWidget extends StateScopeWidget {
  late final localCounter = createMutableState(42);

  TestStateScopeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text('Counter: ${localCounter.value}'),
            TextButton(onPressed: () => localCounter.value++, child: const Text('Increment')),
          ],
        ),
      ),
    );
  }
}

void main() {
  group("ViewModelWidget", () {
    testWidgets("ViewModelWidget displays initial counter values", (tester) async {
      await tester.pumpWidget(TestViewModelWidget(create: () => TestViewModel()));
      expect(find.text('Counter: 42'), findsOneWidget);
      expect(find.text('Local counter: 42'), findsOneWidget);
    });

    testWidgets("ViewModelWidget increments counter value", (tester) async {
      await tester.pumpWidget(TestViewModelWidget(create: () => TestViewModel()));
      await tester.tap(find.text('Increment'));
      await tester.pump(); // Rebuild the widget after state change
      expect(find.text('Counter: 43'), findsOneWidget);
    });

    testWidgets("ViewModelWidget increments local counter value", (tester) async {
      await tester.pumpWidget(TestViewModelWidget(create: () => TestViewModel()));
      await tester.tap(find.text('Increment (local)'));
      await tester.pump(); // Rebuild the widget after state change
      expect(find.text('Local counter: 43'), findsOneWidget);
    });

    testWidgets("ViewModelWidget increments counter value multiple times", (tester) async {
      await tester.pumpWidget(TestViewModelWidget(create: () => TestViewModel()));
      await tester.tap(find.text('Increment'));
      await tester.pump();
      await tester.tap(find.text('Increment'));
      await tester.pump();
      expect(find.text('Counter: 44'), findsOneWidget);
    });

    testWidgets("ViewModelWidget increments local counter value multiple times", (tester) async {
      await tester.pumpWidget(TestViewModelWidget(create: () => TestViewModel()));
      await tester.tap(find.text('Increment (local)'));
      await tester.pump();
      await tester.tap(find.text('Increment (local)'));
      await tester.pump();
      expect(find.text('Local counter: 44'), findsOneWidget);
    });

    testWidgets("ViewModelWidget increments both counters", (tester) async {
      await tester.pumpWidget(TestViewModelWidget(create: () => TestViewModel()));
      await tester.tap(find.text('Increment'));
      await tester.pump();
      await tester.tap(find.text('Increment (local)'));
      await tester.pump();
      expect(find.text('Counter: 43'), findsOneWidget);
      expect(find.text('Local counter: 43'), findsOneWidget);
    });

    testWidgets("ViewModelWidget maintains ViewModel state across rebuilds", (tester) async {
      final viewModel = TestViewModel();
      await tester.pumpWidget(TestViewModelWidget(create: () => viewModel));
      await tester.tap(find.text('Increment'));
      await tester.pump();
      await tester.tap(find.text('Increment (local)'));
      await tester.pump();
      await tester.pumpWidget(TestViewModelWidget(create: () => viewModel)); // Rebuild
      expect(find.text('Counter: 43'), findsOneWidget);
      expect(find.text('Local counter: 42'), findsOneWidget);
    });

    testWidgets("ViewModelWidget maintains ViewModel state across dispose", (tester) async {
      final viewModel = TestViewModel();
      await tester.pumpWidget(TestViewModelWidget(create: () => viewModel));
      await tester.tap(find.text('Increment'));
      await tester.pump();
      await tester.tap(find.text('Increment (local)'));
      await tester.pumpAndSettle();
      // Unmount previous widget
      await tester.pumpWidget(Container());
      // Remount same instance of ViewModel
      await tester.pumpWidget(TestViewModelWidget(create: () => viewModel));
      await tester.pumpAndSettle();
      expect(find.text('Counter: 43'), findsOneWidget);
      expect(find.text('Local counter: 42'), findsOneWidget);
    });

    testWidgets("ViewModelWidget resets state with new ViewModel instance", (tester) async {
      await tester.pumpWidget(TestViewModelWidget(create: () => TestViewModel()));
      await tester.tap(find.text('Increment'));
      await tester.pump();
      await tester.tap(find.text('Increment (local)'));
      await tester.pumpAndSettle();
      // Unmount previous widget
      await tester.pumpWidget(Container());
      // New instance of ViewModel
      await tester.pumpWidget(TestViewModelWidget(create: () => TestViewModel()));
      await tester.pumpAndSettle();
      expect(find.text('Counter: 42'), findsOneWidget);
      expect(find.text('Local counter: 42'), findsOneWidget);
    });
  });

  group("StateScopeWidget", () {
    testWidgets("StateScopeWidget displays initial counter value", (tester) async {
      await tester.pumpWidget(TestStateScopeWidget());
      expect(find.text('Counter: 42'), findsOneWidget);
    });

    testWidgets("StateScopeWidget increments counter value", (tester) async {
      await tester.pumpWidget(TestStateScopeWidget());
      await tester.tap(find.text('Increment'));
      await tester.pump(); // Rebuild the widget after state change
      expect(find.text('Counter: 43'), findsOneWidget);
    });

    testWidgets("StateScopeWidget increments counter value multiple times", (tester) async {
      await tester.pumpWidget(TestStateScopeWidget());
      await tester.tap(find.text('Increment'));
      await tester.pump();
      await tester.tap(find.text('Increment'));
      await tester.pump();
      expect(find.text('Counter: 44'), findsOneWidget);
    });

    testWidgets("StateScopeWidget maintains state across rebuilds", (tester) async {
      await tester.pumpWidget(TestStateScopeWidget());
      await tester.tap(find.text('Increment'));
      await tester.pump();
      await tester.pumpWidget(TestStateScopeWidget()); // Rebuild
      expect(find.text('Counter: 42'), findsOneWidget); // State is reset
    });

    testWidgets("StateScopeWidget resets state on dispose", (tester) async {
      await tester.pumpWidget(TestStateScopeWidget());
      await tester.tap(find.text('Increment'));
      await tester.pumpAndSettle();
      // Unmount previous widget
      await tester.pumpWidget(Container());
      // Remount StateScopeWidget
      await tester.pumpWidget(TestStateScopeWidget());
      await tester.pumpAndSettle();
      expect(find.text('Counter: 42'), findsOneWidget); // State is reset
    });
  });
}
