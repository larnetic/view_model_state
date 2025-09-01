import 'package:flutter/foundation.dart' show ChangeNotifier, ValueNotifier;
import 'states.dart';

/// A base class for view models that manage state and notify listeners of changes.
///
/// A ViewModel is responsible for holding and managing the state of a part of the UI.
/// It extends [ChangeNotifier], allowing it to notify listeners when its state changes.
/// ViewModels can create and manage various types of state, including primitive values,
/// lists, and state derived from [ValueNotifier]s, [Stream]s, or [Future]s.
///
/// ViewModels also handle the disposal of resources when they are no longer needed.
/// When a ViewModel is disposed, it will call any registered disposal callbacks
/// to clean up resources such as stream subscriptions or listeners on ValueNotifiers.
/// ViewModels should be disposed of when they are no longer needed to prevent memory leaks.
///
/// Example usage:
/// ```dart
/// class MyViewModel extends ViewModel {
///   // late is important because otherwise, `this` cannot be passed to the state.
///   late final counter = MutableViewModelState<int>(0, this);
/// }
/// ```
///
/// The above example creates a ViewModel with a mutable integer state initialized to 0.
///
/// There also exist helper methods to create states. These methods automatically
/// register disposal callbacks to clean up resources when the ViewModel is disposed.
/// ```dart
/// class MyViewModel extends ViewModel {
///   late final primitiveState = createMutableState(0); // Primitive mutable state: int
///   late final listState = createMutableStateList<String>(); // List mutable state: List<String>
///   late final notifierState = createStateFromValueNotifier(ValueNotifier<int>(0)); // State from ValueNotifier
///   late final streamState = createStateFromStream(Stream<int>.periodic(Duration(seconds: 1), (x) => x), 0); // State from Stream
///   late final futureState = createStateFromFuture(Future<int>.delayed(Duration(seconds: 1), () => 42), 0); // State from Future
/// }
/// ```
abstract class ViewModel extends ChangeNotifier {
  final _disposeCallbacks = List<Function>.empty(growable: true);

  /// Registers a [callback] to be called when the ViewModel is disposed.
  /// This can be used to clean up resources such as stream subscriptions
  /// or listeners on ValueNotifiers.
  void addDisposeCallback(Function callback) {
    _disposeCallbacks.add(callback);
  }

  @override
  void dispose() {
    onDispose();
    for (final callback in _disposeCallbacks) {
      callback();
    }
    _disposeCallbacks.clear();
    super.dispose();
  }

  @override
  void notifyListeners() {
    onUpdate();
    super.notifyListeners();
  }

  /// Override this method to perform actions whenever the ViewModel is updated.
  /// This method is called before notifying listeners of changes.
  /// It can be used to perform side effects or additional logic when the state changes.
  ///
  /// Make sure to not call [notifyListeners] within this method to avoid infinite loops.
  void onUpdate() {}

  /// Override this method to perform actions when the ViewModel is disposed.
  /// This method is called before the disposal callbacks are executed.
  /// It can be used to perform any necessary cleanup or finalization logic.
  ///
  /// Make sure to call `super.onDispose()` if you override this method.
  void onDispose() {}
}

extension StateHelpers on ViewModel {
  /// Creates a mutable state object that is tied to this ViewModel.
  ///
  /// The state is initialized with the provided [initial] value.
  /// The created state can be read and modified via its `value` property.
  /// The type of the state is determined by the type of [initial].
  /// The state will notify listeners of changes and will be disposed of
  /// when the ViewModel is disposed.
  ///
  /// Example usage:
  /// ```dart
  /// class MyViewModel extends ViewModel {
  ///    // Creates a mutable state of type int initialized to 0.
  ///   late final counter = createMutableState(0);
  /// }
  MutableViewModelState<T> createMutableState<T>(T initial) {
    return MutableViewModelState<T>(initial, this);
  }

  /// Creates a mutable list state object that is tied to this ViewModel.
  ///
  /// The created list state can be manipulated like a regular list.
  /// The type of the list elements is determined by the generic type [T].
  /// The list state will notify listeners of changes and will be disposed of
  /// when the ViewModel is disposed.
  ///
  /// Example usage:
  /// ```dart
  /// class MyViewModel extends ViewModel {
  ///    // Creates a mutable list that is empty initially.
  ///   late final items = createMutableStateList<String>();
  ///   // Creates a mutable list initialized with some values.
  ///   late final numbers = createMutableStateList<int>([1, 2, 3]);
  /// }
  MutableViewModelStateList<T> createMutableStateList<T>(
      [List<T> initial = const []]) {
    return MutableViewModelStateList<T>(this, initial);
  }

  /// Creates a mutable map state object that is tied to this ViewModel.
  ///
  /// The created map state can be manipulated like a regular map.
  /// The type of the map elements is determined by the generic keys [K] and values [V].
  /// The map state will notify listeners of changes and will be disposed of
  /// when the ViewModel is disposed.
  ///
  /// Example usage:
  /// ```dart
  /// class MyViewModel extends ViewModel {
  ///    // Creates a mutable map that is empty initially.
  ///   late final items = createMutableStateMap<String, String>();
  ///   // Creates a mutable map initialized with some values.
  ///   late final numbers = createMutableStateList<String, int>({"one": 1, "two": 2});
  /// }
  MutableViewModelStateMap<K, V> createMutableStateMap<K, V>(
      [Map<K, V> initial = const {}]) {
    return MutableViewModelStateMap<K, V>(this, initial);
  }

  /// Creates an (from the state itself) immutable state object that reflects the value of the given [notifier].
  /// You can modify the state by changing the value of the [notifier].
  ///
  /// The state will be initialized with the current value of the [notifier]
  /// and will update whenever the [notifier]'s value changes.
  /// The state will notify listeners of changes and will be disposed of
  /// when the ViewModel is disposed.
  ///
  /// Example usage:
  /// ```dart
  /// final notifier = ValueNotifier<int>(0);
  /// class MyViewModel extends ViewModel {
  ///    // Creates a mutable state of type int from a given ValueNotifier.
  ///   late final notifierState = createStateFromValueNotifier(notifier);
  /// }
  ViewModelState<T> createStateFromValueNotifier<T>(ValueNotifier<T> notifier) {
    final state = createMutableState(notifier.value);
    void listener() {
      state.value = notifier.value;
    }

    notifier.addListener(listener);
    addDisposeCallback(() => notifier.removeListener(listener));
    return state;
  }

  /// Creates an (from the state itself) immutable state object that reflects the value of the given [stream].
  /// The state can be modified by the stream emitting new values.
  ///
  /// The state is initialized with the provided [initial] value.
  /// The state will update whenever the [stream] emits a new value.
  /// The state will notify listeners of changes and will be disposed of
  /// when the ViewModel is disposed.
  ///
  /// Example usage:
  /// ```dart
  /// class MyViewModel extends ViewModel {
  ///   // Creates a mutable state of type int from a given Stream.
  ///   late final streamState = createStateFromStream(Stream<int>.periodic(Duration(seconds: 1), (x) => x), 0);
  /// }
  ViewModelState<T> createStateFromStream<T>(Stream<T> stream, T initial) {
    final state = createMutableState(initial);
    final sub = stream.listen((value) {
      state.value = value;
    });

    addDisposeCallback(() => sub.cancel());
    return state;
  }

  /// Creates an (from the state itself) immutable state object that reflects the value of the given [future].
  /// The state can be modified by the future completing with a value.
  ///
  /// The state is initialized with the provided [initial] value.
  /// The state will update when the [future] completes with a value.
  /// The state will notify listeners of changes and will be disposed of
  /// when the ViewModel is disposed.
  ///
  /// Example usage:
  /// ```dart
  /// class MyViewModel extends ViewModel {
  ///   // Creates a mutable state of type int from a given Future.
  ///   late final futureState = createStateFromFuture(Future<int>.delayed(Duration(seconds: 1), () => 42), 0);
  /// }
  ViewModelState<T> createStateFromFuture<T>(Future<T> future, T initial) {
    return createStateFromStream(future.asStream(), initial);
  }
}
