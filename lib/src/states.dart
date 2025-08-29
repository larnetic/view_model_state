import 'dart:collection' show ListBase, MapBase;

import 'view_model.dart' show ViewModel;

/// An interface representing a state managed by a [ViewModel].
/// The state can be either mutable or immutable.
/// It provides a way to access the current value of the state.
///
/// When instantiated via a [ViewModel], the state is immutable from the ViewModelState itself,
/// but can be modified by other means, e.g. from a repository.
abstract interface class ViewModelState<T> {
  /// Gets the current value of the state.
  T get value;
}

/// Creates a mutable state object that holds a value of type [T].
/// The state can be modified by setting its [value] property.
///
/// The state will notify the associated [ViewModel] whenever its value changes,
/// allowing the ViewModel to notify its listeners.
class MutableViewModelState<T> implements ViewModelState<T> {
  T _value;
  final ViewModel _model;

  /// Creates a [MutableViewModelState] tied to the given [ViewModel].
  /// The state is initialized with the provided [initial] value.
  MutableViewModelState(this._value, this._model);

  /// Sets the value of the state to [newValue] and notifies the associated [ViewModel].
  /// Reading the current value of the state can be done via the [value] property.
  set value(T newValue) {
    _value = newValue;
    _model.notifyListeners();
  }

  @override
  T get value => _value;
}

/// A mutable list state that holds a list of items of type [T].
/// The list can be modified like a regular list, and any changes will notify
/// the associated [ViewModel].
///
/// The list will notify the ViewModel whenever it is modified, allowing the ViewModel
/// to notify its listeners.
class MutableViewModelStateList<T> extends ListBase<T> {
  // T must be nullable here, because when adding items to the list,
  // the index of that item will shortly contain a null value in dart.
  final List<T?> _list = [];
  final ViewModel _model;

  /// Creates a [MutableViewModelStateList] tied to the given [ViewModel].
  /// The list is initialized with the provided [initial] values.
  MutableViewModelStateList(this._model, [List<T> initial = const []]) {
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
      _model.notifyListeners();
    }
  }

  @override
  // T could be null here, because the user might want to add null values to the list.
  T operator [](int index) => _list[index] as T;

  @override
  void operator []=(int index, T value) {
    _list[index] = value;
    _model.notifyListeners();
  }
}

/// A mutable map state that holds a map of keys of type [K] and values of type [V].
/// The map can be modified like a regular list, and any changes will notify
/// the associated [ViewModel].
///
/// The map will notify the ViewModel whenever it is modified, allowing the ViewModel
/// to notify its listeners.
class MutableViewModelStateMap<K, V> extends MapBase<K, V> {
  final Map<K, V> _map = {};
  final ViewModel _model;

  /// Creates a [MutableViewModelStateMap] tied to the given [ViewModel].
  /// The map is initialized with the provided [initial] values.
  MutableViewModelStateMap(this._model, [Map<K, V> initial = const {}]) {
    _map.addAll(initial);
  }

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(K key, V value) {
    _map[key] = value;
    _model.notifyListeners();
  }

  @override
  void clear() {
    if (_map.isNotEmpty) {
      _map.clear();
      _model.notifyListeners();
    }
  }

  @override
  Iterable<K> get keys => _map.keys;

  @override
  V? remove(Object? key) {
    if (_map.containsKey(key)) {
      final removedValue = _map.remove(key);
      _model.notifyListeners();
      return removedValue;
    }
    return null;
  }
}
