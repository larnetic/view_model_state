import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:view_model_state/view_model_state.dart';

class TestViewModel extends ViewModel {
  late final counter = createMutableState(0);
}

class TestViewModelWidget extends ViewModelWidget<TestViewModel> {
  const TestViewModelWidget({super.key, required super.create});

  @override
  Widget build(BuildContext context, TestViewModel viewModel) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text('Counter: ${viewModel.counter.value}'),
            TextButton(onPressed: () => viewModel.counter.value++, child: const Text('Increment')),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets("ViewModelWidget displays initial counter value", (tester) async {
    await tester.pumpWidget(TestViewModelWidget(create: () => TestViewModel()));
    expect(find.text('Counter: 0'), findsOneWidget);
  });

  testWidgets("ViewModelWidget increments counter value", (tester) async {
    await tester.pumpWidget(TestViewModelWidget(create: () => TestViewModel()));
    await tester.tap(find.text('Increment'));
    await tester.pump(); // Rebuild the widget after state change
    expect(find.text('Counter: 1'), findsOneWidget);
  });

  testWidgets("ViewModelWidget increments counter value multiple times", (tester) async {
    await tester.pumpWidget(TestViewModelWidget(create: () => TestViewModel()));
    await tester.tap(find.text('Increment'));
    await tester.pump();
    await tester.tap(find.text('Increment'));
    await tester.pump();
    expect(find.text('Counter: 2'), findsOneWidget);
  });

  testWidgets("ViewModelWidget maintains state across rebuilds", (tester) async {
    final viewModel = TestViewModel();
    await tester.pumpWidget(TestViewModelWidget(create: () => viewModel));
    await tester.tap(find.text('Increment'));
    await tester.pump();
    await tester.pumpWidget(TestViewModelWidget(create: () => viewModel)); // Rebuild
    expect(find.text('Counter: 1'), findsOneWidget);
  });

  testWidgets("ViewModelWidget resets state with new ViewModel instance", (tester) async {
    await tester.pumpWidget(TestViewModelWidget(create: () => TestViewModel()));
    await tester.tap(find.text('Increment'));
    await tester.pumpAndSettle();
    expect(find.text('Counter: 1'), findsOneWidget);
    // Unmount previous widget
    await tester.pumpWidget(Container());
    // New instance of ViewModel
    await tester.pumpWidget(TestViewModelWidget(create: () => TestViewModel()));
    await tester.pumpAndSettle();
    expect(find.text('Counter: 0'), findsOneWidget);
  });
}
