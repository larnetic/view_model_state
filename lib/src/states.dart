import 'dart:collection' show ListBase, MapBase;

import 'package:view_model_state/src/state_scope.dart';

/// An interface representing a state managed by a [StateScope].
/// The state can be either mutable or immutable.
/// It provides a way to access the current value of the state.
///
/// When instantiated via a [StateScope], the state is immutable from the StateScopeState itself,
/// but can be modified by other means, e.g. from a repository.
abstract interface class ScopedState<T> {
  /// Gets the current value of the state.
  T get value;
}

/// Creates a mutable state object that holds a value of type [T].
/// The state can be modified by setting its [value] property.
///
/// The state will notify the associated [StateScope] whenever its value changes,
/// allowing the StateScope to notify its listeners.
class MutableScopedState<T> implements ScopedState<T> {
  T _value;
  final StateScope _scope;

  /// Creates a [MutableScopedState] tied to the given [StateScope].
  /// The state is initialized with the provided [initial] value.
  MutableScopedState(this._value, this._scope);

  /// Sets the value of the state to [newValue] and notifies the associated [StateScope].
  /// Reading the current value of the state can be done via the [value] property.
  set value(T newValue) {
    _value = newValue;
    _scope.update();
  }

  @override
  T get value => _value;

  @override
  String toString() => '$runtimeType(value: $_value)';
}

/// A mutable list state that holds a list of items of type [T].
/// The list can be modified like a regular list, and any changes will notify
/// the associated [StateScope].
///
/// The list will notify the ViewModel whenever it is modified, allowing the StateScope
/// to notify its listeners.
class MutableScopedStateList<T> extends ListBase<T> {
  // T must be nullable here, because when adding items to the list,
  // the index of that item will shortly contain a null value in dart.
  final List<T?> _list = [];
  final StateScope _scope;

  /// Creates a [MutableScopedStateList] tied to the given [StateScope].
  /// The list is initialized with the provided [initial] values.
  MutableScopedStateList(this._scope, [List<T> initial = const []]) {
    _list.addAll(initial);
  }

  @override
  int get length => _list.length;

  @override
  set length(int newLength) {
    bool shouldNotify = newLength < _list.length;
    _list.length = newLength;
    if (shouldNotify) {
      // Only notify if items were removed
      // This is necessary, because in dart, adding items to a list causes
      // the index of that item to contain a null value first, which would
      // cause a notifyListeners call.
      _scope.update();
    }
  }

  @override
  // T could be null here, because the user might want to add null values to the list.
  T operator [](int index) => _list[index] as T;

  @override
  void operator []=(int index, T value) {
    _list[index] = value;
    _scope.update();
  }

  @override
  String toString() => '$runtimeType(list: $_list)';
}

/// A mutable map state that holds a map of keys of type [K] and values of type [V].
/// The map can be modified like a regular list, and any changes will notify
/// the associated [StateScope].
///
/// The map will notify the StateScope whenever it is modified, allowing the StateScope
/// to notify its listeners.
class MutableScopedStateMap<K, V> extends MapBase<K, V> {
  final Map<K, V> _map = {};
  final StateScope _scope;

  /// Creates a [MutableScopedStateMap] tied to the given [StateScope].
  /// The map is initialized with the provided [initial] values.
  MutableScopedStateMap(this._scope, [Map<K, V> initial = const {}]) {
    _map.addAll(initial);
  }

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(K key, V value) {
    _map[key] = value;
    _scope.update();
  }

  @override
  void clear() {
    if (_map.isNotEmpty) {
      _map.clear();
      _scope.update();
    }
  }

  @override
  Iterable<K> get keys => _map.keys;

  @override
  V? remove(Object? key) {
    if (_map.containsKey(key)) {
      final removedValue = _map.remove(key);
      _scope.update();
      return removedValue;
    }
    return null;
  }

  @override
  String toString() => '$runtimeType(map: $_map)';
}
