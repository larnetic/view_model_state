import 'dart:async' show StreamController;

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter_test/flutter_test.dart';
import 'package:view_model_state/view_model_state.dart';

final controller = StreamController<int>();
final stream = Stream<int>.empty();

class TestViewModel extends ViewModel {
  late final streamState = createStateFromStream(controller.stream, 0);
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
}
