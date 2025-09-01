import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:test/test.dart';
import 'package:view_model_state/view_model_state.dart';

class TestViewModel extends ViewModel {}

void main() {
  group("Test primitive mutable state", () {
    test("Value should initialize to 0", () {
      final viewModel = TestViewModel();
      final counter = viewModel.createMutableState(0);
      expect(counter.value, 0);
    });

    test("Value should be incremented", () {
      final viewModel = TestViewModel();
      final counter = viewModel.createMutableState(0);
      counter.value++;
      expect(counter.value, 1);
    });

    test("Value should be decremented", () {
      final viewModel = TestViewModel();
      final counter = viewModel.createMutableState(0);
      counter.value--;
      expect(counter.value, -1);
    });

    test("Value should stay the same after inc + dec", () {
      final viewModel = TestViewModel();
      final counter = viewModel.createMutableState(0);
      counter.value++;
      counter.value--;
      expect(counter.value, 0);
    });
  });

  group("Test list mutable state", () {
    test("List should initialize empty", () {
      final viewModel = TestViewModel();
      final list = viewModel.createMutableStateList<String>();
      expect(list, isEmpty);
    });

    test("List should initialize with values", () {
      final viewModel = TestViewModel();
      final list = viewModel.createMutableStateList<String>(["item1", "item2"]);
      expect(list, ["item1", "item2"]);
    });

    test("List should add an item", () {
      final viewModel = TestViewModel();
      final list = viewModel.createMutableStateList<String>();
      list.add("item1");
      expect(list, ["item1"]);
    });

    test("List should update an item", () {
      final viewModel = TestViewModel();
      final list = viewModel.createMutableStateList<String>(["item1"]);
      list[0] = "updatedItem";
      expect(list, ["updatedItem"]);
    });

    test("List should remove an item", () {
      final viewModel = TestViewModel();
      final list = viewModel.createMutableStateList<String>();
      list.addAll(["item1", "item2"]);
      list.remove("item1");
      expect(list, ["item2"]);
    });

    test("List should clear all items", () {
      final viewModel = TestViewModel();
      final list = viewModel.createMutableStateList<String>();
      list.addAll(["item1", "item2", "item3"]);
      expect(list, isNotEmpty);
      list.clear();
      expect(list, isEmpty);
    });

    test("List should contain added items", () {
      final viewModel = TestViewModel();
      final list = viewModel.createMutableStateList<String>();
      list.addAll(["item1", "item2", "item3"]);
      expect(list.contains("item1"), isTrue);
      expect(list.contains("item2"), isTrue);
      expect(list.contains("item3"), isTrue);
      expect(list.contains("item4"), isFalse);
    });

    test("List length should update correctly", () {
      final viewModel = TestViewModel();
      final list = viewModel.createMutableStateList<String>();
      expect(list.length, 0);
      list.add("item1");
      expect(list.length, 1);
      list.addAll(["item2", "item3"]);
      expect(list.length, 3);
      list.remove("item2");
      expect(list.length, 2);
      list.clear();
      expect(list.length, 0);
    });
  });

  group("Test map mutable state", () {
    test("Map should initialize empty", () {
      final viewModel = TestViewModel();
      final map = viewModel.createMutableStateMap<String, String>();
      expect(map, isEmpty);
    });

    test("Map should initialize with values", () {
      final viewModel = TestViewModel();
      final map = viewModel.createMutableStateMap<String, String>({"key1": "value1", "key2": "value2"});
      expect(map, {"key1": "value1", "key2": "value2"});
    });

    test("Map should add a key-value pair", () {
      final viewModel = TestViewModel();
      final map = viewModel.createMutableStateMap<String, String>();
      map["key1"] = "value1";
      expect(map, {"key1": "value1"});
    });

    test("Map should update a value", () {
      final viewModel = TestViewModel();
      final map = viewModel.createMutableStateMap<String, String>({"key1": "value1"});
      map["key1"] = "updatedValue";
      expect(map, {"key1": "updatedValue"});
    });

    test("Map should remove a key-value pair", () {
      final viewModel = TestViewModel();
      final map = viewModel.createMutableStateMap<String, String>({"key1": "value1", "key2": "value2"});
      map.remove("key1");
      expect(map, {"key2": "value2"});
    });

    test("Map should clear all key-value pairs", () {
      final viewModel = TestViewModel();
      final map = viewModel.createMutableStateMap<String, String>({"key1": "value1", "key2": "value2"});
      expect(map, isNotEmpty);
      map.clear();
      expect(map, isEmpty);
    });

    test("Map should contain added keys", () {
      final viewModel = TestViewModel();
      final map = viewModel.createMutableStateMap<String, String>();
      map["key1"] = "value1";
      map["key2"] = "value2";
      expect(map.containsKey("key1"), isTrue);
      expect(map.containsKey("key2"), isTrue);
      expect(map.containsKey("key3"), isFalse);
    });

    test("Map length should update correctly", () {
      final viewModel = TestViewModel();
      final map = viewModel.createMutableStateMap<String, String>();
      expect(map.length, 0);
      map["key1"] = "value1";
      expect(map.length, 1);
      map["key2"] = "value2";
      expect(map.length, 2);
      map.remove("key1");
      expect(map.length, 1);
      map.clear();
      expect(map.length, 0);
    });
  });

  group("Test state from stream", () {
    test("Periodic stream should update state", () {
      final viewModel = TestViewModel();
      final stream = Stream<int>.periodic(const Duration(milliseconds: 10), (count) => count).take(5);

      final stateFromStream = viewModel.createStateFromStream(stream, 1);

      expect(stateFromStream.value, 1);

      Future.delayed(const Duration(milliseconds: 60), () {
        expect(stateFromStream.value, 4);
      });
    });

    test("Empty stream should keep initial value", () {
      final viewModel = TestViewModel();
      final stream = Stream<int>.empty();

      final stateFromStream = viewModel.createStateFromStream(stream, 42);

      expect(stateFromStream.value, 42);
    });

    test("Stream with value should update state", () {
      final viewModel = TestViewModel();
      final stream = Stream<int>.fromIterable([10, 20, 30]);

      final stateFromStream = viewModel.createStateFromStream(stream, 0);

      expect(stateFromStream.value, 0);

      Future.delayed(const Duration(milliseconds: 10), () {
        expect(stateFromStream.value, 30);
      });
    });
  });

  group("Test state from future", () {
    test("Future should update state", () async {
      final viewModel = TestViewModel();
      final future = Future<int>.delayed(const Duration(milliseconds: 10), () => 99);

      final stateFromFuture = viewModel.createStateFromFuture(future, 0);

      expect(stateFromFuture.value, 0);

      await Future.delayed(const Duration(milliseconds: 20));
      expect(stateFromFuture.value, 99);
    });

    test("Future with immediate value should update state", () async {
      final viewModel = TestViewModel();
      final future = Future<int>.value(123);

      final stateFromFuture = viewModel.createStateFromFuture(future, 0);

      expect(stateFromFuture.value, 0);

      await Future.delayed(const Duration(milliseconds: 10));
      expect(stateFromFuture.value, 123);
    });
  });

  group("Test state from value notifier", () {
    test("ValueNotifier initial value should be used", () {
      final viewModel = TestViewModel();
      final notifier = ValueNotifier<String>("initial");

      final stateFromNotifier = viewModel.createStateFromValueNotifier(notifier);

      expect(stateFromNotifier.value, "initial");
    });
    test("ValueNotifier should update state", () {
      final viewModel = TestViewModel();
      final notifier = ValueNotifier<int>(5);

      final stateFromNotifier = viewModel.createStateFromValueNotifier(notifier);

      expect(stateFromNotifier.value, 5);

      notifier.value = 10;
      expect(stateFromNotifier.value, 10);

      notifier.value = 15;
      expect(stateFromNotifier.value, 15);
    });
    test("ValueNotifier should handle multiple updates", () {
      final viewModel = TestViewModel();
      final notifier = ValueNotifier<int>(0);

      final stateFromNotifier = viewModel.createStateFromValueNotifier(notifier);

      expect(stateFromNotifier.value, 0);

      for (int i = 1; i <= 5; i++) {
        notifier.value = i * 10;
        expect(stateFromNotifier.value, i * 10);
      }
    });
  });

  group("Test toString implementations", () {
    test("Primitive state toString", () {
      final viewModel = TestViewModel();
      final state = viewModel.createMutableState<int>(42);
      expect(state.toString(), "MutableScopedState<int>(value: 42)");
    });

    test("List state toString", () {
      final viewModel = TestViewModel();
      final listState = viewModel.createMutableStateList<String>(["a", "b", "c"]);
      expect(listState.toString(), "MutableScopedStateList<String>(list: [a, b, c])");
    });

    test("Map state toString", () {
      final viewModel = TestViewModel();
      final mapState = viewModel.createMutableStateMap<String, int>({"one": 1, "two": 2});
      expect(mapState.toString(), "MutableScopedStateMap<String, int>(map: {one: 1, two: 2})");
    });
  });
}
