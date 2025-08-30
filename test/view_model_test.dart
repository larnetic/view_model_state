import 'dart:async' show StreamController;

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter_test/flutter_test.dart';
import 'package:view_model_state/view_model_state.dart';

final controller = StreamController<int>();
final stream = Stream<int>.empty();

class TestViewModel extends ViewModel {
  late final streamState = createStateFromStream(controller.stream, 0);
  late final mutableState = createMutableState(0);

  var onUpdateCallCount = 0;

  @override
  void onUpdate() {
    onUpdateCallCount++;
    super.onUpdate();
  }
}

void main() {
  group("Test disposal", () {
    test("Listeners for Streams are removed", () {
      controller.addStream(stream);
      final viewModel = TestViewModel();
      expect(viewModel.streamState.value, 0);
      expect(controller.hasListener, isTrue);
      viewModel.dispose();
      expect(controller.hasListener, isFalse);
    });

    test("Listeners for ValueNotifiers are removed", () {
      final viewModel = TestViewModel();
      final notifier = ValueNotifier<int>(0);
      final state = viewModel.createStateFromValueNotifier(notifier);
      expect(state.value, 0);
      // ignore: invalid_use_of_protected_member
      expect(notifier.hasListeners, isTrue);
      viewModel.dispose();
      // ignore: invalid_use_of_protected_member
      expect(notifier.hasListeners, isFalse);
    });

    test("Disposing ViewModel multiple times throws an error", () {
      final viewModel = TestViewModel();
      viewModel.dispose();
      expect(() => viewModel.dispose(), throwsA(isA<Error>()));
    });
  });

  group("Test self update", () {
    test("onUpdate is called on notifyListeners", () {
      final viewModel = TestViewModel();
      expect(viewModel.onUpdateCallCount, 0);
      viewModel.notifyListeners();
      expect(viewModel.onUpdateCallCount, 1);
      viewModel.notifyListeners();
      expect(viewModel.onUpdateCallCount, 2);
    });

    test("onUpdate is called on mutable state mutation", () {
      final viewModel = TestViewModel();
      expect(viewModel.onUpdateCallCount, 0);
      viewModel.mutableState.value = 1;
      expect(viewModel.onUpdateCallCount, 1);
    });

    test("onUpdate is called on ValueNotifier change", () {
      final viewModel = TestViewModel();
      final notifier = ValueNotifier<int>(0);
      final state = viewModel.createStateFromValueNotifier(notifier);
      expect(state.value, 0);
      expect(viewModel.onUpdateCallCount, 0);
      notifier.value = 2;
      expect(viewModel.onUpdateCallCount, 1);
    });

    test("onUpdate is called on Stream change", () async {
      final viewModel = TestViewModel();
      final stream = Stream<int>.fromIterable([1, 2, 3]);
      final state = viewModel.createStateFromStream(stream, 0);
      expect(state.value, 0);
      expect(viewModel.onUpdateCallCount, 0);
      await Future.delayed(Duration.zero);
      expect(state.value, 3);
      expect(viewModel.onUpdateCallCount, 3);
    });

    test("onUpdate is called on future change", () async {
      final viewModel = TestViewModel();
      final future = Future<int>.delayed(Duration.zero, () => 42);
      final state = viewModel.createStateFromFuture(future, 0);
      expect(state.value, 0);
      expect(viewModel.onUpdateCallCount, 0);
      await Future.delayed(Duration.zero);
      expect(state.value, 42);
      expect(viewModel.onUpdateCallCount, 1);
    });

    test("onUpdate is called on multiple state changes", () async {
      final viewModel = TestViewModel();
      final stream = Stream<int>.fromIterable([1, 2, 3]);
      final future = Future<int>.delayed(Duration.zero, () => 42);
      final notifier = ValueNotifier<int>(0);
      final state1 = viewModel.createStateFromStream(stream, 0);
      final state2 = viewModel.createStateFromFuture(future, 0);
      final state3 = viewModel.createStateFromValueNotifier(notifier);
      expect(state1.value, 0);
      expect(state2.value, 0);
      expect(state3.value, 0);
      expect(viewModel.onUpdateCallCount, 0);
      await Future.delayed(Duration.zero);
      expect(state1.value, 3);
      expect(state2.value, 42);
      expect(state3.value, 0);
      expect(viewModel.onUpdateCallCount, 4);
      notifier.value = 5;
      expect(state3.value, 5);
      expect(viewModel.onUpdateCallCount, 5);
    });

    test("onUpdate is not called on dispose", () {
      final viewModel = TestViewModel();
      expect(viewModel.onUpdateCallCount, 0);
      viewModel.dispose();
      expect(viewModel.onUpdateCallCount, 0);
    });
  });
}
